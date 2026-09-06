# Regression tests

```bash
bash tests/run-tests.sh
```

Run it before tagging a release. No framework — read the output.

## Why this exists

The profile-strength number — how many roles carry a real metric — had **three
separate bugs**, each found after shipping. It is the number onboarding is built
around, it is parsed from prose people write by hand, and nothing guarded it.

On its first run this suite found a fourth bug elsewhere: the tracker only
recognised a workspace named exactly `job-hunt`, so any other name silently
dropped rows into paste-mode.

## Adding a case

Drop a profile in `tests/profiles/` named `<roles>-<with-metrics>-<what-it-is>.md`.
`2-1-partial.md` means: two roles, one of which has a real metric. The runner
reads the expectation from the filename, so a new case is one file and no code.

Add a case whenever a bug is found in profile parsing — that is how the fourth
one stops becoming a fifth.
