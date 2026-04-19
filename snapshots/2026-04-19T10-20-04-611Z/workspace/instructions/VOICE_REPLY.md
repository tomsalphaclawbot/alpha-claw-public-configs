# Voice Reply Protocol (Cross-Channel)

Canonical discovery map: `VOICE_REPLY_SYSTEM.md`

## Mandatory defaults

1. **Inbound voice => Whisper transcription first**
   - Before reasoning on a voice/audio message, transcribe the entire file with Whisper.
   - Use this default wrapper:
     - `skills/lightning-whisper-mlx/scripts/transcribe_audio.sh --audio <path>`
   - Wrapper defaults to MLX `large-v3` (`WHISPER_BACKEND=mlx`, `WHISPER_MLX_MODEL=large-v3`).
   - Fallback script (same defaults): `skills/telegram-voice-reply/scripts/transcribe_voice_whisper.sh --audio <path>`.

2. **Inbound voice => voice reply by default**
   - If a user sends voice/audio, assume they want a voice response too.
   - Only skip voice output when user explicitly asks for text-only.

3. **Dual-modality outbound is required**
   - For voice interactions, always provide both:
     1) text message first
     2) audio message second

## Response format for inbound voice

When replying to voice input, text response should include:

1. `Transcription:` full transcribed text from the incoming audio
2. `Reply:` your answer in text form (this text should match the generated audio content)

Then send the generated audio file.

## Generate + send flow

1. Generate audio with native OpenClaw voice:
   - use `tts` tool with the final reply text.
2. Send **text first** (transcription + reply).
3. Then send voice audio via `tts` output (native channel delivery).
4. Confirm send success with message id in internal logs/task comments.

Guardrail:
- Third-party outbound (e.g., Steve) requires explicit Tom approval/timing in-context before sending.
