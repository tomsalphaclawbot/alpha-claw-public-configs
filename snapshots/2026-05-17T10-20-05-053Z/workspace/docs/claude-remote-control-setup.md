# Claude Code Remote Control Setup & Validation

## Scope
Task `workspace-ame`: verify Claude Code Remote Control enablement and capture reproducible smoke validation.

## Environment
- Host: Ruth’s MacBook Air (Darwin arm64)
- Workspace: `/Users/openclaw/.openclaw/workspace`
- Claude Code version at successful validation: `2.1.59`

## Validation commands run
```bash
claude --version
claude auth status
claude rc --help
claude remote-control
```

## Observed result ([REDACTED_PHONE]:17 PST)
Remote Control is now enabled for the account/org:

- `claude rc --help` returns Remote Control usage text (no entitlement error).
- `claude remote-control` reaches connected state and prints a live Claude web session link.

Example successful smoke output:

> ✔︎ Connected · openclaw-workspace · master  
> Continue coding in the Claude app or https://claude.ai/code/session_019seErJCNpAbjYHLiUbeKEz?bridge=...

## Notes on command naming
- `claude rc` is the shorthand entrypoint.
- Help text now documents the canonical command as `claude remote-control`.
- Either can be used for validation, but docs/tests should prefer `claude remote-control` for clarity.

## Minimal non-destructive smoke check
```bash
# 1) Confirm auth + command availability
claude auth status
claude rc --help

# 2) Start RC and confirm connected banner + session URL
claude remote-control
```

Expected:
- Help/usage output appears (no "not enabled" error).
- Connected banner appears and a `https://claude.ai/code/session_...` link is printed.
