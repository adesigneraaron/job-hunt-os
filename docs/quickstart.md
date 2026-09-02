# Quickstart

About fifteen minutes from nothing to your first tailored application.

## 1. Install (2 min)

```
/plugin marketplace add adesigneraaron/job-hunt-os
```
```
/plugin install job-hunt-os@job-hunt-os
```

Check it can render PDFs:

```
/job-hunt-os:doctor
```

If it can't find a browser, install Google Chrome or Chromium — that's the one
hard requirement.

**On Windows**, you also need [Git for Windows](https://git-scm.com/downloads/win)
installed first — it supplies the shell these scripts run in. Full details in
[windows.md](windows.md).

## 2. Build your profile (10–15 min)

Open Claude Code in the folder where you want your job hunt to live, then:

```
/job-hunt-os:onboard
```

Have your current resume handy — PDF, Word, or a LinkedIn export all work. It
reads what it can and only asks about what's missing.

**The questions worth slowing down for** are the ones about numbers. For each
job you've had, it asks what changed because you were there. This is the single
biggest lever on how good your resumes come out: a resume of responsibilities
reads like everyone else's, a resume of outcomes doesn't.

If you genuinely don't have a number, say so — it'll capture scope instead
(how many people, how big the team, what you owned). It will never make one up,
and neither should you.

You can stop partway through and pick up later; it saves as it goes. Sections
after the metrics are all skippable.

At the end you get a rendered resume PDF. That's your baseline — every tailored
version starts from it.

## 3. Your first application (1 min)

Find a job posting and:

```
/job-hunt-os:apply https://example.com/jobs/12345
```

If the site blocks automated reading — LinkedIn, Indeed, and Workday usually do
— just paste the job text in instead:

```
/job-hunt-os:apply
```
then paste when asked.

You'll get a folder with a tailored one-page resume, a cover letter, pre-written
answers to the usual form questions, and an interview prep sheet. It also tells
you, privately, which requirements you don't clearly meet — read that part.

## 4. Fill the form

```
/job-hunt-os:formassist acme-product-designer
```

It opens the application in your browser and fills what it can from the package
it just built. It leaves work-authorisation and demographic questions blank —
those are yours — and it never clicks Submit. You review everything and send it.

## Then what

- `/job-hunt-os:mock acme` before an interview — coached practice on your own
  material, graded, with your weak spots tracked over time.
- `/job-hunt-os:scout` to search boards automatically. Read
  [job-boards.md](job-boards.md) first if you're not a designer — the default
  sources are design-focused and you'll want to swap them out.
- `/job-hunt-os:onboard metrics` any time, to strengthen the weakest part of
  your profile.

## Improving your results

The profile is the ceiling. If your resumes feel generic, the fix is almost
always more specific raw material rather than better prompting.

Run `/job-hunt-os:doctor` — it tells you how many of your roles have a real
number attached. Getting that ratio up does more than anything else here.
