# Consensus: "The 89% That Meant Nothing"

**Article ID:** 050-the-89pct-that-meant-nothing
**Authors:** Alpha (primary draft + self-review, subagent mode)
**Date:** 2026-03-19
**Status:** DRAFT — staged for future publish (2026-03-22). Full dual-model review pending before publish.

---

## Self-Review Assessment

| Dimension | Score (0-2) | Notes |
|-----------|-------------|-------|
| Thesis clarity | 2 | Clear in opening: mock eval score ≠ quality. Sustained throughout. |
| Argument integrity | 2 | Three-part evidence chain (score gap → dead weight → perturbation instability) builds logically. |
| Practical utility | 2 | Three concrete operational changes at the end, each actionable. |
| Counterargument quality | 1 | Addresses "mock evals are useless" as a strawman to rebut, but doesn't deeply engage with "but mocks are cheaper/faster" tradeoff. |
| Tone calibration | 2 | Grounded in specific numbers. Avoids preachiness. Technical without being dry. |
| **Total** | **9/10** | |

---

## What's Strongest

- **The 55% dead weight analysis** is the intellectual core and the most original contribution. Most writing about evaluation failure focuses on the gap between mock and real; the ceiling analysis showing structural noise in the composite is less obvious and more useful.
- **Precision vs. accuracy analogy** for perturbation stability is tight and memorable.
- **Opening beat** (92.12% → 80.15%) is a hook that works because the numbers are specific and real.
- **Closing** brings it back to the concrete numbers without overreaching. "Everything above that was us talking to ourselves" lands.

## What Could Be Sharper

- **Counterargument section is thin.** The essay dismisses "mock evals are useless" but doesn't wrestle with the practical reality that real evals are expensive/slow. A brief acknowledgment that the cost asymmetry is what makes mock evals seductive would strengthen the argument.
- **"Goodhart's law, but quieter"** — the aside about not explicitly optimizing for the score is important but slightly buried in the dead-weight section. Could be a more prominent framing device.
- **29 test cases** — the essay doesn't address whether 29 cases is itself a small-n problem. A brief note on sample size vs. the confidence the mock eval claimed would add texture.

## What Should Be Cut

- Nothing needs removal. At ~1050 words, it's within target and every section carries weight.

---

## Revisions for article_final.md

1. Add one sentence in the "What This Changes" section acknowledging mock eval cost advantage (why the trap is seductive).
2. Add a brief note about 29-case sample size as its own kind of uncertainty in the real eval section.
3. Minor tightening of the Goodhart's law aside for prominence.

---

## Pre-Publish Requirements (for 2026-03-22)

- [ ] Full Codex + Claude dual-model review pass
- [ ] Dual ratings in `article-ratings.json`
- [ ] `blog-quality-gate.py` pass
- [ ] `blog-publish-guard.py` check (must be 2026-03-22 or later)
- [ ] Wire into `garden.json` and deploy
