#!/usr/bin/env bash
set -euo pipefail

# Beads-native dispatcher (non-AI):
# - scans open Beads tasks
# - queues top actionable candidates for sub-agent kickoff
# - emits deterministic queue rows with required Beads status cadence guidance

MEMORY_DIR="${MEMORY_DIR:-$HOME/.openclaw/workspace/memory}"
QUEUE_FILE="$MEMORY_DIR/subagent-dispatch-queue.jsonl"
MAX_QUEUE_PER_RUN="${MAX_QUEUE_PER_RUN:-3}"

mkdir -p "$MEMORY_DIR"

python3 - <<'PY' "$MAX_QUEUE_PER_RUN" "$QUEUE_FILE"
import json,sys,datetime,time
limit=int(sys.argv[1]); queue_file=sys.argv[2]
now=time.time()
cooldown_sec=30*60  # do not requeue same bead within 30m


def load_tasks():
    import subprocess
    try:
        out=subprocess.check_output(['bd','list','--status','open','--json'], text=True)
        return json.loads(out)
    except Exception:
        return []


def is_actionable(t):
    title=(t.get('title') or '').lower()
    return not title.startswith('sync:')


def load_recent_queue(path):
    recent={}
    try:
        with open(path,'r',encoding='utf-8') as f:
            lines=f.readlines()[-1000:]
        for line in lines:
            try:
                row=json.loads(line)
            except Exception:
                continue
            bead=row.get('bead')
            ts=row.get('timestamp')
            if not bead or not ts:
                continue
            try:
                t=datetime.datetime.fromisoformat(ts.replace('Z','+00:00')).timestamp()
            except Exception:
                continue
            if (now - t) <= cooldown_sec:
                recent[str(bead)] = max(recent.get(str(bead),0), t)
    except Exception:
        pass
    return recent

recent=load_recent_queue(queue_file)
tasks=[t for t in load_tasks() if is_actionable(t)]
tasks.sort(key=lambda x:(x.get('priority',9), x.get('created_at','9999-12-31T00:00:00Z'), x.get('id','')))
selected=[]
for t in tasks:
    bid=str(t.get('id') or '')
    if not bid:
        continue
    if bid in recent:
        continue
    selected.append(t)
    if len(selected) >= limit:
        break

ts=datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00','Z')
with open(queue_file,'a',encoding='utf-8') as f:
    for t in selected:
        bead=t.get('id')
        row={
            'timestamp': ts,
            'queueType': 'dispatch',
            'queueKey': f"dispatch::{bead}::{ts}",
            'bead': bead,
            'title': t.get('title'),
            'priority': t.get('priority'),
            'status': 'pending-main-agent-spawn',
            'requiredWorkerCadence': {
                'activation': 'bd comments add <bead> "claim: worker_agent=...; worker_session=...; worker_mode=...; log_ref=...; last_heartbeat_at=...; status=active"',
                'progress': 'bd comments add <bead> "progress: ...; evidence=<cmd/log>; last_heartbeat_at=..."',
                'blocker': 'bd comments add <bead> "blocked_on=...; needed=...; why=...; evidence=...; next_check=...; last_heartbeat_at=...; label=blocked"',
                'completion': 'bd comments add <bead> "completion: ...; validation_evidence=...; last_heartbeat_at=...; status=done"'
            }
        }
        f.write(json.dumps(row)+"\n")
        print(f"[subagent-dispatcher] queued {t.get('id')} P{t.get('priority')} {t.get('title')}")
if not selected:
    print('[subagent-dispatcher] scan complete (no new queue candidates after cooldown)')
PY
