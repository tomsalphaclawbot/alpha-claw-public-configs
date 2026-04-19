# Markdown Task Files Workflow

Task tracking default is Markdown files in `tasks/`.

## Files

- `tasks/INBOX.md` — not started
- `tasks/ACTIVE.md` — currently in progress
- `tasks/BLOCKED.md` — waiting on Tom/external dependency
- `tasks/DONE.md` — completed items with validation evidence
- `tasks/LOG.md` — short running changelog of task state transitions

## Required entry format

Each task entry should include:
- `id` (short stable id, e.g. `task-[REDACTED_PHONE]`)
- `title`
- `source` (who/where request came from)
- `status`
- `created`
- `updated`
- `next_action`
- `evidence` (commands/logs/tests when applicable)

## Rules

1. New actionable request -> add task to `ACTIVE.md` (or `INBOX.md` if queued).
2. If blocked -> move to `BLOCKED.md` with one clear unblock question.
3. Before saying "done" to user -> task must be in `DONE.md` with validation evidence.
4. Keep `tasks/LOG.md` append-only for transition traceability.
5. Keep entries concise; link to detailed artifacts instead of pasting huge logs.


