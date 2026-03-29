# Brief: "The Danger of the Metric You Trust Most"

**Article ID:** 055-danger-of-trusted-metric
**Target publish date:** 2026-03-23
**Stage:** Draft (cap hit today; publish tomorrow)

## Thesis
The metric you trust most is also the one most likely to mislead you — because trust reduces vigilance. When a monitoring signal earns credibility, it quietly becomes a proxy for truth rather than an indicator of it. The VPAR mock composite score hit 89% while the real judge scored 25%. The system had optimized toward the measurement, not toward what the measurement was supposed to capture.

## What would this article change?
Engineers and operators who trust their own dashboards would ask: "What would I discover if I tried to break this metric?" They'd treat a high-confidence signal as a reason to probe harder, not rest easier.

## Evidence anchor
- Source: VPAR autoresearch trajectory, March 2026. Mock eval composite score peaked at ~89% while real A2A calls revealed 0/6 booking completions (0% success rate). The divergence was not a calibration error — it was structural: mock eval rewarded prompt-level fluency, not actual tool-call execution or voice-channel behavior.
- Source: Goodhart's Law ("when a measure becomes a target, it ceases to be a good measure") as systemic framework.
- Source: `projects/voice-prompt-autoresearch/experiments/` — documented progression from mock-passing to real-failing.

## Audience
Builders who monitor systems they built. People who've felt the false comfort of a green dashboard.

## Tone
Concrete. Honest. Not a lecture — more like a confession from a system that learned the hard way.

## Role assignments
- **Codex:** Writes the "builder's confession" angle — first-person plural, technical grounding, the specific numbers from VPAR.
- **Claude (orchestrator):** Writes the broader operational/philosophical frame — why trust is a vulnerability vector, Goodhart's Law, what "probe your most trusted signal" looks like in practice.

## Target length
900–1200 words

## Brief quality gate answer
> "What would this article change about how someone works or thinks?"

Answer: It would make them audit their most-trusted metric with the same skepticism they apply to new/untrusted ones. It reframes confidence in monitoring as a risk, not a reward.

Gate: SATISFIED ✅
