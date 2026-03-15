# HEARTBEAT Runbook (Markdown Task System)

Use this only when deep heartbeat policy is needed.

## Per holistic heartbeat run

1. Run `scripts/heartbeat-holistic.sh`.
2. Review outputs:
   - `state/heartbeat-runs.jsonl`
   - `state/heartbeat-latest.json`
   - `state/heartbeat-runs/<run-id>/`
3. Triage task files (Markdown system):
   - `tasks/ACTIVE.md`
   - `tasks/BLOCKED.md`
   - `tasks/INBOX.md`
4. If a task is stale or blocked, update `tasks/BLOCKED.md` with one precise unblock need.
5. If a task completes, move it to `tasks/DONE.md` with validation evidence.
6. Append important transitions to `tasks/LOG.md`.
7. Keep proactive outreach low-noise:
   - message only for completion, blocker requiring Tom, or important reliability/security issue.

## Alerting rule

If nothing needs attention, reply exactly `HEARTBEAT_OK`.

## Beads status

Beads is not a required dependency for heartbeat operations in the default workflow.
