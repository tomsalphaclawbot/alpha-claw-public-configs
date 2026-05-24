# Autonomy Gap Closure Plan

Date: 2026-02-28

This file operationalizes the gap memo into deployable controls for this workspace.

## 1) Security hardening closure (P0)

- Added `scripts/openclaw-security-gate.sh`.
- Behavior:
  - Runs `openclaw security audit --deep --json`.
  - Writes timestamped report to `state/security/audit-<timestamp>.json` and `state/security/audit-latest.json`.
  - Exits non-zero when critical/warn findings exist.

## 2) Reliability SLO visibility (P1)

- Added `scripts/heartbeat-slo-report.sh`.
- Behavior:
  - Reads `state/heartbeat-runs.jsonl`.
  - Computes last-24h aggregates and latency stats.
  - Writes report to `state/reports/heartbeat-slo-latest.json`.

Suggested initial SLO targets:
- Heartbeat OK rate >= 95% (rolling 24h)
- Step error count <= 3/day
- Median heartbeat duration <= 120000 ms

## 3) Prompt-injection resilience cadence (P0)

Use `RED_TEAMING.md` as the canonical attack playbook.

Monthly minimum cadence:
- Run at least 3 adversarial scenarios across untrusted-content surfaces.
- Record each scenario in Beads with severity + mitigation.
- If any High/Critical is observed:
  - Freeze affected external action lane.
  - Patch controls.
  - Re-test before re-enable.

## 4) External action enablement ladder (P1)

- **Stage 0: Read-only** (current default)
  - No third-party outbound writes.
- **Stage 1: Supervised writes**
  - Outbound writes only with explicit human approval.
  - Validation evidence required before send.
- **Stage 2: Bounded autonomy**
  - Writes allowed only for allowlisted users/scopes.
  - Budget/rate caps + kill-switch required.

Promotion gate between stages:
- Security gate clean for 7 consecutive days.
- No unresolved High/Critical red-team findings.
- Heartbeat SLO report within target for 7 days.

## 5) Financial guardrails (P0)

Implemented controls:
- Policy file: `config/financial-controls.json`
- Enforcement CLI: `scripts/financial-controls.sh` (backed by `scripts/financial-controls.py`)
- Ledger: `state/finance/ledger.jsonl`
- Kill-switch state: `state/finance/kill-switch.json`
- Daily report: `state/reports/finance-latest.json`

Supported controls:
- Daily spend cap (`dailyCapUsd`)
- Per-action max spend (`perActionCapUsd`)
- Approval threshold (`approvalThresholdUsd` + `requireApprovalAboveThreshold`)
- Stage gating (`read-only` / `supervised` / `bounded`)
- Immediate kill-switch (`financial-controls.sh kill-switch on`)

Example commands:
- `scripts/financial-controls.sh status`
- `scripts/financial-controls.sh authorize --amount 4.50 --action "api credits" --category inference --actor main-agent`
- `scripts/financial-controls.sh authorize --amount 8.00 --action "domain renewal" --category domain --actor main-agent --approved-by Tom`
- `scripts/financial-controls.sh kill-switch on --reason "incident" --by Tom`
- `scripts/financial-controls.sh report --days 7`

## 6) Worker completion quality gate (P1)

Before marking task complete:
1. Requirement checklist complete
2. Validation command output attached
3. Reconciliation done in Beads (status/comments)
4. Any outbound side effect logged with target + payload summary
