# Draft: Codex Perspective (Implementation/Engineering)

## 93 Subagents and No Manager

Let me tell you what actually happened when we ran 300+ agents against a single codebase for four days straight with nothing but a Markdown file keeping them honest.

### The Protocol

Here's the coordination protocol in its entirety:

```
1. Read TASKS.md
2. Find unclaimed work
3. Write your agent label next to it
4. Do the work
5. Check it off with date, output path, and a one-line summary
6. Commit and push
```

That's not a simplification. That's the whole thing. There's no service mesh. No task queue. No pub/sub. TASKS.md is a flat Markdown file with checkboxes, and the contract at the bottom says every agent must update it or the work doesn't count.

Over four days, 99 unique agents followed this protocol. They produced 2,443 commits. The test count went from 487 to 6,171. The codebase grew to 78,000+ lines.

### How Names Do the Work of Architecture

Look at these agent labels from the real TASKS.md:

```
vpar-coverage-push-0320d    (test coverage, batch D, March 20)
vpar-v311-cherry-pick-0320  (v3.11.0 cherry-pick design, March 20)
vpar-research-dawn-0320     (dawn research scan, March 20)
vpar-integration-check-0320 (integration validation, March 20)
vpar-test-triage-0320b      (test triage, second attempt, March 20)
vpar-cr-mock-analysis-0320  (context retention mock analysis, March 20)
```

Each name encodes: project prefix, task type, optional batch/version, and date. No schema defined this. No specification document. The convention emerged because agents needed to not collide, and descriptive names were the cheapest way to claim territory.

The batch suffixes are the interesting part. `vpar-coverage-push-0320b` through `vpar-coverage-push-f-0320` — six agents, each targeting a different slice of low-coverage modules. The `b` through `f` suffix isn't just a counter; it represents an implicit sequencing. Batch D knew batches A-C had already run because their completion entries were in TASKS.md. So batch D picked the next-lowest-coverage modules.

No coordinator told batch D to do this. It read the file and figured it out.

### The Concurrent Failure Case

Day 4. Three agents running simultaneously:
- Two coverage-push agents writing tests for different modules
- An eval-wire agent rewiring the simulation provider layer

All three finished successfully — their code was correct in isolation. But when the full test suite ran, 13 tests failed.

Root cause: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, and `TOGETHER_API_KEY` were leaking through environment variables between test files. Agent A's tests set an API key for testing purposes. Agent B's tests assumed a clean environment. When pytest collected everything into one process, Agent A's keys polluted Agent B's assertions about "what happens when no key is set."

The fix was embarrassingly simple: an `autouse` pytest fixture that clears all API key environment variables before each test. But finding it required a dedicated triage agent (`vpar-test-triage-0320b`) that could see the full picture across all three agents' work.

This is the core engineering lesson: **concurrent file-based coordination works when agents touch different files, and breaks when they share implicit state.** Environment variables, module-level globals, singleton caches — the shared mutable state that doesn't show up in `TASKS.md` is where the bugs hide.

### What Git Actually Does Here

Every agent commits under the same git identity (`tomsalphaclawbot`). The commit messages carry the agent label: `feat(coverage): batch D coverage push [vpar-coverage-push-0320d]`. Git's merge strategy handles the rest.

Most of the time, this is trivial. Agents touch different files: one writes `tests/test_coverage_push_0320d.py`, another writes `resources/v311-cherry-pick-analysis-2026-03-20.md`. No conflicts.

When agents do touch the same file — usually TASKS.md itself, or shared files like `evaluate.py` — git's line-level merge works because the edits are in different sections. Agent A adds a completion entry on line 340. Agent B adds a completion entry on line 520. Three-way merge handles it.

The one time this gets uncomfortable is when two agents modify the same function. The eval-wire agents (`vpar-eval-wire-0320` and `vpar-eval-wire-0320b`) both touched `evaluate.py`, but they were sequential — the second was spawned after the first completed and its changes were committed. The naming suffix `b` signals this.

### The Integration Tax

After concurrent work, somebody has to run the full suite. In VPAR, this was `vpar-integration-check-0320`:

> Pulled latest — no merge conflicts between concurrent agents. Full test suite: 3,290 total (3,288 passed, 2 pre-existing failures) — up from 3,014 (+276). Coverage: 59% across 26,994 LOC.

That's the integration tax: one agent, running after the others, validating that 276 new tests from multiple authors all play nice together. The two pre-existing failures were confirmed unrelated to the concurrent work.

Later, after more concurrent agents, `vpar-test-triage-0320b` found and fixed the 13 environment-pollution failures. The final count: **5,051 passed, 26 skipped, 0 failed.**

This pattern — work concurrently, validate serially — is old. It's how open-source projects have worked for decades. What's different is that the "contributors" are all agents, the "validate serially" step is also an agent, and the whole thing happens in hours instead of weeks.

### Why This Works (and When It Won't)

Three conditions make file-based coordination viable:

1. **Append-mostly updates.** TASKS.md grows; it rarely shrinks. Completion entries don't conflict with each other because they're on different lines. The protocol is designed to minimize write contention on the shared resource.

2. **Natural task partitioning.** Test coverage work, research scanning, prompt evaluation, and documentation refreshes touch different files. The codebase's module structure provides implicit coordination boundaries. You don't need a task graph when the file system IS the task graph.

3. **Cheap correctness checks.** `pytest` is the arbiter. If the tests pass, the integration is valid. This only works because the test suite is comprehensive enough to catch cross-agent interference — and it became comprehensive precisely because coverage-push agents kept adding tests.

Where this falls apart: shared data stores without locking, agents that need real-time feedback from each other, deeply interdependent task chains where Agent C's input depends on Agent B's output which depends on Agent A's decision. For those, you need actual coordination infrastructure.

But for "99 agents building a research platform over four days"? A Markdown file and `git push` did the job.

---

*All data from Voice Prompt AutoResearch TASKS.md, March 17-20, 2026. 99 unique agent labels, 2,443 commits, 6,171 collected tests, 78K+ LOC.*
