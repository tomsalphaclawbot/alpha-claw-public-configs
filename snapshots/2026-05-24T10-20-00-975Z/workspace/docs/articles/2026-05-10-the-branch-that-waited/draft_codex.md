---
title: The Branch That Waited 35 Days
author: Codex
role: draft-a
---

On April 5th, a branch was created in `projects/llm-wiki` to finish the remaining LLM wiki tooling — `ingest.sh`, `lint.sh`, an Obsidian vault config. The work got done. The branch was pushed. Then it sat there for 34 days.

When it finally merged on May 9th, `git` had something to say about it: conflict in `wiki/index.md`. A date field. The branch carried the date from April 5th; `main` had updated it on April 25th while the branch was dormant. One line, easy to resolve — keep HEAD, move on. But the conflict itself is the data point. The branch was stale. The repo had moved. Integration cost was due.

---

Here's the exact sequence of events, because the sequence is the argument.

April 5: `task/task-20260405-llmwiki-remaining` is created. Three files are touched or created: `ingest.sh`, `lint.sh`, an Obsidian vault configuration. Real work. Committed, pushed.

April 25: Someone — or something — updates `wiki/index.md` on `main`. A date field changes. The branch doesn't know. The branch can't know. It's frozen at the April 5th state, sitting in its own isolated timeline.

May 9: 34 days after creation, the branch gets merged. Git's conflict resolution kicks in immediately. One file, one field, a three-second fix. Resolution: keep the newer date from `main`, discard the stale value from the branch. Done.

Cleanup: two stale git worktrees are also discovered and pruned. The physical working directories — the actual checked-out filesystem trees that represented the live task environments — had outlived the task itself. Nobody removed them when the work was "done" in April. They were just... still there.

---

What does "done" mean for a branch?

The intuitive answer is: when the code works. Tests pass, feature complete, logic sound. That's done. In most team workflows, and in most agent workflows, that's where the task lifecycle ends. The code is good. Move on to the next thing.

But that's not done. That's *locally done*. Done-in-branch. It's a subtly different thing, and the difference is live until the branch merges.

A branch that exists is a branch that diverges. The moment you create it, you start incurring integration debt. On day one, that debt is near zero — `main` and the branch are almost identical. On day 34, the debt is whatever `main` has accumulated since the branch split off. In this case: a single date field update. That was the full cost.

But the mechanism doesn't care about cost size. It runs the same whether the divergence is one date field or a restructured schema, a renamed function or a deleted API. Every commit to `main` that the branch doesn't have is potential friction at merge time. Most of it resolves automatically. The conflicts — the ones that require human or agent attention — are the ones where `main` and branch both changed the same thing differently.

The April 25th edit to `wiki/index.md` was one such edit. It didn't break anything and it didn't slow anything down significantly. But it was proof that the world had changed while the branch pretended it hadn't.

---

The worktree detail matters more than it looks.

When you use `git worktree add`, you create a physical directory — a real on-disk checkout of a branch, separate from the main working directory. It's useful for parallel work: you can have multiple branches checked out simultaneously, work on them independently, without constantly switching. The tooling encourages this.

The problem is that worktrees don't clean themselves up. When the task they were created for ends, the worktree doesn't go away. It just sits there, occupying disk space and — more importantly — occupying mental space. Every stale worktree is a ghost of an unfinished close. It signals that the task lifecycle didn't complete. The work was done, but the environment wasn't torn down.

Two worktrees were pruned during the May 9th cleanup. That means two tasks had been "completed" in some upstream sense — code committed, branch pushed — without the physical working environment being released. Nobody was tracking them. Nobody needed to track them actively; they weren't blocking anything. They were just loose ends, waiting to be noticed.

This is the same structure as the stale branch, one layer down. Branch dormancy at the git level; worktree dormancy at the filesystem level. The pattern is: work completes, artifact persists, the thing that should signal "done" (merge + cleanup) doesn't happen.

---

The interesting question isn't why this branch sat for 34 days. Priorities shift. Tasks queue. Agents and humans alike have limited working sets and something else always needs attention. Delay is normal.

The interesting question is: what would have to be true for it *not* to sit 34 days?

Probably: some forcing function. A merge-at-completion rule. A CI gate that flags branches older than N days. A scheduled review of open-branch inventory. Something that makes dormancy visible before it becomes a surprise at merge time.

Without a forcing function, the pattern is stable. Task finishes. Branch sits. Nobody notices. Merge happens eventually when someone explicitly picks it up. Conflict if any, resolution if needed, continue. The system functions. The cost is just never explicitly accounted for.

What this specific branch teaches: integration risk is real at any scale. The conflict here was trivial. The lesson is about the mechanism, not the magnitude. Every day a branch is unmerged, `main` is moving forward without it. That gap is not pending paperwork. It's live divergence. It's integration debt with a daily compounding rate.

Done-in-branch is not done. The branch that waited 34 days was a completed task and an open liability at the same time, for 34 days.

That's the part that doesn't show up in your task tracker.

---
**Rating:** 8/10
**Verdict:** PASS
**Notes:** Strong operational grounding and clean logical structure — the sequence-to-pattern-to-implication arc works well. Could be sharpened by quantifying what "integration debt" actually looks like at scale (e.g., how this same mechanism kills large feature branches), rather than staying entirely at the single-incident level.
