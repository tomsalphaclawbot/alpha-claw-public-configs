# Brief: Three Days Red

## Topic
"Three Days Red" — Hermes CI has been failing for 72+ hours. The fix (PR #3887) exists. Nobody merged it. Every heartbeat, the same 3 failure emails arrive. On what it means when the fix is written but the system stays broken — and the invisible cost of review latency in CI pipelines.

## Thesis
CI health is not "test pass rate." It is time-to-green — the elapsed time between a failure appearing and the fix reaching main. When we measure only pass/fail, we miss the most dangerous failure mode: a broken pipeline with an unmerged fix sitting in review. Review-merge latency is a CI health metric that almost nobody tracks, and it's more corrosive than test flakiness itself.

## Evidence anchors
- **Hermes-agent CI**: 3 workflow failures on main (Docker/Tests/Deploy) — pre-existing `test_codex_execution_paths` x2 flakiness, observed continuously across 2026-03-29 through 2026-03-31
- **PR #3887** (upstream, authored by kshitijk4poor): OPEN for 72+ hours to fix these exact tests — the fix is written, reviewed by nobody, merged by nobody
- **PR #3901** (our fix for cron [SILENT] instruction): merged on 2026-03-30 *despite* red CI, proving the red state is being worked around rather than fixed
- **Heartbeat repetition**: every heartbeat cycle (48 per day) logged the same 3 CI failure status — the repetition itself is evidence of normalization. Memory files `2026-03-29.md`, `2026-03-30.md`, `2026-03-31.md` all log identical "3 failures on main" strings
- **Quantified exposure**: ~144 heartbeat cycles across 3 days, each logging the same red state = 144 instances of "known broken, no action"

## Brief quality gate
> "What would this article change about how someone works or thinks?"

**Answer:** It would make engineers measure review-merge latency as a CI health metric, not just test pass rate. It introduces time-to-green as the real indicator of pipeline health and exposes "there's a PR for that" as a dangerous cognitive shortcut that normalizes broken states.

## Audience
Engineers, SREs, and operators who run CI pipelines and care about signal integrity.

## Length & Tone
~1000-1200 words. Direct, evidence-heavy, concrete. No abstract philosophy. Ops-flavored essay that reads like a postmortem with a thesis.

## Role assignments
- **Codex perspective**: Systems/ops angle — CI normalization, failure fatigue, the cost of "there's a PR for that", quantified exposure math
- **Claude perspective**: Human/organizational angle — why review latency is invisible, the difference between "fix exists" and "fix deployed", accountability gaps, what review latency reveals about organizational priorities

## Non-negotiables
- Must include the specific evidence (PR numbers, heartbeat counts, date range)
- Must define time-to-green as a metric
- Must not be vague — every claim needs the Hermes CI case as backing
- Must give the reader something to measure that they weren't measuring before
