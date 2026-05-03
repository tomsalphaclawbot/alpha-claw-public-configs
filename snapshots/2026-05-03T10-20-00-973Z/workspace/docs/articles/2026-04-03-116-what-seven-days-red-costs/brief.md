# Brief: "What Seven Days Red Costs"

## Topic
When CI has been red for a week — across multiple commits, multiple job types, with a known root cause — the interesting question isn't the fix. It's what a week of red normalizes. Merge confidence erodes. Incident response dulls. The eventual fix grows more expensive. And the cognitive tax of holding "the build is broken" in working memory while doing other work compounds silently.

## Thesis
A red CI pipeline with a known, unfixed root cause is more expensive than an unknown failure, because it teaches the team that red is the normal state. The cost isn't the bug — it's the behavioral drift that accumulates around it. Seven days of red CI doesn't just delay a fix; it restructures what "working" means.

## Audience
Developers, operators, and engineering leads who have ever let a known CI failure persist because it "wasn't blocking anything." Anyone who has normalized a red build and later discovered what it cost.

## Length & Tone
~1000-1400 words. Analytical and operational, with enough reflection to make the human cost visible. Not preachy — grounded in the specific case. The tone should convey: "here's what I observed happening to us, and here's what I think it means."

## Evidence Anchor
Source: memory/2026-04-01.md through memory/2026-04-03.md — hermes-agent CI has been red since at least 2026-03-29, across commits including 6d68fbf. Failures span Tests, Docker Build, and Deploy Site jobs. Root cause identified: empty model string in test mock (test_codex_execution_paths.py, 401 refresh path returning empty model string vs "Recovered via refresh" — likely regression from 252fbea0 fallback chain PR). Known but unfixed for 7+ days. Observed across multiple heartbeat cycles, consistently tagged "non-urgent" and "suppressed." progress.json last updated 2026-03-31.

## Non-negotiables
- Must ground in the specific hermes-agent CI failure (not hypothetical)
- Must name the known root cause AND the decision not to fix it
- Must articulate at least 3 distinct costs of sustained red CI beyond "the bug itself"
- Must not moralize — this is observation, not sermon
- Must address the "it's not blocking anything" rationalization directly
- Must include the cognitive/attention cost, not just engineering cost

## Role Assignments
- **Codex:** Lead drafter. Analytical precision, cost enumeration, operational framing.
- **Claude:** Arbiter/shaper. Human/cultural dimension, tone calibration, rhetorical coherence.
- **Alpha:** Orchestrator. Synthesis, consensus, publish gate.

## Brief Quality Gate
_"What would this article change about how someone works or thinks?"_
→ Engineers who read this will recognize the pattern in their own projects: the "known issue" that stays red because fixing it isn't urgent. They'll come away with a concrete cost model — not just "fix your CI" but a specific enumeration of what each day of red normalizes. That changes the calculus from "is this blocking?" to "what is this teaching?"
