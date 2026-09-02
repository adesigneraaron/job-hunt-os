// Job-Hunt OS — Google Sheets Apps Script.
// Two jobs in one script:
//   1) doPost()    — webhook receiver: /apply appends application/contact rows.
//   2) scanInbox() — reads Gmail on a timer and AUTO-UPDATES application Status
//                    from confirmation / rejection / interview emails.
//
// SETUP (one time):
//   • Open your "Job-Hunt Tracker" Sheet → Extensions → Apps Script.
//   • Replace the file contents with this, Save.
//   • Run scanInbox once (Run ▸ scanInbox). Google will ask you to authorize
//     Gmail + Sheets access — that's expected; this script runs as you, in your
//     account, and nothing leaves Google.
//   • Add a time trigger: clock icon (Triggers) → Add Trigger → function
//     scanInbox, event source "Time-driven", e.g. Hour timer / every hour.
//   • The web-app deployment for /apply keeps working; no need to redeploy.
//   • Reload the Sheet once — a "Job-Hunt" menu appears with "Scan inbox now"
//     so you can run a scan on demand instead of waiting for the timer.
//
// WHAT IT TOUCHES:
//   • Applications tab — updates the Status cell (col D) + appends an audit note
//     to Notes (col J) on the matched row. This is the real status change.
//   • Rejected tab — rejected rows are MOVED here out of Applications, so your
//     working list only shows live opportunities. Nothing is deleted.
//   • Email Log tab — appends one receipt row per action (updated / skipped /
//     quieted / moved). Audit trail only; never changes your tracker data.
//   • Gmail — confirmed rejections get "Job Hunt/Rejections" and application
//     receipts get "Job Hunt/Applied"; both are marked read and archived out of
//     the inbox. Archiving is what stops the phone notification. INTERVIEW mail is
//     never touched. Nothing is ever deleted, and the scanner still finds archived
//     mail (buildQuery_ has no in:inbox), so this is not self-blinding.
//
// ORDER MATTERS: a rejection is classified → logged → the row is updated → and
// only THEN is the email quieted. Anything the classifier isn't sure about stays
// in the inbox where you'll see it. Failing loud beats hiding silently.
//
// SAFEGUARDS (because this auto-updates):
//   • No downgrades — status only moves forward: Applied → Interview → Rejected/Offer.
//     A stray "thanks for applying" can't knock an Interview row back to Applied,
//     and a terminal status (Rejected/Offer/Hired) is never overwritten.
//   • Full audit trail — every change is logged to an "Email Log" tab AND noted on
//     the row, so a wrong match is visible and reversible, never silent.
//   • Processed emails are remembered (by message id) so nothing double-fires.

// ============================ CONFIG ============================

var HEADERS = {
  'Applications': ['Company','Job Title','Date Applied','Status','Salary Expectation',
                   'Location','Remote?','JD Link','Resume File','Notes'],
  'Contacts':     ['Name','Company','Relationship','Can refer to',
                   'Warm-intro status','Last contact','Notes'],
  'Email Log':    ['Scanned at','Company matched','Detected','Old status','New status',
                   'Action','From','Subject'],
  'Rejected':     ['Company','Job Title','Date Applied','Status','Salary Expectation',
                   'Location','Remote?','JD Link','Resume File','Notes','Filed on']
};

// ---------------- Rejection quieting (added 2026-08-07) ----------------
// Goal: rejections stop reaching your eyes day-to-day, but never stop being tracked.
// Nothing is hidden until AFTER it has been classified, logged, and (where possible)
// matched to a row — so "quiet" always comes second to "recorded".
// Nested labels — the "Job Hunt" parent is created automatically by the slash.
var REJECT_LABEL   = 'Job Hunt/Rejections'; // confirmed rejections
var APPLIED_LABEL  = 'Job Hunt/Applied';    // application receipts ("thanks for applying")
var REJECTED_TAB   = 'Rejected';            // Sheet tab that rejected rows are moved into.

var ARCHIVE_REJECTIONS           = true;  // pull confirmed rejections out of the inbox
var ARCHIVE_UNMATCHED_REJECTIONS = true;  // also quiet clear rejections we can't tie to a row
var MOVE_REJECTED_ROWS           = true;  // relocate rejected rows to the Rejected tab

