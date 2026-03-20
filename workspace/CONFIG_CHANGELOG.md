# CONFIG_CHANGELOG.md

Use this file as an append-only log for OpenClaw configuration, runtime, and recovery changes.

Rules:

- record what changed
- record where it changed
- record whether the change was host-side, runtime-side, or both
- record the validation command or evidence
- do not paste secrets

---

## 2026-03-13

### Recovery baseline established

- Confirmed the running OpenClaw instance is the Docker container `openclaw-openclaw-gateway-1`
- Confirmed runtime workspace source of truth is `/home/node/.openclaw/workspace`
- Confirmed host workspace edits alone do not automatically fix runtime drift

### Restored root control files into runtime

Files restored / synced:

- `AGENTS.md`
- `SOUL.md`
- `ROLE.md`
- `TEAM_ROLES.md`
- `MAIN_CONTROL_POLICY.md`
- `HEARTBEAT.md`

Validation:

- runtime file presence confirmed
- runtime readability for the `node` user confirmed
- gateway restarted and returned healthy

### Recovered `AGENTS.md`

- Replaced a truncated runtime copy with a fuller version containing:
  - session startup rules
  - memory rules
  - heartbeat guidance
  - sub-agent usage rules
  - multi-agent operating model
  - dispatch authority rules

Validation:

- runtime `AGENTS.md` line count increased from 52 to 275

### Skill readiness rechecked

Confirmed ready:

- `agent-reach`
- `github`
- `mcporter`
- `summarize`
- `multi-agent-dispatch`
- `self-improvement`
- `skill-vetting`
- `tavily`

### Tavily check

- Confirmed runtime has `TAVILY_API_KEY`
- Ran a minimal Tavily search successfully

### Self-improvement check

- Confirmed `.learnings/` directory exists
- Confirmed `self-improvement` hook is ready

### Scripts reviewed

Reviewed helper scripts:

- `/home/gaga/bin/openclaw-health-check`
- `/home/gaga/bin/openclaw-restart-stack`
- `/home/gaga/bin/openclaw-rebuild-stack`
- `/home/gaga/bin/openclaw-gh-login`
- `/home/gaga/bin/openclaw-gh-status`
- `/home/gaga/bin/openclaw-context-safe-rollback`

### Logging policy added

Going forward, any config or runtime recovery work should be logged here instead of being kept only in transient chat history.

### Backup / rollback guardrails added

Added helper scripts:

- `/home/gaga/bin/openclaw-backup-state`
- `/home/gaga/bin/openclaw-restore-state`
- `/home/gaga/bin/openclaw-pre-cleanup-check`

Purpose:

- create a point-in-time backup before risky cleanup or rebuild work
- restore the latest or specified backup with one command
- inspect whether a cleanup target is actually safe before deleting Docker/runtime data

Added AGENTS guardrail:

- before deleting caches, Docker data, cookies, or workspace files, run `openclaw-pre-cleanup-check` and create a fresh snapshot with `openclaw-backup-state`

### Legacy skill-vetter archived

- copied legacy host-side `skills/skill-vetter` artifact into `var/workspace/recovered-skills/skill-vetter`
- kept it outside `workspace/skills` to avoid duplicate active runtime loading
- current runtime skill remains `skill-vetting`

### XiaoHongShu cookies persistence

- added `xiaohongshu-mcp` service to `docker-compose.agent-reach.yml`
- set loopback-only port mapping `127.0.0.1:18060:18060`
- mounted `./var/xiaohongshu-mcp/cookies.json` to `/cookies.json`

## 2026-03-20

### Backup target mapping re-confirmed

- Re-confirmed that three different git histories are in use and must not be mixed:
  - product/tooling repo: `/home/gaga/openclaw`
  - assistant runtime backup repo: `var/workspace/assistant-state-backup`
  - English study repo: `var/workspace/projects/english-study/repo`
- Re-confirmed that runtime markdown, learnings, memory, agent role files, and workspace-side skill notes belong in the assistant backup repo, not in the product repo
- Re-confirmed that English study delivery outputs belong in the English study repo, not in the product repo

Validation:

- `assistant-state-backup/save-point.sh` completed a fresh sync pass
- backup repo was already up to date after sync, so no additional runtime delta was left uncommitted there

### Root repo fake-dirty noise was reduced without touching runtime state

