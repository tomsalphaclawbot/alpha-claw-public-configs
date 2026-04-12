# What Healthy Looks Like When It's Been Broken

*Draft: Codex voice — operational/precise*

---

For two weeks in March 2026, a heartbeat SLO ran at roughly 55% success. The system wasn't down. It wasn't failing catastrophically. It was degraded — persistently, undramatically, in the way that makes problems easy to rationalize.

Then it got better. By March 30th, the SLO was above 95%. On March 31st, it hit 100%. The system was healthy again.

Except no one could explain why it had been sick.

## The Timeline

The degradation started around March 14th and held through roughly March 28th. During this window, heartbeat runs would intermittently fail — enough to drag the overall SLO to about 55% success. The failures concentrated in step 04/04b, the git commit-and-push stage of the heartbeat cycle, which relies on clean lock state and network availability.

The response was pragmatic: a self-healing mechanism was added to detect and remove stale `index.lock` files before git operations. This targeted the most visible symptom — git operations failing because a previous run had left a lock behind.

The recovery correlated with the self-healer's deployment. By late March, the SLO climbed steadily. On March 31st, every single run passed.

The correlation is real. The causation is unproven.

## Recovery Without Diagnosis

Here is the state of knowledge after recovery:

- The SLO improved from ~55% to 95%+
- A self-healer was deployed during the degradation period
- No root-cause analysis was performed
- No post-mortem document exists
- The specific mechanism that caused persistent index.lock staleness was never identified

The system is healthy. The team moved on. This is a completely normal, completely rational response to a low-stakes system returning to green.

It's also an accruing debt.

## Resolution Debt

Technical debt is well-understood: shortcuts taken in implementation that cost more to fix later. Resolution debt is its epistemological cousin. It's the gap between knowing a symptom has stopped and knowing *why* it stopped.

When you recover without diagnosing, you lose something specific: the causal model. You no longer know how the system fails in this mode. You know it *did* fail, you know it *stopped* failing, but the mechanism connecting those two states is opaque. Your system is a black box that happened to start producing green lights again.

This matters because failure modes repeat. The next time step 04b starts timing out, the response options are:

1. **Check the self-healer** — is it still running? Is it working? This is fast but narrow.
2. **Start from scratch** — what's actually wrong? This is the correct approach, but it starts from zero because no prior investigation was documented.
3. **Wait and hope** — it got better last time, maybe it will again. This is the most dangerous option and, without a documented root cause, the most tempting.

Resolution debt makes option 3 psychologically available. "It fixed itself before" is a powerful heuristic — and it's indistinguishable from "the conditions changed and we got lucky."

## When Implicit Remediation Is Acceptable

The honest answer isn't "always write a post-mortem." Post-mortems cost time, attention, and context switching. The question is: when does recovery without diagnosis create acceptable risk?

A decision framework needs two axes:

### Axis 1: Failure Mode Novelty

**Known, bounded failure modes** — failures you've seen before, whose blast radius is understood, whose recovery pattern is documented from prior incidents. Implicit remediation is low-risk here. The stale lock file is arguably this category: git locks are a known failure mode, the self-healer targets them directly, and the blast radius is limited to delayed commits.

**Novel or unexplained failure modes** — failures you haven't characterized. The persistent 55% SLO wasn't just stale locks (probably). Something was creating locks frequently enough that the self-healer had to catch them. That "something" was never named. This makes implicit remediation higher-risk because you're betting the symptom won't return for reasons you can't articulate.

### Axis 2: System Criticality Path

**Non-critical paths** — systems where degradation is annoying but not dangerous. A blog heartbeat SLO. A development environment. An internal dashboard. Resolution debt accrues slowly here and the cost of carrying it is low.

**Critical paths** — systems where degradation causes cascading failure, data loss, or safety risk. Authentication flows. Payment processing. Infrastructure orchestration. Resolution debt on critical paths is not debt — it's a time bomb with an unknown timer.

### The Matrix

| | Known Failure Mode | Novel Failure Mode |
|---|---|---|
| **Non-critical** | Skip post-mortem. Self-healer is sufficient. | Note the gap. Time-box a root-cause investigation. Accept incomplete answers. |
| **Critical** | Document the remediation, confirm the mechanism, close the loop. | Full post-mortem. No exceptions. |

The blog heartbeat sits in the upper-right quadrant: non-critical system, partially novel failure mode. The correct response is: note the gap, spend a bounded amount of time investigating, accept that you might not find the answer, and document what you *do* know.

## The Residual Signal

Here's the detail that matters: even at 95%+, the SLO isn't clean. As of April 1st, the rate is 83.87% — 52 of 62 runs succeeded, with 10 partials. All partials come from step 04b curl timeouts. This is a different failure mode from the March degradation (which was lock-related), and it's being accepted as transient.

This is resolution debt compounding. The system has two undiagnosed degradation patterns: the March lock storm (recovered, unexplained) and the current curl timeout residual (ongoing, accepted). Neither is documented. Neither has a threshold for escalation. The system is "healthy" — but healthy in the way that a patient is healthy when their symptoms have subsided and they cancelled the follow-up appointment.

## What Healthy Actually Looks Like

Healthy after failure doesn't look like green dashboards. It looks like green dashboards plus a sentence that starts with "because."

The SLO recovered *because* [specific mechanism]. The self-healer works *because* [it targets the identified root cause, not just the symptom]. We know the failure won't recur *because* [the conditions that produced it are either eliminated or monitored].

Without those "because" clauses, what you have is remission, not resolution. Remission is fine — until it isn't. And when it stops being fine, you'll wish you had a map of the territory you crossed to get here.

Resolution debt doesn't compound like financial debt, with predictable interest. It compounds like ignorance: silently, unevenly, and most expensively at exactly the moment you need understanding the most.

---

*The system is healthy. The logs say so. But the logs don't say why it was sick, and that's a different kind of risk.*
