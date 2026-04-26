# Fast Is Not Default

A benchmark can tell the truth and still mislead your product decision.

We hit that exact edge in the OmniParser spike for VNC click targeting.

On rerun, OmniParser v2 posted a **0.033s median latency**. Florence2, our current default, was **0.583s**. If you only read the summary row, the conclusion is obvious: swap defaults.

We did not swap defaults.

That was the right call.

## What the spike actually measured

Same fixture, same matrix shape, 10 total cases (8 positive, 2 negative):

- **Florence2**: recall **1.000**, specificity **1.000**, median latency **0.583s**.
- **OmniParser v2 (pass 2)**: recall **0.750**, specificity **1.000**, median latency **0.033s**.

Those are real numbers. The trap is pretending they describe one homogeneous workload.

They do not.

The row-level data shows OmniParser’s first parse on a new image took **12.706s** (`cache_hit=0`). After that, repeated queries were near-zero because the parser reused the same detected boxes (`cache_hit=1`).

So the headline median came from a mixed workload where expensive cold parse got amortized by cheap repeated lookup.

That is a valid use case. It is just not our default loop.

## Why the default stayed Florence

Default routing is not about what can be made fast in a favorable sequence. It is about what fails least under typical traffic.

Our typical control loop is still mostly one-shot:

1. capture screenshot,
2. ask one target query,
3. click,
4. capture again.

In that loop, cold-start behavior matters more than warm-cache medians.

And reliability matters most. OmniParser still missed 2 of 8 positive targets in this run shape (recall 0.750). Florence did not miss positives on this fixture (recall 1.000).

A backend that misses one in four positives is not ready to be default for click grounding, even if its warm path can be blazing fast.

## The decision boundary we used

We merged OmniParser as **available, opt-in**, not default (`a1f60d7`).

That split is intentional:

- **Default lane (Florence2):** stable recall + predictable latency.
- **Experimental lane (OmniParser):** parse-once/query-many scenarios where cache reuse is guaranteed and explicit.

This is not anti-innovation. It is anti-self-deception.

## The counterargument, and why it is still valuable

A fair pushback is: “If OmniParser is effectively instant after first parse, shouldn’t we redesign the loop around that model?”

Maybe, yes. But that is a different product move.

Switching default backend is one decision.
Redesigning interaction flow to exploit parse reuse is another.

If we want the second, we should do it explicitly:

- pre-parse on frame capture,
- keep parser state bound to frame hash,
- serve multiple target queries against one parse result,
- invalidate cache only on frame change.

Then benchmark that architecture against the same reliability gates.

Until then, using a parse-cache benchmark median to justify a default swap is category error.

## A practical rule you can steal

When choosing a default vision backend, gate in this order:

1. **Recall floor:** does it meet your minimum positive-hit rate?
2. **Cold vs warm split:** report them separately, always.
3. **Failure shape:** where does it miss (which UI classes and labels)?
4. **Workload fit:** is your real traffic one-shot or parse-once/query-many?

Only after those pass should median latency decide anything.

## Why this article exists

A lot of teams ship the model with the prettiest benchmark row, then spend two months debugging “random” misses that were visible on day one.

The benchmark is not the decision. The benchmark is evidence for a decision boundary.

For us, that boundary was clear:

- OmniParser earned its place as an option.
- Florence kept default ownership.

That is what meaningful progress looks like in agent systems. Not “new model everywhere,” but “new model exactly where its strengths are real.”
