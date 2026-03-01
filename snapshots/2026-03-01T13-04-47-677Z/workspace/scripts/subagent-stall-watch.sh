#!/usr/bin/env bash
set -euo pipefail

# Beads-native stalled worker watcher.
# Detects runtime/session-silence stalls and proactively re-probes workers when
# fresh Beads comments are added on their linked task (cross-thread unblock path).

STALL_MINUTES="${STALL_MINUTES:-30}"
SESSION_STALE_MINUTES="${SESSION_STALE_MINUTES:-20}"
COMMENT_TRIGGER_MINUTES="${COMMENT_TRIGGER_MINUTES:-8}"
MEMORY_DIR="${MEMORY_DIR:-$HOME/.openclaw/workspace/memory}"
QUEUE_FILE="$MEMORY_DIR/stalled-workers-queue.jsonl"
ACTIVE_FILE="${ACTIVE_FILE:-$HOME/.openclaw/workspace/state/subagents/active.json}"

mkdir -p "$MEMORY_DIR"

python3 - <<'PY' "$STALL_MINUTES" "$SESSION_STALE_MINUTES" "$COMMENT_TRIGGER_MINUTES" "$ACTIVE_FILE" "$QUEUE_FILE" "$MEMORY_DIR"
import datetime
import json
import pathlib
import re
import subprocess
import sys
import time

stall = int(sys.argv[1])
session_stale = int(sys.argv[2])
comment_trigger = int(sys.argv[3])
active_file = sys.argv[4]
queue_file = sys.argv[5]
memory_dir = sys.argv[6]

now_ms = int(time.time() * 1000)
cache_path = pathlib.Path(memory_dir) / 'stalled-workers-cache.json'
cooldown_ms = 60 * 60 * 1000  # 1h per run/session signature

try:
    data = json.load(open(active_file))
except Exception:
    print('[subagent-stall-watch] no active worker snapshot')
    raise SystemExit(0)

try:
    cache = json.load(open(cache_path))
    if not isinstance(cache, dict):
        cache = {}
except Exception:
    cache = {}

workers = []
if isinstance(data, dict):
    workers = data.get('workers') or data.get('active') or []
elif isinstance(data, list):
    workers = data

session_updates = {}
try:
    raw = subprocess.check_output(['openclaw', 'sessions', '--json'], text=True)
    j = json.loads(raw)
    sessions = j.get('sessions') if isinstance(j, dict) else (j if isinstance(j, list) else [])
    for s in sessions:
        k = s.get('key')
        u = s.get('updatedAt')
        if k and isinstance(u, (int, float)):
            session_updates[str(k)] = int(u)
except Exception:
    session_updates = {}

bead_show_cache = {}

def bead_comments(bead_id: str):
    if bead_id in bead_show_cache:
        return bead_show_cache[bead_id]
    try:
        out = subprocess.check_output(['bd', 'show', bead_id, '--json'], text=True)
        payload = json.loads(out)
        issue = payload[0] if isinstance(payload, list) and payload else payload
        comments = issue.get('comments') if isinstance(issue, dict) else []
        if not isinstance(comments, list):
            comments = []
    except Exception:
        comments = []
    bead_show_cache[bead_id] = comments
    return comments

if not workers:
    print('[subagent-stall-watch] scan complete (no active workers)')
    raise SystemExit(0)

ts = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')
emitted = 0
suppressed = 0

