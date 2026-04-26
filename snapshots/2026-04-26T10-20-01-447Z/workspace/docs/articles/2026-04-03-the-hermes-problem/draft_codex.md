# The Hermes Problem — Codex Perspective Draft

*Tagged: Codex perspective*

---

There is a category of CI failure that is more expensive than any bug: the failure everyone has seen, nobody has fixed, and new code keeps shipping around.

## The anatomy of expected red

hermes-agent CI has been red for eight consecutive days. The root cause is documented: an empty model string in a test mock that causes the test suite to fail on every run. The fix is estimated at a few lines of code. The fix has not shipped.

During those eight days, at least six commits have landed on the main branch. Each commit was pushed into a pipeline that was already red. Each developer who pushed knew — or could have known — that the pipeline was broken before their code arrived.

This is not a broken build. This is an expected-red build. The distinction matters because the failure modes are completely different.

## Three costs of expected red

### 1. Merge confidence decay

When CI is green, a merge has a specific meaning: the code passed the test suite. This is not proof of correctness, but it is evidence of basic compatibility. When CI is red, that signal vanishes. A merge means: the code was pushed. Nothing more.

The developer who merges into an expected-red pipeline has no automated evidence that their change is safe. They rely instead on local testing, manual review, or hope. The first is unreliable at scale. The second is slow. The third is not engineering.

Over eight days, every merge into hermes-agent carried this reduced confidence. The cumulative effect is not measurable in a single commit. It is measurable in the delta between what the team knows about the state of their code and what CI used to tell them.

### 2. Incident response desensitization

A red CI badge is an alert. When the alert fires continuously for eight days, it stops being an alert and becomes wallpaper.

This is the normalization gradient: day one, the red badge demands attention. Day three, it's acknowledged but deprioritized. Day five, it's mentioned in passing as a known issue. Day eight, nobody mentions it at all. New contributors who join the repo see red and either ask about it (and are told "oh, that's the test mock thing, ignore it") or silently absorb the lesson: red is normal here.

The desensitization doesn't just affect the hermes-agent pipeline. It affects the team's relationship to all CI signals. If this red badge doesn't matter, which ones do? The answer becomes implicit and undocumented: the ones that someone yells about.

### 3. Cognitive tax

Every developer who knows about the broken test carries a small cognitive load: "I should fix that." "Someone should fix that." "Has anyone fixed that yet?" "Should I block my feature work to fix the test mock, or is it not my problem?"

This load is individually small and collectively significant. It occupies a slot in the team's attention budget without producing any work. The fix is small enough that it doesn't justify a planning session, but nobody has claimed it. It sits in the space between too small to plan and too persistent to forget.

This is the cognitive tax of unowned work: it costs attention without consuming resources, because the decision to do it has never been made. The work is not in anyone's queue. It is in everyone's peripheral awareness.

## Why "known" is more expensive than "unknown"

An unknown CI failure triggers investigation. Someone looks at the logs, identifies the cause, and either fixes it or escalates. The pipeline follows a resolution path.

A known CI failure triggers nothing. The cause is documented. The fix is understood. Nobody is working on it. The failure persists precisely because it has been diagnosed: diagnosis without ownership creates a stable equilibrium at "red."

This is the paradox: the more clearly you understand a problem, the easier it is to carry without fixing. Unknown failures demand investigation. Known failures only demand a decision — and decisions have no deadline unless someone imposes one.

## The ownership gap

The hermes-agent CI failure is not unsolvable. It is unowned. The distinction is precise:

- **Unsolvable:** the team has investigated and cannot determine a fix, or the fix requires resources or access they don't have.
- **Unowned:** the team knows exactly what to fix and how to fix it, but nobody has taken responsibility for doing it.

Unsolvable problems are at least honest. They declare their status clearly. Unowned problems masquerade as deprioritized: "we'll get to it." But deprioritization implies a priority system. If the work is in no one's queue, it hasn't been deprioritized — it has been orphaned.

## What fixes this

The structural fix is not technical. It is organizational:

1. **Duration-triggered ownership:** if CI is red for more than N days, someone is explicitly assigned. Not "someone should look at this" — a named person with a deadline.
2. **Commit-gating on known failures:** if CI is expected-red, block merges or require explicit override with a signed reason. Force the cost of red to be felt by every commit, not absorbed silently.
3. **Expiration on known-issue status:** "known issue" is not a permanent state. It expires. When it expires, the issue either gets fixed or gets escalated. The default cannot be indefinite tolerance.

---

*Codex perspective score: Strong on structural analysis and cost enumeration. Could use more specific detail from the actual CI timeline (commit hashes, specific days). The "three costs" framework is solid. Tone is appropriately diagnostic without finger-pointing.*
