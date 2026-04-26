---
name: browser-use-via-claude-chrome
description: Standard workflow for running Claude Code with Chrome extension browser driving for tricky web navigation/search tasks. Use when browsing tasks need deterministic prompts, safety guardrails, and recovery steps for inactive extension/session issues.
---

# Claude Chrome Extension Browser-Driving Workflow

## Terminology and scope (important)

- This skill is **not** about Claude RC entitlement/feature gating (`claude rc ...`).
- This skill is about Claude CLI driving your **normal desktop Chrome** via `claude --chrome` and the Claude Chrome extension/browser integration.
- Keep true Claude RC references separate, and only use them for RC-specific setup/entitlement troubleshooting.

## Run Claude in Chrome extension browser-driving mode

Use this baseline command for browser tasks:

```bash
claude --dangerously-skip-permissions --chrome -p "<task prompt>" --output-format text
```

Use concise prompts with explicit output shape:
- State the browsing goal.
- State any constraints (time range, source quality, max steps).
- Require concise final output (bullets/table/JSON).

## Preference order and comparison

1. **Primary/default:** this skill (`claude --chrome`) in desktop logged-in Chrome context when safe/applicable.
2. **Fallback:** OpenClaw browser plugin/profile automation when Chrome extension driving is unavailable.

- `--chrome` uses your live desktop Chrome context, which usually provides better continuity with existing tabs, logins, and cookies.
- OpenClaw browser/profile automation runs in a separate/isolated context and is preferred when isolation is safer.

## Prompt examples

Navigation + extraction:

```bash
claude --dangerously-skip-permissions --chrome -p "Open https://www.nps.gov, find current Yosemite park alerts, and return a 3-bullet summary with source URL." --output-format text
```

Search + synthesis:

```bash
claude --dangerously-skip-permissions --chrome -p "Search for penguin habitat facts from reputable sources and return 3 facts with URLs." --output-format text
```

## Safety rules (mandatory)

- Never paste or expose secrets (tokens, passwords, callback URLs) in prompts, logs, or issue comments.
- Redact sensitive values in evidence snippets.
- **Because desktop Chrome sessions may already be live/logged in, explicitly confirm before high-risk or external actions** (posting, purchases, account settings changes, destructive edits).
- Prefer read-only browsing unless the user explicitly requests mutations.

## Troubleshooting extension/session issues

1. Browser driving appears inactive / no browser control:
   - Ensure Chrome extension/browser integration is available, then retry the same prompt.
   - Run a tiny sanity prompt first (e.g., "Reply with CHROME_OK").
2. Session hangs or partial output:
   - Re-run the command with a shorter prompt and stricter output format.
   - Retry once; if still stuck, start a fresh Claude invocation.
3. Auth/session drift:
   - Verify current Claude auth/session state, then restart command.
4. Determinism drift:
   - Keep prompt scope narrow and request fixed output structure.

## Separate feature note: true Claude RC

- Use `claude rc ...` docs/workflows only for true Remote Control entitlement/setup behavior.
- Do not treat RC enablement as a prerequisite for this `--chrome` desktop Chrome extension workflow.
