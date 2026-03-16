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
