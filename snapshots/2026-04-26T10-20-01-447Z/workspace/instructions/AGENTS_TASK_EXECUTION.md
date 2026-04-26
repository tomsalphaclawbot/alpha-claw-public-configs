# Task Intake & Execution (Markdown System)

## Default policy

For direct instructions from Tom, treat each actionable instruction as a task.

Task system of record: Markdown files under `tasks/`.

- `tasks/INBOX.md`
- `tasks/ACTIVE.md`
- `tasks/BLOCKED.md`
- `tasks/DONE.md`
- `tasks/LOG.md`



## Lifecycle

1. **Intake**
   - Add a new task entry to `tasks/ACTIVE.md` (or `INBOX.md` if queued).
   - Include source metadata (requester/channel/message id when available).

2. **Execute**
   - Do the work.
   - Use single-step command execution by default; avoid chained/inline-eval shell patterns that may fail preflight.
   - For multi-step operations, prefer script files or run each command as a separate validated step.
   - Keep task `updated` + `next_action` current in `tasks/ACTIVE.md`.
   - Append short state changes to `tasks/LOG.md`.

3. **Blocked handling**
   - Move/update entry in `tasks/BLOCKED.md`.
   - Include one specific unblock needed from Tom.

4. **Validation**
   - Capture command/test/log evidence before completion.

5. **Completion**
   - Move task entry to `tasks/DONE.md` with validation evidence.
   - Only then send user-facing completion.

## Quality gate

Never claim completion without validation evidence.

## Sub-agents

Use sub-agents for heavier implementation work when useful.
Main thread stays responsive and handles orchestration/status updates.

Subagents **must** use git worktrees — see "Git Worktrees" section in `AGENTS.md`.

## Legacy note

Markdown task files under tasks/ are the default and required workflow.
