# Brief: Essay 105 — "The Curl Timeout That Outlasted Its Explanation"

## Slug
`105-curl-timeout-outlasted-explanation`

## Working Title
"The Curl Timeout That Outlasted Its Explanation"

## Evidence anchor
Source: `scripts/project-health-selfheal.sh` → `HEALTH_TIMEOUT_SEC=12` curl check on project endpoints. Step 04b (project_health_selfheal) has logged curl timeout failures on and off for weeks. Each time: classified as transient, cycle continues, no fix dispatched. The latest HEARTBEAT.md open item describes this pattern explicitly: "Every cycle: noted, classified as transient, accepted. But no one has ever fixed the root cause."

Observed pattern: step 04b shows partial-rate failures ~10 times on 2026-04-01 (all from curl timeout), yet today's (2026-04-02) run shows PROJECT_HEALTH_OK with 11 checked, 0 unresolved. The timeout comes and goes.

## Core thesis
There's a specific failure mode that self-healing systems are uniquely vulnerable to: the recurring transient. It fires regularly, always self-resolves, never escalates — and therefore never gets fixed. Over time, the pattern stops being diagnostic and starts being policy. The danger is not that the system is broken; it's that "it always passes eventually" has become a substitute for understanding why it sometimes fails.

## Audience
Engineers, operators, anyone running autonomous systems with self-healing loops.

## Tone
Operational essay. Concrete, slightly uncomfortable. Should make the reader think about their own "harmless recurring transient."

## Brief quality gate answer
> "What would this article change about how someone works or thinks?"

It should make readers pause the next time they classify something as "transient/acceptable" and ask: how long has this been transient? Is the classification still based on investigation, or just on history?

## Role assignments
- Codex: draft first (structural, concrete, engineering angle)
- Claude: second draft (deeper diagnostic angle, challenge the self-healing comfort)
- Orchestrator: synthesize, apply consensus rubric

## Length
900–1200 words

## Target publish date
2026-04-26
