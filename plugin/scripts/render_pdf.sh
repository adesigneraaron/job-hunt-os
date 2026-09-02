#!/usr/bin/env bash
# Job-Hunt OS — render a filled HTML file to PDF with headless Chrome.
#
#   render_pdf.sh <input.html> <output.pdf>
#   render_pdf.sh --check          report which browser was found, then exit
#
# Notes:
#   - Templates use system fonts (Arial and equivalents), so there is nothing
#     to bundle and no absolute paths to resolve. The chosen font is embedded
#     into the PDF at render time, so it looks right on any machine that opens
#     the file.
#   - Page size and margins come from the HTML's @page rule.
#   - Background graphics are on, so coloured rules and accents print.

set -euo pipefail

find_browser() {
  if [[ -n "${JOBHUNT_CHROME:-}" ]]; then
    [[ -x "$JOBHUNT_CHROME" ]] && { printf '%s' "$JOBHUNT_CHROME"; return 0; }
    echo "JOBHUNT_CHROME is set but not executable: $JOBHUNT_CHROME" >&2
    return 1
  fi
  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    "/usr/bin/google-chrome" "/usr/bin/google-chrome-stable"
    "/usr/bin/chromium" "/usr/bin/chromium-browser" "/usr/bin/microsoft-edge"
    "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
    "/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { printf '%s' "$c"; return 0; }
  done
  for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave; do
    if command -v "$c" >/dev/null 2>&1; then printf '%s' "$(command -v "$c")"; return 0; fi
  done
  return 1
}

no_browser_msg() {
  cat >&2 <<'MSG'
No Chrome/Chromium-family browser found — Job-Hunt OS needs one to render PDFs.

  macOS / Windows :  install Google Chrome    https://google.com/chrome
  Debian / Ubuntu :  sudo apt install chromium
  Fedora          :  sudo dnf install chromium

Already have one somewhere non-standard? Point at it:
  export JOBHUNT_CHROME="/path/to/your/chrome"
MSG
}

if [[ "${1:-}" == "--check" ]]; then
  if BROWSER="$(find_browser)"; then
    echo "browser : $BROWSER"
    echo "status  : OK"
    exit 0
  fi
  no_browser_msg; exit 1
fi

[[ "$#" -eq 2 ]] || { echo "usage: render_pdf.sh <input.html> <output.pdf>" >&2; exit 2; }

SRC="$1"; OUT="$2"
[[ -f "$SRC" ]] || { echo "input not found: $SRC" >&2; exit 3; }
BROWSER="$(find_browser)" || { no_browser_msg; exit 1; }

case "$SRC" in /*) ABS="$SRC" ;; *) ABS="$(pwd)/$SRC" ;; esac
mkdir -p "$(dirname "$OUT")"

"$BROWSER" --headless=new --disable-gpu \
  --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  --print-to-pdf="$OUT" \
  "file://$ABS" >/dev/null 2>&1 || true

[[ -f "$OUT" ]] || { echo "render failed: $OUT not produced" >&2; exit 4; }
echo "  -> $OUT"
