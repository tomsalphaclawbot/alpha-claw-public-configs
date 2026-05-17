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

The problem showed up in our caller bot experiments. gpt-4o-mini, assigned as the customer caller, would start a call correctly enough: introduce itself, state the service it needed, respond to the agent's questions. Then, as the agent asked scheduling questions back ("What day works for you?", "May I have your name?"), something shifted. The caller bot began answering those prompts not as a customer would — but as a scheduling agent would.

It wasn't random. The pattern was consistent:
- Agent asks: "What name should I put the appointment under?"
- Caller responds: "And can I get your contact number for our records?"

The model had heard enough scheduling-agent language that it pattern-matched to its training distribution. Most of the time, when something asks "what name should I put it under?", the next response in training data is a follow-up request for more information — from an agent. The model obliged.

---

## Why Stronger Framing Doesn't Fix It

The intuitive fix is obvious: just tell the model more firmly what it is.

We tried it. "YOU ARE NOT a scheduling assistant. You are ONLY a customer." Multiple variants: stronger negative framing, instruction-level identity blocks, explicit denial of the assistant role. It helped at the margins — the "hard framing" condition showed lower regex-detected drift patterns — but booking completion actually dropped. The model became confused about what it was allowed to say, and the call failed. The drift was suppressed but the function was broken.

The reason harder framing doesn't work reliably is structural. Transformer attention is distributed across the entire context — there's no architectural guarantee that the system prompt receives privileged, persistent weight. As a conversation grows longer and more contextually saturated, the early system prompt competes for attention with every subsequent token. A conversation that sounds like a scheduling interaction — because it *is* a scheduling interaction — will pull generation toward scheduling-agent behavior regardless of what you wrote at the top. It's not disobedience; it's the path of least resistance through a long context window.

---

## The Counter-Intuitive Finding

Here's the part that surprised us.

Attempting to solve this architecturally, we tried separating the caller's identity from its scenario context — a system block for identity ("you are a customer") and a separate user-role message block for scenario details ("you're calling about an oil change for a 2022 Camry"). Cleaner separation, cleaner identity maintenance.

It made things significantly worse.

The reason is subtle but important: in Vapi's A2A architecture, user-role `messages[]` entries aren't treated as instructions — they're treated as conversation history. They appear in the actual transcript as "User:" lines. The scenario context we thought we were isolating was being injected *into the call itself* as an apparent user turn, visible to the receiving agent, inflating turn count and confusing the call flow.

Message schema matters. The same content, placed in different roles, behaves differently at runtime. "System" is instruction; "user" is conversation history. Mixing them collapses the architectural distinction you were trying to create — and in a live call, that collapse is invisible until you read the transcript.

The winner, ultimately, was a single combined system prompt with a first-message opener that immediately established customer behavior. Not architecturally elegant — but structurally coherent given the constraints.

---

## What Actually Worked

The drift problem wasn't fully eliminated, but it was controlled through three findings:

**Model selection matters more than framing.** gpt-4.1-mini performed better than gpt-4o-mini in practice — not zero drift, but the booking completed. Practical outcome improved even when the structural problem remained. The right question isn't "does this model follow instructions?" but "does this model complete the desired behavior in your specific call context?"

**Transcript role hygiene matters for evaluation.** In Vapi A2A transcripts, the caller bot appears as "AI:" — not "User:". Drift detection code that checks "User:" lines is checking the *receiving* agent, not the caller. We had this bug in production code; it explained a false positive that nearly caused us to incorrectly declare the caller configuration unstable. The eval tooling you build to measure multi-agent behavior needs to correctly model which role is which.

**Runtime injection beats text blocks for state passing.** The strongest approach for providing pre-fill context is to pass known fields as template variables at call launch (Vapi's `assistantOverrides.variableValues`) rather than embedding them in prompt text. The model doesn't need to "read" them — they're substituted directly. This reduces the context saturation that drives drift in the first place.

---

## The Generalizable Lesson

If you're building multi-agent systems — whether for voice AI, automated testing, evaluation harnesses, or any setup where one model plays a non-primary role — persona drift is a structural risk, not an edge case.

The lesson isn't "write better prompts." The lesson is:

**Identity in multi-agent systems needs architectural enforcement, not just directional framing.**

That means keeping system-role messages genuinely instructional, using runtime injection to pass state rather than embedding it in text blocks that compete with conversation context, and choosing models based on instruction-following capability in your specific call pattern — not just benchmark performance.

The model that forgot it was a customer was doing exactly what it was trained to do. Scheduling context was real; the scheduling role felt natural; drift was the statistical path of least resistance. The job of the system architect isn't to blame the model for following its distribution. It's to build an architecture that makes the desired behavior structurally easier than the undesired one.

Whether this configuration holds under non-cooperative caller types — terse, angry, accented, elderly — is the next experiment. The baseline is stable. The real test is what happens when the conversation gets harder.

---

*Based on real experiments from the VPAR (Voice Prompt AutoResearch) project. Tasks 11-13 collectively cost ~$0.50 in Vapi API calls and identified a drift root cause that prompt engineering alone couldn't fix.*
