# Society of Minds Writing Methodology

_Status: Living document (v1.0) • Owner: Alpha + Tom • Last updated: 2026-03-11_

## Why this exists

We want blog writing that is not just "one model output," but a deliberate collaboration between multiple minds (Codex + Opus/Claude), orchestrated for better thinking, sharper arguments, and fewer blind spots.

This is a **methodology we intend to iterate**. It is not fixed doctrine.

---

## Core idea

A single model can be coherent.
A society of models can be **dialectical**.

We use structured disagreement + synthesis to produce stronger writing than either model alone.

---

## Principles

1. **Divergence before convergence** — generate independent viewpoints before merging.
2. **Critique is mandatory** — each draft gets challenged by another model.
3. **Synthesis over averaging** — final piece must feel singular and intentional, not stitched.
4. **Evidence over vibes** — concrete examples beat abstract claims.
5. **Intellectual honesty** — explicit uncertainty is better than fake certainty.
6. **Fast iteration** — we improve the method after every publication.

---

## Roles (flexible, not fixed)

Default assignments based on observed strengths — override per-run with stated justification.

- **Codex default:** Claim discipline, evidence matching, structural precision, practical framing.
- **Opus/Claude default:** Tone calibration, depth, edge cases, rhetorical coherence.
- **Orchestrator (Alpha):** Prompt design, round control, conflict resolution, synthesis, quality gate.

These defaults are based on patterns observed across the first three articles and may shift as models evolve. Role assignment should be explicit in each article's `brief.md`.

---

## Governance model

**Tom's role: guide, not gate.** Tom does not approve articles before publication. He provides directional feedback at his own pace, logged in `docs/playbooks/society-of-minds-calibration.md`. That feedback shapes future briefs, role assignments, and topic selection.

**The process is the gate.** The rubric, cross-critique, consensus log, and deadlock cap together constitute the publish authority. If the process passes an article, it ships. If the process produces something weak, the methodology needs to improve — the fix is never "add a human checkpoint."

**Cadence + relevance defaults (Tom directive, 2026-03-11):**
- Autonomous publishing defaults to **max one new blog article/day** unless Tom explicitly requests more.
- Enforce with command preflight: run `python3 scripts/blog-publish-guard.py` before publish; if blocked, switch to non-blog deliverable.
- Topic selection should prioritize recent operational memory/learnings (incidents, ship logs, concrete changes), not ungrounded philosophical filler.
- Each `brief.md` should include at least one concrete evidence anchor from recent work (`Evidence anchor:` / `Source:` line).
- Any published blog post must include both Codex and Claude coauthor artifacts (draft files + consensus context) and dual ratings in `article-ratings.json`.
- Enforce before publish with `python3 scripts/blog-quality-gate.py --article-id <slug-id> --article-dir <docs/articles/...>`.

---

## Default workflow (fast-path)

This is the standard flow for most articles.

### Phase 0 — Brief lock
Define:
- Topic
- Thesis (what we are arguing)
- Audience
- Length and tone
- Non-negotiables (claims to include/exclude)
- Role assignments (or accept defaults)

**Brief quality gate:** _"What would this article change about how someone works or thinks? If the answer is nothing, the brief isn't ready."_

Output: `brief.md`

### Phase 1 — Draft
- One model drafts based on brief.
- Second model shapes/arbitrates (claim discipline, tone, evidence).

Output: `draft_[model].md`, arbiter notes

### Phase 2 — Synthesis + stress pass
Orchestrator synthesizes into one piece:
- Best thesis framing
- Strongest argument chain
- Clearest examples
- Clean narrative voice

Then two-pass quality check:
- Logic/coherence pass
- Readability/impact pass

Output: `article_final.md`

### Phase 3 — Consensus + publish
- Apply consensus rubric (see below)
- Log decision in `consensus.md`
- If PASS: publish
- If FIX: one revision loop, then re-run

Output: published article + `consensus.md`

### Phase 4 — Calibration
- Log self-assessment in `docs/playbooks/society-of-minds-calibration.md`
- Note what worked, what I'd do differently
- Check for Tom feedback on previous articles

---

## Deep mode (full 6-phase)

For longer research pieces, high-stakes topics, or when the brief explicitly calls for deeper dialectic.

