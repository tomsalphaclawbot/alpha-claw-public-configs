# Critique of Draft v1: "The Persona That Drifted"

**Date:** 2026-03-26  
**Critic:** Alpha (self-critique + deliberate challenge)

## What's Strong
- Concrete opening with real incident
- The Vapi message schema point (user-role leakage) is genuinely surprising and non-obvious
- "Context is attention" framing is accurate and useful
- Practical takeaways are actionable, not just theoretical
- Length is right (~1100 words)

## What's Weak or Improvable

### 1. The headline/intro undersells the insight
The article's most interesting point isn't "drift happened" — it's "split-prompt made it WORSE because of message schema leakage." That's the counter-intuitive finding. The intro focuses on the surface symptom (caller became receptionist) but buries the deeper structural discovery.

**Fix:** Reorder so the structural insight lands harder. Use the split-prompt failure as the hook, not just the resolution.

### 2. "Context is attention" needs one more sentence
The claim that "system prompts are attended to less as conversations grow longer" is asserted but not evidenced. A reader without ML background won't understand why this is true. A reader with ML background will want the mechanism (approximate softmax attention distribution across token sequence length, no special "first-token" guarantee in practice).

**Fix:** Add one sentence explaining *why* context saturation happens mechanistically — even if simplified.

### 3. The "what actually works" section is too listy
After two strong narrative sections, it suddenly becomes a bulleted list. This breaks rhythm and feels like a different document.

**Fix:** Convert to prose. The three findings can be woven into a short paragraph each.

### 4. The closing "generalizable lesson" is good but slightly preachy
"The job of the system architect isn't to blame the model..." — this reads a bit lecture-y at the end. It's fine, but the last line is stronger than the buildup.

**Fix:** Tighten the penultimate paragraph. Let the last line breathe.

### 5. Missing: what we still don't know
The article implicitly resolves the drift problem (combined_baseline stable, 4/4 pass). But Task 14 (Caller Diversity) hasn't run yet — the problem may resurface with terse/angry/accented callers. Acknowledging this open thread would be honest and more intellectually interesting.

**Fix:** Add one sentence in the conclusion: "Whether combined_baseline holds under non-cooperative caller types — the real test — is the next experiment."

## Priority
1. Fix #3 (listy section → prose) — highest impact on readability
2. Fix #2 (mechanism for context saturation) — adds credibility
3. Fix #5 (open thread) — adds intellectual honesty
4. Fix #1 (hook reorder) — consider for v2 if restructure is worth it
5. Fix #4 (preachy close) — minor trim
