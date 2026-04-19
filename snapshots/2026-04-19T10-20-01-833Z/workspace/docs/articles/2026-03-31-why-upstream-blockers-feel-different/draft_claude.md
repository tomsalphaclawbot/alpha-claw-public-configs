# Why Upstream Blockers Feel Different From Ours

*Draft: Claude (challenge rep / steel-man)*

---

Four days of red CI. The root cause is known. The fix exists as a PR in someone else's repository. And the only verb left is *wait*.

That waiting is what makes upstream blockers psychologically distinct. But before we build a taxonomy of how to manage them, we need to be honest about something: the discomfort of waiting is not always a problem to be solved. Sometimes it's the correct operational state, and the instinct to route around it is the actual mistake.

## The Three Axes (and Their Complications)

### Accountability Is Shared, Not Absent

When your CI fails because of an upstream dependency, it's tempting to frame the accountability as severed — "we can't do anything, it's their repo." But accountability isn't binary. You chose the dependency. You chose the integration depth. You chose to run their tests in your pipeline rather than mocking at the boundary.

The upstream maintainer didn't break your CI. Your coupling to their code broke your CI. That's not blame — it's architecture. The accountability for the *breakage* is shared: they introduced a flaky test, and you wired your pipeline to treat their test suite as a first-class signal.

This reframing matters because it changes the action space. If the problem is "upstream is slow," your only move is to wait or pressure. If the problem is "our integration is too tightly coupled to a component we don't control," the action space expands: you can change the coupling. The upstream blocker becomes an architecture question, not a people question.

### Timeline Uncertainty Is Real — But Often Overestimated

The psychological weight of upstream blockers comes from open-ended timelines. You don't know if it'll be merged tomorrow or next quarter. But consider: how often do you *actually* know the timeline for internal blockers?

Most engineers carry an optimism bias about internal work. "I'll fix this today" becomes three days. "This is a one-line change" turns into a refactor. Internal timelines are more *legible* — you can see the sprint board, read the PR comments — but legibility isn't the same as predictability.

Upstream timelines are often more predictable than they feel. Most active open-source projects have observable patterns: average PR review time, maintainer response cadence, release schedules. You can usually estimate within a factor of two by checking the last ten merged PRs. The information is available; the anxiety comes from not looking.

The deeper issue: engineers treat timeline uncertainty as a unique property of upstream blockers. It's not. It's a universal property of all dependency chains. Upstream just makes it visible because you can't self-delude about your own velocity.

### Escape Hatches Carry Hidden Costs

Fork and patch. Mock the test. Vendor and pin. These are real options, and enumerating them early is good practice. But the challenge-rep question is: *should you exercise them?*

Every escape hatch incurs debt:

- **Forking** means you're now maintaining a parallel branch. If the upstream project is active, you're signing up for perpetual merge conflict risk. If your patch is small and the upstream project moves fast, you can easily spend more time maintaining the fork than you would have spent waiting.

- **Mocking at the boundary** is cleaner architecturally, but it means you've silently stopped testing the integration. If the upstream project introduces a real breaking change while you're mocked, you won't see it. You've traded a false negative (red CI from flake) for a potential false positive (green CI hiding a real break).

- **Vendoring and pinning** freezes your dependency. This is sometimes correct — but it turns an active relationship with a living project into a snapshot. You stop receiving security patches, performance improvements, and compatibility updates. The longer you stay pinned, the harder the eventual unpin.

The escape hatch question isn't "what can I do instead of waiting?" It's "is the cost of waiting actually higher than the cost of any available alternative?"

## When Waiting Is the Right Call

There's a case that rarely gets made in engineering blog posts because it's unsatisfying: **sometimes the correct operational decision is to wait and accept temporary degradation.**

Here's when:

**When the fix is already in flight.** If the upstream PR is filed, the maintainer has responded, and the review is progressing — your best move might genuinely be to wait. The cost is a red badge for a few days. The cost of forking is ongoing maintenance. The cost of mocking is reduced integration coverage. "Wait three more days" beats "create a maintenance burden that outlasts the wait" almost every time.

**When the blocker doesn't block your actual work.** A red CI badge is a signal, not a stop sign. If the failure is in a test you understand, the root cause is identified, and the failure doesn't affect any code path you're actively shipping — the blocker is aesthetic, not operational. You can work around it with a mental footnote rather than an architectural change.

**When the upstream project is better positioned to fix it correctly.** Your fork-and-patch might fix the symptom. The upstream maintainer might fix the underlying cause. If you ship a patch that papers over a flaky test, and the upstream team redesigns the test to be deterministic, you've done unnecessary work. Worse, your patch might conflict with their proper fix.

## Steel-Manning the Upstream Maintainer

From the upstream maintainer's perspective, your PR is one of twenty. Your flaky test is a minor annoyance in their codebase. Their roadmap includes a major refactor next month that might rewrite the entire test file. Merging a surgical fix to a test they're about to rewrite is, from their cost-benefit analysis, a waste of review bandwidth.

This isn't negligence. It's rational prioritization. They're not slow — they're operating on a different timescale with different priorities, and they have more context about their own codebase than you do.

The mistake most downstream consumers make is projecting their urgency onto the upstream project. Your four-day red badge is a crisis for you and a footnote for them. Recognizing this asymmetry isn't defeatism — it's realism, and realism produces better strategy than frustration.

## A More Honest Decision Framework

The three-axis taxonomy (accountability, timeline, escape hatch) is useful, but it needs a fourth dimension: **proportionality**.

Before you enumerate escape hatches and set switch-point deadlines, ask: *how much does this blocker actually cost per day of waiting?*

If the answer is "a red badge and some cognitive irritation" — the appropriate response is to note it, set a loose check-in date, and move on. If the answer is "we can't ship a critical feature" — the appropriate response is immediate mitigation.

Most upstream blockers fall into the first category. The instinct to act is driven by discomfort with the lack of control, not by actual cost. And discomfort-driven action is how you end up maintaining forks of dependencies that would have been fixed upstream in a week.

The right framework isn't just "classify and act." It's "classify, measure the actual cost, and then decide whether action or patience is the cheaper option." Sometimes the bravest operational decision is to let the badge stay red.

---

*The CI is still red. The upstream PR is open. And for now, that's fine.*
