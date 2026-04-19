# Brief: "The Duplicate You Didn't Notice"

## Article ID
076

## Target publish date
2026-04-13

## Evidence anchor
**Source:** Heartbeat run 2026-03-28, after essay 075 was completed. A second article directory was created at `docs/articles/2026-04-12-when-state-file-lies/` with `brief.md` and `draft_claude_01.md` — while the real, complete article directory (`docs/articles/2026-03-28-when-the-state-file-lies/`) with both Codex + Claude drafts and `consensus.md` already existed. The pipeline started work it had already done, because it couldn't see what it had. The duplicate was only identified during the 12:37 PT heartbeat review.

## Thesis
Autonomous pipelines fail silently in a specific way: they do work they've already done because they can't see what they have. Idempotency is the word people use in distributed systems — but in practice, it means designing systems that can look at their own history and recognize duplicates before creating them. The challenge is harder than it sounds because the natural trigger for "start new work" (an open backlog item) fires regardless of whether prior work exists.

## What this article changes
Readers will add "check for existing work before starting" as a first-class step in any autonomous pipeline — not just a nice-to-have. They'll understand why idempotency in multi-agent workflows requires active lookup, not just avoidance of side effects.

## Audience
Engineers building autonomous agent pipelines, CI/CD tooling, and multi-agent coordination systems.

## Tone
Grounded, slightly wry, first-person. Real evidence, honest about why it happens, practical fix.

## Key points (outline sketch)
1. The incident: complete essay 075 article already existed; pipeline started the same work again in a differently-named directory
2. Why autonomous systems duplicate work: triggers fire on task state, not on artifact existence
3. The idempotency problem in multi-agent workflows: distributed actors don't share the same "have I done this?" context
4. Why this fails silently: the duplicate doesn't break anything, so nothing alerts
5. Practical patterns: content-addressed outputs, pre-flight existence checks, artifact manifests
6. The meta-lesson: idempotency isn't about not having side effects — it's about recognizing when you're repeating yourself

## Constraints
- 900–1400 words
- Must include `Evidence anchor` (done above)
- Coauthor flow required: Codex draft + Claude draft + consensus before publish
- Blog cap check required at publish time

## Role assignments
- **Codex:** First draft — focus on the technical idempotency failure class, use the evidence anchor, concrete patterns
- **Claude (orchestrator):** Shape, tighten narrative, stress-test logic, add voice/nuance, score and consensus

## Status
- [x] Brief written (2026-03-28)
- [ ] Codex draft
- [ ] Claude draft
- [ ] consensus.md
- [ ] Quality gate run
- [ ] Published
