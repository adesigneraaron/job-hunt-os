# Worked example

A fictional designer, a fictional job, and the real output the tool produces.

| File | What it is |
|---|---|
| `master-profile.md` | A filled-in profile — what `/job-hunt-os:onboard` produces from your resume plus the gap interview. This is the input to everything else. |
| `jd.md` | A job posting, as captured by `/job-hunt-os:apply`. |
| `resume.html` / `resume.pdf` | The tailored resume. One page, ATS-safe, built only from facts present in the profile. |

Compare the profile to the resume: every number on the resume — 11 minutes to
4, 31% activation, 62% fewer tickets — appears verbatim in the profile's
`metrics` fields. Nothing was invented, rounded, or upgraded in transit. That's
the property the whole system is built to preserve.

Note what *didn't* make the resume: the Halcyon role is one line, because its
`weighting:` note says so, and the story-bank material stays out of the resume
entirely — it's for interviews.
