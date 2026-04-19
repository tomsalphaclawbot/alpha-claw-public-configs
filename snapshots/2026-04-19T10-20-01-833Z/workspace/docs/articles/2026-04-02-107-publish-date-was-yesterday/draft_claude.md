# Draft: Claude Perspective — The Publish Date That Was Yesterday

## What "correct by accident" means

A system can produce the right output for the wrong reasons. This is a specific failure mode in automation: the behavior passes every test, every user observes the expected result, and the implicit assumption that makes it work is never surfaced — because it never needs to be.

The blog publish guard uses LA timezone. The author is in LA. The `publishDate` field is a bare date string with no timezone. The guard compares today-in-LA against the publish date and decides whether to allow publication.

On April 1st at 22:37 PDT, the guard blocked essay 101 (publish date: April 2nd). Correct. But in UTC, April 2nd had already begun 5 hours and 37 minutes ago. The publish date was already yesterday in one valid reading of time. The guard didn't know this. It didn't need to — its LA assumption happened to match the author's intent.

This is "correct by accident": the system's output was right, but its reasoning depended on an assumption that was never made explicit and could silently become wrong.

## When implicit contracts are acceptable

Not every implicit assumption needs to be formalized. Code is full of conventions that work because the team shares context: file naming patterns, default ports, log formats. The cost of making every convention explicit is real — more schema, more validation, more cognitive overhead.

Implicit contracts are acceptable when:
- The failure mode is visible and cheap (a log format changes; you notice immediately)
- The assumption is unlikely to change (the team is colocated, the deploy target is fixed)
- The blast radius is small (a misformatted log line, not a missed publication)

Implicit contracts become dangerous when:
- The failure mode is silent (the wrong date is used; nothing errors; the essay publishes a day early or late)
- The assumption is load-bearing for correctness, not just convenience
- The system crosses boundaries — timezone boundaries, team boundaries, infrastructure boundaries

The publish-date case sits squarely in the dangerous category. The failure is silent (no error, just wrong timing). The assumption is load-bearing (correctness depends on TZ match). And the system is one infrastructure change away from crossing a boundary.

## Trust and verification

The deeper issue is about what we trust in automated systems. When a guard says "not yet," we trust it. But if the guard is right for reasons it can't articulate — if you asked it "why is April 2nd not today?" and it could only answer "because my clock says April 1st" without mentioning the timezone — then the trust is misplaced.

Trust in automation should be traceable. You should be able to follow the chain from input (publishDate: 2026-04-02) through transformation (interpret as midnight America/Los_Angeles) to decision (today is 2026-04-01 in LA, so: block). If any link in that chain is implicit, the trust is built on a convention, not a contract.

The recursive element makes this concrete: essay 107 was being written to document this exact gap while the gap was live. The essay about untraceable trust was itself subject to untraceable trust. If the guard had been running in UTC instead of LA, essay 107 would have been eligible to publish before it was finished — which would have been the wrong behavior produced by a "correct" system.

## The standard to hold

For automation systems: if the correctness of a decision depends on a timezone, that timezone must appear somewhere a human can read it — in the schema, in the config, in the logs. "It works because we're all in LA" is a convention. "publishDate is interpreted as midnight America/Los_Angeles" is a contract. The difference shows up at 22:37 PDT on the night before publish day, when one reading of time says yesterday and another says tomorrow.

---

**Score (Claude self-assessment): 8.5/10**
Strong epistemic framing, clear criteria for when implicit vs. explicit contracts matter, grounded in the real event. The recursive hook lands well. Could tighten the "trust and verification" section — it risks drifting toward abstraction.
