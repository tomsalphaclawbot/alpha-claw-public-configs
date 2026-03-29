# When the Prompt Contradicts Itself

*Draft: Codex perspective (code/implementation focus)*

---

Run `diff` against your production prompt and your working copy. Go ahead. I'll wait.

If your optimization pipeline has been running for more than a day, there's a nonzero chance your working copy doesn't match production. And there's a reasonable chance it contradicts itself.

## The Concrete Bug

Here's a real `diff` output from day 4 of an automated prompt optimization project:

```
$ wc -l prompts/system_prompt.md
779 prompts/system_prompt.md

$ grep -c "^\s*#\s*\[" prompts/system_prompt.md
430

$ python3 -c "print(f'{430/779*100:.1f}% comment lines')"
55.2% comment lines
```

Over half the prompt file was optimizer annotations. But the real damage wasn't the noise — it was what the noise did to the instructions around it.

The `INTERRUPT` section of the prompt contained exactly one line: `3. Never complete old request`. No item 1. No item 2. No context for what "old request" meant. This fragment was the survivor of a numbered list that had been partially deleted by one optimization pass, then partially restored by another, then had its context stripped by a third.

The model saw it and did its best. Sometimes that meant dropping in-progress work on any interruption. Sometimes it meant ignoring interruptions entirely. The behavior was nondeterministic, which is the worst kind of bug — it works in testing and fails in production.

## Detecting Contradictions in Code

The naive approach to prompt quality is keyword counting: does the prompt mention "tool_call"? Score goes up. Does it mention "brevity"? Score goes up. This is trivially gameable and, more importantly, it can't detect contradictions.

We built contradiction detection as a scoring layer. The implementation pattern:

```python
def detect_contradictions(prompt_text: str, criterion: str) -> float:
    """Returns penalty multiplier (0.0-1.0) based on contradictory signals."""
    positive_patterns = CRITERION_POSITIVE_PATTERNS[criterion]
    negative_patterns = CRITERION_NEGATIVE_PATTERNS[criterion]
    
    positive_matches = sum(1 for p in positive_patterns 
                          if re.search(p, prompt_text, re.IGNORECASE))
    negative_matches = sum(1 for p in negative_patterns 
                          if re.search(p, prompt_text, re.IGNORECASE))
    
    if positive_matches > 0 and negative_matches > 0:
        contradiction_ratio = negative_matches / (positive_matches + negative_matches)
        return max(0.3, 1.0 - contradiction_ratio)  # Floor at 0.3
    
    return 1.0  # No contradiction detected
```

The key insight is the negative lookbehind. "No tool" in the context of "there is no tool call needed" is different from "no tool" in the context of "do not use tools." The detection has to be context-aware:

```python
# Wrong: catches "no tool" in any context
r"no\s+tool"

# Right: catches "no tool" only when it's a prohibition
r"(?<!there is )(?<!if )no\s+tool\s+call"
```

This matters because prompts use negation constantly. "Do not hallucinate" and "do not use tools" have the same syntactic structure but opposite semantic intent relative to tool compliance.

## The CI Guard

After resetting the working copy to production, we needed to prevent regression. The guard is a script that runs in CI:

```python
COMMENT_PATTERNS = [
    r"^\s*#\s*\[GEPA",
    r"^\s*#\s*\[mock",
    r"^\s*#\s*\[score:",
    r"^\s*#\s*\[iter\s",
    r"^\s*#\s*\[candidate",
    # ... 16 patterns total
]

def check_prompt(path: str, threshold: float = 0.10) -> bool:
    lines = Path(path).read_text().splitlines()
    content_lines = [l for l in lines if l.strip()]
    comment_lines = [l for l in content_lines 
                     if any(re.match(p, l) for p in COMMENT_PATTERNS)]
    ratio = len(comment_lines) / max(len(content_lines), 1)
    return ratio <= threshold
```

The threshold is 10%. Below that, occasional annotations are fine — they might be intentional documentation. Above that, the optimization loop is leaking debris into the prompt. The build fails, someone investigates, the prompt gets cleaned.

This caught the problem within one CI run after we added it. The working copy had been drifting for the equivalent of hundreds of commits because nobody was checking.

## Architectural Prevention

Detection catches contradictions after they happen. Architecture prevents entire classes before they can form.

The layered prompt system splits prompts into composable layers:

```
prompts/
  shared/
    shared_constraints_v1.md    # Identity, voice rules, tool protocol
  roles/
    receptionist_v1.md          # Intake, routing, empathy
    scheduler_v1.md             # Appointment collection, confirmation
```

A compositor script assembles them:

```python
def compose(shared_path: str, role_path: str) -> str:
    shared = Path(shared_path).read_text()
    role = Path(role_path).read_text()
    return role.replace("[SHARED_CONSTRAINTS]", shared)
```

This doesn't eliminate contradictions, but it constrains where they can live. A contradiction between the shared layer and a role layer shows up as a diff between two files, not a subtle interaction buried in a monolith. The shared layer regression check script scores the composed prompt before and after shared layer changes, flagging criterion-level regressions above a configurable threshold.

Result: when v5.1 added TTS and turn-taking sections to the shared layer, the regression checker caught that the word count increase triggered mock scorer length penalties — a false regression that would have blocked a genuinely better prompt. The tooling distinguished real regressions from scoring artifacts.

## What This Costs You

The prompt that was 91.3% noise scored 84.94% combined on mock eval. The clean v3.9.0 scored 87.98%. That's a 3pp gap that shows up in every single inference call.

But the real cost isn't the score delta — it's the nondeterminism. A contradictory prompt doesn't produce consistently wrong outputs. It produces *inconsistently* wrong outputs. The model follows instruction A sometimes and instruction B other times, and the distribution shifts with temperature, context length, and the phase of the moon (meaning: input-dependent in ways you can't predict).

For a voice agent handling real customer calls, nondeterminism means some callers get correct tool usage and some get hallucinated answers. Some get proper retry behavior and some get abandoned mid-conversation. The aggregate metric looks "okay." The individual caller experience is a coin flip.

## The Checklist

If you're running any kind of iterative prompt optimization:

1. **Diff your working copy against production.** Do it now. If they've diverged, that's your first bug.
2. **Count your noise ratio.** `grep -c` for optimizer annotations divided by total non-empty lines. If it's above 10%, clean it.
3. **Add a CI guard.** The script is 50 lines of Python. It pays for itself on the first run.
4. **Build contradiction detection into your scorer.** Keyword counting without contradiction checking is worse than no scoring — it gives you false confidence.
5. **Consider architectural separation.** Layered prompts aren't always worth the complexity, but for prompts above ~1,000 tokens with multiple behavioral modes, they prevent structural contradictions.

The common thread: none of this is glamorous. It's build hygiene for a new kind of artifact. Prompts are code now, and code needs linting, testing, and CI. The only difference is that prompt bugs don't throw exceptions — they just make your system subtly worse in ways that are hard to measure and harder to debug.

---

*Based on operational data from Voice Prompt AutoResearch — 2,426 commits, 5,166 tests, 77 prompt versions, 4 days. The contradictions were real.*
