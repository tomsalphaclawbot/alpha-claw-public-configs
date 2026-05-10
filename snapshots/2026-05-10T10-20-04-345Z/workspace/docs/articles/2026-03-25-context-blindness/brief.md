# Brief: Context Blindness — Why LLMs Ignore What You Tell Them

**Article ID:** 066
**Target publish:** 2026-04-03
**Format:** Fabric Garden essay (800–1500 words)
**Tone:** Technically honest, grounded, operationally instructive

## Thesis
When you give an LLM pre-filled context buried deep in a long prompt, it often ignores it. This isn't a quirk — it's a first-class engineering problem caused by attention decay in long sequences. Task 9 of VPAR proved this empirically: GPT-4.1 ignored a KNOWN_CONTEXT block at 7000 chars deep and re-collected every field from scratch. The lesson isn't "don't give LLMs context" — it's "understand where they actually read from."

## What would this article change about how someone works or thinks?
Readers building LLM-powered systems will stop assuming context injected somewhere in a long prompt is actually attended to. They'll understand that position matters more than presence, and they'll move critical context to the front.

## Evidence anchor
- Source: VPAR Task 9 (2026-03-25) — `experiments/v54-context-engineering/v54-analysis.md`
- GPT-4.1 called in `full_context` condition (pre-filled name, service, day/time) used MORE turns (7) and MORE cost ($0.085) than baseline (5 turns, $0.062)
- The KNOWN_CONTEXT block was at ~7000 chars in a 9000 char prompt
- Follow-up hypothesis (Task 10): moving the block to position 0 of the scheduler section should fix it

## Key concepts to address
1. Attention as a finite resource — LLMs don't read prompts like humans read documents
2. The "lost in the middle" phenomenon — research shows models attend strongest to beginning and end of context
3. Why 7000 chars of "known context" still produced the same outcome as a blank slate
4. Practical fix: position critical context first, not just somewhere
5. Broader implication: any system that injects state/context mid-prompt is vulnerable to this

## Audience
Engineers and product builders working with LLMs in real systems (not researchers, not casual users)

## Role assignments
- Codex: draft A (engineering-first, specific examples, systems lens)
- Claude: draft B (conceptual depth, broader implications, operationalization)

## Coauthor requirement
Both drafts required before consensus.

