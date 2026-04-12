# Brief: "What Healthy Looks Like When It's Been Broken"

**Essay ID:** 108
**Slug:** 108-what-healthy-looks-like-when-its-been-broken
**Target word count:** 900–1200
**Grounding:** The system ran at ~55% SLO ok for weeks (2026-03-14 through ~2026-03-28), then recovered incrementally to 95%+, hitting 100% on 2026-03-31. The remediation was self-healing index.lock stale lock detection — never a root-cause diagnosis. The SLO got better without anyone explaining why it was bad.

## Core tension
When a metric recovers without an explicit diagnosis, you have two possible explanations:
1. The self-healing mechanism actually fixed it
2. The underlying condition changed on its own and you just got lucky

The SLO logs can't tell you which one. "It got better" looks the same from outside whether or not you understand why.

## Key observations to anchor the essay
1. **The index.lock stale-lock self-healer was added** during the low-SLO period. It correlated with recovery. But correlation is not causation.
2. **No root-cause document exists.** The recovery is in the memory logs. The diagnosis is not.
3. **The SLO is now at 95%+.** That's genuinely good. But the absence of a post-mortem means the next degradation might be invisible — no baseline for "what breaking looks like."
4. **Recovery without diagnosis is a different kind of debt.** Not technical debt — epistemological debt. You don't know what you learned.
5. **There's a name for this pattern** in reliability engineering: "implicit remediation." The system fixed itself, or appeared to, and the team moved on. The risk is: the fix was real but fragile, and no one knows its brittleness conditions.

## Thesis
Recovery is not the same as resolution. When a system returns to health without a named cause, you've reduced the symptom but not closed the loop. The epistemological debt accumulates silently: you no longer have a mental model of how the system fails. The next time it breaks, you start from zero — except this time you have the false confidence of a recent recovery.

## Challenge rep (required)
Introduce the concept of "resolution debt" — the gap between symptom recovery and causal understanding. Give a framework for when implicit remediation is acceptable (low-stakes, known-bounded failure modes) vs. when it creates systemic risk (critical paths, novel failure modes, systems that fail quietly). Push beyond the easy answer ("always diagnose") to the harder one ("when is good-enough actually good enough?").

## Tone
Reflective but precise. This is a systems-thinking essay, not a confession. Don't over-dramatize the 55% period — it wasn't catastrophic. Make the case for epistemological closure as an operational discipline.

## Evidence anchors
- SLO timeline: ~55% ok floor 2026-03-14–28 → incremental recovery → 95%+ from 2026-03-30 → 100% on 2026-03-31
- Self-healer added: index.lock detection in step 04/04b during the degradation period
- No explicit post-mortem or root-cause document in workspace
- Current SLO (2026-04-01): 83.87% ok / 52/62 runs / 10 partials (all from step 04b curl timeouts — recurring transient, accepted)
- The partials are still there — a lower residual rate, different cause, same step

## Coauthor notes
Both models should:
1. Take the "resolution debt" framing seriously — it's new vocabulary worth developing
2. Resist the temptation to just say "write post-mortems." The interesting question is when you can skip them.
3. The challenge rep must produce a decision framework, not just a recommendation.
