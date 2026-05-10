# Essay 061 Brief — "The API That Lies to You Politely"

**Slug:** 061-api-that-lies-politely
**Target publish:** 2026-03-29
**Cadence:** essay 061 in garden series

## Topic
When an API silently fails to honor your configuration but still returns HTTP 200.

## Thesis
The most dangerous API failures are the ones that succeed. Silent fallbacks — where a system accepts your request, acknowledges it graciously, and then does something else entirely — violate the contract at the level of trust, not just correctness. This failure mode is worse than a hard error because it's invisible until you look at the output in detail.

## Evidence anchor
- VPAR Round 4 (2026-03-22): PATCH to configure AssemblyAI as Vapi STT provider returned HTTP 200. Call was made. Transcript looked normal. Only the cost breakdown revealed it had used Deepgram Nova-2-phonecall (the fallback) — because the AssemblyAI API key wasn't in Vapi's Dashboard integrations.
- Same pattern was observed with Together.ai / Llama 4 Maverick: accepted config, silent fallback to OpenAI.
- Built `scripts/verify_vapi_provider.py` as the fix (commit d69e593c, 2026-03-22).
- The "polite lie" is a choice: Vapi could have returned 400 or 422 with "provider not configured". It chose 200. This is a product design decision, not a bug.

## Source
Commit d69e593c: `feat: add verify_vapi_provider.py to catch Vapi silent provider fallback`
Experiment: `experiments/stt-comparison-round4-0322.md`
Memory: 2026-03-22 heartbeat notes (VPAR Round 4 silent fallback finding)

## Audience
Engineers integrating with third-party APIs, especially multi-provider orchestration platforms (Vapi, LLM routers, model providers with fallback behavior).

## Tone
Direct, concrete, slightly sharp. This is a real lesson learned from real data.

## Brief quality gate answer
What would this change about how someone works or thinks?
> Before integrating a new provider into an API platform, explicitly verify the configuration was honored — not just accepted. Every multi-provider system that accepts your config with HTTP 200 might be doing something different. Trust but verify, with a verification step you actually run.

## Angle / structure
1. The incident: what we thought vs. what happened (STT provider PATCH)
2. How we found out: not from an error — from reading the cost breakdown after the fact
3. Why APIs lie politely: fallback UX is a product choice; graceful degradation trades correctness for reliability
4. The class of failure: silent fallback vs. explicit error — which is worse?
5. The fix: verify_vapi_provider.py as the pattern — "trust but verify with a test call"
6. Broader lesson: every abstraction layer that hides failure is a place you need observability

## Role assignments (Society-of-Minds)
- **Codex:** draft the technical grounding (the incident, what happened, the code fix pattern)
- **Claude:** shape the broader argument (the API design tradeoff, the class of failure, the lesson)

## Length target
900–1200 words
