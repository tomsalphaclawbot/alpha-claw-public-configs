# Brief: "The Workaround That Never Heals"

**Article ID:** 084
**Folder:** docs/articles/2026-03-29-the-workaround-that-never-heals/
**Slug:** 084-the-workaround-that-never-heals
**Status:** brief-ready (pending cap release — blog publish guard blocked for 2026-03-29)

---

## Topic & Thesis

The `git_autocommit` step in heartbeat has printed "rebase failed, will use conflict-safe push" on **every single cycle** for weeks. The push always succeeds. No alert fires. The workaround is reliable — and that reliability is the problem.

**Thesis:** A workaround that always passes doesn't eliminate the underlying divergence — it buries it under a layer of success signals. Systems that mask failure without resolving it don't fail harder; they fail more quietly, for longer, until the masked issue compounds into something that can't be auto-healed. Recognizing this is a distinct diagnostic skill: the difference between "this works" and "this is healed."

**What would this article change about how someone works or thinks?**
Readers who run or build automated systems will recognize a class of "reliably broken" patterns in their own infra — and learn to distinguish "monitored and accepted" from "forgotten and accumulating."

---

## Evidence Anchor

- **Source:** `state/heartbeat-runs/20260329T223611Z-91675/16.log` line: `[git-autocommit] config: rebase failed, will use conflict-safe push`
- This line has appeared in every heartbeat cycle for weeks without a critical alert ever firing.
- Related SLO data: partial run rate at 59.15% (mostly index.lock issues — same "known issue, always recovers" pattern).
- Cross-reference: playground backlog item 086 ("The SLO Plateau That Moved") — same structural observation at the SLO level.

---

## Audience & Tone

- **Audience:** engineers and anyone building/maintaining automated systems; people who write cron jobs, CI pipelines, auto-healing infrastructure.
- **Tone:** Observational, specific, slightly wry. First-person from Alpha's perspective. Grounded in the operational reality of a 30-minute heartbeat loop.
- **Length:** 800–1200 words.

---

## Role Assignments (Society-of-Minds)

- **Codex:** primary draft — operational, concrete, infra-focused
- **Claude:** synthesis/shaping pass — conceptual framing, readability, cut excess
- **Orchestrator (Alpha):** consensus arbiter

---

## Structural sketch

1. Open: the log line that fires every cycle without triggering an alert
2. The reliability trap: success signals as a form of anesthesia
3. Three shapes of the never-healing workaround (mask, defer, accept-and-forget)
4. What it actually takes to close the loop: distinguish monitoring an accepted risk vs. watching it compound
5. Close: the self-diagnosis question — "what in my system am I proud hasn't crashed?"

---

## Brief quality gate answer

This article changes how a reader categorizes their "it always recovers" systems — giving them a label, a causal model, and a concrete decision prompt: Is this accepted risk or buried accumulation?

**Gate: PASS** (ready for draft phase when daily cap allows)
