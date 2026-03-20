# STATUS_BOARD.md

## Doing now

- GitHub auth/push plumbing is healthy again in the live runtime: `gh auth status` logs into `lxsdsd`, private repo access works, and `git push --dry-run` on `lxsdsd/openclaw` now reaches the remote and fails only because the remote branch is ahead (`fetch first`), not because of auth.
- The mixed repo boundary is now partially untangled in the cloud: OpenClaw-side state history has been pushed to `lxsdsd/openclaw` branch `recovery-sync-20260319`, extracted English-study history from the mixed snapshot has been pushed to `lxsdsd/English_study` branch `recovered-mixed-history-20260319`, and the recovered current English-study workspace state has been pushed to `lxsdsd/English_study` branch `workspace-recovery-20260319`.
- Current split finding: `assistant-state-backup` did contain tracked `workspace/projects/english-study/repo/...` files, the standalone `projects/english-study/repo/.git` was broken, and it has now been replaced with a healthy remote-derived `.git` so the local English-study tree is again a real git repository. The long-term default branch shape now also lines up end-to-end: GitHub defaults are `lxsdsd/openclaw` -> `workspace-main` and `lxsdsd/English_study` -> `main`, while local working branches track `origin/workspace-main` and `origin/main` respectively. The remaining repo-split work is now limited to whether to retain or prune the temporary recovery branches and how explicitly to document that future push flow.
- Repo-split cleanup is unblocked on the config side: the user confirmed that the local tool-allowlist addition in `assistant-state-backup/config/openclaw.json` should be kept, so future branch/default-branch cleanup must preserve that change instead of treating it as disposable drift.
- English-study closeout is now materially closed in `main`: the polluted `web/libs/editor/src/components/App/App.jsx` source was rebuilt from `web/dist/libs/editor/main.js.map`, the user-visible task/error-page text was localized, the final deferred-asset call is documented in the delivery pack, and the result is captured in commits `305a09d46` and `646152e0d`.
- English-study delivery packaging is healthy again: `projects/english-study/tools/export_delivery_docs.py` now prefers a repo-local vendored `python-docx`, and `projects/english-study/delivery/docx/` has been regenerated from the current Markdown set.
- The only tracked non-English-study change still left in the root worktree is `docker-compose.yml`, where `PLAYWRIGHT_BROWSERS_PATH` is now passed through to two services. Repo docs and `Dockerfile` support that knob, and because it defaults to empty it is currently a low-risk keep-or-drop decision rather than an urgent regression.
- The smallest safe hardening step is no longer pending: live `/home/node/.openclaw/openclaw.json` permissions are now `600`, and the live deep audit dropped from `5 critical / 4 warn / 1 info` to `4 critical / 4 warn / 1 info`.
- The `rightcode` provider blocker is contained for now: live cron state shows the known `403`-blocked worker jobs remain disabled, so there is no enabled empty-spin loop while waiting for quota recovery or a new model path.
- Reporting lanes have been reclassified: older notes that treated `report-2000-bjt` as healthy and `report-2200-bjt` as merely timing out are stale now that live cron state reads empty; both report names should be treated as historical board residue until a real scheduler source is rediscovered or rebuilt.
- The remaining reporting blocker is no longer prompt-sizing but truth reconciliation: `scripts/openclaw-live-cli.sh` still cannot run here because Docker CLI is unavailable, direct CLI cron inspection remains hampered by the `operator.read` path, and live `/home/node/.openclaw/cron/jobs.json` currently has no jobs to inspect.
- New runtime-state finding: the live cron store at `/home/node/.openclaw/cron/jobs.json` is currently empty (`jobs: 0`). That means the report lanes described in the boards are not present in the current on-disk scheduler state, so the remaining reporting/debug path is now split between (a) fixing the local CLI read path and (b) reconciling whether the active scheduler state moved elsewhere or those jobs were cleared and only the notes remained stale.
- New live-auth finding: this runtime does have a persisted operator device token with `operator.read/write/admin/...` under `/home/node/.openclaw/identity/device-auth.json`, but the local CLI still prefers `OPENCLAW_GATEWAY_TOKEN` in local-mode credential precedence. Current env has `OPENCLAW_GATEWAY_TOKEN` set (but no `OPENCLAW_GATEWAY_URL` override), so RPC reads are staying on the shared gateway-token path instead of the cached operator device-token path; when the env token is unset, `gateway status` no longer retries into the device token and instead errors on missing explicit credentials, so the remaining fix is in local CLI credential-selection behavior rather than pairing state.
- Fresh command-path split: `openclaw status --all` still reports `Gateway: local · ws://127.0.0.1:18789 ... unreachable (missing scope: operator.read)` with env `OPENCLAW_GATEWAY_TOKEN=gaga2026.0318`, while `openclaw gateway status --json` reports `rpc.ok: true` against the same loopback target and config path `/home/node/.openclaw/openclaw.json`. At the same time, low-level `openclaw gateway call status|config.get|system-presence` closes with `1000 normal closure`, and `openclaw gateway probe --json --timeout 10000` still times out. So the current blocker is narrower than "gateway down": CLI subcommands are using inconsistent auth/probe behavior against the same local gateway on port `18789`.
- Strong root-cause lead from the bundled auth client: when an explicit gateway token is present, the client only retries with the stored `device-auth.json` device token on `AUTH_TOKEN_MISMATCH`-style connect failures (`retry_with_device_token` advice / `canRetryWithDeviceToken`), not on our current `missing scope: operator.read`, `1000 normal closure`, or timeout paths. That matches the live symptom: env `OPENCLAW_GATEWAY_TOKEN` can shadow the stored operator device token without ever falling back to it for scope-limited reads.
- Stronger proof from config + bundled call path: live config is `gateway.mode=local`, `gateway.bind=lan`, `gateway.auth.mode=token`, with the actual token coming from environment rather than `openclaw.json`; and `shouldAttachDeviceIdentityForGatewayCall()` in the bundled client returns `false` on loopback targets whenever `token` or `password` is present. So on `ws://127.0.0.1:18789`, the moment env `OPENCLAW_GATEWAY_TOKEN` is in play, low-level gateway call paths stop attaching local device identity entirely.
- Dist-code review confirms the paths are genuinely different, not just flaky symptoms: `gateway status` goes through the daemon/service status path and probes via a TLS-aware `callGateway(status)` using merged daemon env; `gateway probe` is a separate loop that hard-codes local loopback as `ws://127.0.0.1:${port}` with a tight local budget and explicitly disables device identity on loopback; `gateway call` is a third path that resolves creds from current CLI config/env and only consults stored `device-auth.json` tokens inside `GatewayClient.selectConnectAuth()`, with fallback retry limited to token-mismatch-style advice. `status --all` mixes these paths, so it can legitimately report different outcomes inside one run.
- Latest probe detail adds one more constraint: the gateway is still running with `bind=lan`, so the probe layer explicitly resolves to `ws://127.0.0.1:18789` while noting that `lan` listens on `0.0.0.0`; that same loopback target reports `port=busy` yet `connect.ok=false/rpcOk=false` with timeout in probe output. This keeps the live issue focused on bind/auth/probe-path mismatch rather than scheduler or session state.
- Fresh healthcheck pass: `openclaw security audit --deep` is down to `1 critical / 3 warn / 1 info`; the only remaining critical finding is the local `skills/tavily-search` audit hit, while the main runtime warnings are the short gateway token and the `operator.read` probe failure.
- `tavily-search` disposition is now finalized: the skill stays as a reviewed local skill because it is already intentionally enabled, tiny, and bounded to Tavily official `https://api.tavily.com/search` and `https://api.tavily.com/extract` endpoints with `TAVILY_API_KEY` plus user-provided query/URL only. Treat the audit hit as accepted remote-API usage rather than proof of broad secret harvesting; future new skills still go through the normal `skill-vetting` gate.
- Fresh capability pass: `openclaw skills check` reports 19 skills ready and 42 missing optional requirements, so the current gap is no longer “skills invisible” but “separate must-have vs intentionally-uninstalled skill dependencies”.
- Fresh memory pass: `openclaw memory status --deep --agent main` is healthy (`20/20 files`, vector ready), so memory indexing is not a current blocker.
- The prioritized infra gap list is now written locally in `OPENCLAW_FOUNDATION_GAP_LIST_2026-03-20.md`; the user has now provided the formal Feishu task Bitable (`✅任务管理`, app `P1B0bfR5saT9bys80GPcMr8rnkf`, table `tblMVX0NKSoy3Oyb`), and current P1/P0 work has started syncing there instead of relying on the temporary supplement doc.
- Maintain the local `skills/skill-vetting/` gate as the default pre-install review path
- Compare and vet external skill-vetting candidates before any install
- Maintain indexes and pitfall tracking so new files and lessons stay discoverable
- Work toward a clean multi-project convention for separate code folders and task tracking

