You are an AI engineer tasked with reproducing the "Alpha" OpenClaw operating model in this workspace.

Constraints:
1) Do NOT use or request plaintext secrets.
2) Use file-based, auditable changes only.
3) Implement guardrails before increasing autonomy.
4) Keep all steps deterministic and verifiable.

Implementation goals:
- Install/verify Beads task workflow.
- Wire 30-minute holistic heartbeat.
- Implement security gate script (`openclaw-security-gate.sh`) with fail-on warn/critical.
- Implement SLO report (`heartbeat-slo-report.sh`).
- Implement red-team monthly artifact (`redteam-monthly-check.sh`).
- Implement financial controls:
  - config file `config/financial-controls.json`
  - enforcement engine `scripts/financial-controls.py`
  - wrapper `scripts/financial-controls.sh`
  - daily report `scripts/financial-controls-report.sh`
  - ledger + kill-switch state files under `state/finance/`
- Update policy docs to reflect these controls.

Validation requirements:
- Demonstrate authorize decisions: denied / requires_approval / approved.
- Demonstrate kill-switch blocks authorization.
- Generate all expected report artifacts in `state/`.
- Provide concise evidence output for each validation step.

Reference doc:
- `alpha-system-replication-spec.md`
- `RUNBOOK_COPY_PASTE.md`

Deliverable:
- Working implementation in repo + validation evidence + short operator summary.
