# Publishing the tracker template (maintainer only)

One-time, ~10 minutes. Produces the link that `docs/sheets-setup.md` points at.

Do this with a **throwaway or secondary Google account if you can** — see the
warning in step 5 about what a template copy carries with it.

## 1. Create the sheet

New Google Sheet → name it **Job-Hunt OS — Tracker**.

Leave it empty. The setup wizard creates every tab and header, and that's the
path users actually exercise, so it should be the path you test.

## 2. Add the script

**Extensions → Apps Script**. Delete the placeholder `myFunction`, paste all of
[`plugin/scripts/apps-script.gs`](../../plugin/scripts/apps-script.gs), and save.

Rename the Apps Script project to **Job-Hunt OS Tracker** — this name is what
users see in the authorisation dialog, and "Untitled project" makes an already
scary screen worse.

Leave `SHEET_ID` empty. The script is bound to this sheet and finds it itself.

## 3. Test it as a user would

Reload the sheet. You should see a **Job-Hunt** menu.

- **⚙ Set up (run me first)** → authorise → confirm the dialog reports tabs
  created, hourly scan installed, and your email detected
- **✓ Check my setup** → everything OK
- **Scan inbox now** → check the Email Log tab

Fix anything odd here, in the sheet, then copy the corrected script back into
the repo so the two don't drift.

## 4. Remove your own data

Before sharing, delete every row the test produced:

- **Applications**, **Email Log**, **Rejected** tabs → delete all rows below the
  header
- **Extensions → Apps Script → Project Settings → Script Properties** → delete
  `SEEN_IDS`, `SETUP_DONE_AT`, and `SELF_EMAIL` if present

`SEEN_IDS` holds Gmail message identifiers from your own inbox. It is the one
thing here that would genuinely leak, so check it specifically.

## 5. Share it

**Share → General access → Anyone with the link → Viewer.**

> **What a copy carries.** When someone copies this sheet they get the script,
> and the script is yours in the sense that your name appears as its author in
> the authorisation dialog. They do *not* get your data, your triggers, your
> Script Properties, or any access to your account — a copy is genuinely theirs
> and runs entirely as them. But your name is attached, which is the reason to
> consider a secondary account.

Take the URL and replace the `/edit` at the end with `/copy`:

```
https://docs.google.com/spreadsheets/d/FILE_ID/copy
```

That makes the link open straight into a "Make a copy?" prompt instead of a
read-only sheet people then have to work out what to do with.

## 6. Wire it into the docs

Replace `TEMPLATE_URL_GOES_HERE` in `docs/sheets-setup.md` with that `/copy`
URL, then commit.

```bash
grep -rn "TEMPLATE_URL_GOES_HERE" docs/
```

## Updating the script later

Copies are snapshots — they do **not** update when you change the template.
People who already copied it keep the old version.

So for anything but a trivial fix:

1. Update the template sheet's script
2. Update `plugin/scripts/apps-script.gs` in the repo to match
3. Note it in the release notes, and tell existing users to paste the new
   version over theirs (Extensions → Apps Script → select all → paste → save)

Because of that, keep the script conservative. A bug you ship here has a long
tail you can't reach.
