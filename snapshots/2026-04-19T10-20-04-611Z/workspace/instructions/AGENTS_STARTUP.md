# Every Session

Source: `docs/context/AGENTS_legacy_2026-03-05.md`

## Every Session

Before doing anything else:

1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. Read `LOW_TRUST_EXECUTION_CONTRACT.md` (execution boundary + trust model)
5. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

Then: load instruction overlays from `instructions/` **on demand only** (most specific module first).
Do not preload all overlays by default.

Don't ask permission. Just do it.

### Voice Reply Discovery (Cross-Channel + Chatterbox)

For any voice generation / voice reply request, use this lookup order so future threads can find it fast:
1. `VOICE_REPLY_SYSTEM.md` (canonical map)
2. `instructions/VOICE_REPLY.md` (runtime protocol)
3. `VOICE_PREFERENCES.md` + `state/voice-preferences.json` (default + per-user voice selection)
4. `skills/telegram-voice-reply/SKILL.md` (skill workflow + script)

