# OpenClaw Operating Architecture

## Purpose
This system is a **living hive mind**: main-agent orchestration + parallel sub-agents, with **Beads as operational system-of-record** and heartbeat-driven automation.

## Governance
- Architecture updates are Tom-controlled.
- Do not modify architecture docs without explicit Tom authorization.

## Core Components
- **Gateway runtime**: OpenClaw gateway + channel integrations.

## Context Loading Architecture (Tom directive, 2026-03-05)
- **Foreground/chat plane** stays minimal: only enough context for safe routing, decisions, and user-visible status.
- **Background/work plane** handles heavy execution, long analysis, and bulky context traversal.
- **Pointer-first retrieval** is the default: resolve specific files/sections on demand instead of preloading large policy bundles.
- **Compression hygiene** remains mandatory at high context pressure (snapshot -> compress -> reload critical memory).
- **Config repo**: `~/.openclaw` (`openclaw-config`) — runtime state and root policy.
- **Workspace repo**: `~/.openclaw/workspace` (`openclaw-workspace`) — scripts, docs, memory, orchestration playbooks.
- **Project sub-repos**: each new app/site/tool under workspace should be its own git repo, typically in `workspace/projects/<project-name>/`.
- **Local automation platform**: `projects/n8n-local` (n8n + worker + Postgres + Redis) is now a first-class local ops component, managed via API runbook (`N8N_ACCESS.md`).
- **Operational queue**: Beads (`.beads/`) for high-frequency multi-agent coordination.
- **Lifecycle visibility**: Beads task history/notes/events in `.beads/`.
- GitHub-era task scripts are archived under `scripts/archive/github-legacy/` and excluded from active orchestration.
- **Worktrees**: one issue/task activation per branch/worktree.
- **Focused-diff policy**: review/triage uses `scripts/git-diff-focus.sh` + tracked excludes (`config/diff-focus-excludes.txt`) while commit coverage remains full.

## Heartbeat Model (stability lock)

### 30-minute (holistic only)
- Active scheduled tier (OpenClaw cron: `heartbeat:30m-holistic`).
- Full operational sweep.
- Triage tasks, watchdog checks, mailbox/calendar scans, dispatch, sync automation.

### Disabled tiers (for now)
- 1-minute and 5-minute heartbeat schedules are disabled until stability is proven and Tom explicitly re-enables them.

## Current Scheduler Reality (post-incident)
- **OpenClaw cron**
  - `heartbeat:30m-holistic` (isolated session)
- **User crontab**
  - `*/2 * * * * scripts/gateway-selfheal.sh` (always-on safe gateway self-heal lane)
  - `0 0 * * * scripts/daily-full-sync.sh` (daily full commit/push)
- Heartbeat authority remains 30-minute holistic only; gateway-selfheal is a separate reliability lane.
- Gateway self-heal health criteria now include an active request/response probe (`openclaw gateway call health` expecting `"ok": true`), not only process/service checks.

## Ingress Policy (Cloudflare)
- Cloudflare tunneling runs at **host/system level** on macOS.
- Project `docker-compose.yml` files should not embed `cloudflared` as a default service.
- Project scaffolds use host-level tunnel stubs (for example `ops/cloudflared.host.example.yml`) and map ingress to local host ports.
- Access-controlled surfaces (dashboard/beads/vnc/wiki) use Cloudflare Access policy gates.

## Mail Architecture (current)
- Primary operational mailbox: `[REDACTED_EMAIL]`.
- Secondary mailbox: `[REDACTED_EMAIL]`.
- Heartbeat executes Zoho check/manage scripts each holistic cycle.
- Outlook Graph lane remains available as secondary and now uses an expiry-aware token helper + keepalive script for reliability.

## Provider Deactivation Locks
- Google/Gmail/Gemini lanes are hard-disabled.
- Runtime config excludes Google API key/profile/model fallback paths.
- Heartbeat policy explicitly forbids Google account/API actions until Tom re-enables.

## Secrets Runtime Policy
- `rbw` remains canonical secret source.
- Non-interactive scripts use `scripts/lib-rbw-safe.sh` wrapper to handle session/context drift.
- Wrapper strategy: normal `rbw` call first, then sanitized env fallback (`env -i HOME=... PATH=... rbw ...`).
- Secrets are retrieved at runtime only and must not be written to docs, logs, or committed files.

