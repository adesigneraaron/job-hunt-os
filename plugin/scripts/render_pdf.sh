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
  local c
  if [[ -n "${JOBHUNT_CHROME:-}" ]]; then
    [[ -x "$JOBHUNT_CHROME" ]] && { printf '%s' "$JOBHUNT_CHROME"; return 0; }
    echo "JOBHUNT_CHROME is set but not executable: $JOBHUNT_CHROME" >&2
    return 1
  fi

  # Chrome is often installed per-user on Windows, under %LOCALAPPDATA%.
  local appdata=""
  if [[ -n "${LOCALAPPDATA:-}" ]] && command -v cygpath >/dev/null 2>&1; then
    appdata="$(cygpath -u "$LOCALAPPDATA" 2>/dev/null || true)"
  fi

  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    "/usr/bin/google-chrome" "/usr/bin/google-chrome-stable"
    "/usr/bin/chromium" "/usr/bin/chromium-browser" "/usr/bin/microsoft-edge"
    # WSL mounts the Windows drive at /mnt/c
    "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
    "/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
    # Git Bash / MSYS present it as /c
    "/c/Program Files/Google/Chrome/Application/chrome.exe"
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe"
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  )
  [[ -n "$appdata" ]] && candidates+=( "$appdata/Google/Chrome/Application/chrome.exe" )

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
    if [[ "$BROWSER" == *.exe ]]; then
      if command -v cygpath >/dev/null 2>&1; then
        echo "paths   : Windows .exe + cygpath available (paths will be converted)"
      else
        echo "paths   : WARNING - Windows .exe but no cygpath; PDFs may come out blank" >&2
      fi
    fi
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

# Git Bash and MSYS present Windows paths in POSIX form (/c/Users/...), but
# chrome.exe is a Windows program and cannot resolve those — it would render a
# blank page with no error. Convert both paths to Windows form when we're
# driving a .exe from a POSIX-style shell. WSL needs no conversion: it mounts
# the drive at /mnt/c and its Chrome resolves that fine.
URL_PATH="$ABS"
OUT_PATH="$OUT"
if [[ "$BROWSER" == *.exe ]] && command -v cygpath >/dev/null 2>&1; then
  URL_PATH="$(cygpath -m "$ABS")"          # -m gives C:/path/with/forward/slashes
  OUT_ABS="$OUT"; [[ "$OUT_ABS" != /* ]] && OUT_ABS="$(pwd)/$OUT"
  OUT_PATH="$(cygpath -w "$OUT_ABS")"
fi

"$BROWSER" --headless=new --disable-gpu \
  --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  --print-to-pdf="$OUT_PATH" \
  "file://$URL_PATH" >/dev/null 2>&1 || true

[[ -f "$OUT" ]] || { echo "render failed: $OUT not produced" >&2; exit 4; }
echo "  -> $OUT"
