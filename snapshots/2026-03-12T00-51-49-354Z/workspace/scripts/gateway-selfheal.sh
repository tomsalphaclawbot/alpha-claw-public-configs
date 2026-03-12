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
CMD_TIMEOUT_SEC="${CMD_TIMEOUT_SEC:-25}"           # hard process timeout per routine openclaw command
DOCTOR_TIMEOUT_SEC="${DOCTOR_TIMEOUT_SEC:-180}"    # doctor can take longer; avoid false timeout/cooldown lockout
GATEWAY_RPC_TIMEOUT_MS="${GATEWAY_RPC_TIMEOUT_MS:-10000}"
COOLDOWN_SEC="${COOLDOWN_SEC:-900}"                # cooldown for aggressive doctor fallback
MAX_LOCK_AGE_SEC="${MAX_LOCK_AGE_SEC:-900}"        # reclaim lock if holder metadata is stale
FAIL_THRESHOLD="${FAIL_THRESHOLD:-2}"              # require N consecutive unhealthy checks before remediation

mkdir -p "$LOG_DIR" "$(dirname "$STATE_FILE")"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" >> "$LOG_FILE"; }

snippet() {
  echo "$1" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-900
}

# Run a command with a hard timeout (portable; avoids external timeout deps).
run_with_timeout() {
  local timeout_sec="$1"
  shift
  python3 - <<'PY' "$timeout_sec" "$@"
import subprocess
import sys

timeout = int(sys.argv[1])
cmd = sys.argv[2:]
try:
  proc = subprocess.run(
      cmd,
      stdout=subprocess.PIPE,
      stderr=subprocess.STDOUT,
      text=True,
      timeout=timeout,
  )
  sys.stdout.write(proc.stdout or "")
  raise SystemExit(proc.returncode)
except subprocess.TimeoutExpired as exc:
  out = exc.stdout or ""
  if isinstance(out, bytes):
    out = out.decode(errors="replace")
  sys.stdout.write(out)
  sys.stdout.write(f"\n__TIMEOUT__ after {timeout}s\n")
  raise SystemExit(124)
PY
}

run_capture() {
  local __out_var="$1"
  shift
  local out
  local rc
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e
  printf -v "$__out_var" '%s' "$out"
  return "$rc"
}

get_status() {
  run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway status --json --timeout "$GATEWAY_RPC_TIMEOUT_MS" || true
}

# Active request/response probe (beyond process/service checks)
get_gateway_health_call() {
  run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway call health --json --timeout "$GATEWAY_RPC_TIMEOUT_MS" || true
}

is_status_healthy() {
  local s="$1"
  if python3 - <<'PY' "$s"
import json, sys
text = sys.argv[1]
try:
  obj = json.loads(text)
except Exception:
  raise SystemExit(1)
service = obj.get("service") or {}
runtime = service.get("runtime") or {}
rpc = obj.get("rpc") or {}
ok = runtime.get("status") == "running" and rpc.get("ok") is True
raise SystemExit(0 if ok else 1)
PY
  then
    return 0
  fi
  # Backwards-compatible fallback for non-JSON output.
  grep -Eiq "Runtime:[[:space:]]*running" <<<"$s" && grep -Eiq "RPC probe:[[:space:]]*ok" <<<"$s"
}

is_roundtrip_healthy() {
  local s="$1"
  if python3 - <<'PY' "$s"
import json, sys
text = sys.argv[1]
try:
  obj = json.loads(text)
except Exception:
  raise SystemExit(1)
ok = isinstance(obj, dict) and obj.get("ok") is True
raise SystemExit(0 if ok else 1)
PY
  then
    return 0
  fi
  grep -Eq '"ok"[[:space:]]*:[[:space:]]*true' <<<"$s"
}

is_healthy() {
  local status_out="$1"
  local call_out="$2"
  is_status_healthy "$status_out" && is_roundtrip_healthy "$call_out"
}

service_missing() {
  local s="$1"

  if python3 - <<'PY' "$s"
import json, sys
text = sys.argv[1]
try:
  obj = json.loads(text)
except Exception:
  raise SystemExit(1)
service = obj.get("service") or {}
runtime = service.get("runtime") or {}
missing = runtime.get("missingUnit") is True
raise SystemExit(0 if missing else 1)
PY
  then
    return 0
  fi

  grep -Eq "Service not installed|Service unit not found|Could not find service \"ai\.openclaw\.gateway\"|service file not found|bootstrap failed: .*No such file" <<<"$s"
}

read_state_field() {
  local field="$1"
  local default="$2"
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "$default"
    return
  fi
  python3 - <<'PY' "$STATE_FILE" "$field" "$default"
import json,sys
p, field, default = sys.argv[1], sys.argv[2], sys.argv[3]
try:
  d=json.load(open(p))
  v=d.get(field, default)
  print(int(v))
except Exception:
  print(int(default))
PY
}

read_last_fix_epoch() {
  read_state_field "last_fix_epoch" 0
}

read_fail_count() {
  read_state_field "consecutive_failures" 0
}

write_state() {
  local last_fix="$1"
  local fail_count="$2"
  python3 - <<'PY' "$STATE_FILE" "$last_fix" "$fail_count"
import json,sys,os
p=sys.argv[1]
last_fix=int(sys.argv[2])
fail_count=int(sys.argv[3])
os.makedirs(os.path.dirname(p), exist_ok=True)
obj={"last_fix_epoch": last_fix, "consecutive_failures": fail_count}
with open(p,'w') as f:
  json.dump(obj,f)
PY
}

write_last_fix_epoch() {
  local t="$1"
  local fail
  fail="$(read_fail_count)"
  write_state "$t" "$fail"
}

