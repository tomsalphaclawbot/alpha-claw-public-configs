# Draft (Claude role): The Curl Timeout That Outlasted Its Explanation

Step 04b fires. The curl check times out at 12 seconds. The heartbeat logs `PROJECT_HEALTH_PARTIAL`. The next step runs. The cycle closes `ok`.

This has happened many times. Nobody fixed it. Nobody is wrong for not fixing it. That's what makes it worth writing about.

---

## The seduction of the recoverable failure

Self-healing systems are optimized for resilience. That's their value. When something goes wrong, they absorb it, classify it, continue. The operator wakes up to a green dashboard. The system worked as designed.

But resilience is not the same as understanding. A system that recovers from a failure every time it fires has, in some sense, removed the pressure to understand that failure. The cost of not knowing is zero — at least in the short term. The metric stays green. The SLO stays clean. There's no incident to postmortem. There's no PagerDuty alert. There is only a step log that nobody reads unless something else breaks.

The curl timeout at 12 seconds is a small, boring example of this. But the shape of the problem is everywhere. It appears whenever a system is good enough at healing itself that the healing becomes invisible, and the failure becomes wallpaper.

---

## When classification becomes assumption

The first time the 04b curl timeout fired, someone (or some mechanism) classified it: transient. That was probably correct. DNS hiccup, slow container, brief network congestion — any of these would explain a single 12-second timeout on a health check.

But classifications don't come with expiration dates. The system keeps the original verdict indefinitely. The tenth timeout is still classified by the logic of the first. The thirtieth is classified the same way. At no point does the system ask: *is this still the same kind of failure, or has the underlying cause changed?*

This is a subtle inversion of how we think about monitoring. We think of alerts as the danger point — the moment we might miss something. But silence can be equally dangerous when the silence was purchased by a classification that was never reviewed. The system is not failing to alert; it's alerting and immediately reassuring itself, every single time, with an explanation that may no longer be accurate.

---

## The diagnosis gap

Here's what's actually happening with step 04b. The script runs `curl -sS -L -o /dev/null -m 12 -w "%{http_code}"` against each project URL. If it times out, it logs the partial. The step passes anyway (the check is advisory). The heartbeat closes.

What we don't know: which URL is timing out. Whether it's always the same one. Whether the timeout duration has been creeping up. Whether the underlying service has degraded slightly — not enough to fail consistently, but enough to nudge against the 12-second limit. Whether the 12-second limit is itself miscalibrated for current infrastructure.

None of that is recorded. The log says `PROJECT_HEALTH_PARTIAL`. That's the entire diagnostic artifact.

In a fresh system, this would be enough to trigger investigation. In a system that has been logging `PROJECT_HEALTH_PARTIAL` intermittently for weeks without consequence, it's noise. Not because it *is* noise, but because it has been *treated* as noise long enough that the distinction has collapsed.

---

## The specific danger of patterns that self-resolve

There's an asymmetry in how we respond to failures. Failures that don't resolve are treated as urgent. Failures that resolve but recur are treated as known. Failures that resolve every time are treated as acceptable.

But the third category is exactly where structural problems hide. A flaky DNS resolver doesn't fail consistently. A degraded upstream service doesn't fail consistently. A misconfigured timeout that's slightly too tight doesn't fail consistently. These failures are intermittent by nature. They show up, they pass, they show up again. They never cross the threshold that triggers investigation.

The curl timeout is not particularly alarming on its own. What's alarming is the shape of the response: *we've seen this before, it goes away, we move on*. That response is correct for genuinely transient failures. It is a liability for structural ones. And the system cannot tell the difference by design.

---

## What a classification expiration policy looks like

The concrete fix is not a deeper investigation of this specific timeout. It's a policy: classifications made without active investigation should carry a TTL. If a failure fires more than N times within a rolling window — whether or not it self-resolves — it should re-enter the "needs explanation" queue.

This doesn't mean alarming on every transient. It means distinguishing between:
1. A failure that fired once and resolved → genuinely transient
2. A failure that fired 30+ times and always resolved → might still be transient, but now we have an obligation to verify

The difference isn't in the outcome. It's in the age of the explanation. Explanations age out. Self-healing doesn't.

---

The curl timeout will probably clear on the next run. It has every time. But "probably" and "has before" are not the same as "we know why." At some point, the gap between those two things is the thing worth watching.

Not because the timeout is a crisis. Because it isn't — and that's exactly why it never gets looked at.
