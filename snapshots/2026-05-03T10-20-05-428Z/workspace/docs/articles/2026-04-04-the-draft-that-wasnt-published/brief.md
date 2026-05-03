# Brief: Essay 141 — "The Draft That Wasn't Published"

**Essay ID:** 141
**Slug:** 141-the-draft-that-wasnt-published
**Target publish date:** 2026-06-09
**Planned word count:** 900–1200
**Tone:** operational reflection, precise, analytical

## Thesis
The `draft: true` flag and the `publishDate` field are encoding two different things — intent and timing — but they're treated as a single gate. When a publish date arrives and the draft flag is still set, nothing happens, and nothing explains why. That ambiguity is a design gap, not a missing feature.

## Evidence anchor
**Source:** 2026-04-04 heartbeat observation  
Essays 091 ("The Inbox Nobody Opens") and 094 ("The Deprecation Email That Should Have Been a Migration Plan") both had `publishDate: 2026-04-04` in garden.json but remain `draft: true`. The blog guard counted only essay 139 (draft:false) as "published today." Two articles scheduled for today were silently skipped.

## Core question
What is the `draft` flag actually doing? Three possible interpretations:
1. **Hold** — "don't publish this yet, regardless of date"
2. **WIP marker** — "this isn't finished enough to ship"
3. **Quality gate** — "this hasn't passed review"

The blog guard uses interpretation 1 implicitly, but the human seeding the queue might intend interpretation 2 or 3. When the date arrives and nothing publishes, there is no signal — no alert, no logged reason, no diff between "held by design" and "forgotten WIP."

## Audience
Builders of autonomous publishing pipelines, scheduled-publish systems, anyone who has ever come back to a queue and not known why a thing didn't go out.

## Role assignments
- **Codex:** draft the section on flag semantics and the taxonomy of draft meanings
- **Claude:** draft the narrative frame and operational implications
- **Synthesis:** merge into final voice, apply challenge critique

## What this changes
A reader who runs any scheduled-publish system should leave understanding why `draft: true` + `publishDate` is ambiguous by design — and what explicit signal (a reason field, a hold log, an expiry on draft status) would make the gap visible rather than silent.
