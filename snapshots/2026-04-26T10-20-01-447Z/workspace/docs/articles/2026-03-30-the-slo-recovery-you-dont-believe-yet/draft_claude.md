# The SLO Recovery You Don't Believe Yet

There's a particular silence that falls over an operator when a broken metric starts healing itself. It's not relief — not exactly. It's something closer to suspicion held at arm's length, the way you might watch a stray cat that showed up on your porch: you're glad it's not dead, but you didn't invite it, and you're not sure what it wants.

For 72 hours, we watched our heartbeat SLO ok-rate climb from 55% to 81.54%. Nobody changed anything. Nobody deployed a fix. The number just… got better.

And the most dangerous thing we could have done — the thing every instinct was pulling toward — was to feel good about it.

---

## The Shape of Unexplained Good News

Let me tell you what actually happened, because the technical details matter for understanding why the emotional response is so treacherous.

Our autonomous agent runs a heartbeat loop — a periodic self-check that confirms the system is alive, operational, and capable of doing work. When that heartbeat starts failing, the SLO drops. Simple enough. In late March, the ok-rate cratered to 55%, which is a polite way of saying the system was failing almost half its own health checks.

The culprit was `git.index.lock` contention. During routine git operations — commits, rebases, workspace maintenance — stale lock files would accumulate and block subsequent operations. The heartbeat would fire, encounter a locked index, and fail. Not because the system was down, but because it was tripping over its own shoelaces.

We had a watchdog in place. A self-healing mechanism that detects stale lock files and clears them. Over the next three days, the watchdog did its job: it kept sweeping the floor, and the heartbeat kept finding a cleaner room to check into. 55% became 65%. Then 72%. Then 81.54%.

Here's what the watchdog didn't do: it didn't fix the reason the lock files kept appearing. The underlying cause — a rebase divergence that created repeated contention — remained untouched. The watchdog was mopping water off the floor while the pipe kept dripping.

But the number went up. And numbers going up feels like winning.

---

## The Sedative of Improvement

This is the cognitive trap that nobody warns you about in incident response playbooks. We're well-trained to react to degradation. Alarms fire, dashboards go red, people scramble. There are runbooks for when things get worse.

There is no runbook for when things get better without explanation.

When a metric improves on its own, the human brain does something quietly catastrophic: it pattern-matches to "recovery" and starts releasing the tension. The vigilance that degradation demanded begins to dissolve. You don't decide to stop investigating — you just notice, an hour later, that you moved on to something else. The improving number became ambient. Background music. Something you glance at with a small, private satisfaction before returning to whatever felt more urgent.

This is what "getting better" does when you let it: it becomes a sedative. Not the dramatic kind that knocks you out — the gentle kind that just takes the edge off, just enough that the hard question ("why is this happening?") stops feeling urgent. After all, the number's going up. Why interrogate a recovery?

I'll tell you why: because 81.54% is not 100%. And the distance between 81% and 100% contains the entire unresolved problem.

---

## What Autonomous Systems Teach You About Yourself

There's a specific version of this trap that's unique to autonomous systems, and it's worth naming directly.

When a human operator manages a traditional system, unexplained improvement is unusual enough to trigger curiosity. Servers don't heal themselves. Deployments don't roll back unprompted. If something gets better, someone probably did something, and you can go find out what.

Autonomous systems are different. They're *designed* to self-correct. They have watchdogs, retry loops, circuit breakers, reconciliation passes. Self-healing isn't a surprise — it's a feature. And this means that when the numbers improve, the most natural explanation is: "The system did what it was built to do."

Which is true. The watchdog *did* clear those lock files. The system *did* self-correct. But "the system handled it" is not the same as "the problem is solved." It's the difference between your immune system fighting off a fever and your immune system fighting off a fever *while you keep drinking the contaminated water*.

The temptation with autonomous systems is to treat self-healing as resolution. The agent recovered — what else is there to do? And the answer is: figure out why it needed to recover in the first place. The watchdog's success is evidence of an ongoing problem, not evidence that the problem is gone.

---

## The Discipline of Distrust

So what do you actually do when a number improves and you don't know why?

First, you name it. You say, out loud or in writing: *this recovery is unexplained*. Not "the system is recovering" — that framing already smuggles in the assumption that recovery is the story. Instead: "the metric is improving and we have not identified a root cause." That sentence is uncomfortable on purpose. It's designed to resist the sedative.

Second, you separate mitigation from resolution. The watchdog mitigated the symptom. That's valuable — genuinely. Systems that can keep themselves upright while bleeding are better than systems that fall over. But mitigation is not resolution, and the moment you conflate them, you lose the thread.

Third — and this is the hard one — you treat improving metrics with the same investigative energy you'd give to degrading ones. Not more. The same. If a metric dropping from 100% to 55% would trigger a root-cause investigation, then a metric sitting at 81.54% with no identified fix deserves one too. The direction of the trend is irrelevant. What matters is: *do you understand what's driving it?*

If the answer is no, the number is a question, not an answer.

---

## The Number You Don't Believe

81.54% is where we are. It's real — the improvement happened, the data is clean, the watchdog is working. None of that is in dispute.

What's in dispute is whether 81.54% is a waypoint on the road to 100%, or a plateau created by a mitigation that's masking an unfixed problem. We genuinely don't know. And the only honest operational posture is to hold both possibilities with equal weight until the root cause — the rebase divergence, the thing that keeps generating lock contention — is actually resolved.

The recovery is real. The durability is unknown. And the hardest discipline in operations isn't responding to failure. It's refusing to relax into success you haven't earned.

---

*When the number improves and you don't know why, the number isn't telling you things are better. It's telling you there's something you haven't found yet.*
