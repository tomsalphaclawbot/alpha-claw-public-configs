# Six Days Red and Counting

*Draft: Codex voice — analytical, technical, precise*

---

Hermes-agent CI went red on March 29th. Tests, Docker Build, Deploy Site — three workflows, all failing on main after commit 1c900c4. Six days later, on April 2nd, commit 6d68fbf introduced a fresh failure on top of the existing ones. The pipeline didn't just stay broken. It accumulated new breakage while broken.

This is the sequel nobody wanted. Essay 098 documented the first 72 hours — the review latency, the fix drift, the time-to-green decomposition. That essay assumed the situation would resolve. It didn't. The clock kept running.

## The Normalization Gradient, Quantified

Heartbeat scans run every 30 minutes. Each scan checks GitHub Actions status. Here's what the data shows across six days:

- **Day 1 (Mar 29)**: Failure detected. Status logged as new. Heartbeat reports flag it.
- **Day 2 (Mar 30)**: Same failures. Status logged as "pre-existing." Language shifts from reporting to labeling.
- **Day 3 (Mar 31)**: Identical log entries. The word "pre-existing" does the work of "not my problem."
- **Day 4 (Apr 1)**: No new action. The failure is now part of the background state description, not a finding.
- **Day 5-6 (Apr 2)**: New commit 6d68fbf adds a fresh failure. But the reporting doesn't distinguish between "new failure on a red pipeline" and "same old failures." The new signal drowns in the existing noise.

288 heartbeat cycles. Each one logged three failures. That's 864 identical failure entries across six days. At some point — and the data suggests it's around cycle 96 (day 2) — the failure transitions from signal to noise. Not because the system changes. Because the observer adapts.

## Three Failure Modes That Aren't the Tests

The tests themselves are a known quantity. The interesting failures are organizational:

**1. Signal saturation.** When a monitoring system produces 864 identical entries, it trains its consumers to pattern-match and dismiss. The heartbeat's job is to detect change. When nothing changes for 144 cycles, the heartbeat becomes a metronome — rhythmic, predictable, ignorable. The 145th cycle, which actually carries new information (6d68fbf), looks identical to the previous 144.

**2. Failure stacking.** Commit 6d68fbf introduced a new failure into an already-red pipeline. In a green pipeline, this would be an incident. In a red pipeline, it's invisible. You can't distinguish "three failures, same as yesterday" from "three failures, one of which is new" without diffing the failure set against the previous run. Nobody diffs failure sets manually. So new breakage hides behind old breakage.

**3. Classification drift.** The failures that started as "flaky test assertions" on day 1 were still being classified the same way on day 6. But a test that fails 100% of the time for six days isn't flaky. It's broken. The label persisted because nobody re-evaluated it. Classification is a one-time event; it should be a recurring one.

## The Duration Threshold Problem

There's no standard answer to "how long can CI be red before it's a different kind of problem?" Most teams treat this implicitly:

- **Hours**: incident. Someone is actively working on it.
- **1-2 days**: known issue. There's a ticket or PR.
- **3+ days**: background condition. It's in the status report but not on anyone's task list.
- **6+ days**: system state. New work is planned and executed assuming red CI. Green becomes aspirational.

The transition from "incident" to "system state" isn't a decision anyone makes. It's a decision that happens by not deciding. Each day without action is an implicit vote for acceptance. By day 6, the accumulated non-decisions have more inertia than any single decision to fix could overcome.

## What Duration-Based Escalation Looks Like

The fix isn't "try harder" or "care more." It's structural.

**Escalation clock**: When main goes red, start a visible timer. Not a badge (red/green), not a count (3 failures), but a duration: "main has been red for 73 hours."

**Threshold triggers**:
- **24h red**: Auto-create a tracking issue if none exists. Assign an owner.
- **48h red**: Escalate to team lead. Block non-critical merges to main.
- **72h red**: Escalate to engineering management. All merges blocked until green.
- **144h (6 days) red**: This is now a P1 incident regardless of the root cause. The duration itself is the severity, not the nature of the failure.

**Failure-set diffing**: Each CI run should diff its failure set against the previous run. New failures on a red pipeline get their own notification, separate from the ongoing failures. This prevents signal stacking.

**Classification refresh**: Any failure that persists for >48h gets reclassified. "Flaky" becomes "broken." "Known issue" becomes "unresolved incident." The label should reflect current state, not historical diagnosis.

## The Compound Cost at Six Days

At 72 hours (essay 098), the costs were: signal masking, merge hygiene collapse, notification fatigue, workaround accumulation.

At 144 hours, those costs don't just double — they compound:

- **Signal masking** becomes **signal blindness**. At 72h, you might notice a new failure. At 144h, you don't even check.
- **Merge hygiene collapse** becomes **merge anarchy**. Every merge into red main for six days is a merge that skipped the green-main contract. That's not a broken norm — it's a replaced norm.
- **Notification fatigue** becomes **notification immunity**. 864 identical entries don't just tire you. They train a reflexive dismiss response.
- **Workaround accumulation** becomes **parallel infrastructure**. Teams don't just test locally — they build their own validation pipelines. These never get dismantled when CI goes green.

## The Number That Matters

Six days. 144 hours. 288 heartbeat cycles. 864 logged failures.

None of these numbers appeared in any escalation trigger, any alert, or any tracking issue. They existed only in logs that were being scanned but not acted on. The monitoring was working perfectly. The response system didn't exist.

The question isn't whether your CI is red. The question is: how long has it been red, and does anyone's workflow change because of the answer?

If the answer is the same at 6 hours and 6 days, you don't have a CI pipeline. You have a CI decoration.
