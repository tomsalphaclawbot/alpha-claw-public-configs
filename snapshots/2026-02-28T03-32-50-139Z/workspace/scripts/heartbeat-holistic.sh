#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

STATE_DIR="state"
RUNS_DIR="$STATE_DIR/heartbeat-runs"
RUN_ID="$(date -u +"%Y%m%dT%H%M%SZ")-$$"
RUN_DIR="$RUNS_DIR/$RUN_ID"
SUMMARY_FILE="$STATE_DIR/heartbeat-runs.jsonl"
LATEST_FILE="$STATE_DIR/heartbeat-latest.json"
mkdir -p "$RUN_DIR"

run_start_epoch="$(date +%s)"
run_start_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

STEP_RESULTS=()

json_escape() {
  python3 - <<'PY' "$1"
import json,sys
print(json.dumps(sys.argv[1]))
PY
}

record_step() {
  local id="$1" name="$2" status="$3" duration_ms="$4" log_rel="$5"
  STEP_RESULTS+=("{\"id\":\"$id\",\"name\":\"$name\",\"status\":\"$status\",\"durationMs\":$duration_ms,\"log\":$(json_escape "$log_rel")}")
}

run_step() {
  local id="$1" name="$2" cmd="$3"
  local log_file="$RUN_DIR/${id}.log"
  local t0 t1 status duration_ms
  t0="$(python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
)"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] STEP $id $name" | tee -a "$RUN_DIR/run.log"
  if bash -lc "$cmd" >"$log_file" 2>&1; then
    status="ok"
  else
    status="error"
  fi
  t1="$(python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
)"
  duration_ms="$((t1-t0))"
  record_step "$id" "$name" "$status" "$duration_ms" "${log_file#$ROOT_DIR/}"
  if [[ "$status" != "ok" ]]; then
    echo "Step $id failed ($name). See $log_file" | tee -a "$RUN_DIR/run.log"
  fi
  return 0
}

run_step "02" "bd_ready" "bd ready --json"
run_step "04" "watchdog" "scripts/openclaw-watchdog.sh"
run_step "07" "discord_openclaw_check" "scripts/discord-openclaw-check.sh"
run_step "08" "conversation_activity_refresh" "scripts/conversation-activity-refresh.sh"
run_step "09a" "git_diff_focus_workspace" "scripts/git-diff-focus.sh --repo workspace --stat"
run_step "09b" "git_diff_focus_config" "scripts/git-diff-focus.sh --repo config --stat"
run_step "10" "git_diff_tasker" "scripts/git-diff-tasker.sh"
run_step "11" "subagent_dispatcher" "scripts/subagent-dispatcher.sh"
run_step "12" "subagent_stall_watch" "scripts/subagent-stall-watch.sh"
run_step "13" "heartbeat_enforce" "scripts/heartbeat-enforce.sh"
run_step "15" "subagent_global_status" "scripts/subagent-global-status.sh"
run_step "15b" "blocker_log_refresh" "scripts/blocker-log-refresh.sh"
run_step "15c" "coherence_audit" "scripts/coherence-audit.sh"
run_step "15d" "evergreen_autostart" "scripts/evergreen-autostart.sh"
run_step "16" "git_autocommit" "scripts/git-autocommit.sh"
run_step "18" "bd_list_open" "bd list --status open --json"

run_end_epoch="$(date +%s)"
run_end_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
run_duration_ms="$(( (run_end_epoch-run_start_epoch)*1000 ))"

steps_json="[$(IFS=,; echo "${STEP_RESULTS[*]}")]"
overall_status="ok"
if echo "$steps_json" | grep -q '"status":"error"'; then
  overall_status="partial"
fi

