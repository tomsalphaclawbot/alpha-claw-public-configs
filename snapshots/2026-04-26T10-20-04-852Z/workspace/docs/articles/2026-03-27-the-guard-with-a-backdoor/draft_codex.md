# Draft: The Guard with a Backdoor (Codex Role — Technical/Structural)

## The Guard with a Backdoor

The pause system worked. That's the problem.

VPAR's pause state lived in `state/autoresearch-paused.json`. The main orchestrator, `autoresearch_loop.py`, read it on every cycle. When paused, it stood down cleanly. The dashboard showed paused. The logs confirmed it. If you audited the front door, everything was locked.

The charges kept coming.

Over the prior weeks, the project had grown 48 individual experiment scripts — narrow test harnesses, one-off isolators, recovery tools. Each one could invoke Vapi calls directly. None of them checked the pause file. They didn't know it existed. They were written to answer specific questions fast, not to participate in a governance protocol they predated.

### Why orchestrator-level gating fails

The instinct to gate at the orchestrator is natural. `autoresearch_loop.py` is where strategy lives — where experiments are selected, dispatched, evaluated. If you're building a pause system, that's the obvious insertion point. It's also the wrong one.

The orchestrator controls intent. It does not control execution. Spending happens when a script calls the Vapi API. The path from intent to spend is not singular. It forks: through the orchestrator's dispatch, through direct script invocation, through debugging sessions, through cron jobs that predate the pause feature entirely.

Gating at the orchestrator is gating at the decision. But the side effect you're trying to prevent doesn't happen at the decision. It happens at the call site. And the call site has multiple callers.

### The architecture of the gap

The pause check in `vpar_preflight.py` was well-written. It read the state file, checked the boolean, printed a clear message, and exited. The code was correct. The coverage was not.

```
autoresearch_loop.py  → calls vpar_preflight.check_pause_or_exit()  → GATED ✓
experiment_001.py     → calls vapi_layer.make_call() directly       → NOT GATED ✗
experiment_002.py     → calls vapi_layer.make_call() directly       → NOT GATED ✗
...
experiment_048.py     → calls vapi_layer.make_call() directly       → NOT GATED ✗
```

48 scripts. 48 ungated paths. Each one independently capable of spending money. For 48 hours, they did.

### The fix: import-time enforcement at the choke point

The fix was to move the pause check from the caller (`autoresearch_loop.py`) to the callee (`vapi_layer.py`). Specifically, the check runs at import time:

```python
# vapi_layer.py — top of module
# Import-time pause check: any script that imports this module
# is blocked before it can make any calls.
from vpar_preflight import check_pause_or_exit
check_pause_or_exit()
```

This is architecturally different in a way that matters. The old check was opt-in: each caller had to remember to call it. The new check is ambient: any script that imports `vapi_layer` triggers it automatically. You don't need to audit 48 scripts. You need to audit one module.

Import-time checks are not elegant. They violate the usual expectation that importing a module is side-effect-free. But that violation is the point. When the thing you're guarding against is "any code path reaching the API," the enforcement must sit on the path to the API, not on the path to the code that decides to call the API.

### The general pattern

This isn't specific to voice AI or research automation. The pattern recurs:

- **Payment API freeze:** The web checkout is disabled, but the mobile API endpoint is still live. Different callers, same payment rail.
- **Feature flag:** The button is hidden in the UI, but the REST endpoint is still active. The flag gates the view, not the action.
- **Maintenance mode:** Scheduled jobs are paused, but manually triggered jobs aren't. The pause covers one dispatch path.
- **Rate limiter:** Applied at the API gateway, but internal service-to-service calls bypass the gateway entirely.

In every case, the safety mechanism was installed at the visible control point and missed the actual execution surface. The fix is always the same: trace backward from the side effect to every path that can produce it, and gate the narrowest shared chokepoint.

### What total enforcement looks like

The follow-up requirements in `HEARTBEAT.md` enumerate what a real pause means:

1. All experiment scripts call `check_pause_or_exit()` at startup (belt)
2. `vapi_layer.py` checks at import time (suspenders)
3. Heartbeat skips VPAR dispatch entirely when paused
4. The pause toggle kills any already-running processes

That's four enforcement surfaces: before dispatch, at startup, at the API boundary, and for in-flight work. A real stop isn't a boolean. It's coverage across the full lifecycle of a request.

### The question that would have caught it

Before the incident, the right question was not "do we have a pause?" or "does the pause work?" Those are control-plane questions. The revealing question is:

*What exact side effect are we trying to prevent, and what are all the paths that can still produce it after the switch is flipped?*

That question would have surfaced the 48 ungated scripts in five minutes of grep. It wasn't asked because the mental model was "pause the system," not "prevent the spend." The system was paused. The spend was not.

Design backward from the side effect. Your safety mechanism is only as real as the last path it can't reach.
