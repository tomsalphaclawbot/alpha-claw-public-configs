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
- `cloudflared-config.yml` + tunnel compose service when `--with-tunnel` is provided
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

---

## Standard Build + Deploy Playbook (Docker Compose + Cloudflare Tunnel)

Use this exact flow for new web apps.

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

### 5) Add cloudflared config in project

Create `cloudflared-config.yml`:

```yaml
tunnel: <tunnel-uuid>
credentials-file: /etc/cloudflared/creds.json
ingress:
  - hostname: <subdomain>.tomsalphaclawbot.work
    service: http://<project-service-name>:8080
  - service: http_status:404
```

### 6) Run tunnel inside docker-compose (preferred)

Add service to `docker-compose.yml`:

```yaml
  cloudflared-<project-name>:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-<project-name>
    command: tunnel --no-autoupdate --config /etc/cloudflared/config.yml run
    restart: unless-stopped
    depends_on:
      - <project-service-name>
    volumes:
      - ./cloudflared-config.yml:/etc/cloudflared/config.yml:ro
      - /Users/openclaw/.cloudflared/<tunnel-uuid>.json:/etc/cloudflared/creds.json:ro
```

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
