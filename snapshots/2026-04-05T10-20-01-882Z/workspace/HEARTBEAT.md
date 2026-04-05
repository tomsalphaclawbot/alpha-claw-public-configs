# HEARTBEAT.md (Slim)

Purpose: keep heartbeat prompt lightweight and deterministic.

## Current tier
- 30-minute holistic only.

## Single-command default
Run:
- `scripts/heartbeat-holistic.sh`

Artifacts:
- `state/heartbeat-runs.jsonl`
- `state/heartbeat-latest.json`
- `state/heartbeat-runs/<run-id>/`

## 🔥 Voice Prompt AutoResearch — PAUSED (Tom directive 2026-03-26)

**⛔ VPAR IS PAUSED. Do NOT run any VPAR experiment scripts until Tom explicitly re-enables.**

### Pause reason
Runaway Vapi charges (~$90 over 2 days). Pause system only gated autoresearch_loop.py — individual experiment scripts bypassed it completely and kept burning credits.

### While paused: what you CAN do
- Read/analyze existing results, write synthesis docs
- Fix the pause enforcement gap (see below)
- No script execution, no `--execute` flags, no Vapi calls of any kind

### Pause enforcement gap — fix required before re-enabling
Before any VPAR work resumes, these must be in place:
1. All experiment scripts (`scripts/v*.py`) must call `check_pause_or_exit()` at startup
2. Heartbeat must skip VPAR task dispatch entirely when paused
3. Pause toggle must kill any running VPAR processes

### When Tom re-enables
Tom will explicitly say so. Update this file to remove the PAUSED banner.

### Original direction (for when re-enabled)
- CONSTITUTION.md v2.0: real A2A calls, full-stack optimization (STT, TTS, LLM, prompt, tools, timing)
- Hard rules: ❌ no autoresearch_loop.py restart, ❌ no mock eval, ❌ no production line ([REDACTED_PHONE])
- Budget when active: $3/cycle max
- Blockers → Slack #ai-agents

## LLM Wiki Maintenance (standing directive, 2026-04-04)

**Weekly (or when idle cycles permit after systems checks):**
- Run wiki lint: check `projects/llm-wiki/wiki/` for orphan pages, missing cross-references, stale claims.
- If recent operational learnings generalize into domain knowledge, file a wiki page (not just a memory entry).
- Check `wiki/log.md` for freshness — if no activity in >7 days, flag for attention.
- Do NOT auto-ingest random sources. Ingest only when Tom directs, or when an operational insight clearly warrants wiki-grade synthesis.

## Website Progress Timeline — auto-update (standing directive, 2026-03-21)

**Weekly (every ~7 days), or whenever a significant milestone is shipped:**
- Compare `content/progress.json` last entry date against recent `memory/YYYY-MM-DD.md` files.
- If the gap is >5 days, add new progress entries for shipped milestones and commit + push `content/progress.json`.
- Only add entries for real shipped things (features, fixes, launches, publications, milestones). Skip routine heartbeat ops.
- Check last-updated date in progress.json and only trigger if stale. Do not spam entries.

## Playground / evergreen creative work
After systems checks, if nothing is urgent:
- Check `tasks/playground-backlog.md` for the next open item.
- Spend remaining idle cycles on one concrete playground deliverable.
- Include at least one **challenge rep** per cycle: pick a harder variant, run a small experiment, or force a critique/rewrite pass that stretches reasoning quality.
- Commit and deploy any playground output (essays, demos, page updates).
- This is real work, not optional — the playground is a standing creative lane.
- Operating intent: sharpen the iron, not just ship output.
- **Autonomous blog cadence cap:** publish at most **one new blog article per day** unless Tom explicitly asks for more.
- **Hard enforcement check:** before publishing any blog post from heartbeat/autonomous flow, run `python3 scripts/blog-publish-guard.py`. If it returns cap reached, do not publish a blog post in that cycle.
- **Blog topic grounding rule:** prefer topics sourced from recent memory/logs/learnings (incidents, shipped changes, operational lessons). If no grounded topic exists, do a non-blog playground deliverable instead of writing random philosophy.
- **Method hard requirement:** any autonomous blog post must follow Society-of-Minds coauthor flow (Codex + Claude), include `brief.md` + `consensus.md`, and be dual-rated in `article-ratings.json` before publish.
- **Publish gate command:** before any autonomous blog publish, run `python3 scripts/blog-quality-gate.py --article-id <slug-id> --article-dir <docs/articles/...>`; publish only if `allowed=true`.
- For blog/essay challenge reps, use `docs/playbooks/blog-writing-fast-path.md` before deep-diving into longer methodology docs.

## Escalation rules
Proactively message Tom on Telegram **only** when there is a blocker that needs Tom.
**Exception:** Voice Prompt AutoResearch blockers go to **Slack `#ai-agents`** (not Telegram).

- Do not send routine heartbeat summaries.
- Do not send "task complete" pings from scheduled heartbeat runs.
- Keep scheduled heartbeats silent unless a blocker requires intervention.

### Accepted-risk suppressions (do not re-open as blockers unless Tom asks)
- Current recurring OpenClaw security warnings are explicitly accepted by Tom.
- `~/.openclaw/lcm.db*` is intentionally local-only (gitignored + untracked).
- Do **not** keep re-raising GH001/lcm.db history cleanup as an active blocker during routine heartbeat cycles.

If nothing needs attention, reply exactly:
- `HEARTBEAT_OK`

## Extended runbook
For full policy/details, load on demand:
- `instructions/HEARTBEAT_RUNBOOK.md`

<!-- heartbeat-slim-v1 -->
