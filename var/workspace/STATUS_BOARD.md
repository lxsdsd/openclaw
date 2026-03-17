# STATUS_BOARD.md

## Doing now

- English-study closeout advanced again in `main`: the polluted `web/libs/editor/src/components/App/App.jsx` source was rebuilt from `web/dist/libs/editor/main.js.map`, the user-visible task/error-page text was localized, and the result is captured in commits `305a09d46` and `646152e0d`.
- The stray `label_studio/core/static_build/*.js` compiled-asset churn has been pushed back out of scope by restoring those files to git baseline; the remaining English-study closeout work is now narrower and mostly about retained upstream-file boundaries, especially a file-level split inside `label_studio/core/static/` between page-shell assets and upstream sample/template assets.
- The only tracked non-English-study change still left in the root worktree is `docker-compose.yml`, where `PLAYWRIGHT_BROWSERS_PATH` is now passed through to two services. Repo docs and `Dockerfile` support that knob, and because it defaults to empty it is currently a low-risk keep-or-drop decision rather than an urgent regression.
- The smallest safe hardening step is no longer pending: live `/home/node/.openclaw/openclaw.json` permissions are now `600`, and the live deep audit dropped from `5 critical / 4 warn / 1 info` to `4 critical / 4 warn / 1 info`.
- The `rightcode` provider blocker is contained for now: live cron state shows the known `403`-blocked worker jobs remain disabled, so there is no enabled empty-spin loop while waiting for quota recovery or a new model path.
- Live reporting is mixed but the remaining issue is now narrower: `report-2000-bjt` stays healthy, while `report-2200-bjt` times out and should be treated as a prompt-sizing task, not as a worker-stall or generic auth issue.
- Close remaining skill activation gaps one by one: `github`
- Maintain the local `skills/skill-vetting/` gate as the default pre-install review path
- Compare and vet external skill-vetting candidates before any install
- Maintain indexes and pitfall tracking so new files and lessons stay discoverable
- Work toward a clean multi-project convention for separate code folders and task tracking

## Waiting on external conditions

- ClawHub rate limit to clear so `openclaw-skill-vetter` and similar candidates can be inspected fully

## Recently resolved

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
