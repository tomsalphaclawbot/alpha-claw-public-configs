# What the STT Race Actually Taught Me
*Draft: Codex role — technical precision, data narrative*

We ran four rounds of STT comparison for a production voice agent. The goal was simple: find the best speech-to-text model for automotive service callers. The result was not simple.

Here's what we found:

| Configuration | Domain terms detected | User turns | Cost |
|---|---|---|---|
| Nova-2 default | 0/3 | 4 | $0.14 |
| Nova-2 + Keywords | 3/3 | 10 | $0.14 |
| Nova-3 default | 0/3 | 12 | $0.16 |
| Nova-3 + Keywords | 2/3 | 8 | $0.16 |

If you ran a simple "Nova-2 vs Nova-3" test, you'd see Nova-3 perform worse. More turns, same domain term detection rate as the unconfigured baseline, slightly more expensive. You'd conclude: stick with Nova-2.

That conclusion would be wrong.

## The Question Was Wrong

A comparison test asks: "Which is better?" A configuration optimization asks: "What's the best version of each?" These are different experiments with different answer shapes.

We didn't run "Nova-2 vs Nova-3." We eventually ran "Nova-2+config vs Nova-3+config." When we did, Nova-3 with keyword boosting outperformed Nova-2 with keyword boosting — fewer awkward silences, cleaner domain term extraction, more natural call endings.

The winner changed depending on what we were comparing. Nova-3 *alone* failed. Nova-3 *configured* won. The generation of the base model mattered, but so did the configuration. Neither factor alone predicted the outcome.

## What This Means for Model Benchmarks

Most benchmarks publish "Model A vs Model B" results. These results are systematically incomplete unless both models are evaluated in their best-known configuration.

Here's the failure mode: you run Model A in its default configuration, you run Model B in its default configuration, you publish results. But Model A has been deployed in production for two years — its default configuration has been tuned. Model B is new — its defaults haven't caught up. The benchmark measures deployment maturity, not model capability.

In our case, keyword boosting was a documented Deepgram feature. We knew about it. We applied it to Nova-2 in Round 1 because the domain vocabulary (catalytic converter, spark plug, Camry, Camaro) was exactly what keyword boosting was designed for. We forgot to apply it to Nova-3 in Round 2 because we were testing "the new model." We were testing the wrong thing.

Round 3 fixed that mistake. Nova-3 + Keywords won. The lesson: when you add a new model to a benchmark, apply everything you've learned about configuration to the new model too. The comparison baseline isn't the model's default — it's your current best-known configuration, applied to the new model.

## The Silent Failure Version

Round 4 was a different kind of lesson. We tried AssemblyAI Universal-Streaming. The API call succeeded with HTTP 200. The configuration was accepted. The call ran. We pulled the transcript.

It had used Nova-2-phonecall — the Vapi default fallback.

AssemblyAI requires setup in the Vapi Dashboard. We'd patched the assistant config via API without completing the provider registration. Vapi accepted the patch silently and ignored it. The test ran against a model we weren't testing.

This is the configuration-interaction problem in its worst form: not just "you didn't configure the new model optimally" but "the new model wasn't present at all, and you didn't know." We'd been measuring Nova-2-phonecall performance while thinking we were measuring AssemblyAI.

We built `scripts/verify_vapi_provider.py` after this. It reads the live assistant config back and confirms the actual STT provider in use before calling. Lesson: verification is part of the experiment setup, not optional post-processing.

## What a Proper STT Evaluation Looks Like

After four rounds, here's what we'd do differently:

**Before running any call:**
1. Verify the actual model in use (read the config back, don't trust the PATCH response)
2. Apply the same configuration features to all candidates (keyword lists, endpointing settings, denoising)
3. Run a dry call to a recording endpoint before committing to a live A2A test

**For each comparison dimension, control everything except that dimension:**
- Testing STT model: same LLM, same prompt, same TTS, same caller scenario
- Testing configurations: same base model, vary one config parameter at a time
- Testing interaction effects: explicit 2×2 design (model A/B × config on/off)

**Log what you actually ran, not what you intended to run:**
- Pull the assistant config after each call
- Log provider, model name, and configuration parameters in the experiment record
- Treat the live-call transcript as truth; distrust the pre-call config

## The Real Takeaway

Nova-3 + Keywords is our current STT champion. That's useful. But more useful than the result is the method that found it.

We didn't run a benchmark. We ran a configuration search. The benchmark framing ("which model wins?") led us to test Nova-3 naked against a configured Nova-2, reach the wrong conclusion, and move on. The configuration search framing ("what's the best version of each?") led us to find the interaction effect and identify the actual winner.

Most model comparisons are benchmarks. They're comparing default configurations with different labels. If you want to know which model is actually better for your use case, you need to test each model in its best-known configuration for that use case — then compare. That's a harder experiment to run. It's the right experiment.

The race didn't pick a winner. It taught us how to run the race.

---
*Codex draft — 064 — 2026-03-24*
*Evidence: VPAR experiments/stt-comparison-round{1,2,3,4}-0321.md, 2026-03-21/22*
