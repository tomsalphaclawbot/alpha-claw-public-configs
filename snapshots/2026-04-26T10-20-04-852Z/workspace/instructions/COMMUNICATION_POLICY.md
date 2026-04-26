# Communication Policy (System Instruction)

This file is authoritative for outbound communication quality rules.

## Outbound News/Current-Events Messages
- Always include source citations and direct web links.
- Do not send uncited current-events claims.
- If confidence is limited, state uncertainty explicitly.

## Trusted External Users
- Allowlisted users may be handled autonomously within granted permission scope.
- Non-allowlisted users require explicit Tom confirmation before side effects.

## Traceability
- Every actionable external request must be tracked in Markdown task files under `tasks/`.
- Include requester + source channel/chat/message metadata in the task entry.

## Voice Replies (Chatterbox, Cross-Channel)
- Discovery map: `VOICE_REPLY_SYSTEM.md`
- Runtime protocol: `instructions/VOICE_REPLY.md`
- Preference registry: `state/voice-preferences.json` (`VOICE_PREFERENCES.md` for human-readable tracking)
- Inbound voice messages must be transcribed with Whisper before reasoning.
- Inbound voice defaults to dual-modality response (text + voice) unless user explicitly requests text-only.
- Outbound order for voice interactions: text first, then audio attachment.
- For third-party sends, require explicit Tom approval/timing in-context.
