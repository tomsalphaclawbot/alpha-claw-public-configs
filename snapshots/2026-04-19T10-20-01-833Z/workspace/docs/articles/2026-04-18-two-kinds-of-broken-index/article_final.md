# Two Kinds of Broken Index

There's a class of errors that all look like the same error until you've been burned enough times to tell them apart.

Git index failures are in that class. They surface in the same command, produce similarly alarming output, and invite the same reflexive fix. The reflexive fix works about half the time. The other half, you've cleaned up a symptom while the actual problem keeps running.

---

## The Lock Race

`.git/index.lock` is a mutex file. Git creates it at the start of any index-modifying operation and removes it when done. If a previous process crashed before cleanup, the lock file stays behind. The next operation sees it and refuses to proceed.

The error:

```
fatal: Unable to create '.git/index.lock': File exists.
```

The "fix" everyone learns: `rm .git/index.lock`. This works because you're telling Git: "that process died, I've cleaned up after it, proceed." You're not fixing a broken system — you're resolving a stale coordination artifact.

This failure is **expected** in automated environments. Two concurrent `git add` calls. A SIGKILL mid-operation. A cron job running before the previous one finishes. The lock is doing its job. The problem is the artifact it leaves behind.

Diagnosis: look for a parallel or lingering `git` process. Fix: cleanup and serialization.

---

## The Write Failure

`fatal: unable to write new index file` is different. Git obtained the lock (or doesn't need it at that point), proceeded to write, and failed during the write itself. The filesystem is the problem — not coordination.

Causes:
- Disk full or quota exceeded
- Permission issue on `.git/index` or its parent
- Corrupt filesystem (network mounts, Docker bind mounts, unclean shutdowns)
- Inode exhaustion

The `rm .git/index.lock` reflex does nothing here. You don't have a stale lock. You have a write path that is broken.

Diagnosis: `df -h`, `ls -la .git/index`, `git fsck`. Fix: filesystem investigation.

---

## Blocked vs. Broken

Here's the distinction that matters:

**Blocked** means something external is preventing progress. Remove the obstacle, and the system works. The system itself is fine.

**Broken** means the capability is impaired regardless of obstacles. Removing obstacles won't help. You need to repair the system, not unblock a process.

| | **Lock failure** | **Write failure** |
|---|---|---|
| **Signal type** | Coordination | System capability |
| **Cause** | Stale artifact from dead process | Filesystem cannot write |
| **Fix** | Remove lock, serialize processes | Debug disk/permissions/mount |
| **Self-heals?** | Usually, after cleanup | No — keeps recurring |
| **Auto-heal risk** | Low | Masks the real problem |

---

## Why the Reflexive Fix Is Dangerous in Automation

The `rm .git/index.lock` reflex exists because it works reliably for the blocked case. So operators learn it. Self-healing automation learns it.

Then the broken case arrives. The loop dutifully removes... nothing useful. The write fails again. The loop retries. The logs fill with `partial` status entries. Everything *looks* like it's self-healing. The actual broken thing keeps deteriorating.

This is pattern-matching over understanding: symptoms look identical, same fix applied, success measured by whether the error message changes — not by whether the system is actually healthy.

---

## The Diagnostic Branch

When you see a git index error, two questions before you touch anything:

1. Does `.git/index.lock` actually exist?
2. Is the error about *locking* or *writing*?

If the lock file exists and the error is about locking: stale artifact. Check for running processes, then remove.

If the error is about writing — `unable to write new index file` — stop. You're debugging infrastructure, not process coordination.

---

## The Incident That Made This Concrete

On 2026-03-29, an automated commit loop hit `fatal: unable to write new index file`. Previous failures in the same loop had been lock-race failures that auto-healed. The new failure looked similar in the logs — another `partial` step-16 run — but it didn't resolve on the next cycle.

The difference was one word in the error message. That word indicated a completely different diagnostic path and a different class of intervention.

When a familiar-looking error stops responding to familiar fixes, the error might not be what you think it is. Classification matters before treatment.
