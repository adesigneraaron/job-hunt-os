---
name: onboard
description: Build or update your Job-Hunt OS master profile from an existing resume, then fill the gaps by interview. Use when setting up Job-Hunt OS for the first time, when the user says they want to onboard, create their profile, import their resume, or when any other Job-Hunt OS command finds no profile. Also use to revisit one section (e.g. "onboard skills").
---

# Onboard

Build `master-profile.md` — the single source of truth every other Job-Hunt OS
command reads. Parse whatever resume the user already has, then interview only
what's missing.

**Argument:** optional section name to revisit (`contact`, `roles`, `metrics`,
`location`, `comp`, `lenses`, `suppress`, `projects`, `education`, `stories`).
With no argument, run the full flow — resuming if a partial profile exists.

## Rules

- **Never invent a fact.** Unanswered fields stay `«»`. A fabricated metric is
  worse than a blank one — the user has to defend every line in an interview.
- **One question at a time.** Wait for the answer. No walls of questions.
- **Write after every phase** so the flow can be interrupted and resumed.
- Never write anything asserting residency, citizenship or work authorisation.
  Record posture only; the user answers those questions on forms themselves.

## Phase 0 — Workspace

1. Look for an existing workspace: `job-hunt/` in the CWD, then walk up; then
   the path recorded in `${CLAUDE_PLUGIN_DATA}/workspace.json`.
2. If found and `profile/master-profile.md` exists → say what's already filled
   and resume at the first incomplete phase, or jump to the requested section.
3. If not found, confirm the location (default `./job-hunt/`) and scaffold:
   ```
   bash <plugin>/scripts/init_workspace.sh <path>
   ```
4. Run the `doctor` skill's checks. Report anything missing **now** — finding
   out Chrome is absent after a 20-minute interview is a bad experience.

## Phase 1 — Ingest

Ask for a resume: PDF, DOCX, plain text, or a LinkedIn data export. Read it
(use the `pdf` or `docx` skills for those formats).

If they don't have one, say so plainly — "no problem, the questions cover the
same ground" — and go straight to Phase 3 with an empty profile.

## Phase 2 — Extract

Copy `<plugin>/templates/master-profile.template.md` to
`<workspace>/profile/master-profile.md` and fill everything the resume
supports. Mark everything else `«»`.

Be conservative. If the resume says "improved conversion" with no number, that
is **not** a metric — leave `metrics:` empty and let Phase 3 ask.

Then show a compact summary — roles found, which have metrics, what's still
open. Not a wall of text, and not the file contents.

## Phase 3 — Gap interview

Follow `<plugin>/reference/onboarding-questions.md` in order, asking only about
`«»` fields. Section 5 (per-role metrics) is the highest-value part of this
whole system: ask twice for a number, then fall back to scope, and never
fabricate. Sections 8–10 are explicitly skippable.

Write to the profile as you go, section by section.

## Phase 4 — Generate the scout config

From the answers to sections 2–4 plus domains inferred from their history,
write `<workspace>/config/scout-config.md` from
`<plugin>/templates/scout-config.template.md`. Keep it plain English — the user
edits this file directly to retune discovery later.

Also write `<workspace>/config/settings.json`:
```json
{ "tracker": "local", "workspace_version": 1 }
```

## Phase 5 — Build the base resume

Fill every `<!--FILL:...-->` region of
`<plugin>/templates/resume-template.html` from the profile → write to
`<workspace>/profile/resume-base.html` → render:

```
bash <plugin>/scripts/render_pdf.sh <workspace>/profile/resume-base.html <workspace>/profile/resume-base.pdf
```

Verify it is one page:
```
bash <plugin>/scripts/pagecount.sh <workspace>/profile/resume-base.pdf
```
If it's over one page, cut the least-relevant bullets and re-render — don't
shrink the type.

Send the PDF to the user with `SendUserFile`. This is the first tangible payoff
and their first chance to see whether the system understood them. Offer one
round of corrections and apply them to the **profile**, then re-render, so the
fix persists into every future application.

## Phase 6 — Report

- What's filled; what's still `«»`.
- **Profile strength:** how many roles carry a real metric, out of how many.
  State it plainly — that ratio predicts resume quality more than anything else.
  Count roles as the `###` blocks inside `## Experience` only; a role has a
  metric when its `metrics:` list holds at least one non-`«»` entry.
- What to run next: `/job-hunt-os:apply <job-url>`.
- How to improve later: re-run `/job-hunt-os:onboard <section>` any time.
