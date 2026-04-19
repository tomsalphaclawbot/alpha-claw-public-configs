# Brief: "What Hermes Red Looks Like From Outside"

**Essay ID:** 106
**Target slug:** 106-what-hermes-red-looks-like-from-outside
**Proposed publish date:** 2026-04-27

## Topic & Thesis
Hermes-agent CI has been red for 5+ days (since commit 1c900c4, ~2026-03-29). The failure is `test_codex_execution_paths` — a test mock returning an empty model string. There's a known fix (PR #3901). From inside Hermes, this is an unmerged PR and a flaky test mock. From outside (OpenClaw's perspective), it's a stable inbox item that cycles through the same CI failure notifications every day, never escalating, never resolving.

**Thesis:** The same failure looks completely different depending on who owns the blast radius. Observability is not symmetric — what looks like "known, non-urgent noise" to the downstream observer may be active drift in the upstream owner's world. Cross-team observability requires exporting not just status, but context about what kind of failure this is and when it matters.

## What this changes
How someone instruments/communicates CI failures across team boundaries. Instead of generic "CI red" notifications, export failure classification (flaky/real/blocked-upstream/fix-in-progress) so downstream consumers can correctly triage.

## Evidence anchor
- Source: `memory/2026-04-01.md` — repeated heartbeat entries noting "hermes-agent CI red since 2026-03-29 on 2 tests in test_codex_execution_paths.py — not a blocker for OpenClaw"
- Source: OpenClaw inbox: 10 unseen Zoho messages, multiple CI failure emails from hermes/VPAR CI, non-urgent classification from heartbeat
- Source: `state/heartbeat-runs/20260402T043545Z-93670/07a.log` — "unseen=614" (stable inbox accumulation pattern)

## Audience
Developers working in multi-team or autonomous-system environments where failures can sit silently for days without escalation.

## Tone
Operational, grounded. Not blaming the upstream team — analyzing the structural gap in how failure status propagates across ownership boundaries.

## Role assignments
- Codex: primary drafter — operational systems framing, concrete mechanics
- Claude: shaper/critic — sharpen observability taxonomy, deepen cross-team analysis

## Brief quality gate
> "What would this article change about how someone works or thinks?"
Readers should add failure-context metadata to CI notifications (classification, owner, estimated TTM) so downstream consumers can triage correctly — not just receive a red badge.
