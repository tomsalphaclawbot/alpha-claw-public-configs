#!/usr/bin/env bash
set -euo pipefail

# Generic stalled worker watcher.
# Evaluates active worker sessions and queues prod-worker nudges when stale.

ACTIVE_JSON="${ACTIVE_JSON:-state/subagents/active.json}"
QUEUE_FILE="${QUEUE_FILE:-memory/stalled-workers-queue.jsonl}"
CACHE_FILE="${CACHE_FILE:-memory/stalled-workers-cache.json}"
RUNTIME_STALE_MIN="${RUNTIME_STALE_MIN:-45}"
SESSION_STALE_MIN="${SESSION_STALE_MIN:-20}"
MAX_QUEUE_PER_RUN="${MAX_QUEUE_PER_RUN:-8}"

mkdir -p "$(dirname "$QUEUE_FILE")" "$(dirname "$CACHE_FILE")"

python3 - <<'PY' "$ACTIVE_JSON" "$QUEUE_FILE" "$CACHE_FILE" "$RUNTIME_STALE_MIN" "$SESSION_STALE_MIN" "$MAX_QUEUE_PER_RUN"
import datetime as dt
import json
import os
import sys

active_json, queue_file, cache_file, runtime_stale_min, session_stale_min, max_queue = sys.argv[1:]
runtime_stale_min = int(runtime_stale_min)
session_stale_min = int(session_stale_min)
max_queue = int(max_queue)

now = dt.datetime.now(dt.timezone.utc)


def parse_iso(value):
    if not value or not isinstance(value, str):
        return None
    try:
        return dt.datetime.fromisoformat(value.replace('Z', '+00:00'))
    except Exception:
        return None


def mins_since(ts):
    if ts is None:
        return None
    return max(0.0, (now - ts).total_seconds() / 60.0)


def get_task_id(item):
    if not isinstance(item, dict):
        return None
    for key in ("taskId", "task_id"):
        value = item.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()

    assignment = item.get("assignment")
    if isinstance(assignment, dict):
        for key in ("taskId", "task_id"):
            value = assignment.get(key)
            if isinstance(value, str) and value.strip():
                return value.strip()

    task = item.get("task")
    if isinstance(task, dict):
        value = task.get("id")
        if isinstance(value, str) and value.strip():
            return value.strip()

    return None


def load_active(path):
    if not os.path.exists(path):
        return []
    try:
        data = json.load(open(path, 'r', encoding='utf-8'))
    except Exception:
        return []
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        for key in ("active", "workers", "subagents", "items"):
            value = data.get(key)
            if isinstance(value, list):
                return value
    return []


def load_cache(path):
    if not os.path.exists(path):
        return {}
    try:
        data = json.load(open(path, 'r', encoding='utf-8'))
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


workers = load_active(active_json)
cache = load_cache(cache_file)

# Cooldown to avoid repeated prods for same stale worker.
cooldown_min = 30
queued = []
updated_cache = dict(cache)

for worker in workers:
    if len(queued) >= max_queue:
        break

    if not isinstance(worker, dict):
        continue

    session_key = worker.get("sessionKey") or worker.get("session_key")
    run_id = worker.get("runId") or worker.get("run_id")
    session_id = worker.get("sessionId") or worker.get("session_id")
    task_id = get_task_id(worker)

    if not session_key:
        continue

    started_at = parse_iso(worker.get("startedAt") or worker.get("createdAt") or worker.get("created_at"))
    last_activity = parse_iso(
        worker.get("lastActivityAt")
        or worker.get("updatedAt")
        or worker.get("heartbeatAt")
        or worker.get("last_active_at")
    )

    runtime_min = mins_since(started_at)
    idle_min = mins_since(last_activity)

    reasons = []
    if runtime_min is not None and runtime_min >= runtime_stale_min:
        reasons.append(f"runtime>{runtime_stale_min}m")
    if idle_min is not None and idle_min >= session_stale_min:
        reasons.append(f"idle>{session_stale_min}m")

    if not reasons:
        continue

    key = f"{run_id or 'run'}::{session_key}"
    last_sent = parse_iso(updated_cache.get(key))
    if last_sent is not None and mins_since(last_sent) is not None and mins_since(last_sent) < cooldown_min:
        continue

    task_label = task_id or "this task"
    steer = (
        f"Stall watchdog: continue execution now for {task_label}. "
        "Post a brief status update: active progress, blocker with required input, or completion with validation evidence."
    )

    row = {
        "timestamp": now.isoformat().replace('+00:00', 'Z'),
        "action": "prod-worker",
        "queueKey": key,
        "runId": run_id,
        "sessionKey": session_key,
        "sessionId": session_id,
        "taskId": task_id,
        "reasons": reasons,
        "runtimeMinutes": round(runtime_min, 1) if runtime_min is not None else None,
        "sessionIdleMinutes": round(idle_min, 1) if idle_min is not None else None,
        "requiredTaskUpdate": "progress | blocker | completion",
        "steerMessage": steer,
    }

    queued.append(row)
    updated_cache[key] = row["timestamp"]

if queued:
    with open(queue_file, 'a', encoding='utf-8') as fh:
        for row in queued:
            fh.write(json.dumps(row) + "\n")

with open(cache_file, 'w', encoding='utf-8') as fh:
    json.dump(updated_cache, fh, indent=2)

print(f"[subagent-stall-watch] workers={len(workers)} queued={len(queued)} runtime>{runtime_stale_min}m idle>{session_stale_min}m")
PY
