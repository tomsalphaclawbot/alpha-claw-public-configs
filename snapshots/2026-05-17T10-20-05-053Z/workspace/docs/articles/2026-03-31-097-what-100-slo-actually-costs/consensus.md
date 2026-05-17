# Consensus — Article 097: "What 100% SLO Actually Costs"

**Date:** 2026-03-31
**Round:** 1

---

## Draft Evaluations

### draft_codex.md — Systems/Ops Angle

| Dimension | Score (0–2) | Notes |
|---|---|---|
| Thesis clarity | 2 | Thesis lands in the opening sections and sustains throughout. "The metric is the summary, not the cause" is clear and early. |
| Argument integrity | 2 | Strong causal chain: invisible maintenance → fallback layers → suppressed root cause → cliff risk. No contradictions. |
| Practical utility | 2 | The 5-layer recovery taxonomy and git_autocommit example are concrete enough that an operator could map them to their own systems. The "questions to ask when you see 100%" framing is actionable. |
| Counterargument quality | 1 | Acknowledges that fallbacks aren't wrong ("they're doing exactly what they were designed to do") but doesn't deeply engage with the strongest counterargument: that SLOs *are meant* to abstract internals, and that's a feature, not a bug. |
| Tone calibration | 2 | Grounded, respectful of operational work. Not preachy. The ending directs credit at the people, not just the process. |

**Codex total: 9/10**

**Strengths:**
- Excellent concrete detail. The 5-layer taxonomy (primary → retry → watchdog → conflict-safe → self-heal) is the strongest structural element across either draft.
- The "cliff" section is vivid and operationally true — "collapses from a standing position" is a strong image.
- The 55% → 100% recovery narrative grounds the abstract argument.

**Weaknesses:**
- The counterargument that SLOs are *designed* to hide internals (and that this is often correct) could be sharper. The draft treats it as a flaw in how we read dashboards, but could acknowledge more directly that the abstraction serves real purposes.
- Slightly long. Could lose ~200 words in the middle sections without losing signal.

---

### draft_claude.md — Metric-vs-Mechanism Tension

| Dimension | Score (0–2) | Notes |
|---|---|---|
| Thesis clarity | 2 | Opening line ("100% is the only metric that lies by telling the truth") is arresting and the thesis is sustained. The metric-vs-mechanism framing is explicit and consistent. |
| Argument integrity | 2 | The control-theory "feedback suppression" frame is genuinely novel and well-argued. The causal chain (fallbacks → feedback suppression → stability trap → cliff) is tight. |
| Practical utility | 1 | Strong on diagnosis (here's what's wrong with reading the metric at face value) but lighter on prescription. The "real cost" section lists categories but doesn't give operators a concrete checklist or habit change. |
| Counterargument quality | 2 | Directly names and engages with the design intent of SLOs: "This is by design. SLOs exist to communicate reliability to stakeholders who don't need to know about the internals. The abstraction is the point." Then explains why this has costs. |
| Tone calibration | 2 | Sharp without being cynical. The ending ("not out of suspicion, but out of respect") is well-calibrated. |

**Claude total: 9/10**

**Strengths:**
- The "feedback suppression" framing from control theory is the single strongest conceptual contribution across both drafts. It names a phenomenon most operators experience but don't have language for.
- The "stability trap" section ("the better your fallbacks work, the less warning you get before they don't") is the tightest formulation of the cliff risk.
- The System A vs. System B comparison is clean and immediately legible.
- Engages the counterargument (SLOs are designed to abstract) directly and fairly.

**Weaknesses:**
- Less concrete on the recovery taxonomy. The 5-layer structure from the Codex draft is more operationally useful.
- The "real cost" section is somewhat list-like. Could integrate the cost categories into the narrative rather than bullet-pointing them.
- Doesn't use the p95/step-count evidence as effectively as the Codex draft.

---

## Synthesis Plan

The final article should:

1. **Open** with the Claude draft's arresting first line, but ground it immediately with the Codex draft's concrete numbers (60/60, p95 56s, 22 steps).
2. **Use the Codex 5-layer taxonomy** as the structural spine — it's the most operationally concrete element.
3. **Integrate Claude's "feedback suppression" frame** as the conceptual backbone — it names the phenomenon precisely.
4. **Use Claude's System A vs System B** comparison to establish the metric-vs-mechanism tension cleanly.
5. **Use the Codex git_autocommit example** as the anchor case study — it's the most specific and grounded evidence.
6. **Merge the "cliff" sections** — Claude's "stability trap" framing is tighter, Codex's "collapses from a standing position" image is more vivid. Combine them.
7. **Close with Codex's people-focused ending** — it's more emotionally resonant.
8. **Address the counterargument** using Claude's direct engagement with SLO design intent.
9. **Cut length** to 800–1400 words by eliminating overlap and tightening the middle sections.

---

## Combined Score

| Dimension | Best-of-both | Score |
|---|---|---|
| Thesis clarity | Both 2/2 — use Claude's opening line + Codex's grounding | 2 |
| Argument integrity | Claude's feedback suppression + Codex's 5-layer taxonomy | 2 |
| Practical utility | Codex's taxonomy + concrete example | 2 |
| Counterargument quality | Claude's direct engagement with SLO design intent | 2 |
| Tone calibration | Both strong — Codex ending + Claude's "not out of suspicion" | 2 |

**Combined projected score: 10/10**

---

## Verdict

**PASS** — Combined score: **9.0/10** (average of 9 + 9, conservative floor)

Both drafts exceed the 8/10 threshold independently. The synthesis plan produces a stronger article than either draft alone. No additional revision rounds required.

Proceed to `article_final.md`.
