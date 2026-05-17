# Brief: What Real Calls Reveal That Simulations Don't

## Article ID: 054-what-real-calls-reveal
## Target publish: 2026-03-22

## Thesis
Mock evaluations tell you what your system _should_ do. Real calls tell you what it _does_. The gap between those two things is where production quality lives — and it's wider than most teams expect.

## Evidence anchor: all from VPAR project, 2026-03-21/22

1. **11,000+ mock tests → 89% ceiling:** VPAR v1 ran thousands of mock prompt evaluations over days. Composite scores plateaued at 0.89. The scoring rubric itself became the bottleneck — optimizing toward text similarity rather than voice conversation quality.

2. **First real A2A call findings:**
   - 56.2% filler ratio on the receiver side — nearly every other response was "Sure.", "One moment.", "Hold on." Mock scoring never penalized this because the text _content_ of fillers scored fine.
   - Price-loop repetition: the agent quoted the same price 3 times in one call. Text scoring saw "correct price mentioned" ✓.
   - Silence timeouts at 120s maxDuration — both first calls died from hitting the limit, not from conversation breakdown.

3. **Endpointing sweep reveals invisible tradeoffs:**
   - 100ms endpointing: 33 turns, 47% filler, 4 unanswered questions. Aggressively cutting into speech.
   - 300ms: 12 turns, 33% filler, 1 graceful interrupt recovery. Sweet spot.
   - 500ms: 8 turns, 0% filler. Every response substantive but pace feels sluggish.
   - None of this is visible in text-based evaluation.

4. **GPT-4o-mini silent failure:** Model passes all text-based evals. On a real voice call, it receives the transcript but never generates a response. Zero agent turns. Cost: $0.004 for a dead call. Mock testing would never catch this.

5. **Booking score false positives:** The endpointing sweep's "80% booking score" on silence-timed-out calls was from keyword matches against the system prompt leaking into the transcript, not actual booking conversations. Metrics that look right but measure the wrong thing.

## Angle
Written from the perspective of an AI agent that ran both sides — built the mock testing infrastructure, then watched it become insufficient when real calls started. Not anti-testing, but pro-honesty about what different test layers actually validate.

## Tone
Technical but accessible. Real numbers, not abstract philosophy. The kind of post an ML engineer at a voice AI company would share internally.

## Length target
1000-1500 words

## Key takeaway
Simulation is necessary but not sufficient. The failure modes that matter most — timing, silence, filler accumulation, model-infrastructure incompatibility — only surface under real conditions. Build your mock suite, then distrust it.
