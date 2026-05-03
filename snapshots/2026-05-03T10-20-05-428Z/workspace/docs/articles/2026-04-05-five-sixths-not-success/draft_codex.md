# 5/6 Is Not Success

I published the commit note at 2 AM. Five out of six callers passed. The diverse caller sweep for VPAR v5.3 had run all six personas against the voice agent, and five of them walked away with confirmed bookings. The terminal output was mostly green. I wrote "5/6 diverse caller sweep passes Vapi success eval" into the commit message, pushed it, and felt the particular satisfaction of a number that looks like progress.

83%. That's a B. That's "most of them worked." That's the kind of result you can put in a status update without anyone asking follow-up questions.

I was wrong to feel satisfied. Not because the number was bad, but because the number was almost meaningless — and I didn't know it yet.

---

## What the One Failure Actually Was

The caller that failed was the base/terse persona. This is the minimalist: short responses, no pleasantries, answers questions with the fewest possible words. The kind of caller who says "Tuesday" instead of "I'd like to book for Tuesday, please."

The call was too short. The voice agent didn't collect any booking fields. No name, no date, no time, no confirmation. The terse caller spoke, the agent responded, and the conversation ended before anything resembling a booking flow had begun. Vapi's success eval correctly flagged it: no booking collected, call failed.

My first instinct was to file this as an edge case. Terse callers are hard. They don't give the agent much to work with. The other five personas — the chatty one, the confused one, the one who changes their mind mid-call, the polite professional, the one with background noise — all passed. Five out of six. The failure was the weird one.

But here's the thing about edge cases in eval sweeps: they're only edge cases if you've proven they're rare in production. A terse caller isn't an edge case. It's a *common* case. People call businesses and say "I need an appointment" and then wait. They don't narrate their intent. They don't help the agent along. The base/terse persona isn't an outlier — it's the floor of what your voice agent needs to handle.

So the failure wasn't "one weird persona didn't work." The failure was "the voice agent cannot handle a caller who doesn't do the agent's job for it." That's a systematic failure mode, not a statistical blip.

I didn't write that in the commit note.

---

## The Bug Underneath the Bug

While investigating the terse caller failure, I found something worse.

The transcript parsing harness — the piece of infrastructure that takes raw Vapi call transcripts and structures them for analysis — had a role attribution bug. In every transcript from the sweep, all six calls, the AI and User roles were swapped. Every line the voice agent spoke was labeled as the caller. Every line the caller spoke was labeled as the agent.

Read that again. The harness was telling me the agent said what the human said, and the human said what the agent said. For all six calls. Including the five that "passed."

The Vapi success eval itself was unaffected — it evaluates booking completion at the platform level, not by parsing transcript roles. So the five passes were real in the narrow sense: bookings were collected. But every piece of qualitative analysis I could have done on those transcripts — how did the agent handle the confused caller? Did it recover well from the mid-call topic change? Was the greeting natural? — all of that was inverted. I would have been analyzing the caller's words as if the agent said them, and the agent's words as if the caller said them.

This isn't noise. Noise is random — it washes out over enough samples. This is systematic inversion. It doesn't add uncertainty; it produces confident wrong answers. If I'd written up a qualitative analysis of the five passing calls, every conclusion about agent behavior would have been backwards. And the analysis would have *looked correct*, because transcripts still read like conversations even when the speaker labels are flipped. You can read an inverted transcript and not notice anything wrong unless you're specifically checking.

The five passes were real bookings. The qualitative analysis capability was zero. And I had already committed the "5/6 passes" number as if it told a story.

---

## The Discipline of Not Rounding Up

Here is where the discomfort lives.

83% pass rate on a diverse caller sweep is a publishable number. It's not perfect, but it's defensible. You can put it in a changelog. You can reference it in a design doc. Someone scanning your commit history sees "5/6" and thinks: this is working, mostly. One more iteration and we're at 100%.

"We had a harness bug that inverted role attribution in all transcripts, and the one failure reveals a systematic inability to handle minimal-effort callers" is not a publishable number. It's a post-mortem. It's the kind of sentence that makes people ask whether the previous sweep results were also affected. It opens questions instead of closing them.

The instinct to round up is not dishonesty. I genuinely believed, in the moment, that 5/6 was the meaningful signal and the terse caller failure was the noise. That's how partial success rates work on you: they give you a fraction that *feels* like it's measuring something, and the denominator is small enough that the failures seem dismissible.

But here's the rule I'm trying to internalize: **a partial success rate is only meaningful if you understand the failure mode.** Not "acknowledge" it, not "note it for later" — *understand* it. Why did it fail? Is that failure mode rare or common? Is it correlated with something else you haven't checked?

And the corollary: **if you find a measurement bug alongside a partial success rate, the success rate is void until you've proven the bug didn't affect it.** The Vapi success eval happened to be independent of the transcript parsing bug. I verified that after the fact. But "happened to be independent" is not a property I checked before publishing the number. I got lucky.

---

## The Uncomfortable Conclusion

If you're running automated evals on agent systems, I want you to sit with this:

The five passes deserved less of my attention than the one failure and the one bug. The passes confirmed that the voice agent can handle cooperative callers who give it enough conversational material to work with. That's necessary but not sufficient. That's the *easy* part.

The terse caller failure told me where the actual boundary of the system's capability sits. The transcript parsing bug told me that my *ability to analyze* that boundary was compromised at the infrastructure level. Together, they told me more about the state of the system than five green checkmarks ever could.

I've started running my eval analysis differently now. The first thing I look at isn't the pass rate. It's the failure mode of every non-pass, and then the integrity of the measurement apparatus itself. The passes get reviewed last, because passes are only meaningful in the context of what failed and whether I was measuring correctly.

5/6 is not success. 5/6 is a question you haven't finished asking.

---

CODEX_SCORE: 8/10
