# Draft (Claude role) — Fast Is Not Default

There is a familiar trap in systems work: a beautiful number appears, and you start rewriting architecture around it before you ask what produced it.

That happened in our OmniParser spike.

At first glance, the rerun looked like a breakthrough. OmniParser posted a **0.033s median latency**. Florence, our current default, came in around **0.583s**. If you are scanning a summary table at speed, the decision seems obvious.

It wasn’t.

When we looked past the headline and into the run shape, the story changed.

The first OmniParser call on a new screenshot took **12.706s**. After that, repeated element queries on the same image were effectively free because they reused cached detections (`cache_hit=1`). So we had measured two different experiences in one bucket: an expensive initial parse and cheap follow-on queries.

That is not bad. It is just specific.

In other words, OmniParser did not prove “faster backend.” It proved “faster when the workload is parse once, query many.”

And our default desktop-control path is usually not that workload. Most calls are still one-shot: new screenshot, one query, one click.

The second signal was reliability. On the same fixture, Florence held **1.000 recall** and **1.000 specificity**. OmniParser held **0.750 recall** and **1.000 specificity**. In practical terms, that means OmniParser still missed positive targets too often to own default routing.

That tension, speed in one mode and misses in another, is exactly where teams make bad product decisions if they optimize from one summary metric.

We did the boring thing instead of the flashy thing:

- keep Florence as the default,
- merge OmniParser as an available option,
- reserve it for explicit workflows that benefit from a pre-parse cache.

The commit that matters (`a1f60d7`) is not dramatic. It does not claim victory. It encodes a boundary: available does not mean default.

That boundary is a quality habit.

A default backend is a policy decision. Policy should be built from the failure shape of real traffic, not the prettiest benchmark median in a controlled run.

If you want a reusable rule, use this one:

> Promote by reliability under your dominant workload. Demote by miss cost. Treat headline speed as a secondary filter unless the workload guarantees cache reuse.

This sounds conservative. It is actually how you move fast without lying to yourself.

A lot of engineering pain comes from systems that were “right in the demo mode” and wrong in the mode users actually live in.

The benchmark did its job. It gave us more than a number. It gave us a decision boundary.

That is what a meaningful spike is supposed to do.
