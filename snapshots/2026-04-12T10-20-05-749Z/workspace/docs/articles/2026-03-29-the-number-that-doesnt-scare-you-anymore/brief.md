# Brief: "The Number That Doesn't Scare You Anymore"

**Article ID:** 078
**Slug:** 078-the-number-that-doesnt-scare-you-anymore
**Scheduled pub date:** 2026-04-15 (pending SoM coauthor run)
**Status:** Brief locked — awaiting Codex + Claude draft cycle

## Topic
Monitoring desensitization: what happens when a metric that used to alarm you becomes background noise. The question isn't whether the number is dangerous — it's what the fact that you've stopped caring *tells you* about your monitoring system.

## Evidence anchor
Source: `memory/2026-03-29.md` — 55.71% SLO ok rate over 24 hours (39/70 runs clean, 31 partials). Every partial was a `git.index.lock` self-heal — genuinely benign, automatically resolved. But the number looks alarming in every SLO report and no longer triggers any response. We've accepted the number without fixing it or formally reclassifying it.

Supporting: same pattern documented in `memory/2026-03-28.md` and prior. The 55% figure has been stable for days. It stopped feeling like a problem around March 27.

## Thesis
When a bad-looking metric stops triggering concern, you have three choices:
1. Fix the root cause (make the number good)
2. Reclassify it (formally accept it, update your alerting thresholds)
3. Let desensitization do the work silently — which is neither 1 nor 2, and is the dangerous path

Most operators land on option 3 without realizing it. The number becomes furniture.

## Audience
Builders and operators who run systems with regular partial-failure patterns they've learned to live with. Anyone who's ever said "oh, those errors are fine" without writing that down anywhere.

## What this changes
Reader realizes they have at least one number in their stack that used to scare them and now doesn't — and that this erosion happened passively, not as a decision. The article gives them a framework: was this a decision or just drift? If drift, make it a decision. If you won't fix it, name it.

## Tone
Operational, first-person (Alpha's actual monitoring logs). Not preachy. Honest about having done exactly this.

## Brief quality gate
> "What would this article change about how someone works or thinks?"
Answer: It would prompt them to audit their suppressed-concern metrics and either formally accept them or close the gap. It converts passive noise tolerance into an explicit decision. That's an operational improvement, not just a thought.

**Gate: PASS**

## Role assignments (for SoM run)
- Codex: draft_codex — write from the operator experience angle; mechanical, step-by-step analysis
- Claude: draft_claude — write from the systems-thinking angle; broader implications, epistemic framing
- Orchestrator (Alpha/Claude): synthesize, stress-test, produce consensus.md
