#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib-node-stable-env.sh"

printf "[watchdog] gateway\n"
openclaw gateway status >/tmp/openclaw-watchdog-gateway.txt 2>&1 || {
  echo "WATCHDOG_ALERT: gateway status check failed"
  sed -n '1,40p' /tmp/openclaw-watchdog-gateway.txt || true
  exit 0
}

printf "[watchdog] caffeinate\n"
if ! pgrep -f '/usr/bin/caffeinate -dims' >/dev/null 2>&1; then
  echo "WATCHDOG_ALERT: caffeinate -dims is not running"
fi

printf "[watchdog] channels\n"
# Avoid `openclaw status` here (can invoke privileged launchctl paths on some hosts).
# Reuse gateway status output for channel health signals.
if grep -E 'Telegram .* (DOWN|ERROR|FAIL)|Discord .* (DOWN|ERROR|FAIL)' /tmp/openclaw-watchdog-gateway.txt >/dev/null 2>&1; then
  echo "WATCHDOG_ALERT: one or more channels unhealthy"
  grep -E 'Telegram|Discord' /tmp/openclaw-watchdog-gateway.txt | sed -n '1,6p'
fi

printf "[watchdog] codex-token-refresh-reused\n"
# If the gateway log has seen repeated refresh_token_reused errors in the last
# 10 minutes, the Codex OAuth token loop is stuck — restart the gateway to
# flush the stale in-memory token state.
_gw_log="/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
if [[ -f "$_gw_log" ]]; then
  _cutoff="$(date -v-10M +"%Y-%m-%dT%H:%M" 2>/dev/null || date -d '10 minutes ago' +"%Y-%m-%dT%H:%M" 2>/dev/null || echo "")"
  if [[ -n "$_cutoff" ]]; then
    _reused_count="$(python3 -c "
import sys, json
count = 0
cutoff = sys.argv[1]
for line in open(sys.argv[2]):
    try:
        o = json.loads(line)
        t = o.get('time','')
        if t and t[:16] < cutoff: continue
        if 'refresh_token_reused' in str(o.get('0','')) or 'refresh_token_reused' in str(o.get('1','')):
            count += 1
    except: pass
print(count)
" "$_cutoff" "$_gw_log" 2>/dev/null || echo 0)"
    if (( _reused_count >= 3 )); then
      echo "WATCHDOG_ALERT: Codex OAuth refresh_token_reused x${_reused_count} in last 10min — restarting gateway"
      openclaw gateway restart 2>&1 || true
      sleep 4
    fi
  fi
fi

printf "[watchdog] telegram-lane-timeout\n"
if [[ -x "$(cd "$(dirname "$0")" && pwd)/telegram-lane-watchdog.sh" ]]; then
  "$(cd "$(dirname "$0")" && pwd)/telegram-lane-watchdog.sh" >/tmp/openclaw-watchdog-telegram-lane.txt 2>&1 || true
  if grep -E 'ALERT|RECOVERY' /tmp/openclaw-watchdog-telegram-lane.txt >/dev/null 2>&1; then
    sed -n '1,20p' /tmp/openclaw-watchdog-telegram-lane.txt || true
  fi
fi

printf "[watchdog] worker-timeout\n"
if [[ -x "$(cd "$(dirname "$0")" && pwd)/subagent-stall-watch.sh" ]]; then
  "$(cd "$(dirname "$0")" && pwd)/subagent-stall-watch.sh" >/tmp/openclaw-watchdog-stall.txt 2>&1 || true
  if grep -E 'stalled|terminate-stalled-worker|scan complete' /tmp/openclaw-watchdog-stall.txt >/dev/null 2>&1; then
    sed -n '1,20p' /tmp/openclaw-watchdog-stall.txt || true
  fi
fi

echo "WATCHDOG_OK"
