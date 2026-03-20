# DISPATCH_BOARD.md

## Rule

- The user talks to main only.
- main is the sole dispatcher for subagents.
- Subagents do not self-assign work. They execute only what is written in their current ASSIGNMENT.md.
- Every active subagent must follow `agents/WORKER_PROTOCOL.md` and prove real start via its own `STATUS.md`.
- If the user says stop, pause, switch, reprioritize, or replace, main must update this board and the target ASSIGNMENT.md files immediately.

## Active assignments

## Supervisor pass - 2026-03-20 02:20 UTC

- runtime truth is now split by interface: direct OpenClaw tools confirm the scheduler is healthy enough to answer, but the local CLI path still hits `missing scope: operator.read`, so future supervision notes must stop treating CLI failure as proof that the runtime is down
- corrected stale report-lane assumptions: live cron state is currently empty (`/home/node/.openclaw/cron/jobs.json` has `jobs: []`, and tool-side `cron list` agrees), so `report-2000-bjt` and `report-2200-bjt` are not active scheduled jobs right now and should no longer be described as healthy vs timing-out live lanes
- no child worker currently qualifies as an active owner: `builder-a` stays `replaced`, `builder-b` stays `paused`, `watchdog` stays `completed`, `research` stays `completed`, `delivery-lead` stays `replaced`, and `monetization` stays `completed` in file-backed assignment state
- next control-plane step: keep child lanes idle, treat the report pair as a scheduler-truth reconciliation/rebuild task instead of a prompt-tuning task, and continue narrowing the CLI credential-selection problem separately

## Supervisor pass - 2026-03-19 04:27 UTC

- runtime re-verified from live CLI first, not the UI: `scripts/openclaw-live-cli.sh status --all` succeeded, gateway loopback stayed reachable, and a targeted `cron list --all --json` recheck confirmed current scheduler truth; one follow-up `cron list` hit a transient `1000 normal closure` and recovered on immediate retry, so OpenClaw does not look stuck and no node-host self-repair path is needed
- no child worker currently qualifies as an active owner: `builder-a` stays `replaced`, `builder-b` stays `paused`, `watchdog` stays `completed`, `research` stays `completed`, `delivery-lead` stays `replaced`, and `monetization` stays `completed` in file-backed assignment state
- corrected live runtime drift instead of trusting the older board note: `research-night-money` had been re-enabled even though `agents/research/ASSIGNMENT.md` is `completed`, and it was repeating provider auth failures as `403 "API Key 已被禁用"`; that cron job is now disabled again so the closed `research` lane stops waking on an unowned retry loop
- the remaining disabled auth-failing jobs stay intentionally parked: `builder-a-night-feishu`, `watchdog-audit`, `main-night-supervisor`, `delivery-lead-track`, `monetization-track`, `report-2000-bjt`, and `report-2200-bjt` still do not own active child lanes and should not be treated as implementation stalls
- next control-plane step: leave child lanes idle until a new explicit assignment opens; when security hardening returns to the top of the queue, reopen only the narrow `/home/node/.openclaw/openclaw.json` permission fix from `SECURITY_TODO.md`

## Supervisor pass - 2026-03-18 04:56 UTC

- runtime re-verified from live CLI first, not the UI: `scripts/openclaw-live-cli.sh status --all` and `scripts/openclaw-live-cli.sh cron list --all --json` both succeeded, the gateway stayed reachable on loopback, and Feishu still probes healthy, so OpenClaw does not look stuck and no node-host self-repair path is needed
- there is still no active child worker to rescue or reroute, and that conclusion is now based on the live workspace files plus CLI state instead of injected context: `builder-a` is `paused`, `builder-b` is `completed`, `watchdog` is `completed`, `research` is `completed`, `delivery-lead` is `completed`, and `monetization` is `completed`
- corrected board drift from the earlier notes that described newer child states than the live assignment files on disk; the queue is still idle, but the stale labels could mislead the next supervision pass about who owns work
- current runtime drift is historical error residue, not a live stalled worker: disabled jobs like `builder-a-night-feishu`, `watchdog-audit`, `main-night-supervisor`, `delivery-lead-track`, `monetization-track`, `report-2000-bjt`, and `report-2200-bjt` still carry old provider-side `403 "API Key 不允许使用余额且无可用套餐"` last-status fields, but they are disabled and do not currently own active lanes
- next control-plane step: leave child lanes idle until a new explicit assignment opens; if the security lane returns to the top of the queue, open one narrow hardening pass for `/home/node/.openclaw/openclaw.json` permissions (`755` -> `600`) from `SECURITY_TODO.md`, otherwise keep the parked worker/report jobs disabled until a working model path or quota headroom returns

## Supervisor pass - 2026-03-16 14:15 UTC

- runtime rechecked from live CLI again, not the UI: `scripts/openclaw-live-cli.sh status --all`, `scripts/openclaw-live-cli.sh cron list --all --json`, and `scripts/openclaw-live-cli.sh agents list --bindings` all still succeeded, so OpenClaw does not look stuck and no host self-repair path is needed
- child ownership still stays honest: there is no active worker to rescue or reassign, and scheduler health alone still does not make `research`, `delivery-lead`, or `monetization` the live owner of the queue
- the parked provider-blocked worker jobs remain intentionally parked: `builder-a-night-feishu`, `watchdog-audit`, and `main-night-supervisor` are still disabled on the same provider `403` family, so keep them out of the queue
- the late report lane has now crossed from a one-off symptom into a concrete control-plane task: `report-2200-bjt` remains enabled but has reached three consecutive timeout failures, while `report-2000-bjt` remains healthy
- next concrete step: keep child lanes idle, preserve `main` as the only active owner, and explicitly slim or split the `report-2200-bjt` prompt/timeout budget instead of treating that recurring timeout as a worker stall

