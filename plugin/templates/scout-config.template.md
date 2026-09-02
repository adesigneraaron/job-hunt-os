# Scout config — job discovery parameters

> `/job-hunt-os:scout` reads this file every run. **Edit this file to change
> what it hunts for — no code changes needed.** Written by `/onboard` from your
> answers; tune it freely afterwards, in plain English. Dated notes to yourself
> are encouraged and are read as instructions.

## Titles to search

> The same job is posted under several different titles. List every string
> you'd actually type into a search box — missing one costs real listings.

- «Target title»
- «Variant»
- «Variant»

**Never surface:** «titles you don't want — e.g. management titles if you want
IC, or junior titles below your level»

## Location rules

- «Remote — your country» ✓
- «Remote — worldwide» ✓
- «Your city, local/hybrid» «✓ or ✗»
- Relocation required ✗
- «Timezone tolerance — e.g. "flag roles requiring fixed hours >3h from mine"»

> Record posture only. Never assert residency or work authorisation you don't
> have — you answer those questions on application forms yourself.

## Seniority window

- In range: «N»–«N» years
- Sweet spot: «band»
- Never surface: junior / intern / «below N years»

## Compensation

- Below «floor» : skip unless exceptional on every other axis
- «target»+ : score up
- No compensation posted: neutral — do not skip (many good roles don't post)

## Domain / signal boosts (+score)

> Domains where your experience is a direct match, and signals that
> differentiate you specifically.

- «domain — why it matches»
- «signal»

## Score-down signals (−score)

- «specialisations outside your target»
- «hard walls you can't clear — clearances, licences, language requirements»
- Agency/staffing posts with unnamed clients (allowed, but note the caveat)

## Hard exclusions (never surface)

- Companies already applied to (checked against `applications/` + scout log) —
  «N»-month no-repeat
- Roles outside your field
- Commission-only, unpaid, equity-only
- Obvious spam / MLM / "no experience needed"

## Sources

> **These defaults are design-focused — they're the boards this tool was built
> and tested against. If you work in another field, some of them will be
> useless to you.** Replace them. `docs/job-boards.md` in the repo has a
> field-by-field list plus a paste-in prompt that will rebuild this section
> around your work in about a minute.
>
> Boards are tried in the order listed. Aggregators lag the source and hide
> results below the fold, so going directly to the applicant-tracking systems
> (tier 3) catches fresh postings the aggregators haven't indexed yet.

**1. PRIMARY — broadest sweep, every run**
- Hiring.Cafe — aggregates dozens of applicant-tracking systems; filter to your
  titles, pay floor, and location rules. Field-neutral.
  *Two known quirks: the result list is virtualised, so scroll and re-read 2–4×
  per query to reach anything below the fold; and it lags the source systems, so
  brand-new roles won't be there yet — tier 3 covers those.*

**2. NICHE — lower competition, higher response rate. Rotate 2–3 per run**
- «design defaults» UX Jobs Board · If You Could · Authentic Jobs · Dribbble Jobs
- «replace these with the niche boards for your field»

**3. DIRECT ATS SEARCH — catches what the aggregators missed. Field-neutral**
- `site:job-boards.greenhouse.io "«your title»" remote`
- `site:jobs.ashbyhq.com "«your title»" remote`
- `site:jobs.lever.co "«your title»" remote`
- When a company surfaces, open its board root (e.g.
  `job-boards.greenhouse.io/<company>`) to list every role they have open.

**4. STARTUPS**
- Y Combinator "Work at a Startup" — public, no login.
- Wellfound — needs your logged-in browser session; go gently, it rate-limits.

**5. REMOTE VOLUME**
- We Work Remotely · RemoteOK

**MANUAL ONLY** — their terms prohibit automated access. Browse yourself and
paste postings into `/job-hunt-os:apply`: LinkedIn, Indeed.

**Cross-source dedupe:** match on company name AND URL, so one role appearing on
three boards surfaces once.

## Automation thresholds

- Auto-build packages at score ≥ «7.0»/10
- «6.0»–«6.9»: listed for you to pick from
- Below «6.0»: collapsed "also seen" list, no action
- Daily build cap: «5» packages per run

## Scoring rubric (/10)

- Domain & skills match vs master-profile ....... /3
- Level fit .................................... /2
- Compensation ................................. /2
- Location cleanliness ......................... /1.5
- Differentiator signals ....................... /1.5
