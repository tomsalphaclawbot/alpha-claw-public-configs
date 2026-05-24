# Alpha System Replication Spec (Developer Handoff)

Last updated: 2026-03-02
Audience: engineer/operator rebuilding this system from scratch

---

## 0) Scope and intent

This document is a build blueprint for reproducing the current Alpha/OpenClaw operating system as deployed in Tom's environment, with all major guardrails and automation patterns.

It is intentionally:
- step-by-step,
- explicit about dependencies,
- explicit about what is policy vs code,
- explicit about secrets handling.

It is **not** a secret dump. Any API keys/tokens are represented as placeholders.

---

## 1) Core design principles (why this system is structured this way)

1. **Reliability before autonomy**
   - Autonomous actions are only safe when heartbeat checks, watchdogs, and rollback paths exist.

2. **Beads is the execution source-of-truth**
   - Task state is kept in Beads, not scattered across chat messages.

3. **Memory-first operation**
   - Durable context is persisted as markdown memory artifacts, not only model context.

4. **Default-deny external side effects**
   - Outbound posts/sends are constrained by allowlists and explicit approvals.

5. **Defense-in-depth guardrails**
   - Security audit gate + prompt-injection playbook + financial controls + kill-switch.

6. **Auditable automation**
   - Scheduled scripts emit machine-readable artifacts in `state/` for verification.

---

## 2) High-level architecture

### Repositories/directories
- OpenClaw config root: `~/.openclaw`
- Workspace root: `~/.openclaw/workspace`
- Task DB: `~/.openclaw/workspace/.beads`
- Docs + policy: workspace root markdown files (`ARCHITECTURE.md`, `HEARTBEAT.md`, etc.)
- Runtime artifacts: `~/.openclaw/workspace/state/*`

### Control plane components
- OpenClaw gateway (local)
- Channels: Telegram + Discord
- Beads for queueing and lifecycle
- Holistic heartbeat script (`scripts/heartbeat-holistic.sh`)
- Safety scripts:
  - `scripts/openclaw-security-gate.sh`
  - `scripts/heartbeat-slo-report.sh`
  - `scripts/redteam-monthly-check.sh`
  - `scripts/financial-controls-report.sh`

---

## 3) Prerequisites

1. Install OpenClaw CLI and verify:
   ```bash
   openclaw --version
   openclaw status
   ```

2. Create/clone workspace repo and ensure git works.

3. Install Beads CLI (`bd`) and verify:
   ```bash
   bd --help
   bd ready --json
   ```

4. Configure secret manager access (Bitwarden/rbw or equivalent) for runtime secret retrieval.

5. Confirm shell execution permissions:
   - all scripts in `workspace/scripts` should be executable.

---

## 4) Base OpenClaw runtime configuration (sanitized)

Create/update `~/.openclaw/openclaw.json` with at least:
- gateway local mode + auth token
- enabled channels you need
- DM policy and group policy
- trusted proxy and tailscale mode (if applicable)
- memory plugin enabled
- ACP runtime settings (optional but recommended)

Use placeholders for secrets:
- `TELEGRAM_BOT_TOKEN`
- `DISCORD_TOKEN`
- `GATEWAY_TOKEN`
- provider API keys

Best practice:
- keep all real secrets in environment/secret manager, not committed plaintext.

---

## 5) Memory system (article-aligned 3-layer implementation)

This setup maps to the article's memory model as follows:

1. **Layer 1 (durable knowledge graph equivalent)**
   - `MEMORY.md` + stable profile files (`IDENTITY.md`, `USER.md`, selected `memory/*` reference files)

2. **Layer 2 (daily notes)**
   - `memory/YYYY-MM-DD.md`
   - heartbeat appends operational summaries automatically

3. **Layer 3 (tacit rules/preferences/guardrails)**
   - `SOUL.md`
   - policy files (`EXFILTRATION_GUARD.md`, `RED_TEAMING.md`, `HEARTBEAT.md`, `AGENTS.md`)