- Confirmed that the root repo `git status` noise was coming primarily from `var/workspace`, `var/config`, `var/qmd-memory-service`, and `var/xiaohongshu-mcp`
- Confirmed that this did **not** mean the product repo still had large amounts of unpushed product code
- Added two local-only git hygiene helpers:
  - `scripts/apply-local-runtime-git-hygiene.sh`
  - `scripts/clear-local-runtime-git-hygiene.sh`
- The apply script:
  - adds local excludes for runtime-state paths under `var/`
  - marks tracked `var/workspace` files as `skip-worktree`
  - leaves runtime files untouched
- The clear script removes the local-only hygiene rules and restores normal git visibility

Validation:

- after applying the hygiene script, root repo `git status` dropped from dozens of runtime-state entries to clean
- helper scripts were committed and pushed to `userfork/codex-runtime-backup-20260320`

### Cloud backup state re-verified

- Product/tooling backup branch tip now includes the local git hygiene helpers
- Assistant runtime backup repo tip now includes the updated handoff rules
- English study repo tip now includes removal of the stale `.git.broken-20260319-1916/config` tracked reference

Operational rule:

- if root repo `git status` explodes again after a fresh clone or reset, re-run `scripts/apply-local-runtime-git-hygiene.sh` before assuming data is missing from cloud backup

### Encrypted secret-state backup scaffolding added

- Added:
  - `scripts/backup-sensitive-runtime-state.sh`
  - `scripts/restore-sensitive-runtime-state.sh`
- Purpose:
  - create encrypted migration backups for secret-bearing runtime state
  - restore those backups back into the canonical repo root when needed
- Current design choices:
  - default output is on `D:` to avoid `C:` pressure
  - root `.env` is excluded by default
  - supported encryption modes are GPG recipient encryption and symmetric encryption with a passphrase file

### Root repo upstream tracking aligned with actual cloud backup branch

- Confirmed there were zero local commits missing from all remotes across:
  - product repo
  - assistant-state backup repo
  - English study repo
- Root cause of the “still so many local git versions” view was branch comparison, not missing pushes:
  - root `main` had been comparing against `origin/main`
  - the actual cloud home for local runtime/tooling backup commits is `userfork/codex-runtime-backup-20260320`
- Updated local tracking so root `main` now tracks `userfork/codex-runtime-backup-20260320`

Validation:

- `git log --branches --not --remotes` returns zero commits in all three repos
- `git branch -vv` for root repo now shows `main` tracking `userfork/codex-runtime-backup-20260320`
- copied current cookies from existing container into host file
- recreated `xiaohongshu-mcp` under compose with bind-mounted cookie storage

Validation:

- Docker mount shows host bind for `/cookies.json`
- `mcporter list` still reports `xiaohongshu` healthy

### Startup recovery hardening

Diagnosis:

- Docker Desktop backup settings showed `AutoStart: false`
- Linux side had `openclaw-node.service` but no dedicated stack-autostart service for `docker compose up -d`

Changes added:

- `/home/gaga/.config/systemd/user/openclaw-stack.service`
- `/home/gaga/bin/openclaw-wait-docker`
- `/home/gaga/bin/openclaw-install-startup-task`
- `/home/gaga/openclaw/scripts/windows-start-openclaw.ps1`

Intent:

- once Docker becomes ready, start the OpenClaw compose stack automatically
- start Docker Desktop and then trigger Linux user services from Windows login

Notes:

- Linux side service file and enable symlink were created
- Windows Startup item creation was blocked from WSL by host-side permissions/policy, so a one-time Windows-side command may still be needed

### Feishu dispatch `EACCES /home/gaga` repair

Symptom:

- Feishu dispatch failed with `EACCES: permission denied, mkdir '/home/gaga'`

Cause:

- runtime agent `workspace` paths point to `/home/gaga/openclaw/var/...`
- inside the container, those host paths were not mounted
- an attempted hotfix added `workspacePath`, but this OpenClaw build does not support that config key and the gateway stopped booting until the key was removed

Fix:

- added bind mount `- /home/gaga/openclaw/var:/home/gaga/openclaw/var` to both `openclaw-gateway` and `openclaw-cli` in `docker-compose.agent-reach.yml`
- removed unsupported `agents.list[*].workspacePath` from runtime config
- kept legal `workspace` keys pointing at the host-style paths
- restarted the gateway

Validation:

- `http://127.0.0.1:18789/healthz` returns 200
- gateway root `/` returns 200
- runtime config again shows valid `workspace` keys only

### Feishu tool surface unblocked for doc/drive

Diagnosis:

