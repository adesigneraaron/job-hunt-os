# Job-Hunt OS

A job-application pipeline for [Claude Code](https://claude.com/claude-code).

You write down what you've actually done, once. After that, every resume, cover
letter, application answer, and interview prep sheet gets built from that one
file — tailored to the specific job, in about a minute, without you retyping
your career for the hundredth time.

**The rule that makes it work: nothing gets claimed that isn't in your profile.**
No invented metrics, no borrowed accomplishments, no "results-driven
professional". If a number isn't in your file, it doesn't reach your resume —
because you have to defend every line of it in an interview.

---

## What it produces

For each job, one folder:

```
job-hunt/applications/acme-product-designer/
├── jd.md                  the posting, captured
├── resume.pdf             tailored, one page          ← example/operations-manager/resume-after.pdf
├── cover-letter.pdf       + a .md version for web forms
├── common-questions.md    pre-written answers to the form questions
└── prep-sheet.md          likely questions + which of your stories to use
```

See the [worked examples](example/) — including a before/after that shows what the onboarding interview pulls out of an ordinary resume.

## Install

```
/plugin marketplace add adesigneraaron/job-hunt-os
```
```
/plugin install job-hunt-os@job-hunt-os
```

Then, in the folder where you want your job hunt to live:

```
/job-hunt-os:onboard
```

Point it at your existing resume. It reads what it can, asks about what's
missing, and hands you back a rendered resume in about fifteen minutes. That's
setup done.

> Prefer not to use the plugin system? Clone the repo and copy `plugin/skills/`
> into your `.claude/skills/` folder. Everything works the same.

## The commands

| Command | What it does |
|---|---|
| `/job-hunt-os:onboard` | Builds your profile from your resume, then interviews the gaps. Run once. |
| `/job-hunt-os:apply <url>` | One posting → a complete tailored application package. |
| `/job-hunt-os:formassist <slug>` | Fills the real application form in your browser. **You click Submit.** |
| `/job-hunt-os:scout` | Searches job boards, scores what it finds, builds packages for the best. *Experimental.* |
| `/job-hunt-os:mock <company>` | Coached interview practice that grades your answers and tracks weak spots. |
| `/job-hunt-os:doctor` | Checks your setup and tells you how complete your profile is. |

## A note on job boards

The default source list in `scout-config.md` is **design-focused** — that's the
field this was built and tested in. If you work in something else, replace it.
[`docs/job-boards.md`](docs/job-boards.md) has boards by field, the
search-the-ATS-directly technique that works in any field, and a prompt you can
paste in to rebuild the list around your own work.

## What it won't do

Deliberate limits, not missing features:

- **Never invents a fact.** Gaps stay blank and get flagged privately to you.
- **Never clicks Submit.** It fills the form; you review it and send it.
- **Never answers work-authorisation, visa, or demographic questions.** Those
  are yours to answer truthfully.
- **Never creates accounts or enters passwords.**
- **Doesn't scrape LinkedIn or Indeed** — their terms prohibit it. Browse them
  yourself and paste any posting into `apply`; it works the same.

## Requirements

- Claude Code
- Google Chrome, Chromium, or Edge — used to turn HTML into PDF
- Python 3, and optionally `pymupdf` (`pip3 install pymupdf`) to verify resumes
  stay one page

Run `/job-hunt-os:doctor` if anything misbehaves; it names the exact fix.

## Your data

Everything lives in a `job-hunt/` folder you own, on your machine. Nothing is
uploaded anywhere, and no analytics are collected. The tracker is a plain CSV
by default — no accounts, no setup. If you'd rather have a Google Sheet that
updates its own statuses from your inbox — rejections filed away, interviews
never touched — copy the template and run one menu item:
[`docs/sheets-setup.md`](docs/sheets-setup.md). About five minutes, entirely
optional.

**If you fork this repo, keep your `job-hunt/` folder out of it.** The included
`.gitignore` does that, and `scripts/scrub-check.sh` will tell you if anything
personal is about to be published.

## License

MIT. See [LICENSE](LICENSE).
