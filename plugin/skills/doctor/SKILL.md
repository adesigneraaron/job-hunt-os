---
name: doctor
description: Check that Job-Hunt OS can actually run — Chrome for PDF rendering, python3, PyMuPDF, the workspace, and the profile's completeness. Use when a Job-Hunt OS command fails, when PDFs won't render, or when the user asks whether their setup is working or how complete their profile is.
---

# Doctor

Report what works and what doesn't. Fix nothing without asking.

## 1. PDF rendering

```
bash <plugin>/scripts/render_pdf.sh --check
```
Reports which browser it found. If none: tell the user to install Google Chrome
or Chromium, or to set `JOBHUNT_CHROME` to their browser binary. This is the
single most common setup failure.

## 2. Python

```
python3 -c "import fitz; print('pymupdf', fitz.__doc__)" 2>&1
```
PyMuPDF is used only to assert resumes stay one page. If missing, say it's
optional and give the install line: `pip3 install pymupdf`.

## 3. Workspace

Locate `job-hunt/` (CWD, then upward, then `${CLAUDE_PLUGIN_DATA}/workspace.json`).
Report its path, or that none exists and `/job-hunt-os:onboard` will create one.

Confirm the expected subdirectories and `config/settings.json` exist.

## 4. Profile completeness

Read `profile/master-profile.md` and report:

- count of remaining `«»` markers, and which sections they're in
- **roles with a real metric, out of total roles** — the number that matters
- whether `resume-base.html` exists and has been rendered

If a role has no metric, name it and say what to run:
`/job-hunt-os:onboard metrics`.

## 5. Tracker

Read `config/settings.json`. For `"local"`, confirm `tracker/applications.csv`
exists and report the row count. For `"sheets"`, confirm a webhook URL is
configured — **never print the URL itself**, only whether it's present.

## Output

A short status list — one line per check, pass/fail, and the exact command to
fix each failure. No prose paragraphs.
