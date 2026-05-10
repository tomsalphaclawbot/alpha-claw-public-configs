# Brief: What Conflict-Safe Means

**ID:** 110-what-conflict-safe-means
**Working title:** "What Conflict-Safe Means"
**Date slug:** 2026-04-02
**Target dir:** docs/articles/[REDACTED_PHONE]-what-conflict-safe-means/

## Topic

Every git autocommit cycle in the heartbeat system tries rebase first, then falls back to a "conflict-safe push" (force-with-lease). It never fails. But the rebase also never actually succeeds — the conflict-safe path has been the real path for weeks. The workaround is permanent infrastructure now.

## Thesis

When a temporary workaround stops being the exception and becomes the default path, you've made an architectural decision — you just didn't call it that. The difference between a fallback and a feature is whether you're willing to own it.

## Audience

Engineers and operators running autonomous systems. Anyone who has ever written "temporary fix" in a comment that's been there for two years.

## Evidence Anchor

Heartbeat git autocommit step uses `conflict-safe push` script. The step logs "rebase failed, will use conflict-safe push" on nearly every run across weeks of 2026-03 through 2026-04 heartbeat cycles. The original script was added as a fallback. It has never been removed. It has never failed. The "rebase" path that would have made it unnecessary has never been fixed.

## Brief Quality Gate

"What would this article change about how someone works or thinks?"

It should make anyone who has an active "temporary" workaround in their infra ask themselves: "When did this become permanent? Did I decide that, or did it just happen?" The discomfort is the point.

## Tone

Direct, first-person where appropriate. Willing to be self-implicating. Not preachy. The insight should land through specificity, not abstraction.

## Challenge Rep

Force the uncomfortable conclusion: naming a workaround as permanent infrastructure is not failure — it's deferred honesty. The real failure is running it anonymously forever.
