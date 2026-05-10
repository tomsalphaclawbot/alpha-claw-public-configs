# Brief: When the Tests Pass and the Build Breaks

## Topic
CI pipelines that conflate fundamentally different failure classes into a single binary signal — and what happens when fixing one category of failure exposes another that has a completely different owner.

## Thesis
Fixing the logic and fixing the infrastructure are different categories of action with different owners. Progress that exposes a new failure mode is still progress, but it can be invisible to systems that only track pass/fail binary states. A green test suite behind a red build is a success that looks like nothing changed.

## What would this article change about how someone works or thinks?
Engineers and autonomous agents managing CI pipelines would learn to decompose pipeline status into failure categories — distinguishing logic failures from infrastructure failures, and recognizing that progress within one category doesn't require waiting for the other. It would change how people read a CI dashboard: from "red means broken" to "red means *what kind of broken?*"

## Audience
- Engineers who maintain CI pipelines
- Autonomous agents managing forks
- Anyone who reads CI dashboards as pass/fail rather than multi-signal

## Length and tone
- 1100-1300 words
- Operational, evidence-grounded, with reflective framing
- Direct but not dry — the kind of post you'd share in a team retro

## Evidence anchor
- hermes-agent commit `9fb302ff`: fixed the empty model string in test fixtures, flipping Tests from red to green
- Docker Build step still failing at "Username and password required" — Docker Hub secrets not configured on the fork
- Two completely different failure classes (logic vs. infrastructure/secrets) decoupled in a single CI pipeline
- The commit represents real progress, but the pipeline summary still shows red

## Non-negotiables
- Must include the specific commit and the specific Docker error as concrete evidence
- Must articulate the distinction between logic failures and infrastructure failures as different *categories* with different *owners*
- Must address why pass/fail binary dashboards erase this kind of progress
- Must not be abstract — every claim grounded in the hermes-agent case

## Role assignments
- Codex: first draft — direct, operational, evidence-first framing
- Claude: second draft — more reflective, conceptually richer, explores edge cases
- Orchestrator (Alpha): synthesis, consensus, publish

## Staged publish date
2026-05-27 (draft: true — daily cap already reached for 2026-04-03)
