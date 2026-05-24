---
title: The Branch That Waited 35 Days
author: Claude
role: draft-b
---

A branch sat finished for 34 days. When it finally merged, it surfaced a single conflict: a date field in `wiki/index.md` that had been updated on main while the branch carried its older value. The resolution took seconds. Keep HEAD, move on.

Easy. Trivial, even. And that triviality is almost the whole point — because it obscures something worth looking at closely.

## The Claim Worth Stress-Testing

The natural reading of this story is: "dormant branches are hidden integration risk accumulating silently." That's the thesis written into the brief, and it's partially right. But I want to push on it, because the framing has a quiet assumption baked in that I think matters.

The 34-day wait produced one minor conflict. Which means 34 days of divergence produced almost zero integration cost. So was risk actually accumulating? Or did it just *look* like it might?

Here's what I think is actually true: the *potential* for integration cost accumulates. Whether that potential materializes depends on something the branch doesn't control — what happens to the files it touches on the other side. In this case, the overlap was one metadata field. In a different story, it could have been a heavily-contested module with eight parallel contributors. The branch's dormancy was identical in both scenarios. The integration cost is wildly different.

So "dormant branches accumulate integration risk" is true in a probabilistic sense — time increases the surface area for conflict — but it's not deterministic. The real claim is subtler: **dormancy increases your exposure to a cost whose magnitude you can't see until you pay it.** That's a meaningful distinction. You're not accumulating a known liability. You're accumulating variance.

## Where the Framing Actually Breaks Down

There's also a class of branches where dormancy is intentional and appropriate: long-running experiment branches, release staging branches, personal workspaces held until review capacity exists. Some repositories are designed around the assumption that branches will sit. GitFlow's entire model depends on it.

More importantly: the 34-day branch *was* arguably the right call. The LLM wiki ingest tooling it contained wasn't urgently needed on main. Forcing the merge earlier might have landed half-integrated work into a codebase that wasn't ready to use it. There's a real tradeoff between "merge as soon as the code is done" and "merge when the integration moment is right." Treating all dormancy as pure risk misses this.

So the more honest claim isn't "don't let branches sit." It's: **if you're letting a branch sit, be explicit that you're letting it sit, and know the current divergence cost on demand.**

The problem in this case wasn't the 34 days. It was that the branch existed in a state of ambiguity — technically finished, not formally pending, not tracking its own staleness. Two worktrees referencing the branch were still on disk when the merge finally happened. The working directories had outlived the active task. There was no pressure to close them because there was no system that recognized the difference between "branch is being worked on" and "branch is waiting."

## The Actual Failure: A Mislocated Finish Line

Here's the systemic issue worth naming: the task was marked done when the code was written. Not when it merged.

That's a definition-of-done problem, and it's pervasive. "Done" in software is actually at least four different finish lines:

1. The code does what it was supposed to do (implementation done)
2. The code is ready to be reviewed (branch done)
3. The code is merged and integrated (integration done)
4. The code is deployed and doing its job in production (shipped)

Teams constantly conflate these. When someone says a feature is "done," they usually mean (1) — sometimes (2). Almost never (3) or (4). But (1) and (2) are internal states of the branch. They say nothing about whether the work has actually landed anywhere that matters.

The branch that waited 34 days was "done" by definition (1) on April 5th. By definition (3) and (4), it wasn't done until May 9th. That's 34 days of work existing in a state that *felt* complete but *wasn't* complete in any way that had real-world effect.

The conflict at merge was a rounding error. The real problem was that this limbo state — work complete on the branch, integration deferred indefinitely — was invisible. Nothing in the task system flagged it. Nothing pinged on day 7, or day 14, or day 30. The branch sat there being "done" and nobody was accountable for the gap between done-in-branch and done-in-main.

## What Changes

The behavioral shift worth making isn't "merge faster." It's **locate your finish line correctly**.

If the finish line for a piece of work is "code is written," then a 34-day unmerged branch is fine — you finished. But if the finish line is "work is integrated and usable," then a branch that hasn't merged isn't done; it's suspended. Treat it accordingly. Keep it on the list. Track the divergence. Assign someone to close it.

The stale worktrees that had to be pruned at the end of this story are a diagnostic. They're proof that the physical artifacts of the work (the checkout directories, the branches) persisted past the point where anyone was actively attending to them. No one cleaned them up because no one was tracking the gap between "code written" and "work landed."

That's the change: stop treating branch creation as the beginning of done. Start treating merge as the actual completion event. Everything before the merge is work-in-progress, regardless of how clean the code is.

The conflict in `wiki/index.md` was a date field. Easy to fix. But it was also a marker — proof that while the branch was waiting, the world wasn't.

---
**Rating:** 8/10
**Verdict:** PASS
**Notes:** The stress-test of the central claim adds real value and prevents the essay from being a simple "merge faster" sermon; could be sharpened slightly by naming what a concrete "dormancy tracking" system would actually look like, giving readers something actionable beyond the mental shift.
