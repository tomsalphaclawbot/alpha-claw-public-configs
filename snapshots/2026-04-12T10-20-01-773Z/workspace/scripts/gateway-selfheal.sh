#!/usr/bin/env bash
set -euo pipefail

# Gateway self-heal script — safe/idempotent, runs from crontab or manually.
#
# Health criteria:
# - service status reports running + RPC probe ok  (is_status_healthy)
# - openclaw gateway call health returns {"ok":true} (is_roundtrip_healthy)
#
# Key design principles:
# - NEVER restart a gateway whose process is alive but whose health-call fails
#   transiently (WS timeout, closed-before-connect).  These are caused by
#   internal channel issues or slow ACP reconcile — restarting can't help.
# - All JSON parsers tolerate [plugins] log noise prefixed before the JSON.
# - Post-restart grace period lets the gateway fully initialize before re-check.
# - Fail counter resets on ANY exit path to prevent stale counters from
#   bypassing FAIL_THRESHOLD on subsequent runs.
# - Log file is rotated to prevent unbounded growth.

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

LOG_DIR="$HOME/.openclaw/logs"
LOG_FILE="$LOG_DIR/gateway-selfheal.log"
LOG_MAX_BYTES="${LOG_MAX_BYTES:-2097152}"           # rotate at 2 MB
LOCK_DIR="/tmp/openclaw-gateway-selfheal.lock"
STATE_FILE="$HOME/.openclaw/state/gateway-selfheal-state.json"
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
KNOWN_GOOD_CONFIG="$HOME/.openclaw/state/openclaw.json.last-good"
CMD_TIMEOUT_SEC="${CMD_TIMEOUT_SEC:-25}"             # hard process timeout per routine openclaw command
DOCTOR_TIMEOUT_SEC="${DOCTOR_TIMEOUT_SEC:-180}"      # doctor can take longer
GATEWAY_RPC_TIMEOUT_MS="${GATEWAY_RPC_TIMEOUT_MS:-10000}"
COOLDOWN_SEC="${COOLDOWN_SEC:-900}"                  # cooldown for aggressive doctor fallback
MAX_LOCK_AGE_SEC="${MAX_LOCK_AGE_SEC:-900}"          # reclaim lock if holder metadata is stale
FAIL_THRESHOLD="${FAIL_THRESHOLD:-2}"                # require N consecutive unhealthy checks before remediation
POST_RESTART_GRACE_SEC="${POST_RESTART_GRACE_SEC:-15}" # wait for gateway to fully initialize after restart

mkdir -p "$LOG_DIR" "$(dirname "$STATE_FILE")"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" >> "$LOG_FILE"; }

snippet() {
  echo "$1" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-900
}

save_known_good_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi
  if [[ -f "$KNOWN_GOOD_CONFIG" ]] && cmp -s "$CONFIG_FILE" "$KNOWN_GOOD_CONFIG"; then
    return 0
  fi
  cp "$CONFIG_FILE" "$KNOWN_GOOD_CONFIG"
  chmod 600 "$KNOWN_GOOD_CONFIG" 2>/dev/null || true
  log "config-guard: updated known-good snapshot at $KNOWN_GOOD_CONFIG"
}

restore_known_good_config() {
  if [[ ! -f "$KNOWN_GOOD_CONFIG" ]]; then
    return 1
  fi
  cp "$KNOWN_GOOD_CONFIG" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE" 2>/dev/null || true
  log "config-guard: restored config from known-good snapshot"
}

validate_config() {
  local out json_str
  local rc
  if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw config validate --json; then
    rc=0
  else
    rc=$?
  fi

  # Some environments occasionally return empty output via the timeout wrapper.
  # Retry once with a direct invocation before declaring failure.
  if (( rc != 0 )) || [[ -z "${out//[[:space:]]/}" ]]; then
    local out2 rc2
    if run_capture out2 openclaw config validate --json; then
      rc2=0
    else
      rc2=$?
    fi
    if (( rc2 == 0 )) && [[ -n "${out2//[[:space:]]/}" ]]; then
      out="$out2"
      rc=0
    else
      log "config-guard: validate command failed rc=$rc output=$(snippet "$out") retry_rc=$rc2 retry_output=$(snippet "$out2")"
      return 1
    fi
  fi
  if ! json_str="$(extract_json "$out")"; then
    log "config-guard: validate returned non-json output=$(snippet "$out")"
    return 1
  fi
  if python3 - <<'PY' "$json_str"
import json, sys
obj = json.loads(sys.argv[1])
raise SystemExit(0 if obj.get("valid") is True else 1)
PY
  then
    return 0
  fi
  log "config-guard: config invalid output=$(snippet "$out")"
  return 1
}

preflight_config_guard() {
  # If current config is valid, keep refreshing known-good snapshot.
  if validate_config; then
    save_known_good_config || true
    return 0
  fi

  # Invalid config: auto-rollback to last known good if available.
  if restore_known_good_config; then
    if validate_config; then
      log "config-guard: rollback succeeded; config valid after restore"
      return 0
    fi
    log "config-guard: rollback attempted but config still invalid"
    return 1
  fi

  log "config-guard: invalid config and no known-good snapshot available"
  return 1
}

