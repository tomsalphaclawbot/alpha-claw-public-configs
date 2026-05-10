# HEARTBEAT.md

## Heartbeat tier (current)

- **30-minute holistic tier only**: full operational sweep (`heartbeat:30m-holistic`).
- 1-minute/5-minute heartbeat lanes are disabled until Tom explicitly re-enables them after stability.

## Current schedulers
- OpenClaw cron:
  - `heartbeat:30m-holistic`
- User crontab:
  - `*/2 * * * * scripts/gateway-selfheal.sh` (always-on safe gateway self-heal lane)
  - `0 0 * * * scripts/daily-full-sync.sh`

(Any 1m/5m heartbeat-style schedules remain disabled until explicit re-enable.)

Ingress policy note: Cloudflare tunnels are host-level processes on this Mac, not per-project docker-compose services.

On each 30-minute scheduled heartbeat:

1. Read `EMAIL_AUTOMATION.md`.
2. **Preferred execution path (auditable):** run `scripts/heartbeat-holistic.sh` once. It executes the core checklist steps and writes structured logs to:
   - `state/heartbeat-runs.jsonl` (one summary per run)
   - `state/heartbeat-latest.json` (latest run snapshot)
   - `state/heartbeat-runs/<run-id>/*.log` (per-step raw logs)
   - `memory/YYYY-MM-DD.md` daily rollup lines (auto-created if missing)
3. Triage queue with Beads-only strategy:
   - Beads operational queue: `bd ready --json` (oldest-first inside priority bands)
   - identify highest-impact unblocked task (respecting blocker + priority order)
3. Run stale-task recovery checks:
   - if an active worker/task has no progress for >30 minutes, treat as failed
   - inspect recent gateway logs and record findings in Beads task comments
   - reclaim and restart under `main-agent`
4. Run `scripts/openclaw-watchdog.sh` (gateway/channels/caffeinate health check + Telegram lane-timeout watchdog with cooldown-gated auto-remediation).
5. Run `scripts/openclaw-security-gate.sh` (deep security audit gate; writes `state/security/audit-latest.json` and fails on warn/critical).
6. Run `scripts/heartbeat-slo-report.sh` (24h reliability rollup to `state/reports/heartbeat-slo-latest.json`).
6.1 Run `scripts/redteam-monthly-check.sh` (ensures monthly red-team checklist artifact in `state/reports/redteam/`).
6.2 Run `scripts/financial-controls-report.sh` (daily finance guardrail summary to `state/reports/finance-latest.json`).
7. Run `scripts/zoho-mail-healthcheck.sh` (Zoho IMAP login + unseen count) and `scripts/zoho-mail-manage-inbox.sh` (read-only unseen summary for triage).
8. If Zoho inbox is unavailable, log blocker status and continue non-email operations.
9. **Google hard lock:** do not run any `gog`/Gmail/Google login/API actions. Treat Google account as disabled until Tom explicitly re-enables it.
10. Run `scripts/discord-openclaw-check.sh` (checks new posts in Discord `Voice Controller` → `#openclaw`, channel id `[REDACTED_PHONE]`).
8. Run `scripts/conversation-activity-refresh.sh` (refresh active conversation registry + preferred proactive thread).
8.1 Drain async update queue (`state/conversations/pending-updates.jsonl`) to the preferred active thread when `scripts/proactive-notify-guard.sh` permits.
9. Run focused diff views before any sync triage:
   - `scripts/git-diff-focus.sh --repo workspace --stat`
   - `scripts/git-diff-focus.sh --repo config --stat`
   (token-efficient review only; commits still include all files)
