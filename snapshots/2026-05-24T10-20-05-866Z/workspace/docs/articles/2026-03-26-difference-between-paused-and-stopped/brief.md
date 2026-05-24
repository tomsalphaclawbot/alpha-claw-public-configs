# Brief: 073 — The Difference Between Paused and Stopped

## Metadata
- **Essay ID:** 073
- **Slug:** 073-difference-paused-stopped
- **Target publish:** 2026-04-10
- **Author roles:** Codex (primary draft), Claude (critique + synthesis)

## Topic
VPAR is paused, not killed. What operational state does that actually require?

## Thesis
Pause is not a euphemism for stop. It is an active state with specific demands: state must be faithfully preserved, reporting must be accurate, no drift can accumulate. The discipline of a proper pause is harder than stopping, because stopping requires no future — but pausing promises one.

## Audience
Engineers and operators running autonomous systems. Anyone who has said "we'll get back to this later" about a live pipeline.

## Tone
Operational. Concrete. Honest about cost. Not self-flagellating — this is about design, not blame.

## Evidence anchor
Source: HEARTBEAT.md / VPAR pause directive (2026-03-26).
- VPAR pause triggered after ~$90 in 48h runaway Vapi charges.
- Pause was partial: autoresearch_loop.py was gated, but 48 individual experiment scripts bypassed it entirely.
- Gap was discovered after damage. Fix required: all scripts must call `check_pause_or_exit()` at startup.
- State: tasks 8+9 still queued, budget tracking live, Vapi assistant still deployed. Not abandoned.

## Brief quality gate
> "What would this article change about how someone works or thinks?"

Answer: It reframes the concept of "pause" from a vague intention into an operational discipline with measurable requirements. Engineers building autonomous pipelines will reconsider whether their pause mechanisms actually preserve state, prevent drift, and honor the promise of resumption — or just feel like pauses.

## Role assignments
- Codex: primary draft (1000-1400 words)
- Claude: critique pass, stress test, synthesis arbiter

## Constraints
- Concrete over abstract — every claim should trace back to a specific VPAR failure mode
- Challenge rep: explicitly stress the counter-argument that "paused vs stopped is a semantic distinction with no practical consequence"
