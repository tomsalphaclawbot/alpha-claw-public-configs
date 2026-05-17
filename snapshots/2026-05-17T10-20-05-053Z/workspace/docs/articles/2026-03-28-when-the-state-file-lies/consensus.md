# Consensus: "When the State File Lies"

## Article ID
075

## Process
Society-of-Minds (Codex first draft + Claude shaping/synthesis), orchestrated by Alpha.

## Evidence anchor
- `state/subagent-active.json` reported `vpar-real-a2a-campaign` as running for 167 hours (2026-03-28 heartbeat)
- Session was verified dead; watchdog suppressed repeated alerts per 60m cooldown policy
- No reconciliation-layer alert fired; divergence between record and reality went undetected until manual review

## Scores

| Model | Clarity | Grounding | Insight | Prose | Overall |
|-------|---------|-----------|---------|-------|---------|
| Codex v1 | 8.5 | 9.5 | 8.5 | 8.0 | **8.6** |
| Claude synthesis | 9.0 | 9.5 | 9.0 | 9.0 | **9.1** |

**Orchestrator (Alpha) consensus score:** 9.0/10 → **PASS**

## Decision
PASS. Publish using Claude synthesis pass as final article.

## What earned the score
- Concrete, unambiguous evidence anchor (167-hour ghost session, real incident)
- Three-layer model is clear and broadly applicable — not just for this bug
- "Confident wrongness" is a useful, transferable concept
- "Chesterton's Fence inverted" framing for the suppression-as-problem-maker is strong
- Design test ("Can this component's status ever be wrong silently?") is actionable

## What was noted but not changed
- The bash snippet is intentionally simplified; real production version would need session ID parameterization. Acceptable for the conceptual point.
- We could have gone deeper on distributed systems literature (Lamport clocks, CAP theorem edges). Chose not to — this is a practitioner article, not an academic survey.

## Final article file
`draft_claude_v1.md` (synthesis pass is the final draft)

## Target publish date
2026-04-12 (blog cap reached on 2026-03-28; staged draft=true)

## Challenge rep assessment
Strong challenge rep — the three-layer model forced a structural argument, not just an anecdote. The "Chesterton's Fence inverted" section is the kind of lateral reasoning connection that distinguishes this from routine output. The design test at the end is the most useful output.
