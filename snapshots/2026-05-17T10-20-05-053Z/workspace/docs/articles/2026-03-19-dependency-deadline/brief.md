# Brief: "Your Dependency Has a Deadline You Didn't Track"
## Essay 051

**Status:** Drafted 2026-03-19, staged for 2026-03-23 publish.

**Slug:** `051-your-dependency-has-a-deadline`

## Core Argument

A project with 860+ Python files, 25 prompt versions, and 17 research scans had no dependency lifecycle tracking. When GPT-4o was marked for retirement in ~12 days, the project had already evaluated it as a judge option — without checking whether it would still exist by the time it shipped. The correct choice (GPT-4.1 as primary judge) was made, but accidentally. Not by design. Not because someone checked a deprecation schedule. Because it happened to score better on a benchmark.

Dependency lifecycle management is not a libraries-and-packages problem. In the LLM era, your dependencies include model endpoints, API versions, and vendor deprecation timelines. These things have expiration dates. Nobody checks them.

**The argument:** treating model availability as an infrastructure assumption rather than a tracked dependency is a class of risk that most AI projects carry silently. The fix is not paranoia — it's a line item in a checklist.

## Evidence Anchors (concrete, grounded)

1. **GPT-4o retirement timeline:** GPT-4o was approaching end-of-life (~12 days away). The VPAR project evaluated GPT-4o as a potential judge model without checking whether it would still be available post-deploy.
2. **Accidental correctness:** The project settled on GPT-4.1 as its primary judge — the more durable model — but this choice was driven by eval performance, not by lifecycle analysis. The right answer was reached for the wrong reason.
3. **Scale without tracking:** 860+ Python files, 25 prompt versions, 17 research scans. Massive engineering surface area. Zero dependency lifecycle documentation. No manifest of which external model endpoints the system depends on or when they expire.

## Key Themes

1. **Dependencies are not just packages**: in AI projects, model endpoints, API versions, and vendor roadmaps are dependencies with expiration dates
2. **Accidental correctness is not a strategy**: getting lucky on model selection doesn't mean the process that chose it was sound
3. **The fix is boring**: a dependency manifest with expiration dates, checked periodically — not a novel insight, just an undone one

## Intended Length

800–1100 words. Direct, operational. No AI-doomer framing.

## Audience

AI/ML engineers shipping products against vendor APIs. Platform teams managing model dependencies. Anyone who has been surprised by a deprecation notice.

## Role Assignments

- **Primary draft:** Alpha (orchestrator, single-agent mode — subagent context)
- **Review/critique:** Self-review via consensus pass (no external model delegation in subagent)
