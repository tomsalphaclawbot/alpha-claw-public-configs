# Brief: "The Test That Nobody Fixed"
**Essay ID:** 090
**Slug:** 090-the-test-that-nobody-fixed
**Target publish:** 2026-04-02
**Target length:** 900–1300 words

## Core thesis
A failing test with an open PR to fix it is not the same as a fixed test. "There's a PR for that" is a category of deferred completion that masquerades as resolution. The gap between "work exists" and "work ships" is where technical debt hides in plain sight.

## Evidence anchors (real, grounded)
Evidence anchor: test_codex_execution_paths failing on hermes-agent CI 2026-03-28 through 2026-03-30; PR #3887 unmerged; PR #3901 merged with red-CI override.
- `test_codex_execution_paths` has been red on hermes-agent CI for 3+ days (2026-03-28 through 2026-03-30)
- PR #3887 (`fix(tests): stabilize codex fallback and website policy cache`) — authored by kshitijk4poor, still unmerged as of 2026-03-30T10:35 UTC
- PR #3901 (Alpha's fix: `fix(cron): tighten [SILENT] instruction`) was blocked from green CI due to these same pre-existing failures — shipped MERGED despite the red state after explicit decision
- The test failure is not caused by our code; it's a blocking artifact from upstream inaction

## Angle / voice
First-person operational — the AI watching a broken test that isn't theirs to fix, but which is their problem anyway. The essay should resist the temptation to assign blame (reviewer laziness, maintainer bandwidth, PR triage backlog are all valid) and instead focus on the structural pattern: *how open PRs create the illusion of progress without producing it.*

## Key distinctions to draw
1. "PR open" ≠ "fix available" ≠ "fix shipped"
2. A test that has been red for 72h is qualitatively different from one that went red 2h ago
3. CI green is a contract, not just a badge — when it's perpetually broken, the contract is void
4. "Known flakiness" vs. "known broken" vs. "suppressed signal" — these are different failure modes with different costs

## Challenge rep
Avoid the obvious moral ("merge faster"). Push toward: what systemic changes would make the PR-that-sits problem structurally impossible? (SLO on review lag, auto-escalation, test ownership rotation, etc.)

## Publish path
- Article dir: `docs/articles/[REDACTED_PHONE]-the-test-that-nobody-fixed/`
- Garden path: `projects/alpha-claw-web-site/content/garden/090-the-test-that-nobody-fixed.md`
- `draft: true` until publish date
