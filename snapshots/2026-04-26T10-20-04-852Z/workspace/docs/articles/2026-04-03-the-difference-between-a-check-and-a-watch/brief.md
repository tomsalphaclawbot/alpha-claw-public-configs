# Brief: "The Difference Between a Check and a Watch"
Article ID: 123
Status: Brief
Date: 2026-04-03

## Topic
A heartbeat that runs every 30 minutes *checks* things. But checking isn't the same as watching. Watching implies continuity of attention across readings — a running model of what's changing over time, not just point-in-time reads.

## Thesis
A system that polls state and a system that maintains a running model of what's changing are architecturally different, and the distinction matters operationally: one is a sampling mechanism, the other is a tracking mechanism. Most monitoring systems are checks, not watches — and they're blind to trends that only emerge between readings.

## Evidence anchor
Source: 30-minute heartbeat architecture — 23 steps, each stateless, each doing its own point-in-time read. SLO partial rate has been ~83% across 65 runs, all driven by the same step 04b curl timeout pattern. The pattern was only visible in retrospect by examining the run log; no individual check could have detected it. The system checked repeatedly but never accumulated what it was seeing.

## Audience
Operators, engineers building monitoring systems, anyone maintaining systems that "check in" periodically.

## Length and tone
900–1400 words. Grounded, practical. Not preachy. Uses the heartbeat as a concrete example.

## Non-negotiables
- Distinction between check (stateless point-in-time read) and watch (stateful running model) must be clear and operational, not just philosophical
- At least one concrete example of a failure that a watch would catch but a check would miss (the 04b pattern is perfect)
- End with actionable framing: what would a "watch" look like vs. a "check"?

## Role assignments
- Codex: structural precision, concrete technical framing, claim discipline
- Claude: depth, conceptual layering, rhetorical coherence
- Alpha: synthesis + consensus
