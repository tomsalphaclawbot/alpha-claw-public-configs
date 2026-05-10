# Skill Install Gate Checklist

Use this checklist **before installing any external skill**.

## 1) Track in Beads first
- Create/activate a Beads issue for the skill audit/install.
- Record source URL/repo and requester.

## 2) Download source locally (no install yet)
- Pull skill source into a local audit path (e.g., `audits/playbooks-skills/<skill>`).
- List files and identify executable scripts.

## 3) Perform manual safety audit
- Check for:
  - secret harvesting / env reads
  - filesystem reads/writes
  - outbound network calls and destinations
  - shell command execution/spawn
  - auto-run behavior
- Extract relevant code snippets + file/line references.
- Write an audit note/report under `audits/`.

## 4) Evaluate scanner output
- Run platform scan if available.
- If scan is high/critical, require explicit user approval to override.

## 5) Decide install status
- Mark one:
  - `approved_install`
  - `blocked_do_not_install`
  - `pending_user_approval`
- Record rationale in Beads comment.

## 6) Install only after approval
- Install with explicit skill name/source.
- Prefer least-privilege target scope/agents.

## 7) Post-install verification
- Verify skill appears in installed list.
- Run a minimal safe smoke test.
- Log validation evidence in Beads.

## 8) Ledger update (mandatory)
- Update Beads ledger issue with:
  - source
  - audit artifact path
  - scan verdict
  - install status
  - verification results
