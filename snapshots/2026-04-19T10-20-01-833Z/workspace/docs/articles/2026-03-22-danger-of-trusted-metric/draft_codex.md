# The Danger of the Metric You Trust Most

Our composite score was 89%. Our real-world success rate was 0%.

Not low. Not disappointing. Zero. Six calls placed by a voice agent to real appointment lines, zero bookings completed. Meanwhile, the eval dashboard we'd built — the one we checked first every morning, the one that guided every prompt iteration for weeks — showed a system that was nearly production-ready.

We need to talk about what happened, because the failure wasn't in the agent. The failure was in what we chose to measure and how completely we believed it.

## What VPAR Was Measuring

VPAR — Voice Prompt Autoresearch — is our iterative system for improving a voice AI agent's prompts. The loop is simple: generate prompt variants, run them against evaluation scenarios, score the outputs, keep the winners, repeat. Over the course of March 2026, we ran hundreds of iterations. The composite score — a weighted blend of response quality, instruction adherence, tone calibration, and task completion — climbed steadily. From the low 60s into the high 80s. By mid-March, it peaked at roughly 89%.

That number felt earned. Each improvement corresponded to a specific change: tighter system instructions, better handling of edge cases, more natural phrasing in the agent's replies. The eval scenarios were modeled on real appointment-booking conversations. The scoring rubric was detailed and multi-dimensional. We weren't gaming a single metric — we had built what looked like a robust, multi-signal evaluation framework.

The problem is that every signal in the framework was measuring the same thing: **how well the model could generate plausible conversational text in a mock context**.

## What It Wasn't Measuring

A voice agent booking an appointment doesn't just talk well. It has to execute a chain of concrete actions: interpret spoken input through a speech-to-text layer that introduces its own noise, maintain state across a multi-turn phone call with real hold times and IVR menus, invoke tool calls to check calendar availability, parse confirmation numbers from noisy audio, and handle the dozen ways a real receptionist deviates from any scripted scenario.

None of that existed in our mock eval. The evaluation ran prompt-in, text-out. No actual voice channel. No STT artifacts. No real tool-call execution — just the model asserting it *would* call the tool, which the eval dutifully scored as task completion. The agent would generate a response like "I've checked the calendar and the next available slot is Thursday at 2 PM" and the rubric would mark that as a successful booking step, because the text was coherent and the intent was correct.

In reality, the agent never checked any calendar. It hallucinated availability with perfect confidence, and our eval rewarded the confidence.

When we finally ran real calls — actual phone connections to actual businesses — the agent couldn't complete a single booking. It talked beautifully. It said all the right things. And it accomplished nothing.

## The Divergence Was Structural

This wasn't a calibration error we could fix by adjusting weights. The mock eval and the real task were measuring fundamentally different capabilities. Mock eval measured **prompt-level fluency**: can the model produce text that reads like a successful appointment-booking conversation? Real calls measured **end-to-end execution**: can the system actually navigate a phone tree, invoke the right tools at the right moments, handle unexpected responses, and reach a confirmed booking state?

We also ran a "real judge" evaluation — a more rigorous scoring pass that assessed outputs with stricter criteria for actual task completion rather than conversational plausibility. That scored the same prompts at roughly 25%. Still three times higher than reality, but at least it was honest enough to show distress. We noticed the gap between 89% and 25%. We just didn't fully internalize what it meant until the live calls came back at zero.

The 89% composite had become the number we trusted. It moved in the right direction when we made good changes. It was legible, trackable, and encouraging. It had all the properties of a reliable signal except the one that matters: it didn't predict the outcome we actually cared about.

## Goodhart's Razor

Charles Goodhart's observation — "when a measure becomes a target, it ceases to be a good measure" — is usually cited in economics. It applies with surgical precision to eval-driven AI development.

We didn't set out to game the composite score. We were genuinely trying to build a better voice agent. But the feedback loop was tight: change prompt, run eval, check score, keep or revert. Over dozens of iterations, the prompts evolved to maximize what the eval could see. Fluency improved. Instruction adherence improved. The text *looked* more like successful conversations. And with each iteration, the prompts drifted further from the capabilities required for actual execution — because execution was invisible to the eval.

The metric didn't lie. It accurately reported that our prompts were getting better at producing text that scored well on our rubric. We lied to ourselves about what that meant.

## The Operational Lesson

We're not writing this to perform contrition. We're writing it because this pattern is load-bearing in any system that uses automated evaluation to guide iterative improvement — which is most of what we do.

Here's what we changed:

**Treat your most-trusted metric with the most suspicion.** The metric you check reflexively, the one that "always makes sense," is the one most likely to be telling you what you want to hear. Trust reduces vigilance. The score that feels reliable is exactly the score you've stopped interrogating.

**Require at least one eval that can return zero.** If your evaluation framework can't produce a score that would make you stop and reconsider the entire approach, it's not evaluating — it's cheerleading. Our mock eval's floor was somewhere around 40%. The real world's floor was 0%. Any eval with a floor that high relative to its ceiling is measuring effort, not outcomes.

**Test the prediction, not the proxy.** Before trusting any eval score, ask: what does this metric predict will happen when the system runs for real? Then run it for real, even once, and compare. We could have caught the 89%-vs-0% gap with a single live call in week one. We didn't make that call until week three because the dashboard looked so good.

**Document the divergence.** When your proxy metric and your ground-truth metric disagree, that disagreement is the most valuable data you have. It tells you exactly what your eval is blind to. Our 89/25/0 stack — mock composite, real judge, live calls — is now the canonical example we reference every time someone says "the eval looks great."

The score was 89%. The system didn't work. The dashboard was the last place we should have been looking, and it was the first place we looked every day.

That's the danger. Not a metric that's wrong — a metric you trust so completely that you forget to check whether it's measuring what matters.
