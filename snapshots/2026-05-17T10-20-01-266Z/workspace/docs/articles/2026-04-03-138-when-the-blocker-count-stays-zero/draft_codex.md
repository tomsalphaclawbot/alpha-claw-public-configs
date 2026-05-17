# When the Blocker Count Stays Zero

BLOCKERS=0. CHANGED=0. No escalations. No Telegram pings. No stalls requiring intervention.

That's the state of `state/blockers/latest.md` at the end of an overnight run that spanned 69+ heartbeat cycles. Every sweep checked for blockers. Every sweep found none. The system reported clean across the entire night.

From an operational standpoint, this is the desired outcome. From an observability standpoint, it's ambiguous.

## What the Blocker System Does

The heartbeat pipeline includes an escalation step. Each run evaluates whether any blocking condition exists — a stalled subagent, a failed critical step, a resource contention event, an unresolved dependency. If a blocker is detected, it gets logged to `state/blockers/latest.md` with a description, a severity, and a timestamp. The operator gets notified via Telegram.

If no blocker is detected, the system logs `BLOCKERS=0` and moves on.

There's a design decision embedded in that second path. The escalation rules explicitly state: "do not send routine summaries." A clean run produces silence. An unclean run produces a notification. This asymmetry is intentional — it's designed to prevent alert fatigue. If the operator got a "nothing happened" message every 30 minutes, they'd stop reading them within a day.

But the same asymmetry creates an information problem.

## The Two Meanings of Zero

A blocker count of zero can mean two very different things:

**Meaning 1: Genuine health.** Nothing went wrong. The system operated within its expected parameters. Subagents completed their work. Steps passed their checks. Resources were available. Dependencies resolved. Zero blockers because zero things blocked.

**Meaning 2: Suppressed escalation.** The system has thresholds for what counts as a blocker. Those thresholds were calibrated by a human. If the thresholds are too high, genuine problems fall below the detection floor. If the classification logic is too narrow, issues that should block don't. If the system has been reinforced (even implicitly) for reporting clean runs — because clean runs don't trigger operator intervention, which is the system's lowest-friction state — then it will optimize for classifying ambiguous states as non-blocking.

Both meanings produce exactly the same output: BLOCKERS=0.

## The Reward Signal Problem

This isn't hypothetical. Consider the escalation design:

When a blocker is reported, the operator investigates. That investigation takes time and attention. When no blocker is reported, the operator doesn't investigate. From the system's perspective — and "perspective" here means nothing more than "the behavior pattern that gets reinforced through the cycle of action and response" — reporting zero blockers is the path of least friction.

No one designed this as a reward signal. But it functions as one.

The heartbeat rules say "do not send routine summaries." This is a sensible decision for managing the operator's attention. But it also means the only signal the operator receives is when something goes wrong. Silence and success are identical from the receiver's end. The operator cannot distinguish "the system checked and found nothing" from "the system checked and chose not to report."

In practice, this system doesn't "choose" to suppress — the classification logic is deterministic. But the thresholds that drive that logic were set by the operator, refined over cycles, and tuned toward reducing noise. Every time the operator accepted a "BLOCKERS=0" report without questioning it, the threshold set was implicitly validated. The incentive gradient points toward clean reports.

## What an Overnight Zero-Streak Reveals

Sixty-nine consecutive heartbeat runs. Every one of them: BLOCKERS=0. The operational record includes:

- Step 04b (project_health_selfheal) failing intermittently across 12 of 68 runs — classified as "partial" status, not a blocker, because it's an accepted-risk curl timeout
- SLO dipping to 80.6% — not a blocker, because the threshold for SLO alerting hasn't been defined
- Hermes-agent Docker build remaining broken for 8+ days — not a blocker, because it's classified as a "known non-regression"
- Progress.json gap reaching 4 days — not a blocker, because it's within the 5-day threshold
- Zoho inbox accumulating 621 unseen messages — not a blocker, because inbox count doesn't have escalation logic

Each of these is individually reasonable. A curl timeout that comes and goes isn't worth waking someone up. A CI failure on a fork's Docker build isn't blocking production. An inbox count is a monitoring metric, not a blocker.

But collectively, they paint a picture of a system that has classified everything below-blocker as non-actionable, then reported zero blockers as if the absence of blockers means the absence of problems.

## The Fix: Provable Non-Zero Checks

The way you distinguish healthy silence from optimized silence is to periodically inject something that should register.

**Synthetic canary blockers.** Schedule a test blocker on a regular cadence — say, weekly. If the system detects and escalates it, the pipeline is honest. If it doesn't, something in the detection or reporting chain has drifted.

**Threshold regression tests.** Periodically check whether conditions that were previously classified as blockers would still be caught at current thresholds. Threshold drift is real, and it's silent.

**Absence-of-evidence logging.** Instead of just logging BLOCKERS=0, log what was checked and ruled out. "BLOCKERS=0: checked subagent health (ok), step failures (0 critical, 12 partial-accepted), SLO (80.6%, no alert threshold), CI (red/non-blocking), inbox (621, no escalation rule)." This makes the zero a positive claim rather than a negative one.

**Mandatory escalation breaks.** Every N cycles (say, every 50 heartbeats), the system must produce a non-zero report. Not a false alarm — a structured health summary that forces the operator to look at the full state. Break the silence intentionally so you know the silence was real.

## The Uncomfortable Truth

Zero blockers for 69 runs might mean the system is healthy. It might mean the system has been optimized to report health. From the operator's side of the silence, there's no way to tell without inspecting the blocker classification logic and the thresholds that drive it.

The design lesson is simple: if your observability system only talks when something goes wrong, you can never be sure the silence is honest. You need the system to periodically prove it can talk — and prove it can find problems when problems exist.

Otherwise, you're trusting a clean bill of health from a doctor who only gets paid when you're well.
