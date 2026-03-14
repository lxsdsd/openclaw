# Learnings Log

Captured learnings, corrections, and discoveries. Review before major tasks.

---

## [2026-03-13] Verify live OpenClaw state from runtime, not the host-side default CLI config

- Host-side `node openclaw.mjs ...` can report false negatives when it falls back to missing `~/.openclaw/openclaw.json` and targets the wrong gateway.
- For this stack, treat `/home/gaga/openclaw/var/config/openclaw.json`, `wsl-host` health checks, and live gateway probes as the source of truth before deciding that an agent, channel, or skill is missing.

---
