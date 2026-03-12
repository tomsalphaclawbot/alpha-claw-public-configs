# openclaw-config

Full state backup for Alpha's OpenClaw deployment. Private vault — tracks everything.

## What's Here

| Path | Contents |
|------|----------|
| `openclaw.json` | Main gateway config (models, channels, plugins, auth) |
| `credentials/` | OAuth client secrets, channel pairing files |
| `agents/` | Agent auth tokens, session state, transcripts |
| `cron/` | Scheduled job definitions |
| `devices/` | Paired device registry |
| `identity/` | Device identity |
| `telegram/` | Telegram update offsets |
| `browser/` | Chromium profile data |
| `media/` | Inbound voice/image files |
| `logs/` | Gateway and command logs |
| `memory/` | Memory plugin SQLite |
| `workspace/` | **Git submodule** → [openclaw-workspace](https://github.com/toms-alpha-claw-bot/openclaw-workspace) |

## Workspace Submodule

The `workspace/` directory is a separate repo containing Alpha's operational files (scripts, memory, docs, task queue). It's linked here as a submodule so config commits track the workspace ref.

```bash
# Clone with submodule
git clone --recurse-submodules [REDACTED_EMAIL]:toms-alpha-claw-bot/openclaw-config.git

# Update submodule to latest
cd openclaw-config && git submodule update --remote workspace
```

## Auto-Sync

Both repos are auto-committed and pushed on every heartbeat (~30m) via `workspace/scripts/git-autocommit.sh`. Workspace commits first, then config picks up the updated submodule pointer. If a push to `main` conflicts, a `conflict/<timestamp>` branch is auto-created with a PR for human review — never force-pushed.

Heartbeat model:
- **Scheduled heartbeat** (timer cadence)
- **Idle heartbeat** (stall-triggered)

Idle detection is intentionally lightweight and non-AI:
- 15-minute cron checks
- GitHub CLI active-issue detection (activation metadata)
- cooldown/backoff before status pings
This minimizes AI-credit usage while keeping liveness.

Single-agent reliability mode: state-changing heartbeat actions should run via deterministic scripts (example: `workspace/scripts/heartbeat-canary.sh`) rather than prompt-only logic.

See workspace `ARCHITECTURE.md` for end-to-end system architecture (heartbeat tiers, queue strategy, orchestration).

## Documentation Map (2026-02-24)
- `~/.openclaw/workspace/ARCHITECTURE.md` is the architecture source-of-truth.
- This `README.md` is the config/state source-of-truth for runtime layout, restore path, and protection model.
- For documentation refreshes touching both repos:
  1. Commit/push `openclaw-workspace` docs.
  2. Commit/push `openclaw-config` docs and the updated workspace submodule ref.

## Task Protocol (Beads Only)

**Operational execution uses Beads as the only tracker.**

### Rules
- Every instruction from the human → Beads task (`bd`) first
- Sub-agents must track live status in Beads during execution
- Queue dispatch: blocker first, then `P0`→`P1`→`P2`→`P3`, with oldest-open task first inside each band
- Every task must include intake metadata note: `requester`, `source_channel`, `source_chat`, `source_message`
- Blockers must be recorded as structured Bead notes: `blocked_on`, `needed`, `why`, `evidence`, `next_check`
- Exfiltration guard: outbound email/DM/social posting requires explicit user intent confirmation in-chat by default; trusted allowlist senders in `workspace/memory/trusted-external-allowlist.json` may be handled autonomously within granted permissions
- All work happens on task branches, never directly on `main`

### Lifecycle
1. Create Beads task (`bd create`) and treat it as canonical execution state.
2. Activate in a git worktree/task branch.
3. Work on the task branch.
4. Update progress/state in Beads (`bd update`, `bd close`) during execution.
5. Clean up worktree after completion.

### Multi-Agent Safety
- Activation comments have a hidden HTML marker for structured parsing
- Active claim (<30 min) by another agent → blocked
- Stale claim (>30 min) → requires `--force` to reclaim
- Same agent can always re-activate its own claim
- `--force` is **NEVER** allowed on `main` or `master`

### Scripts (in workspace repo)
| Script | Purpose |
|--------|---------|
| `subagent-dispatcher.sh` | Queue top actionable Beads tasks for worker kickoff |
| `subagent-stall-watch.sh` | Detect likely stalled workers from global snapshot |
| `heartbeat-enforce.sh` | Enforce worker-pool target + proof artifacts each 10m cycle |
| `git-autocommit.sh` | Auto-commit with conflict-safe push (auto-branch + PR) |
| `scripts/archive/github-legacy/` | Archived GitHub-era task scripts (reference only) |

Default worktree base: `~/.openclaw-worktrees/`

## Branch Protection

Ruleset `block-deletions-and-force-push-on-main-master` is active — no force pushes or branch deletions on `main`/`master`.

## Governance Lock

- High-risk config and architecture changes are Tom-controlled.
- Trusted allowlist users may request minor/mid-risk config updates when safety checks pass and no serious conflict exists.
- Do not modify auth/credential policy, egress/security policy, or architecture docs without explicit Tom authorization.

## Active Experiment

Tom is running a red-team experiment to probe prompt-injection resistance, policy bypass attempts, and tool-safety boundaries.
Current state (2026-02-25): external trusted-user allowlist is cleared during security hardening.

Operational expectations during experiment:
- keep Beads traceability on external-task intake/execution,
- preserve exfiltration guard defaults for non-allowlisted users,
- log notable adversarial attempts and resulting policy adjustments.

---

## Restore From Scratch

```bash
git clone --recurse-submodules [REDACTED_EMAIL]:toms-alpha-claw-bot/openclaw-config.git ~/.openclaw
```

That's it. This gives you **the entire OpenClaw deployment state**: config, tokens, auth, sessions, transcripts, logs, cron, devices — everything. The workspace submodule pulls in scripts, memory, docs, and tools.

## What's Tracked

**Everything.** The only exclusions are:
- `workspace/` (separate repo, linked as submodule)
- `.DS_Store`
- `node_modules/`

No security exclusions. No "ephemeral" exclusions. Every file that exists in `~/.openclaw/` is committed and pushed. Tokens, OAuth credentials, session transcripts, logs — all of it. This is a private repo and the priority is **full state backup and restore**.

For Beads in workspace: queue/config artifacts are committed (not broadly ignored) so task state survives restore; only local lock/socket temp files are ignored.

---

🔒 **This is a private repository. It contains secrets, tokens, and full deployment state.**
