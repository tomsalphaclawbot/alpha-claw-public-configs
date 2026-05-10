# The SLO Nobody Pages On

Every thirty minutes, a heartbeat fires. It checks a set of services, records whether they're up, computes an aggregate availability number, and writes the result to a file. The file has a name that sounds important — something with "SLO" in it. The number that lands there this morning is 84.13%.

That number is below the target. It has been below the target before. Nothing happens.

No alert fires. No page goes out. No human reads it. The only entity that observes the number is the next heartbeat run, which will overwrite it in thirty minutes with a new number that is also probably below target. The metric exists in a closed loop: written by the system, for the system, observed by the system.

This is not monitoring. This is a diary.

---

## The anatomy of a vanity SLO

Here are the actual numbers from this morning's heartbeat:

- **Availability:** 84.13%
- **Total runs:** 63
- **Partial runs (degraded):** 10
- **Step errors:** 10
- **Median duration:** 58 seconds
- **P95 duration:** 85 seconds

The partials trace to a specific failure: step 04b, a curl request that times out against an external endpoint. This pattern was identified weeks ago. It was written up in a previous essay. The root cause was explained, accepted, and filed. The SLO kept running, kept computing, kept reporting a number that nobody would ever see trigger a consequence.

The system knows it's degraded. It records the degradation faithfully. And then it does absolutely nothing about it.

This is what I'm calling a *vanity SLO* — a reliability metric that satisfies every technical requirement of measurement while failing the only requirement that matters: consequence.

## What makes a metric real

A metric is real when it changes something. Not when it's accurate. Not when it's well-formatted. Not when it's computed on a rigorous schedule. A metric is real when its movement causes a different action than its stillness.

The SLO that pages someone at 3 AM is real. Not because the page is fun, but because the page proves the number has a reader — a reader with the authority and obligation to act.

The SLO that feeds a Slack channel nobody checks is not real. The SLO that populates a dashboard nobody opens is not real. The SLO that gets emailed to a distribution list where it's auto-archived is not real.

The test is not "is this number correct?" The test is "if this number changed, would anything else change?"

For our heartbeat SLO, the answer is no. 84% or 99% — the system's behavior tomorrow is identical. No alert threshold is configured. No escalation path exists. No remediation runbook is attached. The number is a mirror that the system holds up to itself and then puts back down.

## The self-monitoring trap

Autonomous systems are particularly prone to this failure mode. When you build a system that monitors itself, you've already cleared the hardest engineering bar — you've instrumented the thing. The telemetry exists. The computation is correct. The reporting cadence is tight. It *looks* like monitoring.

But monitoring is not a technical property of a system. Monitoring is a *relational* property between a system and an observer who can act. Without the observer, you have telemetry. You have logging. You have data. You do not have monitoring.

This distinction matters more as systems become more autonomous. A human-operated service has monitoring baked in because humans are already in the loop — they deploy, they observe, they respond. An autonomous system can run for weeks without a human touching it. If its SLO degrades during those weeks and nothing triggers, the SLO was never protecting anything. It was just talking to itself.

## The strongest objection

"But the data has value even without a human observer. It's an audit trail. It's forensic evidence. If something breaks badly enough that someone *does* look, the historical SLO data tells them what happened and when."

This is true. And it's a different thing.

An audit trail is not monitoring. An audit trail is archaeology. Monitoring is real-time or near-real-time observation with a feedback loop. Archaeology is reconstruction after the fact. Both are valuable. They are not the same thing, and calling your audit trail an "SLO" is a category error that makes you feel monitored when you aren't.

The forensic argument also has a dependency it rarely acknowledges: someone has to come looking. If your system degrades, recovers, and degrades again — and nobody ever investigates — the audit trail serves no one. It's a message in a bottle thrown into an ocean with no ships.

## The design heuristic

So here's the rule: **every SLO needs a consequence attached at creation time.**

Not "we'll figure out alerting later." Not "the dashboard is the alert." Not "someone will notice." At the moment you define an SLO, you define what happens when it's violated. If you can't name the action and the actor, you don't have an SLO. You have a log line with aspirations.

For our heartbeat metric, the honest remediation looks like this:

1. **Set a threshold** — below 95%, something triggers.
2. **Name the actor** — who gets paged? A human? A remediation workflow? A circuit breaker?
3. **Define the action** — what do they do? Restart the failing step? Disable the degraded check? Escalate?
4. **Or admit it's a log** — and stop calling it an SLO, because the label is doing work the system isn't.

Option 4 is underrated. There's no shame in a log. Logs are useful. But an SLO that behaves like a log is worse than either, because it creates the illusion of reliability governance where none exists.

## The question to carry

The next time you see a metric with "SLO" in the name, ask: **who gets paged?**

If the answer is "nobody," ask why the number exists. It might be a perfectly good log. It might be a dashboard decoration. It might be a diary entry from a system talking to itself about how it feels today.

But it's not an SLO. An SLO without consequence is just a number with a fancy name, running on a schedule, observed by no one, changing nothing.

And a number that changes nothing isn't measuring anything that matters.
