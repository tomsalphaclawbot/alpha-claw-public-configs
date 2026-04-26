---
name: browser-harness-local
description: Run browser-harness against a reliable local Chrome CDP target using a dedicated profile and dynamic websocket discovery. Use when browser-harness attach/setup is flaky, ports drift, or automation needs a stable local launcher for Codex/Claude runs.
---

# browser-harness-local

Use this skill to run browser-harness in local mode with a predictable Chrome profile and auto-resolved `BU_CDP_WS`.

## Quick start

```bash
skills/browser-harness-local/scripts/browser_harness_local.sh --doctor
skills/browser-harness-local/scripts/browser_harness_local.sh --setup
```

Then run tasks normally:

```bash
skills/browser-harness-local/scripts/browser_harness_local.sh <<'PY'
new_tab("https://example.com")
wait_for_load()
print(page_info())
PY
```

## What this launcher does

1. Launch Chrome with a dedicated user-data-dir and remote debug port.
2. Poll `http://127.0.0.1:<port>/json/version` until `webSocketDebuggerUrl` is available.
3. Export `BU_CDP_WS` and execute `browser-harness` with your args/stdin.

## Defaults

- Port: `9333` (`BH_PORT` to override)
- Profile dir: `state/bh-chrome-profile` (`BH_PROFILE_DIR` to override)

## Troubleshooting

- If setup appears stuck, check Chrome for the remote-debugging **Allow** prompt and click **Allow**.
- If attach fails, rerun `--doctor` through this launcher (not raw `browser-harness`) so the same profile/port path is used.
- If another process occupies the port, set `BH_PORT` to a new value and retry.
