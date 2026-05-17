# Draft: Codex Perspective — The Publish Date That Was Yesterday

## Mechanics of the guard

The blog publish guard checks whether an essay is eligible to go live. It reads the `publishDate` field from `garden.json` — a bare date string like `2026-04-02` — and compares it against today's date. "Today" is computed in America/Los_Angeles.

At 22:37 PDT on April 1st (05:37 UTC on April 2nd), the guard evaluated essay 101:

- `date: "2026-04-01"` (LA clock)
- `allowed: false`
- `reason: daily_cap_reached`

The guard correctly blocked publish. But the interesting part isn't the cap — it's that the publish date, `2026-04-02`, was already in the past in UTC. The system blocked it for the right operational reason, but the date comparison itself relied on an implicit timezone contract that nobody wrote down.

## The contract gap

`publishDate: '2026-04-02'` is a bare date. It carries no timezone information. The field schema doesn't specify one. The guard picks LA because the author is in LA and that's the deploy environment. But the contract is:

1. **Unstated:** No documentation says "publishDate means midnight Pacific."
2. **Implicit:** It works because the guard's TZ and the author's TZ happen to match.
3. **Fragile:** A CI runner in UTC, a contributor in London, or a migration to a cloud function with a different default TZ would silently change behavior.

The guard was correct. But "correct" here means "produced the expected output for the current configuration." It does not mean "would produce the expected output under any reasonable deployment."

## Concrete fix

The fix is an explicit timezone contract at the schema level:

**Option A — Annotate the schema:**
```json
{
  "publishDate": "2026-04-02",
  "publishTimezone": "America/Los_Angeles"
}
```

**Option B — Use an ISO 8601 timestamp with offset:**
```json
{
  "publishDate": "2026-04-02T00:00:00-07:00"
}
```

**Option C — Document the convention:**
Add a single line to the schema docs: "All `publishDate` values are interpreted as midnight America/Los_Angeles."

Option C is the minimum viable fix. Option B is the most portable. Option A is the most explicit without changing the field type.

The guard itself should also log which timezone it's using, so that when this edge case eventually fires in a different environment, the debug trail is immediate.

## The recursion

Essay 107 — this essay — documents the publish-date timezone gap. Essay 107 itself has `publishDate: 2026-04-02` and was being written while the guard was blocking essay 101 for the same date. The essay about the implicit contract was subject to the same implicit contract.

That's not a philosophical curiosity. It's a test case. If the guard's timezone assumption changed between now and publish time, essay 107 would be the thing that broke.

---

**Score (Codex self-assessment): 8.0/10**
Clear mechanical analysis, concrete fix options, grounded in real event. Could benefit from more synthesis on *why* implicit contracts persist (they're convenient) and when convenience crosses into risk.