var ARCHIVE_APPLIED           = true;   // pull application receipts out of the inbox too
var ARCHIVE_UNMATCHED_APPLIED = false;  // BUT leave a receipt we can't tie to a row visible —
                                        // it usually means an application that never got logged.

// Interview emails are NEVER labelled or archived. They are the whole point of the exercise.

// IMPORTANT: GmailApp reads the mailbox of whoever RUNS this script. Your job emails
// live in the Gmail account you apply from, so this script must run as THAT account.
//   • If this script is BOUND to a tracker sheet you own → leave SHEET_ID ''.
//   • If you run it as a SEPARATE project that writes into a sheet
//     owned by another account → paste that sheet's ID here (the long string in its URL:
//     docs.google.com/spreadsheets/d/THIS_PART/edit). That account needs edit access.
var SHEET_ID = '';

var APP_TAB = 'Applications';
var COL = { company: 1, title: 2, date: 3, status: 4, notes: 10 }; // 1-based columns in Applications

var SCAN_WINDOW_DAYS = 45;   // only look at mail newer than this
var MAX_THREADS      = 150;  // safety cap per run
var BODY_SCAN_CHARS  = 1000; // classify on subject + first N chars of body only (intent is stated up front)

// Status cell background colors.
var STATUS_FILL = { rejected: '#ea9999', interview: '#ffe599', applied: '#e0e0e0' }; // red / yellow / light grey

