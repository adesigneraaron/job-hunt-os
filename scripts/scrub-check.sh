#!/usr/bin/env bash
# Pre-publish guard. Fails if anything personal, private, or unlicensed is
# about to be made public. Run from the repo root; exit 0 means safe to push.
#
#   bash scripts/scrub-check.sh
#
# Personal identifiers live in scrub-patterns.txt (gitignored, never committed)
# so this script itself contains no PII.

set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PATTERNS_FILE="scripts/scrub-patterns.txt"
FAIL=0
SELF_EXCLUDE=( --exclude-dir=.git --exclude=scrub-check.sh --exclude=scrub-patterns.txt )

# --- PDFs are binary, so grep skips them. Extract their text + metadata into a
# --- temp shadow directory and scan that alongside the source tree. PDFs can
# --- carry an author name, a title, or the full filesystem path they were
# --- rendered from — none of which is visible to a plain text search.
SHADOW="$(mktemp -d)"
trap 'rm -rf "$SHADOW"' EXIT
shadow_pdfs() {
  local n=0
  while IFS= read -r -d '' pdf; do
    local out="$SHADOW/$(echo "${pdf#./}" | tr '/' '_').txt"
    if python3 - "$pdf" "$out" 2>/dev/null <<'PYEOF'
import sys
try:
    import fitz
except ImportError:
    sys.exit(9)
doc = fitz.open(sys.argv[1])
with open(sys.argv[2], "w", encoding="utf-8", errors="replace") as fh:
    for k, v in (doc.metadata or {}).items():
        if v: fh.write(f"[metadata:{k}] {v}\n")
    for page in doc:
        fh.write(page.get_text())
PYEOF
    then n=$((n+1))
    else
      strings "$pdf" > "$out" 2>/dev/null && n=$((n+1))
    fi
  done < <(find . -name '*.pdf' -not -path './.git/*' -print0)
  echo "$n"
}
PDF_COUNT="$(shadow_pdfs)"
echo "scanning $PDF_COUNT PDF(s) for embedded text and metadata"

red()  { printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }

echo "== Job-Hunt OS publish gate =="

# --- 1. Personal identifiers -------------------------------------------------
# Format of scrub-patterns.txt: one pattern per line.
#   BAN <regex>              -> must not appear anywhere
#   ALLOW-IN <files> <regex> -> may appear only in this colon-separated file list
if [[ ! -f "$PATTERNS_FILE" ]]; then
  red "MISSING $PATTERNS_FILE — cannot verify the repo is scrubbed."
  echo "   Create it from scripts/scrub-patterns.example.txt and fill in your"
  echo "   own name, emails, phone, domain names and former employers."
  FAIL=1
else
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    kind=$(awk '{print $1}' <<<"$line")
    case "$kind" in
      BAN)
        pat=${line#BAN }
        if hits=$(grep -rInE "${SELF_EXCLUDE[@]}" -- "$pat" . "$SHADOW" 2>/dev/null); then
          red "LEAK: pattern /$pat/ found:"; sed 's/^/    /' <<<"$hits"; FAIL=1
        fi
        ;;
      ALLOW-IN)
        rest=${line#ALLOW-IN }
        allowed=$(awk '{print $1}' <<<"$rest")
        pat=${rest#* }
        if hits=$(grep -rInE "${SELF_EXCLUDE[@]}" -- "$pat" . "$SHADOW" 2>/dev/null); then
          while IFS= read -r hit; do
            f=${hit%%:*}; f=${f#./}
            IFS=':' read -ra ok <<<"$allowed"
            permitted=0
            for a in "${ok[@]}"; do [[ "$f" == "$a" ]] && permitted=1; done
            if (( ! permitted )); then
              red "LEAK: /$pat/ outside allowed files ($allowed):"; echo "    $hit"; FAIL=1
            fi
          done <<<"$hits"
        fi
        ;;
    esac
  done < "$PATTERNS_FILE"
fi

# --- 2. Machine-specific absolute paths -------------------------------------
if hits=$(grep -rInE "${SELF_EXCLUDE[@]}" -- '/(Users|home)/[a-z0-9_.-]+/' . "$SHADOW" 2>/dev/null); then
  red "LEAK: absolute home-directory paths (nothing may point at one machine):"
  sed 's/^/    /' <<<"$hits"; FAIL=1
fi

# --- 3. Live credentials / endpoints ----------------------------------------
if hits=$(grep -rInE "${SELF_EXCLUDE[@]}" -- 'script\.google\.com/macros/s/[A-Za-z0-9_-]{20,}|AIza[A-Za-z0-9_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' . "$SHADOW" 2>/dev/null); then
  red "LEAK: live credential or webhook endpoint:"; sed 's/^/    /' <<<"$hits"; FAIL=1
fi

# --- 4. User data that must never be committed ------------------------------
for d in job-hunt applications interview-prep tracker profile; do
  [[ -e "$d" ]] && { red "LEAK: user-data directory '$d/' present in the repo."; FAIL=1; }
done
for f in scout-log.json webhook-url.txt sheet-config.json; do
  [[ -e "$f" ]] && { red "LEAK: '$f' present in the repo."; FAIL=1; }
done
if command -v git >/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  if tracked=$(git ls-files | grep -E '^(job-hunt|applications|interview-prep|tracker|profile)/' 2>/dev/null); then
    red "LEAK: user data tracked by git:"; sed 's/^/    /' <<<"$tracked"; FAIL=1
  fi
fi

echo
if (( FAIL )); then
  echo "(paths under $SHADOW are extracted PDF contents — fix the source .pdf)" >&2
  red "BLOCKED — do not publish. Fix everything above, then re-run."
  exit 1
fi
green "CLEAN — no personal data, credentials, or licensing gaps found."
