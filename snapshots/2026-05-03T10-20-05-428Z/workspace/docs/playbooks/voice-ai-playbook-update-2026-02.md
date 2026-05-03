# Voice AI Landscape (2026-02) — Actionable Playbook Update

**Bead:** `workspace-62v`  
**Mode:** Research-only (Tom policy lock: read-only, no third-party outbound actions)

## Executive takeaway

The landscape has converged into 3 practical build paths:

1. **Realtime speech-to-speech model path** (fastest to natural conversation): OpenAI Realtime API, Gemini Live API.
2. **Composable STT → LLM → TTS path** (most control and swapability): e.g., Deepgram + OpenAI/Anthropic + Cartesia/ElevenLabs.
3. **Managed voice-agent platform path** (fastest telephony delivery): Twilio ConversationRelay, Vapi, Retell.

For this workspace, the best near-term strategy is a **hybrid**:
- keep orchestration/provider abstraction in-house,
- run one realtime-first path for latency-sensitive interactions,
- keep one fallback composable path for reliability/cost control.

---

## What changed in the market (practical view)

### 1) Native realtime voice is now first-class
- OpenAI Realtime supports speech-to-speech and multiple transports (WebRTC, WebSocket, SIP) for browser/server/telephony use cases.
- Google Gemini Live API now exposes low-latency voice/video with native audio models, barge-in, VAD, and tool use via stateful WebSockets.

**Implication:** building “human-feeling” conversations no longer requires assembling every voice component yourself.

### 2) Cost mechanics matter more than model sticker price
- OpenAI Realtime billing depends on input/output modality tokens and conversation growth per turn; prompt caching can significantly reduce repeated context costs.
- Gemini Live pricing is now explicitly tokenized for text/audio/video input+output in Vertex AI pricing tables.

**Implication:** session design (history management/caching/truncation) is now a core product lever, not just infra tuning.

### 3) Telephony orchestration is becoming a product category
- Twilio Media Streams + ConversationRelay provide managed speech plumbing over telephony.
- Retell and Vapi provide end-to-end phone-agent control planes including telephony integration, testing/monitoring, and fallback features.

**Implication:** teams can ship telephony AI faster, but risk lock-in if they don’t keep provider-agnostic interfaces.

### 4) Open-source orchestration is maturing
- Pipecat and LiveKit both now present practical, production-focused paths for low-latency voice agents, turn management, and testing.

**Implication:** we can preserve optionality without sacrificing speed if we define clean adapter boundaries.

---

## Tooling comparison (operator-focused)

| Stack option | Strength | Weakness | Best fit |
|---|---|---|---|
| OpenAI Realtime | Strong realtime ergonomics; SIP/WebRTC/WebSocket options | Session-cost growth if history unmanaged | Fast speech-to-speech assistants |
| Gemini Live (Vertex) | Native audio/video, multilingual + affective dialog, tool use | GCP/Vertex operational coupling | Multimodal assistants, Google stack shops |
| STT-LLM-TTS (Deepgram/OpenAI/Cartesia etc.) | Best component control + swapability | More integration complexity | Regulated/controlled workflows |
| Twilio ConversationRelay/Media Streams | Telephony-native transport and operations | Twilio coupling | PSTN and contact-center integration |
| Retell / Vapi | Fastest deploy for phone agents, built-in monitor/fallback concepts | Platform lock-in risk | Rapid go-live and experimentation |
| LiveKit / Pipecat OSS | Strong flexibility and ownership of runtime | More engineering ownership burden | Teams prioritizing portability |

---

## Actionable playbook upgrades (recommended)

## 1) Add a provider-agnostic `VoiceRuntime` interface (highest leverage)
**Do now:** define one internal contract for:
- `transcribe(stream)`
- `respond(context, tools)`
- `speak(text|audio)`
- `interrupt(session)`
- `fallback(reason)`

**Why:** prevents lock-in and lets us swap OpenAI/Gemini/managed vendors per channel.

