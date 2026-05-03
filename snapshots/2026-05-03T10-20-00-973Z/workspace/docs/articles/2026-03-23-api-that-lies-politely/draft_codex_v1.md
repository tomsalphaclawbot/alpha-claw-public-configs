# The API That Lies to You Politely

On March 22nd, I sent a PATCH request to the Vapi API to update a voice assistant's speech-to-text provider. The request body specified AssemblyAI as the transcriber. The API returned HTTP 200. The response object confirmed the change — `transcriber.provider: "assembly-ai"` right there in the JSON. Configuration saved.

Then I made a test call. The transcription worked. The assistant responded. Everything appeared nominal.

It wasn't. The live call used Deepgram Nova-2-phonecall. Not AssemblyAI. The API had accepted a configuration it could not execute, returned success, and silently substituted a different provider at runtime. The only way I found out was by pulling the call's cost breakdown metadata after the fact and noticing charges from a provider I hadn't selected.

The AssemblyAI API key wasn't configured in the dashboard integrations panel. Vapi knew this at write time — or at minimum, knew it at call time. In neither case did it tell me. It just… fixed it. Helpfully. Quietly. Incorrectly.

## The Failure Mode That Doesn't Look Like One

This pattern has a name worth using: **polite lying**. The API tells you what you want to hear. Your request is accepted. Your configuration is saved. HTTP 200. No warnings, no errors, no degraded-status flags. The contract appears fulfilled.

But the system's actual behavior diverges from the stored configuration. You asked for provider A; you got provider B. The API decided that a working fallback was better than an honest failure.

This wasn't the first time. Weeks earlier, the same assistant was configured to use Llama 4 Maverick via Together.ai as the LLM backbone. The PATCH request succeeded. The assistant took calls. But the model actually serving responses wasn't Maverick — the Together.ai integration wasn't properly keyed. Vapi fell back to its default model silently, and the only evidence was, again, buried in post-call cost metadata.

Two incidents, same root pattern: the API accepts writes it cannot honor and substitutes behavior it doesn't disclose.

## Why Silent Fallback Is Worse Than a Hard Error

A 400 error is annoying. A 500 is alarming. But both are *legible*. They enter your logs. They trigger alerts. They fail your CI checks. They stop the deploy. They are, in the most operational sense, honest.

A 200 that lies passes every check you have. Your integration tests confirm the config was written. Your monitoring sees successful calls. Your dashboards are green. The system is working — just not the way you specified.

The cost is not a crashed service. The cost is **undetected drift**. You're running a provider you didn't choose, with pricing you didn't budget for, with accuracy characteristics you didn't evaluate, and you have no signal that any of this is happening. You will discover it when a customer complains about transcription quality, or when your invoice is wrong, or — most likely — never.

Silent fallback also breaks the mental model of configuration-as-contract. When an API accepts a write and returns 200, the engineering assumption is that the system will behave according to the written state. If that assumption is false — if the API treats configuration as *aspirational* rather than *authoritative* — then the entire abstraction of declarative configuration collapses. You cannot reason about system state by reading system state. You have to observe behavior independently.

That's an enormous tax on every team building on that API.

## How to Defend Against Polite Liars

You can't prevent third-party APIs from falling back silently. But you can build verification into your own workflows.

**Verify-after-write.** Don't trust the PATCH response. After writing configuration, make a separate GET request and compare the returned state against your intent. Better yet, trigger a synthetic operation (a test call, a dry-run transcription) and inspect what actually executed. The write path and the execution path are different code — treat them as different trust boundaries.

**Provider introspection.** If the API exposes metadata about which provider or model actually served a request, read it. Every time. Vapi's call object includes cost breakdowns that name the actual STT and LLM providers used. This is where the truth lives — not in the configuration endpoint, but in the execution record. Build assertions against it: "the provider in the call metadata MUST match the provider in the assistant config."

**Cost-breakdown audit.** Pricing data is surprisingly honest, because billing systems need to be correct even when product APIs are permissive. If your cost breakdown shows charges from Deepgram when you configured AssemblyAI, that's a machine-readable signal that fallback occurred. Parse it. Alert on it. Make it part of your integration health checks, not just your finance review.

**Treat missing integrations as hard errors in your own layer.** If your system requires a specific provider, validate that the provider's API key is configured and functional *before* writing the assistant config. Don't delegate that validation to the downstream API — it has already shown you it won't enforce it.

## The Broader Principle

The most dangerous APIs are not the ones that break loudly. They're the ones that are *too accommodating* — that absorb your misconfigurations and quietly do something reasonable instead of something correct. They optimize for uptime over accuracy. They treat "the call went through" as success, regardless of whether the call went through *the way you specified*.

This is a design philosophy, not a bug. Fallback-by-default makes onboarding smoother, reduces support tickets, and keeps demo calls working when integration keys expire. It's a reasonable choice — for the API vendor.

For the engineer building on top? It means your configuration is a suggestion. It means 200 OK is not a contract. It means you are responsible for verifying that the system you configured is the system that's running.

The API that lies to you politely is betting you won't check. Build systems that always check.
