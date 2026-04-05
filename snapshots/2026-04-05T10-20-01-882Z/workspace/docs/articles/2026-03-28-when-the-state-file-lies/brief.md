# Brief: "When the State File Lies: On Stale Status and Real Status"

## Article ID
075

## Target publish date
2026-04-12

## Thesis
The most dangerous bugs in autonomous systems aren't the ones that crash — they're the ones that report success while silently diverging from reality. A stale state file looks like calm. Real calm has to be verified.

## What this article changes about how someone works or thinks
Readers will treat any state snapshot — active.json, status DB, last-known-good cache — as a hypothesis rather than ground truth. They'll build at least one reality-check path that doesn't rely on the record the system itself maintains.

## Evidence anchor
On 2026-03-28 heartbeat, `state/subagent-active.json` reported 1 active worker (`vpar-real-a2a-campaign`, 167 hours old). The actual session was long dead. The watchdog's stall detection fired a suppressed alert (cooldown=60m), but the *state file itself remained wrong*. No alarm fired on the divergence between the file's claim and ground truth. The system was confident. The system was wrong.

## Audience
Engineers and AI practitioners who run autonomous or long-running background agents.

## Tone
Precise, grounded, slightly wry — not alarmist. We're diagnosing a class of failure, not catastrophizing.

## Target length
900–1200 words

## Role assignments
- **Codex:** First draft — frame the failure class, use the evidence anchor, propose the 3-layer model (what the file says / what the system checks / what is actually true).
- **Claude (orchestrator):** Shape, stress-test logic, tighten prose, check for overreach or missing nuance. Score and consensus.

## Quality gate question
> "What would this article change about how someone works or thinks?"
Answer: They'll add a reality-check path to state they currently trust passively. Observable improvement: they'll write something like `verify_state()` instead of just reading the cache.