- current agent config used `tools.profile: "coding"`
- the `coding` profile excludes plugin tools, so `feishu_doc` / `feishu_drive` were hidden from this Feishu DM session even though the channel was active

Changes:

- updated `/home/gaga/openclaw/var/config/openclaw.json`
- updated `/home/gaga/openclaw/var/workspace/assistant-state-backup/config/openclaw.json`
- added `tools.allow: ["feishu_doc", "feishu_drive", "feishu_app_scopes"]`

Validation:

- local docs confirm plugin tools are filtered by `tools.profile` and can be added back via `tools.allow`
- config reload plan treats `tools.*` changes as dynamic / no-restart
- next fresh turn/session should expose Feishu doc/drive tools if account scopes are sufficient

### 2026-03-13 - WSL live-diagnostics path pinned to container runtime

Diagnosis:

- this WSL2 + Docker install keeps the real OpenClaw runtime state inside the gateway container at `/home/node/.openclaw`
- some host-side CLI checks can drift to a bad local state path and report false negatives for agents, Feishu tools, or cron

Changes:

- added `var/workspace/scripts/openclaw-live-cli.sh` as the safe local entrypoint for diagnostics against the running gateway container
- added `var/workspace/WSL_DOCKER_RUNTIME_PLAN_2026-03-13.md` to document the source-of-truth model and low-risk operating mode for this machine

Validation:

- `var/workspace/scripts/openclaw-live-cli.sh gateway status --no-probe` reads the live container runtime
- `var/workspace/scripts/openclaw-live-cli.sh cron list` shows active jobs for `main`, `watchdog`, `builder-a`, `research`, `monetization`, and `delivery-lead`

## 2026-03-16

### OpenClaw config permission hardening

- tightened `/home/node/.openclaw/openclaw.json` from mode `755` to `600` inside the live gateway container
- this change was runtime-side only; no token or policy values were changed
- the live deep security audit summary dropped from `5 critical / 4 warn / 1 info` to `4 critical / 4 warn / 1 info`

## 2026-03-20

### Local operator auth path unified across CLI command families

- root cause confirmed in source:
  - `gateway status`
  - `gateway probe`
  - `gateway call`
  - `status --all`
  did not share one consistent local-auth selection path
- on this machine, an ambient low-scope `OPENCLAW_GATEWAY_TOKEN` could shadow the paired local operator device token for some commands, causing split behavior such as:
  - `rpc.ok: true` in one path
  - `missing scope: operator.read` in another
  - `1000 normal closure` or `timeout` in another
- added shared helper `src/gateway/operator-device-auth.ts`
- updated local self-connection auth resolution in:
  - `src/gateway/call.ts`
  - `src/gateway/probe-auth.ts`
  - `src/commands/gateway-status/helpers.ts`
- new policy:
  - for trusted local self-connections with no explicit `--token` / `--password`, prefer the stored paired operator device token
  - keep remote targets, explicit URL overrides, and explicit credentials on the older explicit-auth path

Validation:

- targeted tests passed for:
  - `src/gateway/call.test.ts`
  - `src/gateway/probe-auth.test.ts`
  - `src/commands/gateway-status.test.ts`
  - `src/commands/gateway-status/helpers.test.ts`
  - `src/cli/daemon-cli/status.gather.test.ts`
- full repo `tsc --noEmit` was attempted but hit Node heap exhaustion in this environment; no targeted regression failure was observed

### Cloud-backup repo mapping re-confirmed before cleanup

- Git credential helper currently resolves GitHub username `lxsdsd`
- repo mapping re-confirmed:
  - product code repo: `/home/gaga/openclaw`
  - assistant state backup repo: `var/workspace/assistant-state-backup`
  - English study repo: `var/workspace/projects/english-study/repo`
- do not push assistant-state snapshots from the product repo root by accident
- do not assume English study delivery files outside `projects/english-study/repo/` are already cloud-backed-up

### Disk-pressure cleanup rule tightened

- Windows `C:` is in emergency state (`< 2 GB` free observed during this pass)
- before deleting any local cache, Docker data, or duplicate workspace copy:
  1. verify persistence paths still exist
  2. create fresh backup snapshot
  3. push backup/state repos first
  4. only then remove clearly redundant local artifacts
- priority is to reclaim space without changing the canonical runtime root or breaking restart safety

### Cloud backup and safe cleanup pass executed

- pushed assistant-state snapshot repo:
  - repo: `var/workspace/assistant-state-backup`
  - remote branch: `origin/workspace-main`
