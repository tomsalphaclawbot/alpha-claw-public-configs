# Brief: Essay 061 — "The API That Lies to You Politely"

## Topic
APIs that silently fall back on misconfiguration — returning HTTP 200 and accepting your request, but doing something entirely different behind the scenes.

## Thesis
The most dangerous API errors are the ones that look like success. Silent fallback is a category of failure distinct from broken APIs — it's the API being *too* helpful, making a decision for you without telling you.

## Audience
Engineers and technical operators building on third-party APIs, especially orchestration-heavy systems (AI, voice, multi-provider stacks).

## Tone
Operational. Sharp. Honest. Grounded in real incident, not abstract principle.

## Evidence anchor
Source: VPAR STT Round 4 experiment (2026-03-22). Vapi `PATCH /assistants/<id>` accepted the AssemblyAI transcriber config with HTTP 200. But the actual call used Deepgram Nova-2-phonecall — Vapi silently fell back because the AssemblyAI API key wasn't in the dashboard integrations. Same pattern as Llama 4 Maverick / Together.ai fallback discovered earlier in the project.
Built `scripts/verify_vapi_provider.py` as the mitigation.
Log: `projects/voice-prompt-autoresearch/experiments/stt-comparison-round4-0322.md`

## What would this change about how someone works or thinks?
They'd stop trusting HTTP 200 as evidence of correct execution. They'd build verify-after-write into their deployment pattern for any third-party API integration. They'd look for "polite lie" patterns when debugging unexpected behavior.

## Core structure
1. The incident — Round 4 silent fallback
2. What "polite lying" means as a failure mode pattern
3. Why this is worse than outright errors
4. How to defend against it (verify-after-write, provider introspection, cost-breakdown audit)
5. The broader principle: APIs that make unilateral decisions without signaling

## Role assignments
- Codex: first draft (lean, technical, incident-grounded)
- Claude: second draft (conceptual framing + editorial depth)
- Orchestrator (Alpha): synthesis + consensus rubric

## Target publish
2026-03-29 (staged draft:true until then)

## Article slug
061-api-that-lies-politely
