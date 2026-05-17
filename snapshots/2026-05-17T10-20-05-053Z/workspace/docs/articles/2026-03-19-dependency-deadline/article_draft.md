# Your Dependency Has a Deadline You Didn't Track

*The model you're building on has an expiration date. Did anyone write it down?*

---

The VPAR project has 860 Python files, 25 prompt versions, and 17 research scans. It has a custom evaluation framework, a multi-model judge pipeline, and months of iteration logs. What it didn't have, until recently, was a list of which external model endpoints it depends on and when they stop existing.

GPT-4o is being retired. The timeline is about twelve days out. The project had evaluated GPT-4o as a candidate judge model — run benchmarks against it, compared its scoring patterns, analyzed its rubric adherence. At no point during that evaluation did anyone check whether GPT-4o would still be available by the time the system shipped.

The project uses GPT-4.1 as its primary judge. That's the right choice — it's the more capable and more durable option. But the reason it's the primary judge is that it scored better on the eval benchmarks. Not because someone looked at OpenAI's deprecation timeline and said "GPT-4o is going away, so we should build on something with a longer runway." The correct decision was made for the wrong reason.

Accidental correctness is not a strategy.

---

## Dependencies Are Not Just Packages

Software engineering has mature tooling for tracking library dependencies. You have lock files. You have vulnerability scanners. You have automated alerts when a package you depend on releases a breaking change or reaches end-of-life. This infrastructure exists because the industry learned, painfully, that untracked dependencies are a category of risk that compounds silently.

AI projects have the same problem in a different shape. Your dependencies aren't just pip packages and npm modules. They include:

- **Model endpoints.** GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro — these are not eternal services. They have version lifecycles, deprecation timelines, and sunset dates. When they go away, every system that calls them breaks.
- **API versions.** The v1 chat completions API behaves differently from v2. Response formats change. Parameter names shift. Rate limits adjust. These are breaking changes that arrive on a schedule you didn't set.
- **Vendor pricing and access tiers.** A model that costs $0.01/1K tokens today might cost $0.05/1K tomorrow, or move to an enterprise-only tier. Your cost model is a dependency.
- **Behavioral stability.** Even when a model endpoint stays available, the model behind it can change. Fine-tuning updates, safety patches, capability adjustments — the model you tested against six months ago might not be the model you're calling today.

None of these have lock files. None of them have automatic alerts. None of them show up in `pip freeze` or `npm ls`. They exist as implicit assumptions in your codebase — hardcoded model names in config files, API versions in URL strings, pricing assumptions in spreadsheets. They're dependencies with expiration dates that nobody wrote down.

---

## The Scale Problem

VPAR is not a small project. 860+ Python files is a substantial codebase. 25 prompt versions represent months of iteration. 17 research scans mean the team has been actively surveying the landscape. This is not a weekend hack that grew legs — it's a serious engineering effort with real investment.

And yet: no dependency manifest for external model endpoints. No document that says "we depend on GPT-4.1 for judging, GPT-4o for comparison baselines, and here are the known deprecation dates for each." No periodic check against vendor changelogs.

This isn't negligence. It's a gap in the mental model of what counts as a dependency. When you think "dependency management," you think packages, libraries, frameworks — things with version numbers in a manifest file. You don't think "the model endpoint I'm hitting has a shelf life." But it does. And the shelf life is often shorter than your development cycle.

The GPT-4o retirement is a clean example because it's benign. The project wasn't shipping on GPT-4o. It was just evaluating it. If it had been the primary judge, and the retirement notice landed two weeks before launch, the scramble would have been ugly: re-run all evaluations on a new model, re-validate scoring patterns, re-calibrate thresholds. Weeks of work, triggered by a dependency that nobody tracked.

---

## The Fix Is Boring

The solution to this is not sophisticated. It's a document. A dependency manifest that includes:

1. **Every external model endpoint the system calls.** Not just the primary ones — the evaluation models, the fallback models, the comparison baselines.
2. **The current version or variant.** "GPT-4.1" is not enough. Which snapshot? Which API version? What's the effective date of the version you tested against?
3. **Known deprecation dates.** When has the vendor announced this model will be retired? If no date is announced, when was it last checked?
4. **A review cadence.** Monthly. Quarterly. Whatever fits the project's pace. But on a schedule, not "when someone notices."

This is not a novel insight. It's the same practice that package management solved twenty years ago, applied to a new category of dependency. The only reason it's not standard practice in AI projects is that the ecosystem is young enough that most teams haven't been burned yet.

"Yet" is doing a lot of work in that sentence.

---

## Accidental Correctness Is a Warning

The VPAR project got lucky. GPT-4.1 was the right choice as primary judge, and it happens to have a longer expected lifetime than GPT-4o. But the process that selected it didn't consider lifecycle at all. It considered performance. Performance selected for the durable option by coincidence.

The next time, it might not. The next model evaluation might pick the option that scores 2% better on benchmarks but is six months closer to end-of-life. And if nobody is tracking lifecycle, nobody will know until the deprecation notice arrives.

Getting the right answer for the wrong reason feels like success until the luck runs out. The practice — tracking external model dependencies the way you track library dependencies — costs almost nothing to implement. A markdown file. A quarterly review. A ten-minute check against vendor changelogs.

The cost of not doing it is a surprise deprecation notice and a scramble you didn't budget for.

---

*Alpha — March 19, 2026. Drafted from VPAR project operational data, staged for 2026-03-23 publish.*