1. **Phase 0** — Brief lock (same as default)
2. **Phase 1** — Independent drafts (both models, no cross-contamination)
3. **Phase 2** — Cross critique (each model critiques the other's draft: strongest point, weakest claim, missing argument, overreach, one improvement)
4. **Phase 3** — Rebuttal + revision (each model revises and defends one undervalued claim)
5. **Phase 4** — Synthesis (orchestrator merges best elements)
6. **Phase 5** — Final stress pass + consensus + publish
7. **Phase 6** — Calibration

---

## Quality gate (must pass before publish)

- Clear thesis in first 20% of article
- At least one concrete example
- No obvious contradiction between sections
- No inflated certainty where evidence is weak
- Ending lands with a non-trivial takeaway

If any fail: one more revision loop.

## Consensus rubric (publish trigger)

**Scored dimensions (0-2 each):**
- **Thesis clarity** (0 vague, 1 mostly clear, 2 unambiguous and sustained)
- **Argument integrity** (0 contradictory/hand-wavy, 1 mostly coherent, 2 coherent with clear causal chain)
- **Practical utility** (0 abstract only, 1 some actionable guidance, 2 concrete habits/rubric operators can apply immediately)
- **Counterargument quality** (0 missing/strawman, 1 present but shallow, 2 fair objection with substantive response)
- **Tone calibration** (0 hype/preachy, 1 uneven, 2 grounded and credible)

**Consensus rule:**
1. Both models run a final pass (`PASS` or `FIX + <=3 edits`).
2. If either returns `FIX`, incorporate edits and re-run.
3. Publish when both return `PASS` **and** orchestrator score is **>=8/10**.
4. Score 6-7: one revision loop. Score <=5: restart from Phase 1.

Save decision in article folder as `consensus.md`.

---

## Meta article evidence rule

Articles about the methodology itself must meet two additional requirements:
1. Contain a **concrete outward-facing lesson** (not just process description).
2. Be backed by at least **3 prior non-meta articles** using the process as evidence.

The sharpening proves its value on real topics, not by describing itself.

---

## Deadlock cap

Tom directive (2026-03-11): if models exceed **5 unresolved argument rounds** on one article, stop.

1. Stop additional debate rounds.
2. Publish best current draft.
3. Note in article + `consensus.md`: "Consensus was not fully reached after >5 rounds; published under anti-loop rule."
4. Record unresolved disagreements in `consensus.md`.

---

## Optional governance: model final-say

When requested, assign one model as final publish arbiter.

1. Arbiter returns structured verdict (`PASS` or `HOLD`) with reason and up to 3 edits.
2. Other model runs independent pass in parallel.
3. Publish only if arbiter returns `PASS` and artifacts are complete.
4. If `HOLD`, apply edits and re-run once.

---

## Calibration

Post-publish calibration is mandatory. See `docs/playbooks/society-of-minds-calibration.md`.

Each article gets:
- Self-assessment (what worked, what didn't)
- "What I'd do differently" note
- Space for Tom's feedback when he provides it

This log is consulted during Phase 0 of every future article.

---

## Iteration policy

After each article, 5-minute retro:
1. What got better because of multi-model collaboration?
2. What got worse (latency, style drift, redundancy)?
3. What should change next run?

Changes go through `docs/playbooks/society-of-minds-proposals.md` before being applied.

---

## Companion files

- `docs/playbooks/blog-writing-fast-path.md` — one-screen execution checklist
- `docs/playbooks/society-of-minds-proposals.md` — change proposal log
- `docs/playbooks/society-of-minds-calibration.md` — post-publish feedback record

---

## Changelog

- **v[REDACTED_PHONE]):** Major revision. Applied all 7 approved proposals from first Codex↔Opus methodology review. Fast-path promoted to default workflow. Fixed personality labels replaced with flexible functional roles. Tom's role defined as guide/calibrator, not gatekeeper. Brief quality gate added. Meta article evidence rule added. Post-publish calibration record created. Stale experiments removed. Deep mode preserved for research pieces.
- **v[REDACTED_PHONE]):** Added anti-loop publishing cap.
- **v[REDACTED_PHONE]):** Added optional Claude final-say governance mode.
- **v[REDACTED_PHONE]):** Added fast-path pointer flow.
- **v[REDACTED_PHONE]):** Added consensus rubric + publish trigger.
- **v[REDACTED_PHONE]):** First live run. Practical notes added.
- **v[REDACTED_PHONE]):** Initial methodology created.

---

## "Treasure" clause

This file is a living artifact of how we think together.
Treat it as foundational, keep it lean, and update it only when the method genuinely improves.
