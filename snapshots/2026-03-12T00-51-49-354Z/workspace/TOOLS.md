# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → [REDACTED_PHONE], user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Accounts & Channels

- Assistant email (active mailbox): `[REDACTED_EMAIL]`
- Assistant email (legacy): `[REDACTED_EMAIL]`
- Assistant email (legacy): `[REDACTED_EMAIL]`
- Discord bot/user handle: `@tomsalphaclawbot`
- Discord server: `Voice Controller`
- Telegram bot is configured and working (paired).
- GitHub account: `tomsalphaclawbot` (email: `[REDACTED_EMAIL]`)

## Research Tooling

- Perplexity integration available via `scripts/perplexity-search.sh`.
- Backed by skill folder: `skills/perplexity-safe`.
- Bitwarden item name for key: `Perplexity.ai API key`.

## Azure CLI Access

- `az` CLI is installed and authenticated.
- Verified login context: user `[REDACTED_EMAIL]`, tenant `Default Directory` (`tomsalphaclawoutlook.onmicrosoft.com`), subscription `Azure subscription 1`.
- Use this environment to configure Azure app registrations and OAuth/modern-auth setup for Outlook integration.

## Docker Desktop (local)

- Docker Desktop is installed and running on this Mac.
- `docker` CLI is available and working from OpenClaw sessions.
- Verified working context: `docker-desktop` / `desktop-linux`.
- Use Docker for local project workflows (dev envs, integration tests, service stacks, containers).
- If daemon/socket issues appear after reboot/session changes, ensure Docker Desktop app is launched under the primary user session first.

## n8n Local Automation Stack

- Project path: `projects/n8n-local`
- Local URL: `http://localhost:5678`
- Public URL (via host-level Cloudflare tunnel): `https://n8n.tomsalphaclawbot.work`
- Pinned stack: n8n `2.4.6` + worker, Postgres `15`, Redis `7`
- Local skill path: `skills/n8n-local`
- Compose helper script: `projects/n8n-local/n8n.sh`
- API key source: Bitwarden item `N8N local API credentials` field `token`
- n8n API runbook: `N8N_ACCESS.md`
- Proxy/cookie hardening enabled in compose: `N8N_PROXY_HOPS=1`, `N8N_EDITOR_BASE_URL`, `N8N_SECURE_COOKIE=true`

## Outlook Graph Skill (local)

- Local skill path: `skills/outlook-graph-mail`
- Canonical scripts: `skills/outlook-graph-mail/scripts/` (root-level `scripts/outlook-graph-*.sh` removed)
- Scope: modern-auth Outlook mailbox management (read/send/archive/delete/move/spam-folder checks)
- Default token path: `state/outlook_graph_token.json`
- Standard workflow:
  1. Authenticate: `skills/outlook-graph-mail/scripts/outlook-graph-auth.sh`
  2. Read inbox: `skills/outlook-graph-mail/scripts/outlook-graph-read.sh 20`
  3. Read junk/spam: `skills/outlook-graph-mail/scripts/outlook-graph-read-folder.sh junkemail 20`
  4. Send: `skills/outlook-graph-mail/scripts/outlook-graph-send.sh <to> <subject> <body>`
  5. Archive/Delete/Move by message id via corresponding skill scripts

## Claude CLI Defaults

- When launching Claude Code for this workspace, use flags:
  - `--dangerously-skip-permissions`
  - `--chrome`
  - `--continue`
- This is an explicit Tom directive for local operator workflows.

## Voice Reply Ability (OpenClaw Native, Cross-Channel)

- Canonical discovery map: `VOICE_REPLY_SYSTEM.md`
- Canonical skill: `skills/telegram-voice-reply/SKILL.md`
- Transcription script: `skills/telegram-voice-reply/scripts/transcribe_voice_whisper.sh`
- Dedicated MLX wrapper skill: `skills/lightning-whisper-mlx/scripts/transcribe_audio.sh`
- Transcription backend default: `WHISPER_BACKEND=mlx`
- Transcription model default: `WHISPER_MLX_MODEL=large-v3`
- MLX venv path: `.venvs/lightning-whisper-mlx`
- MLX model cache/workdir: `~/.cache/lightning-whisper-mlx`
- Native voice generation: OpenClaw `tts` tool + `talk-voice` plugin
- Inbound voice policy: transcribe full audio with Whisper before reasoning.
- Outbound voice policy: dual-modality required (text first, then audio).
- Guardrail: sending voice to third parties requires explicit Tom approval/timing in-context.

## X / XAI Tooling

- X API app credentials are stored in Bitwarden item: `X API Information`.
- XAI API token is stored in Bitwarden item: `XAI API Key` (field: `API Key`).
- XAI docs quickstart: `https://docs.x.ai/developers/quickstart`.
- First XAI chat completion test succeeded on 2026-02-25 against `https://api.x.ai/v1/chat/completions` with `grok-4-latest`.
- X content retrieval fallback rule: if `xurl`/API fetch fails, automatically try browser snapshot/screenshot and web search fetch before asking user to paste content.
- ClawHub discovery for an XAI skill (`clawhub search "xai"`) currently times out in this environment; retry when registry/network path is healthy.
- Playbooks skill candidates shared by Tom:
  - `https://playbooks.com/skills/openclaw/skills/xai`
  - `https://playbooks.com/skills/openclaw/skills/x-api`
- Install attempt (`npx playbooks add skill openclaw/skills --skill xai`) reached security scan and was blocked at critical risk (`env_harvesting_and_network`, `file_read_and_network`); requires explicit approval to install anyway.
- Install flow check for `x-api` reached interactive install-target prompt; installation was not completed (no explicit approval yet).

## Zoho Mail Access

- Active mailbox: `[REDACTED_EMAIL]`
- IMAP: `imap.zoho.com:993` (SSL)
- POP3: `pop.zoho.com:995` (SSL)
- SMTP: `smtp.zoho.com:465` (SSL)
- Credentials are stored in Bitwarden item: `www.zoho.com`
- Heartbeat scripts use:
  - `scripts/zoho-mail-healthcheck.sh`
  - `scripts/zoho-mail-manage-inbox.sh`

## Cloudflare Access OTP (secure app browser login)

- Standing operator policy (Tom-approved): when accessing Cloudflare Access-protected app frontends in browser automation, use assistant identity `[REDACTED_EMAIL]` for email OTP.
- Retrieval path: fetch OTP via backend mailbox access (Zoho/Outlook automation scripts) and complete login in-browser.
- Applies to protected surfaces such as:
  - `dashboard.tomsalphaclawbot.work`
  - `beads.tomsalphaclawbot.work`
  - `vnc.tomsalphaclawbot.work`
  - `mission-control.tomsalphaclawbot.work`
  - `openclaw-gateway.tomsalphaclawbot.work`
- Do not request Tom to manually fetch the OTP for this assistant mailbox unless mailbox tooling is degraded.
- Security guardrail: this policy is for assistant-owned mailbox OTP only (never intercept/use OTPs for other users’ personal accounts).

## Google Access (gog CLI)

- `gog` is installed and authenticated for `[REDACTED_EMAIL]`.
- **Status update (2026-03-04):** `[REDACTED_EMAIL]` has been reactivated per Tom.
- **Operational lock (still in effect):** keep Google/Gmail automations disabled until Tom explicitly asks to re-enable workflows/config for Gmail lanes.
