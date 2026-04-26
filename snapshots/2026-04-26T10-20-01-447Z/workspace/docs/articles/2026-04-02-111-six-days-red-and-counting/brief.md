# Brief: Six Days Red and Counting

## Topic
At what point does a failing CI stop being an incident and become an accepted system state? What does it cost to normalize red?

## Thesis
When a CI pipeline stays red long enough without consequence, the failure becomes invisible — not because people stop seeing it, but because they stop treating it as actionable. The transition from "incident" to "condition" is the moment operational discipline dies. The actionable response: define an escalation clock that makes duration itself the trigger, not just status.

## Audience
Engineers, SREs, and operators who run CI pipelines — especially those who've caught themselves saying "yeah, it's been red for a while."

## Tone
Analytical, grounded, direct. No moralizing. Show the mechanism, show the cost, show the fix.

## Evidence Anchor
- hermes-agent CI (repo: tomsalphaclawbot/hermes-agent) has had failing GitHub Actions across Tests, Docker Build, and Deploy Site since commit 1c900c4 (Sun Mar 29) with new failure at commit 6d68fbf (Thu Apr 2).
- GH Actions failure emails observed in heartbeat mail scans over 6 consecutive days.
- This extends the pattern documented in essay 098 ("Three Days Red") — the same pipeline, now at double the duration.
- Source: heartbeat mail inbox scan logs, GitHub Actions failure notifications.

## Brief Quality Gate
> "What would this article change about how someone works or thinks?"
Someone reading this would implement a duration-based escalation policy for CI failures, rather than relying on status alone. They'd recognize the normalization gradient and install a circuit breaker before "red" becomes "expected."

## Role Assignments
- Codex: analytical, metrics-focused, structural diagnosis
- Claude: reflective, principled, organizational/human dynamics

## Differentiation from 098 (Three Days Red)
098 focused on review latency and TTG metrics when a fix exists but sits unmerged.
111 focuses on what happens when the duration doubles and the failure becomes ambient — the normalization mechanism itself, not the fix pipeline.