- pushed local runtime/tooling backup branch:
  - repo: `/home/gaga/openclaw`
  - remote branch: `userfork/codex-runtime-backup-20260320`
- pushed English study deliverables into its own repo:
  - repo: `var/workspace/projects/english-study/repo`
  - remote branch: `origin/main`
- ran `openclaw-pre-cleanup-check`
- created fresh D-drive snapshot under `/mnt/d/openclaw-backups/20260320-115502`
- reclaimed Docker build cache with `/usr/bin/docker builder prune -af`
  - reclaimed output reported `14.56GB`
- ran `scripts/verify-local-runtime.sh` after cleanup and it passed

Cleanup actions completed without touching canonical runtime config/workspace mounts:

- moved duplicate English study delivery tree to D-drive cleanup stash
- moved English study `_vendor` helper copy to D-drive cleanup stash
- moved English study `.git.broken-20260319-1916` to D-drive cleanup stash
- moved English study Playwright browser cache to D-drive cleanup stash
- moved workspace `.venvs` doc-tools cache to D-drive cleanup stash

Important note:

- even after Docker cache cleanup, `C:` remained critically low
- this suggests the remaining `C:` pressure is not only live cache usage; Windows-side Docker/WSL virtual-disk compaction will likely be needed later if more space is required without deleting runtime data

Validation:

- `docker exec <openclaw-gateway> stat -c '%a %n' /home/node/.openclaw/openclaw.json`

## 2026-03-18

### Workspace AGENTS ops-file index added

- updated `var/workspace/AGENTS.md`
- added a dedicated "OpenClaw Ops Files" section so future sessions answer with file paths first
- documented the main operator entrypoints:
  - `../config/openclaw.json`
  - `../../.env`
  - `CONFIG_CHANGELOG.md`
  - `RECOVERY_AUDIT_2026-03-13.md`
  - `WSL_DOCKER_RUNTIME_PLAN_2026-03-13.md`
  - `TODO_USER.md`
  - `TEAM_ROLES.md`
  - `MAIN_CONTROL_POLICY.md`

Validation:

- workspace instructions now contain a stable file-location index for config, recovery, and login-time checks
- `scripts/openclaw-live-cli.sh security audit --deep --json`

### Provider-auth blocked cron state rechecked

- re-verified from live `cron list --all --json` that the known `rightcode`-blocked worker jobs stay disabled instead of empty-spinning
- confirmed `builder-a-night-feishu`, `main-night-supervisor`, and `watchdog-audit` are disabled with no next run scheduled
- no enabled cron job currently shows the same `403 "API Key 不允许使用余额且无可用套餐"` blocker

Validation:

- `scripts/openclaw-live-cli.sh cron list --all --json`

### Auth-debugging lessons recorded

- updated `var/workspace/AGENTS.md`
- updated `var/workspace/PITFALLS.md`
- updated `var/workspace/WSL_DOCKER_RUNTIME_PLAN_2026-03-13.md`

Recorded lessons:

- do not read `.env` by default during auth debugging; answer with file paths first
- `.env` changes require container recreation, not restart-only
- browser auth is two-stage: gateway token, then device pairing
- device pairing source of truth for this machine is the live gateway container runtime

Validation:

- workspace runbook and pitfalls now both document the token and pairing failure mode seen on 2026-03-18

### Tool-profile mismatch repaired

- changed host-side `../config/openclaw.json` tool baseline from `profile: "coding"` to `profile: "full"`
- converted the old additive Feishu plugin exposure from `tools.allow` to `tools.alsoAllow` so it no longer acts like a restrictive allowlist in future reloads/rebuilds
- aligned the live gateway runtime config to the same `full` profile baseline to stop the repeated `tools.profile (coding) allowlist contains unknown entries (apply_patch, cron, image)` warning on this stack
- left the known `rightcode` provider failure untouched for now; this pass only fixed local config mismatch and runtime hygiene

Validation:

- live gateway config now reports `tools.profile = full`
- gateway restart completed healthy
- post-restart gateway logs no longer emit the old `tools.profile (coding)` unknown-entry warning during startup

### Host GitHub push path enabled

- installed a host-side `gh` binary at `/home/gaga/bin/gh` by copying the already-pinned binary from the live gateway container
- configured host Git credential helpers to call the gateway container's authenticated `gh auth git-credential`, so host `git` can reuse the container's GitHub login without duplicating tokens into host config
- added `/home/gaga/bin` to `tools.exec.pathPrepend` in the host config so OpenClaw host-exec jobs can resolve the local `gh` binary more reliably

