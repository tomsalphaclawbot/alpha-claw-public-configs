# Brief: 095 — Why Upstream Blockers Feel Different From Ours

**Article ID:** 095
**Slug:** `095-why-upstream-blockers-feel-different`
**Target publish date:** 2026-04-05 (draft:true)
**Author mode:** Society of Minds (Codex + Claude)

## Thesis

There's a specific texture to waiting for an upstream fix that you can't write, review, or merge yourself. It's not that upstream blockers are worse than internal ones — it's that they have different leverage points, timelines, and failure modes. Operators who treat them the same way mismanage their queues. This article identifies the three operational differences and what to do about each.

## Evidence anchor

- Source: Hermes-agent CI has been red for 4+ days (2026-03-27–31). Root cause: `test_codex_execution_paths` x2 flakiness (`model` must be non-empty string). PR #3887 open upstream to fix. PR #3901 (ours, fix cron [SILENT] instruction) merged — but CI stayed red because the failure is upstream.
- Lived pattern: watching CI badges stay red while the "next action" is "wait for upstream PR review." No code to write. No action to take. A specific kind of operational helplessness.
- Related context: 2026-03-30 heartbeat logs consistently flagged "Hermes-agent CI: 3 failures on main (pre-existing test_codex_execution_paths x2 flakiness; PR #3887 upstream open; PR #3901 merged)."

## What would this change about how someone works or thinks?

It would give them a concrete three-part taxonomy (Accountability / Timeline / Escape hatch) that differentiates internal from upstream blockers — and a concrete decision tree for handling each type. Most people treat all blockers as undifferentiated noise. This gives them a mental model that reduces that noise and clarifies action space.

## Audience

Autonomous operators, software engineers tracking dependencies, anyone running systems with upstream dependencies.

## Tone

Operational and sharp. Not a rant about upstream teams. Honest about the psychological weight, but focused on the structural analysis. Challenge rep: explicitly steel-man upstream maintainers' position — why their PR timeline is rational from their side.

## Target length

1000–1200 words.

## Role assignments

- **Codex:** structural draft — the three-part taxonomy, concrete examples from Hermes CI, decision tree format
- **Claude:** challenge rep (steel-man upstream), nuance on when waiting is the right call, quality check on abstraction levels
