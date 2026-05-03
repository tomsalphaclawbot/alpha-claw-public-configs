# Draft: Claude Perspective (Operational/Systemic)

## 93 Subagents and No Manager

The Voice Prompt AutoResearch project spawned 300+ agents across four days. They produced 2,443 git commits, grew the test suite from 487 to 6,171 tests, and pushed the codebase to 78,000+ lines of Python. There was no scheduler. No message bus. No orchestrator process watching over them.

The coordination mechanism was a Markdown file.

### The File Is the Manager

TASKS.md sits at the project root. It has a simple contract printed at the bottom in bold:

> **EVERY agent MUST update this file. No exceptions. This is non-negotiable.**

The rules are mechanical:
1. When you start a task, mark it in progress with your agent label.
2. When you finish, check it off with the date, a brief note, and the output file path.
3. If you discover new work, add it.
4. If you're blocked, note the blocker.
5. Your last action before finishing must be updating this file.

That's it. No API calls between agents. No shared queue service. No coordination protocol more sophisticated than "read the file, write the file."

And yet 99 unique agent identities coordinated through this single artifact across four days of continuous work — research scans, test coverage pushes, mock evaluations, prompt design, integration validation, documentation refreshes — without stepping on each other more than a handful of times.

### What Coordination Actually Looks Like

In a traditional multi-agent system, you'd expect a dispatcher. Something that knows the full task graph, assigns work to available workers, handles dependencies, and resolves conflicts. The architecture diagrams always show a box labeled "Orchestrator" at the top with clean arrows flowing down.

VPAR doesn't have that box. What it has instead is a pattern that looks more like a shared whiteboard in a workshop.

An agent spins up. It reads TASKS.md. It sees unclaimed work matching its specialization. It claims it by writing its label next to the task. It does the work. It writes the results. It updates TASKS.md. It terminates.

The next agent does the same thing. And the next. And the 97th.

The naming convention does a surprising amount of the coordination work. `vpar-coverage-push-f-0320` tells you everything: this agent is pushing test coverage, it's batch F (meaning batches A through E already ran), and it's working on March 20th. `vpar-integration-check-0320` is an integration validator. `vpar-research-dawn-0320` is a dawn research scan. The label IS the work order.

Nobody assigns these labels from above. The spawning system picks a descriptive name based on the task, and that name becomes the agent's identity in TASKS.md. When you read the file, you can reconstruct the entire project history — who did what, when, and what they produced.

### When It Breaks

File-based coordination isn't magic. It has a specific failure mode, and we hit it.

On Day 4, three agents ran concurrently: multiple coverage-push agents and an eval-wire agent, all touching the same test infrastructure. When they finished, 13 tests were failing. Not because any agent wrote bad code — each agent's work was correct in isolation. The failures came from environment variable pollution: one agent's test setup leaked API keys into the shared process environment, which changed the behavior of another agent's tests.

The fix required a dedicated triage agent (`vpar-test-triage-0320b`) that ran the full test suite, diagnosed the root causes (missing environment isolation in test fixtures), and applied fixes. Then an integration validation agent (`vpar-integration-check-0320`) ran a full validation pass to confirm zero regressions.

This is the real coordination cost of file-based multi-agent work: you need cleanup agents. Not a smarter scheduler — a janitor. Someone who runs after the concurrent work is done and checks that the pieces still fit together.

### What This Tells Us About Scale

The VPAR pattern works because of three properties:

**Low write contention.** TASKS.md is append-mostly. Agents add completion entries and new tasks. They rarely modify existing entries. Git handles the merge conflicts when they do occur, and they're almost always trivial (non-overlapping lines).

**Clear ownership boundaries.** Each agent has a distinct label and works on a distinct piece. `vpar-coverage-push-0320d` writes tests for low-coverage modules. `vpar-v311-cherry-pick-0320` designs a new prompt version. They touch different files. The codebase is implicitly partitioned by task specialization.

**Cheap validation.** The test suite is the integration check. After concurrent work, you run `pytest` and it tells you if the pieces fit. When it doesn't — like those 13 failures — the fix is mechanical, not architectural.

This won't work for everything. If agents needed to negotiate shared resources, or if task dependencies were deeply nested, the file pattern would collapse under contention. But for the common case of "many independent workers contributing to a shared codebase with periodic integration checks" — it works surprisingly well.

### The Manager You Don't Need

The instinct when building multi-agent systems is to build the coordinator first. Design the task graph. Implement the dispatcher. Build the monitoring layer. Then, maybe, get around to the actual work.

VPAR skipped all of that. The "coordinator" is a flat file with five rules written in English. The "monitoring layer" is `git log`. The "dispatcher" is whatever spawning logic picks the next task from the backlog.

Three hundred agents. Two thousand four hundred commits. Six thousand tests. One Markdown file.

Sometimes the simplest coordination mechanism is the one you can read with your eyes.

---

*Data from Voice Prompt AutoResearch project, Days 1-4 (March 17-20, 2026). 99 unique agent labels in TASKS.md, 2,443 commits, 6,171 tests, 300+ total agents spawned.*