Validation:

- host-side `git credential fill` for `https://github.com` now returns both username and password fields via the configured helper chain
- repo-local Git identity remains `Bobo Assistant / assistant@local`

## 2026-03-18

### Main session compaction-timeout recovery

Diagnosis:
- `agent:main:main` in `/home/gaga/openclaw_recovery/sessions/sessions.json` still pointed at session `55a26306-eeed-4fd9-9279-5467b7cfcbef`
- that transcript had grown to about 1.2 MB with 171 messages and no prior compaction archive, including a very large tool-result payload
- a stale cron session entry `agent:main:cron:d35abe06-500d-452e-be1c-0e50a1ea91b1` retained `lastTo=heartbeat` and `deliveryContext.to=heartbeat`, which could recreate the bad startup pending-delivery route

Changes applied:
- created an official backup archive plus separate backups of the live recovery session store before mutation
- reset `agent:main:main` in the recovery session store to a fresh session id `967a8a79-533f-4432-84e3-a8fdfaef8c87` while preserving routing, model, and history metadata
- archived the old transcript as `/home/gaga/openclaw_recovery/sessions/55a26306-eeed-4fd9-9279-5467b7cfcbef.jsonl.reset.2026-03-18T09-38-59.455024Z`
- cleared the stale pending-delivery routing fields on cron session `d35abe06-500d-452e-be1c-0e50a1ea91b1`

Validation:
- `main_session_fix_validation.log` records the pre/post session ids and exact files touched
- post-fix store shows `agent:main:main` with `totalTokens=0`, `totalTokensFresh=true`, and preserved Feishu route
- post-fix store shows the bad cron session with `lastTo=null` and `deliveryContext=null`

## 2026-03-19

### Runtime update policy documented

- added `scripts/update-local-runtime.sh` as the canonical host-side update entrypoint for this Dockerized stack
- updated `LOCAL_SETUP.md` and `STATE_SOP.md` to state that in-container self-update is not the authoritative update path here
- recorded a dedicated runtime handoff file at `OPENCLAW_RUNTIME_STATUS.md`
- updated workspace `AGENTS.md` so OpenClaw opens the runtime status handoff early during operational troubleshooting
- recorded the deeper root cause of the outage: state-root split plus mixed Docker control paths (`docker.exe` wrapper vs WSL-native Docker CLI)
- updated local lifecycle scripts to prefer `/usr/bin/docker` on this machine so the running container reads the same WSL files that were just edited

Why this was needed:

- this machine runs a custom local Docker image on top of upstream OpenClaw
- mounted state in `var/config` and `var/workspace` is persistent, but ad-hoc updates inside a running container are not durable across recreate
- repeated failures were caused by mixing up workspace role files, runtime registrations, state roots, and even the Docker control path used to manipulate the stack

Validation:

- startup and verification entrypoints remain `scripts/start-local-runtime.sh` and `scripts/verify-local-runtime.sh`
- update flow is now explicitly documented as snapshot -> rebuild/pull -> recreate -> verify

### Integration persistence hardening

- added `scripts/audit-local-integrations.sh` to audit the canonical runtime roots and integration surfaces without printing secret values
- added `scripts/gh-git-credential.sh` as the canonical GitHub credential bridge into the live gateway container
- updated `docker-compose.agent-reach.yml` so `gh` auth persists under `var/config/gh/` instead of an implicit container-local path
- updated `scripts/start-local-runtime.sh` and `scripts/verify-local-runtime.sh` to create and verify the persisted GH config mount
- added `scripts/openclaw-runtime-cli.sh` so manual in-container OpenClaw CLI calls no longer need handwritten compose chains
- expanded D-drive snapshot/restore coverage to include `var/xiaohongshu-mcp/` and `var/qmd-memory-service/`
- documented the canonical integration paths and the `docker-compose.wsl.yml` footgun in `LOCAL_SETUP.md`, `STATE_SOP.md`, and `INTEGRATION_AUDIT_2026-03-19.md`
- added `scripts/migrate-legacy-named-volume-state.sh` to inspect the old `openclaw_openclaw_state` named volume and migrate safe Feishu state into the canonical config root

Validation:

