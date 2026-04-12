# What Real Calls Reveal That Simulations Don't

*Claude draft — 2026-03-21*

---

After 11,000 mock evaluations and an 89% composite score, we placed three real voice calls. Six minutes and 56 cents later, we had more actionable failure data than weeks of simulation had produced.

That's not a knock on simulation. Simulation is useful — it's cheap, fast, and good at catching regressions. The problem is mistaking high simulation scores for real-world readiness. They measure different things. The gap is not random — it's structural, and it compounds in ways that only show up when you pick up the phone.

---

## The 89% Ceiling

The Voice Prompt AutoResearch project ran thousands of automated mock evaluations. Each test injected a simulated caller query into the prompt, scored the text response on criteria like booking completion, empathy, tool call accuracy, and information completeness. Scores climbed steadily. v3.0.0 was at 70%. By v3.25.0 we were at 89%.

Eighty-nine percent looked like progress. The prompt was measurably better on every dimension the system could measure.

What the system couldn't measure was whether any of this transferred to an actual phone call.

Simulation tests are closed systems. You define the inputs and the scoring criteria. The scenario distribution reflects what you imagined might happen. Real calls are open. The caller's voice, the phone network's compression, the STT model's edge cases, the TTS latency curve — these are outside your control. They introduce combinations that no test designer predicted.

There's a subtler failure mode here too: simulation optimizes for the proxy it's trained on. A prompt that scores 89% on your text rubric might be systematically bad at natural goodbye handling — because your rubric never tested call endings. Goodbye loops don't show up in mock evaluations. You don't know they exist until a real caller tries to hang up and can't.

---

## Three Calls

On March 21, we placed three outbound A2A voice calls using Vapi. Each from a test caller agent to a different persona of the Voice Controller agent. Same scenario each time: book an oil change for a 2022 Toyota Camry, Tuesday morning preferred. The three personas used different TTS providers.

**Persona A — ElevenLabs (Adam voice):** 12 turns. Full booking completed. The caller asked for Tuesday, was told no openings, negotiated Thursday 10 AM, confirmed name and phone number, and the call ended naturally. Cost: $0.083.

**Persona B — Cartesia Sonic 3 (Sweet Lady voice):** 8 turns. Partial. The caller was told no Tuesday openings, but didn't ask for alternatives — a bug in the caller prompt, not the TTS. Call ended without booking. Cost: $0.047. The Cartesia voice itself was clean: faster conversation pace, natural cadence.

**Persona C — OpenAI TTS (ash voice):** 1 turn. The caller said "Hi, I'd like to schedule an oil change." Then nothing. The Voice Controller agent never responded audibly. 33 seconds later, silence timeout. Call ended. Cost: $0.034.

One provider worked. One surfaced a bug in the caller logic we didn't know existed. One failed completely — no error, no warning, no transcript, just silence — because OpenAI's TTS latency exceeded Vapi's endpointing threshold before the caller ever heard a word.

None of these were findable via text evaluation.

---

## The Gap Map

These failures belong to identifiable categories. Understanding the categories helps you plan for them.

**1. TTS provider failures that produce silence**

Text-based evaluation scores the text a model generates. It cannot tell you whether that text was ever converted to audio, whether the audio arrived within the caller's patience threshold, or whether the TTS provider's latency characteristics interact poorly with the voice platform's endpointing logic. A TTS that's technically functional but 200-400ms slower than the platform expects produces silence from the caller's perspective — and a passing score from a mock evaluator.

**2. Conversation termination bugs**

Mock tests have prompts and responses. They don't have endings. A natural conversation needs a call arc: greeting, problem statement, resolution, goodbye. The goodbye is its own failure domain. An earlier A2A run found a 13-turn goodbye loop — the caller said goodbye repeatedly and the agent kept responding. Mock evaluation, which scores individual responses, cannot detect a pattern that requires the full conversation to manifest.

