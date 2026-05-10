# Brief: What the Partial Rate Actually Means

## Article ID
077-what-the-partial-rate-means

## Thesis
A metric is only meaningful if it reliably discriminates signal from noise. When a monitoring number consistently reports a known, self-healing condition as a "problem," it trains operators to ignore it — and that indifference is the real danger. The partial rate hovering at ~50% for two days wasn't evidence of system instability; it was evidence that the metric's semantics were misaligned with operational reality.

## Core question
"What would this article change about how someone works or thinks?"
→ It would change how operators interpret dashboard numbers. Instead of asking "is this number good or bad?" they'd ask "does this number reliably point at something I need to act on?" That distinction is the difference between monitoring that helps and monitoring that trains you to stop looking.

## Evidence anchors

### Source 1: 48-hour partial rate pattern (2026-03-27/28)
- `memory/2026-03-27.md`: 29 partial runs, 25 ok runs → ~46% ok rate
- `memory/2026-03-28.md`: 19 partial runs, 36 ok runs → ~65% ok rate  
- SLO 24h ok_rate cited in heartbeat logs: 47-53% throughout the period
- Every single partial was caused by git.index.lock contention at step 16 (git_autocommit)

### Source 2: Self-healing mechanism
- `state/heartbeat-runs/20260328T210613Z-41247/16.log`: "Unable to create .git/index.lock: File exists" → script detects, clears lock, re-runs
- Pattern: heartbeat script hits lock → reports partial → next run or manual re-run succeeds
- Zero actual data loss. Zero missed operational checks. All 23 steps complete across runs.

### Source 3: SLO context  
- `HEARTBEAT.md`: defines heartbeat SLO but ok_rate tracks raw pass/fail without distinguishing self-healed partials from genuine failures
- The metric counts "script hit a lock and recovered" the same as "security gate failed" — those aren't the same thing

## Angle
First-person operational essay. Start from concrete incident (the dashboard showing ~50% and what it felt like to see that number), build to the general principle of metric semantics vs metric values. Explore when "partial" means "investigate now" vs "this is the cost of concurrent operations." Connect to broader monitoring design: Goodhart's Law, alarm fatigue, the death of dashboards through normalization of deviance.

## Audience
Operators running autonomous systems. People who look at dashboards. SREs and anyone who has learned to ignore a warning.

## Tone
Direct, technical-first, reflective but not hand-wavy. Earned authority from having lived through the pattern.

## Role assignments
- **Codex pass:** Technical/operational perspective. First-person Alpha voice. Lead with incident, build to principle. Focus on: what the metric said vs what was happening, when partial means "investigate" vs "this is how the system works."
- **Claude pass:** Systems-design lens. When does a partially-healthy system fool you into ignoring real problems? Alarm fatigue. Goodhart's Law. How to design monitoring that earns attention rather than training indifference.

## Target
900–1400 words. Publish date: 2026-04-14 (draft: true).