# ── Log rotation ───────────────────────────────────────────────────────
rotate_log() {
  if [[ -f "$LOG_FILE" ]]; then
    local size
    size="$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)"
    if (( size > LOG_MAX_BYTES )); then
      mv "$LOG_FILE" "$LOG_FILE.1"
      log "log rotated (previous size: ${size} bytes)"
    fi
  fi
}
rotate_log

# ── Shared JSON extraction helper ──────────────────────────────────────
# All openclaw --json commands may prefix log noise like "[plugins] ..." before
# the actual JSON object.  This helper finds the first '{' and parses from there.
# Returns the parsed dict on stdout as a compact JSON string, or exits 1.
extract_json() {
  python3 - <<'PY' "$1"
import json, sys, re
text = sys.argv[1]
m = re.search(r'\{', text)
if not m:
  raise SystemExit(1)
try:
  # raw_decode tolerates trailing content after the JSON object.
  decoder = json.JSONDecoder()
  obj, _ = decoder.raw_decode(text, m.start())
  print(json.dumps(obj, separators=(',', ':')))
except Exception:
  raise SystemExit(1)
PY
}

# ── Timeout + capture helpers ──────────────────────────────────────────
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

get_gateway_health_call() {
  run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway call health --json --timeout "$GATEWAY_RPC_TIMEOUT_MS" || true
}

# ── Health-check predicates ────────────────────────────────────────────
# Each predicate tries JSON extraction first, then falls back to grep for
# backwards compatibility with non-JSON output formats.

is_status_healthy() {
  local s="$1"
  local json_str
  if json_str="$(extract_json "$s")"; then
    python3 - <<'PY' "$json_str"
import json, sys
obj = json.loads(sys.argv[1])
service = obj.get("service") or {}
runtime = service.get("runtime") or {}
rpc = obj.get("rpc") or {}
ok = runtime.get("status") == "running" and rpc.get("ok") is True
raise SystemExit(0 if ok else 1)
PY
    return $?
  fi
  # Backwards-compatible fallback for non-JSON output.
  grep -Eiq "Runtime:[[:space:]]*running" <<<"$s" && grep -Eiq "RPC probe:[[:space:]]*ok" <<<"$s"
}

is_roundtrip_healthy() {
  local s="$1"
  local json_str
  if json_str="$(extract_json "$s")"; then
    python3 - <<'PY' "$json_str"
import json, sys
obj = json.loads(sys.argv[1])
ok = isinstance(obj, dict) and obj.get("ok") is True
raise SystemExit(0 if ok else 1)
PY
    return $?
  fi
  grep -Eq '"ok"[[:space:]]*:[[:space:]]*true' <<<"$s"
}

is_healthy() {
  local status_out="$1"
  local call_out="$2"
  is_status_healthy "$status_out" && is_roundtrip_healthy "$call_out"
}

# Check if the gateway process is running even though the health call failed.
is_process_running() {
  local s="$1"
  local json_str
  if json_str="$(extract_json "$s")"; then
    python3 - <<'PY' "$json_str"
import json, sys
obj = json.loads(sys.argv[1])
service = obj.get("service") or {}
runtime = service.get("runtime") or {}
ok = runtime.get("status") == "running" and runtime.get("pid") is not None
raise SystemExit(0 if ok else 1)
PY
    return $?
  fi
  # No JSON available — can't confirm process state.
  return 1
}

# Detect if the health-call failure looks like a transient WS timeout/close
# rather than a dead gateway.
is_transient_ws_failure() {
  local call_out="$1"
  grep -Eiq "(handshake timeout|gateway closed \(1000\)|closed before connect|connect challenge timeout|ECONNREFUSED|ECONNRESET|__TIMEOUT__)" <<<"$call_out"
}

service_missing() {
  local s="$1"
  local json_str
  if json_str="$(extract_json "$s")"; then
    python3 - <<'PY' "$json_str"
import json, sys
obj = json.loads(sys.argv[1])
service = obj.get("service") or {}
runtime = service.get("runtime") or {}
missing = runtime.get("missingUnit") is True
raise SystemExit(0 if missing else 1)
PY
    return $?
  fi
  grep -Eq "Service not installed|Service unit not found|Could not find service \"ai\.openclaw\.gateway\"|service file not found|bootstrap failed: .*No such file" <<<"$s"
}

# ── Persistent state (consecutive failures + doctor cooldown) ──────────
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

read_last_fix_epoch() { read_state_field "last_fix_epoch" 0; }
read_fail_count()     { read_state_field "consecutive_failures" 0; }

