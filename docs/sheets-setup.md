# Optional: a tracker that updates itself from your inbox

**You don't need this.** Job-Hunt OS writes every application to a plain CSV
file with no setup and no accounts. Skip this page unless you want the upgrade.

## What you get

A Google Sheet that maintains itself. Once an hour it reads your Gmail and:

- flips a row to **Rejected** when a rejection arrives, then files that email
  away so your inbox stops being a slow drip of bad news
- flips a row to **Interview** when someone wants to talk — and never touches,
  labels, or archives those emails
- flips a row to **Applied** when a confirmation receipt lands
- writes every decision it makes to an **Email Log** tab, so a wrong match is
  visible and reversible rather than silent

It only ever moves a status forward, and never overwrites a final one. A
rejected role can't be quietly un-rejected by a stray newsletter.

## Setup — about 5 minutes

### 1. Copy the template

> **[→ Open the Job-Hunt OS tracker template](TEMPLATE_URL_GOES_HERE)**
>
> It will immediately offer to make you a copy. Say yes.

Use the **same Google account you apply to jobs from** — the script reads that
account's mail. The tracking code comes with the copy; there's nothing to paste.

### 2. Run Set up

In your new copy: **Job-Hunt menu → ⚙ Set up (run me first)**

Google will ask you to authorise the script, and will warn you that it's
unverified. That's expected for a personal script you now own — click through
*Advanced → Go to Job-Hunt OS Tracker*.

Setup creates the tabs, installs the hourly scan, and detects your email address
on its own. Nothing to configure.

Then **Job-Hunt menu → ✓ Check my setup** to confirm it all took.

### 3. Optional: let Claude add rows for you

Without this, the scanner still updates statuses — you just add rows yourself.
With it, `/job-hunt-os:apply` writes each application straight into the sheet.

- **Deploy → New deployment → Web app**
- **Execute as:** Me · **Who has access:** Anyone
- Copy the URL it gives you

> **Treat that URL like a password.** Anyone who has it can write rows into your
> sheet. Never paste it into a screenshot, an issue, or a public repository.

Save it where only you can read it:

```bash
mkdir -p ~/.config/job-hunt-os
```
```bash
printf '%s\n' 'PASTE_YOUR_URL_HERE' > ~/.config/job-hunt-os/webhook-url.txt
```

Then in `job-hunt/config/settings.json`:

```json
{ "tracker": "sheets" }
```

Your local CSV keeps being written either way, so you always have a copy that
doesn't depend on Google.

### 4. Watch the first run

**Job-Hunt → Scan inbox now**, then read the **Email Log** tab before letting it
run unattended. It shows what it matched and why.

## Tuning

Near the top of the script (**Extensions → Apps Script**):

| Setting | Default | Does |
|---|---|---|
| `ARCHIVE_REJECTIONS` | on | Files rejections out of your inbox |
| `ARCHIVE_UNMATCHED_REJECTIONS` | on | Also quiets rejections it can't tie to a row |
| `ARCHIVE_APPLIED` | on | Files "thanks for applying" receipts away |
| `ARCHIVE_UNMATCHED_APPLIED` | off | Leaves unmatched receipts visible — usually an application that never got logged |
| `SCAN_WINDOW_DAYS` | 45 | How far back to look |

Interview emails are never archived under any setting.

## If it misfires

Read the **Email Log** tab first — every decision is recorded there.

The usual cause is name matching: your sheet says "Acme" and the email comes
from "Acme Technologies Inc." Edit the company name in the sheet to match what
appears in your mail.

If statuses aren't updating at all, check **Job-Hunt → ✓ Check my setup**. A
missing hourly trigger is the most common cause, and re-running Set up fixes it.

## Running the script under a different account

Rare, but if the account running the script isn't the one you apply from, set a
Script Property named `SELF_EMAIL` to your applying address:
**Extensions → Apps Script → Project Settings → Script Properties**.
