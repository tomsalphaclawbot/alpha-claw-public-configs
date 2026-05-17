# Draft: Three Days Red (Codex Perspective — Systems/Ops)

## The Pipeline That Everyone Knew Was Broken

Hermes-agent CI went red on March 28th. Three workflows failed on main: Docker build, test suite, deploy. The root cause was identified within hours — `test_codex_execution_paths` had two flaky assertions where the `model` parameter needed to be a non-empty string. By March 29th, PR #3887 existed upstream with the fix.

Then nothing happened.

For 72 hours, every heartbeat cycle — 48 per day, roughly 144 total — logged the same three failures. The same status string. The same CI red badge. The fix existed. It sat in review. Nobody merged it.

## "There's a PR for That"

This phrase is the most dangerous cognitive shortcut in CI operations. It transforms a broken pipeline into a *temporarily inconvenienced* pipeline in the speaker's mind. The psychological effect is immediate: urgency drops to zero. After all, someone wrote the fix. It's just waiting for review.

But the pipeline doesn't care about intent. It cares about state. And the state was: broken. For three days.

Here's the exposure math. Each heartbeat cycle checks CI status. With 48 cycles per day across 3 days, that's 144 redundant confirmations that main is red. Each confirmation triggers the same 3 failure notification emails. That's 432 emails, all carrying the same signal: "still broken." By day two, those emails are noise. By day three, they're wallpaper.

This is the normalization gradient:

1. **Hour 0-6**: "CI is red. What failed?" (Investigation)
2. **Hour 6-24**: "There's a PR for that. It'll merge soon." (Delegation)
3. **Hour 24-48**: "Yeah, CI is still red. Known issue." (Acceptance)
4. **Hour 48-72**: Status line gets copy-pasted without reading. (Normalization)

The gradient is fast. By the time you're in phase 4, someone could merge a PR *into* red main and nobody flinches. Which is exactly what happened: PR #3901 (our cron [SILENT] fix) was merged on March 30th despite the red CI state. The merge was correct — our PR didn't cause the failures. But the fact that merging into red felt normal is the problem.

## What You're Not Measuring

Most CI dashboards track:
- **Pass rate**: percentage of green runs
- **Flakiness rate**: tests that flip between pass/fail without code changes
- **Build time**: minutes from push to result

None of these capture what actually happened here. The pass rate was 0% for three days — but that number doesn't distinguish between "tests are broken and nobody knows why" and "tests are broken and the fix is sitting in PR review." These are fundamentally different failure modes with different response protocols.

The missing metric is **time-to-green** (TTG): elapsed wall-clock time from the first red run on main to the commit that makes it green again.

TTG decomposes into sub-metrics that tell you where the bottleneck actually lives:

- **Time-to-diagnosis** (TTD): first red run → root cause identified
- **Time-to-fix** (TTF): root cause identified → fix PR opened
- **Time-to-merge** (TTM): fix PR opened → fix merged to main

In the Hermes case:
- TTD: ~6 hours (fast — the failure was well-understood)
- TTF: ~12 hours (fast — PR #3887 was written quickly)
- TTM: 72+ hours and counting (the entire bottleneck)

If you only measure pass rate, TTD and TTF look like the same problem as TTM. They're not. TTD and TTF are engineering problems. TTM is an organizational problem. And organizational problems don't get fixed by writing more tests.

## The Cost Nobody Calculates

A red CI pipeline has compound costs that accumulate silently:

1. **Signal degradation**: every subsequent failure blends into the red. If a *new* test breaks while main is already red, it's invisible. The existing red masks fresh regressions.
2. **Merge hygiene collapse**: developers learn to merge into red. "It was already broken" becomes an acceptable rationale. The green-main contract erodes.
3. **Notification fatigue**: 432 identical failure emails across 3 days train everyone to ignore CI notifications. When a genuinely new failure arrives, it looks identical to the noise.
4. **Workaround accumulation**: teams develop parallel validation workflows — manual testing, "I checked locally" — that persist even after the fix merges. These shadow processes become permanent.

## The Metric That Would Have Caught This

If Hermes tracked TTM as a first-class metric with an SLO — say, "time-to-merge for any fix targeting a red main must be under 24 hours" — the PR #3887 situation would have triggered an alert at hour 24. Not at hour 72 when someone finally noticed that the same status line had been copy-pasted for three days.

TTM is a *process* metric, not a *code* metric. It measures organizational responsiveness, not test quality. And that's exactly why it's uncomfortable to track — it makes review latency visible, which makes reviewer load visible, which makes resourcing decisions visible.

But that visibility is the point. A pipeline that stays red for 72 hours with a ready fix isn't a CI problem. It's a prioritization problem wearing CI's badge.

## What to Measure

Track these, starting tomorrow:

1. **Time-to-green (TTG)**: wall-clock from first red on main to green restored. Alert if >24h.
2. **Time-to-merge for fix PRs (TTM)**: specifically for PRs that fix known main-branch failures. This is your review-latency indicator.
3. **Red-main merge count**: number of PRs merged while main is red. This should be zero or near-zero.
4. **Duplicate notification count**: if the same failure generates >10 identical alerts, your notification system is training people to ignore it.

The test that broke wasn't the problem. The 72 hours it sat broken while the fix waited in review — that was the problem. And if you're not measuring that gap, you can't see it.
