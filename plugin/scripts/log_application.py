#!/usr/bin/env python3
"""
Job-Hunt OS — log one application to your tracker.

Three tiers, tried in order. The first that works wins, and the script always
exits 0 so a logging problem never fails an otherwise-good application.

  1. LOCAL CSV   (default, zero setup) — appends to <workspace>/tracker/applications.csv
  2. WEBHOOK     (optional)  — POSTs to a Google Apps Script endpoint
  3. GSPREAD     (optional)  — writes to a Google Sheet via a service account

Tier 2 and 3 are opt-in upgrades. See docs/sheets-setup.md. Configure in
<workspace>/config/settings.json:

    { "tracker": "local" }                       # default
    { "tracker": "sheets" }                      # use webhook/gspread, csv as backup

Credentials are never read from the workspace — only from the environment or
~/.config/job-hunt-os/, so they can't be committed by accident.

Usage:
  log_application.py --workspace ./job-hunt --company "Acme" \
      --title "Product Designer" --status "Ready to apply" \
      --location "Remote" --remote yes --jd-link "https://..." \
      --resume "applications/acme-pd/resume.pdf" --notes "Referral"
Date defaults to today.
"""

import argparse, csv, datetime, json, os, sys, urllib.request, urllib.error

COLUMNS = ["Company", "Job Title", "Date Applied", "Status", "Salary Expectation",
           "Location", "Remote?", "JD Link", "Resume File", "Notes"]

CONFIG_DIR = os.path.expanduser("~/.config/job-hunt-os")
WEBHOOK_FILE = os.path.join(CONFIG_DIR, "webhook-url.txt")
GCP_KEY_FILE = os.path.join(CONFIG_DIR, "gcp-service-account.json")


# ---------------------------------------------------------------- workspace --
def find_workspace(explicit=None):
    """Explicit path, then ./job-hunt walking upward, then the plugin pointer."""
    if explicit:
        return os.path.abspath(explicit)
    d = os.getcwd()
    while True:
        cand = os.path.join(d, "job-hunt")
        if os.path.isdir(cand):
            return cand
        if os.path.basename(d) == "job-hunt" and os.path.isdir(os.path.join(d, "profile")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    data_dir = os.environ.get("CLAUDE_PLUGIN_DATA")
    if data_dir:
        p = os.path.join(data_dir, "workspace.json")
        if os.path.isfile(p):
            try:
                with open(p) as fh:
                    ws = json.load(fh).get("workspace")
                if ws and os.path.isdir(ws):
                    return ws
            except (OSError, ValueError):
                pass
    return None


def load_settings(ws):
    if not ws:
        return {}
    p = os.path.join(ws, "config", "settings.json")
    try:
        with open(p) as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return {}


# ------------------------------------------------------------------- tier 1 --
def write_local(ws, row):
    if not ws:
        return False, "no workspace found"
    path = os.path.join(ws, "tracker", "applications.csv")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    new = not os.path.isfile(path) or os.path.getsize(path) == 0
    try:
        with open(path, "a", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            if new:
                w.writerow(COLUMNS)
            w.writerow(row)
        return True, path
    except OSError as e:
        return False, str(e)


# ------------------------------------------------------------------- tier 2 --
def webhook_url():
    u = os.environ.get("JOBHUNT_WEBHOOK_URL")
    if u:
        return u.strip()
    try:
        with open(WEBHOOK_FILE) as fh:
            return fh.read().strip()
    except OSError:
        return None


def write_webhook(row):
    url = webhook_url()
    if not url:
        return False, "no webhook configured"
    payload = json.dumps({"tab": "Applications", "row": row}).encode()
    req = urllib.request.Request(url, data=payload,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            body = resp.read().decode("utf-8", "replace")
        return ('"ok":true' in body.replace(" ", "")), body[:200]
    except (urllib.error.URLError, OSError) as e:
        return False, str(e)


# ------------------------------------------------------------------- tier 3 --
def write_gspread(row):
    sheet_id = os.environ.get("JOBHUNT_SHEET_ID")
    key = os.environ.get("JOBHUNT_GCP_KEY", GCP_KEY_FILE)
    if not sheet_id or not os.path.isfile(key):
        return False, "gspread not configured"
    try:
        import gspread
        from google.oauth2.service_account import Credentials
    except ImportError:
        return False, "gspread/google-auth not installed"
    try:
        creds = Credentials.from_service_account_file(
            key, scopes=["https://www.googleapis.com/auth/spreadsheets"])
        sh = gspread.authorize(creds).open_by_key(sheet_id)
        try:
            ws = sh.worksheet("Applications")
        except gspread.WorksheetNotFound:
            ws = sh.add_worksheet("Applications", rows=1000, cols=len(COLUMNS))
            ws.append_row(COLUMNS)
        ws.append_row(row, value_input_option="USER_ENTERED")
        return True, "sheet"
    except Exception as e:                                    # noqa: BLE001
        return False, f"{type(e).__name__}: {e}"


# ---------------------------------------------------------------------- cli --
def main():
    ap = argparse.ArgumentParser(description="Log one application to the tracker.")
    ap.add_argument("--workspace")
    ap.add_argument("--company", required=True)
    ap.add_argument("--title", default="")
    ap.add_argument("--date", default=datetime.date.today().isoformat())
    ap.add_argument("--status", default="Ready to apply")
    ap.add_argument("--salary", default="")
    ap.add_argument("--location", default="")
    ap.add_argument("--remote", default="")
    ap.add_argument("--jd-link", default="")
    ap.add_argument("--resume", default="")
    ap.add_argument("--notes", default="")
    a = ap.parse_args()

    row = [a.company, a.title, a.date, a.status, a.salary,
           a.location, a.remote, a.jd_link, a.resume, a.notes]

    ws = find_workspace(a.workspace)
    mode = load_settings(ws).get("tracker", "local")

    ok, detail = write_local(ws, row)
    if ok:
        print(f"LOGGED (local) -> {detail}")
    else:
        print(f"local tracker unavailable: {detail}", file=sys.stderr)

    if mode == "sheets":
        sent, detail = write_webhook(row)
        if not sent:
            sent, detail = write_gspread(row)
        print("LOGGED (sheets)" if sent else f"sheets sync skipped: {detail}")

    if not ok:
        print("\nPaste this row into your tracker:\n")
        print("\t".join(COLUMNS))
        print("\t".join(row))

    sys.exit(0)


if __name__ == "__main__":
    main()
