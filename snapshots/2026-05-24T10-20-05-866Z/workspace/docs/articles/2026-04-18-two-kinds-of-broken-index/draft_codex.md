# Two Kinds of Broken Index (Draft — Codex)

The error looks almost the same:

```
fatal: Unable to create '.git/index.lock': File exists.
```

versus

```
fatal: unable to write new index file
```

But they are not the same failure. One is a coordination signal. The other is a system signal.

---

## The Lock Race

`.git/index.lock` is a mutex file. Git creates it at the start of any operation that modifies the index, and removes it when done. If a previous `git` process crashed before cleanup, the lock file is left behind. The next operation sees it and refuses to proceed.

The "fix" everyone learns: `rm .git/index.lock`. This works because you're telling Git: "that process died, I've cleaned up after it, go ahead." You're not fixing a broken system — you're resolving a stale coordination artifact.

This failure is **expected** in automated environments. Two concurrent `git add` calls, a SIGKILL mid-operation, a cron job running before the previous one finishes. The lock is doing its job. The problem is the artifact it leaves behind.

Diagnosis: look for a parallel or lingering `git` process. The fix is cleanup + serialization, not investigation.

---

## The Write Failure

`fatal: unable to write new index file` is different. Git obtained the lock (or doesn't need it at that point), proceeded to write, and failed during the write itself. The filesystem is the problem — not coordination between processes.

Causes include:
- Disk full or quota exceeded
- Permission issue on `.git/index` or its parent
- Corrupt filesystem (especially common on network mounts, Docker bind mounts, or after unclean shutdowns)
- Inode exhaustion

The "rm the lock file" reflex does nothing here. You don't have a stale lock. You have a write path that is broken.

Diagnosis: check `df -h`, check `ls -la .git/index`, run `git fsck`. The fix is a filesystem investigation, not a process coordination cleanup.

---

## Why the Confusion Persists

Both errors surface in the same operation. Both look like "git is broken." Both go away sometimes when you run `git gc` or `rm` various things. The conflation is understandable — until it isn't.

In an automated agent loop that auto-heals by removing the lock file, the write failure will keep recurring. The loop will keep "self-healing." The logs will show `partial` runs. The actual filesystem problem will silently accumulate.

---

## The Reusable Frame

Two categories of failure that look alike:

| | **Lock failure** | **Write failure** |
|---|---|---|
| **Signal** | Coordination | System |
| **Cause** | Stale artifact from dead process | Filesystem cannot write |
| **Fix** | Remove lock, serialize processes | Fix disk/permissions/mount |
| **Self-heals?** | Usually, after cleanup | No |
| **Auto-heal risk** | Low | Masks the real problem |

Before you `rm .git/index.lock`, ask: does the lock file actually exist? If the error is about *writing*, not *locking*, you're diagnosing the wrong layer.

---

## The Incident

On 2026-03-29 at 07:35 PT, step 16 (`git_autocommit`) failed with `fatal: unable to write new index file` — distinct from the usual `index.lock` stale-lock failures that this system auto-heals routinely. Prior runs showed `partial` status with the standard lock-cleanup fix. This one required manual diagnosis and intervention.

The difference was one word: `lock` vs `write`. But that word pointed to a completely different diagnostic path.
