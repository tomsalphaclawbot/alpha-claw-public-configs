# PROJECTS.md

Living tracker for app projects in this workspace, plus the standard Docker + Cloudflare deployment recipe.

## Bootstrap New Projects (recommended)

Use the reusable scaffold script to create new project repos under `projects/`:

```bash
scripts/new-project-bootstrap.sh [--host-port <port>] [--subdomain <name>] [--with-tunnel] [--github-owner <owner>] [--no-github] <project-name>
```

Examples:

```bash
# basic scaffold (default host port 8787, subdomain = project name)
scripts/new-project-bootstrap.sh my-app

# custom host port + subdomain
scripts/new-project-bootstrap.sh --host-port 9090 --subdomain hello my-app

# include Cloudflare tunnel stubs
scripts/new-project-bootstrap.sh --with-tunnel my-app

# default GitHub owner is tomsalphaclawbot; override owner if needed
scripts/new-project-bootstrap.sh --github-owner my-org my-app

# local scaffold only (skip GitHub bootstrap)
scripts/new-project-bootstrap.sh --no-github my-local-only-app
```

What it creates:
- `projects/<project-name>/` as its own git repo (`git init`)
- Node + Express starter app with `/` and `/health`
- `Dockerfile`, `docker-compose.yml` (`restart: unless-stopped`), and `README.md`
- `ops/cloudflared.host.example.yml` host-level tunnel stub when `--with-tunnel` is provided
- GitHub private repo bootstrap by default (`gh`): create or attach existing repo, set `origin`, push initial commit

Safety behavior:
- Refuses to overwrite a non-empty existing project directory.
- If `gh` is missing or `gh auth status` fails, script warns and continues local scaffold without failing.

> Demo scaffolds are fine for validation, but delete them when no longer needed to keep `projects/` clean.

## Active Project Registry

| Project | Path | GitHub Repo | Stack | Local URL | Public URLs | Compose Services | Tunnel | Status | Last Verified |
|---|---|---|---|---|---|---|---|---|---|
| alpha-claw-web-site | `projects/alpha-claw-web-site` | `tomsalphaclawbot/alpha-claw-web-site` | Node.js + Express | `http://localhost:8787` | `https://tomsalphaclawbot.work`, `https://www.tomsalphaclawbot.work` | `alpha-claw-web-site`, `cloudflared-alpha` | `www` (`19a93ee7-94c6-41f1-907d-4ba05568694d`) | running | 2026-02-27 |
| alpha-claw-public-configs | `projects/alpha-claw-public-configs` | `tomsalphaclawbot/alpha-claw-public-configs` | Node.js + Express | `http://localhost:8788` | `https://configs.tomsalphaclawbot.work` | `alpha-claw-public-configs`, `cloudflared-alpha-claw-public-configs` | `configs` (`e6a51b1a-94f0-4517-9dbf-98d422e00919`) | running | 2026-02-27 |
| voicecontroller-maintenance-prototype | `projects/voicecontroller-maintenance-prototype` | `tomsalphaclawbot/voicecontroller-maintenance-prototype` | Node.js + Express (EJS) | `http://localhost:3620` | `https://maintenance-report.tomsalphaclawbot.work` | `voicecontroller-maintenance-prototype` | `voicecontroller-maintenance-prototype` (`7971c147-4572-4dc1-aafe-18d7875a11ec`) | running | 2026-02-28 |
| spacetimedb-chat-prototype | `projects/spacetimedb-chat-prototype` | `tomsalphaclawbot/spacetimedb-chat-prototype` | React + SpaceTimeDB (TypeScript) | `http://localhost:3640` | `https://stdb-chat.tomsalphaclawbot.work` | `spacetimedb-chat-web`, `spacetimedb-chat-engine` | `spacetimedb-chat-prototype` (`3c119ad2-6e8e-4608-a653-b1b6ad39d965`) | running | 2026-02-28 |
| n8n-local | `projects/n8n-local` | `tomsalphaclawbot/n8n-local` | n8n + worker + Postgres + Redis | `http://localhost:5678` | `https://n8n.tomsalphaclawbot.work` | `n8n`, `n8n-worker`, `postgres`, `redis` | `n8n-local` (`f7a1edb4-de1a-44f3-89c9-8345f2993be0`) | running | 2026-02-28 |
| chatterbox | `projects/chatterbox` | `tomsalphaclawbot/chatterbox` | Python + Chatterbox-Turbo + FastAPI | `http://localhost:8000` | `https://chatterbox.tomsalphaclawbot.work` | host service (`uvicorn api_server`) | `chatterbox` (`c8d31938-1e0e-491c-b559-31cad904d506`) | running | 2026-03-02 |
| resonance | `projects/resonance` | `tomsalphaclawbot/resonance` | Next.js + tRPC + Prisma | `http://localhost:3000` | `https://resonance.tomsalphaclawbot.work` | `app`, `postgres` (selfhost profile) | `resonance-selfhost` (`0e8f856e-f[REDACTED_PHONE]d20b000de3e`) | running (migration active) | 2026-03-01 |