10. Run `scripts/git-diff-tasker.sh` (detect meaningful repo diffs for visibility; no Bead auto-creation).
11. Run `scripts/subagent-dispatcher.sh` (queue newly opened actionable Beads tasks for sub-agent kickoff).
12. Run `scripts/subagent-stall-watch.sh` (detect stalled sub-agent workers and queue deterministic `prod-worker` actions with required Beads comment cadence).
13. Run `scripts/heartbeat-enforce.sh` to consume stalled-worker prod queue, inject steering messages into stale worker sessions, and log each prod outcome to `state/subagent-prod-actions.jsonl` (deduped by `state/subagent-prod-cache.json`).
14. Enforce worker-timeout rule: if a worker has been on a single task for >30 minutes, presume stall unless fresh progress evidence exists; inspect logs, record findings in Beads, then **terminate/restart** or apply `blocked` label + blocker reason.
15. Treat stale in-progress validation/finalization as high-priority work: if task status appears in-progress but validation/closure state is stale, prioritize finishing validation + status reconciliation before new lower-priority work.
16. Run `scripts/subagent-global-status.sh` (refresh canonical global worker state in `state/subagents/*`).
16.1 Run `scripts/evergreen-autostart.sh` to auto-schedule work across a worker pool.
   - Parallel policy: fill available slots up to pool target (`MAX_PARALLEL_WORKERS`) with unblocked `source:tom-request` tasks first, then `source:evergreen` tasks.
   - It auto-labels stale `in_progress` tasks as `blocked` after timeout, so stale ownership does not silently consume capacity forever.
17. **Mandatory orphan-prevention audit:** for every Bead in `in_progress`, verify there is an active worker/session claim comment (`worker_agent`, `worker_session`, `worker_mode`, `log_ref`, `last_heartbeat_at`).
   - If claim metadata is missing: add blocker/update immediately (cannot remain validly in-progress).
   - If claim exists: inspect that worker session transcript/log (Dashboard session or `sessions_history`) and append a Beads comment with log-check evidence + current heartbeat timestamp.
18. Run `scripts/git-autocommit.sh` (stage, commit, and push any workspace changes to GitHub).
19. For email management:
   - if mode is `review-only`: suggest concrete actions but do not modify mailbox.
   - if mode is `manage`: perform only actions explicitly allowed in `EMAIL_AUTOMATION.md`, including task-context read/reply/verification/archive flow.
   - In manage mode, archive emails once dealt with or clearly irrelevant; keep inbox focused on items requiring action.
20. Refresh blocker log + change detector via `scripts/blocker-log-refresh.sh`.
   - If `CHANGED=0`, do not proactively re-ping Tom about blockers.
   - If `CHANGED=1`, send concise blocker digest to most recent active thread.
21. Find all open/unresolved Beads tasks (especially unlabeled, `blocked`, or high-priority).
21. Enforce task-cap guardrail: if open task count is >50, run queue-trim first (dedupe/supersede/close with validation evidence) and do not open new non-critical/meta tasks until back under cap.
22. Work on the highest-impact unblocked task you can do safely without asking.
   - If any open actionable task has label `blocker`, work that first (preempts all other tasks).
   - Prefer `source:tom-request` tasks before `source:evergreen`.
   - Do this immediately after triage; do not pause to request permission unless blocked/risky.
23. For every newly created/triaged task, immediately execute or dispatch sub-agent(s). If not, leave a blocker/risk note on the task explaining why.
23.1 Main-thread routing default (heartbeat + active user conversation contexts): keep the main conversation as orchestration/monitoring control plane (triage, dispatch, heartbeat checks, validation, reconciliation).
23.2 During active user conversations, main-thread may perform light direct work to stay responsive and reduce user-facing latency.
23.3 Route substantive implementation to sub-agent threads by default.
23.4 Sub-agents are execution-only (no orchestration/dispatch of other workers).
23.5 Main-thread direct execution beyond light work is exception-only: quick safe one-liners, emergency recovery/takeover, or blocked/no-subagent fallback.
24. For the task being actively worked, keep Beads status/comments current (worker session, progress, blocker state).
   - Enforce comment cadence: start comment, in-flight progress comment, blocker comment (if blocked), and completion comment with validation evidence.