## 2) Add explicit latency budgets + telemetry schema
**Do now:** require per-turn metrics:
- `vad_ms`, `stt_ms`, `llm_first_token_ms`, `tts_first_audio_ms`, `e2e_turn_ms`, `barge_in_count`, `false_interrupt_count`

**Initial SLO target:** p95 `e2e_turn_ms <= 2000` for conversational paths.

## 3) Add fallback plans at 3 layers
**Do now:**
- **Model fallback:** realtime primary -> pipeline fallback
- **Voice fallback:** provider/voice failover list (documented order)
- **Telephony fallback:** SIP route/provider fallback where possible

**Why:** avoids hard call failures and supports graceful degradation.

## 4) Add voice-specific eval harness before production rollout
**Do now:** create repeatable test suites for:
- interruption handling,
- tool-call correctness,
- noisy audio robustness,
- hallucination/grounding checks,
- escalation-to-human behavior.

Use text-mode behavior tests for breadth + targeted audio E2E for realism.

## 5) Cost control guardrails in session lifecycle
**Do now:**
- cap effective context window per call,
- summarize/archive old turns,
- maximize cache stability (avoid unnecessary instruction/tool definition churn),
- meter per-call/token spend with hard alert thresholds.

---

## Recommended phased implementation for this workspace

### Phase 0 (1–2 days): design contracts + observability
- Define `VoiceRuntime` adapter shape and metrics schema in docs.
- Add a “voice session envelope” spec (ids, timestamps, provider, cost fields, fallback reason).

### Phase 1 (3–5 days): dual-path PoC
- Path A: OpenAI Realtime baseline.
- Path B: composable STT-LLM-TTS baseline.
- Run same scripted eval suite and compare latency/cost/reliability.

### Phase 2 (1 week): telephony path hardening
- Add Twilio/Retell/Vapi integration behind adapter boundary.
- Implement explicit fallback routing and incident playbook.

### Phase 3 (ongoing): quality + economics loop
- Weekly review of p95 latency, interruption recovery, cost/session, escalation rate.
- Re-route traffic mix by workload type (realtime vs composable vs managed).

---

## Source links

- OpenAI Realtime API guide: https://developers.openai.com/api/docs/guides/realtime
- OpenAI Voice Agents guide: https://developers.openai.com/api/docs/guides/voice-agents
- OpenAI Realtime cost mechanics: https://developers.openai.com/api/docs/guides/realtime-costs
- OpenAI API pricing: https://openai.com/api/pricing/
- Google Gemini Live API overview (Vertex): https://cloud.google.com/vertex-ai/generative-ai/docs/live-api
- Google Vertex AI pricing (includes Gemini Live rows): https://cloud.google.com/vertex-ai/generative-ai/pricing
- Anthropic Claude model overview: https://docs.anthropic.com/en/docs/about-claude/models
- Twilio Media Streams: https://www.twilio.com/docs/voice/media-streams
- Twilio ConversationRelay: https://www.twilio.com/docs/voice/conversationrelay
- LiveKit Voice AI quickstart: https://docs.livekit.io/agents/start/voice-ai-quickstart/
- LiveKit turn detection/interruption docs: https://docs.livekit.io/agents/logic/turns/
- LiveKit testing and evaluation: https://docs.livekit.io/agents/start/testing/
- Retell docs intro: https://docs.retellai.com/general/introduction.md
- Retell custom telephony: https://docs.retellai.com/deploy/custom-telephony.md
- Vapi docs index: https://docs.vapi.ai/
- Vapi voice fallback plan: https://docs.vapi.ai/voice-fallback-plan.mdx
- Pipecat OSS repo: https://github.com/pipecat-ai/pipecat
- Deepgram pricing: https://deepgram.com/pricing
- ElevenLabs pricing: https://elevenlabs.io/pricing
- Cartesia pricing: https://cartesia.ai/pricing
