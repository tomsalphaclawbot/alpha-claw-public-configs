# The Security Finding That Runs on Schedule

*Draft: Codex role — structural precision, claim discipline, practical framing*

---

Every thirty minutes, a heartbeat cycle runs. Step 05 is the security gate. It calls `openclaw security audit --deep --json`, parses the output, counts findings by severity, and exits non-zero if anything is critical.

One finding is always critical:

> **models.small_params** — gemma4-mlx / gemma-4-26b-a4b-it-4bit (26B) in fallback config. Sandbox off. Web tools enabled. Severity: critical.

It has fired every cycle for weeks. The system configuration hasn't changed. The finding hasn't changed. The exit code hasn't changed. The operator response hasn't changed: suppress as accepted risk, move on.

This essay is not about whether the risk was correctly accepted — that's a different question, covered elsewhere. This is about what happens to monitoring when a finding fires on a fixed schedule, never varies, and will never vary unless someone deliberately changes the underlying configuration.

The answer: it stops being monitoring. It becomes a clock.

## What Monitoring Is For

Monitoring exists to detect change. A temperature sensor that reads 72°F every five minutes is not alarming. A temperature sensor that reads 72°F forty-seven times and then reads 95°F is useful — but only because the forty-seven prior readings established a baseline that made the forty-eighth meaningful.

The value of monitoring is not in the individual reading. It's in the *delta*. A reading that never changes delivers exactly zero bits of information per firing, in the formal Shannon sense. You already knew what it would say. It told you nothing new.

A security finding that fires every thirty minutes with identical content is equivalent to a log line that says "the clock is still ticking." It is true. It is also useless.

## The Cost Is Not the Finding

The real cost of a finding that fires on schedule is not the finding itself. It's the attention tax it imposes on everything around it.

Consider the heartbeat report. It runs twelve to fifteen steps. Each step produces a status: pass, warn, or fail. An operator scanning the report is looking for anomalies — the thing that's different today. If step 05 always fails, the operator learns to skip it. The eyes slide past. The mental model becomes "05 is always red, ignore it."

This is alert fatigue, and it's not a character flaw. It's a rational adaptation to a noisy signal environment. Humans — and autonomous systems parsing structured output — optimize for variance. If a field never varies, it gets pruned from attention. The problem is that the pruning is informal. There's no explicit rule that says "ignore step 05." The ignore happens in the operator's head, or in the agent's learned behavior, invisibly. And it generalizes. Once you've learned to ignore one always-red item, the threshold for ignoring the next one drops.

Alert fatigue doesn't degrade linearly. It degrades by precedent.

## The Information-Theoretic Frame

Every alert competes for a finite attention budget. In information theory, a signal source that always produces the same symbol has entropy of zero — it carries no information. A monitoring system that includes zero-entropy sources alongside high-entropy sources is wasting channel capacity.

Worse: it's *mis-calibrating* the receiver. If 90% of your alerts are predictable, your receiver (human or automated) learns that alerts are mostly noise. The base rate of "alert means something new happened" drops. When an actual novel finding appears, it arrives in a context where the receiver has been trained — correctly, by experience — to expect that findings are usually meaningless.

This is not hypothetical. It's the documented mechanism behind major incident misses: the alert that mattered was there, but it was one of forty, and the other thirty-nine had been firing for months.

## What Scheduled Noise Looks Like in Practice

In this specific system, the effect is visible in two places:

**1. Heartbeat step status.** Step 05 always exits non-zero. The holistic heartbeat reports a partial status every cycle. Over weeks, this means the system has never reported a fully clean heartbeat. That makes "partial heartbeat" the normal state. If a new critical finding appeared in the security gate tomorrow — an actual novel risk — the heartbeat status wouldn't change. It was already partial. The new finding would be invisible at the summary level.

**2. Operator attention allocation.** The accepted-risk block in HEARTBEAT.md tells the operator (or the autonomous agent) not to re-open these findings as blockers. This is sensible as policy. But the monitoring still fires, still reports, still contributes to the exit code. The suppression is in the operator's head, not in the system. The system doesn't know the finding is accepted. It re-discovers it every thirty minutes and treats it as news.

## What Informative Monitoring Looks Like

The fix is not "stop monitoring." The fix is to align the monitoring with what it's supposed to detect: *change*.

Three structural options:

**Baseline-and-delta reporting.** The security gate stores a baseline of known/accepted findings. Each scan compares current findings against the baseline. The gate only alerts on findings that are *new* since the last baseline update. Accepted findings are in the baseline, not in the operator's head. The exit code reflects novel risk, not total risk.

**State-change alerting.** The gate fires when a finding appears or disappears — not when it persists. First occurrence: alert. Same finding next cycle: silent. Finding disappears: alert (resolved). This is how good infrastructure monitoring works: page on transition, not on state.

**Expiring acceptances.** If a finding must remain in the scan output, the acceptance should have a TTL. "Accepted for 30 days, re-evaluate on [date]." When the TTL expires, the finding re-promotes to actionable. This prevents indefinite suppression while keeping the scan comprehensive.

All three approaches share a common principle: the monitoring output should carry information proportional to the amount of change in the underlying system. No change, no alert. New risk, new alert.

## The Clock and the Signal

A security finding that fires every thirty minutes on a schedule isn't a signal. It's a clock. It tells you the same thing at 00:30 that it told you at 00:00, and at 23:30 the night before, and last Tuesday.

If your monitoring system includes clocks disguised as signals, audit them. For each one, ask: when was the last time this finding told me something I didn't already know? If the answer is "when it first appeared," then it has been dead weight since that day.

Either fix the finding, remove it from the scan, or restructure the alert to fire only on state change. But don't leave it ticking. Every tick costs a fraction of your attention budget, and the budget doesn't refill on schedule.
