#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib-node-stable-env.sh"

WORKSPACE="${WORKSPACE:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_DIR="${OUT_DIR:-$WORKSPACE/state/conversations}"
OUT_FILE="${OUT_FILE:-$OUT_DIR/active.json}"
ACTIVE_WINDOW_MS="${ACTIVE_WINDOW_MS:-1800000}"          # 30m
PROACTIVE_WINDOW_MS="${PROACTIVE_WINDOW_MS:-28800000}"   # 8h
MAX_SESSIONS="${MAX_SESSIONS:-100}"

mkdir -p "$OUT_DIR"
RAW="$(openclaw sessions --json)"

python3 - "$OUT_FILE" "$ACTIVE_WINDOW_MS" "$PROACTIVE_WINDOW_MS" "$MAX_SESSIONS" "$RAW" <<'PY'
import json, sys, time

out_file, active_window_ms, proactive_window_ms, max_sessions, raw = sys.argv[1:]
active_window_ms = int(active_window_ms)
proactive_window_ms = int(proactive_window_ms)
max_sessions = int(max_sessions)

def parse_json_blob(text: str):
    text = (text or '').strip()
    start = text.find('{')
    if start == -1:
        start = text.find('[')
    if start == -1:
        raise ValueError('no JSON start token found')
    trimmed = text[start:]

    decoder = json.JSONDecoder()
    obj, _ = decoder.raw_decode(trimmed)
    return obj


all_data = parse_json_blob(raw)
now = int(time.time() * 1000)


def parse_key(key: str):
    p = key.split(':')
    info = {
        'channel': 'unknown',
        'chatId': None,
        'scope': None,
        'isSubagent': ':subagent:' in key,
        'isCron': ':cron:' in key,
        'isRun': ':run:' in key,
        'isMainSession': key.endswith(':main'),
    }
    if len(p) >= 4 and p[2] in ('telegram', 'discord', 'webchat'):
        info['channel'] = p[2]
        info['scope'] = p[3]
        if len(p) >= 5:
            info['chatId'] = p[4]
    return info


def score(s):
    # Higher is better.
    channel_rank = {'telegram': 30, 'discord': 30, 'webchat': 20, 'unknown': 0}
    scope_rank = {'direct': 5, 'dm': 5, 'channel': 3}
    value = 0
    value += channel_rank.get(s.get('channel', 'unknown'), 0)
    value += scope_rank.get((s.get('scope') or '').lower(), 0)
    if s.get('active'):
        value += 40
    if s.get('eligibleForProactive'):
        value += 20
    if s.get('updateEligible'):
        value += 20
    if s.get('isSystemSession'):
        value -= 100
    # More recent gets a small bump.
    updated = s.get('updatedAt') or 0
    value += int(updated / 10_000_000_000)
    return value

if isinstance(all_data, dict):
    source_sessions = all_data.get('sessions', [])
elif isinstance(all_data, list):
    source_sessions = all_data
else:
    source_sessions = []

sessions = []
for item in source_sessions:
    key = item.get('key', '')
    if not key:
        continue
    parsed = parse_key(key)
    if parsed['isSubagent']:
        continue

    updated_at = int(item.get('updatedAt') or 0)
    age_ms = max(0, now - updated_at) if updated_at else 10**18
    active = age_ms <= active_window_ms
    eligible_for_proactive = age_ms <= proactive_window_ms

    is_system_session = parsed['isCron'] or parsed['isRun']
    update_eligible = (
        eligible_for_proactive
        and not is_system_session
        and parsed['channel'] in ('telegram', 'discord', 'webchat')
    )

    session = {
        'key': key,
        'kind': item.get('kind', 'other'),
        'channel': parsed['channel'],
        'scope': parsed['scope'],
        'chatId': parsed['chatId'],
        'sessionId': item.get('sessionId'),
        'updatedAt': updated_at,
        'ageMs': age_ms,
        'active': active,
        'eligibleForProactive': eligible_for_proactive,
        'updateEligible': update_eligible,
        'isSystemSession': is_system_session,
        'isMainSession': parsed['isMainSession'],
    }
    session['routingScore'] = score(session)
    sessions.append(session)

sessions.sort(key=lambda x: (x['routingScore'], x['updatedAt']), reverse=True)
preferred = next((s for s in sessions if s.get('updateEligible')), None)
if preferred is None:
    preferred = next((s for s in sessions if s.get('eligibleForProactive')), None)

payload = {
    'timestampMs': now,
    'activeWindowMs': active_window_ms,
    'proactiveWindowMs': proactive_window_ms,
    'count': len(sessions),
    'counts': {
        'active': sum(1 for s in sessions if s.get('active')),
        'eligibleForProactive': sum(1 for s in sessions if s.get('eligibleForProactive')),
        'updateEligible': sum(1 for s in sessions if s.get('updateEligible')),
    },
    'preferred': preferred,
    'sessions': sessions[:max_sessions],
}

with open(out_file, 'w', encoding='utf-8') as f:
    json.dump(payload, f, indent=2)

print(f"[conversation-refresh] wrote {out_file} (sessions={len(sessions)} updateEligible={payload['counts']['updateEligible']})")
if preferred:
    print(f"[conversation-refresh] preferred={preferred['key']} channel={preferred.get('channel')} chatId={preferred.get('chatId')}")
PY
