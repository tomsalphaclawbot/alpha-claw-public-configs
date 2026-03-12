#!/bin/bash
set -euo pipefail
cd /Users/openclaw/.openclaw/workspace
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export BEADS_DB="/Users/openclaw/.openclaw/workspace/.beads/ephemeral.sqlite3"

# Only restart if health check fails; otherwise leave running instance alone.
if ! curl -fsS http://127.0.0.1:3030 >/dev/null 2>&1; then
  bdui stop >/dev/null 2>&1 || true
  bdui start --host 127.0.0.1 --port 3030 >/tmp/openclaw-beads-ui.log 2>&1 || true
fi
