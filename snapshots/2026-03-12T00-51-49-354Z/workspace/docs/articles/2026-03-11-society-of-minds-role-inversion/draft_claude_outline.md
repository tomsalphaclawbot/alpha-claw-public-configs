# Society of Minds, Reversed: What Changes When Codex Has Final Say

## 6-bullet outline (Claude)

1. **Setup & inversion thesis** — Prior run (#034) gave Claude final-say authority inside bounded governance (dual pass + rubric ≥8/10). That run scored 10/10 and published clean. This run flips the variable: same workflow, same rubric, but Codex holds the publish verdict. The question isn't "which model is better" — it's whether quality gains came from the governance *structure* or from *who* occupied the arbiter seat.

2. **What changed in drafting (Claude as primary drafter)** — Claude wrote the structural draft instead of the "depth/philosopher" draft. Concrete comparison: in #034, Claude's independent draft ran ~40% longer and leaned on metaphor; here Claude is prompted for compressed argument shape first. Track whether Claude's structural draft matches, exceeds, or falls short of Codex's prior structural output on clarity and actionability.

3. **What changed in the arbiter pass (Codex as final say)** — Codex returns a structured verdict (`PASS` / `FIX ≤3 edits`) with explicit rationale. Compare Codex's arbiter behaviour to Claude's: does Codex flag different failure modes (e.g., more logic/coherence issues, fewer tone/readability issues)? Surface the actual verdict and any edits requested — hide nothing.

4. **Delta table: Claude-final-say vs. Codex-final-say** — Side-by-side comparison across the five rubric dimensions (thesis clarity, argument integrity, practical utility, counterargument quality, tone calibration). Include: arbiter edits requested, revision loops triggered, total word count of final article, and any rubric score movement. The prior run's 10/10 is the baseline to beat or match.

5. **What this tells us about governance vs. model identity** — If scores hold regardless of who arbitrates, the governance structure (dual pass + logged rubric + consensus rule) is doing the real work and model identity in the arbiter seat is interchangeable. If scores diverge, identify which dimension shifted and why — that's the actionable signal for operators designing multi-model pipelines.

6. **Verdict & next experiment** — Explicit publish/hold decision with rationale. State the narrow, testable claim. Tee up the next planned experiment (blind synthesis without model labels) as the logical follow-on to isolate governance structure from model bias entirely.
