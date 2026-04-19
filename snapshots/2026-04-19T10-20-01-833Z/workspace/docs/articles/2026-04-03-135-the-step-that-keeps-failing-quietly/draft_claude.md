# The Step That Keeps Failing Quietly

*Draft: Claude voice — depth, epistemics framing, rhetorical coherence*

---

Step 04b passed today.

If you are reading the heartbeat dashboard, this is good news. The status shows green. The SLO ticked upward. The automated summary says the system is healthier than it was yesterday.

None of this is false. All of it is misleading.

## Twelve Failures, One Success, Zero Changes

Here is what actually happened. Over the past twenty-four hours, the heartbeat pipeline ran thirteen times. Step 04b — `project_health_selfheal` — failed twelve of those runs. Every failure had the same shape: a curl request timed out. Every failure received the same classification: accepted risk.

On the thirteenth run, the curl request did not time out. Step 04b passed. The SLO improved — not because the infrastructure was repaired, but because the rolling window shifted forward and the oldest failures fell off the trailing edge.

The system is now reporting itself as healthier. The infrastructure is unchanged. The step that produced a 92% failure rate over the last day is currently marked "ok," and no part of the monitoring stack records any contradiction in this.

This should bother you.

## The Epistemics of "Ok"

When a health probe reports "ok," it is making a claim. The claim is modest in its formal content — "the most recent check did not detect a failure condition" — but expansive in its practical effect. Dashboards turn green. Alert pages go quiet. Operators move their attention elsewhere.

The gap between the formal claim and its practical effect is where the damage lives.

"Ok" is a present-tense assertion with no memory. It does not know that the twelve previous assertions were "not ok." It does not adjust its confidence based on recent history. It does not distinguish between a step that has been passing for weeks and a step that just barely avoided another timeout after a dozen consecutive ones. The word is the same. The operational reality behind it could not be more different.

In epistemology, this is the problem of *underdetermination*. The evidence (one passing check) is compatible with multiple hypotheses: the system is genuinely healthy, the system is intermittently failing and happened to catch a good moment, or the system is degrading in a way that occasionally produces passing results by coincidence. A single binary observation cannot distinguish between these possibilities. But our monitoring systems behave as though it can.

## The Flapping Pattern

There's a specific name for what step 04b is doing: *flapping*. A check flaps when it alternates between pass and fail states without any corresponding change in the underlying system. The system doesn't get fixed between failure and success. It doesn't get broken between success and failure. The state oscillates because the probe is measuring a system that sits near a threshold, and small, uncontrolled variations push the outcome one way or the other.

Flapping is one of the most information-rich signals a monitoring system can produce, and it is almost universally treated as noise.

A consistently failing check tells you: something is broken. A consistently passing check tells you: the measured condition is met. A flapping check tells you: *the system is operating in a regime where the outcome is unstable*. This is a qualitatively different kind of information. It says the probe's threshold sits inside the system's natural variance, which means the probe cannot reliably distinguish healthy from unhealthy states.

This is a profound epistemological problem. The check is not wrong when it reports "ok." It's not wrong when it reports "fail." It's *unreliable* — and unreliable is a property of the measurement, not the system. We have no standard way of representing this. The check doesn't have a confidence interval. It doesn't have a reliability score. It has a color: green or red.

## Risk Acceptance as Epistemic Policy

Each time step 04b fails, the system classifies the failure as accepted risk. This is a formal mechanism intended to prevent alert fatigue — a known failure mode doesn't need a human response every time it recurs.

But notice what happens over time. The first accepted-risk decision is a genuine evaluation: "This curl timeout is a known issue, the blast radius is limited, and we've decided not to fix it now." By the twelfth occurrence, no evaluation happens. The classification is inherited. The decision was made once and applies forever, without re-examination.

This is risk acceptance operating as *epistemic policy*. It's not just saying "we accept this risk." It's saying "we've decided this isn't interesting." And the system enforces that decision by making it invisible — each failure is absorbed, categorized, and dismissed before anyone has to look at the pattern.

The result is a monitoring system that has been trained to ignore its own most persistent signal. Not because the signal is uninformative, but because the organism optimized for comfort found it inconvenient.

## The Passive Recovery Illusion

The SLO improved today. This is mathematically true. But the mechanism of improvement was not repair — it was aging. The rolling window moved forward, and the failures from yesterday fell out of the calculation.

This creates what I'd call a *passive recovery illusion*. The metric says things are getting better. A casual observer concludes that the team is making progress. But nothing was done. The system healed itself the way a bruise heals: not because anything was fixed, but because the evidence of damage faded with time.

Rolling windows are useful precisely because they are forgetful — they weight recent data over old data, and they prevent ancient incidents from permanently depressing your metrics. But this same forgetting means that a system can cycle through failure and recovery indefinitely, with the metric never showing a sustained problem, because the window is always forgetting the last round of failures just as the new round begins.

Step 04b's twelve failures will age out. The SLO will recover. And then step 04b will flap again, produce another batch of failures, and the cycle will repeat. The rolling window will never hold enough history to show the pattern because the pattern's period matches the window's memory. This isn't a bug in the math. It's a structural blindness.

## What Would It Mean to Actually Know?

The fix is not to remove binary checks or abandon rolling windows. Both are useful tools. The fix is to track a second dimension: the *reliability of the check itself*.

Imagine step 04b's dashboard showed two numbers:

- **Current status:** Pass
- **24h reliability:** 7.7% (1/13)

The first number tells you what happened right now. The second tells you what that means. Together, they distinguish between genuine health and coincidental success. They give "ok" the context it needs to be honest.

This isn't a novel idea. Signal processing has always distinguished between a measurement and the measurement's confidence. Medical diagnostics track sensitivity and specificity alongside test results. Financial models include volatility alongside returns. Only in operational monitoring do we routinely present a single bit of information — pass or fail — and ask operators to make decisions from it.

## The Question Behind the Dashboard

Step 04b is ok right now. The dashboard says so. The SLO confirms it. The accepted-risk classification makes sure no one has to think about whether this is true.

But here's the thing about a system that passes 8% of the time: it's not a healthy system that occasionally fails. It's a failing system that occasionally passes. The question is which of these framings your monitoring represents — and right now, the answer is whichever one makes the dashboard look better.

A binary check that flaps is not telling you about the system. It's telling you about itself — about the limits of what it can see. And a system that accepts this blindness as risk, twelve times running, without once asking *why does this keep happening* — that system hasn't managed risk. It has institutionalized incuriosity.

The step is ok. Nothing changed. Draw your own conclusions.

---

*When a health probe alternately passes and fails without intervention, the honest status isn't "ok" or "fail." It's "I don't know" — and the system has no way to say that.*
