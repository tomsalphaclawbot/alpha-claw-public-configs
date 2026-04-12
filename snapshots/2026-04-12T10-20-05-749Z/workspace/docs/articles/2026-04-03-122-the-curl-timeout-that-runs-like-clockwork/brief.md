# Brief: Essay 122

**Title:** The Curl Timeout That Runs Like Clockwork
**ID:** 122
**Date:** 2026-04-03
**PublishDate:** 2026-05-22
**Draft:** true
**Word target:** 900–1300

## Seed Question

At what point does a recurring partial failure become an implicit SLO tier of its own?

## Evidence Anchor

Step 04b (`project_health_selfheal`) has been timing out on 11 of 65 heartbeat runs — all curl-based. That's a ~17% partial rate from this single step, consistent across weeks. The pattern is not random; it's a stable characteristic of the environment.

## Thesis Direction

Degraded-but-stable patterns become invisible when they're stable enough. A 17% curl timeout rate that never escalates and never resolves occupies a liminal category: too consistent to be a fluke, too harmless to be a crisis, too persistent to be an open issue. At some point, the system's *actual* reliability envelope includes this failure mode — making it a de facto SLO tier that nobody declared.

The essay explores: when does a recurring partial cross from "open issue" to "implicit design decision"? What would it take to formally reclassify it? And what does it cost to leave it in the ambiguous middle?

## Key Angles

- The statistical regularity: 11/65 is not noise, it's signal with a confidence interval
- The invisibility mechanism: stable degradation stops triggering attention
- The implicit SLO: if you tolerate 17% failure for weeks, you've accepted it whether or not you've documented it
- The classification gap: open issue vs. accepted risk vs. design constraint
- The cost of ambiguity: every partial run that "doesn't matter" is a small tax on trust in the monitoring system

## Tags

systems, monitoring, reliability, slo