- canonical state files for pairing, `mcporter`, and Xiaohongshu cookies are present under `var/config/`, `var/workspace/config/`, and `var/xiaohongshu-mcp/`
- global Git credential helper was found still pointing at a compose chain that included `docker-compose.wsl.yml`, which explains one persistent wrong-runtime auth path
- canonical config roots checked during this audit still do not contain `channels.feishu`; historical logs confirm Feishu used to run, so that state must be recovered intentionally from the correct runtime root rather than guessed
- old named-volume forensics on 2026-03-19 confirmed Feishu-specific state existed in the legacy volume even though the accessible canonical `openclaw.json` files had no `channels.feishu`

### Feishu recovered from legacy named volume

- confirmed the old Docker named volume `openclaw_openclaw_state` contained the previously active Feishu channel configuration in its own `openclaw.json`
- confirmed the same legacy volume also contained Feishu-only runtime state files that did not exist in the canonical bind-mounted root, including `credentials/feishu-default-allowFrom.json` and `feishu/dedup/default.json`
- restored the legacy `channels.feishu` block into `var/config/openclaw.json` from a local forensic copy of the old named volume
- restored safe non-secret Feishu state into the canonical runtime root:
  - `var/config/credentials/feishu-default-allowFrom.json`
  - `var/config/feishu/dedup/default.json`
- added `scripts/migrate-legacy-named-volume-state.sh` as the repeatable path for future legacy-volume extraction

Validation:

- `scripts/audit-local-integrations.sh` now reports `channels.feishu` present in the canonical config
- `openclaw config get channels.feishu` now returns a live Feishu config structure from the canonical runtime root
- current canonical Feishu config includes a direct top-level credential structure recovered from the legacy runtime, which explains why the previous env-based skeleton was insufficient on its own

### Shared infra baseline established

- added `INFRA_BASELINE.md` as the single operator handoff for runtime roots, persistence risks, integration status, restart/update guardrails, and the current stabilization checklist
- updated workspace `AGENTS.md` so future OpenClaw sessions open `INFRA_BASELINE.md` first for machine-state awareness
- recorded that current QMD and Claude Code Hub verification prove service health only; their deeper OpenClaw integration still needs explicit end-to-end validation
- recorded that GitHub auth bridging is alive and `remote.pushDefault=userfork`, but an actual network push dry-run still needs a dedicated validation pass
- recorded that old Docker named volumes remain the main restart-time persistence risk until they are intentionally retired after more validation

### Runtime validation after baseline

- verified Feishu at runtime from gateway logs rather than config only:
  - plugin tools registered
  - `starting feishu[default]`
  - `WebSocket client started`
  - `ws client ready`
  - inbound DM messages dispatched and completed successfully
- confirmed QMD health endpoint is live on `127.0.0.1:16333`, but still did not prove OpenClaw is actively using QMD as its memory backend
- confirmed Claude Code Hub responds on `127.0.0.1:23000`, but still did not prove an active OpenClaw integration path
- observed agent read failures for non-workspace paths and a missing daily memory file, so `INFRA_BASELINE.md` was updated to prefer workspace-local handoff docs first
- validated one full canonical container teardown + recreate cycle:
  - all configured agents persisted
  - Feishu reconnected and processed messages again
  - Xiaohongshu cookie persistence survived, but manual restart initially revealed that `start-local-runtime.sh` was not restoring `xiaohongshu-mcp`
- updated `scripts/start-local-runtime.sh` to always bring back `xiaohongshu-mcp`
- updated `scripts/verify-local-runtime.sh` to wait through the normal post-recreate connection-reset window instead of failing immediately

## 2026-03-19

### Xiaohongshu MCP endpoint corrected for container networking

- updated `var/workspace/config/mcporter.json` to change the Xiaohongshu MCP URL from `http://localhost:18060/mcp` to `http://xiaohongshu-mcp:18060/mcp`
- reason: inside the gateway container, `localhost` resolved to the gateway itself, causing `connect ECONNREFUSED 127.0.0.1:18060` even though the sibling `xiaohongshu-mcp` container was healthy

Validation:

- from inside `openclaw-openclaw-gateway-1`, `http://xiaohongshu-mcp:18060/` connected successfully
- from inside `openclaw-openclaw-gateway-1`, `http://xiaohongshu-mcp:18060/mcp` also connected successfully
- previous `mcporter list xiaohongshu --json` failure was confirmed as container-network address drift, not missing cookies or a dead container
- after the config change, `mcporter list` showed `xiaohongshu` healthy with 13 tools
- `mcporter call xiaohongshu.check_login_status` reached the MCP successfully and returned `未登录`, proving the remaining issue is session freshness rather than container reachability

### Restart verification window adjusted

