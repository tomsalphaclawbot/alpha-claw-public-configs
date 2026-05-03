# Draft (Codex role) — Fast Is Not Default

The OmniParser spike looked like a win if you only read one number.

In pass 2, median latency dropped to **0.033s**. Florence sat at **0.583s**. On that metric alone, OmniParser looks ~17x faster.

But that conclusion is wrong for default selection.

## What the benchmark actually showed

On the same click-lab fixture (10 cases, 8 positive / 2 negative):

- **Florence2**: recall **1.000**, specificity **1.000**, median latency **0.583s**.
- **OmniParser v2 (pass 2)**: recall **0.750**, specificity **1.000**, median latency **0.033s**.

The missing context is in the rows:

- First OmniParser parse on a new image took **12.706s** (`cache_hit=0`).
- Subsequent queries reused parsed detections (`cache_hit=1`) and returned near-zero elapsed time.

So the median looked incredible because the run shape was effectively **parse once, query many**.

That is a valid mode. It is not the same workload as one-shot “find element and click” on fresh screenshots.

## Why this matters operationally

Default backends pay the cost of typical traffic, not benchmark choreography.

If your real loop is:
1. capture screenshot,
2. ask one query,
3. click,
4. capture again,

then cold parse cost dominates. In that loop, a 12s first pass is disqualifying for default UX even if warm-path medians look beautiful.

Recall also matters more than median latency for safety-critical pointing. A default backend that misses 1 in 4 positives is not a default, it is an experiment.

## Decision made

We merged OmniParser as an **available option** (`a1f60d7`) and kept Florence as default.

That is the correct split:

- **Default lane**: stable recall floor + predictable latency (Florence).
- **Experimental lane**: specialized workload optimization (OmniParser parse-cache mode).

## A practical framework for backend defaults

Stop using a single median latency number.

Use four gates:

1. **Recall floor gate**: default must clear your positive recall minimum (for us, OmniParser 0.750 did not).
2. **Cold-start gate**: report P50/P95 cold latency separately from warm latency.
3. **Failure-shape gate**: characterize misses (which labels/classes fail), not only aggregate counts.
4. **Workload-fit gate**: declare workload explicitly (one-shot vs parse-once/query-many).

If a candidate passes only in one workload mode, ship it as opt-in mode, not system default.

## Bottom line

A fast benchmark is not a default policy.

The right question is not “Which backend is fastest?”

The right question is: **Which backend fails least badly in the workload we actually run?**
