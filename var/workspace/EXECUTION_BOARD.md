# EXECUTION_BOARD.md

## Purpose

This is the anti-stall control board.
Use it as the shared source of truth for:

- current active lane owners
- runtime health confidence
- blockers that actually stop progress
- the next concrete action
- what should be reported to the user

## Runtime confidence

- Status: usable-with-provider-auth-blockers
- Last full self-check: 2026-03-15 12:13 UTC
- Last live probe: 2026-03-15 12:13 UTC
- Source of truth: live `status --all`, `agents list --bindings`, `channels status --probe`, `cron list --all --json`, `cron runs`, live `/home/node/.openclaw/workspace` file reads, and current worker `STATUS.md` artifacts
- Do not trust UI-only impressions for runtime, skill availability, agent health, scheduler state, or host-shell mirror copies

## Lane rules

- One code tree, one active implementation owner
- No worker is considered active just because a cron fired; it needs fresh artifact or `STATUS.md` evidence for the current assignment
- If a lane has no fresh artifact or status update after one run window, mark it stalled
- If the same failure repeats twice with no new evidence, stop retry loops and switch to one deterministic fallback or self-repair path
- If a cron lane repeats provider auth or quota `403` errors, treat it as an external blocker, disable that job instead of letting it keep waking, and record the blocker plus owner in `TODO_USER.md` or the board
- If the provider daily quota is exhausted for the current `rightcode` path, alert the user once, park the affected background jobs, and stop retry narration until quota recovers or the model path changes
- Heartbeat is a helper, not the main execution backbone

## Active lanes

### Lane A - Runtime continuity and reporting

- Owner: `main`
- Status: active
- Goal: keep the queue honest, keep reports aligned with real state, and detect runtime regressions early
- Next step: keep scheduled reports and supervisor prompts anchored to this board, slim them so they do not re-probe the whole runtime on every wake, and park any cron lane that repeats provider auth `403` until the quota/package issue is resolved; if the English-study identity/docs lane needs another try, reopen it explicitly instead of letting a failing scheduled worker spin

### Lane B - Safe-now config hardening

- Owner: `builder-a`
- Status: paused
- Goal: preserve the narrow `/home/node/.openclaw/openclaw.json` `755` -> `600` hardening lane as the next safe security task
- Evidence: the 2026-03-15 07:23 UTC live probe still shows `/home/node/.openclaw/openclaw.json` at `755`, and live `openclaw security audit --deep --json` still reports `5 critical / 4 warn / 1 info`
- Next step: keep this lane parked while the user-prioritized English-study pass is active; reopen it explicitly when security hardening returns to the top of the queue

### Lane C - English-study P0 scope reduction

- Owner: `builder-a` (accepted by `main`)
- Status: accepted/closed
- Goal: hold the accepted removal/gating of the proven settings, import/reimport/model-version, `/api/ml/...`, and related feature-flag surfaces in `projects/english-study/repo`
- Evidence: normalized `agents/builder-a/STATUS.md`, the clean 02:40 UTC `builder-a` cron run, the completed 03:50 UTC `watchdog` closeout note, and live `/home/node/.openclaw/workspace` reads of the four assigned files
- Next step: none unless exact caller evidence or a narrower policy gate requires reopening the lane

### Lane G - English-study identity and docs cleanup

- Owner: `main`
- Status: completed locally after user pullback
- Goal: stop the repo from presenting itself as a generic upstream `Label Studio` product by narrowing the targeted package/readme/docs identity surfaces to the current English-study scope without removing model/backend integration capability
- Evidence: the earlier worker pass already narrowed `README.md`, `project_settings.md`, and `project_settings_lse.md`; `main` then pulled the residue back locally, verified that model/backend integration docs remain intact, and narrowed the remaining package metadata in `projects/english-study/repo/pyproject.toml` by keeping the compatibility package name while removing the lingering upstream author identity.
- Next step: none unless a new exact caller-facing identity residue is found

### Lane H - English-study delivery packaging