- increased `scripts/verify-local-runtime.sh` health wait from 60s to 120s
- reason: after canonical recreate, `/healthz` recovered before Docker updated the container `healthy` flag, causing a false negative in the audit script

Validation:

- `scripts/start-local-runtime.sh` recreated the canonical gateway, cli, and `xiaohongshu-mcp` containers successfully
- a fresh Feishu probe still reported `enabled, configured, running, works`
- `openclaw skills list` still showed workspace-managed skills present after recreate, including `agent-reach`, `multi-agent-dispatch`, `self-improvement`, `skill-vetting`, and `tavily`
- Docker eventually marked `openclaw-openclaw-gateway-1` healthy after the normal delayed recovery window

### Live CLI follow-up refined

- updated `var/workspace/scripts/openclaw-live-cli.sh` to prefer WSL-native Docker resolution (`/usr/bin/docker`) before home-relative shims and PATH lookup
- confirmed the current `main` session runtime still has no Docker CLI available, so the helper cannot be validated from inside this session yet
- confirmed direct `openclaw cron list --all --json` from this session returns no live jobs because the current gateway path is missing `operator.read`, so late-report cron inspection remains blocked here
- updated `STATUS_BOARD.md` and `TODO_USER.md` to reflect the narrower blocker and the pending hiking reminder-time decision

Validation:

- `bash var/workspace/scripts/openclaw-live-cli.sh cron list --all --json` now fails specifically on missing Docker availability rather than on `$HOME/bin/docker`
- `openclaw status` shows gateway unreachable for control reads from this path (`missing scope: operator.read`)
- `openclaw cron list --all --json` returns an empty job set from this session path

### Native QMD backend enabled for `main`

- updated `Dockerfile.agent-reach` to install `@tobilu/qmd` with global `npm` as root instead of the previous Bun-based paths
- reason: Bun/source installation paths were not producing a working `qmd` CLI in this image, while `npm install -g @tobilu/qmd` was verified to work
- hardened the base apt install in `Dockerfile.agent-reach` with explicit retry loops so transient Debian mirror 500/502 errors do not break rebuilds
- updated `scripts/enable-qmd-memory-backend.sh` to use `python3` JSON editing instead of host `jq`, removing an unnecessary host dependency
- updated `docker-compose.agent-reach.yml` and `scripts/start-local-runtime.sh` to persist `main` agent QMD state on D drive at `/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd`
- updated `scripts/verify-local-runtime.sh` to verify the QMD mount and live `qmd` binary

Validation:

- `scripts/update-local-runtime.sh --no-snapshot` rebuilt the custom image and recreated the canonical runtime successfully
- `scripts/openclaw-runtime-cli.sh memory status --agent main --json` now reports `backend: "qmd"`
- the live `dbPath` is `/home/node/.openclaw/agents/main/qmd/xdg-cache/qmd/index.sqlite`
- the live status reports `vector.enabled=true`, `vector.available=true`, and indexed sources from both `memory` and `sessions`

### Xiaohongshu live config mount fixed

- root cause correction: the prior Xiaohongshu repair changed `var/workspace/config/mcporter.json`, but the running container was actually reading `/app/config/mcporter.json`
- updated `docker-compose.agent-reach.yml` to bind-mount `var/workspace/config/mcporter.json` into `/app/config/mcporter.json` for both `openclaw-gateway` and `openclaw-cli`
- updated `scripts/start-local-runtime.sh` to ensure `var/workspace/config/mcporter.json` exists before container recreate, preventing bad file-mount fallback behavior
- updated `scripts/verify-local-runtime.sh` to assert the live `mcporter` config mount and file presence
- updated `scripts/audit-local-integrations.sh` to report both the portable workspace config and the live gateway `/app/config/mcporter.json` mirror

Validation:

- inside `openclaw-openclaw-gateway-1`, `/app/config/mcporter.json` now contains `xiaohongshu`, `exa`, and `weibo`
- inside `openclaw-openclaw-gateway-1`, `mcporter list --json` now reports three healthy servers, including `xiaohongshu`
- inside `openclaw-openclaw-gateway-1`, `mcporter call xiaohongshu.check_login_status` now reaches the service and returns `未登录`
- remaining Xiaohongshu blocker is now only login freshness, not config drift or broken container routing

### Xiaohongshu cookies path corrected

- final root cause correction: the `xiaohongshu-mcp` container runs with working directory `/app` and reads a relative `cookies.json`
- previous compose mapping mounted the host cookie file to `/cookies.json`, which left `/app/cookies.json` missing and made the service report `failed to load cookies: open cookies.json: no such file or directory`
- updated `docker-compose.agent-reach.yml` to mount `var/xiaohongshu-mcp/cookies.json` into `/app/cookies.json`

