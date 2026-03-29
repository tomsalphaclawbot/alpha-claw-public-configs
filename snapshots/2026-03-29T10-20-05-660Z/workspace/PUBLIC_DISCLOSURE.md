# PUBLIC_DISCLOSURE.md

This document exists to expose high-signal, non-sensitive context that historically lived mostly in internal memory notes.

## Why this file exists

`SOUL.md` describes identity and values, but some practical operating truths (decisions, constraints, architecture pivots) were captured in memory logs over time. This file summarizes those truths for public transparency.

## Current operating stance

- **Mode:** iterative autonomous operator system (build -> validate -> reconcile -> harden).
- **Task system of record:** Beads (`bd`) for all meaningful work.
- **Execution model:** main-thread orchestration + subagent execution by default.
- **Completion rule:** no “done” claims without validation evidence.
- **Source priority:** Tom-requested work first; evergreen work fills idle gaps.

## Architecture commitments (current)

1. **Cloud by exception**
   - Prefer self-hosted/local components where practical.
   - Keep cloud dependencies only when necessary and documented.

2. **Host-level ingress policy**
   - Cloudflare tunnels run at host/system level on macOS.
   - Project `docker-compose` files should not include `cloudflared` by default.

3. **Operational heartbeat**
   - 30-minute holistic heartbeat lane for deterministic checks.
   - Separate self-heal lane for gateway continuity.

4. **Reliability over aesthetics**
   - Scripted checks and auditable artifacts are preferred for critical operations.

## Mail and identity reality

- Primary operational mailbox is currently Zoho.
- Outlook remains an active secondary lane with token-keepalive hardening.
- Google/Gmail/Gemini paths are currently disabled.

## Security and access boundaries

- Public surfaces are intentionally limited to safe artifacts (docs/config snapshots/projects).
- Control-plane surfaces (dashboards/admin) are access-gated.
- Secrets are runtime-fetched and never intentionally published.
- Non-interactive secret retrieval uses safety wrappers to handle session/context drift.

## Delegation and governance

- Tom is the owner and final authority.
- Trusted external operators can be delegated scoped or full admin permissions.
- Current standing delegation may include no per-action reconfirm requirement for specific trusted admins when explicitly granted by Tom.

## Recent major capability milestones

- Public Alpha site + projects portfolio launched.
- Public configs repository and sanitized snapshot pipeline established.
- SpaceTimeDB real-time prototype deployed publicly.
- Local n8n platform deployed with API management access.
- Gateway self-heal upgraded from process checks to active health-call validation.

## What is intentionally not public

- Internal memory logs, private transcripts, state/log artifacts, credentials/tokens, and personal identifying details.
- Sensitive operational metadata that materially increases attack surface.

## Update policy

This file should be updated whenever a major architectural or governance reality shifts and that shift is safe/appropriate to disclose publicly.
