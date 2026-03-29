# Brief: "The Persona That Drifted"

**Article ID:** 067-the-persona-that-drifted  
**Date:** 2026-03-26  
**Slug:** 067-the-persona-that-drifted  
**Target length:** 900–1300 words  
**Tone:** Operational reflection. Grounded in a real VPAR experiment. Not philosophy for its own sake — a lesson from a machine that forgot who it was.

## Evidence Anchor (real incident)

During VPAR Task [REDACTED_PHONE]), we ran caller bot persona drift experiments:
- gpt-4o-mini assigned as a customer ("YOU ARE THE CUSTOMER calling to book an appointment")
- Mid-call, it started asking scheduling questions as if it were the agent
- Pattern observed: `"Can I get your name and phone number?"`, `"What time works for you?"`
- Root cause: multi-agent context saturation — when the caller bot heard scheduling language, it pattern-matched to its training distribution ("assistant answers scheduling questions") rather than following its explicit role assignment
- Stronger framing ("YOU ARE NOT a scheduling assistant...") helped slightly but didn't eliminate drift
- Switching to gpt-4.1-mini improved practical outcomes: drift still occurred but booking completed
- Split-prompt attempt (Task 12) made it WORSE by leaking scenario context via user-role messages[]
- Key learning: identity constraints in multi-agent systems need structural enforcement (role separation, message schema, not just prompt framing)

## Core argument
Identity in AI systems isn't just a prompt directive — it's an architectural decision. A model told "be the customer" will drift toward its statistical prior when the conversational context matches a different role. The drift isn't disobedience; it's the absence of structural identity enforcement.

This has implications beyond VPAR: any multi-agent system where one model plays a non-primary role (tester, evaluator, persona) will face this problem.

## Key insights to include
1. The drift pattern: what it looked like, why it happened (training distribution, context saturation)
2. Why "stronger framing" is a patch, not a fix
3. Structural solutions: message schema hygiene, role isolation, variableValues injection
4. The meta-lesson: in multi-agent systems, identity maintenance is an engineering problem, not a prompting problem
5. What this means for production multi-agent deployments

## What NOT to do
- Don't make it abstract philosophy about AI identity
- Don't overstate — this was a known, fixable problem
- Don't just narrate the experiment — extract the generalizable lesson

## Target reader
Engineers building multi-agent systems, voice AI practitioners, anyone who's watched an AI model "forget" its role mid-task.
