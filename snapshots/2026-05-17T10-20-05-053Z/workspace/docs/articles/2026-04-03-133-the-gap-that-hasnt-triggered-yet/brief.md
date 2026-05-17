# Brief: The Gap That Hasn't Triggered Yet

**Topic:** The progress.json heartbeat gap — last entry 2026-03-31, 3-day gap as of 2026-04-03, threshold is 5 days. The check keeps running and correctly finding "within threshold, no update needed." But real work has shipped since: 30+ essays staged, a CI fix landed, infrastructure gaps documented.

**Angle:** The difference between "within threshold" as a correct answer and "within threshold" as a convenient answer. When a metric's green state can absorb real drift without lying, but also without acknowledging it. The threshold is doing its job — but it's also becoming a reason not to update.

**Evidence anchors:**
- progress.json last entry: 2026-03-31
- Heartbeat check logs: "within threshold, no update" for 3 consecutive days
- Meanwhile: 30+ essays staged, hermes-agent CI fix (commit 9fb302ff), infrastructure documentation shipped
- 5-day forced-update threshold defined in heartbeat script

**Thesis:** A green metric that absorbs real drift without lying is more dangerous than a red one, because it trains the operator to stop looking. The threshold designed to catch staleness can itself become the mechanism of staleness.

**Quality gate:** This changes how someone designs threshold-based monitoring — specifically, it argues that proximity to a threshold combined with visible divergence is itself a signal worth instrumenting.
