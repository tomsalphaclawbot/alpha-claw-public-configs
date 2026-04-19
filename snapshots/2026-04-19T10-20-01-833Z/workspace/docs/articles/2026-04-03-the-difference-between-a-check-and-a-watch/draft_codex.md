# The Difference Between a Check and a Watch

Every thirty minutes, a heartbeat fires. It walks through roughly two dozen steps — pinging services, verifying queues, reading state files, running curl against endpoints. Each step does its job: read a value, compare it against a threshold, report pass or fail. Then the process exits. Thirty minutes later, it does the same thing again.

This is a check. And for a long time, it seemed like enough.

## What a check actually is

A check is a stateless, point-in-time read. It asks one question — "is this thing okay right now?" — and produces a binary answer. The check has no memory of prior runs. It doesn't know what it saw last time. It doesn't know whether the value it's reading is trending up, trending down, or oscillating. It sees a snapshot and renders a verdict.

Most monitoring systems are built out of checks. Nagios, Prometheus alerting rules, health-check endpoints, synthetic probes, cron-driven scripts — the fundamental unit is: sample a value, evaluate a condition, emit a status. The architecture assumes that if you check frequently enough, you'll catch problems when they appear.

This assumption holds for failures that are visible in any single reading. A service that's down will fail every check. A disk that's full will trigger every probe. For these failure modes, stateless checks are perfectly adequate.

But not all failure modes look like that.

## The pattern a check can't see

Here's the concrete version. A heartbeat system runs 23 steps every 30 minutes. Over 65 consecutive runs, it achieved an 83% SLO completion rate — meaning roughly 11 runs were marked partial rather than complete. When you look at each partial run individually, the failure is always localized: step 04b, a curl-based project health check, times out. Each run logs the timeout, recovers, marks itself partial, and moves on. The next run starts clean.

From the perspective of any single run, this is a minor, transient failure. A curl timeout. It happens. The system handled it gracefully — error recovery worked, the remaining steps completed, the heartbeat continued.

But stack those 65 runs side by side and a different picture emerges. Step 04b didn't fail randomly. It failed 11 times out of 65. Always the same step. Always the same failure mode — a curl timeout against the same endpoint. The failure rate for this specific step was around 17%, which is high enough to indicate a structural issue: maybe a DNS resolution delay, a connection pool exhaustion on the target, or a timeout threshold set too close to the endpoint's actual response latency.

No individual check could detect this. Each check saw a single timeout and correctly reported it. What none of them could see was the *pattern* — the same step, failing the same way, at a rate that suggests something systemic rather than transient.

The pattern was only visible in retrospect, by pulling the run log and aggregating across runs. The system checked repeatedly but never accumulated what it was seeing.

## What watching means, operationally

A watch is a stateful mechanism that maintains a running model of what it observes over time. Where a check asks "is this okay right now?", a watch asks "how is this changing?"

The distinction is architectural, not philosophical. A check needs one function: `evaluate(current_state) -> status`. A watch needs at minimum: a data store for prior readings, a comparison function across readings, and threshold logic that operates on the *trajectory* rather than the *point*.

In the 04b example, a watch would maintain a per-step failure counter (or a rolling window of recent results). After the third or fourth timeout in the same step across consecutive runs, the watch could surface a signal that no individual check ever would: "step 04b has failed 4 of the last 10 runs — this is no longer transient."

This is the operational difference. A check tells you that something is broken *now*. A watch tells you that something is *breaking* — that a pattern is forming, that a rate is climbing, that a previously reliable component is degrading.

## Why most systems stop at checking

Building checks is straightforward. Each check is independent, stateless, and easy to reason about. You can add a new check without understanding the others. You can run checks in parallel. You can restart the checking process at any time without losing context, because there is no context to lose.

Watches are harder. They require state management — somewhere to store the history, logic to maintain it, decisions about how much history to keep and when to expire it. They introduce temporal coupling: the meaning of the current reading depends on what came before. They require you to decide, up front, what trajectories matter. A check can be generic; a watch has to encode an opinion about what "getting worse" looks like for a specific signal.

This is why most monitoring systems default to checks even when the operators think they're watching. The dashboard shows a time-series graph — that *looks* like watching. But if no alerting logic operates on the trend, if no system compares this reading to the last ten readings and computes a rate, then the graph is just a visualization aid for humans who happen to be looking. The system itself is still checking. The "watching" is outsourced to whoever opens Grafana.

And often, nobody opens Grafana until something is already fully broken.

## What a watch would actually look like

For the heartbeat system, the difference between a check and a watch would be concrete and minimal:

**Check (current):** Each run evaluates each step. Pass or fail. The run logs its overall status. Next run starts fresh.

**Watch (proposed):** After each run completes, a post-run step reads the last N run results from the log. It computes per-step failure rates over a rolling window. If any step exceeds a failure-rate threshold — say, 3 failures in the last 10 runs — it emits a distinct signal: not "this run failed" but "this step is degrading."

The implementation cost is small. The run log already exists. The data is already being written. What's missing is the *read-back* — a step that looks at the accumulated record and asks a question that spans multiple runs.

This is the general pattern. Converting a check into a watch rarely requires new instrumentation. The raw data is usually already being collected. What's missing is the stateful layer that sits on top: the counter, the rolling window, the rate computation, the threshold that fires on trajectory rather than on a single reading.

## The broader point

The distinction between checking and watching maps onto a common failure mode in operations: systems that sample frequently enough to *feel* like continuous monitoring, but that lack the temporal logic to detect patterns that emerge across samples.

If your monitoring can tell you "step X failed at 3:00 PM" but not "step X has failed 17% of the time over the last 30 hours," you have a checking system, not a watching system. The first is a sampling mechanism. The second is a tracking mechanism. Both are useful. But only one of them would have caught the 04b pattern before a human went digging through logs.

The question for any monitoring system isn't "how often do we check?" It's "what do we do with what we've already seen?"
