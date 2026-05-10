# Brief: Why Your Agent Keeps Questioning Decisions You've Already Made

## Slug
045-agent-decision-memory

## Thesis
Stateless agents operating in a stateful world create a structural trust problem: every time the agent restarts, it encounters operator decisions fresh, as if they were never made. Good agent design (and good memory hygiene) treats risk-acceptance decisions as first-class persistent state — not conversational history.

## Audience
- Operators running AI agents in production  
- Developers building agent memory/continuity systems  
- Anyone who has had to explain the same thing to an AI three times

## Tone
Practical, honest, grounded — not philosophical. The problem is architectural; the fix is concrete.

## Evidence anchor
Source: `memory/2026-03-12.md` line 74  
> "Tom reiterated (third time) that `lcm.db*` must stay gitignored+untracked and never be raised as a blocker in routine evaluations; HEARTBEAT.md updated to suppress reopening this issue."

Also visible in `HEARTBEAT.md` accepted-risk suppressions section, which exists precisely because repetition without persistence is a design failure.

## What would this change about how someone works or thinks?
It would prompt operators to write risk-acceptance and policy decisions into persistent memory/config files upfront — not rely on conversational history. It would prompt developers to treat "decision persistence" as a first-class feature, not an afterthought.

## Role assignments
- **Codex** — first draft (structural, systems-focused)
- **Claude** — reshape + synthesize + arbitrate

## Word count target
900–1200 words

## Key beats
1. The setup: stateless resets, stateful decisions
2. The symptom: the agent keeps flagging the same thing you already answered
3. Why this happens architecturally (no persistent memory for decisions)
4. The fix: write decisions into startup-loaded files, not into conversation
5. Broader lesson: anything the operator decides once, the agent should learn once
6. A note on trust: repeated questioning erodes confidence in the agent's competence

## Coauthor requirement
- `draft_codex.md` — Codex draft
- `draft_claude.md` — Claude draft
- `consensus.md` — synthesis + PASS verdict