## Supervisor pass - 2026-03-16 07:03 UTC

- runtime re-verified from live CLI again, not the UI: `scripts/openclaw-live-cli.sh status --all`, `scripts/openclaw-live-cli.sh cron list --all --json`, and `scripts/openclaw-live-cli.sh agents list --bindings` all succeeded, so OpenClaw is responsive enough for control-plane work and no host self-repair path is needed
- there is still no active child-owner drift to correct: `builder-a` stays replaced, `watchdog` stays completed, `research` stays completed, `builder-b` stays paused, `delivery-lead` stays replaced, and `monetization` stays completed; scheduler health alone still does not make any of them live owners
- keep the parked provider-blocked worker jobs parked: `builder-a-night-feishu`, `watchdog-audit`, and `main-night-supervisor` are still disabled with the familiar provider `403` family, so do not reopen any worker lane on those cron states alone
- the reporting blocker changed shape and should stop being described as a generic auth stall: `report-2000-bjt` is back to `lastStatus: ok`, while `report-2200-bjt` is enabled but currently failing by timing out before a response rather than by provider package denial
- next control-plane step: keep child lanes idle, preserve `main` as the only current owner of active work, and narrow the late-report path separately if it stays too heavy instead of misclassifying it as a child-worker stall

## Supervisor pass - 2026-03-16 05:53 UTC

- the user explicitly reprioritized the queue onto `English-study` closeout, so keep this lane in `main` instead of reopening any child worker on the same repo tree
- runtime state for this pass stayed clear enough that no self-repair path was needed; do not infer stuckness from UI lag when live shell work and delivery-file writes are succeeding
- the next concrete closeout step is no longer “wait for Word tooling”: the local `doc-tools` venv already provides `python-docx`, so `main` should export the delivery pack to `projects/english-study/delivery/docx/`, update the test/deploy docs, and then reassess what remains before the second rollback commit
- keep `builder-a`, `builder-b`, `watchdog`, `research`, `delivery-lead`, and `monetization` parked; scheduler health alone still does not make any of them live owners of this repo lane
- after the delivery-pack export lands, update `STATUS_BOARD.md`, `EXECUTION_BOARD.md`, and `TODO_SHORT.md` so the remaining English-study closeout work is narrowed to upstream-file review plus rollback packaging, not generic doc cleanup

## Supervisor pass - 2026-03-13 12:55 UTC

- runtime verified on `wsl-host`: gateway `127.0.0.1:18789` is healthy, Feishu is running, and `research` exists in the live agent config
- local host-side CLI checks can show false negatives when they fall back to missing `~/.openclaw/openclaw.json`; the live stack here is using `/home/gaga/openclaw/var/config/openclaw.json`
- no child lane is currently in a verified running state; rewrite the target `ASSIGNMENT.md` before the next worker run instead of assuming any lane is still live

### builder-a

- status: paused
- assignment file: `agents/builder-a/ASSIGNMENT.md`
- objective: resolve the remaining Feishu `记录待办` bottom-menu gap by proving whether it arrives as plain text, callback/event, or another route, then patch or prove the exact missing integration point
- current step: paused pending main review of the delivered explicit-text capture patch in `agents/builder-a/STATUS.md`; the next reactivation should target menu-path evidence directly instead of repeating the already-proven text path
- success output: real executable patch or exact blocker evidence recorded in `agents/builder-a/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority implementation task

### research

- status: completed
- assignment file: `agents/research/ASSIGNMENT.md`
- objective: ranked monetization shortlist for the current OpenClaw + Feishu + automation stack
- current step: idle until main assigns a new non-overlapping research task
- success output: updated `MONETIZATION_OPTIONS.md` plus concise rationale in `agents/research/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority research task

### builder-b

- status: completed
- assignment file: `agents/builder-b/ASSIGNMENT.md`
- objective: prepare the non-conflicting verification lane for the Feishu `记录待办` implementation
- current step: idle until main assigns the next non-conflicting validation or hardening task
- success output: minimal test patch or exact validation seam recorded in `agents/builder-b/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority non-conflicting implementation task

### watchdog

- status: completed
- assignment file: `agents/watchdog/ASSIGNMENT.md`
- objective: audit worker progress, detect stalls, and recommend rerouting without doing implementation work
- current step: idle; the latest supervision pass already verified runtime health and found no currently running child lane that needs immediate rescue
- success output: concrete supervision notes in `agents/watchdog/STATUS.md`

### monetization

- status: completed
- assignment file: `agents/monetization/ASSIGNMENT.md`
- objective: keep one realistic current赚钱方向 moving for the OpenClaw + Feishu + automation stack
- current step: idle; the latest pass accepted the current best wedge and handed validation back to main instead of opening another worker loop
- success output: updated `MONETIZATION_OPTIONS.md` and a concrete current focus in `agents/monetization/STATUS.md`

### delivery-lead

- status: completed
- assignment file: `agents/delivery-lead/ASSIGNMENT.md`
- objective: own review, integration, testing, polish, and delivery docs for long-running software projects near handoff
- current step: idle until main writes a fresh follow-up; the last completed item was the docs typo fix plus local commit `fbcc0dc` in `projects/english-study/repo`
- success output: project notes plus a browser-validation artifact or one additional safe code-level fix recorded in `agents/delivery-lead/STATUS.md`
