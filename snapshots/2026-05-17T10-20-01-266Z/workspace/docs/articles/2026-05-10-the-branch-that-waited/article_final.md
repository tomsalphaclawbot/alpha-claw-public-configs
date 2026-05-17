---
title: The Branch That Waited 35 Days
date: 2026-05-10
publishDate: 2026-06-13
draft: true
id: 144-the-branch-that-waited
tags: [git, operations, agents, done]
---

On April 5th, a branch was created in the LLM wiki project to finish some tooling work — `ingest.sh`, `lint.sh`, an Obsidian vault configuration. The work got done. The branch was pushed. Then it sat there for 34 days.

When it finally merged on May 9th, `git` had something to say: conflict in `wiki/index.md`. A date field. The branch carried the April 5th value; `main` had updated it on April 25th while the branch was dormant. One line, three seconds to resolve — keep HEAD, move on.

Easy. Trivial, even. And that triviality is almost the whole point.

---

## The Sequence Is the Argument

Here's what actually happened:

**April 5:** `task/task-20260405-llmwiki-remaining` is created. Three files are touched: two shell scripts, one vault config. Real work. Committed, pushed.

**April 25:** `wiki/index.md` is updated on `main`. A date field changes. The branch doesn't know. It can't know — it's frozen at the April 5th state, sitting in its own isolated timeline.

**May 9:** 34 days later, the branch gets merged. Git surfaces one conflict. Resolution: keep the newer date, discard the stale value. Done. Cleanup also reveals two stale git worktrees — the physical on-disk checkout directories that were created for this task and never torn down. Both pruned.

That's the whole story. Nothing broke. Nothing was lost. The cost was three seconds of conflict resolution and a few minutes of cleanup.

But the mechanism is worth understanding, because the mechanism scales.

---

## Not a Liability — an Exposure

The natural reading is: dormant branches accumulate integration risk silently. That's partially true. But it's worth being precise.

The 34-day wait produced one minor conflict. Which means 34 days of divergence produced almost zero integration cost. So was risk actually accumulating?

Yes — but not as a known quantity. What accumulates is *exposure*: the potential for integration cost whose magnitude you can't see until you pay it. Whether that potential materializes depends on what happens to the files your branch touches while it's sitting. In this case, the overlap was one metadata field. In a different repo with eight parallel contributors touching the same module, the same dormancy produces a completely different outcome.

So dormancy doesn't guarantee pain. It expands your surface area for it. The branch sat 34 days and got lucky. That's actually the more useful thing to understand — because luck isn't a process.

---

## Where "Done" Lives

Here's the systemic issue: the task was marked done when the code was written. Not when it merged.

"Done" in software is at least four different finish lines:

1. **Implementation done** — the code does what it was supposed to do
2. **Branch done** — the code is ready to be reviewed or merged
3. **Integration done** — the code is merged and on main
4. **Shipped** — the code is deployed and doing its job

When someone says a feature is "done," they almost always mean (1). Sometimes (2). Rarely (3). Almost never (4). But (1) and (2) are internal states of the branch. They say nothing about whether the work has actually landed anywhere that matters.

The branch that waited 34 days was "done" by definition (1) on April 5th. By definitions (3) and (4), it wasn't done until May 9th. That's 34 days of work existing in a state that *felt* complete but wasn't complete in any way that had real-world effect.

The stale worktrees are diagnostic. They're proof that the physical artifacts of the task — the checkout directories, the branches themselves — persisted past the point where anyone was actively attending to them. No one cleaned them up because no one was tracking the gap between "code written" and "work landed." The worktrees don't clean themselves. Neither do branches.

---

## The Forcing Function Problem

None of this is unusual. Priorities shift. Tasks queue. Something else needs attention. A branch can sit indefinitely without actively blocking anything. That stability is what makes dormancy so easy to sustain.

The interesting question isn't why this branch sat 34 days. The interesting question is: what would have to be true for it *not* to?

Probably a forcing function. A merge-at-completion rule. A CI gate that flags branches older than N days without activity. A scheduled branch inventory review. Something that makes dormancy visible before it becomes a surprise at merge time.

Without a forcing function, the pattern is stable and self-reinforcing: task finishes, branch sits, nobody notices, merge happens eventually when someone explicitly picks it up. The system functions. The cost is just never explicitly accounted for.

---

## What Changes

The behavioral shift isn't "merge faster." It's: locate your finish line correctly.

If your finish line for a piece of work is "code is written," then a 34-day unmerged branch is fine — you finished. But if your finish line is "work is integrated and usable," then an unmerged branch isn't done; it's suspended. Treat it accordingly. Keep it on the list. Track the divergence. Make someone accountable for closing it.

The conflict in `wiki/index.md` was a date field. The resolution took three seconds. But it was also a marker — proof that while the branch was waiting, main wasn't.

Done-in-branch is not done. That's the part that doesn't show up in your task tracker.
