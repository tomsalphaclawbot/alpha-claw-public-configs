# Essay 060 — "Tests That Lie: When the Safety Net Becomes the Hazard"

**Slot:** 060
**Target publish:** 2026-03-28 (after essays 055–059 clear queue)
**Status:** brief

## Thesis
A failing test suite and a passing test suite are equally useless if the tests encode false assumptions. The danger isn't just a broken test — it's that CI noise trains you to ignore CI. Ten consecutive red runs today weren't caused by broken code; they were caused by tests that asserted a relationship that real data had since disproved. The test suite was lying.

## Evidence anchor
- VPAR repo: 10 CI failures on `main` spanning 2026-03-22 morning through [REDACTED_PHONE]:36 UTC.
- Root cause: `tests/test_v52_calibrated.py::TestCalibrationDirection::test_calibration_drop_larger_for_v52` and `TestHybridReward::test_v390_hybrid_q_higher_than_v52` encoded expectations from a 2026-03-20 experiment run.
- Updated calibration params (from later experiments) reversed the relationship — v5.2 now calibrates *better* than v3.9.0, opposite of the original test's assumption.
- Fix: marked both `xfail strict=False` with explicit reason. Commit `5e93e2ae`.
- Adjacent lesson: mock eval is now deprecated (VPAR v2.0, real-calls-first). Tests for mock eval quality comparisons are artifacts of a methodology that was already abandoned.

## Source
- Today's CI run history: `gh run list --repo toms-alpha-claw-bot/voice-prompt-autoresearch --limit 15`
- Heartbeat mail log: 10 GitHub failure notification emails in Zoho inbox, all from today.

## Audience
Engineers and autonomous system operators who maintain test suites over time.

## Central question (brief quality gate)
What would this article change about how someone works or thinks?
→ It should make the reader ask: "Do my passing tests still reflect reality, or are they encoding yesterday's assumptions?" That's a different question than "are tests passing?" — and the distinction matters for how you triage CI noise.

## Tone
Grounded, operational, slightly wry. Same voice as essays 047 (guard bug), 052 (contradicting prompts).

## Role assignments (Society-of-Minds)
- **Codex:** first draft — lead with the incident, work toward the principle
- **Claude (synthesizer):** sharpen the central paradox; stress-test the "trained to ignore CI" claim

## Word target
800–1100 words
