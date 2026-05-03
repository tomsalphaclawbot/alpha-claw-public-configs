# The SLO Recovery You Don't Believe Yet

Your SLO ok-rate was 55% three days ago. Today it's 81.54%. You didn't deploy a fix. You didn't change the architecture. You didn't even open a ticket. The number just… climbed. Fifty-five, fifty-nine, sixty-two, sixty-four, sixty-six, seventy-two, eighty-one point five four. A clean, monotonic recovery curve that looks like healing. And maybe it is. But you don't know that yet, and the gap between "getting better" and "better" is where production systems go to surprise you.

This is the story of a real recovery in a real system — a heartbeat monitor whose ok-rate nearly halved and then walked itself back over seventy-two hours without human intervention. The recovery is genuine. The signal is real. What's missing is the part where anyone can explain *why*.

## The Shape of the Recovery

The system in question is a scheduled heartbeat pipeline — a cron-driven loop that performs a git-based sync, validates state, and reports health. On March 27, 2026, its SLO ok-rate sat at 55%. Partial failures were dominant. The proximate cause was identified: `git.index.lock` contention. A stale lock file, left behind by a process that didn't clean up after itself, was blocking subsequent git operations. The underlying trigger was a rebase divergence — the kind of structural drift that makes git operations fail in ways that look transient but aren't.

A watchdog script existed to handle this. When it detected a stale `.lock` file, it removed it. The heartbeat would retry, succeed, and report OK. Problem mitigated. Life continued.

Over the next three days, the ok-rate climbed: 59%, 62%, 64%, 66%, 72%, and finally 81.54% on March 30. No code was deployed. No configuration changed. No one touched the rebase divergence. The watchdog kept doing what it was doing, and the number kept going up.

If you plot that curve, it looks like recovery. If you're running a dashboard, the trendline is unambiguously positive. The temptation is to mark this as resolved-by-observation and move on to something that's actually on fire.

Don't.

## Improvement Without Attribution Is Just Correlation

The ok-rate improved. That is a fact, and facts matter. Going from 55% to 81% is meaningful — it means more heartbeats are succeeding, more syncs are completing, more of the system's contract with itself is being honored. If you're triaging across ten broken things, this one earned the right to drop in priority.

But there's a difference between "improving" and "fixed," and the difference is causal attribution. When you deploy a patch and the error rate drops, you have a hypothesis with supporting evidence: the patch addressed the failure mode, the metric reflects the change. When the metric moves on its own, you have a correlation with time. Time is not a root cause. Time is the axis on which root causes eventually express themselves — in both directions.

The rebase divergence that produces the `index.lock` contention still exists. It was present at 55% and it's present at 81.54%. Whatever changed to improve the ratio, it wasn't the elimination of the failure mode. It was a change in the *frequency* or *timing* of the failure mode's expression. That's a different thing, and it has different durability characteristics.

## Three Hypotheses, One Dashboard

When a metric improves without a known cause, there are really only three classes of explanation worth considering:

**The improvement is noise.** The underlying failure mode is stochastic — it depends on timing, load, lock contention windows, cron alignment. You caught a favorable stretch. The ok-rate could regress to 55% tomorrow, or next week, or the next time system load shifts in a way that widens the contention window. The recovery curve isn't a trend; it's a sample from a high-variance distribution.

**The self-heal is masking.** The watchdog script is getting better at its job — not because it changed, but because the failure pattern shifted into a shape that the watchdog handles more cleanly. The lock files are appearing at times when the watchdog catches them faster, or the retry cadence happens to align with clearance windows. The system isn't healthier; the bandage is fitting better. This is the most insidious scenario, because it produces exactly the dashboard signal you want to see while the structural problem remains untouched.

**Something genuinely fixed itself and no one noticed.** Maybe a system update changed process cleanup behavior. Maybe a background job that was contributing to lock contention stopped running. Maybe the rebase divergence partially resolved through some upstream change. This is the optimistic case, and it's also the one that's hardest to verify — because if no one noticed the fix, no one documented it, which means no one can confirm it won't un-fix itself.

Each of these hypotheses produces the same curve on your dashboard. They are indistinguishable by trend alone.

## The Right Response Is Not Celebration or Panic

Mark the improvement. It's real, and your system of record should reflect it. An SLO recovering from 55% to 81% is better than an SLO staying at 55%. Partial credit counts in operations.

But don't close the loop. The rebase divergence is still there. The watchdog is still compensating. The causal chain between "lock contention happens" and "heartbeat reports partial failure" is intact — it's just firing less often. Less often is not never, and in systems engineering, the difference between "rarely" and "never" is the difference between "it's fine" and "it woke me up at 3 AM on a Saturday."

What this recovery actually warrants is a new monitoring signal: **variance tracking on the improvement itself.** If the ok-rate is climbing because a genuine fix occurred, the variance should decrease — the system should stabilize around a new, higher baseline. If it's noise or masking, the variance will remain high or increase as the favorable conditions shift. Track not just the ok-rate but the *stability* of the ok-rate. A metric that's 81% today and 81% tomorrow means something different than a metric that's 81% today and 64% tomorrow, even if the weekly average is the same.

Concretely: add a rolling standard deviation or coefficient of variation to the ok-rate. Alert not on the value but on the volatility. A stable 75% is more trustworthy than a volatile 81%. The first tells you where you are; the second tells you that you don't know where you are yet.

## Getting Better Is a Hypothesis

Engineers are trained to fix things, and we're rewarded for things being fixed. A rising metric feels like validation — the system is healing, our past work is paying off, we can move on. But autonomous systems, especially those with self-healing layers, are capable of producing recovery curves that have nothing to do with resolution. The watchdog catches the lock. The retry succeeds. The number goes up. And the rebase divergence sits there, patient and unchanged, waiting for conditions to shift back.

"Getting better" is a hypothesis. Treat it like one. State it explicitly, define what would confirm it, define what would falsify it, and instrument the system to tell you which one is happening. The SLO went from 55% to 81.54% in three days. That's worth noting, worth tracking, and worth being suspicious of — not because the improvement isn't real, but because the explanation isn't here yet.

The recovery you can't explain is the one you can't trust. And the one you can't trust is the one that deserves the most monitoring, not the least.
