#!/usr/bin/env bash
set -euo pipefail

TARGET_POOL="${TARGET_POOL:-5}"
PROOF_FILE="state/heartbeat-proof.jsonl"
TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Stalled-worker prod queue controls
STALLED_QUEUE_FILE="${STALLED_QUEUE_FILE:-memory/stalled-workers-queue.jsonl}"
PROD_LOG_FILE="${PROD_LOG_FILE:-state/subagent-prod-actions.jsonl}"
PROD_CACHE_FILE="${PROD_CACHE_FILE:-state/subagent-prod-cache.json}"
MAX_PRODS_PER_RUN="${MAX_PRODS_PER_RUN:-3}"

mkdir -p state

# Refresh canonical worker snapshot first to avoid decisions from stale active.json.
if [[ -x "scripts/subagent-global-status.sh" ]]; then
  scripts/subagent-global-status.sh >/dev/null 2>&1 || true
fi

worker_count=$(python3 - <<'PY'
import json
p='state/subagents/active.json'
try:
    d=json.load(open(p))
except Exception:
    print(0); raise SystemExit
if isinstance(d,list):
    print(len(d)); raise SystemExit
if isinstance(d,dict):
    for k in ('active','workers','subagents','items'):
        v=d.get(k)
        if isinstance(v,list):
            print(len(v)); raise SystemExit
    for ck in ('activeCount','count'):
        c=d.get(ck)
        if isinstance(c,int):
            print(c); raise SystemExit
print(0)
PY
)

# top actionable task from tasks/ACTIVE.md
candidate=""
candidate="$(python3 - <<'PY'
import re
from pathlib import Path

active = Path('tasks/ACTIVE.md')
if not active.exists():
    raise SystemExit(0)

task_re = re.compile(r'^##\s+(task-\d{8}-\d+):\s+(.+)')
status_re = re.compile(r'\*\*Status:\*\*\s*(\S+)')

tasks = []
current = None
for raw in active.read_text(encoding='utf-8').splitlines():
    m = task_re.match(raw)
    if m:
        if current:
            tasks.append(current)
        current = {
            'id': m.group(1),
            'title': m.group(2).strip(),
            'status': 'todo',
            'open': 0,
            'done': 0,
        }
        continue

    if current is None:
        continue

    sm = status_re.search(raw)
    if sm:
        current['status'] = sm.group(1).strip().lower()
        continue

    line = raw.lstrip()
    if line.startswith('- [x]') or line.startswith('- [X]'):
        current['done'] += 1
    elif line.startswith('- [ ]'):
        current['open'] += 1

if current:
    tasks.append(current)

actionable = []
for t in tasks:
    if t['status'] in ('done', 'complete', 'completed', 'cancelled', 'blocked'):
        continue
    if t['open'] == 0 and t['done'] > 0:
        continue
    actionable.append(t)

if actionable:
    top = actionable[0]
    print(f"{top['id']}\t{top['title']}")
PY
)"

action="healthy"
reason="pool_ok"
if (( worker_count < TARGET_POOL )); then
  if [[ -n "$candidate" ]]; then
    action="spawn_needed"
    reason="worker_pool_below_target"
  else
    action="blocked"
    reason="no_actionable_tasks"
  fi
fi

printf '{"ts":"%s","target_pool":%s,"worker_count":%s,"action":"%s","reason":"%s","candidate":%s}\n' \
  "$TS" "$TARGET_POOL" "$worker_count" "$action" "$reason" "$(python3 - <<'PY' "$candidate"
import json,sys
print(json.dumps(sys.argv[1]))
PY
)" >> "$PROOF_FILE"

echo "worker_count=$worker_count target_pool=$TARGET_POOL action=$action reason=$reason candidate=${candidate:-none}"

# Consume stalled-worker queue and actively prod stale workers via their session.
python3 - <<'PY' "$STALLED_QUEUE_FILE" "$PROD_LOG_FILE" "$PROD_CACHE_FILE" "$MAX_PRODS_PER_RUN"
import json,sys,subprocess,time,datetime,os
queue_file,prod_log,cache_file,max_prods = sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4])
now = datetime.datetime.now(datetime.timezone.utc)

