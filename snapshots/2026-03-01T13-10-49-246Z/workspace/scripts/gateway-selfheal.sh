#!/usr/bin/env bash
set -euo pipefail

# This script is safe/idempotent and may be run from crontab or manually.
# It should always attempt gateway self-heal when unhealthy.
#
# Health criteria now includes an active gateway request/response check:
# - service status reports running + RPC probe ok
# - openclaw gateway call health returns {"ok": true}

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

LOG_DIR="$HOME/.openclaw/logs"
LOG_FILE="$LOG_DIR/gateway-selfheal.log"
LOCK_DIR="/tmp/openclaw-gateway-selfheal.lock"
STATE_FILE="$HOME/.openclaw/state/gateway-selfheal-state.json"
COOLDOWN_SEC="${COOLDOWN_SEC:-180}"   # cooldown only for aggressive doctor fallback

mkdir -p "$LOG_DIR" "$(dirname "$STATE_FILE")"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" >> "$LOG_FILE"; }

snippet() {
  echo "$1" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-900
}

get_status() {
  openclaw gateway status 2>&1 || true
}

# Active request/response probe (beyond process/service checks)
get_gateway_health_call() {
  openclaw gateway call health 2>&1 || true
}

is_status_healthy() {
  local s="$1"
  grep -q "Runtime: running" <<<"$s" && grep -q "RPC probe: ok" <<<"$s"
}

is_roundtrip_healthy() {
  local s="$1"
  grep -Eq '"ok"[[:space:]]*:[[:space:]]*true' <<<"$s"
}

is_healthy() {
  local status_out="$1"
  local call_out="$2"
  is_status_healthy "$status_out" && is_roundtrip_healthy "$call_out"
}

service_missing() {
  local s="$1"
  grep -Eq "Service not installed|Service unit not found|Could not find service \"ai\.openclaw\.gateway\"" <<<"$s"
}

read_last_fix_epoch() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo 0
    return
  fi
  python3 - <<'PY' "$STATE_FILE"
import json,sys
p=sys.argv[1]
try:
  d=json.load(open(p))
  print(int(d.get('last_fix_epoch',0)))
except Exception:
  print(0)
PY
}

write_last_fix_epoch() {
  local t="$1"
  python3 - <<'PY' "$STATE_FILE" "$t"
import json,sys,os
p=sys.argv[1]; t=int(sys.argv[2])
os.makedirs(os.path.dirname(p), exist_ok=True)
obj={"last_fix_epoch": t}
with open(p,'w') as f:
  json.dump(obj,f)
PY
}

run_install_if_needed() {
  local s="$1"
  if service_missing "$s"; then
    log "repair: service missing, running 'openclaw gateway install'"
    local out
    out="$(openclaw gateway install 2>&1 || true)"
    log "install output: $(snippet "$out")"
  fi
}

run_start_attempt() {
  log "repair: running 'openclaw gateway start'"
  local out
  out="$(openclaw gateway start 2>&1 || true)"
  log "start output: $(snippet "$out")"
}

# simple lock (portable on macOS without flock)
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "skip: lock held"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" >/dev/null 2>&1 || true' EXIT

status_0="$(get_status)"
call_0="$(get_gateway_health_call)"
if is_healthy "$status_0" "$call_0"; then
  log "healthy: gateway running + RPC ok + health call ok"
  exit 0
fi

log "unhealthy: initial status $(snippet "$status_0")"
log "unhealthy: initial health-call $(snippet "$call_0")"

# Primary deterministic recovery path: install-if-missing + start
run_install_if_needed "$status_0"
run_start_attempt
sleep 2

status_1="$(get_status)"
call_1="$(get_gateway_health_call)"
if is_healthy "$status_1" "$call_1"; then
  log "recovery: gateway healthy after install/start path"
  exit 0
fi

# Fallback: aggressive doctor repair, cooldown gated
now_epoch="$(date +%s)"
last_fix_epoch="$(read_last_fix_epoch)"
since=$(( now_epoch - last_fix_epoch ))

if (( since < COOLDOWN_SEC )); then
  log "unhealthy: install/start failed and doctor cooldown active (${since}s < ${COOLDOWN_SEC}s)"
  log "status after start: $(snippet "$status_1")"
  log "health-call after start: $(snippet "$call_1")"
  exit 0
fi

log "fallback: running 'openclaw doctor --repair --force --non-interactive --yes'"
doctor_out="$(openclaw doctor --repair --force --non-interactive --yes 2>&1 || true)"
log "doctor output: $(snippet "$doctor_out")"
write_last_fix_epoch "$now_epoch"

status_2="$(get_status)"
run_install_if_needed "$status_2"
run_start_attempt
sleep 2

status_3="$(get_status)"
call_3="$(get_gateway_health_call)"
if is_healthy "$status_3" "$call_3"; then
  log "recovery: gateway healthy after doctor/install/start fallback"
  exit 0
fi

log "warning: gateway still unhealthy after all recovery steps"
log "final status: $(snippet "$status_3")"
log "final health-call: $(snippet "$call_3")"
exit 0
