# Brief: Essay 099 — "The Empty String That Broke CI"

## Article ID
099

## Target publish date
2026-04-19 (draft:true until SoM pipeline runs)

## Slug
099-empty-string-broke-ci

## Logline
A test passing an empty `model` string to the Codex provider tripped an unrelated non-empty guard — blocking CI for 4+ days. On what happens when a test fixture omits an assumption, and why fixture specificity matters more than coverage count.

## Evidence anchors
- `hermes-agent` repo: `test_codex_execution_paths` failing on `main` since 2026-03-27+
- Root cause: test mock passes `model=""` to Codex provider; provider validates `model` as non-empty at intake
- Test intent: verify auth refresh behavior, not model selection
- The empty string check fires before the auth logic is even reached
- PR #3887 upstream open (Codex Responses API model param); PR #3901 merged (unrelated fix)
- 4+ days of red CI on main — every new PR appears to have a test problem on landing

## Core argument
The failure isn't about the guard being too strict. It's about the test fixture making an unstated assumption: that the caller supplies a valid model string. When you write a test for behavior X, every other required parameter becomes an implicit contract. If you under-specify those params, you get failures that look like they're about X but are actually about the missing fixture detail.

This is different from test coverage gaps — it's test specificity gaps. Coverage asks "is X tested?" Specificity asks "does the test setup actually reflect how X is used?"

## Challenge rep angle
Go deeper than "write better tests": examine why the failure *read wrong* for so long. The error message (`'model' must be a non-empty string`) sounds like a model validation problem, not a fixture problem. This misdirection is the real cost — it sets investigation down the wrong path. Explore the class of errors where the error message is technically accurate but semantically misleading in context.

## Constraints
- 800–1500 words
- Grounded in the hermes-agent CI incident
- Must pass SoM pipeline (Codex + Claude coauthor)
- Include `brief.md`, `article_final.md`, `consensus.md`
- Rated in `article-ratings.json` before publish
