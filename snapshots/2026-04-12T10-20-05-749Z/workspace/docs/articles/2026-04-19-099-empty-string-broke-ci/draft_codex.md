# Draft: Codex Voice

## The Empty String That Broke CI

### The Incident

On March 27, 2026, CI on the hermes-agent repo went red. The failing test: `test_codex_execution_paths`. The error message: `'model' must be a non-empty string`. It stayed red for four days.

The test existed to verify auth refresh behavior in the Codex provider. It was not testing model selection. It was not testing input validation. It was testing whether, given a token expiry scenario, the provider would correctly re-authenticate before retrying. The test mock passed `model=""` because the test author did not care about the model parameter -- it was not the axis under test.

But the Codex provider validates `model` as non-empty at intake, before it reaches the auth logic. The empty string tripped a guard that fires early in the call path. The test never reached the code it was designed to exercise.

### Taxonomy: Fixture Gaps vs. Coverage Gaps

These are different failure modes and they demand different responses.

**Coverage gap**: You have no test for behavior X. The fix is to write one.

**Fixture gap**: You have a test for behavior X, but the fixture that sets up the test makes an unstated assumption about parameter Y. The fix is not more tests. The fix is more precise fixtures.

The `test_codex_execution_paths` test had full coverage intent for auth refresh. Its fixture was under-specified: it supplied an empty model string because the test author treated `model` as irrelevant to the behavior under test. That assumption was wrong -- not because model selection matters to auth refresh, but because model validation runs first.

This distinction matters because teams that track coverage metrics will look at this failure and see a test that exists, covers the right code path in theory, but fails. Coverage tooling says "you have a test here." The test says "I'm broken." The gap is invisible to coverage analysis.

### Why the Error Message Misdirected

The error `'model' must be a non-empty string` is technically accurate. The model field was an empty string. The guard correctly rejected it.

But in context, this message is semantically misleading. When you read a CI failure on `test_codex_execution_paths` and see an error about model validation, your first instinct is: "something changed in model validation logic." You go look at recent commits touching model handling. You check whether a new model was added, whether a config changed, whether validation rules tightened.

None of that is the problem. The problem is that the fixture never supplied a valid model in the first place, and something changed in execution order or guard placement that made this latent defect manifest.

This is a category of debugging misdirection I'd call **accurate-but-contextually-misleading errors**. The message tells you what went wrong mechanically. It does not tell you why, in the context of this test, it went wrong. The mechanical truth obscures the structural truth.

### Decision Framework: Fixture Specificity

When writing a test for behavior X, every parameter you supply in the fixture is either:

1. **Axis under test**: the parameter whose variation you're testing. For auth refresh, this is the token state.
2. **Required context**: parameters that must be valid for execution to reach the axis under test. Model is required context here.
3. **Irrelevant context**: parameters that genuinely do not affect the code path. These can be defaults or omitted.

The mistake is classifying a parameter as irrelevant when it is actually required context. The test author thought: "I'm testing auth, model doesn't matter." But model validation gates the entire call. Model is required context.

**Rule**: If a parameter is validated before your axis-under-test code is reached, it is required context, not irrelevant context. Supply a valid value.

**Practical check**: Run your test with every non-axis parameter set to an obviously invalid value (empty string, null, -1). If the test still exercises the code path you care about, those parameters are truly irrelevant. If it fails before reaching your target code, those parameters are required context and need valid fixture values.

### Why Four Days

The four-day timeline is the real cost. Not the bug itself -- that's a one-line fix (supply a valid model string in the fixture). The cost is the investigation time multiplied across everyone who looked at CI, saw red, and either:

- Spent time investigating the wrong layer (model validation changes)
- Assumed someone else was handling it
- Worked around it by skipping CI checks

Four days of red CI on main normalizes failure. It trains the team to ignore red builds. That cultural cost compounds long after the fix lands.

PR #3887 was opened upstream to address this. PR #3901 merged but was unrelated. The gap between "CI is red" and "the right PR exists" was the investigation tax -- paid because the error pointed at the wrong layer.

### Takeaways

1. **Classify every fixture parameter** as axis-under-test, required context, or irrelevant context. Validate the classification by breaking each one.
2. **Error messages that are mechanically accurate can be structurally misleading.** When debugging test failures, ask: "Is this error about the behavior under test, or about fixture setup?"
3. **Under-specified fixtures are latent defects.** They pass until execution order changes, guard placement shifts, or validation tightens. They are time bombs with misleading detonation messages.
4. **Red CI on main is a cultural signal, not just a technical one.** Every day it stays red erodes the team's trust in the build system. Fix or revert fast.