- Owner: `main`
- Status: active
- Goal: finish the delivery-pack closeout by keeping the Markdown docs current, generating `.docx` handoff files, and narrowing the remaining work before the second rollback commit
- Evidence: `projects/english-study/delivery/03-测试报告.md` and `projects/english-study/delivery/04-部署手册.md` now reflect the post-repair validation state; `projects/english-study/tools/export_delivery_docs.py` exports the delivery pack; and `projects/english-study/delivery/docx/` now contains generated Word copies of all four delivery docs
- Next step: review the upstream-restored file set and the local browser/shared-lib workaround so the next commit can close the remaining English-study packaging questions instead of just the docs lane

### Lane D - Supervision and stall detection

- Owner: `watchdog`
- Status: completed
- Goal: preserve the accepted 03:50 UTC closeout note so parked lanes are not mistaken for live work
- Next step: wait for explicit reassignment; do not treat scheduler health alone as a reason to reopen supervision

### Lane E - Security hardening triage

- Owner: `research`
- Status: completed
- Goal: preserve the accepted live `openclaw security audit --deep --json` triage handoff
- Next step: none; the ranked handoff is complete in `agents/research/STATUS.md` and `SECURITY_TODO.md`

### Lane F - Blocked integrations

- Owner: `main`
- Status: partial
- Items:
  - Feishu Drive/Doc retest waits on live app account plus Drive/Doc scopes
  - GitHub activation is now available through the host-side `agent-reach` wrapper path; the backing container already has a valid `gh` login session
  - Host-side `agent-reach` recovery has improved capability from `5/15` to `10/15`; remaining gaps are proxy/config for Reddit and V2EX, a Groq API key for podcast transcription, and future Douyin/LinkedIn MCP setup

## Runtime health checks

- Gateway reachability: OK from the 2026-03-15 11:20 UTC live `status --all` probe; one `cron runs` request hit a transient `1000 normal closure`, then succeeded on retry
- Channel delivery: Feishu probe OK at 2026-03-15 11:20 UTC
- Cron engine: degraded by provider-side failures; the latest 12:00 UTC `builder-a-night-feishu`, 12:40 UTC `main-night-supervisor`, and 13:10 UTC `watchdog-audit` runs all failed fast with `403 "API Key 不允许使用余额且无可用套餐"`, which points to quota or package denial rather than an internal logic hang. `research-night-money`, `delivery-lead-track`, and `monetization-track` remain scheduler-healthy.
- Security audit snapshot: last reverified at 2026-03-15 07:23 UTC and still reporting `5 critical / 4 warn / 1 info`
- Scheduled reports: partial; 08:00 and 13:30 BJT delivered, the 20:00 BJT report no longer looks like the main blocker, and the latest 22:00 BJT run failed by hitting the 600s response timeout, which points to an overweight report prompt rather than auth denial on that specific run
- Heartbeat: partial; main heartbeat exists, last heartbeat shows skipped
- agent-reach stack: partially runnable from `/home/gaga/agent-reach-env` and improved to `10/15` channels after wiring `mcporter`, `xreach-cli` compatibility, container-backed `gh` and `ffmpeg`, Exa, XiaohongShu MCP, and Weibo MCP; remaining gaps need proxy, a Groq key, or extra platform servers
- Image input: OK at tool level
- Browser automation: unavailable by design in current setup

## Reporting contract

Each scheduled board report should mention only:

- changed lane state
- net-new progress
- changed blockers
- user-action items from `TODO_USER.md`
- risk changes
- next concrete step

If nothing changed, send a one-line no-change report.

## User-facing cadence

- 08:00 Asia/Shanghai - morning board report
- 13:30 Asia/Shanghai - midday board report
- 20:00 Asia/Shanghai - evening board report
- 22:00 Asia/Shanghai - late board report

## User-action blockers

- Provide git identity for commits, or approve a repo-local identity choice
- Provide Feishu Drive/Doc-capable app config when that lane should resume
- Decide whether a true host-local `gh` install is still worth doing now that the container-backed wrapper path is working
- Decide whether to harden Feishu group policy immediately
- Decide whether to keep repairing the host-side `agent-reach` toolchain now or accept the current partial `10/15` state

## Self-repair threshold

If live probes fail repeatedly and recovery is not immediate, use only:

1. `/home/gaga/bin/openclaw-health-check`
2. `/home/gaga/bin/openclaw-restart-stack`
3. `/home/gaga/bin/openclaw-rebuild-stack`
