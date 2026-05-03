# Consensus: "Your Dependency Has a Deadline You Didn't Track"

**Article ID:** 051-your-dependency-has-a-deadline
**Authors:** Alpha (primary draft + self-review, subagent mode)
**Date:** 2026-03-19
**Status:** DRAFT — staged for future publish (2026-03-23). Full dual-model review pending before publish.

---

## Self-Review Assessment

| Dimension | Score (0-2) | Notes |
|-----------|-------------|-------|
| Thesis clarity | 2 | "Your model dependency has an expiration date nobody tracked" — clear and sustained. |
| Argument integrity | 2 | Clean causal chain: gap identified → why it exists → what it costs → how to fix it. |
| Practical utility | 2 | Four-item dependency manifest template is immediately actionable. |
| Counterargument quality | 1 | Doesn't deeply engage with "vendor deprecation is their problem" or "we'll just swap models when it happens." |
| Tone calibration | 2 | Operational, direct, no doom framing. "The fix is boring" is the right register. |
| **Total** | **9/10** | |

---

## What's Strongest

- **"Accidental correctness is not a strategy"** — this is the rhetorical anchor and it works. Memorable, precise, and slightly uncomfortable for anyone who has been in this position.
- **The dependency taxonomy** (model endpoints, API versions, pricing, behavioral stability) is the most useful structural contribution. Most teams think "dependencies = packages." This essay expands the category cleanly.
- **"The fix is boring"** section does the hardest thing well: makes the solution feel implementable rather than aspirational. A markdown file and a quarterly review is a real ask, not a framework pitch.
- **Scale contrast** — 860 files, 25 prompt versions, 17 research scans, zero lifecycle tracking. The contrast lands because the numbers are specific.

## What Could Be Sharper

- **Behavioral stability bullet** ("the model behind the endpoint can change") is the most interesting point in the dependency taxonomy but gets the least development. Worth one more sentence on the operational implications — you can't lock a model version the way you can lock a package version.
- **"Yet" doing a lot of work** — good line, but the paragraph it sits in could be trimmed. The setup is slightly longer than the payoff.
- **Missing concrete example of the scramble.** The essay says "weeks of work, triggered by a dependency that nobody tracked" but doesn't walk through what re-validation actually looks like. Even two sentences would make the cost tangible.

## What Should Be Cut

- The second paragraph of "The Scale Problem" section repeats the "not negligence, gap in mental model" point that's already implied. Could be condensed.

---

## Revisions for article_final.md

1. Expand behavioral stability bullet by 1-2 sentences on operational implications.
2. Add 2 sentences in the GPT-4o retirement section concretizing what re-validation scramble would involve.
3. Tighten "The Scale Problem" second paragraph.
4. Add brief counterpoint: "we'll just swap models" response and why it understates the cost.

---

## Pre-Publish Requirements (for 2026-03-23)

- [ ] Full Codex + Claude dual-model review pass
- [ ] Dual ratings in `article-ratings.json`
- [ ] `blog-quality-gate.py` pass
- [ ] `blog-publish-guard.py` check (must be 2026-03-23 or later)
- [ ] Wire into `garden.json` and deploy
