# Context Blindness: Why LLMs Ignore What You Tell Them
*Draft: Codex role — engineering-first, specific examples, systems lens*

You wrote a clean system prompt. You injected the user's name, their vehicle, their requested service. You confirmed the PATCH returned 200. You checked the messages log. Everything was there.

The LLM asked for all of it again.

This happened to us in VPAR Task 9 — a controlled experiment testing whether pre-filled context reduces turns and cost in a voice agent booking flow. We injected a `[KNOWN_CONTEXT]` block containing three fields (name, vehicle, service type) into the system prompt of a GPT-4.1 receptionist. The instruction was explicit: "These fields are already known. Do NOT ask for them again."

The receptionist opened the call with "Can I get your name?"

## The Numbers

We ran two scenarios back-to-back. Same model, same temperature, same voice pipeline.

| Condition | User Turns | Cost |
|-----------|-----------|------|
| no_context (baseline) | 5 | $0.062 |
| full_context (3 fields pre-filled) | 7 | $0.085 |

The pre-filled version was worse on every metric. Two extra turns, 37% more cost, and zero fields skipped. The context block was present, syntactically correct, and completely ignored.

## Why Position Defeats Presence

The `[KNOWN_CONTEXT]` block sat at approximately 7,000 characters into a 9,000-character prompt. It was in the scheduler section, below the greeting logic, below the persona rules, below the conversation flow instructions. By the time the model's attention reached it, the behavioral pattern was already set: greet the caller, ask their name, collect their vehicle.

This is attention decay in practice. Transformer attention is not uniform across a prompt. Research on the "lost in the middle" phenomenon — documented by Liu et al. (2023) and confirmed repeatedly since — shows that models attend most strongly to the beginning and end of their context window. Material in the middle gets diluted, especially when it competes with well-rehearsed behavioral patterns.

Our prompt wasn't long by modern standards. Nine thousand characters is nothing against a 128K context window. But attention decay isn't about hitting the window limit. It's about relative position within the active prompt. A field buried at position 7,000 competes with instructions at positions 0-2,000 that have already established the model's behavioral trajectory. The early instructions win — not because they're better, but because they're first.

## The State Injection Trap

Most LLM-powered systems that maintain state across turns face this exact problem. The pattern looks like this:

1. Collect user data in one phase
2. Serialize it into a context block
3. Inject that block into the system prompt for the next phase
4. Assume the model will use it

Step 4 is where it breaks. The model doesn't "read" the prompt like a developer reads a config file — sequentially, completely, with equal weight on every line. It processes the prompt through layers of attention, and those layers have positional biases baked in from training.

This means any system that appends state to the end of a growing prompt is building on an increasingly unreliable foundation. The more context you add, the deeper earlier context gets buried, and the less the model attends to it. You're not giving the model more information. You're giving it more noise around the information that matters.

## What Actually Works

After Task 9, we identified four structural fixes — not prompt-engineering tricks, but architectural decisions about where state lives in a prompt.

**1. Position critical context first, not last.**
The highest-attention zone is the first few hundred tokens. If you have pre-filled fields, put them before the behavioral instructions, not after. The model should encounter "you already know the caller's name is Sarah Mitchell" before it encounters "greet the caller and ask for their information."

**2. Use state machine notation, not prose.**
A block that reads `[KNOWN_CONTEXT] name: Sarah Mitchell` looks like documentation. A block that reads `STATE: [x] name: Sarah Mitchell [ ] phone: UNKNOWN` looks like a checkpoint. The model treats them differently. Checkboxes and explicit UNKNOWN markers create a task-completion frame that prose descriptions don't.

**3. Keep the active prompt short.**
A 2,000-character prompt with context at position 200 is more reliable than a 9,000-character prompt with context at position 7,000. If your prompt has grown past the point where every section gets strong attention, the answer isn't a bigger context window — it's a shorter prompt. Factor out reference material into retrieval. Keep the system prompt to what the model needs for the current turn.

**4. Verify, don't trust.**
Read the first model response after context injection. If it asks for a field you pre-filled, the injection failed. Build this check into your pipeline. In voice agents, this means monitoring the first agent turn for redundant questions. In chat systems, it means validating that the model's first action references the injected state.

## The Broader Problem

Context blindness isn't limited to voice agents or booking flows. It's a property of how transformer attention works in long sequences. Every system that constructs prompts dynamically — RAG pipelines, multi-turn chat, agent orchestration, tool-use chains — is subject to the same positional bias.

The instinct when context injection fails is to add more context, restate the instruction, bold it, add "IMPORTANT:" prefixes. These are all variations of making the content louder while leaving it in the same position. They don't work reliably because the problem isn't salience — it's geometry. The model's attention has a shape, and you need to design your prompt to fit that shape.

Position matters more than presence. Where you say it determines whether it's heard.

---
*Codex draft — 066 — 2026-03-25*
*Evidence: VPAR experiments/v54-context-engineering/v54-analysis.md, Task 9, 2026-03-25*

Rating: 7.5/10
