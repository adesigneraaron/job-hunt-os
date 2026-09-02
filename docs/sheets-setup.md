# Optional: Google Sheets tracker with automatic status updates

**You don't need this.** Job-Hunt OS logs to a plain CSV file by default, with
no setup and no accounts. Skip this page unless you specifically want the
upgrade below.

## What you get

A Google Sheet that updates itself. An hourly script reads your Gmail and:

- flips a row to **Rejected** when a rejection lands, and files those emails
  away so your inbox stops being a slow drip of bad news
- flips a row to **Interview** when someone wants to talk — and **never**
  touches or archives those emails
- flips a row to **Applied** when a confirmation receipt arrives
- logs every action it takes, so you can see why a row changed

It only ever moves a status forward, and never overwrites a final one.

## Setup (about 20 minutes)

### 1. Make the Sheet

New Google Sheet, named whatever you like. **Use the same Google account you
apply to jobs from** — the script reads that account's Gmail.

### 2. Add the script

`Extensions → Apps Script`. Delete the placeholder code, paste in the contents
of [`plugin/scripts/apps-script.gs`](../plugin/scripts/apps-script.gs), and save.

Near the top, set your own address:

```javascript
var SELF_EMAIL = 'you@example.com';
```

This is how it knows to skip your own replies. Leave `SHEET_ID` empty — the
script is attached to this sheet already.

### 3. Deploy it as a web app

`Deploy → New deployment → Web app`.

- **Execute as:** Me
- **Who has access:** Anyone

Google will warn you about permissions; that's expected for a personal script.
Copy the URL it gives you.

> **Treat that URL like a password.** Anyone who has it can write rows into
> your sheet. Never paste it into a screenshot, an issue, or a public repo.

Save it where only you can read it:

```bash
mkdir -p ~/.config/job-hunt-os
```
```bash
printf '%s\n' 'PASTE_YOUR_URL_HERE' > ~/.config/job-hunt-os/webhook-url.txt
```

### 4. Turn it on

In `job-hunt/config/settings.json`:

```json
{ "tracker": "sheets" }
```

Your local CSV keeps being written either way, so you always have a copy that
doesn't depend on Google.

### 5. Schedule the inbox scan

Back in Apps Script: `Triggers → Add trigger` → function `scanInbox`,
time-driven, hourly.

Run it once by hand first and check the **Email Log** tab to see what it
matched before letting it run unattended.

## Tuning it

Near the top of the script:

- `ARCHIVE_REJECTIONS` — file rejections away automatically (on by default)
- `ARCHIVE_UNMATCHED_REJECTIONS` — also quiet clear rejections it couldn't tie
  to a row
- `ARCHIVE_APPLIED` — file "thanks for applying" receipts away
- `SCAN_WINDOW_DAYS` — how far back to look, 45 days by default

Interview emails are never archived, under any setting.

## If it misfires

Check the **Email Log** tab first — it records every decision.

The usual cause is company-name matching: the sheet says "Acme" and the email
comes from "Acme Technologies Inc." Edit the company name in the sheet to match
what actually appears in your mail.
