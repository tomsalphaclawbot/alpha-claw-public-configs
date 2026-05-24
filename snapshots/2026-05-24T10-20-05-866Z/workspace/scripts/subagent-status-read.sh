#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-$HOME/.openclaw/workspace/state/subagents/active.json}"
python3 - <<'PY' "$FILE"
import json,sys
p=sys.argv[1]
try:
 d=json.load(open(p))
except Exception:
 print('activeCount=0')
 sys.exit(0)
print(f"activeCount={d.get('activeCount',0)}")
for w in d.get('workers',[]):
 print(f"- {w.get('label')} | {w.get('runId')} | {w.get('sessionKey')}")
PY