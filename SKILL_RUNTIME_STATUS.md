# SKILL_RUNTIME_STATUS.md

Last updated: 2026-03-19 14:00 UTC

## Purpose

This file is the short handoff for skill readiness, hook activation, and memory-related gotchas on this machine.
Show this to Codex before asking it to repair, restart, or "finish enabling" a skill.

## Read order

For OpenClaw repair or restart work, read in this order:

1. `INFRA_BASELINE.md`
2. `OPENCLAW_RUNTIME_STATUS.md`
3. `CONFIG_CHANGELOG.md`
4. `SKILL_RUNTIME_STATUS.md`

## Big-picture status

- Native OpenClaw memory backend for `main` is `qmd`
- `memory_search` is live and callable through QMD
- Current `openclaw memory status --agent main --json` reports:
  - `files = 13`
  - `sources = memory + sessions`
  - `vector.enabled = true`
  - `vector.available = true`
  - `dirty = false`
- Bundled `session-memory` hook is ready, so `/new` and `/reset` can flush session context into memory files
- Workspace `.learnings/` files exist and are initialized
- `self-improvement` skill is ready
- `self-improvement-reminder` hook now exists as a real discoverable workspace hook and is enabled in live config

## Plain-language answer: does self-learning auto-start now?

Mostly yes, with one important nuance.

What is now automatic:

- When a new agent session bootstraps, OpenClaw can automatically inject the self-improvement reminder
- That reminder nudges the agent to write into:
  - `.learnings/LEARNINGS.md`
  - `.learnings/ERRORS.md`
  - `.learnings/FEATURE_REQUESTS.md`

What is **not** automatic:

- It does not magically write learnings by itself with zero judgment
- The reminder only tells the agent to capture learnings when they matter
- The durable record still depends on the agent actually writing the note

So in plain Chinese:

- `自学习提醒` 现在已经接到了启动链路里
- 以后新会话启动时，会自动提醒记录经验
- 但它不是“全自动无脑记账机”，关键经验还是要由 agent 在合适的时候写进去

## Overall readiness snapshot

- `openclaw skills list` currently reports `19 / 61` skills as ready
- The remaining not-ready entries are mostly bundled skills blocked by missing binaries, missing API keys, missing channel/plugin config, or unsupported OS
- Those are dependency/config gaps, not evidence of a broken local skill startup path

## Current custom/local skill status

### Workspace / managed skills that are present and usable

- `agent-reach` — ready (`openclaw-managed`)
- `multi-agent-dispatch` — ready (`openclaw-workspace`)
- `self-improvement` — ready (`openclaw-workspace`)
- `skill-vetting` — ready (`openclaw-workspace`)
- `tavily` — ready (`openclaw-workspace`)

### Current hook status

- Bundled hooks ready:
  - `boot-md`
  - `bootstrap-extra-files`
  - `command-logger`
  - `session-memory`
- Workspace hook ready:
  - `self-improvement-reminder`

### Important conclusion

As of this check, there is **no remaining workspace/local skill directory that exists on disk but is missing from the runtime skill list**.

The one real activation gap we found was the self-improvement reminder hook. That gap has now been fixed.

## Exact self-improvement fix that was applied

Before fix:

- `skills/self-improving-agent/` existed
- `openclaw skills list` showed `self-improvement` as ready
- but `openclaw hooks list` had no self-improvement reminder hook

Root cause:

- the skill had reminder source files under `skills/self-improving-agent/hooks/openclaw/`
- but OpenClaw does **not** auto-discover hooks from inside skill folders
- a hook must live in a real hook directory such as:
  - `var/workspace/hooks/...`
  - `~/.openclaw/hooks/...`
- and it must include `HOOK.md`

Applied fix:

- added `hooks/self-improvement-reminder/HOOK.md`
- added `hooks/self-improvement-reminder/handler.ts`
- enabled it in live config
- added `skills/self-improving-agent/references/openclaw-integration.md`
- corrected stale instructions in `skills/self-improving-agent/SKILL.md`

## Files that now matter for this topic

- `hooks/self-improvement-reminder/HOOK.md`
- `hooks/self-improvement-reminder/handler.ts`
- `skills/self-improving-agent/SKILL.md`
- `skills/self-improving-agent/references/openclaw-integration.md`
- `.learnings/LEARNINGS.md`
- `.learnings/ERRORS.md`
- `.learnings/FEATURE_REQUESTS.md`

## Memory-system reality check

Use this mental model:

1. Markdown files are still the durable source of truth
2. QMD improves retrieval/search over those files
3. `session-memory` helps save context on `/new` and `/reset`
4. Important operational state should still be written into handoff docs, not left to memory alone

Do **not** assume "QMD enabled" means all repair context is safe forever unless it was actually written down.

## Known pitfalls to avoid next time

- A skill being `ready` does not mean its related hook is active
- A source-only `handler.ts` inside a skill directory is not enough for hook discovery
- Prefer workspace docs over stale or guessed paths
- Do not treat host-side `openclaw gateway restart` failure as proof that config changes were lost on this machine
- For restart/repair work, trust the canonical runtime notes in `OPENCLAW_RUNTIME_STATUS.md` before improvising

## Verification commands

Use these to re-check status:

```bash
openclaw skills list --json
openclaw hooks list --json
openclaw hooks info self-improvement-reminder
openclaw memory status --agent main --json
```

## Short answer for Codex

If Codex asks "what still is not enabled?" the answer right now is:

- No custom workspace skill is stuck in a half-enabled state anymore
- `self-improvement` was the only one with a real activation gap, and that hook gap is now fixed
- Many bundled skills are still not ready, but those are missing dependency/config cases, not broken startup state