## Diff Hygiene Policy
- Canonical focused-diff helper: `scripts/git-diff-focus.sh`
- Canonical excludes list: `config/diff-focus-excludes.txt`
- Applies to review/triage/heartbeat visibility only (token-efficiency + noise reduction).
- Does **not** alter staging/commit behavior; full-state commit coverage remains intact.
- Supports both repos (`--repo workspace` and `--repo config`).

## Queue Strategy
1. `blocker` tasks preempt everything.
2. Source ordering: `source:tom-request` before `source:evergreen`.
3. Then use priority labels: `P0` -> `P1` -> `P2` -> `P3`.
4. Inside each priority band, enforce **oldest-first** to prevent issue stacking.
5. Use simplicity only as a tie-breaker between similarly aged items.
6. Evergreen anti-churn: evergreen work must emit substantive artifacts (not policy-only churn) or trigger unblock escalation.

Helpers:
- `bd ready --json` for operational ready queue.
- `bd list --status open --json` for full queue inspection.

Queue integrity guardrail:
- `scripts/subagent-dispatcher.sh` + `scripts/heartbeat-enforce.sh` ensure open high-priority Beads tasks are queued and acted on.

## Sub-Agent Orchestration
- Main-agent coordinates (primarily during heartbeat runs and active user conversations).
- In active conversations, main-agent stays responsive and may do light direct work while coordinating.
- Sub-agents execute issue-scoped work in parallel and are execution-only (not orchestrators).
- Sub-agents run in WORK MODE: ship concrete outputs quickly, keep comment cadence tight, and escalate immediately when blocked.
- Every sub-agent spawn should include a context handoff bundle (problem summary, current state, file/paths, acceptance criteria, escalation path).
- Sub-agents must post issue log metadata:
  - session key
  - run id
  - log reference
  - heartbeat timestamp
- Sub-agents can escalate via structured help requests.
- Timeout guardrail: worker runtime on a single issue >30 minutes is treated as likely failure unless fresh progress evidence exists.
- AFK tolerance protocol: assume some workers will drop after partial progress; system must recover by promoting stale in-progress validation/finalization to top-priority and allowing main-agent takeover for closure hygiene.
- Cross-thread worker truth source: `state/subagents/active.json` (refreshed by `scripts/subagent-global-status.sh`) so any active conversation thread sees consistent worker status.
- Active conversation truth source: `state/conversations/active.json` (refreshed by `scripts/conversation-activity-refresh.sh`) for proactive routing to the most recent eligible thread/session.
  - Session model fields: `key`, `channel`, `scope`, `chatId`, `updatedAt`, `ageMs`, `active`, `eligibleForProactive`, `updateEligible`, `isSystemSession`, `routingScore`.
  - Routing rule: prefer `updateEligible=true` user threads (Discord/Telegram/Webchat) by freshness score; suppress cron/run/system sessions.
  - Cooldown guardrail: `scripts/proactive-notify-guard.sh` enforces per-session + global anti-spam before any proactive ping is queued.
  - Async subagent-to-thread update queue: `state/conversations/pending-updates.jsonl` (produced by `scripts/subagent-update-enqueue.sh`, drained by main-agent heartbeat/active conversation loop).
- Dedicated state folder: `state/subagents/` with:
  - `active.json` (current workers)
  - `events.jsonl` (snapshot events)
  - `logs-index.json` (run -> session/log reference mapping)
- Canonical read helper: `scripts/subagent-status-read.sh` for thread-agnostic status replies.

## Beads Task Model
- **Beads (`.beads/`) is canonical for execution**: create, claim, update, close.
- Task lifecycle evidence lives in Beads notes/history/events.
- Heartbeat automation reads/writes Beads directly.
- Bead intake metadata is required for routing traceability:
  - `requester`
  - `source_channel`
  - `source_chat`
  - `source_message`
- Mandatory Beads comment cadence for worked tasks:
  1) intake metadata note,
  2) activation/start note,
  3) at least one progress note,
  4) blocker note when blocked,
  5) completion note with validation evidence.

