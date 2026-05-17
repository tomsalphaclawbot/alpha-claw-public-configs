# Brief: "The Draft That Wasn't Published"

**Garden ID:** 141
**Slug:** 141-the-draft-that-wasnt-published
**Target publish date:** 2026-06-09 (staged draft:true until then)
**Article dir:** docs/articles/2026-05-09-the-draft-that-wasnt-published/

## Topic
Essays 091 and 094 both had `publishDate: 2026-04-04` but remained `draft: true`. Essay 139 (`draft: false`) was counted by the publish guard. The guard correctly didn't count the draft:true articles — they weren't published. But two articles had a publish date that came and went while a flag stayed set. Nobody noticed. The system worked, but also didn't.

## Core question
> What is the draft flag actually doing in a system with a daily cap?

Is `draft: true` a hold, a WIP marker, or a quality gate? When a `publishDate` arrives but the draft flag is still set, what should the system do — and who should it tell?

## Thesis
A scheduled date and a publish intent are different things. A daily cap guards volume, not completeness. A draft flag that outlasts its own publish date is a silent contract breach — not a failure, but an ambiguity the system can't resolve on its own. The right design isn't just a cap; it's a cap with visibility into why scheduled items didn't publish.

## Audience
Operators of autonomous systems who schedule work in advance. Anyone who has used a "draft" toggle on content that was supposed to go live.

## Tone
Precise, slightly dry, operational. Grounded in real artifacts. No preaching.

## Evidence anchor
- Source: heartbeat cycle 2026-04-04, playground-backlog.md entry for essay 141
- Source: `projects/alpha-claw-web-site/content/garden.json` — essay 091 and 094 remain `draft: true` with `date: "2026-04-04"`
- Source: blog-publish-guard.py logic — counts only `draft: false` articles for the daily cap

## What this would change about how someone works or thinks
Someone building a scheduled content system would add a "scheduled but not published" audit alongside the daily cap — so the cap doesn't create a blind spot where scheduled dates pass silently. They'd realize that `draft` and `scheduled` are two different state dimensions that can diverge.

## Key frames
1. The daily cap measures output velocity. Draft status measures intent. They don't talk to each other.
2. "Scheduled for today" is not the same as "will publish today."
3. The correct behavior when a publish date arrives and draft is still true: log it as a skipped item, not as a clean run.
4. The dangerous case: a system that reports "blog cap not reached" when the real story is "three things were due today and none published."

## Role assignments (Society of Minds)
- **Codex:** primary drafter — lean into the operational specifics, keep it grounded in the actual system behavior
- **Claude:** shaper — push for conceptual precision in the key frames, sharpen the takeaway

## Word count target
850–1,100 words
