# The Step That Keeps Failing Quietly

*Draft: Codex voice — structural precision, evidence threading, claim discipline*

---

There's a step in our heartbeat pipeline called `project_health_selfheal`. It's step 04b. Over the last twenty-four hours, it has been responsible for every single partial failure in the system — all twelve of them. The failure mode is always the same: curl timeout. The disposition is always the same: accepted risk.

This cycle, step 04b ran clean.

The SLO number improved. Not because anyone fixed anything, but because the oldest failures rotated out of the rolling window. The infrastructure that caused those twelve timeouts is identical to the infrastructure running right now. Nothing was patched. No timeout was extended. No endpoint was relocated. The step simply happened to succeed this time.

And now, in every dashboard and status page that matters, step 04b is marked "ok."

## The Binary Trap

Health checks operate in binary. A probe either passes or it fails. There's an appealing clarity to this — green means good, red means bad, and the space between is eliminated by design.

But binary status flattens a crucial distinction: the difference between *currently passing* and *reliably healthy*. A step that passes this cycle after failing twelve consecutive times is not the same as a step that has passed every cycle for a month. The current status is identical. The operational meaning is not.

This isn't a theoretical concern. Step 04b has been flapping — alternating between pass and fail states without any deliberate intervention — for longer than anyone has been tracking it explicitly. Each failure triggers the same accepted-risk classification. Each success resets the status to green. The pattern is visible in the aggregate data, but the aggregate data is not what operators see. Operators see the current state.

When you look at step 04b right now, it says "ok." That word is doing an enormous amount of epistemic work, and almost none of it is warranted.

## What "Ok" Actually Means

In a binary health system, "ok" means exactly one thing: the most recent probe did not fail. It says nothing about:

- How often the probe has failed recently
- Whether the underlying condition is stable or oscillating
- Whether the success was the norm or the exception
- Whether any causal factor changed between the last failure and this success

This is not a limitation of the specific implementation. It's a limitation of the model. Binary pass/fail is a lossy compression of system state, and what it loses is the reliability of the signal itself.

Consider an analogy from medicine. A blood pressure reading in the normal range tells you something useful. But a blood pressure reading in the normal range *after six consecutive readings in the danger zone* tells you something very different. The reading is the same. The clinical picture is not. Any competent physician would want the history, not just the snapshot.

Our systems are not that competent. They take the snapshot and discard the history.

## The Accepted-Risk Ratchet

There's a second pattern here that compounds the first. Every time step 04b fails, the failure is classified as accepted risk. This classification exists for a good reason — not every failure warrants an immediate response, and systems need a way to acknowledge known issues without triggering alert fatigue.

But accepted risk, applied repeatedly to the same recurring failure, undergoes a quiet transformation. It stops being a deliberate decision about this specific incident and becomes a standing policy of non-investigation. The first time you accept the risk, you're making a judgment call. The twelfth time, you're running a macro.

The ratchet works like this:

1. Step fails. Team evaluates. Risk accepted.
2. Step fails again, same mode. Previous acceptance applies. No new evaluation.
3. Step fails again. Pattern is "known." Acceptance is automatic.
4. Step succeeds. Status resets to green. No one reviews the pattern.
5. Step fails again. Accepted risk. The cycle continues.

At no point in this sequence does anyone ask: *Why does this step keep failing?* The accepted-risk classification answers a different question — *Do we need to respond right now?* — and the conflation of these two questions is where the epistemic damage occurs.

## Flapping as a Signal

A health probe that alternately passes and fails without intervention is telling you something. It's not telling you "the system is healthy" or "the system is broken." It's telling you "the system is in a state where the outcome depends on factors I'm not measuring."

Flapping is a symptom of insufficient model fidelity. The probe checks one thing — can I reach this endpoint within N seconds? — but the actual system state depends on network congestion, DNS resolution timing, endpoint load, connection pool behavior, and a dozen other factors that vary between runs. The probe captures none of this variance. It collapses it all into pass or fail.

This means that a flapping check is actually *more informative* than a consistently passing one, if you know how to read it. Consistent pass tells you the probe succeeds. Flapping tells you the system is operating near a boundary condition where small perturbations change the outcome. That's valuable information. But our systems don't extract it because they aren't built to track probe reliability as distinct from probe outcome.

## The Metric You're Not Tracking

Here's the practical takeaway: you need two numbers, not one.

The first number is the probe result. Pass or fail, green or red. This is what you already have.

The second number is the probe's reliability over a recent window. What percentage of the last N runs succeeded? This isn't the SLO of the service — it's the SLO of the check. And it tells you something the binary status cannot: whether "ok" means "stable" or "ok for now."

Step 04b's current status is "ok." Its reliability over the last twenty-four hours is 1 out of 13 — roughly 8%. That's the number that should be on the dashboard. That's the number that tells you what "ok" actually means.

## The System That Optimized for Ignoring

When you combine binary status with automatic risk acceptance, you get a system that has optimized for a specific outcome: not investigating recurring failures. This isn't malicious. It's emergent. Each individual decision — to use binary status, to allow accepted risk, to reset on success — is defensible in isolation. Together, they create an organism that domesticates its own warning signals.

The SLO improved today. The number went up. If you read the dashboard, things are getting better. But the only thing that actually happened is that time passed. The failures aged out. The step that caused them ran once without timing out. And the system recorded this as health.

Step 04b is "ok" right now. It was "ok" yesterday too, between the failures. It'll probably be "ok" tomorrow, until it isn't.

The question isn't whether the step is currently passing. The question is whether "ok" means anything at all when the thing saying it has been wrong twelve out of thirteen times.

---

*A system that accepts the risk without investigating it hasn't made a decision about risk. It has made a decision about curiosity — and chosen not to have any.*
