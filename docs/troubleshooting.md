# Troubleshooting

Start with `/job-hunt-os:doctor` — it checks everything below and names the fix.

## "No Chrome/Chromium-family browser found"

PDFs are made by a headless browser. Install Google Chrome or Chromium.

Already have one somewhere unusual? Point at it:

```bash
export JOBHUNT_CHROME="/path/to/your/chrome"
```

## The resume came out as two pages

`apply` should catch this and trim. If it slips through, tell it to cut the
least-relevant bullets and re-render — never reduce the font size to force a
fit, it reads as desperate and ATS parsers don't care about your page count as
much as recruiters do.

Page-count checking needs PyMuPDF: `pip3 install pymupdf`. Without it
everything still works, you just lose the automatic check.

## Boxes or blank squares instead of characters

Emoji don't survive the HTML-to-PDF step. Use plain glyphs — `•` `·` `–` `→`
`★` are all fine.

## "Couldn't fetch the job description"

Normal on LinkedIn, Indeed, and Workday — they block automated readers. Copy the
posting text and paste it in instead; the result is identical.

## Scout returns very little, or fails on a source

Expected sometimes. Job boards change their pages and rate-limit. Scout reports
which sources failed rather than pretending it saw everything.

If it's consistently thin: your filters may be too tight. Widen the title list
in `job-hunt/config/scout-config.md` first — the same job is posted under
several different titles, and missing one costs real listings.

If you're not in design, the default sources are the problem. See
[job-boards.md](job-boards.md).

## It won't fill a field on an application form

By design for work-authorisation, visa, citizenship, demographic, and any
question needing ID or payment details. Those are yours to answer truthfully.

For anything else, it asks rather than guesses when the package doesn't have a
clear answer.

## My resumes feel generic

Almost always thin raw material rather than bad prompting. Run
`/job-hunt-os:doctor` to see how many roles have a real number attached, then
`/job-hunt-os:onboard metrics` to fill the gaps.

## I'm about to publish a fork and want to be sure it's clean

```bash
bash scripts/scrub-check.sh
```

Copy `scripts/scrub-patterns.example.txt` to `scrub-patterns.txt` and fill in
your own details first. That file is gitignored and never ships.