## Escalation Ladder
`sub-agent -> main-agent -> Tom`

If no internal path remains:
- notify Tom on Telegram first
- fallback Discord DM

Delegation note:
- Delegation change (2026-03-04): Steven Dees admin delegation was revoked per Tom directive.

## Blocker Visibility & Digest Suppression
- Canonical blocker snapshots are written to:
  - `state/blockers/latest.md`
  - `state/blockers/latest.json`
  - `state/blockers/YYYY-MM-DD.md` (append-only dated log)
- `scripts/blocker-log-refresh.sh` computes a content hash and marks whether blockers changed.
- Heartbeat should only proactively notify Tom when blocker state changed (`CHANGED=1`) to avoid repetitive pings.

## Idle/Overnight Work Tracking
- Canonical location: `state/idle-work/`
  - `latest.md` = current overnight focus/status
  - `logs/YYYY-MM-DD.md` = dated chronological log
  - `research/*` = generated briefs and synthesis artifacts
- During read-only lock mode, this lane is research/analysis only (no external interactions).

## Reliability/Safety
- Project Immortal safe restart + rollback patterns.
- Stale-claim recovery and worker-stall detection.
- No force operations on `main`/`master`.
- Conflict pushes auto-branch + PR, never overwrite.

## Issue Memory Scope Policy
Issue memory files (`memory/issues/<issue-number>.md`) are strictly issue-scoped.

Allowed content:
- decisions made for that issue
- implementation notes/evidence for that issue
- blockers and next step for that issue
- references/links to preceding conversational memory logs that provide origin context
Disallowed content:
- unrelated chat transcripts
- general diary/log content not tied to issue requirements
- cross-issue notes unless explicitly referenced as dependency

## Issue Closure Validation Gate
Before any issue is closed, execution must include validation evidence linked to requirements.

Worker self-evaluation requirement:
- Before declaring done, worker must explicitly verify checklist completion, validation evidence presence, and issue-state reconciliation.

Minimum closure evidence:
1. **What was validated** (mapped to checklist items)
2. **How it was validated** (commands/tests/manual verification steps)
3. **Observed result** (pass/fail with concise output/log reference)
4. **Artifact reference** (issue comment links, logs, screenshots, or command output snippets)

Allowed close states:
- **Validated complete**: all checklist items validated with evidence
- **Blocked**: explicit blocker + owner/question + `blocked` label; keep open (status may remain `in_progress`)
- **Superseded**: only with `superseded-by #<issue>` plus migration evidence that requirements are covered elsewhere

## Task Closure Hygiene Protocol (mandatory)
Execution order is strict:
1. implement work
2. validate work
3. reconcile issue state (checkboxes + completion/blocker comment + labels + close/open state)
4. only then send user-facing completion update

If implementation is done but issue state is not reconciled, that drift is priority work and must be fixed immediately before new lower-priority tasks.

## Incident Learnings (heartbeat automation)
Key failure modes observed in the prior configuration:
1. repeated stall/escalation loops generated excessive duplicate external actions,
2. GitHub API rate-limit exhaustion from repeated writes,
3. gateway restart churn under heavy automation pressure,
4. scheduler overlap that prioritized noise over deterministic recovery.

Current mitigations:
- cooldown + dedupe guards in dispatcher/stall-watch flows,
- Beads-only operational control plane (no GitHub issue dependency for execution),
- reduced scheduler surface area (single holistic heartbeat + targeted crontab jobs),
- PM reconciliation + unix mail checks integrated into heartbeat enforcement.

## Why sync tasks used to stick
Prior sync-task behavior remained open under runtime churn (live sessions/log drift). Current policy removed Bead auto-creation from diff detection; diff tasker is now visibility-only.

## 2026-02-24 Documentation Refresh
- Clarified that **architecture source-of-truth** lives in `workspace/ARCHITECTURE.md`.
- Reconfirmed two-repo model:
  - `openclaw-workspace`: operations playbooks, scripts, and memory
  - `openclaw-config`: runtime config/state backup + workspace submodule pointer
- Reconfirmed commit order for sync operations:
  1. Commit/push workspace documentation updates.
  2. Commit/push config repo (including updated `workspace/` submodule pointer when changed).