write_state() {
  local last_fix="$1"
  local fail_count="$2"
  python3 - <<'PY' "$STATE_FILE" "$last_fix" "$fail_count"
import json,sys,os
p=sys.argv[1]
last_fix=int(sys.argv[2])
fail_count=int(sys.argv[3])
os.makedirs(os.path.dirname(p), exist_ok=True)
tmp = p + ".tmp"
with open(tmp,'w') as f:
  json.dump({"last_fix_epoch": last_fix, "consecutive_failures": fail_count}, f)
os.replace(tmp, p)
PY
}

write_last_fix_epoch() {
  write_state "$1" "$(read_fail_count)"
}

write_fail_count() {
  write_state "$(read_last_fix_epoch)" "$1"
}

# ── Repair actions ─────────────────────────────────────────────────────
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
  log "repair: running 'openclaw gateway start'"
  local out rc
  if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway start; then
    rc=0
  else
    rc=$?
  fi
  log "start exit=$rc output: $(snippet "$out")"

  # Give the gateway time to bind port, start channels, run ACP reconcile.
  log "repair: waiting ${POST_RESTART_GRACE_SEC}s for gateway to initialize"
  sleep "$POST_RESTART_GRACE_SEC"

  # Check if start was sufficient.
  local s c
  s="$(get_status)"
  c="$(get_gateway_health_call)"
  if is_healthy "$s" "$c"; then
    return 0
  fi

  # If the process is running but the health-call failure looks transient
  # (WS timeout/close), do NOT restart — restarting can't fix this and would
  # cause a restart loop every cron cycle.  Trust the gateway to stabilize.
  if is_process_running "$s" && is_transient_ws_failure "$c"; then
    log "repair: gateway process running after start; health-call is transient WS — not escalating to restart"
    return 0
  fi

  # Escalate to restart only if still unhealthy.
  log "repair: start path insufficient, running 'openclaw gateway restart'"
  if run_capture out run_with_timeout "$CMD_TIMEOUT_SEC" openclaw gateway restart; then
    rc=0
  else
    rc=$?
  fi
  log "restart exit=$rc output: $(snippet "$out")"

  # Grace period after restart too.
  log "repair: waiting ${POST_RESTART_GRACE_SEC}s for gateway to initialize"
  sleep "$POST_RESTART_GRACE_SEC"
}

# ── Locking ────────────────────────────────────────────────────────────
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

# ── Main ───────────────────────────────────────────────────────────────
if ! acquire_lock; then
  exit 0
fi
trap 'rm -rf "$LOCK_DIR" >/dev/null 2>&1 || true' EXIT

if ! preflight_config_guard; then
  log "config-guard: preflight failed; attempting fallback doctor repair"
  if run_capture guard_doctor_out run_with_timeout "$DOCTOR_TIMEOUT_SEC" openclaw doctor --fix; then
    guard_doctor_rc=0
  else
    guard_doctor_rc=$?
  fi
  log "config-guard: doctor --fix exit=$guard_doctor_rc output=$(snippet "$guard_doctor_out")"
  if ! validate_config; then
    log "config-guard: config still invalid after doctor --fix; aborting selfheal cycle"
    exit 1
  fi
  save_known_good_config || true
fi

status_0="$(get_status)"
call_0="$(get_gateway_health_call)"

# ── Happy path: fully healthy ──────────────────────────────────────────
if is_healthy "$status_0" "$call_0"; then
  if [[ "$(read_fail_count)" != "0" ]]; then
    write_fail_count 0
    log "healthy: gateway recovered naturally; consecutive failure counter reset"
  else
    log "healthy: gateway running + RPC ok + health call ok"
  fi
  exit 0
fi

# ── Process alive but health-call flaky ────────────────────────────────
# If the gateway process is running and the health-call failure is a transient
# WS issue, do NOT restart.  Restarting cannot fix bad channel credentials,
# slow ACP reconcile, or event-loop congestion.  Just log and exit.
if is_process_running "$status_0" && is_transient_ws_failure "$call_0"; then
  log "degraded: gateway process running (pid alive) but health-call failed (transient WS); NOT restarting"
  log "degraded: health-call snippet: $(snippet "$call_0")"
  # Don't inflate the fail counter — this isn't a real failure.
  exit 0
fi

# ── Process alive, health-call returned valid JSON but ok!=true ────────
# The gateway responded but reported itself unhealthy.  This is also not
# something a restart can fix — the gateway knows its own state better than we
# do.  Log it but don't restart.
if is_process_running "$status_0"; then
  log "degraded: gateway process running but health check not ok; NOT restarting"
  log "degraded: status snippet: $(snippet "$status_0")"
  log "degraded: health-call snippet: $(snippet "$call_0")"
  exit 0
fi

# ── Process is NOT running — actual outage, proceed with remediation ───
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

# Primary deterministic recovery: install-if-missing + start/restart escalation
run_install_if_needed "$status_0"
run_start_attempt

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
  # Reset fail counter so we don't skip FAIL_THRESHOLD on next run.
  write_fail_count 0
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
# Reset fail counter — we've done everything we can this cycle.
write_fail_count 0
exit 1
