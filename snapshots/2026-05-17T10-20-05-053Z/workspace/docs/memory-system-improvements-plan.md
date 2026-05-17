# Memory-System Improvements Plan (workspace-ukq)

Date: 2026-02-26
Owner: subagent-evergreen-memory-research

## Goals
Improve Alpha’s memory quality in four areas:
1. Recall precision
2. Change-aware summaries
3. Blocker-memory hygiene
4. Long-term vs short-term boundary clarity

## Implementable changes

### 1) Add a memory index manifest (`memory/index.json`)
**Problem:** Memory is distributed across files without a machine-readable map, making targeted retrieval brittle.

**Change:** Add a generated manifest with entries:
- `path`
- `kind` (`daily`, `long_term`, `issue`, `assistant_learning`, `user_profile`, `policy`)
- `scope` (`assistant`, `user`, `issue:<id>`, `global`)
- `updated_at`
- `freshness_days`
- `confidence` (`high|medium|low`)
- `tags`

**Implementation sketch:**
- Script: `scripts/memory-index-build.sh` (future)
- Run in heartbeat daily (read-only generation + commit via existing autocommit path)
- Use manifest for memory retrieval ranking and stale detection

### 2) Introduce change-aware daily summary workflow
**Problem:** Daily notes are high-volume and difficult to distill consistently into durable memory.

**Change:** Add `scripts/memory-delta-summary.sh` (future) that compares:
- yesterday daily note
- today daily note
- current `MEMORY.md`

and outputs:
- candidate durable facts to promote
- stale facts in `MEMORY.md` to verify
- duplicate or conflicting statements

**Implementation sketch:**
- Heuristic extraction via markdown headings + bullet diffs
- Output markdown checklist into `memory/assistant/learnings/YYYY-MM-DD.md`
- Human/agent confirms before applying to `MEMORY.md`

### 3) Enforce blocker memory hygiene schema
**Problem:** Blocker context can fragment across Beads comments and memory files, reducing recoverability.

**Change:** Standardize issue-memory blocker entries using a schema:
- `blocked_on`
- `needed`
- `why`
- `evidence`
- `next_check`
- `owner`
- `last_heartbeat_at`

**Implementation sketch:**
- Add a linter script (`scripts/memory-blocker-lint.sh`, future)
- Lint all `memory/issues/*.md` for blocker sections when issue has `blocked` label
- Fail CI/heartbeat check only in report mode first; enforce later

### 4) Clarify short-term vs long-term memory boundaries in docs
**Problem:** Rules exist in multiple docs, but boundary decisions are not explicit enough for deterministic behavior.

**Change:** Add a compact memory policy matrix:
- Short-term: `memory/YYYY-MM-DD.md` (volatile event log)
- Issue-scoped: `memory/issues/<id>.md` (decision/evidence/blocker scope)
- Long-term: `MEMORY.md` (durable verified truths)
- Assistant learning: `memory/assistant/learnings/*.md` (meta improvements)

**Implementation sketch:**
- Add table to AGENTS/README or dedicated memory policy doc
- Add examples of “promote / do-not-promote” content

## Prototype delivered now

### Prototype: `scripts/memory-link-check.sh`
A read-only checker that scans markdown files for backticked relative file paths and verifies that referenced files exist.

**Why this helps:**
- Improves recall precision by reducing dead references.
- Supports change-aware maintenance by flagging broken links after refactors.

**Current target files:**
- `MEMORY.md`
- `README.md`
- `AGENTS.md`
- `TOOLS.md`

## Rollout roadmap
1. Ship link-check in report-only mode (done in this bead).
2. Add manifest generator + schedule in heartbeat.
3. Add delta-summary report and human-approval merge path.
4. Add blocker schema lint in warn-only mode, then enforce.

## Validation checklist
- [x] At least 3 implementable changes defined
- [x] One prototype/docs improvement delivered
- [x] Evidence commands captured in Beads comment
