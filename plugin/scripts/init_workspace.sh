#!/usr/bin/env bash
# Scaffold a Job-Hunt OS user workspace. Safe to re-run: never overwrites.
#   bash init_workspace.sh [path]      (default: ./job-hunt)
set -euo pipefail
WS="${1:-./job-hunt}"
mkdir -p "$WS"/{profile,config,applications,interview-prep,tracker}

TRACKER="$WS/tracker/applications.csv"
if [[ ! -f "$TRACKER" ]]; then
  printf 'Company,Title,Date Applied,Status,Salary,Location,Remote,JD Link,Resume,Notes\n' > "$TRACKER"
fi

if [[ ! -f "$WS/.gitignore" ]]; then
  cat > "$WS/.gitignore" <<'EOF'
# This workspace holds personal data. If you version it, keep it PRIVATE.
*service-account*.json
webhook-url.txt
.env
EOF
fi

printf '%s\n' "$(cd "$WS" && pwd)"
