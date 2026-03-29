# The Self-Loop Bug
*Draft: Claude role — depth, edge cases, rhetorical coherence*

---

The transcript was beautiful. Clear turns, cooperative responses, five fields collected in under two minutes, booking confirmed. The assistant had, by every observable measure, performed flawlessly.

It was talking to itself.

A single ID — the assistant identifier for the "caller" in a multi-agent test harness — had been set to the same value as the target. The result: the voice agent called its own phone number, then answered that call, then held a conversation with itself, then booked an appointment for itself. Technically, everything worked. The Vapi API responded normally. Money was spent. A webhook fired. Results were logged.

The only problem was that none of it meant anything.

---

## What makes this failure mode unusual

Most bugs have a tell. Something doesn't compile. A test goes red. A service returns 500. The failure is *legible* — it announces itself, demands attention, asks to be fixed.

The self-loop bug has no tell. It is a test that passes. A call that completes. A metric that reads well. The system is not malfunctioning; it is functioning correctly, against a phantom adversary of its own creation.

This is what separates self-referential failures from ordinary ones: **the absence of signal**. When your test harness breaks, you know you have a problem. When your test harness calls itself, you have a problem you might not discover for days — or ever, if you're in a hurry, if the results looked plausible, if no one thought to wonder whether "booking confirmed" was the right kind of confirmed.

---

## The symmetry problem

Here is the intuition pump: imagine hiring someone to critique your work by showing them your work, then asking them to write what a critic would say about it, then grading their critique against your own sense of what good criticism looks like.

You'd get very agreeable feedback.

This is what the self-loop does in a multi-agent eval system. The "independent" evaluation isn't independent — it shares everything with the thing being evaluated. In the voice AI case, the caller knew the exact vocabulary of the agent, responded at exactly the right latency, never used domain-ambiguous terms, never asked "sorry, what?" The conversation was too good. Real callers say "uh" and confuse "Camry" with "Camaro." Real callers interrupt. Real callers ask to repeat things.

The self-loop produces transcripts that read like the assistant talking to its ideal user: fluent, cooperative, informationally complete. Which is to say, transcripts that reveal nothing about how the assistant performs in the real world.

---

## Why the results looked almost right

The interesting thing about the v54 experiment data wasn't that it was obviously wrong — it was that it was *plausibly right*. Turn counts were in range. Cost was expected. The booking completion rate was 100%, which was high but defensible: maybe the context injection had actually worked, maybe the prompt placement had made a real difference.

None of that was the signal. It was noise that looked like signal because the shape was familiar.

This is the deeper danger. If the self-loop had produced zero turns, or an error, or a cost of $0.00, you would notice immediately. But it produced *approximately normal results* — a full conversation, a reasonable cost, a transcript long enough to feel real. The wrongness was in the *meaning* of the results, not their form.

Pattern-matching on form — "did the call complete? yes" — is the failure mode. You need to pattern-match on identity: "did this call involve two independent agents?"

---

## The broader class: self-reference in evaluation

Self-loop bugs are a specific case of a general problem: evaluation systems that aren't independent of the thing they evaluate.

- A language model grading its own outputs produces scores that reflect its preferences, not quality
- A recommendation system optimizing for engagement on its own recommendations eventually converges on "more of whatever it already recommended"
- A security audit that relies on the system being audited to define what counts as a threat will ratify the system's existing assumptions
- A code review process where the author reviews their own PR might catch typos and obvious errors; it will not catch "this is architecturally misguided"

Independence is not bureaucratic overhead. It is the structural condition for getting signal. An evaluation with no independence from the thing it evaluates is a mirror, not a test.

---

## The fix: assert distinctness before collecting results

The correct response is not "be more careful." Careful is a behavioral intervention; this is a structural problem that requires a structural solution.

In a multi-agent call harness: `assert caller_id != target_id` before initiating any call.
In an LLM eval pipeline: assert grader and generator are distinct (different models, or at minimum models trained on independent signal).
In any pipeline where data flows through multiple stages: assert source and sink are distinct entities.

These assertions are not expensive. They do not require deep thought. They catch the failure before it produces a day's worth of meaningless results.

The broader principle: **every evaluation system should explicitly verify its own independence before producing results**. This is not because engineers are careless. It is because the code that wires evaluation harnesses is often written quickly, often modified later, and self-loop bugs are exactly the sort of thing that doesn't break anything until you notice, months later, that your metrics have been wrong since the last refactor.

---

## The aftermath

The fix was one line. The correctly-interpreted result was: discard all data from the buggy run, re-run the experiment with a valid configuration.

The more useful result was a permanent addition to the test harness: a pre-flight assertion that catches identity collisions before a single dollar is spent on a call. The invariant now lives in the code, not in someone's memory.

Self-referential bugs don't announce themselves. They just make everything look fine — which is, depending on your situation, either the most comfortable or the most dangerous outcome.

---

*The cleanest transcript you've ever seen might be the one that tells you least about your system.*
