# Brief — 052: When the Prompt Contradicts Itself

## Topic
Self-undermining instructions in LLM system prompts: when a prompt tells the model to always use tools but also hardcodes static answers, or when accumulated optimizer comments create contradictory directives.

## Thesis
Prompt contradictions are not edge cases — they're a structural failure class that emerges naturally from iterative optimization. The fix isn't just "proofread better"; it requires systematic detection, CI guards, and architectural separation of concerns.

## Audience
Engineers and operators working with LLM system prompts, especially those running automated optimization loops (GEPA, DSPy, APO) or managing prompts that evolve over time.

## Tone
Honest, grounded, operational. Concrete examples from real work. Not philosophy.

## Evidence Anchor: VPAR Baseline Drift + Contradiction Detection (REQUIRED)

### 1. Baseline Drift Audit (resources/baseline-drift-audit-0320.md)
- Working copy was stuck at v3.7.0 while production was v3.9.0
- **91.3% noise by token count** — 430 GEPA/mock optimizer comment lines polluting the prompt
- Comments like `# [GEPA candidate 0: structural_reorg → turn_taking_compliance]` and `# [mock PIVOT strategy=addition targeting conciseness]` mixed into live instructions
- 3 unresolved git conflict markers (`<<<<<<`, `=======`, `>>>>>>>`) in the prompt
- INTERRUPT section was broken — only had orphaned fragment "3. Never complete old request"
- first_response_speed: -18.8pp vs production v3.9.0; tts_friendliness: -14.4pp vs v3.9.0

### 2. Mock Scorer Contradiction Detection (TASKS.md — Mock Scorer Contradiction Extension)
- Extended contradiction detection from 3 criteria to 10
- Found prompts that said "always use tools" but also had pre-baked answer patterns
- retry_on_interrupt scores dropped from 0.97 to 0.58 when contradictions detected
- response_latency scores dropped from 0.81 to 0.49 with contradictions
- Pattern: keyword-stuffed prompts that claim compliance while containing contradictory instructions

### 3. Working Copy Cleanup (TASKS.md — Working Copy Reset)
- v3.7.0 content with GEPA comments had internal contradictions
- ZERO shop knowledge directive + accumulated answer patterns = contradiction
- Reset to v3.9.0 eliminated 91.3% noise, restored production-quality prompt
- CI guard added: `scripts/prompt_comment_guard.py` — fails build if >10% comment ratio

## What would this change about how someone works or thinks?
- They'd add contradiction detection to their eval pipeline, not just correctness checks
- They'd treat prompt hygiene as a CI concern, not a manual review step
- They'd recognize that optimization loops are contradiction factories by default
- They'd design prompt architectures (layered, modal) that structurally prevent certain contradiction classes
