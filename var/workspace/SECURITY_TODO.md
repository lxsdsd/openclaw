# SECURITY_TODO.md

## Priority 0 - Do first

- [x] Stop exposing the OpenClaw gateway on LAN; changed bind mode from `lan` to `loopback`.
- [x] Rotate the current gateway token to a long random value.
- [x] Define a default sensitive-path policy before any broader filesystem work.
- [x] Keep `web_search` disabled until a provider key is intentionally configured with spending limits.

## Priority 1 - Hardening

- [x] Disable elevated execution by default (`tools.elevated.enabled: false`).
- [x] Disable browser evaluate execution (`browser.evaluateEnabled: false`).
- [x] Tighten browser SSRF posture (`browser.ssrfPolicy.dangerouslyAllowPrivateNetwork: false`).
- [x] Decide whether browser control should remain enabled at all; disabled it by default.
- [x] Reconnect local control clients after token rotation; gateway RPC and Feishu are healthy again.
- [x] Verify `tavily` is live with the intentionally added API key before treating it as an available research path.
- [ ] Review `openclaw security audit --fix` output before deciding whether to apply it.
- [ ] Finalize bootstrap/identity cleanup after the user decides whether to keep refining those files now.
- [x] Make `skill-vetting` the default gate before any future skill install or update.
- [ ] Re-check the external `openclaw-skill-vetter` package after rate limits clear; this is backlog follow-up, not the current front-of-queue task.

## Priority 1.5 - Knowledge hygiene

- [x] Create a canonical skill index.
- [x] Create a canonical markdown/knowledge index.
- [x] Create a canonical pitfalls log.
- [x] Create a best-practices file for reusable standards.
- [x] Create a live status board for parallel work and blockers.
- [ ] Add a project-tracking convention for multiple parallel codebases (actively tracked in `TODO_LONG.md`).
- [x] Add a structured backlog convention for future capability tracks (`BACKLOG_CONVENTION.md`).
- [ ] Keep all future durable `.md` files registered in `KNOWLEDGE_INDEX.md`.
- [ ] Keep all future lessons and near-misses recorded in `PITFALLS.md`.
- [x] Treat `find-skill` as unavailable unless a runtime-visible install exists under the active OpenClaw skill roots.

## Priority 2 - Safe operating policy

- [x] Maintain a deny-by-default list for private data stores and credential locations.
- [x] Add a short runbook for what the assistant may read freely, what requires approval, and what is forbidden.
- [x] Prefer local-only access over LAN exposure.

## Research follow-up

- [x] Re-check public OpenClaw advisories for recent security topics.
- [x] Do a second pass on public issues/PRs specifically for accidental spend, billing surprises, or cost-footguns.
- [x] Convert the relevant findings into local controls and a cost-guardrail file.
