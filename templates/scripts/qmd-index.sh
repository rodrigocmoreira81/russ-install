#!/usr/bin/env bash
# qmd-index.sh — reindexa o cérebro no qmd (crontab do Linux, 1x por noite). Módulo A1.
#   20 4 * * * ~/.hermes/scripts/qmd-index.sh
set -euo pipefail
export QMD_FORCE_CPU=1
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
LOG="$HOME/.hermes/logs/qmd-index.log"
mkdir -p "$(dirname "$LOG")"
{
  echo "=== $(date -u +%FT%TZ) start ==="
  nice -n 19 qmd update          # incremental, ~1s
  nice -n 19 qmd embed           # só o que mudou
  qmd status | grep -E 'Total|Vectors|Pending' || true
  echo "=== $(date -u +%FT%TZ) done ==="
} >> "$LOG" 2>&1
