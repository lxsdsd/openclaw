# OpenClaw State SOP

## Canonical state

- Runtime state root: `var/config/`
- Runtime workspace root: `var/workspace/`
- Local startup entrypoint: `scripts/start-local-runtime.sh`
- Local verification entrypoint: `scripts/verify-local-runtime.sh`
- Canonical in-container CLI entrypoint: `scripts/openclaw-runtime-cli.sh`
- Runtime startup includes `xiaohongshu-mcp`; avoid partial service restores.

## What must survive migration

- `var/config/openclaw.json`
- `var/config/agents/`
- `var/config/devices/`
- `var/config/gh/`
- `var/config/identity/`
- `var/config/memory/`
- `var/config/skills/`
- `var/config/exec-approvals.json`
- `var/config/node.json`
- `var/workspace/`
- `var/workspace/config/mcporter.json`
- `var/xiaohongshu-mcp/`
- `var/qmd-memory-service/`

## Snapshot

- Create D-drive bundle: `./scripts/snapshot-state-to-d.sh`
- Bundle root: `/mnt/d/OpenClaw/state-bundles/openclaw/current`

## Restore

- Restore from D-drive bundle: `./scripts/restore-state-from-d.sh`
- After restore, restart with: `./scripts/start-local-runtime.sh`
- Then verify with: `./scripts/verify-local-runtime.sh`

## Updates

- Canonical host-side update entrypoint: `./scripts/update-local-runtime.sh`
- Do not rely on in-container self-update as the persistent update path for this Dockerized stack.
- Why:
  - the runtime is a recreated Docker container
  - the image is a custom local build on top of upstream OpenClaw
  - mounted state persists, but ad-hoc package updates inside the container do not
- Safe update order:
  - snapshot
  - rebuild image with upstream pull
  - recreate runtime
  - verify mounts and health

## MCP / mcporter

- Portable source of truth: `var/workspace/config/mcporter.json`
- Live gateway path: `/app/config/mcporter.json`
- Startup must bind-mount the workspace file into the live gateway path
- If MCP servers disappear after restart, verify the live mount before editing workspace notes or reinstalling tools

## QMD

- Main OpenClaw memory backend is native `qmd`, enabled in `var/config/openclaw.json`
- Enable/update config: `./scripts/enable-qmd-memory-backend.sh`
- Verify live backend: `./scripts/openclaw-runtime-cli.sh memory status --agent main --json`
- Live container path: `/home/node/.openclaw/agents/main/qmd`
- Host persistence path: `${OPENCLAW_QMD_MAIN_DIR:-/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd}`
- `var/qmd-memory-service/` is a separate sidecar stack and is not the current source of truth for `main` memory

## Rules

- Do not use ad-hoc `docker compose up` for local OpenClaw.
- Do not use `docker-compose.wsl.yml` as part of the canonical runtime or Git credential chain on this machine.
- Do not treat `~/.openclaw/` as the canonical Docker runtime state.
- If Docker named volumes `openclaw_openclaw_state` or `openclaw_openclaw_gh_config` still exist, inspect and migrate them before cleanup; they are evidence of an older runtime root.
- If runtime looks fresh, verify mounts and state before attempting recovery.
