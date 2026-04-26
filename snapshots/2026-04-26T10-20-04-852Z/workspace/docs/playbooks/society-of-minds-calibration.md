# Society of Minds — Calibration Record

_Running log of post-publish self-assessment and Tom's directional feedback._
_Used during Phase 0 brief-writing to avoid repeating known weaknesses._

---

## 033 — Sharpen the Iron
- **Published:** 2026-03-11
- **Rubric:** Codex PASS, Claude PASS, orchestrator 9/10
- **Self-assessment:** Strongest of the three — had a real thesis about something beyond the process. Concrete example (migration rollout) grounded the argument.
- **What I'd do differently:** Tighter ending; the three habits list could have been more specific.
- **Tom feedback:** _(pending)_

## 034 — Society of Minds, In the Room
- **Published:** 2026-03-11
- **Rubric:** Claude final-say PASS 10/10
- **Self-assessment:** Meta-article about the process. Necessary as calibration, but thin on outward-facing value. Scored high because the models graded a process-about-process — not because it was genuinely useful to external readers.
- **What I'd do differently:** Would not publish this as a standalone unless it contained a concrete lesson transferable outside our workflow.
- **Tom feedback:** _(pending)_

## 035 — Society of Minds, Reversed
- **Published:** 2026-03-11
- **Rubric:** Codex arbiter 8/10, Opus final-say 9/10
- **Self-assessment:** Another meta-article. The finding ("governance is portable across roles") is real but thin for a full essay. Timeline section reads like build logs. Audience framing ("founders and operators") was aspirational. Punctuation issues in published version.
- **What I'd do differently:** Would not have published without a stronger outward-facing payoff. Needed the brief gate (Proposal 007) — "what does this change for someone outside this project?" Answer was too weak.
- **Tom feedback:** _(pending)_

---

## Tom directional guidance (running)

- **2026-03-11:** "I am trying to get opus and codex to sharpen each other and to actually write truthful and useful articles as opposed to just blathering on philosophically." — Focus on real-topic utility, not philosophical meta-commentary.
- **2026-03-11:** "I don't want to be the gate. I will simply guide over time, not gate." — Autonomous publish authority; Tom calibrates, does not approve.

---

## 2026-03-26 — Operational calibration note (heartbeat idle, no new article)

**Context:** Blog cap reached for the day (article 058 published). No new article published this cycle.

**Observation:** Today's playground work that yielded the most useful content was backlog seeding — items 070–074 — all drawn from a real operational incident (VPAR runaway spend). Those briefs wrote themselves in under a minute because the evidence was hot and specific. This validates the brief quality gate: "what does this change for someone outside the project?" was easy to answer when the source material was a real event with a real cost.

**Anti-pattern caught:** The stale `vpar-real-a2a-campaign` subagent entry (run ID `91e5f944`) was sitting in `state/subagents/active.json` for 5+ days post-completion with `no-session` status — generating repeated prod-attempt noise every heartbeat cycle. Removed manually this cycle. **Lesson:** subagent cleanup should be part of the completion contract, not left for heartbeat to detect repeatedly. A worker that reaches `no-session` status repeatedly with no active bead should be auto-expelled from active.json.

**Process improvement flagged:** The stall-watch prod mechanism doesn't distinguish between "session gone, bead complete" and "session gone, unknown status." The former should auto-clean; the latter should escalate once, not repeat indefinitely. Consider adding an auto-expiry after N failed prod attempts (e.g., 3+ consecutive `no-session`) when no active bead exists.


## 139 — The Inbox That Reached a Number and Stopped
- **Published:** 2026-04-04
- **Rubric:** Codex PASS, Claude PASS (shaped), orchestrator 9/10
- **Self-assessment:** Strong grounding from real operational data — 621 unseen count stable across weeks. The two-kinds-of-flat framework (equilibrium vs. stagnation) is the core insight and it transfers cleanly. The concrete fix (`delta(metric, t-24h) == 0` as its own alert) satisfies the brief gate. Codex's "corpse dressed as a patient" was the only theatrical misstep; Claude's shaped version cut it cleanly.
- **What I'd do differently:** The SLO blind-spot section could have named a concrete tool (e.g., Prometheus `absent()` or increase rate) for extra credibility with engineering audiences.
- **Tom feedback:** _(pending)_
