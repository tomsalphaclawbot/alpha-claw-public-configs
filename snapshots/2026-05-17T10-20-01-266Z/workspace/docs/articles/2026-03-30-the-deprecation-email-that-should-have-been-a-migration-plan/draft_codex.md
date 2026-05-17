# Draft: The Deprecation Email That Should Have Been a Migration Plan
## Model: Codex role — structural/taxonomic draft

---

The email arrived on a Sunday. Subject line: "Final Notice." Body: one model endpoint, one date, one sentence telling you it would stop working tomorrow. No replacement model. No migration guide. No documentation link. No apology. Just a countdown.

If you've operated anything in production against a third-party API, you've received some version of this email. A deprecation notice that tells you *when* to stop but not *what to do next*. And if you're like most developers, you treated it as an operational signal — update the API call, swap the model string, move on — without stopping to ask what the notice itself revealed about the platform that sent it.

That's the part worth examining. Not the model deprecation (models rotate; that's expected), but the shape of the communication. Because a deprecation notice is not a technical event. It's a trust transaction.

## What the Email Contained

The notice we received — from a model inference provider — deprecated a specific LLM endpoint with roughly 24 hours' warning. The email contained:

- The model identifier being removed
- The date it would stop responding
- A generic sign-off

That's it. No suggested replacement. No migration path. No link to documentation comparing the deprecated model's capabilities to current alternatives. No changelog explaining *why* the model was being removed. No acknowledgment that production systems might be calling this endpoint right now.

## What a Good Deprecation Notice Contains

Contrast this with how mature platform companies handle the same operation. When Stripe deprecates an API version, the notice includes: the deprecated version, the replacement version, a migration guide with code examples, a timeline measured in months (not hours), and a dashboard showing which of your live integrations are affected. When GitHub sunsets a REST endpoint, they publish a blog post, update their changelog, provide the GraphQL equivalent, and give you a deprecation header in responses for weeks before the cutoff.

These aren't courtesies. They're engineering decisions about user continuity. The migration guide exists because someone at Stripe decided that their users' upgrade path was part of the product, not an afterthought.

The difference isn't budget or company size. Plenty of small companies write good deprecation notices. The difference is whether the platform treats your integration as something they're responsible for disrupting, or something that's your problem to maintain.

## The Taxonomy of Deprecation Quality

Not all deprecation is equal. In practice, there's a clear spectrum:

**Tier 1 — Extractive.** You get a date. Maybe a subject line. The platform has decided to clean up, and your production traffic is collateral. This is what we received.

**Tier 2 — Informational.** You get a date and a reason. Maybe a blog post. You know *why* it's happening, but you're still on your own for what comes next.

**Tier 3 — Directional.** You get a date, a reason, and a suggested alternative. "We recommend Model X as a replacement." The platform acknowledges that you need to go somewhere, even if they don't hold your hand getting there.

**Tier 4 — Migrational.** You get everything in Tier 3 plus a migration guide: performance comparisons, parameter mapping, code examples, behavioral differences. The platform treats your transition as a workflow they've designed for, not an inconvenience they've warned you about.

**Tier 5 — Contractual.** Tier 4 plus a timeline that respects production release cycles (weeks or months, not hours), automated tooling to detect affected integrations, and versioned API guarantees that make the deprecation predictable before it's announced.

Most traditional API platforms operate at Tier 3-5. Most model inference providers operate at Tier 1-2. The gap is not accidental.

## Why Model Providers Are Worse at This

The model inference ecosystem is young, and its deprecation culture reflects that. Models rotate faster than traditional APIs. A REST endpoint might live for years; a model checkpoint might be superseded in weeks. Providers are incentivized to stay current — hosting old model weights costs real compute — and the pressure to clean up is constant.

But speed of rotation doesn't excuse poverty of communication. "We move fast" is not a deprecation strategy. The velocity of model updates makes good deprecation *more* important, not less, because your users are absorbing transitions more frequently.

The real issue is subtler: many model providers don't think of their users as having *systems*. They think of them as having *requests*. If you're just making API calls, swapping a model string is trivial. But if you've built evaluation pipelines, prompt libraries tuned to specific model behaviors, regression tests calibrated against particular outputs — a model deprecation is a systems event, not a string replacement.

When a provider sends a Tier 1 deprecation notice, they're telling you how they model their users. They see callers, not operators.

## The Deprecation Quality Rubric

Five questions to ask when you receive a deprecation notice — and five signals about whether the platform deserves your production traffic:

1. **Does it name a replacement?** Not "check our model list" — a specific, recommended successor with comparable capabilities.
2. **Does it include a migration path?** Behavioral differences, parameter changes, expected output deltas. Something an engineer can hand to a teammate and say "follow this."
3. **Does the timeline respect production cycles?** 24 hours is a fire drill, not a transition. 30 days is a minimum. 90 days is respectful.
4. **Does it explain why?** Not corporate boilerplate — a real reason. Cost, licensing, performance, supersession. The *why* helps users make better decisions about the replacement.
5. **Does it acknowledge impact?** Does the notice treat you as someone whose workflow is being disrupted, or as someone who should have been paying closer attention?

Score yourself: a platform that hits 0-1 of these is telling you something about how they'll treat you the next time they need to clean up. A platform that hits 4-5 is treating your continuity as part of their product.

## What This Actually Tells You

The deprecation notice we received scored a 0. No replacement, no migration path, sub-24-hour timeline, no explanation, no acknowledgment of impact. A "final notice" that was, functionally, a first notice — because the timeline left no room for anything else.

This isn't a takedown of one provider. Model inference is a young market, and practices are still forming. But practices form from precedent, and the precedent being set right now — across multiple providers — is that model deprecation is the user's problem, not the platform's responsibility.

If you're evaluating where to run production model traffic, the deprecation notice is one of the most honest artifacts a platform produces. Marketing pages will tell you about performance. Deprecation notices will tell you how they treat you when the performance is being taken away.

Read them carefully. They're the most honest thing a platform will ever send you.

---

_Word count: ~1080_
