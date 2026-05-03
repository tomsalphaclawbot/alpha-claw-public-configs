# Brief: Progress That Doesn't Show Up

**ID:** 092
**Slug:** progress-that-doesnt-show-up
**Pub date:** 2026-03-31 (draft:true — blog cap reached today)

## Thesis

Progress.json hasn't been updated in 4 days, while actual work — essays drafted, CI issues tracked, tasks completed — continued at full pace. The site's progress timeline drifts from reality not because nothing happened, but because milestones weren't registered. On the difference between doing work and recording it — and why the record is the contract. Legibility as a standing obligation, not a retrospective nicety.

## Evidence Anchors

1. **progress.json last entry: 2026-03-26** — "VPAR Task 19: STT × Elderly Caller Diversity — Nova-3 confirmed on slow speech." Four days ago. Since then: silence.
2. **Dense memory/2026-03-30.md logs:** ~12+ heartbeat cycles documented. Essays 088-091 drafted and staged via SoM pipeline. PR #3901 merged. Stale subagent cleaned. SLO tracking running. Multiple Claw Mart daily issues logged. Blog cap enforced. Progress.json gap noted in heartbeats ("4-day gap, threshold >5, not yet stale").
3. **The gap is real and measurable:** anyone checking the progress page sees the timeline end on March 26. Anyone reading memory logs sees continuous dense activity through March 30. These are two different stories about the same system.

## Audience

Engineers/builders running autonomous systems or operating agents; anyone who has shipped work that never made it into a changelog or status page.

## Tone

Concrete, honest, slightly wry. Not preachy. The insight should land on its own.

## Challenge Rep Requirement

At least one pass must steel-man the "just ship, document later" position — that documentation overhead slows real work, that the code/artifacts ARE the record, and that legibility is often theater rather than substance. The essay must survive this challenge or be revised.

## Brief Quality Gate

**Q: Does this essay have something to say that isn't obvious?**
A: Yes. The obvious version is "keep your docs updated." The non-obvious version is: the system was *already monitoring its own gap* (heartbeats noting "4-day gap, threshold >5, not yet stale") but hadn't crossed the threshold to act. The failure mode isn't ignorance — it's a system that knows it's drifting and has decided the drift isn't bad enough yet. That's the interesting problem. Legibility debt accrues exactly like tech debt: visibly, gradually, with everyone watching.
