#!/usr/bin/env bash
# Job-Hunt OS regression tests. No framework — run it and read the output.
#
#   bash tests/run-tests.sh
#
# Exists because the profile-strength number (how many roles carry a real
# metric) has had three separate bugs. It is the number onboarding is built
# around, it is parsed from text people write by hand, and every bug in it was
# found after shipping. Run this before tagging a release.

set -uo pipefail
_src="${BASH_SOURCE[0]}"; _dir="${_src%/*}"; [[ "$_dir" == "$_src" ]] && _dir="."
ROOT="$(cd "$_dir/.." && pwd)"
P="$ROOT/plugin/scripts"
PASS=0; FAIL=0
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

ok()  { printf '  PASS  %s\n' "$*"; PASS=$((PASS+1)); }
bad() { printf '  FAIL  %s\n' "$*"; FAIL=$((FAIL+1)); }

echo "Job-Hunt OS — regression tests"
echo

# ---------------------------------------------------------------------------
echo "Profile parsing (fixtures named <roles>-<with-metrics>-<case>.md)"
bash "$P/init_workspace.sh" "$WORK/ws" >/dev/null
for f in "$ROOT"/tests/profiles/*.md; do
  base="$(basename "$f" .md)"
  want_roles="${base%%-*}"; rest="${base#*-}"; want_metrics="${rest%%-*}"
  cp "$f" "$WORK/ws/profile/master-profile.md"
  out="$(cd "$WORK/ws" && bash "$P/doctor.sh" 2>&1)"

  if grep -q "no roles found" <<<"$out"; then
    got_roles=0; got_metrics=0
  else
    line="$(grep -E "Profile — " <<<"$out" | head -1)"
    # the failing path reads "only N of M", the passing path "N of M"
    got_metrics="$(sed -n 's/.*[——] *\(only \)\{0,1\}\([0-9][0-9]*\) of \([0-9][0-9]*\) roles.*/\2/p' <<<"$line")"
    got_roles="$(sed -n 's/.*[——] *\(only \)\{0,1\}\([0-9][0-9]*\) of \([0-9][0-9]*\) roles.*/\3/p' <<<"$line")"
    got_metrics="${got_metrics:-?}"; got_roles="${got_roles:-?}"
  fi

  if [[ "$got_roles" == "$want_roles" && "$got_metrics" == "$want_metrics" ]]; then
    ok "$base  ($got_metrics of $got_roles)"
  else
    bad "$base  expected $want_metrics of $want_roles, got $got_metrics of $got_roles"
  fi

  # A finding must never surface as a shell error.
  grep -qE "syntax error|unbound variable|command not found" <<<"$out" \
    && bad "$base  produced a shell error:" && grep -E "syntax error|unbound variable|command not found" <<<"$out" | sed 's/^/          /'
done

# ---------------------------------------------------------------------------
echo
echo "Tracker — spreadsheet formula injection"
cd "$WORK/ws"
for payload in '=HYPERLINK("http://evil.test","x")' '+1234' '-2+3' '@SUM(1)' 'Normal Co'; do
  bash "$P/log_application.sh" --company "$payload" --title t >/dev/null 2>&1
done
python3 - <<'PY' > "$WORK/inj.txt"
import csv
rows = list(csv.reader(open("tracker/applications.csv")))[1:]
live = [r[0] for r in rows if r and r[0][:1] in ("=", "+", "-", "@")]
plain = [r[0] for r in rows if r and r[0] == "Normal Co"]
print(len(live), len(plain))
PY
read -r live plain < "$WORK/inj.txt"
[[ "$live" == "0" ]] && ok "all four injection payloads neutralised" || bad "$live payload(s) still executable"
[[ "$plain" == "1" ]] && ok "ordinary company name left unchanged" || bad "ordinary value was mangled"

# ---------------------------------------------------------------------------
echo
echo "Rendering"
cp "$ROOT/example/operations-manager/resume-after.html" "$WORK/r.html"
if bash "$P/render_pdf.sh" "$WORK/r.html" "$WORK/r.pdf" >/dev/null 2>&1; then
  ok "renders a PDF"
  [[ "$(bash "$P/pagecount.sh" "$WORK/r.pdf")" == "1" ]] && ok "resume is one page" || bad "resume is not one page"
else
  bad "render failed"
fi
mkdir -p "$WORK/dir with spaces"
cp "$WORK/r.html" "$WORK/dir with spaces/r.html"
bash "$P/render_pdf.sh" "$WORK/dir with spaces/r.html" "$WORK/dir with spaces/out.pdf" >/dev/null 2>&1 \
  && ok "handles paths containing spaces" || bad "paths with spaces break rendering"
[[ -z "$(find "$WORK" -name '.render-*' 2>/dev/null)" ]] && ok "no temp files left behind" || bad "temp files left behind"

# ---------------------------------------------------------------------------
echo
echo "Graceful degradation"
out="$(cd "$WORK/ws" && env PATH=/bin bash "$P/pagecount.sh" "$WORK/r.pdf" 2>/dev/null; echo "rc=$?")"
grep -q "rc=0" <<<"$out" && ok "pagecount exits 0 with no Python" || bad "pagecount hard-fails without Python"
out="$(cd "$WORK/ws" && env PATH=/bin bash "$P/log_application.sh" --company X 2>/dev/null; echo "rc=$?")"
grep -q "rc=0" <<<"$out" && ok "logging exits 0 with no Python" || bad "logging hard-fails without Python"

# ---------------------------------------------------------------------------
echo
echo "Manifests"
python3 - "$ROOT" <<'PY' && ok "versions valid and in sync" || bad "manifest version mismatch"
import json, sys, re
r = sys.argv[1]
a = json.load(open(f"{r}/plugin/.claude-plugin/plugin.json"))["version"]
b = json.load(open(f"{r}/.claude-plugin/marketplace.json"))["plugins"][0]["version"]
assert a == b, f"plugin.json {a} != marketplace.json {b}"
assert re.fullmatch(r"\d+\.\d+\.\d+", a), f"not semver: {a}"
PY
for s in "$ROOT"/plugin/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$s")")"
  head -5 "$s" | grep -q "^name: $name$" || bad "skill $name: frontmatter name mismatch"
done
ok "every skill's frontmatter name matches its folder"

echo
echo "-----------------------------------------"
printf ' %d passed, %d failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
