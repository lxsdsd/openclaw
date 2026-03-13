# RECOVERY_AUDIT_2026-03-13.md

## Scope

This document records the OpenClaw recovery and verification work completed on 2026-03-13 for the currently running Docker / WSL environment.

It focuses on:

- workspace control files
- runtime-vs-host drift
- active skills and their readiness
- helper scripts used for OpenClaw operations
- remaining gaps that still need manual follow-up

## Runtime Source of Truth

- Active container: `openclaw-openclaw-gateway-1`
- Active UI / gateway bind: `127.0.0.1:18789`
- Runtime workspace actually used by OpenClaw: `/home/node/.openclaw/workspace`
- Host workspace often edited manually by user/Codex: `/home/gaga/openclaw/var/workspace`

### Key finding

The root cause of the missing personality / role / control behavior was workspace drift:

- host files had been updated
- runtime files inside the container were older / shortened
- OpenClaw UI and session bootstrap read the runtime files, not the host copies

## Restored Control Files

These files were checked and restored into the runtime workspace:

- `AGENTS.md`
- `SOUL.md`
- `ROLE.md`
- `TEAM_ROLES.md`
- `MAIN_CONTROL_POLICY.md`
- `HEARTBEAT.md`

### Verification summary

- `AGENTS.md`: restored from truncated 52-line runtime copy to a fuller version with session startup, memory rules, heartbeat guidance, sub-agent rules, and multi-agent dispatch rules
- `SOUL.md`: present and readable
- `ROLE.md`: present and readable
- `TEAM_ROLES.md`: present and readable
- `MAIN_CONTROL_POLICY.md`: present and readable
- `HEARTBEAT.md`: present and readable

### Runtime readability check

Verified that the runtime `node` user can read the restored control files.

## Agent / Role State

The runtime config currently registers these agents and display names:

- `main` -> `总控`
- `watchdog` -> `督办官`
- `builder-a` -> `主事官`
- `builder-b` -> `验收官`
- `research` -> `参谋官`
- `monetization` -> `商业化官`
- `delivery-lead` -> `交付官`
- `hr` -> `HR`

Important distinction:

- UI display names come from runtime agent registration in config
- workspace markdown files define behavior and operating rules
- both layers must be correct for the system to look and behave correctly

## Gateway / UI State

### Current status

- gateway container restarted successfully after recovery
- container health returned to `healthy`
- local UI root responds with HTTP 200 on `127.0.0.1:18789`

### Previously observed failure

- message dispatch and UI bootstrap were previously blocked by inability to open workspace control files
- ownership / readability problems were corrected earlier
- current runtime files are now readable

## Skills Loaded by Runtime Workspace

The runtime workspace currently exposes these custom workspace skills:

- `multi-agent-dispatch`
- `self-improving-agent`
- `skill-vetting`
- `tavily-search`

### Runtime `skills check` result

Relevant ready skills confirmed:

- `agent-reach`
- `github`
- `mcporter`
- `summarize`
- `multi-agent-dispatch`
- `self-improvement`
- `skill-vetting`
- `tavily`

### Important naming note

The installed skill folder is `skill-vetting`, and the runtime-ready skill name is also shown as `skill-vetting`.
If the user refers to `skill-vetter`, that is a naming mismatch in conversation, not proof that the runtime is missing the skill.

## Skill Verification Details

### Tavily

Status:

- ready in `skills check`
- `TAVILY_API_KEY` is present in runtime environment
- direct minimal Tavily search command returned results successfully

Conclusion:

- Tavily is activated and functioning

### Self-Improvement

Status:

- ready in `skills check`
- hook `self-improvement` is listed as ready in `hooks list`
- workspace learning files exist:
  - `.learnings/LEARNINGS.md`
  - `.learnings/ERRORS.md`
  - `.learnings/FEATURE_REQUESTS.md`

Conclusion:

- self-improvement is activated
- bootstrap reminder hook is enabled
- logging substrate is present

### Skill-Vetting

Status:

- ready in `skills check`
- runtime workspace contains `/home/node/.openclaw/workspace/skills/skill-vetting/SKILL.md`

Conclusion:

- skill-vetting is loaded by the running OpenClaw
- no missing requirement was reported by runtime skill checks

## Helper Scripts Reviewed

The following helper scripts currently exist in `/home/gaga/bin`:

- `openclaw-health-check`
- `openclaw-restart-stack`
- `openclaw-rebuild-stack`
- `openclaw-gh-login`
- `openclaw-gh-status`
- `openclaw-context-safe-rollback`

### Script summary

#### `openclaw-health-check`

Purpose:

- check compose state
- check OpenClaw health
- probe channels
- confirm runtime tools like `rg`, `summarize`, `mcporter`, `gh`, `python3`
- check `openclaw-node.service`

#### `openclaw-restart-stack`

Purpose:

- restart compose stack
- restart `openclaw-node.service`
- run health check afterward

#### `openclaw-rebuild-stack`

Purpose:

- rebuild gateway + CLI images
- bring stack back up
- restart `openclaw-node.service`
- run health check afterward

#### `openclaw-gh-login`

Purpose:

- ensure container GH config directory exists with correct ownership
- run `gh auth login` inside running gateway container

#### `openclaw-gh-status`

Purpose:

- show GitHub authentication state inside running gateway container

#### `openclaw-context-safe-rollback`

Purpose:

- switch context engine back to legacy
- disable `context-safe` plugin
- restart stack

## Known Working Pieces Preserved

- gateway stays loopback-bound
- gateway auth remains enabled
- Feishu channel remains configured
- GitHub auth inside container had already been restored earlier
- `mcporter` runtime exists and is ready
- `agent-reach` is ready

## Gaps / Pending Manual Follow-Up

### `GITHUB_TOKEN` pass-through

Current status:

- not yet confirmed as passed through from host shell into Docker runtime
- if needed for a specific skill or tool, compose environment passthrough still needs to be added

### Missing optional skill requirements

Many bundled skills remain unavailable because they require:

- extra CLIs
- extra API keys
- macOS-only tooling
- additional channel configuration

This is normal and not a recovery bug.

## Final Recovery Judgment

- Core workspace control files: restored
- Runtime/UI availability: restored
- Agent display registration: present in runtime config
- Custom workspace skills: present and recognized by runtime
- Tavily: working
- Self-improvement: working
- Skill-vetting: loaded and ready

The main resolved issue was not total data loss; it was runtime drift between host-edited files and the actual container workspace.

## Continued Recovery Work

### Legacy `skill-vetter` preserved

The older host-side `skill-vetter` artifact has been archived into:

- `recovered-skills/skill-vetter/README.md`
- `recovered-skills/skill-vetter/SKILL.md`
- `recovered-skills/skill-vetter/_meta.json`
- `recovered-skills/skill-vetter/.clawhub/origin.json`

This keeps the legacy artifact inside the workspace backup surface without loading it as a second active runtime skill.

Current runtime canonical skill remains:

- `skills/skill-vetting/SKILL.md`

### `xiaohongshu-mcp` cookies persistence implemented

Before this change:

- container `xiaohongshu-mcp` had no bind mounts
- `/cookies.json` lived only inside the container
- container rebuild or recreation could silently drop login state

After this change:

- compose-managed service `xiaohongshu-mcp` was added
- host cookie file path is now `var/xiaohongshu-mcp/cookies.json`
- service bind-mounts that file to `/cookies.json`
- container remains loopback-bound on `127.0.0.1:18060`

Validation:

- Docker mount inspection shows `/cookies.json` is now backed by the host file
- host cookie file exists and is non-empty
- `mcporter list` reports `xiaohongshu` healthy after container recreation
