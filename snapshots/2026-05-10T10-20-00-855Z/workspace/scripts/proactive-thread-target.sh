#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
ACTIVE_FILE="${ACTIVE_FILE:-$WORKSPACE/state/conversations/active.json}"

python3 - "$ACTIVE_FILE" <<'PY'
import json,sys
p=sys.argv[1]
try:
    j=json.load(open(p))
except Exception:
    sys.exit(1)
pref=j.get('preferred') or {}
key=pref.get('key')
if key and pref.get('updateEligible', False):
    print(key)
    sys.exit(0)
sys.exit(1)
PY