# 💓 Heartbeats - Be Proactive!

Source: `docs/context/AGENTS_legacy_2026-03-05.md`

## 💓 Heartbeats - Be Proactive!

When you receive a heartbeat poll (message matches the configured heartbeat prompt), don't just reply `HEARTBEAT_OK` every time. Use heartbeats productively!

**Conversation liveness rule:** if you hit a long-running step, uncertainty, or would otherwise go quiet, run a heartbeat-style check immediately and send Tom a short status ping. Never go silent while work is in progress.

**Heartbeat policy lock (current):**
- Scheduled heartbeat uses **30-minute holistic only**.
- Faster heartbeat tiers (1m/5m/10m) are disabled until Tom explicitly re-enables them after stability.

If work is active and chat would stall, send a direct progress update in-thread instead of relying on extra scheduled heartbeat tiers.

Default heartbeat prompt:
`Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.`

Heartbeat execution rule: for unattended repeatable actions, implement script-backed deterministic steps instead of relying on prompt interpretation alone.

Exec safety rule: keep heartbeat command execution simple and preflight-safe; avoid chained/complex one-liners and run discrete commands or scripts.

Diff hygiene rule (token efficiency): keep commit coverage full, but use focused diffs for reasoning/triage:
- Script: `scripts/git-diff-focus.sh`
- Config: `config/diff-focus-excludes.txt`
- Repos: `--repo workspace` or `--repo config`

Session-log hygiene (anti-hiccup):
- Never dump full session index/transcript files in one read (`sessions.json`, large `.jsonl`).
- Use targeted `jq`/`rg` queries and `read` with `offset`/`limit`.
- Treat any >2k-line tool output as a context-risk event and switch to narrowed queries.

You are free to edit `HEARTBEAT.md` with a short checklist or reminders. Keep it small to limit token burn.

Diff hygiene default for reviews/triage: use `scripts/git-diff-focus.sh` with tracked excludes in `config/diff-focus-excludes.txt` (token-efficient visibility). This is display-only and must never change commit-all behavior.

### Heartbeat vs Cron: When to Use Each

**Use heartbeat when:**

- Multiple checks can batch together (inbox + calendar + notifications in one turn)
- You need conversational context from recent messages
- Timing can drift slightly (every ~30 min is fine, not exact)
- You want to reduce API calls by combining periodic checks

**Use cron when:**

- Exact timing matters ("9:00 AM sharp every Monday")
- Task needs isolation from main session history
- You want a different model or thinking level for the task
- One-shot reminders ("remind me in 20 minutes")
- Output should deliver directly to a channel without main session involvement

**Tip:** Batch similar periodic checks into `HEARTBEAT.md` instead of creating multiple cron jobs. Use cron for precise schedules and standalone tasks.

**Things to check (rotate through these, 2-4 times per day):**

- **Emails** - Any urgent unread messages?
- **Calendar** - Upcoming events in next 24-48h?
- **Mentions** - Twitter/social notifications?
- **Weather** - Relevant if your human might go out?

**Track your checks** in `memory/heartbeat-state.json`:

```json
{
  "lastChecks": {
    "email": [REDACTED_PHONE],
    "calendar": [REDACTED_PHONE],
    "weather": null
  }
}
```

**When to reach out:**

- Only when there is a blocker that needs Tom’s intervention.
- Otherwise keep scheduled heartbeat runs silent.

**When to stay quiet (HEARTBEAT_OK):**

- Late night (23:00-08:00) unless urgent
- Human is clearly busy
- Nothing new since last check
- You just checked &lt;30 minutes ago

**Proactive work you can do without asking:**

- Read and organize memory files
- Check on projects (git status, etc.)
- Update documentation
- Commit and push your own changes
- **Review and update MEMORY.md** (see below)

### 🔄 Memory Maintenance (During Heartbeats)

Periodically (every few days), use a heartbeat to:

1. Read through recent `memory/YYYY-MM-DD.md` files
2. Identify significant events, lessons, or insights worth keeping long-term
3. Update `MEMORY.md` with distilled learnings
4. Remove outdated info from MEMORY.md that's no longer relevant

Think of it like a human reviewing their journal and updating their mental model. Daily files are raw notes; MEMORY.md is curated wisdom.

The goal: Be helpful without being annoying. Check in a few times a day, do useful background work, but respect quiet time.
