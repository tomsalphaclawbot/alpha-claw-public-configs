---
name: lightning-whisper-mlx
description: Default local transcription skill for OpenClaw. Uses lightning-whisper-mlx with Whisper large-v3 for audio-file transcription on Apple Silicon.
---

# Lightning Whisper MLX (large-v3) Skill

Use this skill when you need to transcribe local audio files quickly with MLX acceleration.

## Default behavior
- Backend: `mlx`
- Model: `large-v3`
- Task: `transcribe`

## Command
```bash
scripts/transcribe_audio.sh --audio <path-to-audio>
```

Optional overrides:
```bash
scripts/transcribe_audio.sh --audio <path> --lang en --backend auto
```

## Notes
- This skill is the preferred replacement for OpenAI Whisper API transcription in this workspace.
- If MLX is unavailable, use `--backend auto` to allow whisper CLI fallback.
