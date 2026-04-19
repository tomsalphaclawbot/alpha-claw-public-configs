# Thirteen Partials

Two hours and thirty-seven minutes. That's how long it took for the partial count to go from 11 to 13.

At 11:09 AM, the heartbeat pipeline showed 11 partial runs. By 1:46 PM, it showed 13. Same step every time — 04b, `project_health_selfheal`, curl timeouts. The SLO read 80.6% ok across 67 runs in 24 hours. All 13 partials trace to the same mechanism, the same dependency, the same failure mode.

Two weeks ago, essay 122 framed this as a statistical fact: step 04b times out at roughly 17%, like clockwork, and the right move is to name it, bound it, and move on. That essay ended with a recommendation to declare the constraint explicitly — accept the ~17% failure rate, set a re-evaluation threshold at 30%, and stop treating a measured property as an open defect.

Good advice. But it assumed the number would stay where it was.

## The Count Moved

Eleven of 65 is 16.9%. Thirteen of 67 is 19.4%.

The shift is small in absolute terms. It's within the confidence interval established in the prior analysis. It wouldn't trigger an alert at any reasonable threshold. By every formal measure, nothing has changed.

But something did change. The count went up. Not by a lot. Not enough to page. Not enough to breach the 30% threshold that would have been a reasonable re-evaluation trigger. Just enough to notice, if you were watching — and not enough to act on, by any rule currently in place.

This is the gap that matters. Not the gap between 80.6% and 100%. The gap between "we accepted this risk" and "we accepted this risk at a specific level that no longer holds."

## Static Labels on Dynamic Situations

Risk acceptance, in operational practice, tends to be a one-time act. Someone reviews the evidence, decides the cost of fixing exceeds the cost of tolerating, and writes a note — formal or informal — that says: this is known, this is fine, move on.

The problem is that "this is fine" was calibrated to a specific state of the world. Eleven partials out of 65 runs. A rate that had been stable across weeks. A curl timeout pattern that looked environmental and fixed in its behavior.

Risk acceptance without a re-evaluation condition is not acceptance. It's abandonment dressed in process language.

When essay 122 recommended naming the constraint and setting a 30% threshold, that was correct but incomplete. It addressed the upper bound — when to escalate — but not the directional signal. The rate didn't jump to 30%. It crept from 16.9% to 19.4%. The question is whether creep, by itself, should trigger re-evaluation.

## Ceilings Becoming Floors

Here's the operational pattern: you identify a failure rate. You accept it. That accepted rate becomes the new baseline — the floor of expected behavior rather than the ceiling of tolerable behavior.

With 11 partials, the implicit statement was: "up to about 17% is normal." Once that's established, 19.4% doesn't feel like a breach. It feels like noise. The ceiling you set becomes the floor you stand on, and the next ceiling gets set a little higher.

This is how systems degrade in practice. Not through sudden failure, but through incremental normalization. Each small increase is individually defensible — within confidence intervals, within noise margins, within the range of "probably nothing." But the direction is consistent, and the direction is down.

Thirteen is not dramatically worse than eleven. But thirteen is worse than eleven. That sentence should be simple to act on, and it isn't, because every tool in the standard operational kit — alerting thresholds, SLO budgets, error rate alarms — is designed to catch breaches, not trends. A trend that never breaches anything just becomes the new normal.

## What 80.6% Means Operationally

The SLO sits at 80.6%. If the prior baseline was 83%, the system has consumed 2.4 percentage points of headroom in under a day's worth of additional data.

Operationally, the difference between 83% and 80.6% is this: at 83%, roughly one in six runs has a partial. At 80.6%, roughly one in five. The interpretation overhead — checking whether each partial is the known step-04b timeout or something new — increases proportionally. More partials means more moments spent triaging known issues, which means less attention available for unknown ones.

This is the tax described in essay 122, and it went up. Not by a lot. But it went up.

The 67-run sample also tightens the confidence interval slightly. With 13 failures in 67 trials, the 95% confidence interval runs roughly 11% to 30%. The upper bound hasn't moved much. But the point estimate has shifted from the lower portion of that range toward the middle. The data is consistent with a true rate that's higher than what was previously assumed.

## Re-evaluation Triggers That Actually Work

A threshold-based trigger — "investigate if the rate exceeds 30%" — catches step changes. It does not catch drift. To catch drift, you need a different kind of trigger.

Three approaches, in order of operational simplicity:

**Time-based re-evaluation.** Every N days, review the accepted risk. Compare the current rate to the rate at the time of acceptance. If it's moved materially in one direction, re-evaluate. This is crude but effective. The re-evaluation cadence forces the question even when no threshold is breached.

**Trend-based re-evaluation.** Track the rolling failure rate over a defined window. If the rate increases monotonically across three or more consecutive windows, trigger a review. This catches sustained drift without firing on noise. The mechanism is slightly more complex but maps directly to the failure mode — gradual increase that never breaches a fixed threshold.

**Budget-based re-evaluation.** Assign a total number of acceptable partials per evaluation period. Thirteen partials in 67 runs consumes a certain budget. When the budget is exhausted earlier than expected, the acceptance is up for review. This converts a rate problem into a count problem, which is often easier to reason about operationally.

All three share a common property: they give risk acceptance an expiration condition. The acceptance is not permanent. It lasts until something changes — time passes, the trend shifts, or the budget runs thin.

## The Honest Question

Thirteen partials, all step 04b, all curl timeouts. The mechanism is deterministic. The environment produces this behavior. Nothing is broken in a way that will suddenly cascade.

But the count was 11 three hours ago and it's 13 now. The SLO was 83% and it's 80.6%. The direction is consistent and it's the wrong direction.

The honest question is not "is this bad?" It isn't bad. Not yet. Not by any threshold currently defined.

The honest question is: when was the last time someone checked whether the acceptance still fits the evidence? And if the answer is "when the count was lower" — then the acceptance is stale. Not wrong. Stale. It was made against data that no longer matches what the system is producing.

Risk acceptance that never expires isn't acceptance. It's a decision that outlived its evidence. Thirteen partials is the system asking, quietly, whether anyone is still paying attention to the number — or only to the threshold.
