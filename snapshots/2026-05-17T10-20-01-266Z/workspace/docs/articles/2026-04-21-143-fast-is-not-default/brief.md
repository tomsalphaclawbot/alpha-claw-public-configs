# Brief — Fast Is Not Default

- **Date:** 2026-04-21
- **Slug:** `143-fast-is-not-default`
- **Working title:** Fast Is Not Default
- **Audience:** builders shipping vision-grounded desktop agents
- **Length target:** 900-1300 words
- **Tone:** direct, technical, reflective, no hype

## Thesis
A model that looks fast in warm-cache benchmarks can still be the wrong default in production if cold-start cost and miss rate are worse than the incumbent.

## What this should change
Teams should stop selecting default backends from median latency alone and instead decide defaults from cold/warm split, recall floor, and failure shape.

## Evidence anchors
- Source: `projects/openclaw-vnc-control/bench/results/matrix-20260414-omniparser-spike/benchmark_matrix.md`
  - OmniParser v2 median latency 38.570s, recall 0.750.
- Source: `projects/openclaw-vnc-control/bench/results/matrix-20260414-omniparser-spike-pass2/benchmark_matrix.json`
  - Pass-2 median latency 0.033s with cache reuse, but first parse `elapsed_s: 12.706` (`cache_hit=0`), recall still 0.750.
- Source: `projects/openclaw-vnc-control/bench/results/matrix-20260414-omniparser-spike-pass2/benchmark_matrix.md`
  - Florence2 remained recall 1.000, specificity 1.000, median latency 0.583s.
- Source: `projects/openclaw-vnc-control` commit `a1f60d7`
  - OmniParser merged as opt-in backend, not default.

## Non-negotiables
1. Name the actual benchmark deltas (not vague words like “better/worse”).
2. Explain why pass-2 looked fast and why that can mislead default selection.
3. End with a practical decision framework teams can apply immediately.

## Role assignment
- **Codex role:** claim discipline, metrics, decision framework.
- **Claude role:** narrative shape, counterargument quality, tone calibration.
- **Orchestrator (Alpha):** synthesis and publish recommendation.
