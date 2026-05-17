# Brief: "The Publish Date That Was Yesterday"

**Essay ID:** 107  
**Working title:** The Publish Date That Was Yesterday  
**Target publish date:** 2026-04-02 (LA time, i.e., after midnight PT)  
**Article dir:** `docs/articles/[REDACTED_PHONE]-publish-date-was-yesterday/`

## Evidence anchor (real event, live now)

Essay 101 (`101-the-ci-that-nobody-owns`) has `publishDate: 2026-04-02` in `garden.json`.  
As of [REDACTED_PHONE]:37 PDT ([REDACTED_PHONE]:37 UTC), the blog publish guard correctly reports:
- `date: "2026-04-01"` (LA clock, not UTC)
- `allowed: false`
- `reason: daily_cap_reached` (090 already published today)

The guard will allow it after midnight LA time — approximately 90 minutes from now.

But here's the friction: the publish date was already in the past (in UTC) when the guard blocked it. The system had no explicit timezone contract on what "publishDate: 2026-04-02" means. It happened to work correctly (guard uses LA, Tom is LA-based), but the contract is implicit.

## Core argument

Scheduled-publish systems need explicit timezone contracts, not just dates. A bare date string (`2026-04-02`) carries no timezone information. Systems that consume it must pick a timezone — and that choice is usually invisible until something breaks at a boundary.

The deeper point: when "correct" behavior depends on an implicit assumption (LA = author TZ = system TZ), the system has a latent bug even if it never fires. The publish date was already yesterday in one valid reading of time. The guard was right. But was it right for the right reasons?

## Target length

~600–800 words. Concise and precise — this is a craft essay about operational edge cases, not a philosophy piece.

## Coauthor instructions

- Codex draft: focus on the mechanics — what the guard does, what the contract gap is, concrete fix proposal
- Claude draft: focus on the epistemic angle — what "correct by accident" means for system trust, when implicit contracts are acceptable vs. dangerous
- Consensus: neither pure mechanics nor pure philosophy — weave them together
- Both must rate with numeric score before publish gate can run

## Acceptance criteria

- Brief + draft_codex + draft_claude + consensus + article_final
- Dual-rated ≥ 7.5/10 both models
- `blog-quality-gate.py` must return `allowed: true`