write_fail_count() {
  local fail="$1"
  local last
  last="$(read_last_fix_epoch)"
  write_state "$last" "$fail"
}

run_install_if_needed() {
  local s="$1"
  if service_missing "$s"; then
    log "repair: service missing, running 'openclaw gateway install'"
    local out rc
    if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway install; then
      rc=0
    else
      rc=$?
    fi
    log "install exit=$rc output: $(snippet "$out")"
  fi
}

run_start_attempt() {
  # Prefer non-disruptive start first to avoid transient launchctl unload windows.
  log "repair: running 'openclaw gateway start'"
  local out rc
  if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway start; then
    rc=0
  else
    rc=$?
  fi
  log "start exit=$rc output: $(snippet "$out")"

  # Escalate to restart only if still unhealthy after start path.
  local s c
  s="$(get_status)"
  c="$(get_gateway_health_call)"
  if is_healthy "$s" "$c"; then
    return 0
  fi

  log "repair: start path insufficient, running 'openclaw gateway restart'"
  if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway restart; then
    rc=0
  else
    rc=$?
  fi
  log "restart exit=$rc output: $(snippet "$out")"
}

acquire_lock() {
  local now existing_pid existing_epoch age
  now="$(date +%s)"

  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "$$" >"$LOCK_DIR/pid"
    echo "$now" >"$LOCK_DIR/epoch"
    return 0
  fi

  existing_pid=""
  existing_epoch=""
  [[ -f "$LOCK_DIR/pid" ]] && existing_pid="$(tr -dc '0-9' < "$LOCK_DIR/pid")"
  [[ -f "$LOCK_DIR/epoch" ]] && existing_epoch="$(tr -dc '0-9' < "$LOCK_DIR/epoch")"
  age=0
  if [[ -n "$existing_epoch" ]]; then
    age=$(( now - existing_epoch ))
  fi

  if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
    log "skip: lock held by live pid=$existing_pid age=${age}s"
    return 1
  fi

  if [[ -z "$existing_pid" ]] && (( age > 0 && age < MAX_LOCK_AGE_SEC )); then
    log "skip: lock metadata fresh (${age}s < ${MAX_LOCK_AGE_SEC}s)"
    return 1
  fi

  log "lock: reclaiming stale lock (pid=${existing_pid:-unknown}, age=${age}s)"
  rm -rf "$LOCK_DIR"
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "$$" >"$LOCK_DIR/pid"
    echo "$now" >"$LOCK_DIR/epoch"
    return 0
  fi
  log "skip: failed to acquire lock after stale reclaim attempt"
  return 1
}

# Portable lock with stale lock recovery.
if ! acquire_lock; then
  exit 0
fi
trap 'rm -rf "$LOCK_DIR" >/dev/null 2>&1 || true' EXIT

status_0="$(get_status)"
call_0="$(get_gateway_health_call)"
if is_healthy "$status_0" "$call_0"; then
  if [[ "$(read_fail_count)" != "0" ]]; then
    write_fail_count 0
    log "healthy: gateway recovered naturally; consecutive failure counter reset"
  else
    log "healthy: gateway running + RPC ok + health call ok"
  fi
  exit 0
fi

log "unhealthy: initial status $(snippet "$status_0")"
log "unhealthy: initial health-call $(snippet "$call_0")"

fail_count="$(read_fail_count)"
fail_count=$(( fail_count + 1 ))
write_fail_count "$fail_count"

if (( fail_count < FAIL_THRESHOLD )); then
  log "unhealthy: consecutive_failures=${fail_count}/${FAIL_THRESHOLD}; deferring remediation"
  exit 0
fi

log "unhealthy: threshold reached (consecutive_failures=${fail_count}/${FAIL_THRESHOLD}); starting remediation"

# Primary deterministic recovery path: install-if-missing + start/restart escalation
run_install_if_needed "$status_0"
run_start_attempt
sleep 2

status_1="$(get_status)"
call_1="$(get_gateway_health_call)"
if is_healthy "$status_1" "$call_1"; then
  write_fail_count 0
  log "recovery: gateway healthy after install/start path; consecutive failure counter reset"
  exit 0
fi

# Fallback: aggressive doctor repair, cooldown gated
now_epoch="$(date +%s)"
last_fix_epoch="$(read_last_fix_epoch)"
since=$(( now_epoch - last_fix_epoch ))

if (( since < COOLDOWN_SEC )); then
  log "unhealthy: install/restart failed and doctor cooldown active (${since}s < ${COOLDOWN_SEC}s)"
  log "status after restart: $(snippet "$status_1")"
  log "health-call after restart: $(snippet "$call_1")"
  exit 1
fi

log "fallback: running 'openclaw doctor --repair --non-interactive --yes'"
if run_capture doctor_out run_with_timeout "$DOCTOR_TIMEOUT_SEC" openclaw doctor --repair --non-interactive --yes; then
  doctor_rc=0
else
  doctor_rc=$?
fi
log "doctor exit=$doctor_rc output: $(snippet "$doctor_out")"
if (( doctor_rc == 0 )); then
  write_last_fix_epoch "$now_epoch"
else
  log "fallback: doctor did not complete successfully; cooldown timestamp not updated"
fi

status_2="$(get_status)"
run_install_if_needed "$status_2"
run_start_attempt
sleep 2

status_3="$(get_status)"
call_3="$(get_gateway_health_call)"
if is_healthy "$status_3" "$call_3"; then
  write_fail_count 0
  log "recovery: gateway healthy after doctor/install/restart fallback; consecutive failure counter reset"
  exit 0
fi

log "warning: gateway still unhealthy after all recovery steps"
log "final status: $(snippet "$status_3")"
log "final health-call: $(snippet "$call_3")"
exit 1
