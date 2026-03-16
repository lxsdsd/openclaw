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

Validation:

- `docker exec <openclaw-gateway> stat -c '%a %n' /home/node/.openclaw/openclaw.json`
- `scripts/openclaw-live-cli.sh security audit --deep --json`

### Provider-auth blocked cron state rechecked

- re-verified from live `cron list --all --json` that the known `rightcode`-blocked worker jobs stay disabled instead of empty-spinning
- confirmed `builder-a-night-feishu`, `main-night-supervisor`, and `watchdog-audit` are disabled with no next run scheduled
- no enabled cron job currently shows the same `403 "API Key 不允许使用余额且无可用套餐"` blocker

Validation:

- `scripts/openclaw-live-cli.sh cron list --all --json`
