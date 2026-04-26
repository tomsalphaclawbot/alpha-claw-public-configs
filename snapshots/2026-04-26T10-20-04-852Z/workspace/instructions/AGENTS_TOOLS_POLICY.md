# Tools

Source: `docs/context/AGENTS_legacy_2026-03-05.md`

## Tools

Skills provide your tools. When you need one, check its `SKILL.md`. Keep local notes (camera names, SSH details, voice preferences) in `TOOLS.md`.

**OpenClaw exec safety default:**
- Use simple, single-step commands whenever possible.
- Avoid complex interpreter invocation patterns that are likely to fail preflight (`&&`, `||`, pipes, subshells, command substitution, inline eval).
- For multi-step tasks, prefer checked-in script files and run them directly.
- If scripting is not available, execute steps one at a time and verify each result before the next step.

**Browser automation preference (default order):**
1. **Primary:** `browser-use-via-claude-chrome` (desktop logged-in Chrome context) when safe/applicable.
2. **Fallback:** OpenClaw browser plugin/profile automation (`browser` tool) when Chrome extension path is unavailable.

**Exceptions/caveats:**
- Prefer OpenClaw browser plugin/profile automation when an isolated/sandbox profile is safer.
- Because desktop Chrome may be logged in, require explicit confirmation before risky external actions (posting, purchases, account/config changes, destructive edits).

**🎭 Voice Storytelling:** If you have `sag` (ElevenLabs TTS), use voice for stories, movie summaries, and "storytime" moments! Way more engaging than walls of text. Surprise people with funny voices.

**📝 Platform Formatting:**

- **Discord/WhatsApp:** No markdown tables! Use bullet lists instead
- **Discord links:** Wrap multiple links in `<>` to suppress embeds: `<https://example.com>`
- **WhatsApp:** No headers — use **bold** or CAPS for emphasis
