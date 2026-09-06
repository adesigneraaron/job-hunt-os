#!/usr/bin/env bash
# Job-Hunt OS health check. Deterministic, and ALWAYS exits 0 — a missing
# workspace or absent optional dependency is a finding to report, not a failure.
# Improvised shell for this produced red "Exit code 1" errors during checks that
# had actually succeeded.
set -uo pipefail
_src="${BASH_SOURCE[0]}"; _dir="${_src%/*}"; [[ "$_dir" == "$_src" ]] && _dir="."
HERE="$(cd "$_dir" && pwd)"
. "$HERE/_python.sh"

pass() { printf '  PASS   %s\n' "$*"; }
fail() { printf '  FAIL   %s\n' "$*"; }
skip() { printf '  ----   %s\n' "$*"; }

echo "Job-Hunt OS — health check"
echo

# --- 1. Browser -------------------------------------------------------------
if out="$(bash "$HERE/render_pdf.sh" --check 2>&1)"; then
  pass "PDF rendering — $(sed -n 's/^browser *: *//p' <<<"$out" | head -1)"
  grep -q 'WARNING' <<<"$out" && printf '         %s\n' "$(grep 'WARNING' <<<"$out")"
else
  fail "PDF rendering — no browser found"
  echo "         Install Chrome/Chromium/Edge, or set JOBHUNT_CHROME"
fi

# --- 2. Python --------------------------------------------------------------
if PY="$(find_python)"; then
  pass "Python — $("$PY" -V 2>&1)"
  if "$PY" -c "import fitz" >/dev/null 2>&1; then
    pass "PyMuPDF — installed (one-page checks enabled)"
  else
    skip "PyMuPDF — not installed (optional). Page checks skipped."
    echo "         Enable with: $PY -m pip install pymupdf"
  fi
else
  fail "Python — not found"
  echo "         Applications still build; tracker + page checks are skipped."
  skip "PyMuPDF — cannot check without Python"
fi

