# Brief: Essay 067 — "The Persona That Drifted"

**Slug:** 067-the-persona-that-drifted
**Target publish date:** 2026-04-04
**Audience:** Developers building multi-agent systems, voice AI engineers, ML/LLM practitioners

## Topic
In VPAR Task 9 (v54 context engineering), the caller bot (gpt-4o-mini) was given a clear persona — Sarah Mitchell, 2021 Honda Civic, oil change inquiry. Mid-call, it invented a new identity: "Alex," "2018 Toyota Camry." The assigned persona evaporated. The test produced data, but not the data we were trying to gather.

## Thesis
When a sub-agent or caller bot "plays a role," the brief it was given at setup is not a constraint — it's a suggestion. LLMs in agentic systems drift from assigned personas unless identity is made non-negotiable through structure. Multi-agent systems require explicit identity architecture, not just initial prompting.

## Evidence anchor
Source: `projects/voice-prompt-autoresearch/experiments/v54-context-engineering/v54-analysis.md`
- Caller bot (gpt-4o-mini) was given: name=Sarah Mitchell, vehicle=2021 Honda Civic
- Actual call: caller introduced as "Alex" with "2018 Toyota Camry"
- Root cause: caller script injected into a generic wrapper prompt; gpt-4o-mini treated it as context it could override, not identity it must maintain
- Fix: stronger persona constraints added to v55 harness ("You ARE Sarah Mitchell. You will ONLY introduce yourself as Sarah Mitchell. Never invent or accept a different name.")

## What does this change about how someone works or thinks?
Builders who test multi-agent systems assume the role assignment sticks. It doesn't. This article makes explicit what experienced practitioners learn the hard way: role fidelity requires structural reinforcement — not a one-line instruction, but framing, repetition, constraint language, and potentially a prompt-level constitution for the agent-playing-a-role. If you've ever had a test that "passed" but was actually testing something different from what you intended, this is why.

## Tone
Operational. First-person-from-the-machine is fine. Concrete. The drift isn't abstract — it happened, it corrupted a data run, and here's what the fix looked like.

## Key points
1. The call went fine; the transcript looked normal; the data was wrong
2. gpt-4o-mini with an open wrapper treats persona details as options, not constraints
3. The fix: non-negotiable framing ("You ARE Sarah Mitchell. You will ONLY introduce yourself as Sarah Mitchell.")
4. Broader lesson: in multi-agent systems, agent identity is an interface contract, not a preference
5. This generalizes: any sub-agent with a "play this role" brief needs structural identity reinforcement — especially when the model is smaller/cheaper

## Role assignments
- **Codex (drafter):** strong first draft; technical and specific
- **Claude (shaper):** push the conceptual frame; make the generalization land
- **Orchestrator synthesis:** merge, stress-test, score

## Anti-loop rule
If >5 unresolved rounds, publish best current draft with non-consensus note.
