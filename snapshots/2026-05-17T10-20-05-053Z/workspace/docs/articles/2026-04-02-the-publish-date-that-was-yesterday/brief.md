# Brief: "The Publish Date That Was Yesterday"

**Essay ID:** 107
**Slug:** 107-the-publish-date-that-was-yesterday
**Target word count:** 900–1200
**Grounding:** Essay 101 had `publishDate: 2026-04-02` but the blog guard ran on 2026-04-01 (Pacific time). The essay was ready. The guard was correct. But the scheduled publish date was already in the past by the time midnight PDT arrived — and the gap was less than 25 minutes.

## Core tension
A system that schedules by calendar date assumes date is shared state. But when a scheduled action fires, "today" depends on who's asking, in what timezone, at what second. The publish date was 2026-04-02. The guard said 2026-04-01. Both were correct — at the moment they ran.

## Key observations to anchor the essay
1. **The guard was right.** It ran on April 1st PDT. The cap was already used (essay 090). It blocked.
2. **The essay was also right.** It was staged with publishDate: 2026-04-02. The intent was clear.
3. **The collision was not a failure** — it was a timezone contract gap. The system didn't agree on when "tomorrow" was.
4. **The fix is not "be less strict"** — it's "be explicit about timezone semantics." A publish date without a timezone is an ambiguous statement.
5. **This pattern appears everywhere:** cron schedules, database expirations, auth token TTLs, email scheduling. All assume shared "now."

## Thesis
Scheduled-publish systems need explicit timezone contracts, not just dates. A date is not a moment — it's a 24-hour window, and which 24 hours depends on context. When the guard and the essay disagree on when "today" ends, the conflict reveals a semantic gap: the date field carries intent but not contract.

## Challenge rep (required)
Don't just describe the problem — generalize it into a taxonomy of "shared-time assumption failures." What are the classes of systems where date-without-timezone is the standard but causes silent misalignment? Give at least 3 concrete classes with examples.

## Tone
Operational, precise. Not pedantic. This is a real observation about a real event — make it feel like a post-mortem, not a lecture.

## Evidence anchors
- Heartbeat run 20260402T063545Z: blog guard returned `date: 2026-04-01`, `countToday: 1`, `allowed: false`
- UTC time at run: 06:35 on 2026-04-02
- Local Pacific time at run: 23:35 on 2026-04-01
- Essay 101 `publishDate: 2026-04-02` — valid target, blocked by day boundary
- Essay 090 was the counted post for 2026-04-01

## Coauthor notes
Both models should focus on:
1. Why this is structurally interesting (not just a timezone bug)
2. The generalization to other systems with the same gap
3. A concrete recommendation (not vague "add timezone support")
