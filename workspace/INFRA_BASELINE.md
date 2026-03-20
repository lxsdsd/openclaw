# INFRA_BASELINE.md

Last updated: 2026-03-20 11:50 Asia/Shanghai

## Purpose

Single operator handoff for this machine's OpenClaw infrastructure.

Use this file when:

- OpenClaw looks fresh after restart
- Feishu or other channels disappear
- Git / GitHub auth behaves differently from last time
- Docker was restarted or recreated
- OpenClaw wants to self-update or repair the stack
- A human or agent needs to know the current risks before making changes

Append timestamped notes here for infra-level findings that future sessions must know.
Append detailed low-level mutations to `CONFIG_CHANGELOG.md`.

## 2026-03-20 11:50 Asia/Shanghai

### Disk pressure and backup-first cleanup posture

- Windows `C:` was observed in emergency state during this pass with under `2 GB` free
- The live OpenClaw repo itself is **not** on `C:`; it lives on the Linux filesystem under `/home/gaga/openclaw`
- Therefore random workspace deletion is not the first lever for `C:` pressure
- The main cleanup candidates are more likely:
  - Docker Desktop image / build cache / old volumes
  - duplicated project artifacts
  - obsolete local recovery copies
  - project-local virtualenv / browser caches outside the canonical runtime

### Mandatory order before cleanup

1. verify canonical persistence paths still exist
2. save/push assistant-state backup
3. save/push project repos
4. only then prune redundant local artifacts

### Backup mapping that future sessions must not confuse

- Product repo: `/home/gaga/openclaw`
- Assistant state backup repo: `var/workspace/assistant-state-backup`
- English study project repo: `var/workspace/projects/english-study/repo`

Future sessions must not mix these three during commit or cleanup work.

### Completed backup refs from this pass

- assistant-state backup pushed to `origin/workspace-main`
- runtime/tooling backup pushed to `userfork/codex-runtime-backup-20260320`
- English study repo pushed to `origin/main`

### Git boundary rule re-confirmed

- Root `openclaw` repo dirt is not automatically “missing product commits”
- On this machine, root `git status` also sees live runtime files under `var/workspace`, nested backup repos, and nested project repos
- Therefore “many local files not yet pushed” must be classified before committing:
  - runtime state -> assistant backup repo
  - English study work -> English study repo
  - product code / scripts / compose / Dockerfiles -> product repo
- A fresh `assistant-state-backup/save-point.sh` sync confirmed the assistant backup repo already contains the current runtime notes and learnings from this pass

### Secret-bearing state is not part of code-repo backup

- Directory-structure review re-confirmed that some persistent paths are auth-bearing by nature:
  - `var/config/devices`
  - `var/config/identity`
  - `var/config/gh`
  - `var/config/credentials`
  - `var/xiaohongshu-mcp/cookies.json`
  - `var/qmd-memory-service/.env`
- These paths were intentionally not pushed into the git backup repos during this pass
- Current recovery coverage for them is:
  - canonical bind-mounted persistence under `var/`
  - D-drive snapshot created before cleanup
- If future policy requires cloud backup for these paths, use encryption first; do not normalize raw-secret commits into the normal git repos

### What future sessions must remember from this pass

- The root repo was not “missing lots of uploads”; it was showing mixed visibility across:
  - product repo files
  - runtime workspace state
  - nested project repos
  - secret-bearing persistence paths
- That visibility problem is now locally suppressed by:
  - `scripts/apply-local-runtime-git-hygiene.sh`
  - `scripts/clear-local-runtime-git-hygiene.sh`
- Current cloud anchors after this pass:
  - product/tooling backup branch contains the hygiene helpers
  - assistant backup repo contains the updated handoff notes
  - English study repo contains the cleaned project history state
- Future sessions should treat “clean root `git status`” as a local operator convenience only, not as proof that runtime state has been backed up; backup truth still lives in the three canonical repos plus the D-drive snapshot path

### Git history visibility clarification

- A later audit confirmed all three repos currently have `0` commits that exist only locally and on no remote
- The confusing part was not missing pushes; it was the root repo tracking target
- Root `main` now tracks `userfork/codex-runtime-backup-20260320`
- This should reduce IDE confusion where already-pushed local runtime/tooling commits looked like unpushed divergence only because the comparison target was still `origin/main`

### Sensitive migration path improved

- Added encrypted secret-state backup scaffolding at:
  - `../../scripts/backup-sensitive-runtime-state.sh`
  - `../../scripts/restore-sensitive-runtime-state.sh`
- This is the correct next layer above “mounted persistence + D-drive snapshots”
- It is intended for migration and disaster recovery of secret-bearing runtime state without pushing raw auth material into the normal git repos
- Default archive target is on `D:`, not the pressure-constrained `C:`

