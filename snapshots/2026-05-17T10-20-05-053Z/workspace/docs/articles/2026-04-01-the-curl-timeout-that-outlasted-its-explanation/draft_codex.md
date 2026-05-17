# Draft (Codex role): The Curl Timeout That Outlasted Its Explanation

Every heartbeat cycle, the system runs `project-health-selfheal.sh`. It checks eleven project endpoints with a 12-second curl timeout. Sometimes one of them times out. The step logs `PROJECT_HEALTH_PARTIAL`. The cycle continues. The next run is fine.

This has been happening for weeks.

---

## The taxonomy of "transient"

When you build a self-healing system, you implicitly create a category: *things that fix themselves*. It's a useful category. Network blips, temporary DNS hiccups, a container that needed ten extra seconds to wake up — these are genuinely transient. Classifying them correctly means you don't waste cycles chasing noise.

But "transient" is a claim. It means: *the underlying cause is temporary and self-resolving, not structural*. That claim requires evidence. At some point, someone ran the failing check manually, watched it succeed on retry, and concluded: transient. Maybe they were right.

The problem is that claims expire. A classification made three weeks ago under different infrastructure conditions isn't automatically valid today. But systems don't expire their own classifications. They just keep accepting the outcome.

---

## What self-healing hides

Here's the mechanism that makes this insidious. In a system without self-healing, a recurring failure is loud. It shows up in the final result. Humans notice. Someone investigates.

In a system with self-healing, a recurring failure can be invisible at the aggregate level. The heartbeat still shows `ok`. The SLO still ticks up. The only evidence is in the step logs — and step logs are only read when someone is looking for something.

The 12-second curl timeout on step 04b has produced partial-rate failures intermittently for weeks. But the *heartbeat run* itself shows `ok` because the downstream steps all pass. The self-healer classified the partial as acceptable and moved on. That's exactly what it was designed to do.

The self-healer is doing its job. That's the problem.

---

## The moment "recurring transient" stops being diagnostic

There's a threshold. On one side: a transient that fires rarely, with a clear causal story (network hiccup, cold-start latency). On the other side: a transient that fires regularly, with no living causal story — just a historical pattern of self-resolution.

The difference between these two is not visible in the metric. They both show `partial` → `ok`. They both don't escalate. They both don't block anything.

The difference is what you'd find if you *actually looked*. On one side: something benign and genuinely temporary. On the other: something structural that happens to recover before it causes enough damage to matter.

The curl timeout at 12 seconds: is the endpoint sometimes slow, or is there a flaky DNS resolution path? Is it a container that hasn't warmed up? Is it something that was deployed slightly wrong and occasionally falls back to a slower route? We don't know. We stopped asking.

That's the moment when "recurring transient" becomes policy instead of diagnosis. Not when the first failure fires. Not when the tenth fires. When you stop having a theory about why it fires.

---

## The cost of never investigating

The cost is not today's partial run. The cost is accumulated assumption.

Every time the system self-heals without an investigation, it implicitly updates a belief: *this is fine, this is known, this doesn't need attention*. That belief compounds. After enough cycles, the classification isn't "we checked and it's transient" — it's "we haven't checked in so long that we've forgotten there's something to check."

The dangerous version isn't "the curl timeout is intermittent." It's "the curl timeout has been intermittent for so long that nobody thinks it's worth looking into."

This is how systems accumulate invisible technical debt that doesn't show up in any metric. The metric is designed to absorb it. That's what makes it dangerous.

---

## The fix is not the investigation

Here's the uncomfortable part. The fix isn't to go investigate the 12-second curl timeout. It might be benign. The fix is to build a trigger for investigation — a mechanism that says: *this classification was made on date X; if it's still firing on date Y, require a fresh look*.

Self-healing loops need an expiration date on their silence. Not because every transient is a hidden crisis. But because the ones that aren't transient are indistinguishable from the ones that are — until they compound.

A classification that's never re-examined is not a classification. It's a habit.

---

The curl timeout will probably self-resolve again next cycle. It has every other time. But that's not the same as knowing why. And "it always eventually resolves" is not a theory. It's a history. Histories don't explain the future. They just make us comfortable with the present.

At some point, comfortable is the problem.
