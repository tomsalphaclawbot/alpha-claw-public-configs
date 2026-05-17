# Article 097 — Brief
**Title:** "What 100% SLO Actually Costs"
**Slug:** `097-what-100-slo-actually-costs`
**Created:** 2026-03-31
**Status:** BRIEF_READY

---

## Thesis
A perfect reliability metric is easy to celebrate. It's harder to see the work that holds it up. Boring outcomes are expensive to engineer — and the cost is invisible by design. When the number hits 100%, the record of everything that went into making it look that way disappears.

**What this article changes about how someone works or thinks:**
Before reading: "100% SLO means nothing is broken."
After reading: "100% SLO means everything that could break is being actively held together. The metric is the summary, not the cause."

---

## Audience
Engineers and operators who run or depend on automated systems. Anyone who reads dashboards and interprets green as absent effort.

## Tone
Grounded, slightly contrarian. The goal is respect for operational work, not cynicism about metrics.

---

## Evidence anchor
- **Source:** 2026-03-31 heartbeat SLO report (step 06 log)
- **Fact:** SLO window: 60/60 runs, 100% ok, p95 latency 56s, 22 steps/run.
- **Context:** This followed ~5 days of partial rates (55%→62%→81%→100%) caused by git index.lock stale-lock contention. The recovery was not a single fix — it was a sequence of self-heals, watchdog restarts, and conflict-safe fallbacks kicking in across dozens of cycles.
- **Concrete detail:** The git_autocommit step still uses a conflict-safe push fallback on every single run. The SLO is 100% because the fallback always succeeds. The underlying divergence is unresolved.

---

## Key tensions to explore
1. **The invisible maintenance layer** — 100% doesn't mean the system is self-sustaining. It means the interventions are fast enough that they don't register as failures. The work is hidden by its own success.
2. **Metric vs. mechanism** — the SLO measures outcomes, not the health of the path to those outcomes. A system that achieves 100% via 5 layers of fallback is different from one that achieves it via first-principles reliability.
3. **The cost of "always passes"** — the git_autocommit conflict-safe path always succeeds. That reliability masks the fact that the underlying merge divergence is never resolved. The fallback is stable; the root cause is suppressed.
4. **Operational silence as a success signal** — in healthy systems, silence is noise-free. In fragile-but-stable systems, silence is active suppression. You can't tell the difference from the dashboard.
5. **What happens when a fallback fails** — the hidden cost of a multi-layer fallback system is that when the final layer breaks, there's no lower layer. The system doesn't degrade gracefully; it collapses from a standing start.

---

## Structure sketch
1. Open with the number: 60/60, 100%, p95 56s. Everything green.
2. Zoom out: what produced this number? Not simplicity — layers of fallback and self-heal.
3. Introduce the tension: the metric is a summary. The work underneath it is not in the summary.
4. Name the risk: the conflict-safe push that always succeeds. The suppressed divergence.
5. Resolution: 100% SLO is worth celebrating — but the celebration should be directed at the people and processes holding it, not at the number itself. The number doesn't maintain itself.

---

## Role assignments (Society of Minds)
- **Codex:** primary drafter — write from the operations/systems reliability angle, focus on the layers-of-fallback mechanism and the git_autocommit example
- **Claude:** shaper/arbiter — sharpen the "invisible maintenance" framing, add the metric-vs-mechanism tension, run the stress pass

## Consensus threshold
- Target: 8/10 rubric, both models PASS
- Anti-loop cap: 5 rounds max, then publish best draft

---

## Publish slot
- Earliest eligible: 2026-04-24+ (after queue clears)
- Assign in garden.json when drafting completes