25. Before ending a work cycle, reconcile task status:
   - complete => Beads close + **validation evidence**
   - blocked => keep status `in_progress` if ownership continues, apply `blocked` label + blocker note
26. If a candidate close lacks validation evidence, do not close; append "validation missing" comment and continue execution.
27. If a worker is AFK/stale, main-agent must perform finalization takeover on that task (validation + state update) or explicitly apply `blocked` label + blocker note.
28. Treat task-state drift as priority work: if implementation appears done but status/closure state is not reconciled, fix task state before starting lower-priority new work.
29. Run a cleanup pass each holistic cycle: dedupe/supersede obvious overlapping meta tasks and close completed ones with validation evidence.
30. Enforce closure hygiene protocol: no user-facing completion update until task-state reconciliation is finished.
31. No-progress guardrail: if two consecutive cycles show no substantive artifact, stop policy churn and switch to one concrete execution task or escalate exact unblock to Tom.
32. If blocked, leave a structured blocker note on the task (`blocked_on`, `needed`, `why`, `evidence`, `next_check`) and ask Tom one specific question.

## Alerting / outreach policy (anti-noise)

Only proactively reach out when:
- a task is completed,
- a blocker requires Tom,
- there is an important reliability/security issue,
- email triage found something time-sensitive,
- or Discord `#openclaw` has new actionable posts.

Daily blocker nudge (new):
- Once per day, send Tom a concise blocked-Beads roundup with the top unblock questions.
- Include only blockers needing Tom action; max 5 bullets.
- If no blocked tasks need Tom, skip the nudge.

When blocked or an important question exists:
1. Send Tom a concise message on **Telegram first**.
2. Record outreach state in `memory/blocker-outreach.json` with: blocker id, first ping time, last ping channel, resolved status.
3. If no response after 30 minutes and blocker is still unresolved, send one fallback ping to **Discord DM**.
4. Do not reping more than once every 6 hours for the same blocker unless severity is high.
5. Once resolved, mark blocker as resolved in `memory/blocker-outreach.json`.

Escalation mandate:
- If an issue/task is blocked and no further internal escalation path exists, main-agent must reach out to Tom directly using the channel order above (Telegram -> Discord fallback).

If nothing changed and nothing needs attention, reply `HEARTBEAT_OK`.

Idle execution rule: if no unblocked tasks are available, spend the cycle trying to move blocked tasks forward (fallback implementation, context gathering, or narrowed unblock question).

Evergreen execution rule: if blockers remain unchanged and no immediate unblock path exists, start/advance evergreen Beads tasks (self-improvement, architecture hardening, OpenClaw release intelligence, AI research) so cycles continue producing value.

Evergreen singleton enforcement: keep one canonical in-progress release/watch evergreen Bead; dedupe any duplicate evergreen brief tasks immediately (supersede/close duplicates, never parallel-clone them).

Evergreen quality gate: each evergreen cycle must produce at least one substantive artifact with evidence (commit, doc with citations, script/test output). If not, do not count cycle as progress.

Always-on continuity rule: this is not overnight-only. During any idle window, keep executing highest-value available work without waiting for a new prompt.

Idle output logging rule: append meaningful progress to `state/idle-work/logs/YYYY-MM-DD.md` and refresh `state/idle-work/latest.md`.
No-idle ledger enforcement: each cycle must record `net_new_outputs`, `blockers_changed`, `outcome_category`, and `next_concrete_action` (even when outcome is maintenance-only).

Single-agent reliability rule: whenever a heartbeat action is meant to modify state, prefer script execution with auditable artifacts over freeform model-only steps.

## Conversational Stall Handling

If active work is in progress and chat would otherwise stall:
1. Run a heartbeat-style status sweep immediately.
2. Send Tom a concise in-chat progress update (what is running, ETA, next checkpoint).
3. Keep long commands in background and monitor with polling; do not block chat responses.

Priority order:
1) Reliability/runtime continuity
2) Security hardening
3) Workflow automation
4) Nice-to-have improvements
