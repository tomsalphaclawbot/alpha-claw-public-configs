# Workspace Root Markdown Audit - 2026-02-27

Scope: `*.md` files at workspace root.

## Classification Table

| file | status | rationale | recommended action |
|---|---|---|---|
| ACTIVE_USERS.md | KEEP | Active registry with current trust/authorization visibility; aligns with allowlist policy references. | Keep as operational reference; refresh when trusted cohort changes. |
| AGENTS.md | KEEP | Canonical operating policy and execution protocol; explicitly enforces Beads as system of record. | Keep canonical; continue incremental updates only with policy intent. |
| ARCHITECTURE.md | KEEP | Current architecture source for orchestration model and Beads control plane. | Keep; update only with approved architecture changes. |
| BEADS.md | KEEP | Canonical tasking policy doc for Beads-only execution. | Keep as primary task-system reference. |
| CONSTITUTION.md | KEEP | Governance and invariants still current (traceability, evidence, safety). | Keep. |
| EMAIL_AUTOMATION.md | UPDATE | Title/body still Gmail-centric while workspace now documents Outlook/Zoho operations and Google hard lock. | Update wording to mailbox/provider-agnostic policy and reflect current active mail lanes. |
| EMAIL_INFRA_RESEARCH.md | ARCHIVE_CANDIDATE | Research snapshot appears historical and mostly pre-migration baseline context. | Move to `docs/archive/` (or add clear "historical research" header) once superseded decisions are captured elsewhere. |
| EMAIL_MIGRATION_PLAN.md | UPDATE | Migration plan may be partially completed; still useful but should reflect current implemented state and remaining gaps. | Add "current status" section and mark completed vs pending steps. |
| EMAIL_PROVIDER_RANKING.md | ARCHIVE_CANDIDATE | Selection rationale is useful history but likely not active operational policy. | Archive as historical decision record (or mark read-only historical). |
| EXFILTRATION_GUARD.md | KEEP | Active security policy and outbound control constraints remain directly in force. | Keep as active policy. |
| GITHUB_ISSUES_WORKFLOW.md | DEPRECATE | Legacy guidance overlaps/conflicts with Beads-only policy unless explicitly fenced as historical. | Keep for history only with strong deprecation banner + links to `BEADS.md` and `AGENTS.md`. **Applied in this change set.** |
| HEARTBEAT.md | KEEP | Active 30m holistic runbook with Beads-first queue triage and operational checks. | Keep current; maintain script parity. |
| IDENTITY.md | KEEP | Current identity/profile metadata and channels are actively referenced. | Keep; update as accounts/channels evolve. |
| MEMORY.md | KEEP | Long-term curated context includes Beads-only transition memory and operating constraints. | Keep; continue curation. |
| PERPLEXITY_INTEGRATION.md | KEEP | Valid skill/tooling setup doc; still useful and scoped. | Keep. |
| PROJECTS.md | KEEP | Active project bootstrap and deployment runbook. | Keep; refresh examples when tooling changes. |
| README.md | UPDATE | Generally current, but should explicitly flag GitHub Issues workflow doc as deprecated historical-only to reduce ambiguity. | Add small deprecated/historical note in key files section. **Applied in this change set.** |
| RED_TEAMING.md | KEEP | Security testing playbook remains valid; includes current paused status note. | Keep; update trusted tester state when resumed. |
| SOUL.md | KEEP | Active persona/behavior contract with explicit operational guidance. | Keep. |
| TELEGRAM_ONBOARDING.md | KEEP | Current pairing-handshake runbook still operationally relevant. | Keep; update templates as needed. |
| TODO.md | KEEP | Already framed as informational-only with Beads as source of truth. | Keep as lightweight pointer doc. |
| TOOLS.md | KEEP | Environment-specific operational notes; actively useful. | Keep and maintain as cheat sheet. |
| TRUSTED_USER_ONBOARDING.md | KEEP | Active trusted-user onboarding process with traceability rationale. | Keep; synchronize with allowlist state. |
| USER.md | KEEP | Core user profile/context file used at startup. | Keep and update as preferences evolve. |

## Beads-only Policy Sources (citations)

The current policy baseline is consistently Beads-first / GitHub-Issues-retired:

1. `AGENTS.md:98`
   `Task system of record: Beads (bd) in workspace. Do not use GitHub issues for task tracking.`

2. `MEMORY.md:72`
   `System of record is now transitioning to Beads-only local tasking (bd) per Tom (2026-02-24).`

3. `MEMORY.md:75`
   `no new operational dependency on GitHub Issues for queue execution;`

4. `HEARTBEAT.md:25-26`
   `Triage queue with Beads-only strategy:`
   `Beads operational queue: bd ready --json ...`

## Shareable Skills & Tools

### Installed workspace skills (`workspace/skills/*`)

- `skills/browser-use-via-claude-chrome` - deterministic Claude + Chrome extension browsing workflow.
- `skills/claude-control-skill` - stepwise PTY/session control for Claude CLI auth and interactive flows.
- `skills/claude-relay` - tmux-based persistent Claude session relay across projects.
- `skills/outlook-graph-mail` - modern-auth Outlook mailbox operations via Microsoft Graph scripts.
- `skills/perplexity-safe` - web-grounded Perplexity research with security hardening.

### Key tool docs currently used in this workspace

- `AGENTS.md` - canonical operating protocol + Beads enforcement.
- `BEADS.md` - canonical task system policy (`bd` as source of truth).
- `HEARTBEAT.md` - operational sweep/runbook for routine execution.
- `TOOLS.md` - environment-specific tooling/account notes.
- `README.md` - top-level orientation and key file map.

### Action-oriented recommendation

Keep this section as a compact onboarding/export block for collaborators, and refresh it whenever a skill is added/removed under `skills/`.

## Notes

- This audit treats historical docs as valid when clearly labeled; the main risk is ambiguous operational guidance.
- High-confidence cleanup in this pass focuses on preventing task-system confusion (GitHub Issues vs Beads).
