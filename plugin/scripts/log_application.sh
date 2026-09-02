#!/usr/bin/env bash
# Wrapper around log_application.py that finds Python on any platform.
set -uo pipefail
_src="${BASH_SOURCE[0]}"; _dir="${_src%/*}"; [[ "$_dir" == "$_src" ]] && _dir="."
HERE="$(cd "$_dir" && pwd)"
# shellcheck source=/dev/null
. "$HERE/_python.sh"
PY="$(find_python)" || {
  echo "No Python 3 found. Install it from https://python.org, or set JOBHUNT_PYTHON." >&2
  echo "Your application files are fine — only the tracker row was skipped." >&2
  exit 0
}
exec "$PY" "$HERE/log_application.py" "$@"
