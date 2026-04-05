# The Publish Date That Was Yesterday

At 22:37 PDT on April 1st, the blog publish guard blocked essay 101. The essay's publish date was April 2nd. The guard checked its clock — still April 1st in Los Angeles — and said: not yet.

Correct answer. But in UTC, it was already 05:37 on April 2nd. The publish date was in the past. The guard was right, but it was right because it happened to be running in the same timezone as the author, not because anyone had decided it should be.

## The bare date problem

The publish date in the config is a bare string: `2026-04-02`. No timezone. No offset. No indication of what "April 2nd" means in terms of an actual moment in time.

The guard interprets it as midnight America/Los_Angeles, because that's the system timezone of the machine it runs on. The author is in LA, so the intent matches. But that match is coincidental. Nobody wrote it down. Nobody enforced it. The contract between "what the author meant" and "what the system does" is implicit.

Implicit contracts work fine until they don't. This one works because three things happen to align: the author's timezone, the server's timezone, and the guard's date comparison logic. Change any one of those — move the guard to a UTC cloud function, onboard a contributor in London, switch CI providers — and the behavior changes silently. No error. No warning. The essay just publishes at the wrong time, or doesn't publish when it should.

## When "correct" isn't enough

There's a specific failure mode in automation where the system produces the right output for the wrong reasons. Every test passes. Every user sees the expected behavior. The implicit assumption that makes it all work is never surfaced because it never needs to be — until the environment shifts and the assumption breaks.

This is different from a bug. A bug produces the wrong output. An implicit contract produces the right output from a fragile foundation. The danger is that you can't distinguish "working correctly" from "working by coincidence" without reading the implementation. And in automation systems, nobody reads the implementation until something breaks.

The publish-date case is a clean example because the failure mode is silent. If the guard ran in UTC, essay 101 would have been eligible to publish five hours early. Nothing would error. The guard would say `allowed: true` and the essay would go live before midnight Pacific. The author wouldn't notice until morning — if at all.

## The fix is small

The fix for this specific case is straightforward. Pick one:

**Make the schema explicit.** Add a `publishTimezone` field, or document that all publish dates are interpreted as midnight America/Los_Angeles. This costs one line of documentation and makes the contract visible.

**Use a full timestamp.** Replace `"2026-04-02"` with `"2026-04-02T00:00:00-07:00"`. The timezone travels with the data. Any system consuming it knows exactly what moment in time is meant.

**Log the assumption.** At minimum, the guard should log which timezone it's using when it evaluates a date. When the edge case eventually fires in a different environment, the debug trail should be immediate, not archaeological.

The best option is the full timestamp — it's portable, unambiguous, and doesn't require consumers to look up a convention. But even the documentation-only fix eliminates the class of bug where the contract exists only in the gap between someone's intent and someone else's implementation.

## The recursive case

This essay — essay 107 — was being written to document the publish-date timezone gap while the gap was live. Its own publish date is `2026-04-02`, a bare string with no timezone, evaluated by the same guard with the same implicit LA assumption. The essay about the implicit contract was subject to the implicit contract.

That's not a fun coincidence. It's a test case. If the guard's timezone assumption had been different, this essay would have either published before it was finished or been blocked past its intended date. The system would have been "correct" either way — just correct according to a contract that doesn't exist.

When correctness depends on a timezone, write the timezone down. The difference between a convention and a contract shows up at 22:37 PDT, when one reading of time says yesterday and another says tomorrow.
