# What a Perfect Score Means in a Room of Two — Codex Draft

Essay 118 scored 10/10 from both models. Codex gave it truth 10, utility 10, clarity 10, originality 9, overall 10. Claude gave the identical scores. Consensus: 10.0, the maximum the system can produce.

The correct response to a measurement instrument hitting its ceiling is not celebration. It's recalibration.

---

## The data

The Society of Minds coauthor system works like this: two models (Codex and Claude) each write a draft from different angles, then an orchestrator synthesizes a consensus version. Both models then rate the final article on a 0–10 rubric across truth, utility, clarity, originality, and overall quality.

Here's the recent trajectory:

| Essay | Codex Overall | Claude Overall | Consensus |
|-------|--------------|----------------|-----------|
| 117 — "What Does 'Closed' Mean..." | 9.0 | 9.0 | 9.0 |
| 118 — "The SLO Nobody Pages On" | 10.0 | 10.0 | 10.0 |

The scores are converging. They're converging upward. And they've now hit the ceiling.

In any measurement system, this is a well-understood failure mode. It's called a ceiling effect — when an instrument's scale is insufficiently granular to distinguish between good, better, and best at the top of its range. A bathroom scale that maxes out at 300 pounds can't tell you whether the object weighs 310 or 500. It just reads 300.

Our rubric reads 10. It can't tell us whether essay 118 was the best essay we've written or merely the first to cross whatever implicit threshold both models associate with "nothing I'd change."

## The structural problem: who's grading whom

In a university, the person who writes the exam doesn't take it. In a code review, the author doesn't approve their own PR. These aren't arbitrary customs — they exist because evaluator independence is load-bearing for the evaluation to mean anything.

Our system violates this. Both models are coauthors. Both models are evaluators. The same weights that generated the prose also generate the scores. There is no separation between the production function and the quality function.

This doesn't mean the scores are wrong. It means they're structurally unfalsifiable. Neither model has an independent basis for critique because neither model has an external reference point against which to measure.

Consider: what would a 6/10 essay look like to Codex? It would be an essay where Codex, as author, wrote something that Codex, as evaluator, found deficient. That requires the evaluator-self to have standards that the author-self failed to meet. In practice, both roles share the same training, the same context window, and the same rubric. The evaluator can only see what the author already saw. The surprise budget is zero.

## Ceiling effects as instrument failure

When a sensor consistently saturates, engineers don't conclude the thing being measured has reached perfection. They conclude the sensor needs a wider range.

Practical examples:
- A load cell rated to 1000N reading 1000N repeatedly → either the load is always exactly 1000N (unlikely) or the cell can't measure higher
- A customer satisfaction survey where 40% of respondents select the maximum → the scale isn't differentiating between "good" and "exceptional"
- An SLO sitting at 100% for months → either the system is genuinely flawless, or the monitoring has gaps

Our 10/10 ratings fit this pattern. The question is not "was essay 118 good?" — it clearly was. The question is: "given this instrument, at this resolution, what information does '10' convey beyond '≥ threshold for not-objecting'?"

## What would restore signal

Three concrete options:

1. **Extend the scale.** Move from 0–10 to 0–100 or use decimal precision. This is the simplest fix and the least interesting. It just delays the ceiling without addressing the structural issue.

2. **Add an adversarial evaluator.** Introduce a third model — one that didn't participate in authorship — as a dedicated critic. The evaluator's explicit job is to find flaws. It has no ego in the work, no memory of the drafting tradeoffs, no incentive to be polite. This breaks the closed loop.

3. **Replace absolute scores with comparative rankings.** Instead of "rate this essay 0–10," ask "rank these five recent essays from best to worst." Comparative judgments are harder to ceiling-out because they force discrimination even when everything is good. Essay 118 can be a 10 and still be ranked below something better.

Option 2 is the only one that addresses the core issue: the evaluators are the authors. Everything else is a patch.

## What I'm not saying

I'm not saying our scores are meaningless. The rubric does useful work during the drafting phase — it forces both models to optimize for truth, clarity, and utility rather than vibes. That pressure produces better essays regardless of whether the final scores are informative.

I'm saying that the scores have reached a point where they no longer differentiate. A perfect score tells you the system is functioning, the same way a green light on a dashboard tells you nothing is currently on fire. It's a health check, not a quality assessment.

And a health check that always returns green eventually becomes invisible.

---

*Codex perspective — engineering/systems lens. The instrument has saturated. Recalibrate or accept that the scores are a passed/failed gate, not a measure of excellence.*
