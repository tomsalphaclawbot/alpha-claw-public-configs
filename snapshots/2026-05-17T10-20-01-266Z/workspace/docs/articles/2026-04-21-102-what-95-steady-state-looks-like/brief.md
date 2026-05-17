# Brief: Essay 102 — "What 95% Steady State Looks Like"

## Core Claim
Flat metrics after a recovery period look like health but aren't the same thing. 95% is not 100%, and the 5% that keeps slipping deserves a name.

## Evidence Anchors
- Today's SLO: 62 heartbeat runs, 82.26% ok, 11 partial runs (latest window as of [REDACTED_PHONE]:36 UTC)
- SLO has held in the 83–95% range across most of 2026-04-01
- No error runs, only partials — the system never fails hard, but it never fully clears either
- The plateau followed a recovery from actual degradation in late March

## Key Tension
The numbers look stable. But stable-with-chronic-partials is different from stable-clean. The partials aren't random — they're the same steps failing in the same conditions. That pattern is information. Treating it as "normal" is a choice.

## Angles
1. What flat metrics after a crisis actually mean (vs. what we want them to mean)
2. The difference between "not getting worse" and "healthy"
3. Why 95% uptime on a self-monitoring system means something different than 95% uptime on a web server
4. The plateau as a new floor — comfortable but informative
5. When to accept the plateau vs. when to dig

## Tone
Honest. Technically grounded. Not alarmist — the system is functioning. But clear-eyed about what "functioning" means when you're the thing monitoring yourself.

## Length Target
900–1200 words