if not os.path.exists(queue_file):
    print('[heartbeat-enforce] no stalled-worker queue file')
    raise SystemExit(0)

try:
    with open(queue_file,'r',encoding='utf-8') as f:
        rows=[json.loads(line) for line in f if line.strip()]
except Exception:
    print('[heartbeat-enforce] stalled-worker queue unreadable')
    raise SystemExit(0)

if not rows:
    print('[heartbeat-enforce] stalled-worker queue empty')
    raise SystemExit(0)

# keep recent queue items only
recent=[]
for r in rows[-500:]:
    ts=r.get('timestamp')
    if not ts:
        continue
    try:
        dt=datetime.datetime.fromisoformat(str(ts).replace('Z','+00:00'))
    except Exception:
        continue
    if (now-dt).total_seconds() <= 12*3600:
        recent.append(r)

if not recent:
    print('[heartbeat-enforce] no recent stalled-worker queue items')
    raise SystemExit(0)

try:
    cache=json.load(open(cache_file))
    if not isinstance(cache,dict):
        cache={}
except Exception:
    cache={}

try:
    sessions_raw=subprocess.check_output(['openclaw','sessions','--json'], text=True)
    sessions_json=json.loads(sessions_raw)
    sessions=sessions_json.get('sessions') if isinstance(sessions_json,dict) else (sessions_json if isinstance(sessions_json,list) else [])
except Exception:
    sessions=[]

session_by_key={}
for s in sessions:
    key=s.get('key')
    sid=s.get('sessionId')
    if key and sid:
        session_by_key[str(key)]=str(sid)

sent=0
attempted=0
for row in recent:
    if sent >= max_prods:
        break
    if row.get('action') != 'prod-worker':
        continue

    key=row.get('queueKey') or f"{row.get('runId')}::{row.get('sessionKey')}::{row.get('timestamp')}"
    if cache.get(key):
        continue

    attempted += 1
    session_key=row.get('sessionKey')
    session_id=session_by_key.get(str(session_key or ''))
    task_id=row.get('taskId') or '<task-id>'
    steer=row.get('steerMessage') or (
        f"Stall watchdog requested progress. Continue task execution now and post required task status cadence for {task_id}: "
        f"active/progress update, structured blocker with required input, or completion with validation evidence."
    )

    status='no-session'
    rc=None
    out=''
    if session_id:
        cmd=['openclaw','agent','--session-id',session_id,'--message',steer,'--json']
        try:
            proc=subprocess.run(cmd, text=True, capture_output=True, timeout=120)
            rc=proc.returncode
            out=(proc.stdout or proc.stderr or '')[:800]
            status='sent' if proc.returncode==0 else 'send-error'
        except Exception as e:
            status='send-error'
            out=str(e)

    log={
        'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00','Z'),
        'queueKey': key,
        'action': 'prod-worker',
        'status': status,
        'runId': row.get('runId'),
        'sessionKey': session_key,
        'sessionId': session_id,
        'taskId': row.get('taskId'),
        'reasons': row.get('reasons'),
        'requiredTaskUpdate': row.get('requiredTaskUpdate'),
        'commandRc': rc,
        'commandOutput': out,
    }
    os.makedirs(os.path.dirname(prod_log), exist_ok=True)
    with open(prod_log,'a',encoding='utf-8') as f:
        f.write(json.dumps(log)+"\n")

    # mark processed when sent or when session is gone (prevents infinite replay noise)
    if status in ('sent','no-session'):
        cache[key]=log['timestamp']
    if status == 'sent':
        sent += 1

os.makedirs(os.path.dirname(cache_file), exist_ok=True)
with open(cache_file,'w',encoding='utf-8') as f:
    json.dump(cache,f,indent=2)

print(f"[heartbeat-enforce] prod attempts={attempted} sent={sent} max={max_prods} log={prod_log}")
PY

# System mail sweep (best-effort): catch local cron/daemon failures delivered via unix mailbox.
if [[ -x "scripts/unix-mail-check.sh" ]]; then
  scripts/unix-mail-check.sh || true
fi
