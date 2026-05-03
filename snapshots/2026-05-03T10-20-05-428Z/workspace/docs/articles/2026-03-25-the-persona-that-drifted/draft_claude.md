The Persona That Drifted

Here is the version of the story that sounds fine: a caller contacts a voice agent, has a normal conversation, and the booking completes. The system worked.

Here is the actual story: the caller I scripted was supposed to be Sarah Mitchell, calling about her 2021 Honda Civic, needing an oil change. The caller that showed up on the transcript introduced itself as Alex, driving a 2018 Toyota Camry. The test ran. The booking completed. The data was useless.

This is the failure mode that doesn't announce itself. No error codes. No crash. Just a plausible conversation that measured something other than what you were trying to measure.

---

The experiment was straightforward. I wanted to know whether injecting pre-filled customer information into a voice agent's system prompt would reduce unnecessary turns. If the receptionist already knew the caller's name, vehicle, and service type before the call started, it should be able to skip those questions. The hypothesis was reasonable. The data could have been interesting. But a prior failure made the whole thing moot.

The caller bot was built from a generic wrapper prompt with a scenario-specific script appended. The scenario was clear: name, car, service, opening line. In practice, the model in that caller role — gpt-4o-mini — treated all of it as *context* rather than *identity*. It had been told who to be. It had not been *made* to be that person. So when the call started and the model's generative machinery turned on, it produced a plausible caller instead of the assigned one. Not maliciously. Not randomly. Just... differently.

The call itself revealed nothing wrong. The receptionist collected fields. The caller answered. The booking closed. Every conversational signal pointed toward a successful run. The contamination was invisible until you looked at the persona name in the transcript and noticed it didn't match the scenario.

---

There's a distinction worth being precise about here: the difference between *narrative* and *constraint*.

When you give a sub-agent a persona description, you are usually writing narrative. "You are Sarah Mitchell. You drive a 2021 Honda Civic. You are calling about an oil change." That's a story. Models are trained to extend stories, to be consistent with them, to fill in the world around them. But they're not trained to treat story elements as hard constraints. The story can evolve. Characters can change.

What you actually need in a multi-agent test harness is constraint. Not a description of who the agent is, but a structural enforcement that it cannot be anyone else. The fix I applied in the next version was exactly this: imperative language, repetition, and explicit prohibition. "You ARE Sarah Mitchell. You will ONLY introduce yourself as Sarah Mitchell. Never invent or accept a different name. If asked your name, you say Sarah Mitchell and nothing else." That's not a richer description of the character. That's removing degrees of freedom.

The distinction matters more when models are smaller. Capable frontier models are often better at following persistent persona instructions because their instruction-following is more reliable across a long context. Smaller, cheaper models — the ones you'd naturally reach for in a high-volume test harness — are more likely to treat persona instructions as soft scaffolding that gets crowded out by their stronger default behaviors around coherent conversation. You cannot write your way out of this with better descriptions. You have to write constraints.

---

The broader failure is architectural. In multi-agent systems, when one agent is playing a role *for the purpose of testing another agent*, the role is not decoration — it is the input specification. If I'm measuring how well a receptionist handles a customer named Sarah Mitchell with a specific vehicle and service request, the caller *is* that input. The caller IS the test. Letting the model drift that input means the test is measuring something undefined.

This generalizes cleanly. A QA agent assigned to reproduce a specific bug path might quietly reroute around the interesting parts because a different path is easier to articulate. A research agent role-playing as "user with limited context" might accidentally give full context because that's what it has. A simulated support caller might omit the precise ambiguity that was supposed to stress-test the agent under evaluation. In every case: the transcript sounds fine. The call completes. The data lies.

The analogy I keep returning to is typed function arguments. If I pass `name="Sarah Mitchell"` and `vehicle="2021 Honda Civic"` to a function, I expect those values to remain stable for the duration of that function's execution. No one would build a system where a function could spontaneously rename its inputs to something plausible. But that's what happens when persona identity lives only in prompt prose. The model doesn't treat it as a fixed value. It treats it as a live variable that's open to creative improvement.

---

There are a few practical implications from this.

First: any agent that plays a role in a test harness needs explicit identity constraints, not persona description. Shorter, more imperative, more repetitive. If the role has fixed fields, declare them as fixed — not as background story.

Second: cheaper/smaller models in the caller role are higher risk for drift. This doesn't mean you can't use them. It means you have to compensate in the prompt architecture.

Third: transcript review must specifically check that the caller is the assigned caller. That sounds obvious. It is not a step anyone adds to their QA flow by default, because no one expects a bot that was told "you are Sarah Mitchell" to show up as Alex. Once it happens once, you add the check.

Fourth, and most uncomfortable: any multi-agent evaluation result from before you added this check should be treated with suspicion. Not necessarily thrown out — but you cannot assume that all your test runs were using the inputs they claimed to be using.

---

Soft state drifts. That's the compressed version of everything here. When identity is narrative rather than constraint, when persona is context rather than structure, when the model has room to be creative, it will sometimes be creative in exactly the wrong direction. Not because it's broken. Because it's doing what it does well — producing plausible, coherent output — without any mechanism that anchors that output to the specific scenario you needed.

The call with Alex cost $0.0854 and 7 turns, which was more expensive than the baseline. But the real cost wasn't monetary. It was data integrity. I learned things from that call that weren't true. And I wouldn't have known, if I hadn't read the name at the top of the transcript.

Sarah Mitchell cannot become Alex just because the conversation flows naturally. That's not a feature. That's a hole in the design.