### Cleanup findings from this pass

- The highest-risk reclaim target for `C:` was Docker build cache, not OpenClaw live state
- `/usr/bin/docker builder prune -af` reclaimed `14.56GB` of builder cache
- local image prune reclaimed very little by comparison
- despite that, `C:` stayed under `3 GB` free

Inference:

- reclaiming builder cache helps, but does not fully shrink the Windows-side virtual disk while the stack remains live
- future deeper reclaim likely needs a planned Windows/Docker/WSL compaction step after a safe shutdown window

### Runtime safety check after cleanup

- `scripts/verify-local-runtime.sh` passed after the cleanup pass
- canonical mounts, device state, GH state, QMD state, and the Xiaohongshu sidecar remained intact

## 2026-03-19 20:15 Asia/Shanghai

### Restart verification follow-up

- Re-ran the canonical restart path with `scripts/start-local-runtime.sh`
- Re-ran `scripts/verify-local-runtime.sh` immediately after recreate
- Confirmed the canonical containers came back with the expected mounts and services:
  - `openclaw-openclaw-gateway-1`
  - `openclaw-openclaw-cli-1`
  - `xiaohongshu-mcp`
- Confirmed Feishu still probes as `enabled, configured, running, works`
- Confirmed workspace-managed skills are still visible after recreate, including:
  - `agent-reach`
  - `multi-agent-dispatch`
  - `self-improvement`
  - `skill-vetting`
  - `tavily`
- Confirmed Xiaohongshu cookie persistence is still bound from `../xiaohongshu-mcp/cookies.json`

### Verification script finding

- The only failed check in the restart pass was Docker's `healthy` flag timing, not actual gateway availability
- `/healthz` recovered before Docker marked the container `healthy`
- Docker health eventually turned `healthy` on its own; this was a validation-window problem, not a runtime outage
- `scripts/verify-local-runtime.sh` now waits up to 120 seconds for container health so post-recreate audits do not false-fail during the normal recovery window

### Still open

- Full Docker Desktop stop/start persistence is still not validated end to end from this pass
- QMD backend is now proven for `main`, but a future pass should still watch one real memory write/read cycle after normal daily use
- Claude Code Hub is still only proven reachable on `127.0.0.1:23000`, not proven integrated into OpenClaw
- A real GitHub remote push probe still needs a dedicated run outside this current runtime restriction

## 2026-03-19 20:23 Asia/Shanghai

### Xiaohongshu MCP root cause

- `mcporter` project config was present, but the `xiaohongshu` server stayed offline inside the gateway container
- Root cause: `var/workspace/config/mcporter.json` used `http://localhost:18060/mcp`
- In this Docker topology, `localhost` inside `openclaw-gateway` points back to the gateway container itself, not to the sibling `xiaohongshu-mcp` container
- Verified that the sibling container is reachable from the gateway over the compose network at `http://xiaohongshu-mcp:18060/mcp`
- Updated the project MCP config to use the compose service name instead of `localhost`

### Impact

- Before this fix, `mcporter list xiaohongshu --json` reported:
  - `status: offline`
  - `connect ECONNREFUSED 127.0.0.1:18060`
- This explains why Xiaohongshu could look "running" at the Docker level while still failing end to end from OpenClaw
- After the endpoint fix, `mcporter list` now reports `xiaohongshu` healthy with 13 tools
- A real tool call (`xiaohongshu.check_login_status`) now reaches the MCP successfully, but the current result is `未登录`
- The cookie file is still persisted at `../xiaohongshu-mcp/cookies.json`, so the remaining gap is live re-login, not mount loss

## Canonical runtime

- Runtime config root: `../config/`
- Runtime workspace root: `.`
- Start: `../../scripts/start-local-runtime.sh`
- Verify: `../../scripts/verify-local-runtime.sh`
- Update: `../../scripts/update-local-runtime.sh`
- Runtime CLI: `../../scripts/openclaw-runtime-cli.sh`
- Integration audit: `../../scripts/audit-local-integrations.sh`
- Legacy-volume migration: `../../scripts/migrate-legacy-named-volume-state.sh`
- Snapshot: `../../scripts/snapshot-state-to-d.sh`
- Restore: `../../scripts/restore-state-from-d.sh`

Do not replace these with handwritten `docker compose` commands.

## Current audited state

Audit timestamp: 2026-03-19 20:10 Asia/Shanghai

### Runtime

- `openclaw-openclaw-gateway-1` is healthy on `127.0.0.1:18789`
- Canonical config/workspace mounts are active
- Canonical GH mount is active
- Pairing state is persisted under `../config/devices/`
- Main agent model chain was restored to `rightcode/gpt-5.4`
- A full canonical container teardown + recreate preserved:
  - agent registry and workspaces
  - Feishu runtime reconnect
  - Xiaohongshu cookie persistence
  - canonical bind mounts
