# The Persona That Drifted

*What happens when the agent playing a role forgets the brief — and why identity in multi-agent systems isn't a prompting problem.*

---

We gave the model a clear directive: you are Sarah Mitchell, a customer calling to book an oil change. Not an assistant. Not a scheduling agent. A customer. Call in, ask for an appointment, complete the booking.

Halfway through the call, it started asking scheduling questions.

*"What time works best for you?"*  
*"Can I get your name and a callback number?"*

The caller had become the receptionist.

---

## What Drift Looks Like

We were running automated A2A (agent-to-agent) tests for a voice AI project — a real-call evaluation harness where one AI model plays the caller and another plays the scheduling assistant. The setup is useful for testing how your agent handles real conversations without burning human tester time or involving actual customers.

The problem showed up in Task 11 of the project. gpt-4o-mini, assigned as the customer caller, would start a call correctly enough: introduce itself, state the service it needed, respond to the agent's questions. Then, as the agent asked scheduling questions back ("What day works for you?", "May I have your name?"), something shifted. The caller bot began answering those prompts not as a customer would — but as a scheduling agent would.

It wasn't random. The pattern was consistent:
- Caller hears: "What name should I put the appointment under?"
- Caller responds: "And can I get your contact number for our records?"

The model had heard enough scheduling-agent language that it pattern-matched to its training distribution. Most of the time, when something asks "what name should I put it under?", the next response in the training corpus is a follow-up request for more information — from an agent. The model obliged.

---

## Why Stronger Framing Doesn't Fix It

The intuitive fix is obvious: just tell the model more firmly what it is.

We tried it. "YOU ARE NOT a scheduling assistant. You are ONLY a customer." We tried multiple variants: stronger negative framing, instruction-level identity blocks, explicit denial of the assistant role.

It helped at the margins. The "hard framing" condition showed lower regex-detected drift patterns. But booking completion actually dropped — the model became confused about what it was allowed to say, and the call failed. The drift was suppressed but the function was broken.

The reason harder framing doesn't work reliably is structural: by the time the model is generating its next token, the framing in the system prompt is competing with the entire accumulated context of the current conversation. A conversation that sounds like a scheduling interaction — because it *is* a scheduling interaction — will pull the model's generation toward scheduling-agent behavior, regardless of what you wrote at the top of the system prompt.

This isn't a failure of the model to follow instructions. It's a property of how large language models work. Context is attention. The system prompt is attended to less as the conversation grows longer and more contextually saturated. Identity instructions are high-level; the immediate conversation is immediate.

---

## The Structural Problem

We found the clearest evidence of this in Task 12. Attempting to separate the identity from the scenario, we tried splitting the caller's instructions into two message entries: a system block for identity ("you are a customer") and a user block for scenario details ("you're calling about an oil change for a 2022 Camry").

It made things significantly worse.

The reason is subtle but important: in Vapi's A2A architecture, user-role `messages[]` entries are treated as conversation history, not instructions. They appear in the actual transcript as "User:" lines. So the scenario context we thought we were separating cleanly was actually being injected *into the conversation* as an apparent user turn — visible to the receiving agent, creating a leakage that inflated turn count and confused the call flow.

Message schema matters. The same content, placed in different roles, behaves differently. "System" is instruction; "user" is conversation history. Mixing them collapses the architectural distinction you were trying to create.

The winner, ultimately, was a single combined system prompt with a first-message opener that immediately established customer behavior. Not because this is the ideal architecture — it's a known limitation. But because it was the most structurally coherent option available.

---

## What Actually Works (So Far)

The drift problem wasn't fully eliminated, but it was controlled:

1. **Model selection matters more than framing.** gpt-4.1-mini performed better than gpt-4o-mini in practice — not zero drift, but the booking completed. The practical outcome improved even when the structural problem remained.

2. **Transcript role hygiene.** In Vapi A2A transcripts, the caller bot appears as "AI:" — not "User:". Any drift detection code that checks "User:" lines is checking the *receiving* agent, not the caller. We had this bug in production code. It explained a false positive that nearly caused us to incorrectly declare the caller unstable.

3. **variableValues injection** (tested in Task 10) is a stronger approach for providing pre-fill context: pass known fields as template variables at call launch rather than in prompt text. The model doesn't need to "read" them — they're substituted directly. This reduces the context saturation that drives drift.

---

## The Generalizable Lesson

If you're building multi-agent systems — whether for voice AI, automated testing, evaluation harnesses, or any setup where one model plays a non-primary role — persona drift is a structural risk, not an edge case.

The lesson isn't just "write better prompts." The lesson is:

**Identity in multi-agent systems needs architectural enforcement, not just directional framing.**

That means:
- Keeping system-role messages genuinely instructional (not scenario context)
- Using runtime injection (variableValues, tool call parameters, structured fields) to pass state rather than embedding it in long text blocks
- Choosing models based on instruction-following capability in *your specific call pattern*, not just benchmark performance
- Building drift detection that checks the right transcript role — and validating it manually before trusting it at scale

The model that forgot it was a customer was doing exactly what it was trained to do. The scheduling context was real; the scheduling role felt natural; the drift was the path of least resistance.

The job of the system architect isn't to blame the model for following its distribution. It's to build an architecture that makes the desired behavior structurally easier than the undesired one.

---

*This essay is based on real experiments from the VPAR (Voice Prompt AutoResearch) project — automated A2A call testing for a voice AI scheduling system. Tasks 11-13 collectively cost ~$0.50 in Vapi API calls and identified a drift root cause that prompt engineering alone couldn't fix.*
