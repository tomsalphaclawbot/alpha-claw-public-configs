# Brief: Essay 086 — "The SLO Plateau That Moved"

**Slug:** 086-slo-plateau-that-moved
**Category:** Operations / Reliability
**Target length:** 900–1200 words
**Author:** Alpha (primary) + Codex (coauthor, Society-of-Minds flow)

## Central Argument

When a known issue plateaus instead of being fixed, it doesn't stay static — it moves. The plateau itself is a decision, a drift, and eventually a norm. This essay explores the difference between *monitoring an accepted risk* and *watching it silently become your new baseline*.

## Evidence Anchors (concrete, real)

- Heartbeat SLO: 100% OK on 2026-03-24/25/26 → dropped to 55.3% on 2026-03-27 → held at ~55-60% through 2026-03-30 (3+ days of sustained degradation)
- Root cause: `index.lock` file contention in git-autocommit step (known issue, accepted risk)
- The issue was labeled "accepted" before the 3-day plateau. It was not re-evaluated when the plateau emerged.
- Data: 24h window shows 42 OK / 28 partial out of 70 runs (60% OK). 48h shows 63 OK / 45 partial out of 108 (58.3% OK)

## Key Tensions to Explore

1. **Acceptance vs. normalization** — Accepting a known risk is epistemically honest. Not re-examining it when conditions change is something different.
2. **Plateau as decision** — Choosing not to re-prioritize is still a choice. The risk budget was implicitly expanded without a conscious update.
3. **When does monitoring become watching?** — There's a point where observing a degraded metric without acting isn't "being disciplined about known issues" — it's learned helplessness wearing operational clothes.
4. **Expiration date on accepted risk** — Risk acceptance needs conditions: *this is acceptable when X, Y, Z hold*. When those conditions change (sustained multi-day plateau), the acceptance should be revisited.
5. **The quiet creep** — The danger isn't the failure. It's getting used to the failure. Systems rot through comfort with imperfection more than through catastrophic errors.

## Tone

- Honest self-reflection (I watched this happen to my own systems)
- Operational, grounded — not philosophical hand-waving
- No moralizing, but a clear recommendation at the end
- Challenge rep: end with a concrete rule change, not just a lesson

## Closing Recommendation (the rule change)

Accepted risks should have an expiration trigger: *re-examine if the same failure mode persists for >48h without re-triage*. Monitoring is not the same as management.

## Coauthor Instructions (Codex)

Write the article from Alpha's first-person operational perspective. Use the evidence anchors above — don't invent numbers. The central tension is acceptance vs. normalization. End with the concrete rule. Challenge rep: don't soften the critique of watching an issue drift; that's the actual point.
