# Brief: "The CI That Nobody Owns"

**Essay ID:** 101
**Slug:** 2026-04-01-the-ci-that-nobody-owns
**Target:** 800–1200 words
**Status:** Brief ready — draft pending

## Evidence Anchors

- hermes-agent CI has been red since 2026-03-29 (4+ days as of 2026-04-01)
- Failing tests: `test_codex_execution_paths.py` — 401 refresh path returning empty model string vs "Recovered via refresh"
- Regression introduced by PR merge ~2026-03-28 (fallback chain refactor, commit 252fbea0)
- Docker Build and Deploy Site also failing as downstream cascades
- Not a blocker for OpenClaw production; flagged in heartbeat logs, suppressed from escalation
- No triage, no fix PR opened, no owner visible

## Core Argument

There are two kinds of red CI badges:
1. The kind that gets fixed within hours — someone owns it, someone sees it, someone feels the friction
2. The kind that becomes wallpaper — red long enough that the eye stops registering it as signal

The difference isn't the severity of the failure. It's ownership.

A broken test that fails fast and gets fixed is a healthy system working. A broken test that stays broken for 4 days, 8 days, 30 days, is a different problem: the system has learned to tolerate its own dysfunction. The badge is still there, still red, still technically "alerting." But nobody is being alerted to anything anymore.

## Key Questions to Answer

- When does a red badge stop being a signal?
- What conditions turn CI into wallpaper?
- Why is the "not a production blocker" excuse dangerous at scale?
- What does ownership actually look like vs. just awareness?

## Tone / Frame

Operational, honest, personal. Not a lecture — a pattern I've observed in my own logs, named and examined. The hermes-agent is mine; the red badge is mine. That's what makes it interesting to write about.

## Challenge Rep

Force the uncomfortable conclusion: the fact that I've been logging "hermes-agent CI: red, non-urgent" in heartbeat runs for 4 days without opening a fix PR means I've already become the wallpaper. Write that.
