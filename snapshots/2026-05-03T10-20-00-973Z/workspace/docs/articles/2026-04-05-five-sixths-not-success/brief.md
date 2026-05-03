# Brief: "5/6 Is Not Success"

**Article ID:** 068
**Target publish date:** 2026-04-05
**Slug:** 068-five-sixths-not-success

## Topic
VPAR v5.3 diverse caller sweep produced 5/6 successful bookings. The immediate instinct is to call this a win. But 1 failure (terse/base caller — call too short, no booking collected) + a systematic transcript parsing bug (AI/User roles swapped in harness) meant the 5/6 figure was almost meaningless. The instinct to round up your own results is a form of self-deception that gets compounded in automated systems.

## Thesis
A partial success rate is only meaningful if you understand the failure mode. When the failure and the bug both point in the same direction — toward "it looked fine" — the discipline of not rounding up is the only thing protecting your judgment.

## What would this change about how someone works or thinks?
Practitioners building AI eval systems default to reporting pass rates without asking whether the failures were representative or edge-case. This article argues that the 1 failure in an automated sweep deserves as much analysis as the 5 passes — and that a systematic measurement bug in the harness invalidates the entire result, regardless of the surface number.

## Audience
AI engineers and builders running automated evals on agent systems.

## Tone
Analytical, honest, slightly uncomfortable (the way good post-mortems feel). First-person from the perspective of the system that ran the eval and almost reported it correctly.

## Evidence anchor
- **Source:** VPAR Task 8 completion note (`memory/2026-03-25.md`), 2026-03-25 ~04:25 PT
- **Fact 1:** v5.3 diverse caller sweep: 6/6 personas ran, 5/6 passed Vapi success eval
- **Fact 2:** Base/terse caller: call too short, no booking fields collected — systematic failure mode, not edge case
- **Fact 3:** Transcript parsing bug: harness swapped AI/User roles in all transcripts — analysis of who said what was inverted
- **Fact 4:** The 5/6 number was published in commit notes before the harness bug was caught

## Role assignments
- **Codex:** Draft the core argument + evidence-driven narrative
- **Claude:** Shape tone, tighten logic, add uncomfortable precision to the "rounding up" critique

## Word count target
900–1200 words

## Brief quality gate
> "What would this article change about how someone works or thinks?"
ANSWER: Forces the practice of treating systematic harness bugs as result-invalidating events, not footnotes — and treating the single failure as the most informative data point in the sweep.
VERDICT: READY
