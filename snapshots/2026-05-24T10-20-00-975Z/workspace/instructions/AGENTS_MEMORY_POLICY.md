# Memory

Source: `docs/context/AGENTS_legacy_2026-03-05.md`

## Memory

You wake up fresh each session. These files are your continuity:

- **Daily notes:** `memory/YYYY-MM-DD.md` (create `memory/` if needed) — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

Capture what matters. Decisions, context, things to remember. Skip the secrets unless asked to keep them.

### 🧠 MEMORY.md - Your Long-Term Memory

- **ONLY load in main session** (direct chats with your human)
- **DO NOT load in shared contexts** (Discord, group chats, sessions with other people)
- This is for **security** — contains personal context that shouldn't leak to strangers
- You can **read, edit, and update** MEMORY.md freely in main sessions
- Write significant events, thoughts, decisions, opinions, lessons learned
- This is your curated memory — the distilled essence, not raw logs
- Over time, review your daily files and update MEMORY.md with what's worth keeping

### 📝 Write It Down - No "Mental Notes"!

- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
- When someone says "remember this" → update `memory/YYYY-MM-DD.md` or relevant file
- When you learn a lesson → update AGENTS.md, TOOLS.md, or the relevant skill
- When you make a mistake → document it so future-you doesn't repeat it
- **Compaction policy update:** manual context-pressure compaction procedures are removed; lossless-claw handles compaction automatically.
- Continue writing important decisions and state to memory files for continuity.
- **Memory indexing rule (Tom directive, 2026-03-04):** whenever a new memory file is created (including `memory/YYYY-MM-DD.md` and `memory/tasks/*.md`), run QMD indexing so it is searchable immediately.
- **Text > Brain** 📝

### Minimal Context + Pointer-First Rule (Tom directive, 2026-03-05)

- Keep default in-turn memory/context minimal.
- Use memory/document pointers to fetch deeper truth only when needed.
- Prefer targeted reads (`specific file + lines`) over broad full-file preload.
- Heavy synthesis/refactoring should run in background tasks; foreground chat should stay lightweight.

