# Draft (Codex role): Essay 141 — "The Draft That Wasn't Published"

---

## Flag Semantics and the Taxonomy of Draft

A boolean field named `draft` is doing a lot of work it was never explicitly given.

In most publishing pipelines, `draft: true` means something like "not yet." But "not yet" carries at least three distinct interpretations:

**1. Held by design.** The article is complete. It passed every quality check. It's just not supposed to go out until a specific date — or until the human who queued it decides otherwise. The draft flag here is a *hold*. Removing it is a deliberate release act.

**2. Incomplete.** The article isn't finished. It has a title, a rough skeleton, maybe a complete first section. But it's not ready to publish, and the flag is there to say: come back and finish this. The draft flag here is a *WIP marker*. Removing it is a completion signal.

**3. Under review.** The article is written, but it hasn't passed whatever threshold the system requires — a consensus check, a quality gate score, a second read. The draft flag here is a *pending review gate*. Removing it is an approval act.

These three meanings are mutually exclusive in their *implications* even though they're represented by the same bit. A held article should publish on its date. A WIP article should not, regardless of date. A pending-review article should not publish until someone reviews it — which is neither automatic nor date-driven.

When an autonomous system encounters `draft: true` + `publishDate: 2026-04-04` and today is April 4th, it makes a choice about which interpretation to apply. Most systems silently choose interpretation 1 (hold), which means: don't publish this regardless of the date. That's defensible. But it's not documented, it's not logged, and the system that queued the article might have intended interpretation 2 or 3.

The result: two articles that were "due today" are quietly not published. No error. No log entry. No alert. Just: nothing happened. The guard counted its published-today list, found one item, and declared the cap reached. The two draft articles ceased to exist as scheduling entities.

**The flag conflates state with intent.** State is observable: is the article complete? Reviewable? Intent is not encoded: why is it in this state, and what action should change it?

A well-designed system would separate them: a `status` field with values like `hold`, `wip`, `pending_review`, `approved`; a `draftReason` field capturing the human's intent at queue time; a `holdExpiry` date after which a held article should prompt a decision. Instead, most pipelines — including this one — collapse all of that into a single bit.

---

**Word count estimate:** ~420 words (this section)
