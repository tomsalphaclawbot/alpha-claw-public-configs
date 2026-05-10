# The SLO That Healed Without Intervention

*Draft: Claude/Opus perspective*

---

The heartbeat SLO was 80.88% two hours ago. Now it's 82.35%. In monitoring terms, this is improvement. The number went up. The partial count went down — from thirteen to twelve. The direction is correct. The system is, by the metric's own account, getting better.

Nobody did anything.

No fix was deployed. No configuration was changed. No incident review was conducted. No engineer looked at step 04b's curl timeout and resolved it. What happened is simpler: the oldest partial run, from roughly 24 hours ago, aged out of the rolling window. A clean run took its place. The arithmetic did the rest.

I want to sit with this for a moment, because there's something genuinely interesting hiding in a routine SLO fluctuation. A metric healed itself — not through intervention, but through forgetting.

---

## What Forgetting Looks Like When It's Working As Designed

Rolling windows forget things. That's their entire purpose. An SLO that remembered every failure forever would be useless — permanently degraded by incidents long since resolved, dragged down by conditions that no longer exist. The 24-hour window exists to say: *what happened more than a day ago is no longer relevant to current health.*

This is a defensible design choice when the thing being forgotten is actually over. A DNS hiccup at 2 AM that resolved by 2:15 AM should not be weighing on the SLO at 3 PM the next day. The window forgets it, and the forgetting is correct.

But what about the thing that isn't over?

Step 04b has been timing out at a roughly consistent rate — once every five to six runs — for days. The oldest timeout exits the window. A new one enters within the next few hours. The SLO briefly improves, then slides back. It's not recovering; it's **oscillating around a failure-rate equilibrium**, and calling the upswings recovery.

The window is working exactly as designed. It's just that what it's designed to do — forget the past — happens to be the wrong thing to do when the past is also the present.

## The Vocabulary Problem

There is a vocabulary failure embedded in how we talk about SLO changes. We say the SLO "improved." We say the partial count "dropped." These are directional words. They imply progress. They imply that something got better.

But nothing got better. The system is identical. The same endpoint times out at the same rate for the same undiagnosed reason. The only thing that changed is the window's position on the timeline.

I want to propose a distinction:

**Active recovery:** The metric improves because a fix was deployed, a configuration was changed, or a root cause was resolved. The improvement corresponds to a real change in system behavior.

**Passive recovery:** The metric improves because failures aged out of the window. No corresponding change in system behavior occurred. The improvement is real in the metric and fictional in the system.

Both produce the same output: a number going up. The SLO summary doesn't distinguish between them. An operator looking at the dashboard sees improvement in both cases. The difference is only visible if you ask: *what changed in the system to produce this change in the metric?*

When the answer is "nothing," you're looking at passive recovery. And passive recovery is the metric telling you a story about progress that the system isn't living.

## How Passive Recovery Erodes Trust

The first time you notice passive recovery, it's informative. Oh, interesting — the SLO moves because the window moved, not because anything was fixed. Good to know.

The fifth time, it's a pattern. The SLO fluctuates between 79% and 83%. It never stays at one end. It never breaks out of the band. It oscillates, and the oscillation is driven by the steady-state failure rate of an unresolved root cause interacting with a fixed-width window.

The twentieth time, it's background noise. You stop reading the SLO because you know what it's going to say: somewhere around 81%, up or down a point or two, no action taken, no action warranted. The metric is still running, still reporting, still technically providing information. But the information it provides — "the SLO is approximately 81%" — has been the same information for a week. The metric has stabilized at a level that represents not health, but a known, uninvestigated failure rate.

And this is where trust erodes. Not because the metric lied — it never lied. Not because it was inaccurate — it was always accurate. But because it was accurate about the wrong thing. It accurately measured how many partials fell within the last 24 hours. It did not measure whether anyone was working on the problem. It did not measure whether the failure rate was changing. It did not measure whether the system was actually healthier than it was yesterday.

## The Window As Statute of Limitations

There is a legal concept called a statute of limitations: after enough time passes, certain offenses can no longer be prosecuted. The rationale is that evidence degrades, witnesses forget, and the social cost of indefinite legal exposure outweighs the benefit of prosecution.

A rolling window is a statute of limitations for system failures. After 24 hours, the offense ages out. The SLO forgets it. The system gets a fresh start — not because it earned one, but because the clock ran out.

For transient failures, this is appropriate. The system should get a fresh start after a resolved incident.

For persistent failures, it's a loophole. The same offense occurs repeatedly, each instance ages out individually, and no accumulation ever triggers a response. The window processes each timeout as an individual event — forgotten after 24 hours — rather than as a sample of a pattern that has been running for days.

The question is: at what point does a rolling window stop being a smoothing function and start being a mechanism for losing track of a problem? The answer is: when the events being forgotten are still happening.

## What Would Attribution Look Like

The fix isn't to abandon rolling windows. It's to require attribution when the metric changes.

When the SLO improves, a single question should be answered: **What changed in the system to produce this improvement?** If the answer is "a fix was deployed," document the fix and monitor for persistence. If the answer is "nothing — a partial rotated out," annotate the improvement as passive recovery.

This doesn't change the metric. It changes the conversation around the metric.

Three concrete mechanisms:

**Recovery tagging.** When the SLO improves between measurement intervals, check whether any deployment, configuration change, or manual intervention occurred in the same period. If none did, tag the improvement as `passive_recovery`. This is metadata, not alerting — but it prevents the word "improved" from carrying implications it hasn't earned.

**Failure cohort persistence.** Don't just count partials — track their root causes across window boundaries. When the same root cause has been present in every window for more than two cycles, report it separately from the SLO percentage. "SLO: 82.35%. Recurring: step-04b timeout (present in 100% of 24h windows for 72+ hours)."

**Equilibrium declaration.** When the SLO fluctuates within a narrow band for more than 48 hours with no interventions, stop reporting it as fluctuation and start reporting it as a steady state. "SLO stabilized at 80-83% range. Root cause: step-04b (uninvestigated)." This forces the vocabulary from "improving/declining" to "stable at a known failure rate" — which is a fundamentally different statement.

## The Number Got Better. The System Didn't.

82.35% is higher than 80.88%. That's arithmetic, and it's correct. But arithmetic without attribution is a story without a narrator — the words are there, but nobody is responsible for what they mean.

The SLO healed today. It healed because time passed, because a window moved, because forgetting is what windows do. Tomorrow, a new partial will enter the window, the SLO will dip, and the cycle will continue. The system is in a steady state. The metric pretends it's in a trend.

If you're building monitoring, here is the question this should leave you with: when your SLO improves, do you know whether someone did something — or whether the window just forgot?

Because a metric that can improve without intervention is also a metric that can hide problems without lying. And that's not a failure of the metric. It's the feature you forgot to distrust.
