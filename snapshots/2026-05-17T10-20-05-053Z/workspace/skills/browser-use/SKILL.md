---
name: browser-use
description: >
  Agentic web browser automation using the browser-use library with a real Chromium browser.
  Use when a task requires navigating websites, filling forms, clicking elements, extracting
  content from pages, logging in, or performing multi-step web workflows that need real browser
  rendering (JavaScript, SPAs, auth flows). NOT for simple page fetching (use web_fetch or
  lightpanda for that). Best for tasks that require actual interaction — clicking, typing,
  waiting for dynamic content, handling modals/captchas, or multi-step flows.
---

# browser-use Skill

## When to Use

- Multi-step web navigation (login → navigate → extract → submit)
- Sites that require JavaScript rendering or auth
- Form filling and submission
- Clicking buttons, dropdowns, dynamic UI elements
- Extracting data from pages that don't have clean APIs
- Any task where `web_fetch` or `lightpanda` fails due to JS/auth

## NOT for

- Simple page reads → use `web_fetch` or lightpanda
- Browser snapshots/screenshots → use the `browser` tool
- API-accessible data → call the API directly

---

## Setup

- **Venv:** `/Users/openclaw/.openclaw/workspace/.venvs/browser-use/`
- **Python:** `/Users/openclaw/.openclaw/workspace/.venvs/browser-use/bin/python`
- **Playwright Chromium:** installed (headless)
- **Runner script:** `skills/browser-use/scripts/run_task.py`
- **API key:** auto-retrieved from `~/.openclaw/agents/main/agent/auth-profiles.json` (`anthropic:manual.token`) — no env var needed

---

## Running a Task

Use the runner script. It takes a single positional task string and runs it with Claude claude-sonnet-4-6 as the driving LLM.

```bash
/Users/openclaw/.openclaw/workspace/.venvs/browser-use/bin/python \
  /Users/openclaw/.openclaw/workspace/skills/browser-use/scripts/run_task.py \
  "Go to example.com and return the page title"
```

### Options

```
--model MODEL        Anthropic model to use (default: claude-haiku-[REDACTED_PHONE])
--max-steps N        Max agent steps (default: 20)
--headless / --no-headless   Run Chromium headless (default: headless)
--output-file PATH   Write final result JSON to a file
```

### Model notes

- `claude-haiku-[REDACTED_PHONE]` — default, fast, confirmed working ✅
- `claude-sonnet-4-6` / `claude-opus-4-6` — these are OpenClaw aliases that require extended-thinking beta header; **do not use with browser-use directly**
- For sonnet-tier: use dated ID `claude-sonnet-[REDACTED_PHONE]` (may have access issues — test first)

### Full example

```bash
/Users/openclaw/.openclaw/workspace/.venvs/browser-use/bin/python \
  /Users/openclaw/.openclaw/workspace/skills/browser-use/scripts/run_task.py \
  --max-steps 30 \
  "Go to news.ycombinator.com, find the top 5 story titles and their point counts, return as JSON"
```

---

## Output Format

The script prints progress to stderr and writes final JSON to stdout:

```json
{
  "success": true,
  "result": "...",
  "steps": 7,
  "error": null
}
```

---

## Spawning via exec

For long-running tasks, use exec with background=true and poll:

```python
exec(command="ANTHROPIC_API_KEY=[REDACTED_SECRET]'task here'", yieldMs=60000)
```

---

## Key Capabilities

browser-use drives a real Chromium instance via Playwright. The agent loop:
1. Takes a screenshot
2. Identifies interactive elements via DOM + vision
3. Decides next action (click, type, scroll, extract, done)
4. Executes action
5. Repeats until task is done or max_steps reached

Supported actions: `go_to_url`, `click_element`, `input_text`, `scroll`, `extract_content`,
`open_tab`, `close_tab`, `switch_tab`, `go_back`, `wait`, `done`.

---

## Notes

- Headless by default; use `--no-headless` to see the browser window (useful for debugging)
- The Anthropic API key must be present in env — it's available in the OpenClaw gateway environment automatically
- For sites needing login, pass credentials in the task description or use a pre-seeded browser profile
- Rate limits: each step = 1 LLM call; complex tasks can use 10-30 calls — use sparingly
- If a task fails mid-way, check stderr output for the last action taken
- **Verified working:** `claude-haiku-[REDACTED_PHONE]` on example.com in 2 steps (Mar 21 2026)
