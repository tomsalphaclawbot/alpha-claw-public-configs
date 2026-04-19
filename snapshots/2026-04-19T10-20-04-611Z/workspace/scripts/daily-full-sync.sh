#!/usr/bin/env bash
set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
LOG_DIR="$HOME/.openclaw/logs"
LOG_FILE="$LOG_DIR/daily-full-sync.log"
LOCK_DIR="/tmp/openclaw-daily-full-sync.lock"

mkdir -p "$LOG_DIR"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" >> "$LOG_FILE"; }

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "skip: lock held"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" >/dev/null 2>&1 || true' EXIT

log "start: running scripts/git-autocommit.sh (workspace + config, all changes)"
if /Users/openclaw/.openclaw/workspace/scripts/git-autocommit.sh >> "$LOG_FILE" 2>&1; then
  log "done: git-autocommit completed"
else
  code=$?
  log "error: git-autocommit exited code=$code"
fi

# Post-pass for workspace: if prior pre-push guards left staged metadata changes,
# run bd sync + retry push so the daily run still converges.
cd "$HOME/.openclaw/workspace"
if [[ -n "$(git status --porcelain)" ]]; then
  log "post-pass: workspace still dirty, attempting bd sync + push retry"
  bd sync >> "$LOG_FILE" 2>&1 || true
  if [[ -n "$(git status --porcelain)" ]]; then
    git add -A >> "$LOG_FILE" 2>&1 || true
    if ! git diff --cached --quiet; then
      git commit -m "auto: workspace daily sync post-pass $(date '+%Y-%m-%d %H:%M')" >> "$LOG_FILE" 2>&1 || true
    fi
  fi
  git push origin HEAD >> "$LOG_FILE" 2>&1 || true
fi

# Sub-repo pass: keep Obsidian vault repo in sync as part of daily cron.
OBSIDIAN_REPO="$HOME/.openclaw/workspace/obsidian_vault"
if [[ -d "$OBSIDIAN_REPO/.git" ]]; then
  log "start: obsidian_vault daily sync"
  cd "$OBSIDIAN_REPO"

  # Rebase first to reduce push conflicts.
  git pull --rebase origin main >> "$LOG_FILE" 2>&1 || true

  if [[ -n "$(git status --porcelain)" ]]; then
    git add -A >> "$LOG_FILE" 2>&1 || true
    if ! git diff --cached --quiet; then
      git commit -m "auto: obsidian vault daily sync $(date '+%Y-%m-%d %H:%M')" >> "$LOG_FILE" 2>&1 || true
    fi
  fi

  git push origin HEAD >> "$LOG_FILE" 2>&1 || true
  log "done: obsidian_vault daily sync"
else
  log "skip: obsidian_vault repo not found"
fi
