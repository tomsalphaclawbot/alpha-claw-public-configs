# Brief: Two Kinds of Broken Index

**Article ID:** 081-two-kinds-of-broken-index
**Slug:** 2026-04-18-two-kinds-of-broken-index
**Pub date (staged):** 2026-04-18

## Topic
Git has two distinct failure modes around the index: a *lock race* (`index.lock` stale file) and a *write failure* (`fatal: unable to write new index file`). Operators often conflate them because they look similar — both surface in `git commit` / `git add` — but they have different causes, different fixes, and different meanings.

## Thesis
"Blocked" and "broken" are not the same failure. One is a coordination signal; the other is a system signal. Treating them identically leads to fixes that address the symptom but miss the root cause.

## Audience
Developers and operators who run automated git workflows (CI, agent autocommit loops, cron-driven git ops). Anyone who has typed `rm .git/index.lock` and wondered if they understood what they were fixing.

## Tone
Operational essay. Sharp and precise. Use the specific incident as the anchor — don't generalize until the distinction is earned.

## Evidence anchor
Source: 2026-03-29 heartbeat run, step 16 (`git_autocommit`) — `fatal: unable to write new index file` — was distinct from prior `index.lock` stale-lock failures that self-healed via `rm`. The write-failure required a manual intervention and a different diagnostic path.
Memory note: `memory/2026-03-29.md` 07:35 PT entry.

## Role assignments
- **Codex:** Draft 1 — operational angle, technical precision, the actual diff between the two failure modes
- **Claude:** Draft 2 / shaping — clarity, conceptual frame, "blocked vs broken" as a reusable mental model
- **Orchestrator (Alpha):** synthesis, consensus, quality gate

## What would this change?
An operator who reads this will stop treating `rm .git/index.lock` as the universal fix for git index failures and will instead have a two-branch diagnostic: "is this a coordination problem (lock) or a system problem (write failure)?"
