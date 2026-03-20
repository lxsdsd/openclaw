# OpenClaw Runtime Status

Last updated: 2026-03-20

## Purpose

This file is the single short handoff for OpenClaw itself.
Read this before attempting repair, restart, update, pairing, agent recovery, or config repair on this machine.

## Canonical runtime

- Runtime config root: `var/config`
- Runtime workspace root: `var/workspace`
- Canonical startup entrypoint: `scripts/start-local-runtime.sh`
- Canonical verification entrypoint: `scripts/verify-local-runtime.sh`
- Canonical host-side update entrypoint: `scripts/update-local-runtime.sh`
- Canonical migration snapshot entrypoint: `scripts/snapshot-state-to-d.sh`

## Do not infer the wrong root

Treat these as non-canonical unless a human explicitly tells you otherwise:

- `~/.openclaw`
- Docker named volumes
- temporary recovery directories
- backup directories
- workspace markdown alone

For this machine, the Docker runtime must use the mounted host paths:

- `var/config -> /home/node/.openclaw`
- `var/workspace -> /home/node/.openclaw/workspace`
- `var/workspace/config/mcporter.json -> /app/config/mcporter.json`

## MCP config rule

- The portable source of truth for `mcporter` is `var/workspace/config/mcporter.json`
- The running gateway reads `/app/config/mcporter.json`
- Therefore the Docker runtime must bind-mount the workspace file into `/app/config/mcporter.json`
- If `xiaohongshu`, `weibo`, or other MCP entries disappear after restart, check this mount before editing any other file
- `xiaohongshu-mcp` also reads `cookies.json` relative to `/app`, so the persisted cookie file must be mounted at `/app/cookies.json`, not at `/cookies.json`

## QMD status

- `main` now uses native OpenClaw `qmd` memory backend, not builtin SQLite
- Verified status comes from `scripts/openclaw-runtime-cli.sh memory status --agent main --json`
- Live `dbPath` is under `/home/node/.openclaw/agents/main/qmd/...`
- Host persistence path is `${OPENCLAW_QMD_MAIN_DIR:-/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd}`
- Do not confuse this with the separate `var/qmd-memory-service/` sidecar stack; that sidecar is not the current OpenClaw main memory backend

## Important distinction

There are two different shapes of agent-related files:

1. Runtime registrations
   - live config in `var/config/openclaw.json`
   - live runtime state in `var/config/agents`
   - this is what the UI and gateway actually use

2. Workspace role files
   - `var/workspace/agents/<id>/...`
   - these are role docs, assignment boards, notes, and prompts
   - these do not automatically make an agent appear in the UI

If UI and markdown disagree, trust live runtime config first.

## Multi-agent rule for this machine

Only `agents.list[]` in live config counts as a registered agent.

Potential independent workspaces discovered on disk:

- `var/workspace-builder-a`
- `var/workspace-builder-b`
- `var/workspace-research`
- `var/workspace-watchdog`
- `var/workspace/agents/delivery-lead`
- `var/workspace/agents/monetization`

Role-doc directories under `var/workspace/agents/*` are not enough by themselves.
They must be registered explicitly in `var/config/openclaw.json` if they should appear in UI/runtime.

## Update policy

This runtime uses a custom local Docker image:

- image name: `openclaw-agent-reach:local`
- base image: upstream OpenClaw image
- local additions: extra CLI/tools/packages in `Dockerfile.agent-reach`

Consequences:

- in-container self-update is not the authoritative update path
- Control UI `update.run` may update the running container filesystem, but that can be lost on container recreate
- persistent state is preserved by mounted host directories, not by container internals

Safe update path:

1. `scripts/snapshot-state-to-d.sh`
2. `scripts/update-local-runtime.sh`
3. `scripts/verify-local-runtime.sh`

Do not use a bare `docker compose up` from memory.

## Current known issues

### 0. Local operator auth used to split across command families

- Root cause is now code-confirmed, not speculative:
  - `gateway status`
  - `gateway probe`
  - `gateway call`
  - `status --all`
  historically did not share one identical local-auth selection path
- Impact:
  - some commands could still report healthy service-level status while others failed with `missing scope: operator.read`, `1000 normal closure`, or `timeout`
- Current repair status:
  - a shared local operator-token preference path was added in source for trusted local self-connections
  - this reduces ambient env-token shadowing of paired device auth
- Important nuance:
  - this does **not** mean Docker-side gateway token env should be deleted blindly
  - service-side gateway auth and client-side operator auth are separate concerns on this machine
- Operational rule:
  - if a future session sees `gateway status` and `gateway call` disagree again, inspect local operator-device auth selection before touching container mounts or Feishu config

### 1. Agent UI visibility is incomplete

- Root cause: live runtime config is missing explicit `agents.list[]` registrations for the expected worker roster
- Effect: UI can show only `main` even though role/workspace files exist

### 2. Skills visibility and runtime registration are separate

- Local skills exist under `var/workspace/skills`
- Live config may still be missing related enablement or per-skill config
- Do not assume a skill is active only because its files exist

### 3. Feishu is not fully enabled in live runtime

- Logs already showed tool allowlist entries for Feishu without matching live plugin/config enablement
- Result: Feishu tools can appear as unknown allowlist entries and Feishu integration looks half-configured

### 4. Main session model path has a RightCode Responses-state failure

- Symptom: `HTTP 404 ... Item with id 'rs_...' not found. Items are not persisted when store is set to false`
- This is separate from mount health
- Do not misdiagnose it as a Docker mount loss by default

## Outage root cause

This machine's recurrent failures are not explained by a single Feishu bug.
The deepest root cause is runtime-state split plus inconsistent Docker control path.

### State split

Multiple OpenClaw state roots have existed on this machine:

- `var/config`
- `~/.openclaw`
- `openclaw_recovery`
- backup/config copies under workspace

If startup, restore, recovery, or repair work touches the wrong root, the running gateway can come up with:

- missing `channels.feishu`
- missing `agents.list`
- missing or stale device/pairing state
- stale provider/model config

That makes it look like Feishu, skills, agents, todo files, and personality all disappeared together.

### Docker control-path split

There was also an execution-path split:

- Windows wrapper path: `~/bin/docker` -> `docker.exe`
- WSL-native path: `/usr/bin/docker`

For this machine, using the wrong path can cause the operator to edit one WSL file tree while the running container effectively sees a different config snapshot.

### Mandatory guardrail

For local lifecycle commands on this machine:

- prefer `/usr/bin/docker`
- use `scripts/start-local-runtime.sh`
- use `scripts/verify-local-runtime.sh`
- do not treat Windows `docker.exe` wrapper control as equivalent for local repair work

## Repair order

When OpenClaw looks broken on this machine, use this order:

1. Verify runtime health and mounts
   - `scripts/verify-local-runtime.sh`
2. Confirm live config root and workspace root
3. Check `var/config/openclaw.json` for:
   - `agents.list`
   - `skills.entries`
   - live channel config
4. Only then investigate session/model/provider issues
5. Before risky repair, create a fresh D-drive snapshot

## What not to do

- Do not guess the runtime root
- Do not treat workspace markdown as live registration
- Do not treat container-local package updates as durable
- Do not start recovery by “restoring files” before verifying the active runtime root
- Do not recreate containers blindly without confirming the mounted config/workspace paths
