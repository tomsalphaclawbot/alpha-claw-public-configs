# RUNBOOK (Copy/Paste)

> Execute in target bot workspace root.

## 1) Baseline checks
```bash
openclaw --version
openclaw status
bd --help
```

## 2) Create core folders
```bash
mkdir -p config scripts docs state/reports state/security state/finance state/reports/redteam memory
```

## 3) Financial controls config
Create `config/financial-controls.json`:
```json
{
  "version": 1,
  "currency": "USD",
  "stage": "supervised",
  "dailyCapUsd": 30.0,
  "perActionCapUsd": 10.0,
  "approvalThresholdUsd": 3.0,
  "requireApprovalAboveThreshold": true,
  "allowedCategories": ["inference","hosting","software","domain","other"]
}
```

## 4) Add scripts
Copy in these scripts from this pack/spec implementation:
- `scripts/financial-controls.py`
- `scripts/financial-controls.sh`
- `scripts/financial-controls-report.sh`
- `scripts/openclaw-security-gate.sh`
- `scripts/heartbeat-slo-report.sh`
- `scripts/redteam-monthly-check.sh`

Then:
```bash
chmod +x scripts/*.sh scripts/*.py
```

## 5) Heartbeat wiring
Ensure holistic heartbeat includes these steps each cycle:
- security gate
- slo report
- redteam monthly check
- finance report

And in HEARTBEAT policy doc, include corresponding checklist lines.

## 6) Validate controls
```bash
scripts/financial-controls.sh status
scripts/financial-controls.sh authorize --amount 2.00 --action "test" --category inference --actor main-agent
# expect: requires_approval (exit 3 in supervised mode)

scripts/financial-controls.sh authorize --amount 2.00 --action "test approved" --category inference --actor main-agent --approved-by Owner
# expect: approved (exit 0)

scripts/financial-controls.sh kill-switch on --reason "test" --by Owner
scripts/financial-controls.sh authorize --amount 1.00 --action "should fail" --category inference --actor main-agent --approved-by Owner
# expect: denied while kill-switch on
scripts/financial-controls.sh kill-switch off --reason "test done" --by Owner

scripts/openclaw-security-gate.sh
scripts/heartbeat-slo-report.sh
scripts/redteam-monthly-check.sh
scripts/financial-controls-report.sh
```

## 7) Acceptance checks
- `state/security/audit-latest.json` exists
- `state/reports/heartbeat-slo-latest.json` exists
- `state/reports/finance-latest.json` exists
- `state/reports/redteam/YYYY-MM.md` exists
- finance ledger events written to `state/finance/ledger.jsonl`

## 8) Schedule
- OpenClaw cron: 30-minute holistic heartbeat
- User cron: gateway self-heal + daily full sync

## 9) Commit
```bash
git add .
git commit -m "Add alpha guardrails + heartbeat integrations"
git push
```
