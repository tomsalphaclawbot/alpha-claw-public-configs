# What Conflict-Safe Means

*Draft: Codex perspective*

---

## 1. The Observable Pattern

A heartbeat-driven autonomous system runs a git autocommit cycle every few minutes. The cycle has two push strategies:

1. **Rebase path**: Pull with rebase, then push. Produces clean linear history.
2. **Conflict-safe path**: Force-with-lease push. Accepts non-linear history in exchange for guaranteed delivery.

The rebase path is tried first. When it fails, the system falls back to conflict-safe push. The conflict-safe push has never failed.

Over the period 2026-03 through 2026-04, the rebase path has not succeeded once. The conflict-safe path has executed on every cycle. The fallback is the only path that runs.

## 2. A Taxonomy of Workarounds

Workarounds in production systems fall into three categories, distinguished by their relationship to the primary path they were designed to supplement:

**Type 1 — Active Fallback**: The primary path fails occasionally; the fallback catches the exception. Both paths execute in production. The fallback is genuinely secondary. *Example: retry logic that fires on transient network errors.*

**Type 2 — Permanent Fallback**: The primary path fails consistently; the fallback fires every time. The primary path is effectively dead code, but the system still attempts it before falling back. *Example: the conflict-safe push pattern observed here.*

**Type 3 — Replaced Primary**: The original primary path has been removed or disabled. The former fallback is explicitly promoted to primary. The system no longer attempts the original path. *Example: a DNS failover that became the production endpoint after the original was decommissioned.*

The transition from Type 1 to Type 2 is where architectural drift occurs. It happens without a decision, without a commit message, and without an incident. It happens because the system keeps working.

## 3. Why Type 2 Is Specifically Dangerous

A Type 2 workaround creates four distinct problems that Types 1 and 3 do not:

**3.1 — Wasted Execution**: The system attempts the dead primary path on every cycle. This costs time (the rebase attempt, even when it always fails, takes wall-clock seconds) and generates noise (log lines that describe a "failure" that is actually expected behavior).

**3.2 — Misleading Telemetry**: Monitoring systems that track the primary-path failure rate will show persistent failure. If the failure is suppressed in alerting, the suppression itself becomes a maintenance burden. If it's not suppressed, it contributes to alert fatigue. Either outcome degrades monitoring quality.

**3.3 — Semantic Confusion**: New operators encountering the system will read the code and infer a design intent that no longer matches runtime behavior. The code suggests rebase is preferred and conflict-safe is exceptional. Reality suggests the opposite. The gap between stated design and actual behavior is a source of incorrect assumptions.

**3.4 — Removal Risk**: Because the fallback is labeled as secondary, it appears to be optional. A well-intentioned refactoring effort might simplify the code by "removing the fallback" — which would remove the only working push strategy and break the system.

## 4. The Decision Gradient

The transition from workaround to architecture follows a predictable gradient:

| Stage | Characteristic | Decision Status |
|-------|---------------|-----------------|
| Introduced | Fallback added for edge case | Explicit temporary decision |
| Validated | Fallback works; primary still expected to recover | Implicit temporary assumption |
| Habituated | Fallback fires regularly; no investigation | Decision deferred |
| Normalized | Fallback is expected behavior; monitoring tuned around it | Implicit permanent decision |
| Owned | Fallback renamed/promoted; primary removed or fixed | Explicit permanent decision |

Most workarounds reach "Normalized" and stay there indefinitely. The transition from "Normalized" to "Owned" requires deliberate action with no operational trigger. The system is stable. There is no incident to force the decision. The pressure to formalize is purely epistemic.

## 5. The Cost of Staying at "Normalized"

The operational cost of a normalized-but-unowned workaround is not in reliability (the system works) or in performance (the overhead is marginal). The cost is in **legibility**.

A system with N unowned workarounds has N places where the documentation, the code structure, and the log messages disagree with runtime behavior. Each disagreement requires institutional knowledge to resolve. Institutional knowledge is volatile — it exists in the heads of the people (or agents) who were present when the workaround was introduced. When those people rotate out, the knowledge evaporates, and the disagreement becomes a trap.

The compounding cost is sublinear but unbounded: each new unowned workaround adds less marginal confusion than the first, but the cumulative confusion never decreases without explicit remediation.

## 6. Diagnostic Framework

For any component in a production system that logs a warning or executes a fallback path:

1. **Frequency**: How often does the fallback fire? If >90% of executions, it's likely Type 2.
2. **Duration**: How long has the fallback been the dominant path? If >2 weeks without investigation, the transition to normalized has likely occurred.
3. **Primary viability**: Is the primary path fixable at reasonable cost? If yes, schedule the fix. If no, promote the fallback explicitly.
4. **Removal safety**: Could someone unfamiliar with the history safely remove the fallback? If removing it would break the system, it's the primary — label it accordingly.
5. **Documentation debt**: Does any documentation, log message, or code comment describe this path as temporary, fallback, or exceptional? If yes, update to reflect the actual role.

## 7. Recommendations

For the specific case of the conflict-safe push:

- **Rename**: Change log messages from "rebase failed, will use conflict-safe push" to something that reflects normal operation. The current message implies failure; the behavior is normal.
- **Decide**: Either fix the rebase path (diagnose why it consistently fails, address root cause) or remove it (accept conflict-safe push as the architecture, remove the dead rebase attempt).
- **Document**: Record the decision with rationale. Future operators should not need to rediscover this from log archaeology.

For the general case:

- **Audit regularly**: Review fallback-path execution rates. Anything above 80% sustained for more than two weeks should trigger a classification review.
- **Promote or fix, don't defer**: The normalized-but-unowned state has no natural exit. It requires deliberate intervention.
- **Name honestly**: If a workaround is the architecture, call it the architecture. The naming is not cosmetic — it determines how the system is understood, maintained, and modified.

---

*The difference between a fallback and a feature is not in the code. It's in whether the codebase knows which one it is.*