---

## Standard Build + Deploy Playbook (Docker Compose + System-Level Cloudflare Tunnel)

Use this exact flow for new web apps.

Policy: Cloudflare tunneling runs at host/system level on macOS, not inside per-project docker-compose files.

### 1) Create project folder + git sub-repo

```bash
mkdir -p projects/<project-name>
cd projects/<project-name>
git init
```

### 1.5) Bootstrap private GitHub repo (default script behavior)

The bootstrap script attempts this automatically unless `--no-github` is set:

```bash
# default owner: tomsalphaclawbot
scripts/new-project-bootstrap.sh <project-name>

# custom owner
scripts/new-project-bootstrap.sh --github-owner <owner> <project-name>
```

Behavior:
- If `gh auth status` passes and repo does not exist: create private repo + set `origin` + push
- If repo already exists: configure `origin` and push
- If `gh` auth is unavailable: warn and continue local scaffold only

### 2) Build app + Dockerfile

Minimum convention:
- app listens on container port `8080`
- `Dockerfile` builds a production image
- include health endpoint (example: `/health`)

### 3) Add `docker-compose.yml`

Required defaults:
- host mapping: `HOST_PORT:8080`
- `restart: unless-stopped`
- predictable container names

Example app service skeleton:

```yaml
services:
  <project-name>:
    build: .
    container_name: <project-name>
    ports:
      - "8787:8080"
    restart: unless-stopped
```

### 4) Create Cloudflare tunnel (one time per app)

```bash
cloudflared tunnel create <tunnel-name>
cloudflared tunnel route dns <tunnel-name> <subdomain>.tomsalphaclawbot.work
```

### 5) Add host-level cloudflared config (outside compose)

Create a host config file under `~/.cloudflared/`, for example:

```yaml
tunnel: <tunnel-uuid>
credentials-file: /Users/openclaw/.cloudflared/<tunnel-uuid>.json
ingress:
  - hostname: <subdomain>.tomsalphaclawbot.work
    service: http://127.0.0.1:<host-port>
  - service: http_status:404
```

### 6) Run tunnel at system level (preferred)

```bash
cloudflared tunnel --config ~/.cloudflared/config-<project-name>.yml run <tunnel-uuid>
```

(Managed host-level process; do not add a `cloudflared` service to project compose by default.)

### 7) Build + run

```bash
docker compose up -d --build
docker compose ps
```

### 8) Validate local + public

```bash
curl -fsS http://localhost:<host-port>/
curl -fsS http://localhost:<host-port>/health
curl -fsS https://<subdomain>.tomsalphaclawbot.work/
curl -fsS https://<subdomain>.tomsalphaclawbot.work/health
```

### 9) Operations / updates

```bash
# deploy code changes
docker compose up -d --build

# logs
docker compose logs -f --tail=100

# restart stack
docker compose restart

# stop stack
docker compose down
```

---

## Add-a-Project Checklist

When adding a new app, update this file with:
- new row in **Active Project Registry**
- tunnel name + tunnel UUID
- public URL
- last-verified date
- status (`running`, `paused`, `retired`)

## Notes

- This is for **public, non-gated** app tunnels unless explicitly specified otherwise.
- Keep each project isolated in `projects/<name>/` with its own git repo.