Validation:

- inside `xiaohongshu-mcp`, working directory is `/app`
- inside `xiaohongshu-mcp`, `/app/cookies.json` now exists and is the persisted host file
- after recreate, `mcporter call xiaohongshu.check_login_status` now returns `✅ 已登录`

## 2026-03-19

### Self-improvement skill activation tightened

- rechecked the live OpenClaw state instead of trusting prior notes alone:
  - `openclaw skills list` shows `self-improvement` as ready
  - `.learnings/LEARNINGS.md`, `.learnings/ERRORS.md`, and `.learnings/FEATURE_REQUESTS.md` are present
  - `openclaw hooks list` initially did **not** show any self-improvement reminder hook
- root cause: the skill folder contained reminder handler source under `skills/self-improving-agent/hooks/openclaw/`, but not a discoverable OpenClaw hook directory with `HOOK.md` under `var/workspace/hooks/` or `~/.openclaw/hooks/`
- added a real workspace hook at `var/workspace/hooks/self-improvement-reminder/` with:
  - `HOOK.md`
  - `handler.ts`
- enabled it in live config, which now sets:
  - `hooks.internal.enabled = true`
  - `hooks.internal.entries.self-improvement-reminder.enabled = true`
- updated `skills/self-improving-agent/SKILL.md` to stop implying that a source-only skill hook folder is auto-discoverable
- added `skills/self-improving-agent/references/openclaw-integration.md` to document the OpenClaw-specific activation steps and pitfalls
- updated `SKILL_INDEX.md` to record that the reminder hook is now discoverable and enabled

Validation:

- `openclaw hooks list --verbose` now shows `self-improvement-reminder` as `openclaw-workspace` and `ready`
- `/home/node/.openclaw/openclaw.json` now contains `hooks.internal.entries.self-improvement-reminder.enabled = true`
- attempted host-side `openclaw gateway restart` is still not the canonical runtime reload path on this machine; it reported the service as disabled, which matches existing infra notes and should not be mistaken for config loss
- added `SKILL_RUNTIME_STATUS.md` as the dedicated Codex handoff for skill readiness, hook activation, memory-link caveats, and current pitfalls
- updated `AGENTS.md` so future sessions know to consult `SKILL_RUNTIME_STATUS.md` during OpenClaw troubleshooting

### Context overflow prevention research + machine-specific plan

- investigated current anti-overflow posture using local OpenClaw docs plus external 2025–2026 context-management references
- confirmed the live environment is `rightcode/gpt-5.4` over `openai-responses` with `128000` context and only minimal local compaction config (`mode: safeguard`)
- confirmed that OpenClaw `contextPruning` is **not** the main fix for this machine right now because local docs scope it to Anthropic-style calls; this avoids blindly applying the wrong best-practice recipe
- added `CONTEXT_COMPACTION_STATUS.md` as the dedicated handoff for:
  - current context-management state on this machine
  - recommended local compaction tuning
  - optional `responsesServerCompaction` test shape for `rightcode/gpt-5.4`
  - startup-doc bloat guidance and pitfalls
- updated `AGENTS.md` so future restart/repair work also points to `CONTEXT_COMPACTION_STATUS.md`

## 2026-03-20 — GITHUB_TOKEN fix & env var injection pitfall

- **Root cause**: `~/.profile:36` had a hardcoded `export GITHUB_TOKEN='ghp_XYQ5...'` (old/invalid token). Shell env vars override Docker Compose `.env` file, so containers always received the stale token even after `.env` was updated.
- **Where**: host-side (`~/.profile`) + runtime-side (container env)
- **Fix**:
  - Removed hardcoded `GITHUB_TOKEN` from `~/.profile`
  - `docker compose down` + `./scripts/start-local-runtime.sh` to fully rebuild with clean env
  - `gh auth login --with-token` + `gh auth setup-git` on host
- **Validation**:
  - Container fingerprint matches `.env` fingerprint: YES
  - Container `curl https://api.github.com/user`: HTTP 200
  - Container `gh auth status`: logged in as lxsdsd, scopes: admin:org, repo, workflow
- **Lesson**: When debugging env var mismatch, always check shell profile files (`~/.profile`, `~/.bashrc`) — they take priority over `.env`. Use `unset VAR` or new terminal before rebuilding containers.
