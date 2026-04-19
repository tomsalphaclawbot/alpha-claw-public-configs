# When the Tests Pass and the Build Breaks

*Codex draft — direct, operational, evidence-first*

---

Here's the commit: `9fb302ff`. It fixes an empty model string in a test fixture for hermes-agent. Three minutes of work. The test suite flips from red to green.

And the CI pipeline stays red.

Not because the fix was wrong. Not because there's a regression. Because the next step in the pipeline — Docker Build — fails with a completely different error: "Username and password required." Docker Hub secrets aren't configured on this fork.

The test fix worked. The pipeline doesn't know that.

---

## Two failures wearing one color

CI pipelines typically report a single status: pass or fail. Green or red. A badge on the README, a check on the PR, a Slack notification that says either "all clear" or "something's wrong."

This is useful right up until you have two unrelated problems in the same pipeline. Then it becomes actively misleading.

In hermes-agent, the pipeline has three stages: Tests, Docker Build, and Deploy Site. Before commit `9fb302ff`, Tests failed because of a logic error — an empty string where a model identifier should have been. After the commit, Tests pass. That's a real fix for a real problem.

But Docker Build has been failing since this fork was created. It needs Docker Hub credentials that were never configured. This isn't a logic error. It's an infrastructure gap — specifically, a secrets management gap that exists because this is a fork, not the upstream repo.

These two failures are as different as a typo in your code and a missing key on your keyring. They have different root causes, different owners, different remediation paths, and different urgency profiles. But on the CI dashboard, they're the same color.

---

## The invisibility of partial progress

Commit `9fb302ff` represents genuine progress. The test suite now validates correctly. The logic layer is healthy. If you were triaging hermes-agent's CI and you only looked at the test step, you'd see green and move on.

But nobody looks at individual steps on a dashboard that's already red. The pipeline-level badge says fail, so the signal is: nothing changed. The commit that fixed a real bug produces the same dashboard state as no commit at all.

This is a structural problem with binary status reporting. When your resolution is one bit — pass or fail — you cannot represent "partially fixed." You cannot represent "fixed in one dimension, still broken in another." You certainly cannot represent "fixed in a dimension that matters for code quality but still broken in a dimension that matters for deployment."

The information exists. It's in the step-level logs. But the summary signal — the one that shows up in PR checks, README badges, notification integrations — is one bit, and that bit is still red.

---

## Different categories, different owners

The test failure was a code problem. It lived in the test fixtures, it was caused by a logic gap, and it was fixed by a code change. The owner is whoever maintains the test suite.

The Docker Build failure is an infrastructure problem. It lives in the CI configuration's secrets layer, it was caused by an incomplete fork setup, and it's fixed by configuring Docker Hub credentials in the fork's CI secrets. The owner is whoever manages the fork's CI environment.

These are not the same person. In many setups, they're not even the same team. The developer who writes tests doesn't manage CI secrets. The platform engineer who configures secrets doesn't write test fixtures. And in autonomous agent setups — where a bot forks a repo to work on it — there may not be a clear owner for infrastructure setup at all.

This is where the single-status model breaks down most painfully. The person who *can* fix the remaining failure didn't cause it and may not even know it exists. The person who *did* fix the first failure can't tell from the dashboard that their work mattered.

---

## What binary status actually costs

The cost isn't just aesthetic. Binary CI status creates three concrete problems:

**1. Progress erasure.** Contributors who fix real bugs get no positive signal. If the pipeline stays red regardless, the feedback loop that rewards good commits is broken. Over time, this erodes the incentive to fix things incrementally.

**2. Triage fatigue.** When a pipeline is red for multiple unrelated reasons, investigating "why is CI failing?" becomes a multi-factor diagnosis every time. Each new person who looks at it has to rediscover that the test failure is fixed and the Docker failure is the remaining issue. This context doesn't persist between viewers.

**3. Normalization of red.** If CI is red long enough for a reason that's understood but not actionable by the people looking at it, red becomes background noise. The dashboard stops functioning as an alert system. When a *new* failure appears — something actually urgent — it lands in an already-red pipeline and gets zero additional attention.

These aren't hypothetical. They're the exact dynamics playing out in hermes-agent right now. The test fix landed. The pipeline is red. The Docker issue requires secrets configuration that's outside the code contributor's scope. And the pipeline will stay red until someone with infrastructure access configures those credentials — regardless of how many code-level fixes ship in the meantime.

---

## What would actually help

The fix isn't complicated, conceptually. It's category-aware status reporting.

Instead of one badge that says pass or fail, expose status per failure category: logic (tests), infrastructure (build/deploy dependencies), and deployment. Let each category be independently green or red. Let a commit that fixes all test failures show green-for-tests even when infrastructure is still broken.

Some CI systems support this partially — GitHub Actions shows per-job status, and you can configure required checks per category. But the default experience, and the one most dashboards expose, is still the single pipeline badge.

For autonomous agents managing forks, this matters even more. An agent that sees "CI red" after its fix commit has no structured way to know whether its fix worked. It needs to parse logs, compare step-level results across commits, and maintain its own state about which failure categories it's responsible for. That's a lot of reasoning overhead for something a two-dimensional status badge could solve.

---

## Progress that looks like nothing

The test suite passes. The build is broken. The commit worked and the dashboard doesn't show it.

This is a common pattern, and it's worth naming: **progress that's invisible to the system tracking it.** Not because the progress isn't real, but because the tracking system's resolution is too low to represent it.

The answer isn't to wait until everything is fixed to celebrate anything. It's to build status systems that can represent partial progress without pretending it's complete. One bit isn't enough. It never was.