Implementation behavior:
- Every operational cycle appends to dated memory logs.
- Issue/task-specific decisions are written to `memory/issues/<id>.md`.

---

## 6) Task orchestration model

### System of record
- Beads only.

### Core workflow
1. Create task in Beads.
2. Claim task (`in_progress`) with assignee metadata.
3. Execute work.
4. Add progress comments with evidence.
5. Close only with validation evidence.

Core commands:
```bash
bd ready --json
bd list --status open --json
bd show <id>
bd create --title "..." --type task --priority 1
bd update <id> --status in_progress
bd comments add <id> "progress/evidence"
bd close <id> --reason "Completed"
```

---

## 7) Heartbeat and scheduler implementation

### Scheduler targets
- OpenClaw cron: `heartbeat:30m-holistic`
- User cron:
  - `*/2 * * * * scripts/gateway-selfheal.sh`
  - `0 0 * * * scripts/daily-full-sync.sh`

### Holistic heartbeat behavior
`HEARTBEAT.md` + `scripts/heartbeat-holistic.sh` define sequence including:
- queue triage
- watchdog checks
- security audit gate
- SLO report generation
- red-team monthly artifact enforcement
- financial controls daily report
- subagent dispatch/stall handling
- blocker reconciliation
- autocommit/push

Artifacts produced:
- `state/heartbeat-runs.jsonl`
- `state/heartbeat-latest.json`
- `state/heartbeat-runs/<run-id>/*.log`
- `memory/YYYY-MM-DD.md` rollup lines

---

## 8) Security model and guardrails

### Prompt-injection and side-effect controls
Policy file: `EXFILTRATION_GUARD.md`

Key rules:
- default deny on outbound side effects,
- treat fetched content as untrusted,
- only allow side effects for allowlisted users/scopes,
- require paid actions to pass financial authorization gate.

### Security gate script
File: `scripts/openclaw-security-gate.sh`

Behavior:
- runs deep security audit,
- writes reports to `state/security/audit-*.json` and `state/security/audit-latest.json`,
- exits non-zero on warn/critical.

---

## 9) Red-team regimen

Policy file: `RED_TEAMING.md`
Enforcement helper: `scripts/redteam-monthly-check.sh`

Monthly minimum:
- at least 3 adversarial scenarios,
- Beads entries with severity + mitigation + evidence,
- freeze/retest path for high/critical findings.

Artifact:
- `state/reports/redteam/YYYY-MM.md`

---

## 10) Financial controls (new gap closure)

### Policy file
`config/financial-controls.json`

Current default profile:
```json
{
  "stage": "supervised",
  "dailyCapUsd": 30.0,
  "perActionCapUsd": 10.0,
  "approvalThresholdUsd": 3.0,
  "requireApprovalAboveThreshold": true
}
```

### Enforcement engine
- `scripts/financial-controls.py`
- wrapper: `scripts/financial-controls.sh`

### Commands
```bash
scripts/financial-controls.sh status
scripts/financial-controls.sh authorize --amount 4.50 --action "api credits" --category inference --actor main-agent
scripts/financial-controls.sh authorize --amount 8.00 --action "domain renewal" --category domain --actor main-agent --approved-by Tom
scripts/financial-controls.sh kill-switch on --reason "incident" --by Tom
scripts/financial-controls.sh report --days 7
```

### Exit-code semantics
- `0` approved
- `2` denied
- `3` requires explicit approval

### State artifacts
- Ledger: `state/finance/ledger.jsonl`
- Kill switch: `state/finance/kill-switch.json`
- Report: `state/reports/finance-latest.json`

---

## 11) Observability and SLOs

### SLO report script
File: `scripts/heartbeat-slo-report.sh`

Output file:
- `state/reports/heartbeat-slo-latest.json`

Suggested initial targets:
- heartbeat OK rate >= 95% (24h)
- step errors <= 3/day
- median duration <= 120s

---

## 12) Channel and identity governance

- Trusted users tracked in:
  - `memory/trusted-external-allowlist.json`
  - `ACTIVE_USERS.md` (human-readable)
