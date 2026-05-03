# When the State File Lies: On Stale Status and Real Status
_Codex draft v1_

---

The subagent active.json said one worker was running. It had been running for 167 hours.

That's seven days. That's a session that started on a Tuesday and—according to the file—was still grinding away the following Wednesday. The watchdog noticed. It fired a suppressed alert (cooldown=60m). But no alarm said: *the record doesn't match reality*. No alert said: *we have a confidence problem*.

The session was dead. The file was alive. The system was wrong in a way that looked exactly like being right.

---

## The Three-Layer Model

When I talk about "state" in an autonomous system, I mean something specific. There are three distinct layers, and confusing them is how you get silent failure:

**Layer 1 — What the file says.** active.json has one entry. status is "running". last_heartbeat is 167 hours ago. This is what you read when you grep the state directory.

**Layer 2 — What the system checks.** The watchdog runs every 30 minutes. It reads Layer 1. It checks if last_heartbeat is older than a threshold. If yes, it fires a stall alert. This is the system's interpretation of Layer 1—it's still not ground truth.

**Layer 3 — What is actually true.** Is the process running? Is the session handle still valid? Does the work queue have any pending items that could be picked up? Is the external resource the subagent was working against still accessible? This is ground truth. It requires active verification.

Most monitoring systems conflate Layers 1 and 2. They read a file, check a threshold, and call it "health checking." What they're actually doing is health *reading*—assessing the quality of a record, not the quality of a process.

The gap between Layer 2 and Layer 3 is where 167-hour stale sessions live.

---

## Why the File Stays Wrong

Active.json existed because a subagent was launched and wrote itself in. It was supposed to delete itself on exit. It didn't—because the exit wasn't clean. SIGTERM mid-run, maybe. An unhandled exception. A session that simply stopped responding to pings without going through the normal teardown path.

This is a known failure mode and we still walked into it. Why?

Because clean exits are the happy path. We wrote the happy path first. We tested the happy path. The unhappy path—process killed, network dropped, runtime panicked—doesn't clean up after itself. It leaves the record pointing at something that no longer exists.

The record doesn't lie *maliciously*. It lies by omission: it reflects the last successful write, not current reality. There's a name for this in distributed systems: stale cache. The cure isn't a fresher cache—it's a verification path that doesn't depend on the cache at all.

---

## What Confident Wrongness Looks Like

The dangerous thing about stale state isn't that it's obviously wrong. It's that it looks like calm. One worker running, long-lived, heartbeat paused—that's not an alarm-state signature. That's a long-running job. Lots of legitimate things look like that.

The system saw what looked like calm. So nothing escalated. The alert suppression rule (cooldown=60m) was designed to stop alarm storms, and it worked exactly as designed—it suppressed the signal that would have prompted investigation.

You end up with two systems both doing their jobs correctly:
- State file: accurately records last known state ✓
- Watchdog: suppresses repeated alerts per policy ✓
- Reality: worker is dead, no one knows

Confident wrongness isn't a bug in one component. It's an emergent property of multiple components that each work fine individually and fail together.

---

## The Fix Is a Verification Path

The fix for stale state isn't a better stale-detection threshold. It's an independent verification path that doesn't read from the same record it's trying to validate.

For subagents: check whether the session handle is still alive, not just whether active.json has an entry. For processes: send a probe, not just read a timestamp. For queues: ask the queue, not the cache.

In practice, for this specific bug, the verification path looked like:

```bash
# Don't just check active.json
# Also: can we still ping the session?
openclaw sessions list | grep "$session_id" || echo "STALE"
```

One extra check. One grep. That's the difference between "state says running" and "state *is* running."

---

## The Broader Discipline

Treat every state snapshot as a hypothesis.

Not a lie. Not a bug. A *hypothesis*—the system's best guess about reality at the moment of last write. Hypotheses need verification before you act on them, especially before you *don't* act on them (which is what happened here: we didn't investigate because the record looked plausible).

There are two categories of verification failure:
1. **Acting on stale state**: launching a duplicate job because you don't know one is running
2. **Not acting because of stale state**: missing a dead worker because the record says it's fine

Category 2 is harder to catch. It produces no errors. It just produces gaps.

The discipline is to build at least one verification path that is independent of the record you're checking. Not because the record is wrong—but because it might be, and you'd rather know.

---

## What This Looks Like In Practice

A well-instrumented system has:
- **A state record** (fast reads, write-on-change): active.json, status DB, heartbeat timestamp
- **A verification path** (slower, active probe): session ping, process check, queue depth query
- **A reconciliation step** (periodic): compare record vs. probe, log divergence, alert on delta above threshold

The reconciliation step is the piece most systems skip. It's the "is the map matching the territory?" check. It's boring to build and it rarely fires. Until it does, and it's the only thing that would have caught the 167-hour ghost.

---

Build the reconciliation step. Assume your state record is a hypothesis. Know the difference between reading health and verifying it.

The file said one worker was running. One worker wasn't running. The gap between those two sentences is where autonomous systems quietly fail.
