# SKILL_INDEX.md

## Purpose

Canonical index of installed, local, and planned skills. Every skill should have an entry before use or installation.

## Status legend

- `planned`: requested but not yet created or installed
- `local`: created locally in this workspace
- `installed`: pulled from an external registry and available for use
- `blocked`: rejected for security or quality reasons
- `review-needed`: discovered but not yet vetted

## Entries

| slug | status | source | version | owner | last_reviewed | risk | notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| skill-vetting | local | local-workspace | draft | local | 2026-03-12 | low | Local mandatory pre-install review workflow created in `skills/skill-vetting/`. |
| skill-vetter | local | local-workspace | unknown | unknown | 2026-03-12 | medium | Workspace skill present and ready; distinct from `skill-vetting`, used as an additional security-first review skill. |
| self-improving-agent | local | local-workspace | unknown | unknown | 2026-03-12 | low | Folder present in workspace; runtime skill name is `self-improvement`; loaded but `.learnings/` is not initialized yet. |
| tavily-search | local | local-workspace | unknown | unknown | 2026-03-12 | medium | Folder present in workspace; runtime skill name is `tavily`; loaded but depends on `TAVILY_API_KEY`. |
| agent-reach | installed | managed-local | unknown | unknown | 2026-03-12 | high | Runtime-visible under `/home/node/.openclaw/skills`; doctor runs and reports partial channel availability. |
| openclaw-skill-vetter | review-needed | clawhub | 1.0.0 | donovanpankratz-del | 2026-03-12 | unknown | Search hit found via clawhub; file inspection hit rate limit before full review. |

## Review rules

- No skill gets installed before it has an entry here.
- Any externally sourced skill must record source, owner, version, review date, and risk outcome.
- If a skill is rejected, keep the entry and mark it `blocked` with the reason.
- Update this file whenever a skill is created, installed, upgraded, blocked, or removed.
