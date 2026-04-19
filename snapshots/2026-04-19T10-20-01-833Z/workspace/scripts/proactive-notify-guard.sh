#!/usr/bin/env bash
# proactive-notify-guard.sh
# Check cooldown + eligibility before allowing a proactive notification to a session.
#
# Usage:
#   scripts/proactive-notify-guard.sh [session-key]
#   Exit 0 = OK to notify (prints resolved session key)
#   Exit 1 = suppressed (cooldown active or no eligible session)
#
# Env overrides:
#   COOLDOWN_SEC        per-session cooldown in seconds (default: 300 = 5 min)
#   GLOBAL_COOLDOWN_SEC global cross-session cooldown (default: 60 = 1 min)
#   NOTIFY_STATE_FILE   path to per-session cooldown state (default: state/conversations/notify-state.json)
#   ACTIVE_FILE         path to active.json (default: state/conversations/active.json)

set -euo pipefail

WORKSPACE="${WORKSPACE:-$(cd "$(dirname "$0")/.." && pwd)}"
ACTIVE_FILE="${ACTIVE_FILE:-$WORKSPACE/state/conversations/active.json}"
NOTIFY_STATE_FILE="${NOTIFY_STATE_FILE:-$WORKSPACE/state/conversations/notify-state.json}"
COOLDOWN_SEC="${COOLDOWN_SEC:-300}"        # 5 min per-session cooldown
GLOBAL_COOLDOWN_SEC="${GLOBAL_COOLDOWN_SEC:-60}"  # 1 min global cooldown

SESSION_KEY="${1:-}"

python3 - "$ACTIVE_FILE" "$NOTIFY_STATE_FILE" "$COOLDOWN_SEC" "$GLOBAL_COOLDOWN_SEC" "$SESSION_KEY" <<'PY'
import json, sys, time, os

active_file, state_file, cooldown_sec, global_cooldown_sec, requested_key = sys.argv[1:]
cooldown_sec = int(cooldown_sec)
global_cooldown_sec = int(global_cooldown_sec)

now_ms = int(time.time() * 1000)
now_sec = int(time.time())

# Load active sessions
try:
    active = json.load(open(active_file))
except Exception as e:
    print(f"[proactive-guard] ERROR reading {active_file}: {e}", file=sys.stderr)
    sys.exit(1)

# Load cooldown state
state = {}
if os.path.exists(state_file):
    try:
        state = json.load(open(state_file))
    except Exception:
        state = {}

last_notified_any = state.get("lastNotifiedAnyEpoch", 0)
per_session = state.get("perSession", {})

# Global cooldown check
if (now_sec - last_notified_any) < global_cooldown_sec:
    remaining = global_cooldown_sec - (now_sec - last_notified_any)
    print(f"[proactive-guard] SUPPRESSED global cooldown active ({remaining}s remaining)", file=sys.stderr)
    sys.exit(1)

# Resolve target session
if requested_key:
    sessions = [s for s in active.get("sessions", []) if s["key"] == requested_key]
    target = sessions[0] if sessions else None
else:
    target = active.get("preferred")

if not target:
    print("[proactive-guard] SUPPRESSED no eligible session found", file=sys.stderr)
    sys.exit(1)

if not target.get("eligibleForProactive", False):
    print(f"[proactive-guard] SUPPRESSED session {target['key']} not eligible for proactive", file=sys.stderr)
    sys.exit(1)

if not target.get("updateEligible", False):
    print(f"[proactive-guard] SUPPRESSED session {target['key']} not update-eligible (system/non-routable)", file=sys.stderr)
    sys.exit(1)

# Per-session cooldown check
key = target["key"]
last_notified_session = per_session.get(key, {}).get("lastEpoch", 0)
if (now_sec - last_notified_session) < cooldown_sec:
    remaining = cooldown_sec - (now_sec - last_notified_session)
    print(f"[proactive-guard] SUPPRESSED per-session cooldown active for {key} ({remaining}s remaining)", file=sys.stderr)
    sys.exit(1)

# OK — update state and emit session key
per_session[key] = {"lastEpoch": now_sec, "lastMs": now_ms}
state = {
    "lastNotifiedAnyEpoch": now_sec,
    "lastNotifiedKey": key,
    "perSession": per_session,
}
os.makedirs(os.path.dirname(state_file), exist_ok=True)
with open(state_file, "w") as f:
    json.dump(state, f, indent=2)

print(key)
sys.exit(0)
PY
