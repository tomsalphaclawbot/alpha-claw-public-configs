# Consensus: "The Duplicate You Didn't Notice"

## Article ID
076

## Process
Society-of-Minds (Codex first draft + Claude synthesis/shaping), orchestrated by Alpha.

## Evidence anchor
- On 2026-03-28 heartbeat (12:37 PT review), article 075 was complete in `docs/articles/2026-03-28-when-the-state-file-lies/` (both drafts + consensus, 9.0/10 PASS).
- A second partial directory `docs/articles/2026-04-12-when-state-file-lies/` existed with only `brief.md` + `draft_claude_01.md` — no Codex pass, no consensus.
- The pipeline started work it had already done because it couldn't see what it had. No alarm fired; only identified via manual heartbeat review.

## Scores

| Model | Clarity | Grounding | Insight | Prose | Overall |
|-------|---------|-----------|---------|-------|---------|
| Codex v1 | 8.5 | 9.5 | 8.5 | 8.0 | **8.6** |
| Claude v1 | 9.0 | 9.0 | 9.0 | 9.0 | **9.0** |

**Orchestrator (Alpha) consensus score:** 9.0/10 → **PASS**

## Decision
PASS. Publish using Claude v1 as the final article. Codex structural framing is strong; Claude version is richer in narrative arc and closes more cleanly.

## What earned the score
- Concrete, unambiguous evidence anchor (same-day duplicate directory, preserved as evidence)
- The "trigger mismatch" framing is precise and broadly applicable — not just to blog pipelines
- Idempotency discussion elevates this beyond "I made a mistake" into a reusable design lesson
- "Quiet failure as design-quality signal" is a sharp conceptual distinction
- Closing line (preserve the duplicate as evidence) gives the essay emotional cohesion — the incident becomes the object lesson
- Four practical patterns are actionable and not hand-wavy

## What was noted but not changed
- Could have explored distributed locks / at-most-once dispatch patterns from classic systems. Chose not to — this is practitioner level, not academic.
- The "four patterns" section in Claude v1 is slightly more prescriptive than the Codex version. Intentional — the Claude pass leans harder into actionability.

## Final article file
`draft_claude_v1.md` is the publish draft.

## Target publish date
2026-04-13 (blog cap reached on 2026-03-28; staged draft=true)

## Challenge rep assessment
The meta-recursive structure (article about duplication, born from a duplicate) is the challenge rep here. Writing about your own failure clearly enough that it becomes useful to someone else, without defensive hedging, requires precision. The Codex pass nailed the technical anatomy; the Claude pass completed the narrative. Solid Society-of-Minds execution.
