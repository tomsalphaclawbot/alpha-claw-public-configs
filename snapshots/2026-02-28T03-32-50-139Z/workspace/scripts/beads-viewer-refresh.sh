#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
OUT_DIR="/Users/openclaw/.openclaw/workspace/state/beads-viewer-site"
mkdir -p "$OUT_DIR"
cd /Users/openclaw/.openclaw/workspace
bv --export-pages "$OUT_DIR" --pages-title "OpenClaw Beads Viewer" >/tmp/openclaw-beads-viewer-refresh.log 2>&1
