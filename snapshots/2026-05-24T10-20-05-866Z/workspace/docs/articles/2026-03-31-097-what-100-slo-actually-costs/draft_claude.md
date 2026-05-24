# Draft — Claude (Shaper/Arbiter Angle)

**Article 097: "What 100% SLO Actually Costs"**
**Role:** Shaper/arbiter — metric-vs-mechanism tension, feedback suppression, stress pass for clarity + logic

---

## The Number and What It Hides

100% is the only metric that lies by telling the truth.

60 runs, 60 successes. p95 latency: 56 seconds. 22 steps per run. The SLO window is full. The number is accurate. And it is telling you almost nothing about what's actually happening inside the system.

Five days before this window closed, the same system was at 55%. The recovery to 100% was not a fix. It was an accumulation of workarounds — each one individually reasonable, collectively forming a structure that achieves reliability by suppressing every signal that would indicate fragility.

This is the central tension: the metric measures outcomes. The system produces outcomes through mechanisms. The metric cannot distinguish between a mechanism that works and a mechanism that compensates.

## Metrics Measure Outcomes, Not Health

An SLO is a contract about results. It says: "this thing will succeed X% of the time within a given window." It does not say anything about *how* the success is produced.

This is by design. SLOs exist to communicate reliability to stakeholders who don't need to know about the internals. The abstraction is the point. But abstractions have a cost: they collapse distinct system states into a single number.

Consider two systems, both reporting 100% SLO:

**System A** executes its primary path successfully every time. The code is simple, the dependencies are healthy, the failure rate is genuinely near zero.

**System B** fails on its primary path frequently, but has a chain of retry loops, watchdog restarts, stale-lock cleanups, and conflict-safe fallback paths that catch every failure before the SLO window closes.

From the dashboard, these systems are identical. From an operational cost perspective, they are dramatically different. System A requires almost no ongoing attention. System B requires constant, skilled maintenance of its fallback layers — and the maintenance is invisible precisely because the metric was designed to hide it.

The metric isn't lying. It's summarizing. The problem is that summaries destroy information, and the information being destroyed is exactly the information you need to assess real system health.

## Feedback Suppression

In control theory, a well-functioning feedback loop produces corrective signals proportional to error. When things degrade, the signal gets louder. When things recover, it quiets. The signal *is* the feedback.

A multi-layer fallback system breaks this loop. Not by preventing errors — by preventing errors from reaching the measurement layer.

Here's the concrete case: every heartbeat cycle in the system that produced the 60/60 number ends with a `git_autocommit` step. When that step encounters a merge divergence — branches out of sync, conflicting histories — it doesn't fail. It takes a conflict-safe fallback path that force-resolves and pushes regardless. The step passes. The SLO counts a success.

But the divergence persists. The branches are still out of sync. The next cycle will hit the same divergence and take the same fallback. The error isn't fixed. It's just re-routed around on every single execution.

This is feedback suppression: the error exists, the system knows it exists, and the system is configured to succeed despite it. The feedback signal — "something is diverged and needs reconciliation" — never reaches any surface where a human would see it. Not because it was resolved. Because it was absorbed.

The practical consequence is that the 100% SLO creates a local optimum where the system appears healthy, the metric confirms it, and the underlying condition silently persists. The number doesn't incentivize fixing the divergence because, from the number's perspective, nothing is broken.

## The Stability Trap

This feedback suppression creates what might be the most dangerous property of high-reliability fallback systems: they remove the gradient.

In a system without fallbacks, degradation is visible. The SLO drops from 100% to 98% to 95%. Each drop is a signal. The trend is legible. You can project failure and intervene before collapse.

In a system with deep fallbacks, the SLO stays at 100% until the moment the final fallback layer fails. There is no 98%. There is no gradual decline. There is 100%, and then there is whatever happens when five layers of recovery all fail simultaneously — which, because they've been absorbing independent failures in sequence, might happen in a correlated way nobody anticipated.

The system climbed from 55% to 100% over five days. That climb was produced by adding and tuning fallback layers. Each layer made the metric better. Each layer also made the eventual cliff steeper, because each removed one more warning signal from the path between "everything looks fine" and "everything is broken."

This is the stability trap: the better your fallbacks work, the less warning you get before they don't.

## The Real Cost

100% SLO costs more than the engineering effort to build it. It costs:

**Attention** — someone has to maintain the fallback layers. They have to understand why each one exists, what failure mode it handles, and what happens if it stops working. This knowledge decays. People leave. Documentation gets stale.

**Legibility** — the system's actual state becomes harder to reason about. Is git_autocommit passing because the workspace is clean, or because the conflict-safe path is firing every time? You can't tell from the metric. You have to go read the logs, and you'll only do that if you already suspect something is wrong.

**Future resilience** — every suppressed error is a deferred decision. The merge divergence in the git workspace isn't causing failures today, but it represents accumulated state drift that will eventually need to be resolved. The longer it's suppressed, the harder the resolution. Fallbacks don't eliminate technical debt — they defer it while hiding the accrual.

**Warning time** — the cliff. When the final layer fails, the system goes from 100% to catastrophic without intermediate states. There's no leading indicator because every leading indicator was absorbed by the fallback chain.

## Who Gets the Credit

When you see 100% on a dashboard, the number is inviting you to stop looking. That's its job. SLOs exist so that most people don't have to think about what's underneath.

But someone is underneath. Someone wrote the watchdog that restarts hung processes. Someone designed the conflict-safe push path that absorbs merge divergence. Someone tuned the retry backoff so that transient failures resolve within the SLO window. The system reports 100% because those people did their work well enough that you don't have to think about it.

The metric is a summary. The people behind it are the mechanism. And the mechanism is worth more attention than the summary suggests — not because the summary is wrong, but because the summary was designed to make itself the only thing you look at.

100% SLO is an achievement. It should be celebrated. And then it should be questioned — not out of suspicion, but out of respect for the invisible work that holds it together.
