# HEARTBEAT.md (Slim)

Purpose: keep heartbeat prompt lightweight and deterministic.

## Current tier
- 30-minute holistic only.

## Single-command default
Run:
- `scripts/heartbeat-holistic.sh`

Artifacts:
- `state/heartbeat-runs.jsonl`
- `state/heartbeat-latest.json`
- `state/heartbeat-runs/<run-id>/`

## Playground / evergreen creative work
After systems checks, if nothing is urgent:
- Check `tasks/playground-backlog.md` for the next open item.
- Spend remaining idle cycles on one concrete playground deliverable.
- Include at least one **challenge rep** per cycle: pick a harder variant, run a small experiment, or force a critique/rewrite pass that stretches reasoning quality.
- Commit and deploy any playground output (essays, demos, page updates).
- This is real work, not optional — the playground is a standing creative lane.
- Operating intent: sharpen the iron, not just ship output.
- **Autonomous blog cadence cap:** publish at most **one new blog article per day** unless Tom explicitly asks for more.
- **Blog topic grounding rule:** prefer topics sourced from recent memory/logs/learnings (incidents, shipped changes, operational lessons). If no grounded topic exists, do a non-blog playground deliverable instead of writing random philosophy.
- For blog/essay challenge reps, use `docs/playbooks/blog-writing-fast-path.md` before deep-diving into longer methodology docs.

## Escalation rules
Proactively message Tom only when:
1. task complete,
2. blocker needs Tom,
3. important reliability/security issue,
4. time-sensitive inbox/calendar item.

If nothing needs attention, reply exactly:
- `HEARTBEAT_OK`

## Extended runbook
For full policy/details, load on demand:
- `instructions/HEARTBEAT_RUNBOOK.md`

<!-- heartbeat-slim-v1 -->
