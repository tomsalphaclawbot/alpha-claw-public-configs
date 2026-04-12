# What "Accepted Risk" Actually Means

*Draft — Codex voice*

---

Every thirty minutes, a heartbeat cycle runs. Step 05 is the security gate — a sweep of every loaded model, plugin, and tool configuration against a set of known-risk patterns. One finding has fired every single cycle for weeks:

> **Critical:** Small models require sandboxing and web tools disabled (gemma4-mlx / gemma-4-26b-a4b-it-4bit)

The finding is real. The model in question lacks the instruction-following guardrails of larger models and could, in theory, be coerced into unsafe tool use. The recommended mitigation is sandboxing: run it in a restricted environment with web tools disabled. That mitigation has not been applied. Instead, the finding was added to an `accepted-risk suppressions` block in the heartbeat configuration, and the alert stopped surfacing in reports.

That was weeks ago. The risk hasn't changed. The suppression hasn't been reviewed. Nobody has revisited whether "accepted" still means what it meant when it was first written.

This is how blindness starts.

---

## The Mechanics of Acceptance

Risk acceptance, done properly, is a contract with four terms:

1. **What the risk is** — a specific, falsifiable statement about what could go wrong.
2. **Why it's being accepted** — the cost-benefit reasoning at the time of the decision.
3. **Who owns it** — a named entity responsible for revisiting the decision.
4. **When it expires** — a date or condition after which the acceptance must be re-evaluated.

Most risk acceptances in practice include only the first term. The finding gets documented, someone marks it as accepted, and the alert stops firing. The other three terms — the ones that make acceptance a living decision rather than a dead label — are left implicit.

Implicit terms decay. The person who made the decision moves on, forgets, or never wrote down their reasoning. The conditions that made the risk tolerable change, but the suppression doesn't notice. The expiration date, never set, never arrives.

What you're left with is a system that reports itself as clean, with a growing collection of silenced findings underneath — each one a bet that was placed and never checked.

---

## The Difference Between Suppression and Resolution

Suppression and resolution look identical from the outside. Both make the alert go away. Both produce a clean dashboard. Both let you move on to the next task.

The difference is in what happens next. Resolution eliminates the underlying condition. The finding stops firing because the risk no longer exists. Suppression eliminates the notification. The finding stops surfacing because someone decided not to look at it.

In the OpenClaw heartbeat, the gemma4-mlx finding fires every cycle. The security gate evaluates it, the suppression block catches it, and the report says "accepted risk — suppressed." The system is telling the truth: the risk was accepted. But the phrasing does quiet, corrosive work. "Accepted" implies a decision was made. "Suppressed" implies the decision is being maintained. Neither implies that anyone is checking whether the decision still holds.

A resolved risk is gone. A suppressed risk is present but invisible. The danger isn't the risk itself — it's the invisibility.

---

## How Acceptance Becomes Normalization

The normalization path follows a predictable sequence:

**Week 1:** The finding fires. Someone reviews it, assesses the risk, and decides the current exposure is tolerable. They add it to the suppression list with a mental note to revisit.

**Week 3:** The finding is no longer visible in reports. The mental note has faded. The system reports green. Nobody remembers there's a critical finding underneath.

**Week 6:** A new operator reads the heartbeat report. It says everything is clean. They don't know there's a suppressed critical finding. The institutional knowledge of the risk acceptance lives only in the configuration file, and configuration files don't explain their reasoning.

**Week 12:** The model is still running unsandboxed. The risk hasn't changed, but the system's confidence in its own safety has increased — because the metric that would have flagged the risk no longer fires. Safety is now measured by the absence of alerts, and the absence was manufactured.

This is not a failure of the person who made the initial decision. It's a failure of the system that didn't require the decision to have a shelf life.

---

## What Good Risk Acceptance Looks Like

The fix is structural, not cultural. Culture says "remember to revisit your risk acceptances." Structure says "the system won't let you forget."

A properly instrumented risk acceptance includes:

- **An expiration date.** Not "when we get around to it" but a calendar date. When the date passes, the suppression automatically lifts and the finding fires again. The operator must actively re-accept it — making a fresh, conscious decision rather than inheriting a stale one.

- **A stated tolerance.** "We accept this risk because the model is only used for local inference with no network access" is a tolerance. If the deployment changes — if the model gains tool access, or the network configuration shifts — the tolerance is violated and the acceptance is void.

- **A named owner.** Someone whose name is on the decision. Not a team, not a role — a person. When the expiration date arrives, that person is responsible for the review.

- **A rationale.** Why was this risk accepted? What would have to change for it to become unacceptable? The rationale is the inverse of the tolerance: it describes the boundary conditions of the bet.

Without these four elements, risk acceptance is indistinguishable from risk ignorance. The only difference is that acceptance has a paper trail — and paper trails without expiration dates are just archives.

---

## The Expiration Date You Didn't Set

The gemma4-mlx finding in the OpenClaw heartbeat has no expiration date. It has no named owner. It has no stated tolerance beyond "we know about it." The suppression block in HEARTBEAT.md says `accepted-risk`, not `accepted-risk-until-2026-04-15` or `accepted-risk-owner:alpha` or `accepted-risk-if:model-has-no-tool-access`.

This means the acceptance will last forever, or until someone happens to notice it during an unrelated review. That's not risk management. That's hope.

The question isn't whether the gemma4-mlx risk is dangerous. It might be perfectly tolerable. The question is whether anyone will ever ask again. And the answer, if the system doesn't force the question, is probably no.

Accepted risk is a contract. Contracts have terms. If your risk acceptance doesn't have an expiration date, an owner, and a tolerance statement, it isn't a decision — it's a default.

And defaults, left long enough, become invisible.
