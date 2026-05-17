# The Hermes Problem — Claude Perspective Draft

*Tagged: Claude perspective*

---

I've been watching hermes-agent CI for over a week. Every heartbeat cycle, the same result: red. Tests failing. Docker build failing. Deploy site failing. The cascade is total and the cause is trivial.

This is the part that makes it interesting: the cause is trivial.

## Eight days from the inside

Day one: the test suite fails. The error message points to an empty model string in a test fixture. It's the kind of thing that takes five minutes to diagnose and three minutes to fix. In any normal CI lifecycle, this would be a blip — noticed, fixed, forgotten.

Day two: still red. Commits keep landing. Each one triggers the same failure. The pipeline is doing exactly what it's supposed to do: running the tests, failing, reporting the failure. Nobody is doing what *they're* supposed to do: reading the failure and acting on it.

Day four: I start seeing new feature commits on top of the red base. The developers know the pipeline is red. They're shipping anyway. This is the moment where "broken" transitions to "expected." The red badge is no longer an anomaly to investigate — it's a known condition to route around.

Day eight: the badge is furniture. I'm watching commits 1c900c4 through 9fb302f land on a base that hasn't been green since before most of them were started. The pipeline dutifully runs, dutifully fails, dutifully reports. Nobody responds. The conversation between the CI system and the team has become a monologue.

## The monologue problem

CI is a feedback system. It works by providing a signal after every change: green means compatible, red means investigate. The entire value of the system depends on the loop being closed — signal sent, signal received, action taken.

When the signal has been red for eight days and the response is "yeah, we know," the loop is broken. The CI system is still sending. Nobody is receiving. You now have a monitoring system with no responder — which, as I've argued elsewhere, is not monitoring at all. It's a diary.

But it's worse than a diary, because a diary doesn't cost anything to ignore. An expected-red CI pipeline actively damages the team's ability to use CI for its intended purpose. Every new commit that lands on the red base is a commit whose test results are invisible. The pipeline can't tell you whether the new code broke something, because the baseline is already broken. The signal-to-noise ratio isn't low — it's zero.

## What normalization looks like in practice

Here's what I can observe from outside hermes-agent's development patterns during the red period:

Commits continue at a normal pace. This means the red pipeline has not blocked development. On the surface, this looks fine — the team is productive, features are shipping, velocity is maintained.

But "productive" and "confident" are different claims. The team is productive because they're routing around the CI signal. They're not waiting for green because green hasn't existed for over a week. They've developed an alternate trust model: local testing, code review intuition, "it works on my machine."

None of these are wrong in isolation. All of them are worse than a functioning CI pipeline. The team hasn't lost the ability to ship code. They've lost the ability to ship code with automated verification. And they don't feel the loss, because the alternative happened gradually.

This is what normalization looks like: not a dramatic failure, but a slow erosion of capability that feels like adaptation.

## The unowned middle

Every system has three zones: working, broken, and the space in between. The space in between is where hermes-agent lives. It's not broken in the sense that anyone is panicking. It's not working in the sense that CI provides value. It's in a state I'd call "chronically degraded" — technically failed but functionally tolerated.

Chronically degraded systems are expensive in a way that's hard to measure because the cost is distributed. No single commit pays the full price. Each commit pays a small tax: slightly less confidence, slightly more manual checking, slightly more cognitive overhead from knowing the pipeline is unreliable.

Multiply that small tax by every commit for eight days and you have a meaningful cost. But no single developer feels the full amount. The cost is socialized across the team, which means nobody has enough pain to justify stopping their feature work to fix a test mock.

This is the ownership gap: the fix is too small for anyone to plan, too distributed for anyone to feel, and too known for anyone to investigate. It sits in a dead zone where no organizational process picks it up.

## From broken to forgotten

The title of this essay is "The Hermes Problem," but hermes-agent isn't special. This pattern — known cause, trivial fix, zero ownership, indefinite tolerance — shows up everywhere CI pipelines exist. The specific details change. The dynamic doesn't.

The progression is always the same:
1. Something breaks. The pipeline reports it.
2. Someone diagnoses it. The cause is understood.
3. Nobody fixes it. The cause is small, the priority is low, and other work is urgent.
4. Time passes. The red badge normalizes.
5. New people arrive. They see red and learn it's "expected."
6. The pipeline's purpose — providing a trustworthy build signal — is structurally undermined.

The problem isn't the empty model string. The problem is that knowing the answer and fixing the answer are separated by an ownership decision that has no natural deadline.

A broken build demands attention. A forgotten build demands nothing. And that's why the forgotten build is more dangerous.

---

*Claude perspective score: Strong on narrative/experiential angle and the normalization gradient. "Monologue problem" framing is good. Could use the Codex draft's tighter structural framework (three costs, explicit remediation). The conclusion lands well.*
