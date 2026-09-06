---
name: doctor
description: Check that Job-Hunt OS can actually run — a browser for PDF rendering, Python, PyMuPDF, the workspace, and the profile's completeness. Use when a Job-Hunt OS command fails, when PDFs won't render, or when the user asks whether their setup is working or how complete their profile is.
---

# Doctor

Run the health check script and interpret the result. **Don't improvise shell
commands for this** — the script covers every check, is identical for every
user, and always exits 0, so a normal finding (no workspace yet, PyMuPDF not
installed) never surfaces as a red error.

```
bash <plugin>/scripts/doctor.sh
```

`<plugin>` is the directory containing this skill's parent — use
`${CLAUDE_PLUGIN_ROOT}` when it's set, otherwise resolve it from this file's own
path.

## What it checks

1. **PDF rendering** — which browser was found; warns on Windows if path
   conversion isn't available
2. **Python** — resolves `python3`, `python`, or `py`
3. **PyMuPDF** — optional; only used to assert resumes stay one page
4. **Workspace** — searched here, upward, then the plugin's data pointer
5. **Profile** — how many roles carry a real metric, and how many fields are
   still unfilled
6. **Base resume** — built and rendered?
7. **Tracker** — local CSV row count; whether a Sheets webhook is configured
   (never prints the URL)
8. **Applications** — how many packages exist

## Reporting it back

Show the output, then add one line of interpretation. Prioritise in this order:

- **A failing browser or Python check** blocks real work — lead with it and
  give the exact fix.
- **A weak profile** ("only 2 of 4 roles carry a real metric") is the most
  valuable thing you can tell them. That ratio predicts resume quality more
  than anything else in the system. Point at `/job-hunt-os:onboard metrics`.
- **No workspace** is expected on a first run, not a problem. Say so, and point
  at `/job-hunt-os:onboard`.

Don't restate every passing line in prose — the table already says it. Add
only what the user should do next.