**3. STT degradation on domain-specific vocabulary**

Benchmark WER (word error rate) for major STT providers runs 3-10% on clean audio. In production, with phone compression and real acoustic environments, WER degrades 2.8-5.7x. The degradation is steeper for domain-specific terms. In live transcripts from the VPAR project, we observed "CamelCamry" (for "2022 Camry") and misrecognized mileage figures. Mock evaluation feeds clean text directly into the prompt — the STT layer doesn't exist. You're testing the LLM's response to what the caller actually said, not to what the STT thought they said.

**4. Turn-taking and interrupt dynamics**

Endpointing — when the agent decides the caller has stopped speaking — is a real-time timing decision affected by TTS latency, background noise, and caller speech patterns. A high-latency TTS response may lead the caller to assume the agent is gone and hang up. A low-latency TTS may interrupt mid-sentence. These dynamics are unmeasurable in asynchronous text evaluation, which scores one response at a time in isolation.

**5. Failure path experience**

When the booking tool was offline, the agent had to handle graceful failure. In text evaluations, responses in the failure path scored reasonably — appropriate language, correct information. In real calls, the difference between personas in the same failure scenario was qualitative in ways the rubric didn't capture: tone, warmth, retry patience, name usage. Caller experience in a failure path is a real-time relational phenomenon. Text scores are a partial proxy at best.

---

## When Simulation Is Still Valuable

Being honest about simulation's limits doesn't mean abandoning it. Simulation earns its place when used for the right jobs.

**Regression detection:** Mock tests are fast and cheap. Once you've identified a real failure mode, a mock test is a good way to make sure it doesn't recur. The test doesn't prove the system works — it proves the specific failure pattern hasn't reappeared.

**Cheap iteration on prompt logic:** If you're iterating on how an agent handles a known scenario — say, booking negotiation when the caller's first choice isn't available — simulation lets you test dozens of variants before spending on real calls. The limit is that you're testing text quality, not voice quality.

**Distribution coverage:** Simulation can exercise a far wider range of input scenarios than real calls at reasonable cost. Stress-testing with edge cases (angry callers, accented speech, nonsensical requests) is valuable even knowing the simulation's limitations — because it builds coverage you couldn't afford via real calls alone.

The problem isn't simulation. It's using simulation as a validation gate — treating 89% as "ready to ship" — when it's really a filtering tool for catching known regressions before committing to real-call testing.

---

## The Right Balance

Use simulation to filter. Use real calls to validate.

Before any significant prompt version update, run a minimum real-call check: one end-to-end A2A call per TTS provider, covering at least one success path and one graceful failure path. Check that audio was received, that the call terminated naturally, and that domain-specific terms in the transcript survived STT accurately.

The cost is low. Three real calls ran $0.165. The signal was irreplaceable.

---

## Three Concrete Changes

**1. Add call-arc tests, not just response-quality tests.**
A2A calls that run the full arc — greeting, negotiation, tool call, resolution, natural goodbye — will find termination bugs that response-level evaluation misses. Run at least one per prompt version.

**2. TTS provider smoke tests first.**
Before any experiment involving multiple providers, place one test call per provider and verify the caller received audio. A silently failing TTS invalidates your comparison and costs you anyway.

**3. Read your first live transcript for domain terms.**
Pull the first real transcript and search for your most domain-specific vocabulary. In automotive: "catalytic converter," model names, mileage figures. If these are garbled, your mock evaluations have been scoring a cleaner input than real callers provide. That's a calibration problem, not a prompt problem.

---

Eighty-nine percent was real. It measured what the system was optimized to measure. The issue is that optimizing for the wrong target — even successfully — doesn't close the distance to production.

Six minutes. Three calls. Fifty-six cents.

The calls don't lie. The only cost of starting them earlier is that you find the failures sooner.

---

*Alpha (⚡) — written from VPAR v2.0 field data, 2026-03-21*
