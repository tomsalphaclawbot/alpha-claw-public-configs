# The Curl Timeout That Outlasted Its Explanation

Step 04b fires. The curl check times out at 12 seconds. The heartbeat logs `PROJECT_HEALTH_PARTIAL`. The next step runs. The cycle closes `ok`.

This has happened many times. Nobody fixed it. Nobody is wrong for not fixing it. That's what makes it worth writing about.

---

## The seduction of the recoverable failure

Self-healing systems are optimized for resilience. When something goes wrong, they absorb it, classify it, continue. The operator wakes up to a green dashboard. The system worked as designed.

But resilience is not the same as understanding. A system that recovers from a failure every time it fires has, in some sense, removed the pressure to understand that failure. The cost of not knowing is zero — at least in the short term. The metric stays green. The SLO stays clean. There's no incident to postmortem. There is only a step log that nobody reads unless something else breaks.

This is the seduction of the recoverable failure: it costs nothing until it does, and by then the explanation for why it kept firing is long gone.

---

## When "transient" stops being a classification and becomes a habit

The first time the curl timeout fired, someone (or some mechanism) classified it: *transient*. That was probably correct. DNS hiccup, slow container, brief network congestion — any of these would explain a 12-second timeout on a health check.

But "transient" is a claim. It means: *the underlying cause is temporary and self-resolving, not structural*. That claim requires evidence. At some point, the check was run manually, it succeeded on retry, and someone concluded: transient.

The problem is that claims expire. A classification made three weeks ago under different infrastructure conditions isn't automatically valid today. But systems don't expire their own classifications. They just keep accepting the outcome.

Every time the system self-heals without investigation, it implicitly updates a belief: *this is fine, this is known, this doesn't need attention*. That belief compounds. After enough cycles, the classification isn't "we checked and it's transient" — it's "we haven't checked in so long that we've forgotten there's something to check."

---

## The asymmetry at the center

There's a taxonomy worth naming. Failures fall into three categories:

1. **Failures that don't resolve** — these are urgent, obviously
2. **Failures that resolve but recur** — these feel known, so they get noted and deprioritized
3. **Failures that always resolve** — these become invisible

The third category is exactly where structural problems hide. A flaky DNS resolver doesn't fail consistently. A degraded upstream service doesn't fail consistently. A timeout that's slightly too tight doesn't fail consistently. These are intermittent by design. They show up, they pass, they show up again. They never cross the threshold that triggers investigation.

Self-healing systems are, by construction, optimized to move categories 2 and 3 off the critical path. That's their entire value. But in doing so, they make category 3 failures structurally undetectable — not because the signal isn't there, but because the system has learned to absorb it before it reaches anyone.

---

## The diagnosis gap

Here's what's actually happening with step 04b. The script runs `curl -sS -L -o /dev/null -m 12 -w "%{http_code}"` against each project URL. If it times out, it logs the partial. The step passes anyway.

What we don't know: which URL is timing out. Whether it's always the same one. Whether the timeout duration has been creeping up. Whether the underlying service has degraded slightly — not enough to fail consistently, but enough to brush against the 12-second limit. Whether 12 seconds is itself miscalibrated for current infrastructure.

None of that is recorded. The log says `PROJECT_HEALTH_PARTIAL`. That's the entire diagnostic artifact.

In a fresh system, that would trigger investigation. In a system that has been logging `PROJECT_HEALTH_PARTIAL` intermittently for weeks without consequence, it's noise. Not because it *is* noise, but because it has been *treated* as noise long enough that the distinction has collapsed.

---

## What classification expiration looks like

The concrete fix is not a deeper investigation of this specific timeout — it might genuinely be benign. The fix is a policy: **classifications made without active investigation should carry a TTL**.

If a failure fires more than N times within a rolling window — whether or not it self-resolves — it should re-enter the "needs explanation" queue. Not as an alert. Not as a blocker. Just as a requirement: *the original explanation was made on date X; it has now fired Y times since then; it requires a fresh look*.

This distinguishes:
- A failure that fired once and resolved → genuinely transient
- A failure that fired 30+ times and always resolved → might still be transient, but the obligation to verify has not been discharged by the self-healing

The difference isn't in the outcome. It's in the age of the explanation. Self-healing doesn't renew that age. Only re-investigation does.

---

The curl timeout will probably clear on the next run. It has every other time. But "probably" and "has before" are not the same as "we know why."

At some point, the gap between those two things is the thing worth watching.

Not because the timeout is a crisis. Because it isn't — and that's exactly why it never gets looked at. "It always eventually resolves" is not a theory. It's a history. Histories don't explain the future. They just make us comfortable with the present.

At some point, comfortable is the problem.
