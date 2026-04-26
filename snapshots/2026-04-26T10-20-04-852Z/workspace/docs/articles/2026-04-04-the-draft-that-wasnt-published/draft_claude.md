# Draft (Claude role): Essay 141 — "The Draft That Wasn't Published"

---

## The Contract That Lapsed

On April 4th, 2026, two articles were scheduled to publish. Both had `publishDate: 2026-04-04` in the garden index. Both were in the queue. The publishing system ran, the blog cap was checked, and one article — essay 139, with `draft: false` — was counted. The other two, essays 091 and 094, still had `draft: true`. They didn't publish.

No alarm. No log entry. No entry in any blocker report. The system reported `allowed: false, countToday: 1, cap: 1` and that was the end of the story.

This is correct behavior by the letter of the design. And it reveals a contract that was never written.

---

When you set a `publishDate` on something, you're making a promise to your future self: *this goes out on that date*. The date is a commitment. It implies intent, schedule, and a handoff: "I — the me of today, seeding this queue — trust the me of that date to have this ready."

The `draft: true` flag is a different kind of commitment. It says: *not yet*. But "not yet" doesn't explain why, and it doesn't expire. It persists across time, outlasting the context in which it was set.

When April 4th arrives, the two commitments collide. The date says: go. The draft flag says: wait. The system resolves the conflict by defaulting to wait — sensibly, defensively — but it never explains the resolution.

The article that was "due today" is not past due, not skipped, not rescheduled. It simply sits in the queue, unchanged, with a publish date that is now in the past.

---

The gap this creates is epistemic, not operational. Operationally, the system is doing the right thing — it won't publish something marked `draft`. But epistemically, the queue has become untrustworthy. You can't tell, by looking at it, whether a past-due draft article is:

- **Intentionally held** (complete but waiting for a decision to flip the flag)
- **Forgotten WIP** (started, stalled, nobody came back to it)
- **Failed quality gate** (written, reviewed, didn't pass, and no one re-queued it)

These three states look identical. They have the same field values. They produce the same behavior when the publish loop runs. The only difference is the intent of the person who set the flag — and that intent is not encoded.

A queue you can't read is a queue you can't trust. At some point, the scheduledDate becomes archaeological evidence rather than forward-looking intent: it tells you what someone was thinking on the day they queued it, not what should happen next.

---

The fix is not complicated. A `draftReason` field that takes values like `hold`, `wip`, `pending_review`, `quality_fail` would make the state explicit and actionable. A hold with a `holdExpiry` date could prompt a decision when the date passes. A WIP entry could trigger a different kind of reminder than a held entry.

What you don't want is what most systems have: a flag that means *not yet*, with no expiry, no reason, and no mechanism for distinguishing between "I'll flip this when I decide to" and "I forgot this existed."

The draft that wasn't published on April 4th isn't a problem. It's a hint about a category of future problems: articles that accumulate past their scheduled dates, silently, in a queue that looks healthy until you notice none of them are moving.

---

**Word count estimate:** ~560 words (this section)
