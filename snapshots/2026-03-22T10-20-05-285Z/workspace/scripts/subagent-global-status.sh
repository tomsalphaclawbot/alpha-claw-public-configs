#!/usr/bin/env bash
set -euo pipefail

# Cross-thread source-of-truth snapshot for active sub-agents.
STATE_DIR="${STATE_DIR:-$HOME/.openclaw/workspace/state/subagents}"
ACTIVE_FILE="$STATE_DIR/active.json"
EVENTS_FILE="$STATE_DIR/events.jsonl"
LOGS_INDEX_FILE="$STATE_DIR/logs-index.json"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$STATE_DIR"

RUNS_FILE="${RUNS_FILE:-$HOME/.openclaw/subagents/runs.json}"

python3 - <<'PY' "$RUNS_FILE" "$TS" "$ACTIVE_FILE" "$EVENTS_FILE" "$LOGS_INDEX_FILE"
import json,sys,os
runs_file,ts,active_file,events_file,logs_index_file=sys.argv[1:6]
items=[]
try:
    payload=json.load(open(runs_file))
except Exception:
    payload={}
runs=payload.get('runs',{}) if isinstance(payload,dict) else {}
logs_index={}
for _id,r in runs.items():
    session_key = r.get('childSessionKey') or r.get('sessionKey')
    run_id = r.get('runId')
    if run_id and session_key:
        logs_index[run_id] = {
            'sessionKey': session_key,
            'logReference': f'sessions_history({session_key})'
        }
    if r.get('endedAt'):
        continue
    items.append({
        'runId': run_id,
        'sessionKey': session_key,
        'label': r.get('label'),
        'task': r.get('task'),
        'startedAt': r.get('startedAt'),
        'model': r.get('model')
    })
obj={'timestamp':ts,'activeCount':len(items),'workers':items}
with open(active_file,'w') as f:
    json.dump(obj,f,indent=2)
with open(logs_index_file,'w') as f:
    json.dump({'timestamp':ts,'runs':logs_index},f,indent=2)
with open(events_file,'a') as f:
    f.write(json.dumps({'timestamp':ts,'event':'snapshot','activeCount':len(items)})+'\n')
print(f"wrote {active_file} activeCount={len(items)}")
PY