# The Draft That Wasn't Published — Claude Draft

**Contract lens: What the system promised, and to whom**

---

A publish date is a contract. The question is: between whom?

When you assign `publishDate: 2026-04-04` to an article, you're making a commitment — but the schema doesn't specify who holds the other end of that commitment. Is it a promise to readers (this will be live by then)? A promise to yourself (I will have finished this by then)? A promise to the pipeline (you may publish this when the date arrives)? All three are different. The schema treats them the same.

The blog guard does not distinguish between them either. It asks: how many articles are published today? One. Cap reached. Done.

Essays 091 and 094 sit with `publishDate: 2026-04-04` and `draft: true`. The date arrived. Nothing happened. From the pipeline's perspective, this is a normal state. From the perspective of whoever assigned those dates, it's a missed deadline — if they meant it as one.

The draft flag is a veto. Whatever the date says, the draft flag says *not yet*. That's its job. But "not yet" combined with a past date creates a new semantic that neither flag was designed to capture: *was scheduled, is now late*.

Most content systems don't surface this. The article sits in the queue, correctly marked draft, correctly excluded from publication counts, with a publishDate that has become historical metadata. The system is consistent. The state is incoherent.

The reason this matters: a queue of 140+ staged articles, many with future publish dates, relies on those dates being meaningful. If past-due drafts silently accumulate without any signal, the date field decays into decoration. Over time, nobody trusts it. Scheduling decisions stop happening because the feedback loop is gone — you can assign any date to anything, and whether it publishes or not, the system will continue to run cleanly.

There's a name for this: commitment without accountability. The system accepts promises but has no mechanism for noticing that they were broken. The guard enforces the cap. Nobody enforces the schedule.

This doesn't require a complicated fix. A simple audit — "find all articles where `draft: true` and `publishDate < today`" — would surface the candidates. Run it once a week. That's not a pipeline feature; it's a discipline. The question is whether the system is designed to surface the ambiguity or to silently absorb it.

Most systems absorb. The articles that weren't published today will still be there tomorrow, with their past-due dates, waiting for someone to notice. Or not.

---

The draft flag and the publishDate are both honest. They just don't talk to each other.

---

*Claude draft: 450 words*
