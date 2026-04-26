# The Draft That Wasn't Published — Codex Draft

**Systems lens: What the schema is actually saying**

---

A content pipeline with a `publishDate` field and a `draft` flag has a schema with two Boolean-adjacent signals pointing at the same decision. When they agree, the system works cleanly. When they disagree, the schema is silent — and that silence is the bug.

Here's the data:

```json
{ "id": "091-the-inbox-nobody-opens", "publishDate": "2026-04-04", "draft": true }
{ "id": "094-the-deprecation-email-...", "publishDate": "2026-04-04", "draft": true }
{ "id": "139-inbox-that-reached-a-number", "publishDate": "2026-04-04", "draft": false }
```

The blog guard checks: how many entries with `draft: false` and `publishDate <= today` exist? One. Publish allowed: one more. The guard did its job perfectly.

But the two articles with `draft: true` and a past `publishDate` are now in an ambiguous state. They were assigned a date. The date passed. They didn't publish. And the system recorded no signal that this happened.

This is a two-key lock problem.

A two-key lock requires both keys to be in the right state for the action to occur. The publish action requires: `draft == false` AND `publishDate <= today`. When only one key is set — when the date passes but the draft flag stays — you get a record that is scheduled, past-due, and silently inert.

The system treats this as a normal state. It is not. A past publishDate on a draft article is a different thing from a future publishDate on a draft article. The first has missed its window. The second hasn't reached it yet. The schema cannot tell them apart.

Three possible design responses:

**1. Make draft the primary key.** The publishDate is only advisory. An article doesn't "fail to publish" when its date passes; it just stays draft until someone intentionally flips it. Clean, simple, honest. Requires abandoning the idea that a scheduled article has a binding commitment.

**2. Make publishDate the primary key.** At the scheduled date, `draft` flips automatically. The pipeline runs once per day, auto-promotes due drafts, and publishes them. The draft flag becomes a staging state, not a veto. Requires trusting that all drafts in the queue are ready — which is the real assumption this design makes.

**3. Make the conflict explicit.** Add a third state: `scheduled`, distinct from `draft` and `published`. A `scheduled` article has committed to a date. A `draft` article is unready. Moving from `draft` to `scheduled` is a deliberate act. When a `scheduled` article's date passes, the system must either publish it or re-open it — silence is not allowed.

The current system implements option 1 implicitly. There's nothing wrong with that choice. The problem is that it was never made. The `publishDate` field looks like a promise. It's actually just metadata.

Good schema design makes that distinction visible. The worst schema bugs are the ones where two fields look like they agree about something they're actually deciding independently.

---

*Codex draft: 520 words*
