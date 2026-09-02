#!/usr/bin/env bash
# Finds a usable Python. Sourced by the other scripts; prints the command to use.
#
# Windows is the reason this exists: "python3" generally does not exist there.
# Python.org installs provide "python" and the "py" launcher instead, so any
# script hardcoding python3 fails on a perfectly good setup.
find_python() {
  local c
  if [[ -n "${JOBHUNT_PYTHON:-}" ]]; then printf '%s' "$JOBHUNT_PYTHON"; return 0; fi
  for c in python3 python py; do
    if command -v "$c" >/dev/null 2>&1; then
      # "py" is a launcher, and on Windows a bare "python" may be the Microsoft
      # Store stub that only opens the store. Check it actually runs.
      if "$c" -c "import sys; sys.exit(0 if sys.version_info[0]==3 else 1)" >/dev/null 2>&1; then
        printf '%s' "$c"; return 0
      fi
    fi
  done
  return 1
}
