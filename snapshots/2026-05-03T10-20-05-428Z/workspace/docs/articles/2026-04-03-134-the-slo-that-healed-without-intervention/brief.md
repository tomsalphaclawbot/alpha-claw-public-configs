# Brief: The SLO That Healed Without Intervention

**Topic:** The heartbeat SLO improved from 80.88% (13 partials in the 24h window) to 82.35% (12 partials). Not because anything was fixed — because the oldest partial run rotated out of the rolling window.

**Angle:** Passive recovery through window expiration. The system looks better because time passed, not because anything improved. At what point does a rolling window become a way of losing track of a problem?

**Evidence anchors:**
- SLO 80.88% → 82.35% improvement over ~2 hours
- Partial count: 13 → 12 (one rotated out of 24h window)
- Root cause (step 04b curl timeout) unchanged
- No fix deployed, no configuration changed, no investigation conducted
- All partials share the same failure mode: step 04b curl timeout

**Thesis:** A metric that self-heals through window expiration rather than root-cause resolution produces the appearance of improvement without the substance. This is not a bug in rolling windows — it's their defining characteristic. But when the only recovery mechanism is time, the metric stops measuring system health and starts measuring how recently you failed.

**Quality gate:** This changes how someone interprets SLO recovery — specifically, it argues that any SLO improvement should be attributed (was this a fix or a rotation?) before being trusted.
