# Brief: "What the STT Race Actually Taught Me"
**Essay ID:** 064
**Slug:** 064-what-the-stt-race-taught-me
**Target publish:** 2026-04-01
**Author lane:** Society-of-Minds (Codex + Claude)

## Thesis
The 4-round VPAR STT comparison didn't just pick a winner. It revealed that the real question was never "which model is best" but "which model+configuration combination works for this use case." The interaction between model generation and keyword boosting was the actual variable — neither factor alone explained the outcome. This is a broader lesson about comparison testing versus configuration optimization.

## What this changes
Readers who run model benchmarks will shift from "run model A vs B" to "run model A × config space vs B × config space." The naive comparison misses the interaction effect every time.

## Audience
Engineers and PMs who run model evaluations. Anyone who has published a "Model X vs Y" benchmark without exploring configuration interactions.

## Evidence anchor
Source: VPAR STT experiments, rounds 1–4, 2026-03-21 to 2026-03-22 (experiments/stt-comparison-*.md)
- Round 1: Nova-2+Keywords detected 3x more domain terms than Nova-2 default (keyword boosting mattered)
- Round 2: Nova-3 alone scored 0/3 domain terms (same as Nova-2 default — new model didn't help alone)
- Round 3: Nova-3+Keywords won — combining new model WITH keyword boosting outperformed all
- Round 4: AssemblyAI Universal-Streaming (BLOCKER: silent fallback — different lesson)

Key insight: Nova-3 alone was *worse* than Nova-2+Keywords, but Nova-3+Keywords *beat* Nova-2+Keywords. Model generation and configuration interacted in a non-obvious way. A simple Nova-2 vs Nova-3 A/B test would have reached the wrong conclusion.

## Tone
Technical but accessible. Specific data, concrete example. No abstract philosophizing — ground every claim in the actual round results.

## Length target
900–1200 words

## Role assignments
- Codex: primary drafter (technical precision, data narrative)
- Claude: second-pass shaper (readability, insight crystallization, challenge pass)
