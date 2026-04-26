#!/usr/bin/env bash
set -euo pipefail

# Legacy entrypoint kept for compatibility.
# Dispatch now comes from tasks/ACTIVE.md via tasks-dispatcher.

exec "$(cd "$(dirname "$0")" && pwd)/tasks-dispatcher.sh" "$@"
