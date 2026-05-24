# When the Tests Pass and the Build Breaks

*Claude draft — reflective, conceptually richer*

---

There's a particular kind of frustration that comes from doing the right thing and having no evidence to show for it. You fix the bug. The tests go green. And the CI badge stays red, because something else — something entirely unrelated to your fix — is also broken, and the dashboard can't tell the difference.

Commit `9fb302ff` in hermes-agent fixed an empty model string in a test fixture. Clean, surgical, correct. The test suite went from failing to passing. And the pipeline summary didn't change at all, because the Docker Build step — which has nothing to do with test logic — has been failing since the fork was created. "Username and password required." Docker Hub secrets were never configured.

Two problems. One status indicator. And a commit that represents real progress trapped behind a signal that can't represent it.

---

## The taxonomy of red

Not all failures are the same failure. This sounds obvious when stated directly, but CI systems are designed around a premise that contradicts it: a pipeline either passes or it doesn't. The reasons are details. The status is binary.

In hermes-agent, the pipeline runs three stages: Tests, Docker Build, Deploy Site. Before the fix, Tests failed due to a logic error — a missing model identifier that caused assertions to blow up. After `9fb302ff`, Tests pass cleanly. This is a logic-layer fix, entirely within the code contributor's domain.

Docker Build fails because the fork doesn't have Docker Hub credentials configured in its CI secrets. This is an infrastructure-layer problem. The code is fine. The Dockerfile is fine. The credentials just aren't there, because setting up secrets on a fork is a separate operation from forking the code itself.

These failures belong to different taxonomies. One is about *what the code does*. The other is about *what the environment has*. They have different causes, different fixes, different responsible parties, and different timelines. But on the dashboard, they collapse into a single state: red.

The word for this in information theory is lossy compression. You take a multi-dimensional signal and reduce it to a single bit. Some information survives. Most doesn't. And the information that doesn't survive is exactly the kind you need to make good decisions.

---

## The epistemology of a CI badge

A CI badge is a knowledge claim. When it's green, it asserts: "every check we know how to run has passed." When it's red, it asserts: "at least one check failed." 

The asymmetry matters. Green is a conjunction — *all* conditions met. Red is a disjunction — *any* condition failed. This means green is fragile (one new failure breaks it) and red is sticky (one persistent failure masks everything else).

For hermes-agent, the stickiness of red is the problem. Docker Build has been failing since the fork existed. It was failing before the test suite was fixed, and it's failing after. The badge was red then and it's red now. From the badge's perspective, commit `9fb302ff` never happened.

This creates a strange epistemic situation. The contributor knows the fix worked — they can check the test step and see green. But the *system's* representation of the project's health doesn't reflect that knowledge. The dashboard and the reality have diverged, and the dashboard is the thing that other people (and other systems) consult.

For autonomous agents, this divergence is particularly acute. An agent that submits a fix and checks the pipeline status sees red. Without sophisticated log parsing and step-level comparison logic, it has no structured way to determine whether its fix succeeded. The system of record says "still broken." The agent has to decide whether to trust the system or do its own investigation — and that decision requires exactly the kind of contextual judgment that binary status indicators were supposed to eliminate.

---

## The ownership boundary problem

There's a deeper issue here than dashboard resolution. It's about organizational boundaries embedded in technical pipelines.

The test failure had a clear owner: whoever maintains the code and test fixtures. The fix was a code change, merged through the normal code review path. This is the happy case — problem and solution live in the same domain.

The Docker Build failure has a murkier ownership story. On the upstream repo, Docker Hub secrets are presumably configured by whoever set up the CI environment. On a fork, those secrets don't transfer. Someone needs to configure them — but who? The person who forked the repo may not have Docker Hub access. The person with Docker Hub access may not know this fork exists.

In autonomous agent workflows, this gap is even wider. An agent forks a repo to contribute. It can modify code, run tests, create pull requests. But it typically can't configure CI secrets on the fork, because that requires account-level access to the CI platform. The agent can fix every code bug in the repo and the pipeline will stay red, because the infrastructure layer is outside its action space.

This is the shape of the problem: **a single status indicator spanning multiple ownership domains, where progress in one domain is invisible because of persistent failure in another.**

It's not just a CI problem. It's a pattern that shows up anywhere a composite system reports a single aggregate status. A deployment that's healthy-at-the-app-layer but degraded-at-the-network-layer. A project that's on-track-for-features but blocked-on-compliance. A team that's shipping-code but failing-reviews. The aggregate status says "not okay," and the dimension where things improved gets lost.

---

## What partial progress needs

The instinct when confronted with this problem is to make the status more granular. Show per-step results. Add category labels. Break the single badge into multiple badges.

This helps, but it's not sufficient. Granularity alone doesn't solve the ownership mapping problem. You need three things:

**Category-aware status.** Not just "which step failed" but "what kind of failure is this?" Logic errors, infrastructure gaps, configuration drift, and transient flakes are different categories that demand different responses.

**Ownership tagging.** Each failure category should map to a responsible party or action domain. When an autonomous agent sees "Docker Build: failed (infrastructure — secrets not configured)," it knows this isn't its problem. When it sees "Tests: passed (logic — all assertions green)," it knows its fix worked. The information was always in the logs. The status system should surface it.

**Progress-aware comparison.** The ability to see that *something changed* even when the aggregate status didn't. Commit `9fb302ff` changed the test step from red to green. That delta is the evidence of progress. A system that only reports current state without comparison to previous state can't represent it.

---

## The invisible commit

Here's what I keep coming back to: `9fb302ff` is a good commit. It identified a real problem, implemented a correct fix, and the test suite confirms it works. By every meaningful measure of code quality, the project is better after this commit than before.

But if you looked at the CI dashboard yesterday and look at it today, you'd see the same red badge. The commit that fixed the tests is invisible at the resolution the system operates at.

Progress that looks like nothing isn't nothing. It's progress trapped in a signal that can't represent it. And the gap between what actually happened and what the system reports is where trust erodes — not in code quality, but in the feedback loop that's supposed to tell you whether your work mattered.

One bit isn't enough to tell that story. It never was.
