---
name: formassist
description: Fill a job application form in the browser from a package already built by apply — the user reviews everything and clicks Submit themselves. Use when the user wants help filling out an application form, entering an application on a company site or ATS, or says they're ready to submit an application they've prepared.
---

# Form assist

Transcribe a finished application package into the real form, with the user
present.

**The user always reviews and clicks Submit. Never submit, and never click any
final send / apply / confirm button yourself.** This is transcription with
judgment, not authorship — the package already holds the authored answers.

**Input (`$ARGUMENTS`):** the application slug, optionally followed by a form
URL if it differs from the one in `jd.md`.

## 1. Load the package

From `<workspace>/applications/<slug>/`: `jd.md` (the URL is near the top),
`cover-letter.md`, `common-questions.md`, `prep-sheet.md`. Plus
`<workspace>/profile/master-profile.md` for contact details, links, and the
verbatim education summaries.

Upload paths: `resume.pdf`, `cover-letter.pdf`, and — if the user has one —
`<workspace>/profile/portfolio-onepager.pdf`.

## 2. Open the form

Prefer **Claude in Chrome** so the user's logged-in sessions and real file
uploads work. Load the tools in one batched ToolSearch (`tabs_context`,
`navigate`, `read_page`, `computer`, `form_input`, `file_upload`). Fall back to
the Browser pane if Chrome isn't connected.

If the page requires **creating an account or logging in — stop and hand it to
the user.** Never create accounts and never enter passwords. Resume once
they're in.

## 3. Fill, mapped from the package

Walk the form top to bottom with `read_page`. For each field:

- **Contact and basics** → from the profile.
- **Resume / cover letter uploads** → `file_upload` with the package PDFs. If
  the upload fails, give the user the exact path to drag in.
- **"Why us" / motivation / fit questions** → from `common-questions.md`, which
  is already written for this role. Trim to character limits, keep their voice.
- **Education** → the verbatim summaries in the profile. Use exact months if
  the form demands them.
- **Salary** → follow the guidance in `common-questions.md` for this role. If
  it's free text and unclear, **ask rather than guess.**
- **Links** → portfolio and LinkedIn from the profile.

## 4. Fields you never fill

Leave these blank, list them clearly, and let the user answer them live:

- **Work authorisation / visa / right-to-work / citizenship** — always theirs
  to answer, truthfully.
- **EEO, demographic, disability, and veteran surveys** — theirs to answer or
  decline.
- Anything requiring credentials, payment details, government ID, or a national
  insurance / social security number.
- **Any question whose truthful answer you don't have.** Ask; never invent one.

## 5. Handoff

- Summarise what was filled, field by field, and where each answer came from.
- List the fields left blank and waiting on them.
- Tell them to review the whole form and **click Submit themselves.**
- Once they confirm it's submitted, append `submitted <date> via <ats>` to
  `applications/<slug>/jd.md` and update the tracker row's status to "Applied".

Tone: fast, quiet, precise.
