# Local OpenClaw setup notes

- Docker runtime listens on the container network, but published host ports are bound to `127.0.0.1` only.
- Tailscale exposure is configured on the host with `tailscale serve`.
- Sensitive values are left as placeholders by design.

## Manual secrets to fill later

- `OPENCLAW_GATEWAY_TOKEN` in `.env`
- `RIGHTCODE_API_KEY` in `.env`
- `https://laptop-hacnr4t5.taildcef12.ts.net` in `var/config/openclaw.json`
- Your model/provider credentials in `var/config/openclaw.json` or environment variables

## Start

`docker build -t openclaw-agent-reach:local -f Dockerfile.agent-reach .`

`./scripts/start-local-runtime.sh`

## Canonical local files

- Runtime config: `var/config/openclaw.json`
- Runtime state root: `var/config/`
- Runtime workspace: `var/workspace/`
- GitHub auth state: `var/config/gh/`
- Device pairing state: `var/config/devices/`
- MCP config: `var/workspace/config/mcporter.json`
- Xiaohongshu cookie state: `var/xiaohongshu-mcp/cookies.json`
- Base compose: `docker-compose.yml`
- Long-term local override: `docker-compose.agent-reach.yml`
- D-drive bundle root: `/mnt/d/OpenClaw/state-bundles/openclaw/current`
- QMD service root: `var/qmd-memory-service/`
- QMD data root: `/mnt/d/OpenClaw/qmd-memory`

## Post-start checks

- Container health: `~/bin/docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'`
- Runtime verification: `./scripts/verify-local-runtime.sh`
- Canonical in-container CLI: `./scripts/openclaw-runtime-cli.sh ...`
- Snapshot to D drive: `./scripts/snapshot-state-to-d.sh`
- Gateway probe: `python3 - <<'PY'`
  `import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:18789/healthz', timeout=5).read().decode())`
  `PY`

## Safe updates

- Do not treat Control UI `update.run` or in-container `openclaw update` as the primary update path for this machine.
- This stack runs a custom Docker image (`openclaw-agent-reach:local`) built from `ghcr.io/openclaw/openclaw:latest` plus local packages/tools.
- A self-update performed inside a running container can be lost on the next container recreate.
- Preferred host-side update entrypoint: `./scripts/update-local-runtime.sh`
- Safe update flow:
  - snapshot mounted state to D drive
  - rebuild the custom Docker image with `--pull`
  - recreate the runtime with `./scripts/start-local-runtime.sh`
  - verify mounts and health with `./scripts/verify-local-runtime.sh`
- Data persistence depends on these mounted paths staying intact:
  - `var/config/`
  - `var/workspace/`

## Runtime root rule

- Do not start local OpenClaw with a bare `docker compose up` from memory.
- Always use `./scripts/start-local-runtime.sh`.
- Do not use `docker-compose.wsl.yml` for this machine's steady-state OpenClaw runtime or Git credential helper path.
- `var/config/` is the canonical runtime state root used by Docker.
- The startup script only seeds `var/config/` from `~/.openclaw/` when `var/config/openclaw.json` is missing; it does not overwrite canonical runtime state on every start.
- The startup script also restores `xiaohongshu-mcp`; avoid partial restarts that only bring back gateway/cli.
- If startup looks like a fresh instance again, run `./scripts/verify-local-runtime.sh` before doing any recovery work.

## Integration persistence

- GitHub auth for containerized `gh` must persist under `var/config/gh/`.
- Host Git should use `./scripts/gh-git-credential.sh` as the credential helper bridge into the live gateway container.
- Manual OpenClaw CLI operations should use `./scripts/openclaw-runtime-cli.sh ...` instead of a handwritten `docker compose exec ...`.
- `mcporter` config belongs under `var/workspace/config/mcporter.json` and is already inside the portable workspace bundle.
- Xiaohongshu cookies must stay under `var/xiaohongshu-mcp/cookies.json`; that path is now part of D-drive snapshots and restores.
- Pairing state belongs under `var/config/devices/`; if pairing disappears, audit the runtime root before re-pairing.
- `channels.feishu` was recovered on 2026-03-19 from the legacy named volume into `var/config/openclaw.json`; do not assume older backup roots are canonical.
- If legacy named volumes still exist (`openclaw_openclaw_state`, `openclaw_openclaw_gh_config`), treat them as stale runtime roots and inspect/migrate them with `./scripts/migrate-legacy-named-volume-state.sh` before deleting anything.

## Migration

- Create portable bundle: `./scripts/snapshot-state-to-d.sh`
- Restore portable bundle: `./scripts/restore-state-from-d.sh`
- The portable bundle includes:
  - `var/config/`
  - `var/workspace/`
  - `var/xiaohongshu-mcp/`
  - `var/qmd-memory-service/`
  - `git-repos/` bundles + dirty-worktree diffs + untracked-file archives
  - startup / verification scripts
  - Docker override and local setup notes

## QMD

- Install QMD on D drive: `./scripts/install-qmd-memory.sh`
- Verify QMD: `./scripts/verify-qmd-memory.sh`
- QMD binds to loopback only:
  - HTTP: `127.0.0.1:16333`
  - gRPC: `127.0.0.1:16334`

## Model provider rule

- Do not keep a provider-specific model as the default in `var/config/openclaw.json` unless that provider's secret is already available inside the container runtime.
- If a provider key is not ready yet, remove that provider from startup config first; add it back after runtime is stable.

## Host Tailscale Serve

`tailscale serve --bg 443 http://127.0.0.1:18789`
