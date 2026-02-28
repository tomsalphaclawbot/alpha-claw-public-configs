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
