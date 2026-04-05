# Brief: "The Self-Loop Bug"

**Article ID:** 069
**Target publish date:** 2026-04-06
**Staged as:** draft: true (blog cap already reached 2026-03-25)

## Topic
The self-loop bug: when your test infrastructure accidentally calls itself instead of the system under test.

## Thesis
Small configuration errors in multi-agent systems produce results that look completely valid until you read the transcript — because the system is technically running, generating outputs, even appearing to pass. The self-loop is the subtlest form of test theater: nothing breaks, everything executes, and the results are perfect garbage.

## Audience
Builders of multi-agent systems, voice AI engineers, anyone writing integration tests that call external services they also control. Anyone who has shipped a test that "passed" before realizing it wasn't testing what they thought.

## Concrete evidence anchor
**Source:** VPAR v54 context engineering experiment (2026-03-25). The caller bot harness was dialing the exact same Vapi assistant ID it was supposed to be evaluating — a 1-line config error where `callerAssistantId` and `targetAssistantId` were the same. The call completed with a full transcript showing "booking confirmed," 5/6 criteria checked — except the agent was talking to itself. The fix was trivial; the implication was not: every metric we'd collected was comparing the assistant to itself, not to a real caller interaction.

## Length and tone
800–1200 words. Honest, a little wry. Concrete over abstract. The self-loop is slightly funny in retrospect — lean into that while keeping the technical lesson crisp.

## Non-negotiables
- Must include the actual failure mode (caller dialing target = self)
- Must explain *why* the results looked valid (no error, full transcript, plausible conversation)
- Must generalize to a broader class of "self-reference bugs in test harnesses"
- Do not make it a post about "always double-check your config" — the real insight is about *what makes this class of bug so dangerous*: it produces green-ish outputs that require deep reading to catch

## Role assignments (default)
- **Codex:** Structural precision, claim discipline, evidence matching
- **Claude (Sonnet/Opus):** Depth, edge cases, rhetorical coherence, final synthesis
- **Alpha (Orchestrator):** Prompt design, round control, synthesis, quality gate

## Brief quality gate check
> "What would this article change about how someone works or thinks?"

→ It gives builders a concrete mental model for a class of test failure they may not have named yet: self-referential evaluation. It explains why standard "did it run?" checks fail to catch it. It suggests a structural fix (always verify distinct identities in caller/target pairs, or any multi-entity test scenario). After reading, an engineer should immediately think about where their own test harnesses might be calling themselves.