## Waiting on external conditions

- ClawHub rate limit to clear so `openclaw-skill-vetter` and similar candidates can be inspected fully

## Recently resolved

- English-study delivery export chain is repaired: `projects/english-study/tools/export_delivery_docs.py` now prefers vendored `python-docx` under `projects/english-study/tools/_vendor/`, and the `.docx` delivery pack has been regenerated from current Markdown
- English-study closeout boundary work is now fully spelled out in the delivery docs: the final retention decision keeps runtime-coupled `label_studio/` assets in place, downgrades weakly-coupled upstream demo assets to archive candidates, and avoids a risky physical `examples/archive` move during closeout
- English-study delivery packaging advanced: `projects/english-study/tools/export_delivery_docs.py` now exports the delivery pack and `projects/english-study/delivery/docx/` contains generated Word copies of the current docs
- English-study UI closeout advanced: visible task/error-page text is now localized, the polluted editor source was restored from source maps, and the stray compiled `static_build` JS edits were reverted out of the delivery scope
- English-study docs are now more honest about repo roles: `用户指南.md` remains the in-repo Chinese operator guide, while untracked `roadmap.md` is treated as upstream historical context instead of a local delivery promise
- English-study boundary docs now explicitly separate `web/dist` runtime bundles from `web/.../src` maintenance sources, and they split `label_studio/core/static/` into direct page-shell assets versus template/sample assets for follow-up review
- English-study boundary review now also distinguishes runtime-coupled `label_studio/annotation_templates/` from more likely upstream-demo `label_studio/core/examples/`, based on the live `TemplateListAPI` scan path in `label_studio/projects/api.py`
- English-study sample-asset review is now finer-grained: most `core/static/templates/*.png` files are still template-cover assets, the 6 unmatched covers currently have no live refs outside `staticfiles.json`, `core/static/samples/` splits into direct-template samples vs backend sample-endpoint assets vs weaker test/example-only files, and `sample-task-sin-headless.csv` has been downgraded from “possible missing asset” to an upstream dead reference shared with the SDK example bundle
- English-study backend boundary review now also separates runtime-coupled Django apps from vague `label_studio/(other)` leftovers: `INSTALLED_APPS`, `core/urls.py`, and `server.py` confirm a concrete running set around users/projects/tasks/import/export/storage/ML/webhooks/labels
- English-study top-level package review now also separates root runtime entry/config files (`manage.py`, `server.py`, `feature_flags.json`, `constants.py`) from test-only helpers (`tests/`, `pytest.ini`, `.coveragerc`, `sitecustomize.py`)
- English-study `core/` review now also separates template runtime helpers (`core/templatetags/filters.py`) from version/diagnostic auxiliaries (`core/all_urls.json`, `core/version_.py`, `core/ls-version_.py`)
- English-study `core/` top-level file review now also confirms most scattered Python files are runtime infrastructure rather than leftovers, based on live imports from settings, urls, server, and active apps
- Local control clients reconnected after token rotation
- Gateway token mismatch cleared
- Feishu DM channel successfully paired and working
- Skill visibility issue understood: runtime sees skills under `/home/node/.openclaw` and `/home/node/.openclaw/workspace`, not the earlier host-side repo path
- `agent-reach` is installed and partially usable now (`doctor` shows about 7/15 channels available)
- `tavily` is live with the newly added API key and the bundled search script returns results
- `find-skill` has no runtime-visible install in the current workspace or OpenClaw skill roots, so it should be treated as not installed