summary_json="{\"runId\":\"$RUN_ID\",\"startedAt\":\"$run_start_iso\",\"endedAt\":\"$run_end_iso\",\"durationMs\":$run_duration_ms,\"status\":\"$overall_status\",\"runDir\":$(json_escape "${RUN_DIR#$ROOT_DIR/}"),\"steps\":$steps_json}"

echo "$summary_json" >> "$SUMMARY_FILE"
echo "$summary_json" > "$LATEST_FILE"

# Daily memory persistence (local TZ): ensure memory/YYYY-MM-DD.md exists and append heartbeat rollup
MEMORY_DIR="$ROOT_DIR/memory"
LOCAL_DATE="$(TZ=America/Los_Angeles date +%F)"
LOCAL_TIME="$(TZ=America/Los_Angeles date +%H:%M)"
MEMORY_FILE="$MEMORY_DIR/$LOCAL_DATE.md"
mkdir -p "$MEMORY_DIR"
if [[ ! -f "$MEMORY_FILE" ]]; then
  {
    echo "# $LOCAL_DATE"
    echo
  } > "$MEMORY_FILE"
fi
OPEN_COUNT="?"
if [[ -f "$RUN_DIR/18.log" ]]; then
  OPEN_COUNT="$(python3 - <<'PY' "$RUN_DIR/18.log"
import json,sys
p=sys.argv[1]
try:
    data=json.load(open(p))
    print(len(data) if isinstance(data,list) else '?')
except Exception:
    print('?')
PY
)"
fi
if ! grep -q "$RUN_ID" "$MEMORY_FILE" 2>/dev/null; then
  printf -- "- %s PT heartbeat run %s: status=%s, duration=%sms, open_beads=%s.\n" "$LOCAL_TIME" "$RUN_ID" "$overall_status" "$run_duration_ms" "$OPEN_COUNT" >> "$MEMORY_FILE"
fi

# Idle value ledger: require explicit net-new/blocker/action fields per cycle
IDLE_DIR="$ROOT_DIR/state/idle-work"
IDLE_LATEST="$IDLE_DIR/latest.md"
IDLE_LOG_DIR="$IDLE_DIR/logs"
IDLE_LOG_FILE="$IDLE_LOG_DIR/$LOCAL_DATE.md"
mkdir -p "$IDLE_LOG_DIR"

BLOCKERS_CHANGED=0
if [[ -f "$RUN_DIR/15b.log" ]] && grep -Eq 'CHANGED=1|changed=1' "$RUN_DIR/15b.log"; then
  BLOCKERS_CHANGED=1
fi

NET_NEW_OUTPUTS=0
if [[ -f "$RUN_DIR/16.log" ]]; then
  if grep -Eqi 'files changed|create mode|Auto-commit complete|pushed' "$RUN_DIR/16.log" && ! grep -Eqi 'nothing to commit|no changes' "$RUN_DIR/16.log"; then
    NET_NEW_OUTPUTS=1
  fi
fi

OUTCOME_CATEGORY="maintenance"
if [[ "$NET_NEW_OUTPUTS" == "1" ]]; then
  OUTCOME_CATEGORY="net-new-output"
elif [[ "$BLOCKERS_CHANGED" == "1" ]]; then
  OUTCOME_CATEGORY="blocker-movement"
fi
if [[ "$overall_status" != "ok" ]]; then
  OUTCOME_CATEGORY="error-recovery"
fi

NEXT_ACTION="Advance highest-priority open Bead (or move blocker with one concrete unblock step)."

cat > "$IDLE_LATEST" <<EOF
# Idle Work Snapshot
- updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- run_id: $RUN_ID
- net_new_outputs: $NET_NEW_OUTPUTS
- blockers_changed: $BLOCKERS_CHANGED
- outcome_category: $OUTCOME_CATEGORY
- open_beads: $OPEN_COUNT
- next_concrete_action: $NEXT_ACTION
EOF

if ! grep -q "$RUN_ID" "$IDLE_LOG_FILE" 2>/dev/null; then
  {
    [[ -f "$IDLE_LOG_FILE" ]] || echo "# $LOCAL_DATE"
    printf -- "- %s PT run %s | status=%s | net_new_outputs=%s | blockers_changed=%s | outcome=%s | open_beads=%s | next=%s\n" "$LOCAL_TIME" "$RUN_ID" "$overall_status" "$NET_NEW_OUTPUTS" "$BLOCKERS_CHANGED" "$OUTCOME_CATEGORY" "$OPEN_COUNT" "$NEXT_ACTION"
  } >> "$IDLE_LOG_FILE"
fi

echo "$summary_json"
