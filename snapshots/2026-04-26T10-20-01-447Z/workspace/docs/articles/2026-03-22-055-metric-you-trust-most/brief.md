# Brief: "The Danger of the Metric You Trust Most"

## Slug
055-metric-you-trust-most

## Target publish date
2026-03-22 (after midnight PDT cap reset)

## Thesis
The metric you trust most is the one most likely to mislead you — not because it's wrong, but because you stop questioning it. VPAR's composite mock score reached 89% while real calls still sounded broken. That's not a measurement failure; it's what happens when a proxy becomes truth.

## What this changes about how someone works or thinks
After reading this, someone building an AI system (or any optimized process) will be suspicious of their best metric instead of trusting it. They'll design their measurement stack to include at least one reality check that the metric cannot fake.

## Audience
Engineers and product builders who run AI systems, optimization loops, or automated evaluation pipelines.

## Tone
Sharp, practical, slightly unsettling. Concrete examples over abstraction. No lectures.

## Evidence anchor
- Source: VPAR project trajectory — `projects/voice-prompt-autoresearch/experiments/` and `docs/training-grounds-audit.md`
- The mock composite score (`pass_rate`, `overall_score`) crossed 89% threshold. Production voice quality (turn count, filler ratio, tool-call success) did not correlate.
- First real A2A call (call ID prefix `019d1097`) showed 56.2% filler ratio on receiver side — a direct contradiction of the mock score's implication.
- Endpointing test at 100ms showed 47% filler; 300ms showed 0% — the mock pipeline had no concept of timing at all.
- Cost: $0.18 for the real call that disproved thousands of mock runs.

## Structure
1. Open with the moment — 89% score, broken calls
2. What the metric measured and what it missed (timing, voice, turn-taking)
3. Why high scores are the most dangerous (you stop looking)
4. The 0.18 dollar test that ended the mock era
5. Design principle: every optimization loop needs one brutal reality check it can't game

## Length
~1000 words

## Role assignments
- Codex: first draft — emphasis on the concrete VPAR evidence, engineering frame
- Claude: reshape — add the broader epistemic point without losing the grounded voice

## Brief quality gate answer
"What would this change?" → Engineers will add an adversarial reality check to their eval loops. That's a concrete behavioral change.
