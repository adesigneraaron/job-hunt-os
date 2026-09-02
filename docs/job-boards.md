# Where to actually find jobs

The source list shipped in `scout-config.md` is **design-focused**, because
that's the field it was built and tested in. If you work in something else,
some of it will be useless to you. This page is the raw material for rebuilding
it around your field — and at the bottom there's a prompt that will do most of
that work for you.

---

## Start here

These four carried the most weight in practice. The first three are
field-neutral; the fourth is design-specific.

| Source | What it is | Why it earns a place |
|---|---|---|
| **Hiring.Cafe** | Aggregator pulling from dozens of applicant-tracking systems | The broadest single sweep, with real filters for pay, remote, and seniority. Good first stop in almost any field. |
| **Greenhouse** (`job-boards.greenhouse.io`) | An ATS — the software companies run hiring in | You can search it directly and reach postings the aggregators haven't indexed yet. Field-neutral. |
| **Ashby** (`jobs.ashbyhq.com`) | Another ATS, popular with well-funded startups | Same idea as Greenhouse; different set of companies. Field-neutral. |
| **Wellfound** | Startup jobs, formerly AngelList Talent | The richest startup pool, but it needs a logged-in account. Strong for design and engineering. |

---

## The technique worth learning: search the ATS directly

This is the most transferable thing in this document, and it works in **any**
field.

Most companies don't build their own careers page — they rent one. Those rented
pages live on predictable web addresses, which means you can search them
directly instead of waiting for an aggregator to index them. Postings show up
here **first**.

Search the web for a phrase like:

```
site:job-boards.greenhouse.io "your job title" remote
```

Swap in each of these:

- `job-boards.greenhouse.io` — Greenhouse
- `jobs.ashbyhq.com` — Ashby
- `jobs.lever.co` — Lever
- `apply.workable.com` — Workable
- `jobs.smartrecruiters.com` — SmartRecruiters
- `app.dover.com/apply` — Dover
- `*.pinpointhq.com` — Pinpoint

When one company turns up, open its board's root address (for example
`job-boards.greenhouse.io/companyname`) to see *every* role they have open —
including ones your search terms didn't happen to match.

---

## Aggregators

Broad sweeps across many companies at once. Field-neutral unless noted.

- **Hiring.Cafe** — wide coverage, genuinely good filters.
- **Simplify** — aggregates startup and tech roles; has an autofill extension.
- **TrueUp** — tracks funded tech companies.
- **Otta / Welcome to the Jungle** — curated tech roles, opinionated matching.

> A caution that applies to all of them: aggregators lag the source. A role
> posted this morning may not appear for a day or two, which is exactly why the
> direct-ATS search above matters.

## Startups

- **Y Combinator — Work at a Startup** (`workatastartup.com`) — vetted YC
  companies, public, no login needed.
- **Wellfound** — needs an account; go gently, it rate-limits.

## Remote-first

- **We Work Remotely** — high volume, clean listings.
- **RemoteOK** — has a public data feed, easy to scan.
- **Remotive** — curated remote roles.
- **Working Nomads**, **JustRemote** — smaller, worth a rotation.

## By field

Niche boards have far less competition than the big aggregators, which usually
means a higher response rate per application. Rotate two or three each run
rather than checking all of them.

**Design** *(the shipped defaults)* — UX Jobs Board · If You Could · Authentic
Jobs · Dribbble Jobs · Working Not Working · Behance Jobs

**Engineering** — Hacker News "Who Is Hiring" (monthly thread) · Stack Overflow
Jobs · Functional Works · Golang/Rust/Python community boards

**Data & ML** — ai-jobs.net · Kaggle Jobs · EuroTechJobs

**Product management** — Product Hunt Jobs · Mind the Product · Lenny's Job Board

**Marketing & growth** — GrowthHackers · MarketerHire · Superpath (content)

**Writing & content** — Superpath · ProBlogger · Contena

**Nonprofit & public sector** — Idealist · Work for Good · your government's
own jobs portal (these are almost never on aggregators)

**Academia & research** — HigherEdJobs · jobs.ac.uk · Nature Careers

**Trades, healthcare, education** — these run on sector-specific boards and
licensing bodies rather than tech aggregators. Search
`"your role" jobs "your region"` and note which boards keep reappearing — that
list *is* your source tier.

## Manual only

**LinkedIn** and **Indeed** have the volume, but their terms prohibit automated
access, so this tool won't scrape them. Browse them yourself and paste any
posting you like straight into `/job-hunt-os:apply` — it works exactly the same
from pasted text as from a URL.

---

## Build your own source list

Paste this into Claude Code to generate a source tier for your field. It
replaces the "Sources" section of `job-hunt/config/scout-config.md`.

```
I'm job hunting as a «your role» in «your industry», based in «your location»,
looking for «remote / hybrid / onsite» work.

Help me build a job-source list for my field, structured as:

1. PRIMARY — the one or two broadest sources for my field, that I'd check every run
2. NICHE — 3-5 smaller boards specific to my field, where competition is lower
3. DIRECT — which applicant-tracking systems companies in my field actually use,
   with an example `site:` search string for each
4. COMMUNITY — any forums, Slack groups, newsletters, or association job pages
   where roles in my field get posted before they hit the big boards
5. MANUAL — sources I should check by hand rather than automate

For each one tell me: what it is, roughly how much volume to expect, and whether
it needs an account. Flag anything that's genuinely field-specific versus
general. Then write it into job-hunt/config/scout-config.md, replacing the
Sources section, keeping the existing plain-English format.
```

The community tier is the one people skip and shouldn't. In a lot of fields the
best roles circulate on a mailing list or an association board weeks before they
reach a public aggregator — and often never reach one at all.
