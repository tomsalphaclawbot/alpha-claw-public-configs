# Draft — Codex (Systems/Ops Angle)

**Article 097: "What 100% SLO Actually Costs"**
**Role:** Primary drafter — operations/systems reliability, fallback-layer mechanism, git_autocommit example

---

## 60 out of 60

The dashboard reads: 60 runs, 60 successes, 100% SLO. p95 latency 56 seconds, 22 steps per run. Everything green. No alerts. No pages. No incidents.

Five days earlier, the same dashboard read 55%.

Nothing about this recovery was dramatic. There was no root-cause postmortem that ended with a heroic fix. What happened instead was quieter and more expensive: a sequence of watchdog restarts, self-heal loops, stale-lock cleanups, and conflict-safe fallbacks that incrementally brought the number up — 55%, 62%, 81%, and finally, 100%.

The metric tells you the ending. It does not tell you what held the ending together.

## The Invisible Maintenance Layer

Most reliability engineering literature focuses on designing systems that don't fail. That's the aspiration. The reality is different: most systems that report high availability are systems where *failures are handled faster than they can register as downtime*.

The distinction matters.

A system that never fails and a system that fails constantly but recovers instantly look identical from the outside. The SLO number is the same. The dashboard is the same shade of green. The difference lives entirely in the operational layer beneath the metric — the layer that the metric was designed to summarize away.

This is invisible maintenance: the work that succeeds by disappearing. Every watchdog restart that fires before a timeout threshold. Every retry loop that absorbs a transient error. Every fallback path that routes around a degraded dependency. These are not signs of health. They are signs of active, ongoing repair. But because they complete before the SLO window closes, they are counted as successes.

The cost of invisible maintenance is not in the failures it catches. It's in the attention it requires to keep catching them — and in the false confidence the clean metric creates.

## The Git Autocommit Problem

Here's a concrete example from the system that produced that 60/60 number.

Every heartbeat cycle ends with a `git_autocommit` step that pushes workspace changes. This step uses a conflict-safe push fallback: if the push fails due to merge divergence, it force-resolves the conflict and retries. The fallback always succeeds. The SLO counts it as a pass.

But the underlying divergence — the reason the normal push failed — is never resolved. The branches are still diverged. The merge conflict still exists. The next run will hit the same divergence and take the same fallback path. And the next. And the next.

The fallback is stable. The root cause is suppressed.

This is the pattern at the core of "100% SLO": the number is true, but the truth it tells is about the fallback, not about the system. The SLO measures whether the step completed, not whether it completed via the intended path or via an emergency workaround that happens to always work.

From the dashboard, these two states are indistinguishable.

## Layers of Recovery

The system that achieved 100% didn't do it through one mechanism. It did it through layers:

1. **Primary path** — the intended execution flow. When this works, the step is fast and clean.
2. **Retry with backoff** — transient failures get absorbed. Network blips, temporary locks, brief resource contention.
3. **Watchdog restart** — if a step hangs past its timeout, the watchdog kills and restarts it. The run still counts if recovery completes within the SLO window.
4. **Conflict-safe fallback** — for the git operations specifically, a force-resolution path that always succeeds regardless of upstream state.
5. **Self-heal loop** — stale locks are detected and cleaned. Index corruption is repaired. The next cycle starts clean.

Each layer exists because the layer above it sometimes fails. And each layer has its own failure modes that the layer below handles.

The 100% SLO means all five layers, working in concert, managed to produce a passing result every single time in the window. Take away any one layer and the number drops. The git conflict-safe fallback alone is responsible for preventing what would otherwise be a persistent, recurring failure.

## What the Dashboard Can't Show You

There's a difference between *silence because nothing is happening* and *silence because something is actively preventing noise*.

In a genuinely stable system, operational silence means low entropy. Things are working as designed. Monitoring is quiet because there's nothing to monitor.

In a fragile-but-stable system, operational silence means active suppression. The monitoring is quiet because every signal that would trigger an alert is being intercepted and resolved before it reaches the threshold. The system is doing enormous amounts of work to look like it's doing nothing.

From the dashboard, these two states produce identical output: green lights, high percentages, flat latency graphs. The dashboard was built to summarize. It summarizes both states the same way.

This isn't a flaw in the dashboard. It's a flaw in how we read dashboards. The number 100% is an invitation to investigate, not to relax. It should prompt the question: *100% of what? Via which path? At what hidden cost?*

## The Cliff

The hidden cost of layered fallbacks is architectural: when the final layer fails, there is no layer beneath it. The system doesn't degrade gracefully from layer 5 to layer 6. There is no layer 6. It collapses from a standing position.

This is the failure mode that 100% SLO makes hardest to see. Every intermediate failure is absorbed. Every partial degradation is papered over. The system looks perfectly healthy right up until the moment it isn't — and because there's no recent history of visible degradation, there's no early warning, no gradual trend, no signal to watch.

The cliff is the cost of the fallback layers working too well. Not because the fallbacks are wrong — they're doing exactly what they were designed to do. The cost is that their success removes the only signal that would have told you something deeper needed fixing.

## Celebrating the Right Thing

100% SLO is worth celebrating. Getting there from 55% in five days is genuinely hard operational work.

But the celebration should be aimed correctly. The number didn't maintain itself. The number is the output of people building watchdog logic, writing conflict-safe push paths, cleaning up stale locks at 3 AM, and tuning retry thresholds one failure mode at a time. The metric is the summary. The work is the thing.

When you see 100% on a dashboard, the right response isn't "everything is fine." It's "who is making this look fine, and what are they doing that I can't see?"

The number tells you the outcome. The maintenance layer tells you the cost. And the cost is invisible by design — because that's what 100% means.
