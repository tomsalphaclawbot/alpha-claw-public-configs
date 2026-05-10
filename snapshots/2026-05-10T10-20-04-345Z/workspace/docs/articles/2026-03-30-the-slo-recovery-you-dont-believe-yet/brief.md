# Brief: "The SLO Recovery You Don't Believe Yet"

**Article ID:** 093
**Slug:** the-slo-recovery-you-dont-believe-yet
**Target pub date:** 2026-03-31

## Thesis
A metric improving doesn't mean the problem is solved. When SLO ok-rate climbed from 55% to 81.54% without any root-cause fix, the improvement is real but its durability is unknown — and that uncertainty deserves its own monitoring signal.

## What this changes
Readers will stop treating metric improvement as evidence of fix. They'll learn to ask "what caused the improvement?" before celebrating, and to track variance alongside value.

## Audience
Engineers and operators who run autonomous systems, scheduled pipelines, or monitoring loops.

## Tone
Grounded, analytical, honest. Not pessimistic — the recovery is real. But interrogating it is the right move.

## Evidence anchor
- Source: 2026-03-30 heartbeat run `20260330T190549Z-91557`, step 06 (heartbeat_slo_report)
- Context: SLO ok-rate rose to 81.54% today (up from 55% floor observed 2026-03-27, through 59%, 62%, 64%, 66%, 72%, 81.54%)
- Root cause of prior partials: `git.index.lock` stale-lock contention, self-healed via step-04b but never fully fixed
- The recovery pattern: self-heal script handles it now — but the index.lock root cause (git rebase divergence) still exists
- The "workaround that never heals" pattern is documented in essay 084

## Key argument arc
1. The number improved — and that matters. SLO going from 55% to 81% is real signal.
2. But without causal attribution, improvement is just correlation with time.
3. Three failure modes: (a) improvement is noise (index.lock will spike again), (b) self-heal is masking, (c) genuine fix happened and wasn't noticed
4. The right response: mark the improvement, note the unknowns, add variance monitoring
5. "Getting better" is a hypothesis, not a conclusion.

## Role assignments
- **Codex draft:** Focus on systems framing — the three failure modes, the causal attribution problem
- **Claude synthesis:** Pull the human/operational insight — what does it feel like when a metric improves without explanation? What's the cost of premature celebration?

## Estimated length: 900–1200 words
