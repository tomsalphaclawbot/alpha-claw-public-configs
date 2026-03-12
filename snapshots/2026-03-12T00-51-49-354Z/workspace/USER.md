# USER.md - About Your Human

_Learn about the person you're helping. Update this as you go._

- **Name:** Tom Chapin
- **What to call them:** Tom
- **Pronouns:** _(optional)_
- **Timezone:** America/Los_Angeles
- **Notes:** Prefers a sharp, playful-intellectual assistant vibe that stays friendly and capable of humor while still being serious for focused work.

## Context

- Currently setting up OpenClaw channels and control workflows.
- Wants practical operations setup first: messaging integrations (Telegram/Discord) and agent/task visibility in dashboard.
- Discord workspace server name: `Voice Controller`.

## Contact & Identity Map (working draft)

### Tom contact addresses
- `[REDACTED_EMAIL]` — Tom personal sender address (used to send test emails to trigger automations)

### Assistant-managed mailboxes (for inbound to Alpha)
- `[REDACTED_EMAIL]` — active mailbox for assistant operations
- `[REDACTED_EMAIL]` — legacy/blocked assistant mailbox (do not rely on it)

### Known contact channels
- Telegram DM (primary fast path)
- Discord DM / `Voice Controller` server (secondary/fallback)
- Email triggers via Zoho mailbox (asynchronous operations/testing)

### Operating notes
- Treat sender identity as contextual; Tom may initiate from different verified addresses.
- For new/unknown sender addresses claiming to be Tom, request confirmation before sensitive actions.
- Default web workflow preference (2026-03-01): use `claude --dangerously-skip-permissions --chrome` first for browsing/web-page interaction tasks; use OpenClaw browser tool as fallback when Claude Chrome path is unavailable.
- Discord DM preference (2026-03-02, updated 2026-03-04): when Tom requests voice/audio responses, default to OpenClaw native voice replies.
- Secure-app browser login preference (2026-03-03): for Cloudflare Access OTP during browser automation, use assistant mailbox `[REDACTED_EMAIL]` and fetch codes via backend mail tooling.
- Context hygiene preference (2026-03-03): keep references minimal and avoid duplicating verbose policy text across many files.
- Learning capture requirement (2026-03-09): whenever I learn anything about how Tom works or what he needs, record it immediately in lessons/memory so Tom never has to repeat himself.
- Bi-directional learning preference (2026-03-09): lessons should flow both ways — I should not only learn from Tom, but also proactively surface and document improvements that help Tom work better with me.
- Website security preference (2026-03-09): remove/avoid public user-submitted prompt surfaces (example: “Plant a Seed”) to reduce prompt-injection attack surface.
- Writing workflow preference (2026-03-11): for blog/article creation, default to `docs/playbooks/society-of-minds-writing-methodology.md` (Codex + Opus/Claude + orchestrated synthesis), and treat it as a living process that should be iterated/versioned over time.
- Creative rigor preference (2026-03-11): heartbeat idle cycles should include blog/experiment work that intentionally challenges capability (“sharpen your iron”), not only routine output.
- Pointer-first writing preference (2026-03-11): keep a minimal Codex+Claude blog fast-path pointer (`docs/playbooks/blog-writing-fast-path.md`) so article runs do not waste cycles rediscovering workflow.
- Anti-loop publishing preference (2026-03-11): if Alpha and Claude exceed 5 unresolved rounds on one article, stop arguing and publish the best current draft with an explicit note that full consensus was not reached.
- Commit-cadence preference (2026-03-11): don’t hesitate to commit files; nightly automatic workspace commits already run, so default to timely commits for meaningful changes instead of over-batching.
- Blog cadence/quality preference (2026-03-11): autonomous writing should generally cap at one new blog post/day, and topics should be grounded in recent memory/learnings/real shipped work rather than random philosophical blather.

---

The more you know, the better you can help. But remember — you're learning about a person, not building a dossier. Respect the difference.
