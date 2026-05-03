# openclaw-workspace

**Private.** OpenClaw agent workspace (`~/.openclaw/workspace/`) for the `toms-alpha-claw-bot` org.

## What This Is

This is the working directory for Alpha (⚡), the AI assistant. It contains scripts, memory, documentation, and tools that the agent reads on every session startup.

## Project Creation Rule

Any new project (website/app/tool) created under workspace must be its own git repository (sub-repo), preferably under:

`projects/<project-name>/`

This keeps project histories isolated and maintainable.

## What's Tracked

**Everything.** The only exclusions are `.DS_Store` and `node_modules/`. No security exclusions, no "ephemeral" exclusions. Every file in this directory is committed and pushed. The priority is **full state backup and restore**.

## Focused Diff Policy (Token-Efficient Reviews)

- Commit behavior is unchanged: **we still commit everything** in both repos.
- For review/analysis/heartbeat triage, use `scripts/git-diff-focus.sh` to hide noisy runtime/binary artifacts.
- Exclude patterns are tracked in `config/diff-focus-excludes.txt`.
- Helper supports both repositories:
  - `scripts/git-diff-focus.sh --repo workspace`
  - `scripts/git-diff-focus.sh --repo config`

## Relationship to `openclaw-config`

| Repo | Path | Purpose |
|------|------|---------|
| [openclaw-config](https://github.com/toms-alpha-claw-bot/openclaw-config) | `~/.openclaw/` | Gateway config, agent settings, cron jobs |
| **openclaw-workspace** (this repo) | `~/.openclaw/workspace/` | Scripts, memory, docs, tools, daily notes |

This repo is nested inside `openclaw-config` but tracked independently (the parent's `.gitignore` excludes `workspace/`).

## Key Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | **Start here.** Task protocol, memory rules, safety guidelines, group chat behavior. Every agent reads this on startup. |
| `SOUL.md` | Agent personality and core values |
| `USER.md` | Info about the human (Tom) |
| `IDENTITY.md` | Agent name, emoji, avatar |
| `MEMORY.md` | Long-term curated memory (main session only — contains personal context) |
| `TOOLS.md` | Environment-specific notes (accounts, cameras, SSH, TTS voices) |
| `HEARTBEAT.md` | Checklist for periodic heartbeat polling |
| `TODO.md` | Legacy pointer; active task system of record is Markdown files under `tasks/` |
| `GITHUB_ISSUES_WORKFLOW.md` | Deprecated historical reference only (do not use for active tasking; see `BEADS.md` + `AGENTS.md`) |
| `EMAIL_AUTOMATION.md` | Email management policy and allowed actions |
| `PROJECTS.md` | Project registry + Docker/Compose + Cloudflare deployment runbook |
| `N8N_ACCESS.md` | n8n API management runbook (credentials source, safety workflow, endpoint patterns) |

See also: `ARCHITECTURE.md` for full operating model (heartbeat tiers, queue strategy, sub-agent orchestration).

Playbooks:
- `docs/playbooks/voice-ai-playbook-update-2026-02.md` — 2026 voice AI landscape brief + actionable implementation upgrades.

## Documentation Ownership (2026-02-24)
- **Architecture docs:** maintained in `ARCHITECTURE.md` (this repo).
- **Config/state docs:** maintained in `~/.openclaw/README.md` (`openclaw-config`).
- **Sync order:** update workspace docs first, then commit config repo with refreshed submodule pointer.

## Heartbeat Architecture

- **Scheduled heartbeat:** 30-minute holistic sweep only.
- Faster heartbeat schedules are disabled during stability lock.
- If active work needs liveness updates, the main thread posts direct progress updates instead of adding high-frequency scheduled heartbeats.

## Focused Diff Policy (Token-Efficient Reviews)

- Use `scripts/git-diff-focus.sh` for review/triage diffs (especially heartbeat automation).
- Excludes are tracked in `config/diff-focus-excludes.txt` (large/binary/runtime/noisy churn).
- This policy changes **display only**. Commit behavior is unchanged: we still commit all files.
- Supports both repos:
  - `scripts/git-diff-focus.sh --repo workspace`
  - `scripts/git-diff-focus.sh --repo config`

## Scripts (`scripts/`)

| Script | Purpose |
|--------|---------|
| `subagent-dispatcher.sh` | Queue top actionable tasks for sub-agent kickoff (legacy Beads hooks may still exist) |
| `subagent-stall-watch.sh` | Detect stalled worker runs from global worker snapshot |
| `subagent-global-status.sh` | Refresh canonical cross-thread worker snapshot (`state/subagents/*`) |
| `subagent-status-read.sh` | Read canonical active-worker snapshot for status replies |
| `subagent-update-enqueue.sh` | Enqueue async subagent progress/blocker/done updates for thread ping routing |
| `proactive-thread-target.sh` | Resolve most-recent eligible conversation thread/session target |
| `heartbeat-enforce.sh` | Enforce worker-pool target + proof artifact logging |
| `git-autocommit.sh` | Auto-commit workspace + config changes; conflict-safe push (auto-branch + PR on conflict) |
| `git-diff-focus.sh` | Token-efficient diff view with tracked excludes (`config/diff-focus-excludes.txt`) |
| `scripts/archive/github-legacy/` | Archived GitHub-era task scripts (reference only; not used) |
| `openclaw-watchdog.sh` | Gateway, channel, and caffeinate health checks |
| `discord-openclaw-check.sh` | Monitor Discord `#openclaw` for new posts |
| `heartbeat-canary.sh` | Deterministic 5m heartbeat canary executor (claim/update/close `heartbeat-test` beads) |
| `heartbeat-enforce.sh` | Deterministic 10m enforcement/proof step (worker-pool target + next-bead candidate + artifact log) |

## Memory (`memory/`)

- `memory/YYYY-MM-DD.md` — Daily raw notes
- `memory/heartbeat-state.json` — Tracks last check timestamps
- `memory/blocker-outreach.json` — Tracks blocker pings to avoid over-notifying

## Task Protocol

**Queue execution defaults to local Markdown task files under `tasks/`. Beads is optional and only used when explicitly requested.**

## Browser Automation Routing (Operational Default)

1. **Primary:** `skills/browser-use-via-claude-chrome` (desktop logged-in Chrome context) when safe/applicable.
2. **Fallback:** OpenClaw browser plugin/profile automation (`browser` tool) when Chrome extension path is unavailable.

Exceptions/caveats:
- Use OpenClaw browser plugin/profile automation when isolation/sandbox is safer.
- Because desktop sessions can be logged in, require explicit confirmation before risky external actions.

- Every instruction from Tom → tracked in Markdown task files (`tasks/`)
- After triage, start the highest-impact unblocked issue immediately (no permission prompt unless blocked/risky)
- Priority model: blocker first, then `P0`→`P1`→`P2`→`P3` (oldest-first inside each band; simplicity only tie-break)
- Single-agent operating loop: claim → execute → validate (evidence) → close/reconcile → mirror
- Use sub-agents in parallel for independent tasks; main-agent acts as coordinator
- Minute dispatcher cron (`scripts/subagent-dispatcher.sh`) auto-queues newly opened actionable issues for sub-agent kickoff
- Issue creation must be immediately followed by main-thread execution or sub-agent spawn (no parked tasks without blocker/risk note)
- Use the Markdown task schema consistently (priority, status, owner, blockers, notes, evidence)
- Keep task notes concise and evidence-oriented
- Work happens on `issue/<number>-<slug>` branches, never on `main`
- Blockers are represented by `blocked` label + blocker comment (status can remain `in_progress` while waiting)
- External interaction is currently read-only locked (no X posting / no third-party interaction unless Tom re-enables)
- Finalize as done when complete (record evidence and move task to done state)
- Agents/sub-agents coordinate through Markdown task updates (progress, handoffs, blockers, metadata)
- Sub-agent runs should include log-tracking references in the task record (session key, run id, log reference, heartbeat timestamp)
- Sub-agents may escalate/give up with a structured help-request note when blocked repeatedly
- See `AGENTS.md` for the full lifecycle
