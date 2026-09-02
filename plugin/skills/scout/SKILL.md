---
name: scout
description: Search job boards for new postings that match your profile, score them, and automatically build application packages for the best ones. Use when the user wants to find new jobs, check for new postings, run their morning job search, or asks what's out there today. Experimental — job boards change their pages often.
---

# Scout

Find today's new postings, score them against the user's config, and build
packages for the strongest.

> **Experimental.** This is the most fragile part of Job-Hunt OS: job boards
> change their page structure without warning, and some rate-limit or block
> automated reading. When a source fails, say so plainly, skip it, and carry on
> with the others — never silently return fewer results as though that were the
> whole picture.

## 1. Load state

- `<workspace>/config/scout-config.md` — all the tuning. Titles, locations, pay
  floor, boosts, thresholds, sources, and the scoring rubric. **Follow it as
  written**, including any dated notes the user has added to themselves.
- `<workspace>/profile/master-profile.md` — what they've actually done.
- `<workspace>/scout-log.json` — everything seen before (create it if absent).
- `ls <workspace>/applications/` — companies already applied to.

## 2. Discover

Work through the source tiers in `scout-config.md` in order. Notes that apply
generally:

- **Aggregators lag and virtualise.** Scroll and re-read the list 2–4 times per
  query — the first read usually returns only the top 20–30 rows.
- **Search the ATSs directly** for anything fresh. When a company surfaces,
  open its board root to see every role it has open, not just the matched one.
- **Never touch LinkedIn or Indeed.** Their terms prohibit automated access.
  If the user wants those, they browse and paste into `/job-hunt-os:apply`.
- Respect rate limits. If a source pushes back, stop and note it.

## 3. Filter

Drop anything matching the config's hard exclusions: companies already applied
to within the no-repeat window, roles outside the field, unpaid or
commission-only, and obvious spam.

**Dedupe on company name *and* URL** — the same role appears on several boards.

## 4. Score

Apply the rubric in `scout-config.md` exactly — don't invent your own weights.
Show the per-axis breakdown, not just a total, so the user can tell *why*
something scored well.

## 5. Digest

Grouped by score band:

- **At or above the auto-build threshold** → building now
- **In the "your pick" band** → listed with scores; the user green-lights with
  one word ("build 2 and 4")
- **Below** → a collapsed "also seen" list

For each: company, title, location and remote policy, pay if posted, the score
with its breakdown, one line on why it fits, and any flags the config asks for.

## 6. Auto-build

For each role at or above the threshold, up to the daily cap, run the `apply`
skill. Spawn these in parallel where possible — they're independent.

## 7. Check before reporting

For every package built:

- Nothing from the profile's `suppress:` list appears in the resume or cover
  letter.
- Any `weighting:` rules were honoured.
- Each resume PDF is exactly one page.

## 8. Report

What was built and where, what's waiting on the user's pick, which sources
failed or were skipped and why, and the nudge:
`/job-hunt-os:formassist <slug>` to fill the form.

Append everything seen to `scout-log.json` so tomorrow's run doesn't repeat it.
