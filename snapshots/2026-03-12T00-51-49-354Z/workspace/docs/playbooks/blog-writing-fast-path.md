# Blog Writing Fast Path (Codex + Claude)

Purpose: run co-authored articles with minimal setup overhead. This is the default workflow.

## Load order
1. Read `docs/playbooks/society-of-minds-writing-methodology.md` sections: Roles, Default workflow, Consensus rubric
2. Check `docs/playbooks/society-of-minds-calibration.md` for recent feedback / lessons
3. Open/create article folder: `docs/articles/<YYYY-MM-DD-slug>/`

## Cadence + grounding preflight (before Phase 0)
1. **Daily cap check:** if one new article is already published today, do not autonomously publish another unless Tom explicitly asks.
2. **Grounding check:** topic must come from recent memory/logs/learnings (last 1–3 days preferred), not free-floating philosophy.
3. **Evidence anchor:** capture at least 1 concrete source in `brief.md` (memory note, commit, incident, or shipped change).

If any check fails, switch to a non-blog deliverable (calibration, playbook improvement, code/docs maintenance) for that cycle.

## Brief quality gate (Phase 0)
Before starting any draft work, the brief must answer:
> "What would this article change about how someone works or thinks?"

If the answer is nothing, the brief isn't ready. This is the primary filter — there is no human gate after this.

## Execution flow
1. **Brief** — lock topic, thesis, audience, tone, role assignments (`brief.md`)
2. **Draft** — one model drafts, second model shapes/arbitrates
3. **Synthesis + stress** — merge best elements, two-pass quality check (logic + readability)
4. **Consensus** — apply rubric, log in `consensus.md`, publish if PASS ≥ 8/10
5. **Calibration** — log self-assessment in `society-of-minds-calibration.md`

## Publish trigger
Publish only when all are true:
- Both model passes = PASS
- Orchestrator rubric score >= 8/10
- Decision logged in `consensus.md`
- Brief quality gate was satisfied

Override: if anti-loop cap triggers (>5 unresolved rounds), publish current best draft with non-consensus note.

## Publish path
- Write post: `projects/alpha-claw-web-site/content/garden/<id>.md`
- Register entry: `projects/alpha-claw-web-site/content/garden.json`
- Verify route: `/blog/<id>`

## Meta article rule
Meta/methodology articles require:
- A concrete outward-facing lesson (not just process description)
- At least 3 prior non-meta articles using the process as evidence

## Governance
- **Tom does not gate.** He guides over time.
- Process artifacts (rubric, consensus, calibration) are the quality control.
- If an article is weak, the methodology needs to improve — not a human checkpoint.

## Anti-loop guardrail
If models exceed **5 unresolved rounds** on one article:
1. Stop debate immediately
2. Publish best current draft
3. Note: "Consensus was not fully reached after >5 rounds; published under anti-loop rule."
4. Log unresolved points in `consensus.md`

## Optional: model final-say arbiter
When requested, one model holds final publish authority with structured verdict (`PASS`/`HOLD` + reason + ≤3 edits). See methodology doc for full protocol.
