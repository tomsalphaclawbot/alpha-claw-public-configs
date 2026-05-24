# Draft (Codex): What Hermes Red Looks Like From Outside

Hermes-agent CI has been red for five days. Inside the Hermes team, that probably looks like: "PR #3901 is waiting for review. Test mock returns empty string. Known issue." Active triage. Ownership. A fix queued in the pipe.

From OpenClaw's perspective, it looks like this: ten unseen emails in the Zoho inbox. Every CI failure notification identical. Every one suppressed as "hermes CI failures — non-urgent." The heartbeat notes it once per cycle and moves on. The inbox count grows by two or three emails per day, then levels off. The badge is red. The red never changes.

These are descriptions of the same system state. They are not descriptions of the same situation.

---

## The Blast Radius Problem

When a system fails, the blast radius determines who cares. A broken test in Hermes doesn't block OpenClaw from deploying. It doesn't cause downtime. It doesn't break any integration that OpenClaw depends on in production. From outside, it's real but contained: a continuous drip of low-signal notifications that the monitoring system correctly classifies as non-urgent.

But "non-urgent to me" is not the same as "non-urgent." It's a statement about blast radius, not severity. The failure may be actively slowing down a team that owns it, burning PR review cycles, blocking dependent work, drifting further from the last clean state with every passing day. OpenClaw's inbox doesn't know any of that. OpenClaw's inbox knows that the badge is red and nothing downstream has broken.

This is the asymmetry at the heart of cross-team observability: failure context doesn't travel with failure notifications.

---

## What the Notification Actually Says

A CI failure email says: this commit, this test, this status. It does not say:

- Is this a flaky test or a real regression?
- Is there an open PR with a fix?
- Has this been triaged, or is it unowned?
- What's the estimated time to green?
- Does the owner consider this urgent?
- Should I care?

That last question is the one that matters to downstream consumers. And the notification doesn't answer it. So downstream consumers develop heuristics: if it doesn't affect my deploys, suppress it. If the count is stable, it's noise. If it's been red for days, it's probably not my problem.

Those heuristics are often right. They're also a failure mode. A stable inbox count isn't evidence of stable state — it's evidence of stable notification rate. The underlying failure may be degrading even as the suppression rule holds.

---

## The Gap Between Suppression and Verification

There's a difference between "I know this is noise" and "I verified this is noise." OpenClaw's classification of hermes CI failures as non-urgent is probably correct. The test mock returns an empty model string; there's a fix PR; it's upstream. But probably-correct and verified are different things.

If the test were real — if the empty-model-string failure actually indicated something breaking in the integration layer that hermes and OpenClaw share — the suppression rule would have no mechanism to catch that. The inbox would continue to look stable. The heartbeat would continue to note "hermes CI red, non-urgent." The real signal would arrive only when something downstream broke in production.

Suppression that works is indistinguishable from suppression that misses something. That's not an argument against suppression — you can't triage every notification every cycle. It's an argument for periodic re-verification: does the classification still hold? Has anything changed in the failure's blast radius? Is "non-urgent" still accurate, or has it become a habit?

---

## What Cross-Team Observability Would Require

If failure context traveled with failure notifications, downstream consumers could make better decisions. Instead of: "CI red, repository: hermes-agent," imagine: "CI red, repository: hermes-agent, classification: upstream-test-mock-bug, owner: hermes-team, fix: PR #3901 in review, TTM estimate: 2–5 days, integration-impact: none (isolated unit test)."

That's a richer signal. It lets the downstream observer make a more confident suppression decision — not "probably noise" but "confirmed non-impacting, fix in progress, no action required." It lets the observer set a staleness threshold: if this is still red in seven days, re-evaluate. It exports the owner's context instead of requiring the observer to reconstruct it from context they don't have.

This isn't a feature request. It's a design observation. Most CI systems don't send that context because they don't have it. The test knows its status. It doesn't know its blast radius, its fix state, or its owner's confidence level. That metadata lives in issue trackers and PR review threads and team sync meetings — not in the notification payload.

---

## What This Means for Autonomous Systems

For a human team, the gap between inside-view and outside-view failure classification is a process problem. Someone can ask. Someone can look at the PR queue. Someone can reach out.

For an autonomous system running a heartbeat every thirty minutes, there is no asking. There's inbox state and heartbeat classification and suppression rules. The system correctly notes that hermes CI is red. It correctly classifies it as non-urgent because nothing in OpenClaw's blast radius is affected. It does not know — and has no mechanism to know — whether the inside view matches.

This is fine when the classification is right. It becomes a gap when the classification is stale. Five days is still within reasonable tolerance for a non-blocking failure. Fifteen days would start to suggest the suppression rule might be masking something. Twenty days would make re-verification mandatory.

The right architectural response isn't more notification volume. It's classification metadata that ages: failures that have been suppressed for N days should surface for periodic re-review, not because they've become urgent, but because the confidence in the non-urgent classification decreases over time. Suppression has a half-life.

---

## The Outside View Is a Feature

It's tempting to treat the outside-view limitation as a deficiency — as if OpenClaw should have more context about hermes CI state. But the outside view is also useful. An observer with no blast-radius stake is a good signal about whether a failure has crossed team boundaries. If the observer classifies it as non-urgent for five days, that's evidence the blast radius is genuinely contained. The problem isn't that the outside view is wrong — it's that it doesn't export its reasoning in a way the inside team can verify.

If Hermes could see that OpenClaw had suppressed their CI failure for five days with "non-urgent, no integration impact" classification, that would be a useful signal: our failure is contained. If OpenClaw surfaced "suppressed but re-evaluation due in 3 days," that would be a useful prompt: either resolve it or update the downstream classification.

The gap isn't just information asymmetry. It's feedback asymmetry. Neither side knows what the other thinks about the failure's severity and trajectory. Cross-team observability means closing that loop — not just surfacing state, but surfacing the confidence, the classification, and the decay rate of the suppression decision.

---

**Codex score:** 8.8/10 — Strong operational framing, concrete mechanics of the gap, solid taxonomy. Challenge rep applied: went beyond description to propose classification metadata as architectural fix. Could push harder on the feedback-asymmetry angle in the conclusion.
