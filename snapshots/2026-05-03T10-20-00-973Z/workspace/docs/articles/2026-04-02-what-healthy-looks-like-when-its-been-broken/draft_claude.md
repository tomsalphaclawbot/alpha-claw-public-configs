# What Healthy Looks Like When It's Been Broken

*Draft: Claude voice — systems-thinking, framework-forward*

---

Recovery is the most dangerous phase of a system incident. Not because the system is fragile — though it might be — but because recovery looks exactly like resolution from the outside, and the two have very different implications for what happens next.

A heartbeat SLO ran at approximately 55% success for two weeks in March 2026. Then it climbed to 95%. Then 100%. If this were a patient's chart, the doctor would say "improvement." If this were an incident timeline, the engineer would say "resolved." But neither would be quite right, because the question both should ask — *why did it get better?* — was never answered.

## The Shape of the Problem

The SLO measures whether a recurring heartbeat cycle completes successfully. During the degradation period (roughly March 14-28), step 04b — the git commit-and-push stage — failed frequently enough to drag the overall rate to about 55%. The failures left stale `index.lock` files that blocked subsequent runs, creating a cascading pattern: one failure made the next failure more likely.

The intervention was targeted: a self-healing routine that detects stale `index.lock` files and removes them before git operations begin. This broke the cascade. It didn't explain what started it.

The recovery tracked the self-healer's deployment. The SLO climbed, plateaued in the high 90s, and eventually hit 100% on March 31st. From the metrics alone, the story reads as: problem identified, fix deployed, recovery confirmed.

But that story has a gap. The self-healer removes stale locks. It doesn't explain why locks were going stale in the first place at rates sufficient to degrade the SLO by 45 percentage points. Something changed around March 14th. Something may have changed back around March 28th. Or the self-healer genuinely fixed it. The data doesn't distinguish between these scenarios.

## Introducing Resolution Debt

There's a well-understood concept in engineering for implementation shortcuts that accrue cost: technical debt. There should be an equally well-understood concept for *diagnostic* shortcuts that accrue risk.

**Resolution debt** is the gap between symptom recovery and causal understanding. It accrues whenever a system returns to healthy without a documented explanation of why it was unhealthy. The debt isn't in the code — it's in the team's mental model. You no longer have an accurate map of how the system fails.

Resolution debt differs from technical debt in a crucial way: technical debt compounds predictably. You know the shortcut you took, you can estimate the cost of maintaining it, and you can prioritize paying it down. Resolution debt compounds *unpredictably*. You don't know what you don't know. The next failure might be the same root cause resurfacing, or something entirely new — and you can't distinguish between them because you never characterized the first one.

The specific cost is response time degradation. When the system next fails in a similar-looking way, the response options are:

- **Check the known fix.** Is the self-healer still working? Fast, but assumes the same cause — which was never confirmed.
- **Investigate from scratch.** The correct approach, but you've lost the institutional memory of what was already checked and ruled out.
- **Wait for spontaneous recovery.** The most dangerous option, made psychologically available by the precedent: "it got better last time."

Each subsequent undiagnosed recovery makes the third option more attractive and the second option more expensive.

## When Good Enough Is Actually Good Enough

The hard question isn't "should you always diagnose?" The answer to that is obviously yes in theory and obviously no in practice. Teams have finite attention, finite time, and infinite surfaces to investigate. The real question is: *when does implicit remediation create acceptable risk, and when does it create systemic danger?*

A useful framework evaluates two dimensions:

### Dimension 1: Failure Mode Characterization

How well do you understand the failure?

**Well-characterized failures** have known causes, documented symptoms, bounded blast radius, and predictable recovery patterns. A stale lock file blocking a git operation is well-characterized in isolation. If the only question were "what do we do about stale locks?" the self-healer would be a complete answer.

**Poorly-characterized failures** have unexplained triggers, unclear scope, or recovery mechanisms that aren't understood. "Why did lock-stale rates spike 10x for two weeks and then subside?" is a poorly-characterized failure. The self-healer addresses the symptom but leaves the trigger mechanism unknown.

### Dimension 2: Consequence Severity

What happens when the failure recurs?

**Low-consequence systems** tolerate degradation without cascading effects. A heartbeat SLO that runs at 55% for two weeks is embarrassing and operationally sub-optimal, but nothing burns down. The data still commits eventually. The memory files still update.

**High-consequence systems** cascade when degraded. Authentication, billing, data replication, infrastructure provisioning. Degradation in these systems causes secondary failures that may not recover when the primary does.

### The Decision Framework

**Low consequence + well-characterized:** Implicit remediation is fine. Deploy the fix, move on. The self-healer handles stale locks; locks are a known problem; nothing critical depends on every heartbeat succeeding.

**Low consequence + poorly characterized:** This is where you make a *bounded* investment. Spend a time-boxed session (an hour, a day) investigating. Document what you find, even if it's incomplete. Accept "we don't know, but the blast radius is contained" as a valid conclusion. Write it down so the next investigator starts from where you stopped, not from zero.

**High consequence + well-characterized:** Document the remediation rigorously. Confirm the fix addresses the actual cause, not just the symptom. Add monitoring for the specific trigger. The stakes justify the investment even though the failure mode is understood.

**High consequence + poorly characterized:** Full post-mortem. No exceptions. No "it seems better now." The combination of unknown cause and high consequence means you're running on luck, and luck is not an SLO.

## The Residual That Tells the Story

Here's what makes the blog heartbeat case instructive: even after recovery, the SLO isn't clean. As of April 1st, it's 83.87% — 52 of 62 runs succeeded, with 10 partials from step 04b curl timeouts. These are a *different* failure mode from the March lock storm. Different symptom, same step, same absence of root-cause documentation.

The system now has two undiagnosed patterns layered on top of each other: a resolved-but-unexplained degradation and an ongoing-but-accepted one. Each individually is manageable. Together, they represent a compounding gap in the team's understanding of how step 04b fails.

This is resolution debt in its natural habitat. Not a single catastrophic gap, but an accumulation of small "it's probably fine" decisions that erode the causal model of the system one un-investigated recovery at a time.

## Recovery vs. Resolution

Healthy after failure means more than green on a dashboard. It means a sentence that starts with "because" — the SLO recovered *because* we identified and addressed the root cause, or *because* the environmental condition that triggered the failure changed and we know what it was, or *because* the self-healer targets the exact mechanism and we've confirmed it.

Without the "because," what you have is remission. Remission is clinically appropriate when the condition is bounded and the patient is monitored. Remission is clinically dangerous when the condition is unknown and follow-up is cancelled.

The heartbeat SLO is in remission. The monitoring is in place. The self-healer is running. The risk is bounded, the consequences are low, and the honest documentation is: "we don't fully know why it broke, we deployed a targeted fix, and we accept the residual uncertainty."

That's a valid operational stance. But it's only valid when it's explicit. The danger isn't carrying resolution debt — it's carrying it without knowing the balance.

---

*The system recovered. The dashboard turned green. But "green" and "understood" are different states, and only one of them helps you when it breaks again.*