- Non-allowlisted external requests requiring side effects are blocked pending owner approval.

---

## 13) Comparison to article workflow (Nat/Felix)

Article themes vs this system:

1. **3-layer memory**
   - Implemented, with explicit file-backed persistence.

2. **Parallel execution / multi-threaded operation**
   - Implemented via subagent orchestration + heartbeat dispatch enforcement.

3. **Heartbeat + cron autonomy**
   - Implemented and hardened with log artifacts + watchdog + recovery checks.

4. **Prompt-injection resistance**
   - Implemented with explicit policy and red-team cadence.

5. **Business/autonomy guardrails**
   - Strengthened beyond article baseline using coded financial controls + kill-switch.

Where this system goes beyond article claims:
- formal Beads lifecycle discipline,
- explicit security audit gate in loop,
- codified spend authorization + machine-readable ledger,
- explicit staged enablement ladder for outbound autonomy.

---

## 14) End-to-end implementation checklist (copy/paste for developer)

1. Set up OpenClaw + workspace repos.
2. Enable channels with placeholder tokens.
3. Install/verify Beads.
4. Create baseline policy docs:
   - `HEARTBEAT.md`
   - `EXFILTRATION_GUARD.md`
   - `RED_TEAMING.md`
   - `ARCHITECTURE.md`
5. Add scripts:
   - heartbeat holistic + watchdog + dispatch scripts
   - `openclaw-security-gate.sh`
   - `heartbeat-slo-report.sh`
   - `redteam-monthly-check.sh`
   - `financial-controls.py`, `financial-controls.sh`, `financial-controls-report.sh`
6. Add financial policy config (`config/financial-controls.json`).
7. Wire heartbeat script to call security/SLO/red-team/finance steps.
8. Configure scheduler (OpenClaw cron + user cron self-heal/sync).
9. Create allowlist and active user registry files.
10. Run validation suite:
    - `openclaw status`
    - `scripts/openclaw-security-gate.sh`
    - `scripts/heartbeat-slo-report.sh`
    - `scripts/financial-controls.sh status`
    - approval/deny/kill-switch test commands
11. Confirm artifacts appear in `state/` paths.
12. Commit + push.

---

## 15) Validation protocol for acceptance

A rebuild is accepted only if all are true:

1. Security gate returns zero warn/critical.
2. Heartbeat runs produce expected JSON/log artifacts.
3. Financial authorization returns expected exit codes for:
   - denied (policy breach),
   - requires_approval,
   - approved.
4. Kill-switch blocks authorizations when enabled.
5. Beads workflow can track create->in_progress->close with evidence.
6. Memory daily files are being appended automatically.

---

## 16) Non-portable environment specifics (adapt when cloning)

When cloning to a new instance, replace:
- hostnames/domains,
- channel bot tokens,
- gateway auth token,
- secret-manager wiring,
- mailbox provider credentials,
- allowlist user IDs.

Do **not** copy raw credentials/tokens from an existing deployment.

---

## 17) Optional hardening extras

- Add signed config manifests (integrity verification before startup)
- Add policy unit tests for side-effect/allowlist decisions
- Add immutable append-only remote backup for `state/finance/ledger.jsonl`
- Add alerting on security gate failure and finance cap-denial spikes

---

## 18) Source mapping (local)

- `ARCHITECTURE.md` — topology and operating model
- `HEARTBEAT.md` — deterministic loop contract
- `EXFILTRATION_GUARD.md` — outbound safety model
- `RED_TEAMING.md` — adversarial testing model
- `docs/autonomy-gap-closure-plan.md` — gap closure decisions
- `config/financial-controls.json` + `scripts/financial-controls.py` — spend controls

---

## 19) Operator note on the paid prompt pack question

You do not need a paid prompt pack to reproduce the system pattern.
What matters is:
- durable memory structure,
- deterministic operational loop,
- explicit safety controls,
- auditable state and validation evidence.

This spec gives the implementation shape directly in code/policy terms so a developer can rebuild it without relying on proprietary prompt bundles.
