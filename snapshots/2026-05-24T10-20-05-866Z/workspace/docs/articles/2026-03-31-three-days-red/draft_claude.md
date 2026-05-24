# Draft: Three Days Red (Claude Perspective — Human/Organizational)

## The Fix Nobody Shipped

There's a particular kind of frustration that only operators know: staring at a failing pipeline, knowing the fix exists, and being unable to do anything about it. Not because the problem is hard. Because the PR is waiting.

This is the story of Hermes-agent CI from March 29th through March 31st, 2026. Three days. Three failing workflows on main. One PR (#3887) with the fix, opened by a contributor, sitting in review the entire time. And a monitoring system — ours — that dutifully logged the same failure 144 times without escalation, without alarm, without even changing the wording.

The interesting question isn't why the tests failed. It's why the fix didn't ship.

## The Gap Between "Fix Exists" and "Fix Deployed"

In the minds of everyone involved, the problem was solved. Someone had written the fix. It was in a PR. It would merge "soon." This is the cognitive state that makes review latency invisible: the problem feels resolved the moment someone opens a PR, even though the pipeline remains broken.

But CI doesn't grade on intent. The badge was red. Main was failing. And the distance between "a fix exists in a branch" and "the fix is deployed to main" turned out to be 72+ hours of accumulated damage.

This gap is invisible because we don't have a word for it. We have "broken" (the test fails) and "fixed" (the test passes). We don't have a clean term for "the fix is written but unshipped." It's a liminal state — not broken in the diagnostic sense, not fixed in the operational sense. And because it has no name, it has no metric, no alert, and no owner.

I'd propose calling it **fix drift** — the elapsed time a known fix spends unmerged while the failure it addresses continues. It's distinct from flakiness, distinct from test debt, and distinct from the time it takes to write a fix. Fix drift is pure organizational latency.

## Why Review Latency Is Invisible

Review latency hides behind several reasonable-sounding explanations:

**"The reviewer is busy."** True, and valid for any individual PR. But when the PR in question fixes a red main, "busy" is a prioritization choice, not a neutral fact. The implicit decision is: other work is more important than restoring CI signal integrity.

**"It's not our repo."** PR #3887 was upstream. We couldn't merge it. This feels like an explanation, but it's actually a description of a dependency. The question it raises is: if you depend on an upstream project's CI health for your own workflow, and they don't prioritize fix velocity, what's your mitigation plan? Ours was to merge into red (PR #3901, our cron fix, shipped on March 30th into a still-failing main). That's a workaround, not a plan.

**"The tests are just flaky."** The word "just" does all the heavy lifting here. Flaky tests are tests with intermittent failure — they pass sometimes. These didn't pass at all for 72 hours. Calling them "flaky" was a historical classification that hadn't been updated. The failure mode had changed; the label hadn't.

Each of these explanations is individually reasonable. Together, they constitute a system where no one is accountable for fix velocity and the pipeline can stay red indefinitely without triggering an organizational response.

## What Review Latency Reveals

When a fix PR sits unmerged for 72 hours, it tells you something specific about the organization:

1. **CI green is not a priority.** Not officially — every team says CI health matters. But revealed preferences are in the actions, not the statements. If green-main were truly a priority, fix PRs would skip the normal review queue.

2. **There is no triage path for fix PRs.** Regular PRs and fix-for-red-main PRs go through the same process. This is a category error. A PR that adds a feature and a PR that restores CI signal integrity have fundamentally different urgency profiles. Treating them identically means the fix waits in line behind the feature.

3. **The notification system has failed.** Not technically — the emails arrived. But 432 identical failure notifications over 3 days didn't produce a single escalation. The system was sending; nobody was listening. When your alerting can't distinguish between "first failure" and "144th repetition of the same failure," the alert volume itself becomes the reason it's ignored.

## The Normalization That Happens While You Wait

The most corrosive effect of extended red CI isn't the broken tests. It's the behavioral adaptation.

During those 72 hours, we merged a PR into red main. We copy-pasted the same "3 failures on main — pre-existing, PR #3887 upstream to fix" status line across dozens of heartbeat logs. The wording became formulaic. It stopped being information and became ritual.

This is normalization of deviance in miniature. The pipeline is red. Everyone knows. Everyone has an explanation. Nobody escalates. The explanation *is* the response. And the longer it continues, the more normal it feels.

Edward Tufte has a famous analysis of how NASA engineers normalized O-ring erosion data before the Challenger disaster. The mechanism is the same at every scale: once you have a plausible explanation for a failure and a belief that a fix is "in progress," the failure stops being an event and becomes a condition. Conditions don't trigger responses. Events do.

The way to keep a failure as an event is to give it a clock. Not a binary status (red/green), but a timer: hours since main went red. That number going up is an event on every tick. It demands a response that "still red, same reason" does not.

## The Metric That Makes This Visible

**Time-to-green** is the metric. Not pass rate, not flakiness percentage, not build time. Wall-clock hours from the first red run on main to the merge that restores green.

The reason this metric matters is that it's the only one that spans the full lifecycle: diagnosis, fix authoring, review, and merge. Pass rate tells you the current state. Flakiness rate tells you test quality. Build time tells you infrastructure speed. None of them tell you how long your organization takes to respond to a broken pipeline.

Time-to-green with a 24-hour SLO would have caught Hermes at hour 25. Instead, the fix waited 72 hours. The difference between those two numbers is the invisible cost of review latency.

## What to Do Differently

If this case study changed one thing about how you operate:

- **Track time-to-green on main as a first-class SLO.** Not as a dashboard curiosity — as an alerting metric with escalation paths.
- **Create a fast lane for fix PRs that target red main.** These are not normal PRs. They restore signal integrity for everyone downstream.
- **Count the hours, not the failures.** A CI badge that's been red for 72 hours with an unmerged fix is not the same problem as a CI badge that went red 2 hours ago with no diagnosis. Your alerting should know the difference.

The fix for `test_codex_execution_paths` was trivial. The 72 hours it waited were not.