with open(queue_file, 'a', encoding='utf-8') as f:
    for w in workers:
        started = w.get('startedAt')
        runtime_age = None
        if isinstance(started, (int, float)):
            runtime_age = (now_ms - int(started)) / 60000

        skey = str(w.get('sessionKey') or '')
        sess_updated = session_updates.get(skey)
        session_age = None
        if isinstance(sess_updated, int):
            session_age = (now_ms - sess_updated) / 60000

        task_text = str(w.get('task') or '')
        bead_match = re.search(r'\bworkspace-[a-z0-9]+\b', task_text)
        bead_id = bead_match.group(0) if bead_match else None

        reasons = []
        if runtime_age is not None and runtime_age >= stall:
            reasons.append(f'runtime>{stall}m')
        if session_age is not None and session_age >= session_stale:
            reasons.append(f'session_silence>{session_stale}m')

        # New behavior: if Beads comments changed and worker is at least mildly stale,
        # queue a context-injection prod to resume execution with latest unblock info.
        new_comment_lines = []
        latest_comment_id = None
        if bead_id:
            comments = bead_comments(bead_id)
            if comments:
                try:
                    latest_comment_id = int(comments[-1].get('id'))
                except Exception:
                    latest_comment_id = None

                sig_base = str(w.get('runId') or w.get('sessionKey') or w.get('label') or bead_id)
                cursor_key = f'comment_cursor::{sig_base}'
                last_seen_comment_id = int(cache.get(cursor_key, 0) or 0)

                if latest_comment_id and latest_comment_id > last_seen_comment_id:
                    stale_enough = (session_age is None) or (session_age >= comment_trigger)
                    if stale_enough:
                        reasons.append('bead_comment_update')
                        for c in comments:
                            try:
                                cid = int(c.get('id'))
                            except Exception:
                                continue
                            if cid <= last_seen_comment_id:
                                continue
                            text = ' '.join(str(c.get('text') or '').split())
                            if len(text) > 280:
                                text = text[:277] + '...'
                            new_comment_lines.append(
                                f"- [{c.get('created_at')}] #{cid} {c.get('author')}: {text}"
                            )
                        new_comment_lines = new_comment_lines[-3:]

        if not reasons:
            continue

        sig_base = str(w.get('runId') or w.get('sessionKey') or w.get('label') or w.get('task') or 'unknown')
        cooldown_sig = sig_base
        if latest_comment_id and 'bead_comment_update' in reasons:
            cooldown_sig = f"{sig_base}::comment::{latest_comment_id}"

        cooldown_key = f'cooldown::{cooldown_sig}'
        last = cache.get(cooldown_key)
        if isinstance(last, int) and (now_ms - last) < cooldown_ms:
            suppressed += 1
            continue

        cadence = (
            f"Required now: post bd comments on {bead_id or '<bead-id>'} for "
            f"status=active/blocker/completion with evidence and last_heartbeat_at (no silent stop)."
        )

        steer = (
            f"Stall watchdog flagged your worker ({', '.join(reasons)}). "
            f"Immediate actions: 1) continue task execution with next concrete step, "
            f"2) if blocked, post structured blocker comment (blocked_on/needed/why/evidence/next_check), "
            f"3) if complete, post validation evidence and close. {cadence}"
        )
        if new_comment_lines:
            steer += "\n\nNew Beads context added since your last acknowledged update:\n" + "\n".join(new_comment_lines)

        row = {
            'timestamp': ts,
            'queueType': 'stalled-worker',
            'queueKey': f"stalled::{cooldown_sig}::{ts}",
            'runId': w.get('runId'),
            'sessionKey': w.get('sessionKey'),
            'label': w.get('label'),
            'task': task_text,
            'beadId': bead_id,
            'runtimeAgeMinutes': round(runtime_age, 1) if runtime_age is not None else None,
            'sessionAgeMinutes': round(session_age, 1) if session_age is not None else None,
            'reasons': reasons,
            'action': 'prod-worker',
            'steerMessage': steer,
            'requiredBeadsComment': cadence,
            'latestCommentId': latest_comment_id,
            'newCommentCount': len(new_comment_lines),
        }
        f.write(json.dumps(row) + "\n")

        cache[cooldown_key] = now_ms
        if bead_id and latest_comment_id:
            cursor_key = f"comment_cursor::{sig_base}"
            cache[cursor_key] = int(latest_comment_id)

        emitted += 1
        print(f"[subagent-stall-watch] queued prod for {w.get('label')} reasons={','.join(reasons)} bead={bead_id or '-'}")

cache_path.parent.mkdir(parents=True, exist_ok=True)
json.dump(cache, open(cache_path, 'w'), indent=2)
if emitted == 0:
    if suppressed > 0:
        print(f"[subagent-stall-watch] scan complete (suppressed={suppressed}, cooldown=60m)")
    else:
        print('[subagent-stall-watch] scan complete (no stalls/comment updates)')
PY
