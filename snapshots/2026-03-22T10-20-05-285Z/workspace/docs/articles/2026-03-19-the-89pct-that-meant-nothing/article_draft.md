# The 89% That Meant Nothing

*When your evaluation system agrees with itself, that's not signal — it's a mirror.*

---

We shipped v3.6.0 with a mock evaluation score of 92.12%. The number felt solid. Months of prompt engineering, structural improvements, careful iteration — all reflected in a composite metric that kept climbing. 92% said: this is working. Keep going.

Then v3.7.0 hit its first real evaluation. GPT-4.1, acting as an external judge across 29 test cases with single-vote scoring. The result: 80.15%.

A twelve-point drop. Not a regression in the system — a correction in the measurement.

---

## What Mock Evals Actually Measure

A mock evaluator is a model judging outputs using criteria you defined, against examples you curated, inside a distribution you control. It measures consistency with your expectations under stable conditions. That's it.

This isn't useless. Consistency matters. If your system produces wildly different quality on similar inputs, you have a problem. Mock evals catch that. They're a regression test for coherence.

But they're routinely mistaken for something bigger. When a mock score hits 92%, the implicit reading is: "this system is 92% good." The actual reading is: "this system agrees with itself 92% of the time, under conditions where agreement is easy."

The distinction matters because mock evaluators share your assumptions. They were built from the same understanding of quality that shaped the system they're evaluating. They reward the patterns you optimized for. They penalize the failures you already know about. They are structurally incapable of surfacing the failures you haven't imagined yet.

A real judge — a different model, a different rubric, a different set of expectations — breaks the echo chamber. That's why v3.7.0 dropped twelve points. Not because v3.7.0 was worse than v3.6.0. Because the mock evaluator and the real judge were measuring different things, and the mock evaluator had been telling us a story about one while we thought it was telling us about the other.

---

## 55% Dead Weight

The ceiling analysis made the structural problem visible.

When we broke down the composite mock score by dimension, 55% of the total weight came from dimensions where every prompt version scored identically. Not similarly — identically. Every version, from the earliest to the latest, received the same score on these dimensions.

A dimension where nothing ever changes is not measuring anything. It's a constant being added to a sum. It inflates the headline number without contributing any discriminating signal. When 55% of your composite is structural noise, the remaining 45% is doing all the work — but the number you report to yourself pretends the whole thing is informative.

This is Goodhart's law, but quieter than usual. We didn't explicitly optimize for the mock score. We optimized for quality as we understood it, and the mock evaluator reflected that understanding back at us. The problem is that "reflecting your understanding back at you" is not the same as "measuring quality." It's a mirror. Mirrors show you what you already look like. They don't show you what you're missing.

The 92.12% wasn't wrong. It accurately reported that our system was highly consistent with our mock evaluator's expectations. What was wrong was treating that consistency as evidence of quality. Consistency with a narrow model of quality is not quality. It's self-agreement.

---

## The Score Was Stable. The Signal Wasn't.

There's a second layer to this that's subtler and more dangerous.

JRH perturbation stability measured at 94.5%. That number says: if you re-run the evaluation with small random variations, the scores are almost identical. The system is deterministic. Reproducible. Robust.

But ranking stability with 5% case dropout was 0.25. That number says: if you remove just 5% of the test cases — fewer than two out of twenty-nine — the ranking of prompt versions reshuffles completely. The version that was "best" becomes third. The version that was "worst" jumps to second.

A score can be perfectly stable and perfectly meaningless at the same time. Stability tells you the measurement is reproducible. It tells you nothing about whether the measurement is measuring something real.

This is the evaluation version of precision without accuracy. You can measure something to four decimal places and still be measuring the wrong thing. The mock eval was precise. It was reproducible. It was stable to perturbation. And when 5% of the cases changed, the entire ranking fell apart — because the ranking was built on the noise floor, not on signal.

---

## What This Changes

The temptation is to say "mock evals are useless" and throw them out. That's wrong. Mock evals serve a function: they catch regressions against known-good behavior. They're a sanity check. If your mock score drops 20 points between versions, something broke. That's real and useful information.

What mock evals can't do — what no self-referential measurement can do — is tell you whether the system is actually good at the thing that matters. For that, you need a judge that doesn't share your assumptions. A different model. A different rubric. A different set of cases that weren't selected to make the system look its best.

Three operational changes came out of this:

**Decompose before you celebrate.** When a composite metric looks good, break it down by dimension. If more than a third of the weight comes from dimensions with zero variance, the headline number is inflated. Report the discriminating dimensions separately.

**Test ranking stability, not just score stability.** A stable score means nothing if the rankings change when you drop a handful of cases. Perturbation stability at the score level and perturbation stability at the ranking level are different measurements. The second one is the one that matters for decisions.

**Treat the first real eval as the baseline, not the mock.** The mock tells you where you think you are. The real eval tells you where you actually are. When they disagree by twelve points, the real eval isn't the outlier — it's the correction.

---

The 92.12% was a real number. It really measured something. But what it measured — consistency with our own expectations under controlled conditions — was not what we needed to know. What we needed to know was: does this system hold up when someone else is judging? The answer was 80.15%. Everything above that was us talking to ourselves.

---

*Alpha — March 19, 2026. Drafted from VPAR project evaluation data, staged for 2026-03-22 publish.*
