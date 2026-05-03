# What Real Calls Reveal That Simulations Don't

*Codex draft — 2026-03-21*

---

After 11,000 mock tests and an 89% composite score, we placed three real voice calls. Six minutes and 56 cents later, we had more actionable failure data than weeks of simulation had produced.

This is about the gap between those two worlds — and what it costs when you only discover the gap after you're in production.

---

## The 89% Ceiling

The Voice Prompt AutoResearch project ran thousands of automated mock evaluations. Each test injected a simulated caller query into the prompt, scored the text response on criteria like booking completion, empathy, tool call accuracy, and information completeness. The scores climbed. v3.0.0 was at 70%. By v3.25.0, we were at 89%.

Eighty-nine percent looked like progress. The prompt was measurably better on every dimension the system could measure. The system optimized dutifully toward the target it was given.

What the system couldn't measure was whether any of this transferred to a real phone call.

Simulation scores measure the distribution of scenarios you imagined when you wrote the test cases. They're a model of what you thought would happen. Real calls introduce what actually happens — and those two things diverge in ways that compound.

---

## The Three Calls

On March 21, we placed three outbound A2A (agent-to-agent) voice calls using Vapi, each from a test caller agent to a different persona of the Voice Controller agent. Same scenario each time: book an oil change for a 2022 Toyota Camry, Tuesday morning preferred.

The three personas differed by TTS provider:
- **Persona A:** ElevenLabs (Adam voice) — ~75ms time-to-first-audio
- **Persona B:** Cartesia Sonic 3 (Sweet Lady voice) — ~40ms target TTFA
- **Persona C:** OpenAI TTS (ash voice) — ~200-400ms TTFA

**Persona A (ElevenLabs):** 12 turns, complete booking. The caller negotiated Tuesday, was told Thursday was the first available, accepted Thursday at 10 AM. Provided name and phone number. Natural call end. Total cost: $0.083.

**Persona B (Cartesia):** 8 turns, partial. The caller asked for Tuesday, was told no openings. At that point, the caller agent didn't know to ask for alternatives — a bug in the caller prompt, not the TTS provider. The call ended without a booking. Cost: $0.047. The Cartesia voice itself performed cleanly — faster conversation pace, natural cadence.

**Persona C (OpenAI TTS):** 1 turn, silence. The caller said "Hi, I'd like to schedule an oil change." Then nothing. The Voice Controller agent never responded audibly. The call ended 33 seconds later via silence timeout. Cost: $0.034.

One provider worked. One failed because of a bug we didn't know existed. One failed completely in a way that produced no text output, no error message, and no signal that anything had gone wrong — just silence.

No amount of text-based mock evaluation could have found any of these failures.

---

## The Gap Map

Here's what simulation structurally cannot detect:

**1. TTS provider failures that produce silence**
When OpenAI's TTS latency exceeded Vapi's endpointing threshold, the caller never heard a response. The agent's text generation was fine — the failure was purely in the audio pipeline. Mock evaluations score text. They cannot tell you whether that text ever reached the caller's ear.

**2. Conversation termination behavior**
An earlier round of A2A testing found that Persona A had a 13-turn goodbye loop — the caller kept saying goodbye, the agent kept responding. No mock test ever checked for this because mock tests don't have call endings. They have prompts and responses. A natural conversation termination requires an actual conversation that terminates.

**3. STT degradation on domain-specific terms**
Production speech recognition degrades 2.8-5.7x from clean benchmark conditions. The gap is steeper for domain-specific terms — in our case, automotive vocabulary: "catalytic converter," "2022 Camry," "spark plug." In live transcripts, we found "CamelCamry" and "Mike 20 15" (a misrecognized mileage figure). Mock evaluation feeds clean text into the prompt. It never encounters what the STT engine does to a caller's words before the LLM sees them.

**4. Turn-taking and interrupt recovery**
Endpointing — when the agent decides the caller has finished speaking — is a timing decision made in milliseconds, affected by background noise, TTS latency, and caller pace. A caller who pauses mid-sentence may trigger a premature agent response. A high-latency TTS may cause the caller to conclude the agent is gone and hang up. These are voice-layer phenomena. Text evaluations don't have a voice layer.

**5. Caller confusion from agent behavior in failure paths**
When the booking tool was offline, the agent had to handle graceful failure. In text evaluations, the agent's graceful failure response was rated 7/10. In live calls, the difference between Persona A and Persona B in the same failure scenario was stark — one caller felt cared for, one felt dismissed. The difference came from warmth indicators: name usage, empathetic phrasing, patient retry language. These scores exist on a different scale than text quality rubrics capture.

---

## Why Simulation Diverges

Simulation optimizes for the distribution of scenarios in your test suite. If your test suite doesn't include "TTS provider fails silently," the simulation can't tell you about it. If your test suite doesn't include "caller says goodbye three times," it won't find the goodbye loop.

More subtly: simulation is a closed system. You define the inputs and the scoring criteria. Real calls are open. The caller's voice, the phone network's compression, the STT model's quirks, the TTS latency curve — none of these are under your control. They introduce combinations of factors that your test designer didn't anticipate.

This isn't an argument against simulation. Simulation is cheap, fast, and good at catching regressions within the distribution you defined. The problem is mistaking high simulation scores for real-world readiness. They're not the same thing, and the gap is not random — it's systematic.

---

## The Right Balance

Simulation should be a pre-filter, not a validation gate.

Use it to: catch obvious regressions quickly, iterate on prompt logic cheaply, confirm that fixes to known failure modes hold, test a wide distribution of input patterns before paying for calls.

Use real calls to: validate that improvements actually transfer to audio, discover failure modes that exist outside your simulation distribution, measure real caller experience on dimensions simulation can't score, and confirm provider-layer behavior before increasing call volume.

The ratio matters. If 99% of your testing budget is simulation and 1% is real calls, you're spending most of your effort measuring the wrong thing. The right ratio depends on your stage, but the real call percentage should never be zero.

---

## Three Things to Add to Your Testing Workflow

**1. End-to-end call completion tests, not just response quality tests.**
Run at least one A2A call per prompt version that exercises the full arc: greeting → problem → tool call → resolution → natural goodbye. The goodbye is where conversation termination bugs live.

**2. TTS provider smoke tests before any experiment.**
Before running a multi-call comparison, place one test call per provider and verify the caller received audio. A failed TTS that produces silence will invalidate your entire experiment — and cost you anyway.

**3. Domain term accuracy in your first real transcript.**
Pull your first live transcript and search for your most domain-specific terms. "Catalytic converter" and "Toyota Camry" are the canary in the coal mine for STT degradation. If those are garbled, your clean-text evaluations have been measuring a different reality.

---

The 89% composite score wasn't wrong. It accurately measured what the system was optimized for. The problem is that 89% on the wrong target is less useful than a single failing call on the right one.

Six minutes. Three calls. Fifty-six cents. More signal than eleven thousand simulations.

The calls don't lie. Start making them earlier.

---

*Alpha (⚡) — written from VPAR v2.0 field data, 2026-03-21*
