# Draft: The Deprecation Email That Should Have Been a Migration Plan
## Model: Claude role — tone stress-test, rubric sharpening, concrete > abstract

---

You can learn more about a platform from its deprecation notices than from its marketing page. One tells you what they want you to believe. The other tells you what happens when they're done with something you depend on.

On Sunday, a model inference provider sent what it called a "final notice": a specific LLM endpoint would stop responding the next day. The email contained the model name, the date, and nothing else. No replacement recommendation. No migration guide. No documentation link. No explanation of why. No acknowledgment that anyone, anywhere, might have production traffic pointed at that endpoint right now.

This is not unusual. It's becoming the norm. And that's the problem.

## The Deprecation as Artifact

Treat the notice as a document and read it for what it reveals. A deprecation email has to answer a small number of questions. The ones it skips tell you what the sender didn't prioritize.

**What every deprecation notice should answer:**
- What is being removed?
- When?
- Why?
- What replaces it?
- How do I transition?

The email we received answered two of five. Model name: yes. Date: yes. Everything else: absent.

Now, there's a reasonable objection here — maybe this was a "final" notice and earlier emails covered the rest. Maybe there's a docs page somewhere. Maybe they assume their users are sophisticated enough to find alternatives independently. These are fair points, and they're worth considering before concluding that a platform doesn't care.

But here's the test: if a developer who only sees this email — who missed earlier notices, who's on a team where someone else set up the integration — receives it on Sunday evening, can they act? Not scramble. *Act*. With a plan. The answer is no. And "final notice" is exactly when that question matters most, because it's the last chance.

## The Counterexample That Makes the Contrast Obvious

When Stripe deprecates an API version, this is what you get:

- A timeline announcement months in advance
- A dedicated migration guide with before/after code snippets
- A dashboard showing which of *your specific integrations* call the deprecated version
- Deprecation headers in API responses before the cutoff, so your monitoring catches it even if you missed the email
- A clearly named successor version with documented behavioral differences

This isn't because Stripe is generous. It's because Stripe decided that their users' transition is part of their product surface. The migration guide isn't a favor — it's engineering. Someone scoped it, wrote it, tested it, and shipped it alongside the deprecation decision.

You don't need to be Stripe-sized to do this. A two-paragraph email that says "We're removing Model X on [date]. We recommend Model Y as a replacement — it handles similar workloads with [these differences]. Here's a migration note: [link]" would cost the provider an afternoon and save their users days.

The gap between what Stripe does and what most model providers do is not resources. It's priority.

## Is This Too Harsh?

Let me stress-test my own argument. Model providers face real constraints that traditional API companies don't:

**Model rotation is faster.** A REST API version might live for years. A model checkpoint can be superseded in weeks. The sheer velocity of model releases creates deprecation pressure that Stripe never faces.

**Hosting old models costs real money.** Every deprecated model checkpoint sitting on GPUs is compute that could serve a current model. The economic incentive to clean up is stronger and more immediate.

**The ecosystem is young.** Deprecation norms take time to form. Traditional API companies had a decade of painful lessons before they standardized migration guides. Model providers haven't had that decade yet.

All of this is true. None of it changes the core point: the *communication* costs almost nothing. The expensive part is keeping the old model running. The cheap part — naming a replacement, writing two paragraphs of migration guidance, giving more than 24 hours — is where the gap is. You can deprecate aggressively *and* communicate respectfully. Those are independent variables.

## A Deprecation Quality Rubric

Five concrete criteria. Use these the next time you receive a deprecation notice — not to complain, but to calibrate how much trust to place in the platform for your next integration.

**1. Named successor (not "see our docs").**
Does the notice identify a specific replacement? "We recommend Model Y" is a signal that someone thought about your transition. "Check our model catalog" is a redirect, not guidance. *Test: can an engineer reading only this email know what to switch to?*

**2. Migration path with behavioral differences.**
Does it explain what will change? Different context windows, different output formatting, different tool-calling behavior, different pricing — these are the things that break integrations silently. A good notice names at least the top 2-3 differences. *Test: can an engineer estimate their migration effort from this email alone?*

**3. Timeline that respects deployment cycles.**
24 hours is not a deprecation timeline. It's an outage with advance warning. 30 days is a minimum for any production-facing endpoint. 90 days is standard in mature API ecosystems. *Test: does the timeline allow for a team to test, stage, and deploy a replacement in their normal release cadence?*

**4. Explanation of why.**
"This model is being replaced by a more capable successor" tells you something useful. "We're removing this model effective tomorrow" tells you nothing. The *why* helps users make better decisions — not just about this migration, but about how to evaluate future model selections on the same platform. *Test: does the notice help you avoid the same disruption next time?*

**5. Acknowledgment of production impact.**
This is the subtlest signal, but it's the most telling. Does the notice use language that treats you as someone whose workflow is being disrupted? Or does it read like a changelog entry — factual, detached, directed at no one in particular? *Test: does the email read like it was written by someone who imagined a human receiving it at 11 PM on a Sunday?*

## What 0 Out of 5 Means

The notice we received scored zero. That's not a moral judgment — it's a measurement. And measurements are useful precisely because they're not personal.

What a zero tells you: this platform, at this moment, treats model deprecation as a cleanup task, not a user-facing operation. That's a legitimate business choice. But it's information you should have when you're deciding where to run production inference — because the next deprecation email is coming, and it will probably look the same.

Model providers are building the deprecation norms of their industry right now, in real time, one email at a time. The ones who figure out that a migration guide is cheaper than a churned customer will set the standard. The rest will keep sending final notices that read like eviction letters: legally sufficient, operationally useless, and exactly as respectful as they intend to be.

---

_Word count: ~1150_
