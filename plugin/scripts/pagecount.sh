#!/usr/bin/env bash
# Prints a PDF's page count, or "unknown" if PyMuPDF isn't installed.
# Exits 0 either way — a missing optional dependency must never fail a build.
set -uo pipefail
_src="${BASH_SOURCE[0]}"; _dir="${_src%/*}"; [[ "$_dir" == "$_src" ]] && _dir="."
HERE="$(cd "$_dir" && pwd)"
# shellcheck source=/dev/null
. "$HERE/_python.sh"
[[ $# -eq 1 ]] || { echo "usage: pagecount.sh <file.pdf>" >&2; exit 2; }
PY="$(find_python)" || { echo "unknown (no Python found)"; exit 0; }
"$PY" -c "
import sys
try:
    import fitz
except ImportError:
    print('unknown (pymupdf not installed - pip install pymupdf)'); sys.exit(0)
print(fitz.open(sys.argv[1]).page_count)
" "$1"