# --- 3. Workspace -----------------------------------------------------------
find_workspace() {
  [[ -n "${JOBHUNT_WORKSPACE:-}" && -d "${JOBHUNT_WORKSPACE:-}" ]] && { printf '%s' "$JOBHUNT_WORKSPACE"; return 0; }
  local d; d="$(pwd)"
  while :; do
    [[ -d "$d/job-hunt/profile" ]] && { printf '%s' "$d/job-hunt"; return 0; }
    [[ -d "$d/profile" && -d "$d/applications" ]] && { printf '%s' "$d"; return 0; }
    [[ "$d" == "/" || -z "$d" ]] && break
    d="$(cd "$d/.." && pwd)"
  done
  local ptr="${CLAUDE_PLUGIN_DATA:-}/workspace.json"
  if [[ -n "${CLAUDE_PLUGIN_DATA:-}" && -f "$ptr" ]]; then
    local w; w="$(sed -n 's/.*"workspace" *: *"\([^"]*\)".*/\1/p' "$ptr" | head -1)"
    [[ -n "$w" && -d "$w" ]] && { printf '%s' "$w"; return 0; }
  fi
  return 1
}

if WS="$(find_workspace)"; then
  pass "Workspace — $WS"
else
  fail "Workspace — none found"
  echo "         Searched from: $(pwd)"
  echo "         If that is not where you expected to be, cd to the right folder"
  echo "         first — the shell does not always sit where you started."
  echo "         Create one with:  /job-hunt-os:onboard"
  skip "Profile — no workspace yet"
  skip "Tracker — no workspace yet"
  echo
  echo "Everything above the workspace line is what matters for setup."
  echo "If those pass, you're ready to run /job-hunt-os:onboard."
  exit 0
fi

# --- 4. Profile -------------------------------------------------------------
PROFILE="$WS/profile/master-profile.md"
if [[ -f "$PROFILE" ]]; then
  # grep -c prints 0 AND exits 1 when there are no matches, so a "|| echo 0"
  # fallback appends a second zero and breaks the arithmetic test below.
  # Counting occurrences with -o | wc -l always yields exactly one number.
  gaps=$(grep -o '«' "$PROFILE" 2>/dev/null | wc -l | tr -d ' ')
  gaps=${gaps:-0}
  if [[ -n "${PY:-}" ]]; then
    read -r roles withm weak <<<"$("$PY" - "$PROFILE" <<'PYEOF'
import re, sys
s = open(sys.argv[1], encoding="utf-8", errors="replace").read()
exp = s.split("## Experience")[1].split("\n---")[0] if "## Experience" in s else ""
roles = re.split(r"^### ", exp, flags=re.M)[1:]
# A role heading still wrapped in «» is a template placeholder, not a job.
roles = [r for r in roles if "«" not in r.split("\n")[0]]
def metrics_body(r):
    """Text under `metrics:`, whether written inline or as an indented list.

    The old lookahead required another `key:` line after the block, so a role
    whose metrics were the LAST thing written scored zero despite having real
    numbers — and writing metrics last is completely natural by hand.
    """
    lines = r.split("\n")
    for i, line in enumerate(lines):
        m = re.match(r"\s*metrics:\s*(.*)$", line)
        if not m:
            continue
        inline = m.group(1).strip()
        if inline:
            return inline
        body = []
        for nxt in lines[i + 1:]:
            if not nxt.strip():
                continue
            # stop at the next field or the next role
            if re.match(r"\s*[A-Za-z_][A-Za-z0-9_ -]*:\s", nxt) or nxt.startswith("###"):
                break
            if re.match(r"\s*[A-Za-z_][A-Za-z0-9_-]*:$", nxt):
                break
            body.append(nxt.strip().lstrip("-").strip())
        return "\n".join(x for x in body if x)
    return ""

def has_metric(r):
    body = metrics_body(r)
    # ANY « means it is still guidance text, not a fact the user supplied.
    return bool(body) and "«" not in body
def label(r):
    h = r.split("\n")[0]
    h = re.sub(r"\s*\([^)]*\)\s*$", "", h).strip()   # drop trailing dates
    return h
weak = [label(r) for r in roles if not has_metric(r)]
print(len(roles), sum(1 for r in roles if has_metric(r)), "|".join(weak))
PYEOF
)"
    if [[ "${roles:-0}" -gt 0 ]]; then
      if [[ "$withm" == "$roles" ]]; then
        pass "Profile — $withm of $roles roles carry a real metric"
      else
        fail "Profile — only $withm of $roles roles carry a real metric"
        [[ -n "${weak:-}" ]] && echo "         No numbers yet: ${weak//|/, }"
        echo "         This is the strongest predictor of resume quality."
        echo "         Strengthen it with:  /job-hunt-os:onboard metrics"
      fi
    else
      fail "Profile — no roles found under ## Experience"
    fi
  else
    skip "Profile — found, but Python is needed to measure completeness"
  fi
  [[ "$gaps" -gt 0 ]] && echo "         $gaps unfilled «» field(s) remain"
else
  fail "Profile — not found at $PROFILE"
  echo "         Create it with:  /job-hunt-os:onboard"
fi

# --- 5. Base resume ---------------------------------------------------------
if [[ -f "$WS/profile/resume-base.html" ]]; then
  if [[ -f "$WS/profile/resume-base.pdf" ]]; then
    pass "Base resume — built ($(bash "$HERE/pagecount.sh" "$WS/profile/resume-base.pdf") page)"
  else
    skip "Base resume — HTML exists but has never been rendered"
  fi
else
  skip "Base resume — not built yet"
fi

# --- 6. Tracker -------------------------------------------------------------
MODE="local"
[[ -f "$WS/config/settings.json" ]] && MODE="$(sed -n 's/.*"tracker" *: *"\([^"]*\)".*/\1/p' "$WS/config/settings.json" | head -1)"
MODE="${MODE:-local}"
CSV="$WS/tracker/applications.csv"
if [[ -f "$CSV" ]]; then
  rows=$(( $(wc -l < "$CSV") - 1 )); (( rows < 0 )) && rows=0
  pass "Tracker — local CSV, $rows application(s) logged"
else
  fail "Tracker — applications.csv missing"
fi
if [[ "$MODE" == "sheets" ]]; then
  if [[ -n "${JOBHUNT_WEBHOOK_URL:-}" || -f "$HOME/.config/job-hunt-os/webhook-url.txt" ]]; then
    pass "Google Sheets — webhook configured"   # never print the URL itself
  else
    fail "Google Sheets — mode is 'sheets' but no webhook URL is configured"
    echo "         See docs/sheets-setup.md, step 3"
  fi
fi

# --- 7. Applications --------------------------------------------------------
if [[ -d "$WS/applications" ]]; then
  n=$(find "$WS/applications" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  pass "Applications — $n package(s) built"
fi

echo
exit 0
