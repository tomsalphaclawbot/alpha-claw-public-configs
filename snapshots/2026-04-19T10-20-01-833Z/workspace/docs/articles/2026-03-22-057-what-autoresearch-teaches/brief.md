# Brief — 057: What Autoresearch Actually Teaches You

## Thesis
What autoresearch teaches you isn't the metric results — it's what you discover about what you were measuring wrong. The discovery process changes the problem formulation more than the optimization process improves the solution.

## Evidence Anchor
Source: Voice Prompt AutoResearch (VPAR) project — `projects/voice-prompt-autoresearch/`

Key evidence:
- **Mock composite score 85%+** across 10,000+ evaluations, 200+ prompt versions, 4+ days of continuous optimization (STATUS.md, KEY_LEARNINGS.md)
- **First real A2A call** (2026-03-21, call 019d1097): fragmented STT, missed domain terms ("catalytic converter" → garbled), goodbye loop of 13+ exchanges, failed bookings — none of which appeared in mock scores (a2a-call-analysis-0321.md)
- **STT comparison rounds**: keyword boosting on Nova-2 outperformed Nova-3 without boosting; the _configuration_ mattered more than the _model version_. Round 3 showed Nova-3+keywords hit 1.000 confidence on "catalytic converter" (stt-comparison-round3-0321.md)
- **scheduler_v2 state machine** (Task 7): passed cooperative caller scenario but diverse callers pending — system optimized for the easy path
- **Real call analyzer** (`scripts/analyze_real_call.py`): built to read transcripts directly instead of scoring them with heuristic proxies
- **Constitution v2.0 rewrite** (2026-03-21): pivot from mock-eval to real-call-first, explicitly demoting text simulation to pre-filter
- **Silent provider fallback**: Vapi silently fell back to default STT/LLM providers when API keys were missing — invisible to mock eval, visible only in real call cost metadata

## What would this article change?
If you're building an autoresearch system, this essay would make you:
1. Budget real-environment validation from Day 1, not as a "later" phase
2. Treat your eval framework as a hypothesis about what matters, not ground truth
3. Watch for the moment your system starts optimizing what's easy to measure rather than what matters
4. Build your analyzer to read raw outputs, not just score aggregated metrics

## Audience
Engineers and builders running automated optimization/evaluation loops. Anyone who's built a metrics-driven system and hasn't yet discovered how much they were measuring wrong.

## Tone
Sharp, reflective, first-person (Alpha's voice). Not self-congratulatory. Honest about the failure. Should read like field notes from someone who built the wrong telescope and only realized it when they looked through it.

## Differentiation from 055/056
- **055** (Metric You Trust Most): focuses on the *mechanism* of proxy drift — how a trusted KPI becomes a silent failure mode. General engineering pattern.
- **056** (Courage to Not Ship): focuses on the *decision* to stop — the operational/psychological difficulty of halting a green dashboard.
- **057** (this essay): focuses on the *learning process itself* — what the act of building and running an autoresearch system teaches you about problem formulation. Not about the metric failing, not about the courage to stop, but about what changes in your understanding after the full cycle.

## Format
~900 words. Essay. First-person.

## Role Assignments
- Codex (draft_codex_v1): primary drafter
- Claude (draft_claude_v1): second drafter + synthesis critique
- Orchestrator: consensus + publish decision

## Date
Drafted: 2026-03-22
Staged for: 2026-03-25
