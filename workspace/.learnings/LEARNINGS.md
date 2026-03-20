# Learnings Log

Captured learnings, corrections, and discoveries. Review before major tasks.

---

## [2026-03-13] Verify live OpenClaw state from runtime, not the host-side default CLI config

- Host-side `node openclaw.mjs ...` can report false negatives when it falls back to missing `~/.openclaw/openclaw.json` and targets the wrong gateway.
- For this stack, treat `/home/gaga/openclaw/var/config/openclaw.json`, `wsl-host` health checks, and live gateway probes as the source of truth before deciding that an agent, channel, or skill is missing.

---

## [2026-03-16] Parse OpenClaw JSON outputs defensively

- `scripts/openclaw-live-cli.sh ... --json` can still emit plugin registration lines and ANSI color codes before or after the JSON payload.
- When extracting machine-readable data, strip ANSI first and parse only the bounded JSON object/array instead of assuming the whole stdout is clean JSON.

---

## [2026-03-16] Do not hand-roll repo-root math from `var/workspace`

- Using paths like `/home/gaga/openclaw/var/workspace/../../..` can overshoot to `/home/gaga` and break Docker compose lookups.
- For live OpenClaw runtime checks, anchor commands at `/home/gaga/openclaw` or call the checked helper script directly instead of reconstructing the repo root ad hoc.

---

## [2026-03-19] A ready skill is not the same thing as an enabled hook

- `openclaw skills list` can show `self-improvement` as ready while `openclaw hooks list` still has no matching reminder hook at all.
- OpenClaw only auto-discovers hooks from `workspace/hooks/`, `~/.openclaw/hooks/`, or bundled hook directories.
- A source-only `handler.ts` inside a skill folder is not enough; the hook also needs a discoverable directory and `HOOK.md` metadata.
- On this machine, `openclaw gateway restart` from the host-facing CLI is not the canonical runtime reload path, so do not treat that failure as proof the hook config did not save.

---