- Gateway health can return connection resets for roughly the first 10–20 seconds after recreate before settling to `200`

### Feishu

- Root cause was confirmed: historical Feishu state lived in the old Docker named volume `openclaw_openclaw_state`, not in the canonical bind-mounted config root
- `channels.feishu` is now restored into `../config/openclaw.json`
- Feishu non-secret runtime state restored into canonical root:
  - `../config/credentials/feishu-default-allowFrom.json`
  - `../config/feishu/dedup/default.json`
- Runtime validation now confirms Feishu is actually connected and processing messages:
  - `starting feishu[default]`
  - `WebSocket client started`
  - `ws client ready`
  - inbound DM events and dispatch completions appear in gateway logs
- Feishu is no longer only “configured”; it is live again

### Git / GitHub

- Repo remotes exist: `origin`, `userfork`
- `remote.pushDefault` is `userfork`
- Global Git credential helper points to the canonical script bridge, not the old WSL compose chain
- `git credential fill` returns a username/password pair via the helper bridge
- This means the auth bridge is alive, but actual network push should still be verified with a real `push --dry-run` or `ls-remote` when needed

### Xiaohongshu / agent-reach / MCP

- `xiaohongshu-mcp` container is up
- Persistent cookie file exists at `../xiaohongshu-mcp/cookies.json`
- portable `mcporter` config exists at `config/mcporter.json`
- live gateway `mcporter` config is bind-mounted at `/app/config/mcporter.json`
- live `mcporter list --json` now reports `xiaohongshu`, `exa`, and `weibo` as healthy
- `xiaohongshu-mcp` now also reads persisted cookies from the correct live path `/app/cookies.json`
- `check_login_status` now returns `✅ 已登录`
- `agent-reach` is recorded as runtime-visible in `SKILL_INDEX.md`
- `start-local-runtime.sh` now explicitly restores `xiaohongshu-mcp` so a normal canonical restart does not silently leave it down

### Memory / QMD / self-improving

- OpenClaw `main` now runs with native `qmd` memory backend
- verified by `scripts/openclaw-runtime-cli.sh memory status --agent main --json`
- live `dbPath` is `/home/node/.openclaw/agents/main/qmd/xdg-cache/qmd/index.sqlite`
- `main` QMD state persists on D drive at `/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd`
- do not confuse this with the separate `var/qmd-memory-service/` sidecar, which is not the current source of truth for `main` memory
- `self-improving-agent` workspace files exist and `.learnings/` is initialized:
  - `.learnings/LEARNINGS.md`
  - `.learnings/FEATURE_REQUESTS.md`
  - `.learnings/ERRORS.md`
- `skill-vetting` and `tavily` are present in workspace skill records

### Claude Code Hub

- `claude-code-hub-app-1` is healthy on `127.0.0.1:23000`
- Important limitation: service health only proves it is running, not that OpenClaw is actively consuming it

### Runtime caveats observed in logs

- Gateway warns that it binds non-loopback inside the container and relies on Docker host port binding for local-only exposure
- Some agent tool reads failed because the agent attempted host/repo-root paths that are not guaranteed to exist inside the workspace context:
  - missing `memory/2026-03-19.md`
  - missing direct reads of `LOCAL_SETUP.md`, `STATE_SOP.md`, and scripts from non-workspace paths
- Operational rule: prefer `INFRA_BASELINE.md` and workspace-relative docs first during agent troubleshooting

## Known risks still present

### P0: legacy Docker named volumes still exist

- `openclaw_openclaw_state`
- `openclaw_openclaw_gh_config`

These are the biggest remaining persistence footgun.

Why this matters:

- They are evidence of the old non-canonical runtime root
- If someone starts OpenClaw with the wrong compose chain again, state may split again
- Future troubleshooting can look like "data disappeared" even when it moved into the wrong root

Current policy:

- Do not delete them yet
- Keep them quarantined until the canonical runtime passes more end-to-end checks
- Use `../../scripts/migrate-legacy-named-volume-state.sh` before any cleanup

### P0: Feishu credentials are recovered but need hygiene review

- Feishu config was restored from the legacy volume into canonical config
- This is the correct move for state continuity
- But it also means credential storage format should be reviewed later and possibly migrated to a cleaner env/SecretRef path after stability is confirmed

Do not rotate or rewrite this path blindly during stabilization.

### P1: live `mcporter` config can drift if `/app/config/mcporter.json` is not mounted from workspace

