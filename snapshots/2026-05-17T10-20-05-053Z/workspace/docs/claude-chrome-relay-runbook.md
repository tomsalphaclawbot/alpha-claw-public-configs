# Claude ↔ Chrome Relay Operator Runbook

## Purpose
Keep a **persistent Claude session** alive in tmux so the main thread can iteratively drive browser tasks (send/tail loop), instead of spawning one-off runs.

## Session target
- Project path: `/Users/openclaw`
- Relay script: `skills/claude-relay/scripts/relay.sh`
- Deterministic session name: `cc_openclaw`

## Operator contract (main thread)
1. **Ensure session is running/reused**
   - `skills/claude-relay/scripts/relay.sh start /Users/openclaw`
2. **Send next instruction into same ongoing Claude conversation**
   - `skills/claude-relay/scripts/relay.sh send /Users/openclaw "<instruction>"`
3. **Read Claude output / current prompt state**
   - `skills/claude-relay/scripts/relay.sh tail /Users/openclaw 120`
4. **Check active relay sessions**
   - `skills/claude-relay/scripts/relay.sh status`
5. **Stop session only when explicitly requested**
   - `skills/claude-relay/scripts/relay.sh stop /Users/openclaw`

## Response flow
- `send` auto-waits and tails recent output.
- If Claude is awaiting a permission dialog, operator may need to advance it in tmux, then tail again.
- Main thread should treat each `send` + `tail` as one interaction turn and continue refining prompts in the same session.

## Safety
- Use read-only prompts for browsing validation unless write actions are explicitly approved.
- Do not paste secrets or tokens into relay prompts/output.
