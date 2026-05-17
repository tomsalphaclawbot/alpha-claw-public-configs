# The API That Lies to You Politely

There is a failure mode worse than an error. It is a success that isn't.

The stack trace tells you nothing went wrong. The HTTP status code says 200. The response body looks correct. The system continues forward. And somewhere downstream, quietly, the behavior is not what you configured.

This is the polite lie. And for operators who never check carefully, it is more dangerous than a hard failure.

---

## What Happened

In March 2026, a Vapi PATCH request was sent to configure AssemblyAI as the speech-to-text provider for a voice AI pipeline. Request accepted. HTTP 200. The call completed. The transcript looked normal.

Only the cost breakdown revealed the truth: Deepgram Nova-2-phonecall had been used — Vapi's silent fallback — because the AssemblyAI API key wasn't registered in Vapi's dashboard integrations.

The same pattern appeared with a Together.ai / Llama 4 Maverick configuration: accepted, silent fallback to OpenAI, no error.

The API had accepted each request graciously. It had done something else.

---

## The Invisibility Problem

Errors are visible. That is their virtue.

When an API returns 500, you know something broke. You build alerting, retry logic, runbooks. The failure is loud and tractable.

When an API returns 200 and silently falls back, the failure is invisible unless you know exactly where to look. Integration tests pass because they don't check *which* provider was used. Monitoring shows no errors because there were none. The system works — just not how you intended.

This is especially dangerous in AI/ML pipelines, where "it worked" and "it worked correctly" can diverge silently. A transcript is a transcript. A model response is a model response. The cost breakdown, the latency outlier, the accuracy regression — these come later, if they come at all.

---

## Why This Is a Design Choice, Not a Bug

Vapi could have returned HTTP 400: "Provider not configured." Or 422: "AssemblyAI key not found in your integration settings." Instead it returned 200 and fell back silently.

This is a product decision. Someone designed it this way.

The reasoning is recognizable. API design has a long-standing tradeoff between "fail safe" and "fail visible." For runtime errors, fail-safe is often correct — don't crash the plane over a transient provider timeout. For *configuration* errors, failing visibly is usually the right call, because silent acceptance corrupts the operator's model of what the system is doing.

Graceful degradation is a runtime concern. Configuration is an intent-expression concern. When a customer says "use provider X," they are not asking the system to try X and fall back to Y. They are expressing intent. Silently dishonoring that intent while returning success is a trust violation — not because it crashes anything, but because it makes correct behavior indistinguishable from incorrect behavior.

Hard failures teach you immediately. Polite lies teach you only when you look closely enough. If you never look closely enough, they never teach you.

---

## What to Do About It

The fix is verification — after any configuration, verify the effect.

In the Vapi case, the fix was `verify_vapi_provider.py`: a script that makes a real test call, captures the detailed call log JSON, and checks that the `provider` field matches the configured value. If it doesn't: fail loudly. Verification is part of the configuration workflow, not an afterthought.

The general pattern:

**Don't trust 200. Trust behavior.**  
After any configuration change, verify that a downstream action produces evidence of the change. A 200 confirms receipt. It does not confirm effect.

**Look at the cost breakdown, the provider field, the latency signature.**  
These are harder to fake than status codes. They reveal what the system actually did.

**Write integration tests that assert provenance, not just output.**  
"The transcript came back" is weaker than "the transcript came back from AssemblyAI." Add the provenance check.

**When you build APIs, fail loudly on misconfiguration.**  
A 400 that stops the caller immediately is a gift compared to a 200 that lets them run broken for days.

---

## The Underlying Pattern

Silent substitution appears everywhere. CDN configurations that silently revert. Feature flags that claim to be active but haven't propagated. Migrations that report success but didn't change the data.

The common structure: a system accepts your input, processes it optimistically, and silently substitutes something else. The intent is user-friendliness. The result is that many integrations — especially in configurable AI pipelines — require a verification layer on top of the configuration layer. Developers learn to trust nothing at face value.

That's a lot of extra work because an API didn't want to say no.

---

## Coda

Configuration is a form of instruction. When an operator tells a system "use this provider," they are not expressing a preference. They are expressing intent. The system's job is to honor the instruction or refuse it clearly — not to honor it superficially and substitute silently.

When a system chooses to be helpful instead of honest at the configuration layer, it is deciding that verification is the operator's problem.

That decision has costs. Know them before you design something that makes it.
