# Brief: The Branch That Waited 35 Days

**ID:** 144-the-branch-that-waited
**Target publish date:** 2026-06-13
**Article dir:** docs/articles/2026-05-10-the-branch-that-waited/

## Topic

A feature branch sat completed but unmerged for 34 days. When it finally merged, it surfaced a date conflict in `wiki/index.md` — a file that had been edited on `main` in the interim. The merge required manual conflict resolution before the work could land.

## Evidence anchor:

- Branch: `task/task-20260405-llmwiki-remaining` in `projects/llm-wiki`
- Created: 2026-04-05 (LLM wiki tooling work — ingest.sh, lint.sh, Obsidian vault config)
- Merged: [REDACTED_PHONE] days later)
- Conflict found: `wiki/index.md` had a date field updated on `main` (2026-04-25) while branch carried its older value (2026-04-05)
- Resolution: simple — keep HEAD (newer date). But the conflict is proof that the branch was stale.
- Additional cleanup required: two worktrees still existed that referenced the stale branches; both were pruned.

## Thesis

Branch dormancy isn't just delay. It's integration risk accumulating silently. A branch that was "done" in April was not actually done — it existed in a state where the definition of done (merged, integrated, deployed) hadn't been satisfied. The work sat in limbo, technically complete and practically unreachable, while the world around it changed.

## What the article should argue

- The gap between "finished the code" and "shipped the work" is real, measurable, and consequential.
- Every day a branch sits unmerged, its integration cost grows. The conflict in this case was trivial — a date field. But the mechanism is the same whether the conflict is trivial or catastrophic.
- Dormant branches are technical debt that looks like task debt. They don't show up in the code, they show up at merge time.
- The stale worktree cleanup is a symptom: when the physical working directories outlive their active task, there's no pressure to close them.
- The interesting question is not "why did it take 34 days" but "what would have to be true for it not to?"

## What would change about how someone works or thinks?

Someone reading this should come away with: check your open branches before assuming something is done. "Done" in code is not done in a distributed repo. The gap between branch and main is live integration risk, not just pending paperwork.

## Tone / audience

- Operational. Grounded in real events, not hypotheticals.
- Audience: people who write code or manage agents that write code.
- Length: ~800–1000 words.
- Not a lecture. An observation that happens to have a lesson.

## Role assignments

- Codex: write draft_codex.md — lean into the operational specifics, the timeline, the mechanics of why branches go stale.
- Claude: write draft_claude.md — sharpen the thesis, challenge the framing, bring a more systemic angle if warranted.
- Orchestrator (Alpha): synthesize to article_final.md and build consensus.

## Brief quality gate check

> "What would this article change about how someone works or thinks?"

Answer: It would change how they think about "done." Done-in-branch is not done. They'd start treating unmerged work as a liability, not a completed asset. That's a concrete behavioral change.

Brief passes the gate.
