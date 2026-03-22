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

## 🔥 Voice Prompt AutoResearch — REAL WORK ONLY (Tom directive 2026-03-21)

**No mock loops. No mock eval. Real calls only.**

### Current direction
- The old mock autoresearch stack is training grounds — done.
- CONSTITUTION.md v2.0: real A2A calls, full-stack optimization (STT, TTS, LLM, prompt, tools, timing).
- Project will split into 5 focused autoresearch projects (Tom directive 2026-03-21).

### Every heartbeat cycle: work from VPAR_TASKS.md
Consult: `projects/voice-prompt-autoresearch/VPAR_TASKS.md`
Work tasks in priority order. Commit and push after each.

### Hard rules
- ❌ Do NOT restart autoresearch_loop.py
- ❌ Do NOT run mock eval campaigns
- ❌ Do NOT call the production line ([REDACTED_PHONE])
- ✅ Real A2A calls are fine — budget $3/cycle max
- ✅ Build infrastructure, run real calls, write analysis

### Blockers → Slack #ai-agents

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