- `mcporter` is designed to use `./config/mcporter.json`
- In the container, the live path is `/app/config/mcporter.json`
- If this file is not bind-mounted from `var/workspace/config/mcporter.json`, the gateway falls back to the image-baked config and silently loses later MCP additions like `xiaohongshu`
- This is the same class of failure as other past issues on this machine: editing a plausible file that is not the live runtime source

### P1: UI / in-container self-update is not the safe update path

- This stack uses a custom Docker image (`openclaw-agent-reach:local`)
- In-container self-update is not the persistent source of truth here
- Safe update path remains `../../scripts/update-local-runtime.sh`

### P1: host `openclaw` binary is not in host PATH

- This is acceptable as long as all operators use `../../scripts/openclaw-runtime-cli.sh`
- It is still a usability risk if someone assumes `openclaw ...` on the host shell is canonical

### P1: `.env` changes are not hot-reloaded

- If `.env` changes, Docker services must be recreated
- A restart alone is not sufficient

### P2: Docker Desktop auto-start was not re-verified in this pass

- Current audit verified container health after Docker is up
- It did not prove Windows login -> Docker Desktop auto-start -> WSL runtime auto-recovery end to end
- `docker-desktop-settings-store.backup.json` contains `AutoStart=false`, so there is a concrete machine-level risk that Docker Desktop still will not auto-launch after Windows login until the user enables it

## WSL2 + Docker Desktop operational realities

These are architecture-level constraints, not bugs:

- Bind mounts and Docker named volumes are different persistence systems
- WSL filesystem edits can diverge from what the running Docker Desktop VM is actually using if the wrong compose chain is invoked
- Windows Docker wrappers and WSL-native Docker CLI are not interchangeable on this machine
- Localhost-only service publishing is safe by default, but host-side `tailscale serve` can still expose services if configured incorrectly
- Rebuilds and recreates are cheap; state recovery is expensive; always snapshot before cleanup or update

## What OpenClaw must read first

When OpenClaw needs to understand this machine before acting, read in this order:

1. `INFRA_BASELINE.md`
2. `OPENCLAW_RUNTIME_STATUS.md`
3. `CONFIG_CHANGELOG.md`
4. `TODO_USER.md`

## 2026-03-19 21:05 Asia/Shanghai

### Native QMD backend confirmed

- rebuilt the canonical custom image with a working global `qmd` CLI
- enabled `memory.backend = "qmd"` in `var/config/openclaw.json` via `scripts/enable-qmd-memory-backend.sh`
- verified live runtime status reports `backend: "qmd"` for `main`
- verified `main` QMD state is mounted to D drive at `/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd`

### Xiaohongshu live config root corrected

- confirmed the portable MCP config file was correct but the running gateway was still reading an unmounted `/app/config/mcporter.json`
- fixed the runtime by bind-mounting `var/workspace/config/mcporter.json` into `/app/config/mcporter.json`
- extended restart and verify scripts so this mount is recreated and audited every time
- then confirmed a second live-path issue: the MCP process reads `cookies.json` relative to `/app`, while compose had mounted the cookie file at `/cookies.json`
- fixed the runtime by mounting `var/xiaohongshu-mcp/cookies.json` into `/app/cookies.json`
- current Xiaohongshu status is restored and logged in

## Pending checklist

### P0

- [x] Send a real Feishu test message and confirm receive + reply path
- [ ] Verify canonical runtime remains stable across one full Docker Desktop restart
- [x] Verify OpenClaw still opens the same agents / workspace after container teardown + recreate

### P1

- [x] Prove whether QMD is only healthy or actually integrated into OpenClaw memory flow
- [ ] Verify GitHub cloud push with a real `push --dry-run userfork main`
- [ ] Verify `agent-reach` end-to-end path with a real action, not just file presence
- [x] Restore live Xiaohongshu MCP registration inside the running gateway
- [x] Restore Xiaohongshu MCP login from persisted cookies
- [ ] Verify Claude Code Hub is reachable and decide whether OpenClaw should integrate with it or leave it standalone
- [ ] Decide whether to create workspace-local mirrors for critical ops docs so the agent never fails on non-workspace path reads

### P2

- [ ] Decide when to retire the old Docker named volumes after enough validation
- [ ] Decide whether to migrate Feishu secrets from restored legacy style to a cleaner env/SecretRef path
- [ ] Add a machine-local skill if repetitive recovery / audit steps keep recurring

## Change protocol

Every future infra repair should do all of the following:

1. Add a timestamped note here
2. Append the detailed mutation to `CONFIG_CHANGELOG.md`
3. If the rule changes, update `LOCAL_SETUP.md` or `STATE_SOP.md`
4. If the issue is recurring, consider encoding it into a script or skill
