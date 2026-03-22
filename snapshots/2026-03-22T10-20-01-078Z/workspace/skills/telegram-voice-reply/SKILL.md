---
name: telegram-voice-reply
description: Generate and deliver voice responses using OpenClaw native voice tooling for chat channels like Telegram and Discord. Use when a user asks for a spoken/audio reply or voice-note style output, and for inbound voice messages that must be transcribed with Whisper and answered in dual-modality (text + audio).
---

# Voice Reply (OpenClaw Native)

Generate spoken responses using native OpenClaw voice tooling, and run inbound voice handling with Whisper transcription.

## Workflow

1. Detect inbound type + channel
- If inbound message includes voice/audio, run Whisper transcription before reasoning.
- Confirm destination channel (Telegram, Discord, etc.).

2. Transcribe inbound voice (mandatory)
- Run: `../lightning-whisper-mlx/scripts/transcribe_audio.sh --audio <path>`
- Default backend is `mlx` with `large-v3` model.
- Capture full transcript text for user-visible reply.

3. Decide reply modality
- Default for inbound voice: return voice + text (dual modality).
- Only skip voice if user explicitly requests text-only.

4. Generate audio reply
- Use native OpenClaw voice generation via `tts` tool with the final reply text.

5. Deliver in dual-modality order
- Send text first, containing:
  - `Transcription:` full inbound transcript
  - `Reply:` full outbound reply text (match generated audio text)
- Then send audio via native `tts` delivery for the active channel.

6. Validate and report
- Confirm message send success (`ok=true`, message id).
- Keep task logs/comments updated with transcript+delivery evidence.

## Guardrails

- Do not use shell/curl for provider messaging; use `message` tool for delivery.
- If target is a third party (not the requesting user), require explicit user approval/timing before sending.
- Keep content safe, non-deceptive, and aligned with existing external-communication policy.

## Reference

- System discovery map: `VOICE_REPLY_SYSTEM.md`
- Runtime protocol: `instructions/VOICE_REPLY.md`
- Voice preference policy/tracking: `VOICE_PREFERENCES.md` + `state/voice-preferences.json`
- Prompt patterns and voice-note style examples: `references/prompt-patterns.md`
