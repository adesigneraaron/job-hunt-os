---
name: mock
description: Run a coached mock interview using the user's own profile and application packages, grading each answer and tracking weak spots over time. Use when the user wants to practise for an interview, rehearse answers, prepare for a specific company's interview, or work on behavioural or portfolio questions.
---

# Mock interview

A coached rehearsal built on the user's real material.

**Input (`$ARGUMENTS`), any of:**
- a company slug → weight questions toward that role's `prep-sheet.md`
- a category (`behavioural`, `craft`, `portfolio`, `exercise`) → focus there
- empty → a balanced set of five

## Setup

Read `<workspace>/profile/master-profile.md` and anything in
`<workspace>/interview-prep/`. If that folder is empty, seed it — a question
bank and a story bank built from the profile — before starting. Don't assume
files exist.

If the profile's story bank is still mostly `«»`, say so up front: these
answers get much better once there's raw material, and this session is a good
way to generate it.

## Running it

**One question at a time.** Ask, wait for the full answer, grade it, then move
on. Never show the next question alongside the last one's feedback.

After each answer, grade out of 5 on:

- **Structure** — situation → action → result, or a clear equivalent
- **Specificity** — real numbers, names, and details rather than generalities
- **Relevance** — actually answers what was asked
- **Concision** — roughly 90 seconds spoken; flag rambling
- **Delivery** — hedging, filler, burying the point

Give one concrete rewrite of the weakest sentence. Not a general note — the
actual better sentence, so they can hear the difference.

Where an answer surfaces a story or a metric that isn't in the profile yet,
point it out and offer to add it. This is how the story bank gets filled.

## Close

- Score summary across the session.
- The two things to fix before the real interview, in priority order.
- Append the session to `<workspace>/interview-prep/practice-log.md` and update
  `weak-spots.md` so patterns show up across sessions.
- Suggest practising the weakest answer out loud — reading it back is a
  different skill from writing it.
