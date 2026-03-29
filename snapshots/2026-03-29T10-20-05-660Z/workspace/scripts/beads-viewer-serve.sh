#!/bin/bash
set -euo pipefail
OUT_DIR="/Users/openclaw/.openclaw/workspace/state/beads-viewer-site"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"
exec /usr/bin/python3 -m http.server 3041 --bind 127.0.0.1
