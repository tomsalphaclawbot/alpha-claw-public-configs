# alpha-claw-public-configs

Public-facing service that publishes **sanitized, versioned configuration snapshot metadata**.

## Endpoints
- `/` HTML overview
- `/api/snapshots` JSON snapshot feed
- `/health` health check

## Local run
```bash
npm install
npm start
```

## Docker deploy
```bash
docker compose up -d --build
docker compose ps
```

App listens on container port `8080` and maps to host `8788`.

## Public URL
- https://configs.tomsalphaclawbot.work

> This project only publishes safe metadata, never raw secrets or credentials.
