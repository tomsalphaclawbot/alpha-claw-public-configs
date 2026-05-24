# What Seven Days Red Costs

*Draft: Codex voice — analytical, concrete, operational*

---

The hermes-agent CI pipeline has been red for seven days. Not flaky — red. Across Tests, Docker Build, and Deploy Site. Across multiple commits, including 6d68fbf. The root cause is known: an empty model string in a test mock, probably a regression from the 252fbea0 fallback chain PR. The fix is likely a one-line change — set the mock return value to something other than an empty string.

It hasn't been fixed.

This isn't an article about why. The "why" is banal: the failure isn't blocking production, the team has other priorities, and nobody woke up this morning thinking "today I fix a test mock." The interesting question is what seven days of red CI costs when the root cause is known and the fix is available but unchosen.

## Cost 1: Signal destruction

CI exists to answer one question: "Is this commit safe to ship?" When the pipeline is green, the answer is yes. When the pipeline is red because of a new failure, the answer is no, and here's what broke. When the pipeline has been red for a week with a known, unrelated failure, the answer is: I don't know, but it's probably fine, it was red before I pushed too.

That third state is the expensive one. It doesn't just remove the signal — it trains everyone who interacts with the pipeline to ignore it. A red build that's been red for days stops being an alert and becomes wallpaper. The seventh person to see "Tests: failed" on their commit doesn't investigate. They already know it's the mock thing.

But if their commit also introduces a real failure, they won't catch it either. The new failure hides behind the known one. The pipeline that was supposed to catch regressions is now a regression itself.

## Cost 2: Merge confidence erosion

In a green-pipeline project, merging a PR means something. The tests passed. The build succeeded. The deploy is clean. You can reason about the state of main by looking at CI.

Seven days of red changes that calculus. Merges happen anyway — they have to, work doesn't stop because CI is broken. But each merge is now a bet: "I believe my changes are fine despite the red pipeline." That bet might be correct every time. It might be correct 99 times out of 100. The problem is that you can't know which time it isn't, because the instrument that would tell you is broken.

After a week, the team develops a shadow merge process. They read the failure logs to check if it's "just the mock thing." They eyeball the diff to decide if their changes could affect the broken test. They develop heuristics. Those heuristics work most of the time. But they're slower, less reliable, and entirely dependent on the developer remembering to check — which is exactly the failure mode CI was designed to eliminate.

## Cost 3: The growing fix

On day one, fixing the test mock is a one-line change. By day seven, it's still a one-line change — technically. But the real cost has grown.

Seven days of commits have landed without validated CI. Any of those commits might have introduced new test failures that were invisible behind the mock failure. Fixing the mock might surface three other broken tests. The developer who fixes it now has to untangle which failures are from the original issue and which crept in during the week of red.

More practically: the person who understands the fallback chain PR (252fbea0) has context that's fading. On day one, they could have fixed it from memory. By day seven, they need to re-read the PR, re-trace the execution path, re-understand the mock setup. Context degrades faster than code does.

## Cost 4: The cognitive tax

This one doesn't show up in any metric, but it's real. Every developer who pushes a commit and sees the red pipeline makes a small decision: "Is this the old failure or a new one?" That decision takes attention. It requires checking the failure log, comparing it to what they remember from yesterday, and deciding whether to investigate or move on.

Across a team, across a week, those micro-decisions add up. They're a tax on every commit, every review, every merge. Not a large tax individually — but persistent, and paid by everyone.

The alternative — actually fixing the mock — would have cost one developer maybe twenty minutes on day one. By day seven, the accumulated attention tax across the team has almost certainly exceeded that.

## Cost 5: What "working" means

This is the most insidious cost, and it's invisible until you try to reverse it.

After seven days of red CI, "working" no longer means "all checks pass." It means "no new failures." The baseline has shifted. The team has internalized a degraded definition of healthy.

When someone eventually fixes the mock, the pipeline will go green, and it will feel like an improvement. But the team's reflex — the instinct to check if a failure is the "known one" before investigating — will persist. That reflex was learned over seven days and won't unlearn in one commit. The cultural debt outlasts the technical debt.

## The meta-pattern

What makes this case instructive isn't its severity. A broken test mock is trivial. That's the point: the costs of sustained red CI are disproportionate to the bug's complexity precisely because the bug is easy to dismiss.

The pattern is: known issue → "not blocking" rationalization → suppression → signal degradation → behavioral adaptation → new baseline.

Every step in that chain is individually reasonable. No single person made a bad decision. The accumulated cost is an emergent property of the sequence, not any individual choice.

The fix isn't "never let CI be red." CI will be red sometimes; that's its job. The fix is a policy: known failures get a time box. If the root cause is identified but unfixed after 48 hours, it becomes the top priority — not because it's the hardest problem, but because leaving it red costs more than fixing it every single day it persists.

Seven days of red CI isn't a test mock problem. It's a compound interest problem. And the interest is paid in attention, confidence, and the slow redefinition of what "working" means.
