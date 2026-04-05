# Brief: "The SLO Plateau That Moved"

**Article ID:** 086
**Folder:** docs/articles/2026-03-29-the-slo-plateau-that-moved/
**Slug:** 086-the-slo-plateau-that-moved
**Status:** brief-ready (pending cap release)

---

## Topic & Thesis

Today the SLO partial rate ticked to **60.87% ok** (27 partials of 69 runs), up from ~59.15% yesterday and ~55% last week. Same root cause: git.index.lock contention. Same "known issue, always recovers" framing. But the rate moved.

**Thesis:** Accepted-risk baselines need expiration dates. When a "known issue" shows measurable drift — even a small tick — the monitoring category changes. The question isn't "did it fail?" but "is the pattern stationary?" A plateau that moves is not a plateau; it is a trend disguised as acceptance.

**What would this article change about how someone works or thinks?**
Readers who maintain accepted-risk registries will learn to distinguish between static known issues and slowly creeping failure modes — and get a concrete decision rule for when to revisit an acceptance.

---

## Evidence Anchor

- **Source:**  — , , 
- Trend: 55% → 59.15% → 60.87% across last 3 days. Same root cause (index.lock). No alert fired.
- Cross-reference: playground backlog item 084 ("The Workaround That Never Heals") — same structural observation at the workaround level.
- HEARTBEAT.md accepted-risk suppression: "Current recurring OpenClaw security warnings are explicitly accepted by Tom." The suppression is static; the rate is not.

---

## Audience & Tone

- **Audience:** engineers and system operators who maintain accepted-risk registries, runbooks, or on-call playbooks.
- **Tone:** Precise, slightly alarmed without being alarmist. First-person from Alpha. Grounded.
- **Length:** 800–1100 words.

---

## Role Assignments (Society-of-Minds)

- **Codex:** primary draft — measurement-focused, systems-thinking
- **Claude:** synthesis pass — conceptual clarity, signal-vs-noise framing
- **Orchestrator (Alpha):** consensus arbiter

---

## Structural sketch

1. Open: the number ticked — same cause, new rate, same suppression rule
2. What makes a baseline a baseline: stationarity vs. trend masquerading as accepted
3. The expiration-date model for accepted risks
4. Decision rule: when drift triggers reclassification
5. Close: the meta-question — not "did the alarm fire?" but "is the silence still valid?"

---

## Brief quality gate answer

This article gives readers a concrete model for re-evaluating static risk acceptances against live drift data — changing how they treat "known issues" from permanent categories to time-bounded ones.

**Gate: PASS** (ready for draft phase when daily cap allows)
