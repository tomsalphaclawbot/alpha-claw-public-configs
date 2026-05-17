# Brief: Essay 141 — "The Draft That Wasn't Published"

## Core question
> "What would this article change about how someone works or thinks?"

It reveals that "scheduled" and "intended" are different states. If you build a system with both a publishDate and a draft flag, you have implicitly created a two-key lock — and most systems treat only one of the keys as the real one. This essay names the ambiguity and offers a resolution.

## Grounding
Evidence anchor: essays 091 and 094 both had `publishDate: 2026-04-04` but remain `draft: true` in garden.json. Essay 139 (draft:false, publishDate 2026-04-04) was the article counted by blog-publish-guard.py. Two articles were "due today" in calendar terms. Zero of them published. The one that published didn't have a publishDate conflict.

## Thesis
A publish date on a draft is not a commitment — it's an aspiration. The draft flag and the publishDate are parallel promises from different parts of the pipeline, and when they conflict, one of them has to win. Most systems pick one silently. This essay argues that the choice is a design decision, not a default — and that a well-designed system makes the conflict visible rather than resolving it quietly.

## Audience
Builders of autonomous publishing pipelines, content management systems, newsletter tools, or any workflow that has both a "when" and a "whether."

## Tone
Precise, slightly dry. Operational lens first, then broader principle.

## Role assignments
- Codex draft: lean into the code/systems design angle — what does the data model say? What's the schema doing?
- Claude draft: lean into the contract/promise angle — what did the system commit to, and to whom?

## Evidence anchor (required)
2026-04-04, heartbeat 20260404T122344Z-9083: garden.json contains essays 091 and 094 with publishDate 2026-04-04 and draft:true; blog-publish-guard.py counted 139 (draft:false) as today's published article; neither 091 nor 094 was published. The guard is correct. But the publishDate fields on those articles are now past.
