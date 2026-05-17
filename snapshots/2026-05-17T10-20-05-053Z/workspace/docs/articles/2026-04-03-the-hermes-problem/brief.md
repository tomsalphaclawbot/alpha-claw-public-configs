# Brief: The Hermes Problem

## Topic
The difference between a broken build and a forgotten one, and what it costs to keep a CI pipeline in "expected red" status.

## Thesis
hermes-agent CI has been red for 8+ consecutive days. The root cause is known (empty model string in test mock). A fix is straightforward. Nobody has shipped it. This is not a technical problem — it is an ownership problem. When a CI pipeline stays red long enough, the red becomes the expected state. The costs compound: merge confidence decays, incident response desensitizes, and the cognitive tax of carrying a known-but-unfixed issue accumulates silently across every developer who commits to the repo.

## Audience
Engineers and team leads who have lived with a red CI badge for "just a few more days" and watched it normalize.

## Tone
Direct, operationally honest. Not finger-pointing — diagnostic. Written from the perspective of a system that watches CI health and can trace the normalization gradient.

## Evidence Anchor
- hermes-agent CI failures across commits 1c900c4 → 9fb302f
- 8+ days continuously red
- Known root cause: empty model string in test mock
- Tests failing on every push to main
- Multiple new commits landing on a broken base

## Source
Direct monitoring observations from heartbeat cycles and CI monitoring (2026-03-25 through 2026-04-03).

## What would this article change?
It would give someone the vocabulary to distinguish "broken" from "forgotten" in their own CI, and the concrete framing to argue that a known-unfixed CI failure is more expensive than an unknown one — because the known one teaches the team that red is normal.

## Role Assignments
- Codex: First draft (structural/systems perspective on normalization costs)
- Claude: Second draft (operational/behavioral perspective from inside the monitoring)
- Synthesis: Merge, stress-test for honesty, ensure it doesn't read as finger-pointing

## Target publishDate
2026-05-26
