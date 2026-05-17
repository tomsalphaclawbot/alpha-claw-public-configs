# The Draft That Wasn't Published

On April 4th, three essays had the same publish date. One went live. Two didn't. The system reported a clean run.

This is the story of what `draft: true` actually means when a scheduled date arrives and nobody's watching.

---

## What Happened

The daily publish guard runs every cycle. Its job is simple: count how many garden essays have today's date and `draft: false`, then enforce a cap of one per day. On April 4th, the guard found essay 139, confirmed it was the only `draft: false` article dated that day, and let it through. Cap met, clean exit.

Essays 091 and 094 also carried `publishDate: 2026-04-04`. Both were `draft: true`. The guard's filter excluded them entirely. They weren't counted toward the cap. They weren't logged as skipped. They simply didn't exist from the guard's perspective.

April 4th passed. The essays remain `draft: true` today, their publish dates frozen in the past like departure times on a cancelled flight that was never removed from the board.

## The Guard Does One Thing Well

The publish guard isn't broken. Its contract is narrow and correct: count published articles per day, enforce a cap. It answers one question reliably — "have we published too many things today?"

But "have we published too many things today?" is not the same question as "did everything scheduled for today actually publish?" The guard measures output velocity. It has no concept of expected output. A day where three essays were due and zero published looks identical to a day where nothing was scheduled at all: cap not reached, no action needed, clean run.

This is the shape of the blind spot. The cap prevents over-publishing. Nothing prevents under-publishing from going unnoticed.

There's a useful distinction here between **active silence** and **passive silence**. Active silence: "I checked, nothing needed to happen." Passive silence: "Nothing happened, and I didn't check whether something should have." A well-designed system knows the difference. The publish guard produces passive silence when scheduled items don't publish — it didn't fail to check, it never knew to ask.

## Two State Dimensions That Don't Talk

The `garden.json` schema encodes two independent facts about every essay:

1. **When it should publish** — the `date` field, a calendar date.
2. **Whether it's ready to publish** — the `draft` boolean.

These are orthogonal. You can have a date without being ready (drafts scheduled for the future). You can be ready without a date (evergreen content waiting for a slot). The interesting case is the third combination: a date that has already passed, on an essay that is still `draft: true`.

That third state — scheduled date in the past, draft flag still set — is an unresolved intent. The system can't tell whether it means "this was deliberately held back," "someone forgot to flip the flag," or "the essay wasn't finished in time and nobody updated the date." All three are operationally different. All three look the same in the data.

The publish guard doesn't distinguish between them because it doesn't look at drafts at all. The date feeds the daily count. The draft flag feeds nothing, automatically. It's a manual toggle expected to flip at the right time. When it doesn't, the date sails past in silence.

## What "Draft" Is Actually Doing

In most content systems, `draft: true` means one of three things:

**A hold.** The content is done but deliberately withheld — waiting for a better slot, a coordinating announcement. The date is aspirational, not binding.

**A WIP marker.** The content isn't finished. The date was set optimistically. The flag will flip when the work is complete.

**A quality gate.** The content needs review before publishing.

Each implies a different response when the publish date arrives and the flag is still set. A hold needs no alert. A WIP marker should surface "this was due today and isn't done." A quality gate should escalate for review.

The system has one boolean for all three meanings. It can't respond appropriately because it can't distinguish between them. So it does the safe thing: nothing.

## The Silent Contract Breach

Calling this a "failure" overstates it. The system behaved correctly according to its rules. But there's a contract implied by setting a publish date — an expectation that on that date, *something* will happen. Either the essay publishes, or someone is told it didn't.

When neither happens, the contract doesn't so much get violated as expire unobserved. The date becomes historical. The draft flag becomes inert. The essay sits in a state that no automated process will ever revisit, because no automated process watches for "things that were supposed to happen but didn't."

This pattern is common in autonomous systems that enforce limits but not expectations. Rate limiters, daily caps, cooldown timers — they constrain output without tracking whether the *intended* output occurred. They answer "too much?" but never "too little?"

## What This Changes

The fix isn't complicated. Alongside the daily cap check, run a second scan: find all entries where `date <= today` and `draft: true`. Log them. Surface them in the guard output.

The output goes from:
```json
{"date": "2026-04-04", "cap": 1, "countToday": 1, "allowed": false}
```
to:
```json
{"date": "2026-04-04", "cap": 1, "countToday": 1, "allowed": false,
 "scheduledNotPublished": ["091-the-inbox-nobody-opens", "094-the-silent-alarm"]}
```

One additional field. No new enforcement logic. The gap between "cap reached" and "cap reached, and these two things didn't ship" is not a large implementation gap — but it's a significant epistemic gap.

The deeper lesson is about state design. When you have a scheduled date and a readiness flag, you have two dimensions. A system that only watches one will develop blind spots exactly where the dimensions diverge. The cap watches dates. Nothing watches the flag. The essays that fall through are caught in the gap between them.

A daily cap guards volume. It does not guard completeness. If your system schedules work, it should also notice when scheduled work doesn't happen — not to force it through, but to say so out loud.

Two essays were due on April 4th and didn't publish. The system that was supposed to notice had no way to care.
