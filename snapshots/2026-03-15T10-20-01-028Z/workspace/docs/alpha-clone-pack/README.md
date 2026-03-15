# Alpha Clone Pack (Direct Import)

This pack is the fastest/safest way to replicate the system on another OpenClaw bot.

## Recommended method (best practice)
Use **file-based import + runbook execution**, not a giant chat paste.

Why:
- deterministic (versioned files)
- auditable (git diff)
- repeatable (scripted steps)
- less token/context loss than long chat prompts

## Contents
- `alpha-system-replication-spec.md` — full architecture + policy + rationale
- `RUNBOOK_COPY_PASTE.md` — strict command sequence for setup
- `BOOTSTRAP_PROMPT.md` — one-shot instruction prompt for an AI engineer/sub-agent

## Suggested execution on target bot
1. Download and extract this pack.
2. Commit these files into target workspace repo under `docs/`.
3. Execute `RUNBOOK_COPY_PASTE.md` top-to-bottom.
4. Validate with acceptance checks at end.

## Security warning
Do not copy raw tokens/secrets from another instance. Use placeholders and populate via secret manager on target host.
