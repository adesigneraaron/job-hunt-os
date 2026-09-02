---
name: apply
description: Turn one job posting into a complete tailored application package — resume, cover letter, application-form answers, and an interview prep sheet — then log it to your tracker. Use when the user shares a job posting URL or pastes a job description and wants to apply, tailor their resume for it, or build an application for it.
---

# Apply

One job posting in, a finished application package out. Efficient — don't ask
questions unless a step genuinely blocks.

**Input (`$ARGUMENTS`):** a job posting URL, or pasted job-description text.

## Source of truth

Read the workspace profile at `<workspace>/profile/master-profile.md`. It is the
**only** place facts come from.

**Never fabricate** a title, metric, date, employer, or skill. You may only
*select and rephrase* what's already in the profile. Requirements the user
doesn't meet go in a private "gaps" note at the end — never into the resume by
invention.

If there's no profile, stop and run `/job-hunt-os:onboard` first.

## Step 1 — Get the job description

- URL → fetch it, asking for title, company, responsibilities, requirements,
  location, and salary if posted.
- If the fetch comes back empty, short, or login-walled (common on LinkedIn,
  Indeed, and Workday) → **stop and ask the user to paste the text.** Never
  guess at a job description.
- Already pasted text → use it directly.

## Step 2 — Parse and set up

Extract: company, role title, seniority, location and remote policy, posted
salary, and the top 8–12 skills, keywords and themes.

If the profile defines more than one voice lens, pick the one that fits this
role and use its bullet set throughout.

Make a slug `company-role` (lowercase, hyphenated) and
`mkdir -p <workspace>/applications/<slug>`. Write the captured posting to
`jd.md` with the source URL and today's date at the top.

## Step 3 — Tailor the resume

Copy `<workspace>/profile/resume-base.html` → `applications/<slug>/resume.html`.
Edit **only** the text inside `<!--FILL:...-->` regions. Never touch the
`<style>` block or the structure.

- **HEADER title** — match the posting's title where that's an honest fit.
- **SUMMARY** — 2–4 sentences mirroring their language, built from real facts.
  Lead with the most relevant proof you actually have.
- **EXPERIENCE** — keep the most relevant roles and bullets, trim the rest.
  Rephrase toward the posting's keywords without changing what happened.
- **SKILLS** — reorder so the relevant categories lead; swap in real skills
  from the profile. Drop categories that don't apply rather than padding.

**Respect the profile's rules:**
- Anything in `suppress:` is omitted. If it carries an exception and this role
  matches it, **ask before including** — never default to it.
- Honour any `weighting:` note on a role (e.g. "≤1 bullet, don't lead with it").

**One page, always.** No emoji — headless Chrome renders them as empty boxes.
Plain glyphs (`•` `·` `–` `→` `★`) are fine.

Render and verify:
```
bash <plugin>/scripts/render_pdf.sh <workspace>/applications/<slug>/resume.html <workspace>/applications/<slug>/resume.pdf
python3 -c "import fitz,sys;print(fitz.open(sys.argv[1]).page_count)" <workspace>/applications/<slug>/resume.pdf
```
If it prints 2, cut the least-relevant bullets and re-render. Never shrink the
type to force a fit.

## Step 4 — Cover letter

Copy the cover-letter template → `applications/<slug>/cover-letter.html`. Fill
HEADER, DATE (today), ADDRESSEE, GREETING, and three body paragraphs:

- **Hook** — something specific about *this* company. If the paragraph could be
  pasted into another application unchanged, rewrite it.
- **Proof** — the most relevant real outcome, with its number, tied explicitly
  to what they said they need.
- **Close** — what they'd want to work on, and a plain next step.

250–320 words. Render to PDF, and also write `cover-letter.md` (same words,
plain text) for pasting into web forms.

## Step 5 — Application-form answers

Write `applications/<slug>/common-questions.md` in the user's voice, from real
facts:

- Why this company (needs a specific, researched reason — not flattery)
- Why you're a fit for this role
- Why you're looking, and why now
- Salary expectations — anchor to the posted band if there is one; otherwise
  leave a placeholder and flag it rather than inventing a number
- Every explicit screening question in the posting

## Step 6 — Prep sheet

Write `applications/<slug>/prep-sheet.md` from the profile and anything in
`<workspace>/interview-prep/`:

- 6–10 likely questions for this role
- Which of the user's stories to use for each
- 4–6 sharp questions to ask them, specific to the company
- A short pre-interview checklist

## Step 7 — Log it

```
python3 <plugin>/scripts/log_application.py --workspace <workspace> \
  --company "<company>" --title "<role>" --status "Ready to apply" \
  --location "<location>" --remote "<Yes/No/Hybrid>" --salary "<posted or blank>" \
  --jd-link "<url>" --resume "applications/<slug>/resume.pdf" --notes "<source>"
```

## Step 8 — Report

- What was produced, with paths.
- The top three ways the resume was tailored.
- **Gaps** — requirements the user doesn't clearly meet. Honest and private;
  these never appear in the application itself.
- Next step: `/job-hunt-os:formassist <slug>` to fill the form, or
  `/job-hunt-os:mock <company>` before an interview.
