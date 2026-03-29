# Config Gap Analysis (Backup vs Current)

Date: [REDACTED_PHONE]:19 PST

## Scope Compared

- Workspace policy backups:
  - `docs/context/AGENTS_legacy_2026-03-05.md`
  - `docs/context/HEARTBEAT_legacy_2026-03-05.md`
- Current policy files:
  - `AGENTS.md`
  - `instructions/AGENTS_*.md`
  - `HEARTBEAT.md`
  - `instructions/HEARTBEAT_RUNBOOK.md`
- Runtime config backups:
  - `~/.openclaw/openclaw.json.bak*`
  - `~/.openclaw/openclaw.json.smoke.bak`
  - current `~/.openclaw/openclaw.json`

---

## Findings

### 1) AGENTS baseline sections

**Status: restored/present.**

Current `AGENTS.md` now includes baseline sections expected from upstream template plus compaction-safe sections:
- `Session Startup`
- `Red Lines`
- `First Run`
- `Every Session`
- `Memory`
- `Safety`
- `External vs Internal`
- `Group Chats`
- `Tools`
- `💓 Heartbeats - Be Proactive!`
- `Make It Yours`

So the key “don’t over-compress into no baseline guidance” risk is addressed.

### 2) Legacy policy content coverage

**Status: mostly preserved via modular files.**

Legacy AGENTS content was moved into `instructions/AGENTS_*.md`; the heavy operational rules now live there instead of the root file.

Important directives (task discipline, claim metadata, validation evidence, context-pressure/compression rules) are present in modules, especially:
- `instructions/AGENTS_TASK_EXECUTION.md`
- `instructions/AGENTS_MEMORY_POLICY.md`
- `instructions/AGENTS_HEARTBEAT_POLICY.md`

### 3) HEARTBEAT content

**Status: preserved.**

- `HEARTBEAT.md` is now slim by design.
- Full prior heartbeat policy is preserved in `instructions/HEARTBEAT_RUNBOOK.md` (line-count parity with legacy backup).

### 4) `openclaw.json` gaps vs backups

#### Likely meaningful missing items

1. **`skills.entries.openai-whisper-api` missing in current**
   - Present across `.bak` backups
   - Absent in current config
   - Impact: removes API transcription fallback path (local MLX path still exists).

2. **`gateway.nodes.denyCommands` hardening list absent in current**
   - Present in `openclaw.json.smoke.bak` as:
     - `camera.snap`, `camera.clip`, `screen.record`, `calendar.add`, `contacts.add`, `reminders.add`
   - Current is empty array (`[]`)
   - Impact: less restrictive node command safety posture.

#### Intentional removals (not regression)

1. **Google/Gemini config/profile/plugin entries absent in current**
   - Seen in smoke backup, absent now.
   - Matches documented runtime lock policy in `MEMORY.md` and `TOOLS.md`.

2. **Thinking default changed medium -> high**
   - Current `agents.defaults.thinkingDefault = high`
   - This was explicitly requested in-thread.

---

## Recommended Next Steps

1. Decide if `openai-whisper-api` should be restored as fallback (keep local MLX as primary).
2. Decide if `gateway.nodes.denyCommands` should be reintroduced for safety hardening.
3. Keep current modular AGENTS structure, but treat `AGENTS.md` baseline sections as immutable minimum to prevent future over-compression.