## Needs user decision

- Whether to finalize identity/bootstrap cleanup now or later
- Whether any browser-control capability should ever be re-enabled for specific tasks
- Whether to fund better external research capability later (optional, not needed for current safety baseline)
- When multiple coding projects are active, whether to split them into explicit project folders and labels up front
- When to start designing the multi-agent workbench for project-specific and function-specific helper agents

## Future work backlog

- PPT creation workflow
- Document writing workflow
- Multi-project coding workflow across separate folders
- Stock and fund monitoring workflow
- AI landscape monitoring: new tools, models, and information edge tracking
- Reading/monitoring content sources such as Xiaohongshu, Douyin, and WeChat Official Accounts
- A dedicated content-operations agent for managing the user's own accounts and posting workflow later
- A code-manager operating model with Git/GitHub rollback discipline, modern best-practice research, and anti-regression checks
- Per-agent customizable tone/persona profiles when the multi-agent setup expands
- Feishu menu-driven todo capture: clicking `记录待办` should route follow-up messages into a real todo inbox with assistant triage, editable priority, and todo viewing

## Operating cadence

- Keep running on queued/runnable work without waiting for repeated prompts
- If work runs dry, proactively tell the user that there are no active todos and ask for the next task
- If network returns after an outage, resume work automatically without asking again
- If VPN/network access is the blocker, tell the user exactly that it needs their help
- Ask the user when a choice is ambiguous, risky, or materially affects cost/security
- If workload exceeds one agent comfortably, propose parallel help via sub-agents/other "colleagues"
- Send scheduled progress updates at 08:00, 13:30, 20:00, and 22:00 UTC

## Candidate skill ranking (temporary)

1. `openclaw-skill-vetter` - best fit by current metadata; still pending full file review
2. `skill-vetter` - strong generic candidate; pending full file review
3. `skill-scanner` - likely useful, but seems more scanner-like than full install-decision workflow

## Next planned moves

1. Prompt for `gh auth` only if `github` is the next skill the user wants fully activated
2. Retry metadata/file inspection for external skill-vetter candidates when rate limits clear
