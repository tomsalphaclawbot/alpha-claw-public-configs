---
name: n8n-local
description: Manage the local self-hosted n8n instance at n8n.tomsalphaclawbot.work via API (list/create/update/activate/deactivate workflows) and validate webhook endpoints. Use when the user asks to build, edit, test, or debug n8n workflows in the local Docker stack.
---

# n8n-local

Use this skill for workflow operations against the local n8n deployment.

## Environment assumptions

- n8n URL: `https://n8n.tomsalphaclawbot.work`
- API key source: Bitwarden item `N8N local API credentials`, field `token`
- Stack project path: `projects/n8n-local`
- Reference runbook: `N8N_ACCESS.md`

## Retrieve API key at runtime

```bash
KEY="$(rbw get 'N8N local API credentials' --field token)"
```

Never print or store raw key values in logs, Beads comments, or committed files.

## Core API operations

### List workflows

```bash
curl -sS -H "X-N8N-API-KEY: [REDACTED_SECRET]" \
  "https://n8n.tomsalphaclawbot.work/api/v1/workflows"
```

### Get a workflow

```bash
WF_ID="<workflow-id>"
curl -sS -H "X-N8N-API-KEY: [REDACTED_SECRET]" \
  "https://n8n.tomsalphaclawbot.work/api/v1/workflows/$WF_ID"
```

### Create a workflow

```bash
curl -sS -X POST \
  -H "X-N8N-API-KEY: [REDACTED_SECRET]" \
  -H "Content-Type: application/json" \
  -d @workflow.json \
  "https://n8n.tomsalphaclawbot.work/api/v1/workflows"
```

### Activate / deactivate

```bash
WF_ID="<workflow-id>"

curl -sS -X POST -H "X-N8N-API-KEY: [REDACTED_SECRET]" \
  "https://n8n.tomsalphaclawbot.work/api/v1/workflows/$WF_ID/activate"

curl -sS -X POST -H "X-N8N-API-KEY: [REDACTED_SECRET]" \
  "https://n8n.tomsalphaclawbot.work/api/v1/workflows/$WF_ID/deactivate"
```

## Webhook testing pattern

1. Create workflow with webhook path.
2. Activate workflow.
3. Hit webhook URL and capture HTTP code + response.

Example path pattern:

```text
https://n8n.tomsalphaclawbot.work/webhook/<workflow-id>/webhook/<path>
```

## Safety checklist before edits

1. Export or fetch current workflow JSON (backup).
2. Apply minimal change.
3. Reactivate if needed.
4. Re-test endpoint execution.
5. Record validation evidence in Beads.

## If API calls fail

- Verify stack health:
  - `cd projects/n8n-local && docker compose ps`
- Verify public URL:
  - `curl -I https://n8n.tomsalphaclawbot.work`
- Re-check key retrieval from `rbw` in current runtime session.
