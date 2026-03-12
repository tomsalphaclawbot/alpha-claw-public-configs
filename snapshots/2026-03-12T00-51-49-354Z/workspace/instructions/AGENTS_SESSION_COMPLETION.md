# Landing the Plane (Session Completion)

Before ending a work session:

1. Run quality checks relevant to the changes (tests/lint/build/verification).
2. Reconcile task files:
   - move completed tasks to `tasks/DONE.md` with evidence
   - update `tasks/BLOCKED.md` for blockers
   - keep `tasks/ACTIVE.md` accurate
3. Commit and push all intended changes.
4. Confirm repo status is clean and up to date with remote.
5. Leave a concise handoff note in `tasks/LOG.md` when needed.

## Critical rules

- Do not claim completion without validation evidence.
- Do not leave task state ambiguous across task files.
- Beads sync is not required in the default workflow.