// Skip your own replies and obvious job-board digests/alerts (not real status emails).
// YOUR OWN email address — so the scanner skips your own sent replies.
// Set this before first run.
var SELF_EMAIL = 'you@example.com';
var SELF_RE  = new RegExp(SELF_EMAIL.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
var NOISE_RE = /(job\s*alert|new\s+jobs\s+(for|matching)|recommended\s+for\s+you|jobs\s+you\s+may\s+be|jobs\s+for\s+you|weekly\s+(digest|job)|people\s+you\s+may\s+know|job\s+recommendations|based\s+on\s+your\s+profile)/i;

// Words stripped when normalizing a company name for matching.
var COMPANY_STOPWORDS = ['inc','llc','ltd','corp','co','company','software','technologies',
  'technology','finance','financial','digital','labs','lab','studio','studios','the','group',
  'services','information','solutions','systems','app','apps','hq'];

// Classification keywords. Order of checks below is REJECT → INTERVIEW → APPLIED
// (so "won't be moving forward to an interview" reads as a rejection, not an interview).
// REJECT — require genuine rejection phrasing tied to your application/candidacy,
// NOT a bare "unfortunately" or "we wish you" (those appear everywhere).
var RE_REJECT = /(not\s+(be\s+)?(moving|move|progress(ing)?|proceeding)\s+forward\s+with\s+(your|this)|(moving|move|going)\s+forward\s+with\s+other\s+candidates|decided\s+(not\s+to\s+(move|proceed)|to\s+(move|go)\s+(forward|ahead)\s+with\s+(other|another))|(will\s+not|won'?t)\s+be\s+(moving|proceeding|progressing|continuing)\s+(forward|with|ahead)|(go|going|gone)\s+with\s+(another|a\s+different)\s+candidate|filled\s+(the|this|our|a)\s+(?:\w+\s+){0,4}(position|role|opening)|(politely\s+|regretfully\s+|respectfully\s+)?declin(e|ed|ing)\s+(your|to\s+(move|proceed|advance))|regret\s+to\s+inform|unable\s+to\s+offer\s+you|your\s+application\s+(has\s+been\s+|was\s+)?(unsuccessful|not\s+successful)|not\s+(been\s+)?(selected|successful)\s+for\s+(this|the)|decided\s+to\s+pursue\s+other|not\s+moving\s+forward\s+at\s+this\s+time|(position|role|posting|opening)\s+(has|is|was|had)?\s*(now|officially|already|recently)?\s*(been\s+)?(filled|closed)\b|we\s+have\s+decided\s+not\s+to\s+proceed|not\s+to\s+proceed\s+with\s+your)/i;

// INTERVIEW — require a real invitation: the schedule/invite verb must be paired with an
// interview/call word. Bare "next steps" / "schedule" / "connect" no longer count.
var RE_INTERVIEW = /(invite\s+you\s+to\s+(an?\s+)?(interview|initial\s+call|phone\s+screen)|(like|love|want)(\s+to)?\s+(invite|schedule|set\s*up|arrange|book)\b[^.]{0,40}(interview|call|conversation|chat|screen|meet)|schedule\s+(a\s+|an\s+|your\s+)?(interview|call|phone\s+screen|screening|conversation|chat)|set\s*up\s+(a\s+|an\s+|some\s+)?(time|call|interview|chat|conversation)|(phone|video|initial|first|technical|onsite|final)\s+(screen|interview)\b|next\s+(round|stage)\b|move\s+you\s+(forward\s+)?to\s+the\s+next\s+(round|stage)|(your\s+)?availability\s+(for|to)\s+(a\s+|an\s+)?(call|interview|chat|conversation)|book\s+a\s+time\s+(to|for)|(would|we'?d|i'?d)\s+(like|love)\s+to\s+(chat|speak|talk|meet)[^.]{0,30}(about|regarding|discuss)[^.]{0,45}(role|position|opportunity|application))/i;

var RE_APPLIED = /((thank\s+you|thanks)\s+for\s+(applying|the\s+application|your\s+application|submitting)|application\s+(has\s+been\s+)?received|received\s+your\s+application|thank\s+you\s+for\s+your\s+(interest|application)|we'?ve\s+received\s+your|successfully\s+(applied|submitted)|application\s+(was\s+)?submitted|we\s+have\s+received\s+your\s+application)/i;

// Gmail search — narrow to likely job mail within the window, unread-or-read, in inbox+archive.
function buildQuery_() {
  var phrases = ['"thank you for applying"','"application received"','"received your application"',
    '"your application"','"move forward"','"other candidates"','"schedule"','"next steps"',
    '"interview"','"unfortunately"','applying'];
  return 'newer_than:' + SCAN_WINDOW_DAYS + 'd {' + phrases.join(' ') + '}';
}

// ============================ MENU: "Scan inbox now" ============================

// Adds a custom menu to the Sheet on open. Reload the Sheet after pasting to see it.
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Job-Hunt')
    .addItem('Scan inbox now', 'scanInboxMenu')
    .addItem('File rejected rows away', 'moveRejectedRowsMenu')
    .addItem('Recolor statuses', 'recolorStatusesMenu')
    .addToUi();
}

// Sweeps any row already marked Rejected into the Rejected tab, without scanning mail.
function moveRejectedRowsMenu() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var n = moveRejectedRows_(ss, ss.getSheetByName(APP_TAB), getOrCreateSheet_(ss, 'Email Log'));
  ss.toast(n + ' row(s) moved to the ' + REJECTED_TAB + ' tab', 'Job-Hunt', 5);
}

function recolorStatusesMenu() {
  var n = recolorAllStatuses();
  SpreadsheetApp.getActiveSpreadsheet().toast('Recolored ' + n + ' rows', 'Job-Hunt', 4);
}

// Runs a scan on demand and reports what it did via a toast (bottom-right popup).
function scanInboxMenu() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  ss.toast('Scanning your inbox…', 'Job-Hunt', 3);
  var r = scanInbox();
  var msg = r
    ? (r.updated + ' updated · ' + r.quieted + ' filed away · ' + r.moved + ' moved to ' +
       REJECTED_TAB + ' · ' + r.threads + ' emails scanned')
    : 'Nothing to scan.';
  ss.toast(msg, 'Job-Hunt · scan complete', 6);
}

// ============================ WEBHOOK (unchanged) ============================

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var tab = data.tab || 'Applications';
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var sheet = ss.getSheetByName(tab);
    if (!sheet) {
      sheet = ss.insertSheet(tab);
      if (HEADERS[tab]) sheet.appendRow(HEADERS[tab]);
    }
    if (sheet.getLastRow() === 0 && HEADERS[tab]) sheet.appendRow(HEADERS[tab]);
    sheet.appendRow(data.row);
    return ContentService
      .createTextOutput(JSON.stringify({ ok: true }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ ok: false, error: String(err) }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// ============================ INBOX SCANNER ============================

function ss_() {
  return SHEET_ID ? SpreadsheetApp.openById(SHEET_ID) : SpreadsheetApp.getActiveSpreadsheet();
}

function scanInbox() {
  var ss = ss_();
  var appSheet = ss.getSheetByName(APP_TAB);
  if (!appSheet || appSheet.getLastRow() < 2) return;
  var logSheet = getOrCreateSheet_(ss, 'Email Log');

  // Build the list of applications with a matchable company token.
  var lastRow = appSheet.getLastRow();
  var rows = appSheet.getRange(2, 1, lastRow - 1, COL.notes).getValues();
  var apps = [];
  for (var i = 0; i < rows.length; i++) {
    var company = String(rows[i][COL.company - 1] || '');
    var token = companyToken_(company);
    if (token.length >= 3) {
      apps.push({ rowIndex: i + 2, company: company, token: token,
                  status: String(rows[i][COL.status - 1] || ''),
                  notes: String(rows[i][COL.notes - 1] || '') });
    }
  }
  // NOTE: we deliberately do NOT bail when apps is empty. An empty tracker still
  // needs clear rejections quieted (they just log as unmatched).

  var seen = loadSeen_();
  var threads = GmailApp.search(buildQuery_(), 0, MAX_THREADS);
  var updated = 0, skipped = 0, quieted = 0, alreadySeen = 0;

  for (var t = 0; t < threads.length; t++) {
    var thread = threads[t];
    var msgs = thread.getMessages();
    var msg = msgs[msgs.length - 1];        // latest message in the thread
    var id = msg.getId();
    if (seen[id]) { alreadySeen++; continue; }  // already handled this exact message

    var from = msg.getFrom() || '';
    seen[id] = 1;                           // mark handled regardless (avoid re-scan churn)
    if (SELF_RE.test(from) || NOISE_RE.test(from)) continue;  // skip own replies + job-board digests

    var subject = msg.getSubject() || '';
    if (NOISE_RE.test(subject)) continue;
    var body = '';
    try { body = msg.getPlainBody() || ''; } catch (e2) { body = msg.getBody() || ''; }
    // Classify on subject + top of body only — intent is stated up front; avoids stray
    // words in long threads, footers, and signatures triggering a false match.
    var hay = (subject + '\n' + body.substring(0, BODY_SCAN_CHARS)).toLowerCase();

    var detected = classify_(hay);          // 'Rejected' | 'Interview' | 'Applied' | null
    if (!detected) continue;

    // Find the best application match: company token present as a whole word.
    var match = bestMatch_(apps, hay);

    if (!match) {
      // Can't tie this to a tracked row — recruiter mail that never names the company, or
      // a role logged under a different name. Rejections are still quieted (and logged as
      // unmatched, so the Email Log shows what was hidden with no row behind it). Receipts
      // are NOT, by default: an untracked "thanks for applying" usually means an
      // application that never made it into the sheet, which you want to notice.
      var allowUnmatched = detected === 'Rejected' ? ARCHIVE_UNMATCHED_REJECTIONS
                         : detected === 'Applied'  ? ARCHIVE_UNMATCHED_APPLIED
                         : false;
      var uRule = allowUnmatched ? quietRuleFor_(detected) : null;
      if (uRule && quietThread_(thread, uRule.label, uRule.archive)) {
        logSheet.appendRow([new Date(), '(no match)', detected, '', '',
                            'quieted (unmatched ' + detected.toLowerCase() + ')', from, subject]);
        quieted++;
      }
      continue;
    }

    var oldStatus = match.status;
    if (!canAdvance_(oldStatus, detected)) {
      // Can't advance — a duplicate rejection for a row we've closed, or a stale receipt
      // for one that has already moved on. No status change, but it should still leave
      // the inbox. (Interview never matches a rule, so it always stays put.)
      var tRule = quietRuleFor_(detected);
      var alsoQuieted = tRule ? quietThread_(thread, tRule.label, tRule.archive) : false;
      if (alsoQuieted) quieted++;
      logSheet.appendRow([new Date(), match.company, detected, oldStatus, oldStatus,
                          alsoQuieted ? 'quieted (already terminal)'
                                      : 'skipped (no downgrade / terminal)', from, subject]);
      skipped++;
      continue;
    }

    // Apply the update + audit note + color.
    appSheet.getRange(match.rowIndex, COL.status).setValue(detected);
    colorRow_(appSheet, match.rowIndex, detected);
    var note = match.notes + (match.notes ? '  ·  ' : '') +
               '[auto ' + fmtDate_(new Date()) + '] ' + detected + ' via ' + domainOf_(from);
    appSheet.getRange(match.rowIndex, COL.notes).setValue(note);
    match.status = detected;                // keep in-memory copy fresh
    match.notes = note;

    // Tracked first, quieted second: the row is already updated and logged by this point.
    var rule = quietRuleFor_(detected);
    var didQuiet = rule ? quietThread_(thread, rule.label, rule.archive) : false;
    if (didQuiet) quieted++;

    logSheet.appendRow([new Date(), match.company, detected, oldStatus, detected,
                        didQuiet ? 'updated + quieted' : 'updated', from, subject]);
    updated++;
  }

  saveSeen_(seen);

  // Done touching row indexes in the loop — safe to relocate rejected rows now.
  var moved = MOVE_REJECTED_ROWS ? moveRejectedRows_(ss, appSheet, logSheet) : 0;

  // Print a summary so a manual run from the editor isn't silent. If "skipped (already
  // seen before)" accounts for nearly every email, clear the seenIds script property —
  // the scanner has processed them on an earlier run and won't look at them again.
  Logger.log('scanInbox — ' + threads.length + ' emails found · ' + updated + ' rows updated · ' +
             quieted + ' filed away · ' + moved + ' rows moved to ' + REJECTED_TAB + ' · ' +
             skipped + ' skipped (terminal) · ' + alreadySeen + ' skipped (already seen before)');

  return { threads: threads.length, updated: updated, skipped: skipped,
           quieted: quieted, moved: moved, alreadySeen: alreadySeen };
}

// ---- Gmail quieting: label + archive a thread ----
var _labelCache = {};
function labelNamed_(name) {
  if (!_labelCache[name]) {
    _labelCache[name] = GmailApp.getUserLabelByName(name) || GmailApp.createLabel(name);
  }
  return _labelCache[name];
}

// Returns true if the thread was successfully filed away. Never throws — a Gmail
// hiccup must not abort the scan or lose the tracker update that preceded it.
function quietThread_(thread, labelName, doArchive) {
  try {
    thread.addLabel(labelNamed_(labelName));
    thread.markRead();                    // clears the unread badge
    if (doArchive) thread.moveToArchive(); // out of the inbox = no notification
    return true;
  } catch (err) {
    return false;
  }
}

// Which label/archive rule applies to a detected status. Returns null for anything
// that must stay in the inbox — notably 'Interview'.
function quietRuleFor_(detected) {
  if (detected === 'Rejected') return { label: REJECT_LABEL,  archive: ARCHIVE_REJECTIONS };
  if (detected === 'Applied')  return { label: APPLIED_LABEL, archive: ARCHIVE_APPLIED };
  return null;
}

// ---- move rejected rows out of Applications into the Rejected tab ----
// Iterates BOTTOM-UP so deleting a row never shifts the indexes we haven't checked yet.
// Only rank 3 (rejected) moves — Offer/Hired (rank 4) is terminal too but stays put.
function moveRejectedRows_(ss, appSheet, logSheet) {
  var last = appSheet.getLastRow();
  if (last < 2) return 0;
  var width = appSheet.getLastColumn();
  var vals = appSheet.getRange(2, 1, last - 1, width).getValues();
  var rejSheet = null, moved = 0, today = fmtDate_(new Date());

  for (var i = vals.length - 1; i >= 0; i--) {
    if (statusRank_(vals[i][COL.status - 1]) !== 3) continue;
    if (!rejSheet) rejSheet = getOrCreateSheet_(ss, REJECTED_TAB);
    rejSheet.appendRow(vals[i].concat([today]));
    appSheet.deleteRow(i + 2);
    moved++;
    if (logSheet) {
      logSheet.appendRow([new Date(), vals[i][COL.company - 1], 'Rejected',
                          vals[i][COL.status - 1], vals[i][COL.status - 1],
                          'moved to ' + REJECTED_TAB + ' tab', '', '']);
    }
  }
  return moved;
}

// ---- status color-coding ----
function fillFor_(status) {
  var s = String(status).toLowerCase();
  if (/reject|declin|unsuccess|not\s+selected|filled/.test(s)) return STATUS_FILL.rejected;   // red
  if (/interview/.test(s)) return STATUS_FILL.interview;                                        // yellow
  if (/applied|confirm|received/.test(s)) return STATUS_FILL.applied;                           // light grey
  return null; // anything else (e.g. "Ready to apply", "Offer") → clear
}
function colorRow_(sheet, rowIndex, status) {
  sheet.getRange(rowIndex, COL.status).setBackground(fillFor_(status)); // null resets to default
}
// Run this once from the editor (or the menu) to color every existing row by its current Status.
function recolorAllStatuses() {
  var sh = ss_().getSheetByName(APP_TAB);
  if (!sh || sh.getLastRow() < 2) return 0;
  var n = sh.getLastRow() - 1;
  var vals = sh.getRange(2, COL.status, n, 1).getValues();
  for (var i = 0; i < n; i++) colorRow_(sh, i + 2, vals[i][0]);
  return n;
}

// ---- classification ----
function classify_(hay) {
  if (RE_REJECT.test(hay))    return 'Rejected';
  if (RE_INTERVIEW.test(hay)) return 'Interview';
  if (RE_APPLIED.test(hay))   return 'Applied';
  return null;
}

// ---- company matching ----
function companyToken_(name) {
  var n = String(name).toLowerCase();
  n = n.replace(/\(.*?\)/g, ' ');                 // drop parentheticals like "(via recruiter)"
  n = n.replace(/[^a-z0-9 ]+/g, ' ');             // punctuation → space
  var words = n.split(/\s+/).filter(function (w) {
    return w && COMPANY_STOPWORDS.indexOf(w) === -1;
  });
  if (!words.length) return '';
  // Prefer the full remaining phrase; fall back to the longest distinctive word.
  var phrase = words.join(' ').trim();
  if (phrase.length >= 3 && phrase.indexOf(' ') === -1) return phrase; // single clean word
  var longest = words.slice().sort(function (a, b) { return b.length - a.length; })[0];
  return (phrase.length <= 24 ? phrase : longest);
}

function bestMatch_(apps, hay) {
  var best = null;
  for (var i = 0; i < apps.length; i++) {
    var tok = apps[i].token;
    var re = new RegExp('\\b' + tok.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'i');
    if (re.test(hay)) {
      if (!best || tok.length > best.token.length) best = apps[i]; // longest/most specific wins
    }
  }
  return best;
}

// ---- status precedence (only advance, never overwrite terminal) ----
function statusRank_(s) {
  s = String(s).toLowerCase();
  if (/reject|declin|not\s+selected|position\s+filled/.test(s)) return 3; // terminal
  if (/offer|hired/.test(s)) return 4;                                    // terminal
  if (/interview/.test(s)) return 2;
  if (/applied|confirm|received/.test(s)) return 1;
  return 0; // "Ready to apply" / blank / anything else
}
function canAdvance_(oldStatus, detected) {
  var oldR = statusRank_(oldStatus);
  if (oldR >= 3) return false;                 // don't touch terminal states
  var newR = detected === 'Rejected' ? 3 : detected === 'Interview' ? 2 : 1;
  return newR > oldR;                          // strictly forward only
}

// ---- helpers ----
function domainOf_(from) {
  var m = String(from).match(/@([a-z0-9.\-]+)/i);
  return m ? m[1] : from;
}
function fmtDate_(d) {
  return Utilities.formatDate(d, Session.getScriptTimeZone(), 'yyyy-MM-dd');
}
function getOrCreateSheet_(ss, name) {
  var sh = ss.getSheetByName(name);
  if (!sh) { sh = ss.insertSheet(name); if (HEADERS[name]) sh.appendRow(HEADERS[name]); }
  if (sh.getLastRow() === 0 && HEADERS[name]) sh.appendRow(HEADERS[name]);
  return sh;
}

// Clears the processed-message memory and immediately re-scans, in one action.
// Use this instead of deleting the seenIds property by hand: it can't be half-done,
// and no scheduled run can slip in between the clear and the scan to refill it.
// Pick "rescanEverything" from the editor's function dropdown and hit Run.
function rescanEverything() {
  PropertiesService.getScriptProperties().deleteProperty('seenIds');
  Logger.log('seenIds cleared — taking a fresh look at all mail in the window');
  return scanInbox();
}

// ---- processed-message memory (capped) ----
function loadSeen_() {
  var raw = PropertiesService.getScriptProperties().getProperty('seenIds');
  return raw ? JSON.parse(raw) : {};
}
function saveSeen_(seen) {
  var ids = Object.keys(seen);
  if (ids.length > 400) {                      // keep it small; drop oldest-ish
    var trimmed = {};
    ids.slice(ids.length - 400).forEach(function (k) { trimmed[k] = 1; });
    seen = trimmed;
  }
  PropertiesService.getScriptProperties().setProperty('seenIds', JSON.stringify(seen));
}
