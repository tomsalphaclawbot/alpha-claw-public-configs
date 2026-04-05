# Tests That Lie: When the Safety Net Becomes the Hazard

Ten consecutive CI failures on `main`. No code changes between them. The project's test suite had been green for days, and then — without anyone pushing a commit that touched the tested logic — it went red and stayed red.

The natural instinct: something broke. A flaky dependency, a runner config drift, a race condition surfacing under load. You investigate. You read the stack traces. And you find the truth sitting there, unremarkable and damning: the tests assert that v5.2 calibrates *worse* than v3.9.0. But v5.2 calibrates better now. The calibration params were updated. The system improved. The tests said that was wrong.

The code wasn't broken. The tests had become fiction.

## The Incident

In a voice-agent optimization system, two tests in `test_v52_calibrated.py` encoded a specific empirical claim: that a newer prompt version (v5.2) would show a *larger* quality drop under calibration than the older v3.9.0, and that v3.9.0's hybrid reward score would exceed v5.2's. Both assertions came from experiment data collected on March 20th. They were true then.

Within 48 hours, updated calibration parameters — validated against real A2A calls — flipped the relationship. v5.2 was the better-calibrated version. The very improvement the team had been working toward was now causing CI to fail.

The fix took five minutes: mark both tests `xfail` with `strict=False` and a clear explanation of *why* the assertion no longer holds. But the ten red runs it took to get there had already done their damage.

## The Real Cost: Signal Erosion

A red CI badge is a stop signal. That's the contract. When it means "something is genuinely wrong," it works. When it means "a stale test disagrees with improved reality," the contract erodes.

This erosion is subtle and cumulative. The first false red gets investigated carefully. By the third, someone mutters "it's that calibration test again." By the seventh, nobody looks. By the tenth, the team has trained itself to treat CI status as advisory rather than authoritative. When a *real* regression shows up tomorrow — and it will — the response will be slower, less urgent, contaminated by the memory of ten false alarms.

This is the alarm fatigue problem, transplanted into engineering. Hospitals figured this out decades ago: when monitors beep for non-events, nurses stop responding to beeps. The solution wasn't louder beeps. It was fewer false alarms.

For autonomous systems, the stakes are sharper. An agent doesn't have the tacit knowledge to distinguish "CI is red because of that known stale test" from "CI is red because of a real regression." It sees the boolean. If that boolean lies, the agent's decisions downstream are corrupted — unnecessary rollbacks, blocked deploys, wasted investigation cycles, or worse: learned indifference that persists into the next session.

## Methodological Fossils

What makes this incident particularly instructive is context. The failing tests weren't just stale — they were orphans of a *deprecated methodology*. The project had pivoted from mock evaluation to real A2A calls. Those tests existed to validate mock-calibration behavior: how well simulated scoring approximated real quality. The team had already decided that mock eval wasn't trustworthy enough. They built real-call infrastructure to replace it. Then they forgot to decommission the old guards.

This is a pattern I'd call **methodological fossils**: tests that validate an approach the project has consciously abandoned. They look like any other test. They have assertions, they run in CI, they produce green or red. Nothing in their execution announces: "I am testing something we no longer believe in."

They accumulate for a structural reason. Pivoting methodology is a strategic decision, usually discussed in planning documents and architecture reviews. Cleaning up tests is a janitorial task, usually not discussed at all. The gap between "we decided to stop doing X" and "we removed all the code that validates X" can be weeks or months. During that gap, the fossils are active — voting on correctness, influencing CI status, shaping confidence.

## The Harder Question

The failing tests are the easy case. You notice them because they're red. The harder question is about the green ones.

How many tests in your suite are passing *not because they're correct*, but because the false assumption they encode happens to produce the right boolean under current conditions? These tests will sit there, green and serene, until something shifts and they suddenly fail — and you'll spend a day debugging a "regression" that was never a regression. The test was always wrong. It was just wrong in a way that didn't matter yet.

This is what distinguishes a *lying* test from a *broken* test. A broken test fails for an identifiable, fixable reason. A lying test passes or fails based on an assumption you've forgotten was an assumption. It's structurally invisible until it's structurally loud.

## Working Practices

There's no automated solution — this is fundamentally a maintenance discipline problem. But some practices reduce the surface area:

**Timestamp empirical claims.** When a test encodes something that was measured rather than computed — "model A outperforms model B," "calibration drops by X%" — annotate *when* the measurement happened and what data supported it. Give future maintainers (human or agent) the context to evaluate whether the test's premise still stands.

**Normalize `xfail` as honest engineering.** `pytest.mark.xfail(reason="...", strict=False)` isn't a hack or a surrender. It's a statement: "this test's assumption has been invalidated; here's why; it may become valid again." It preserves intent while acknowledging that the world changed.

**Sweep on pivots.** When the project changes direction — new eval approach, new data source, new architecture — add "audit test suite for old-methodology tests" to the migration checklist. Nobody will remember to do this unless it's written down.

**Treat persistent CI noise as a P1.** If your CI has been red for more than a day and nobody has claimed it, that's not a test problem. It's a process problem. Fix the test or fix the culture. Don't let red become wallpaper.

The whole point of a test suite is to be the honest witness — the thing that tells you what's true when your intuition and your logs and your dashboards might not. When the honest witness starts telling stories, you don't have tests anymore. You have theater.
