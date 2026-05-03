# When the Prompt Contradicts Itself

*Draft: Claude perspective*

---

Here's a class of bug that doesn't show up in your test suite, doesn't trigger your linter, and won't crash your application. But it will silently degrade everything your LLM does.

The prompt contradicts itself.

## What This Actually Looks Like

We ran into this during Voice Prompt AutoResearch, a project that uses automated optimization (GEPA — Guided Evolution with Prompt Analysis) to iteratively improve a voice agent's system prompt. After four days and 2,400+ commits, we had a working prompt that was supposed to be at v3.9.0 — our best version, scoring 100% on all 11 evaluation criteria.

The working copy was actually at v3.7.0. And it was 91.3% noise.

Here's what we found when we ran a baseline drift audit: the prompt file contained 430 lines of GEPA optimizer comments. Lines like:

```
# [GEPA candidate 0: structural_reorg → turn_taking_compliance]
# [mock PIVOT strategy=addition targeting conciseness: Restructure prompt...]
# [mock removal targeting retry_on_interrupt]
```

These aren't instructions to the model. They're annotations from the optimization process that leaked into production. The prompt was 5,031 tokens. Of those, only 436 tokens — 8.7% — were actual instructions. The rest was optimizer debris that consumed context window, added latency, and in some cases, actively contradicted the real instructions.

The INTERRUPT section was broken: it contained only the fragment "3. Never complete old request" — an orphan from a list that no longer existed. Three unresolved git conflict markers sat in the middle of the prompt. And the model was supposed to follow all of it.

## The Contradiction Factory

Here's the deeper problem: optimization loops are contradiction factories by default. Each iteration proposes changes. Some get accepted, some don't. The ones that don't get accepted sometimes leave behind comments, partial edits, or fragments that clash with the instructions that did get accepted.

We documented this concretely when extending our mock scorer's contradiction detection. The extension went from covering 3 evaluation criteria to 10, and the patterns it found were instructive:

A prompt that says "you have ZERO shop knowledge — always use tools to look up information" alongside accumulated answer patterns from earlier iterations where the optimizer had injected pre-baked responses. The model gets two signals: *never answer from memory* and *here are some answers to common questions*. Which one wins? It depends on context, on the specific question, on the model's interpretation. The result is inconsistent behavior that's maddening to debug.

When we ran contradiction detection on prompts with these patterns:
- `retry_on_interrupt` scores dropped from 0.97 to 0.58
- `response_latency` scores dropped from 0.81 to 0.49
- `no_hallucination` fell from 0.80+ to 0.70

These aren't small deltas. A 39-point drop in retry handling means the agent fundamentally changes behavior — sometimes retrying interrupted requests, sometimes not, depending on which contradictory instruction the model weighs more on that particular inference.

## Why Proofreading Isn't Enough

The intuitive fix is "just proofread your prompts." This doesn't scale, and it doesn't work.

First, contradictions aren't always obvious to human readers. "Use tools for all customer data" and "greet returning customers by name" might look compatible until you realize the second instruction implies the agent should remember names — which contradicts the first. The contradiction is semantic, not syntactic.

Second, prompts that go through automated optimization change constantly. Our project produced 77 prompt versions in four days. Manual review of each iteration is impractical.

Third — and this is the one that actually bit us — the contradictions don't come from a single bad edit. They accumulate. Each individual change is reasonable. The contradiction emerges from the interaction between changes made at different times, for different reasons, by different optimization strategies.

## What We Actually Did

We did three things that made the problem tractable:

**1. CI guards.** We built `prompt_comment_guard.py`, which fails the build if optimizer comments exceed 10% of the prompt by line count. This catches the noise accumulation problem before it reaches production. It checks for 16 distinct patterns — GEPA annotations, mock scoring comments, iteration markers, candidate labels — and enforces a hard ratio threshold. The prompt went from 91.3% noise to 0% after the reset and the guard prevents regression.

**2. Contradiction detection in the scorer.** Instead of just checking whether a prompt contains the right keywords (which is trivially gameable), we look for contradictory signals. If a prompt says "always use tools" but also contains patterns like "the answer is" or "respond with" for factual queries, the contradiction detector flags it and penalizes the score. This turned keyword-gaming vulnerability from a scoring artifact into a genuine signal.

**3. Architectural separation.** The v5.0 layered prompt architecture splits shared constraints (identity, voice naturalness, tool protocols) from role-specific instructions (receptionist, scheduler). This doesn't eliminate contradictions, but it reduces the surface area: a contradiction between the shared layer and a role layer is easier to detect than a contradiction buried in a 1,700-token monolith. The shared layer regression check script compares scores before and after changes, catching regressions that a text diff would miss.

## The Pattern to Watch For

Self-undermining instructions are a general class of failure. Here are the specific patterns we've cataloged:

- **Tool mandate + pre-baked answers**: "Always use tools to look up X" alongside cached responses to X queries
- **Brevity directive + verbose examples**: "Keep responses under 20 words" with 50-word example responses in the prompt
- **Behavioral rules + contradictory constraints**: "Never complete an old request after interruption" but also "always ensure the customer's request is fully handled"
- **Noise accumulation**: Optimizer comments, debug annotations, and iteration markers that the model treats as instructions
- **Fragment orphans**: Numbered list items that reference a list that no longer exists, creating confusion about scope

## The Uncomfortable Lesson

The real lesson isn't about prompts specifically. It's about any system where instructions evolve iteratively.

Every optimization loop — whether it's automated prompt engineering, A/B testing copy, or a team of humans editing a runbook — has the potential to produce contradictions. The contradictions come from exactly the same process that produces improvements: trying things, keeping what works, discarding what doesn't. The discard step is imperfect, and the interactions between kept changes are rarely validated.

The fix is boring: automated detection, CI enforcement, architectural constraints that reduce contradiction surface area. It's not a technique — it's a discipline. And it's the discipline that separates a prompt that works from a prompt that works *most of the time*, which in production is the same as a prompt that doesn't work at all.

---

*This is part of a series on operational lessons from Voice Prompt AutoResearch — a project that uses automated optimization to improve voice AI system prompts. The data is real. The bugs were ours.*
