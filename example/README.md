# Worked examples

Two fictional people, to show what the tool actually produces — and what it
refuses to produce.

## [`operations-manager/`](operations-manager/) — start here

A warehouse operations manager with a completely ordinary resume: duty-listing
bullets, filler summary, and **not a single number anywhere**. That's what most
real resumes look like.

| File | What it shows |
|---|---|
| `original-resume.txt` | What he started with |
| `interview-transcript.md` | The onboarding questions, and how he answered |
| `master-profile.md` | The profile that produced |
| `resume-before.pdf` / `resume-after.pdf` | Same template, same font — only the words differ |

**The whole point is in the transcript.** Asked what changed because he was
there, his first answer was *"I ran the warehouse. Things ran smoother, I
guess."* The second, more concrete ask is what produced everything:

- late shipments from roughly 1 in 5 orders to about 1 in 50
- a monthly two-day inventory shutdown replaced by two hours a week of cycle counting
- the site's worst shift on safety taken to ~18 months incident-free
- a team of 14 across two shifts, nine of them his hires

The "before" resume has nine numbers on it. **All nine are dates or his phone
number** — none describe his work. The "after" has fourteen that do.

Every one of those facts was already true when he wrote the first version. He
just didn't think of them as resume material; he thought of them as his job.

Note also what survived: *roughly*, *about*, *around 18 months*. He hedged, and
the hedge stayed in. He has to defend these in an interview, and a number he
can't defend exactly is worse than one he's honest about.

## [`design-product-designer/`](design-product-designer/)

A senior product designer with a strong profile already, showing a tailored
package built against a specific job posting (`jd.md`).

Compare `master-profile.md` to `resume.pdf`: every number on the resume — 11
minutes to 4, 31% activation, 62% fewer tickets — appears verbatim in the
profile's `metrics` fields. Nothing was invented, rounded, or upgraded in
transit. That's the property the whole system exists to preserve.

Note what *didn't* make the resume: the earliest role gets one line, because its
`weighting:` note says so, and the story-bank material stays out entirely — it's
for interviews, not resumes.
