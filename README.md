# alpha-claw-public-configs

Public-facing service for **sanitized OpenClaw setup snapshots**.

This repo now represents a shareable view of the overall Alpha OpenClaw configuration: important identity/config markdown, selected ops scripts, and skill definitions — with sensitive/noisy data stripped.

## What gets included

Snapshot pipeline (`scripts/build-snapshot.js`) pulls allowlisted content from:

1. `~/.openclaw/workspace`
   - Core docs: `AGENTS.md`, `SOUL.md`, `IDENTITY.md`, `USER.md`, `TOOLS.md`, `HEARTBEAT.md`, `ARCHITECTURE.md`, etc.
   - `docs/**`
   - `instructions/**`
   - selected operational scripts under `scripts/`
   - `skills/*/SKILL.md`
2. `~/.openclaw` config root (safe subset)
   - `README.md`
   - shell completions under `completions/`

> Note: duplicate doc copies from `workspace-claude/` and `workspace-codex/` are intentionally excluded. Public snapshots use the canonical `workspace/*` docs to avoid confusion.

## What gets excluded

Even if referenced, blocked/noisy paths are skipped:

- `memory/**`, `state/**`, `logs/**`
- `transcripts/**`, `sessions/**`
- `.git/**`, `node_modules/**`
- `credentials/**`, `delivery-queue/**`, `tmp/**`

## Sanitization / redaction

Text files are copied into a versioned snapshot and sanitized with basic regex redaction:

- email addresses -> `[REDACTED_EMAIL]`
- phone-like numbers -> `[REDACTED_PHONE]`
- long numeric IDs/chat-like IDs -> `[REDACTED_ID]`
- token/secret/password assignment values -> `[REDACTED_SECRET]`

Each snapshot emits `manifest.json` with included files, SHA-256 hashes, size, and per-file redaction counts.

## Generate a snapshot release

```bash
npm run snapshot:build
```

Output layout:

- `snapshots/<timestamp>/...` sanitized files
- `snapshots/<timestamp>/manifest.json`
- `snapshots/latest` symlink (or fallback copied directory)

## Service endpoints

- `/` HTML overview
- `/health` health check
- `/api/snapshots` snapshot index
- `/api/snapshots/latest` latest manifest JSON
- `/snapshots/latest/manifest.json` direct manifest path

## Local run

```bash
npm install
npm run snapshot:build
npm start
```

## Docker deploy

```bash
docker compose up -d --build
docker compose ps
```

App listens on container port `8080`, mapped to host `8788`.

## Versioned release workflow (suggested)

1. Build fresh snapshot: `npm run snapshot:build`
2. Review `snapshots/latest/manifest.json` and git diff
3. Commit: `git add snapshots/ scripts/build-snapshot.js ... && git commit -m "snapshot: publish <timestamp>"`
4. Tag release: `git tag -a snapshots-YYYYMMDD -m "Sanitized snapshot release"`
5. Push branch + tags: `git push && git push --tags`
6. Optionally create GitHub release titled with snapshot tag and link to manifest path.

## Public URL

- https://configs.tomsalphaclawbot.work
