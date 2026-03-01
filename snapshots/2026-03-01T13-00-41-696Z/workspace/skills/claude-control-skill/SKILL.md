---
name: claude-control-skill
description: Control Claude Code CLI interactive sessions reliably using OpenClaw exec/process tools. Use when login/auth flows require pasting callback URLs/tokens, when a CLI must be driven step-by-step (start/read/send/stop), or when browser-based auth must be bridged back into a waiting terminal prompt.
---

# Claude Control Skill

Use this skill for interactive Claude CLI control.

## Core workflow (PTY + process)

1. Start Claude CLI in PTY/background:
```bash
exec(command="claude auth login", pty=true, background=true)
```
Save `sessionId`.

2. Read prompt/output:
```bash
process(action="poll", sessionId="<id>", timeout=120000)
```

3. Send input (preferred over key combos):
```bash
process(action="write", sessionId="<id>", data="<callback-url-or-token>\n")
```

4. Confirm completion:
```bash
exec(command="claude auth status")
```

5. Stop stale/blocked sessions:
```bash
process(action="kill", sessionId="<id>")
```

## Callback-token bridge pattern

When Claude prints an OAuth URL and waits for callback paste:
- Have user complete browser auth.
- Request full callback URL (preferred) from the current auth attempt.
- Paste directly into waiting PTY via `process.write(..."\n")`.
- Do not rely on Ctrl+V in terminal automation.

## Safety rules (mandatory)

- Treat callback URLs/tokens as secrets.
- Do not persist raw secrets in Beads notes, docs, or chat summaries.
- If user posted a token in chat, recommend rotating/re-authing.
- Redact values in any evidence logs.

## Troubleshooting quick checks

- `claude auth status` shows `loggedIn: false`:
  - restart auth flow, ensure using callback from current attempt only.
- Session hangs after login URL:
  - user likely hasn’t completed browser step or callback not pasted.
- CLI flow corrupted by prior run:
  - kill old PTY session and start fresh.

For detailed playbooks, read `references/flows.md`.
