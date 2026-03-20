# TODO_SHORT.md

## Purpose

One-time actionable tasks. Clear completed items quickly so this file stays focused on active work only.

## Priority legend

- `P0` urgent, start now
- `P1` important, do next
- `P2` useful, schedule after higher priorities
- `P3` backlog, low urgency

## Active

- [P1] Rebuild and redeploy the local runtime from the source tree that already contains the operator-auth unification fix, then rerun `gateway status`, `gateway probe`, `gateway call`, and `status --all` on the live container.
- [P1] Add and validate an encrypted backup path for secret-bearing runtime state (`devices`, `identity`, `gh`, `credentials`, cookies, and secret env files) so migration does not depend only on local mounts plus D-drive snapshots.
- [P1] Reconcile reporting state: the live cron store is empty, so `report-2000-bjt` / `report-2200-bjt` are currently a scheduler-truth audit/rebuild task, not just a prompt-sizing task.
- [P1] Keep the current `rightcode`-blocked worker jobs disabled until quota recovers or a different working model path is chosen; do not let them resume empty-spin.

## Done recently

- [x] Closed the main repo-boundary/default-branch cleanup: `lxsdsd/openclaw` now defaults to `workspace-main`, `lxsdsd/English_study` defaults to `main`, and the local working branches track those long-term upstreams (`assistant-state-backup` `main` -> `origin/workspace-main`, `projects/english-study/repo` `main` -> `origin/main`), so future work now lands in the correct repo by default.
- [x] Finalized the `tavily-search` disposition: keep it as a reviewed local skill / accepted remote-API exception rather than an unresolved high-risk unknown; it remains bounded to Tavily official endpoints and still does not bypass the normal skill-vetting gate for any new skill.
- [x] Realigned `SECURITY_TODO.md` to live state: `gateway.bind` is tracked again as unresolved (`lan` -> loopback still pending), Feishu inbound hardening is marked done, and the local CLI `operator.read` credential-selection bug is now tracked explicitly.
- [x] Verified GitHub auth/push path is healthy again: `gh auth status` logs into `lxsdsd`, private repo access works, and `git push --dry-run` now reaches the remote and fails only on non-fast-forward state instead of auth.
- [x] Repaired the English-study delivery export chain by vendoring `python-docx` under `projects/english-study/tools/_vendor/`, updating `export_delivery_docs.py` to prefer the repo-local dependency, and regenerating all files under `projects/english-study/delivery/docx/`.
- [x] Finished the last English-study closeout slice by turning the boundary review into an explicit retention decision: runtime-coupled `label_studio/` assets stay in place, weakly-coupled upstream demo assets are now documented as archive candidates, and no physical `examples/archive` move will happen during closeout.
- [x] Revalidated child-lane ownership at the 2026-03-16 14:15 UTC supervisor pass: no child worker is active, the known provider-blocked worker crons remain intentionally disabled, and the live recurring report issue is now tracked specifically as `report-2200-bjt` timeout repetition rather than as a generic worker stall.
- [x] Kept child-lane ownership honest at the 2026-03-16 07:03 UTC supervisor pass: no child worker is currently active, the known provider-blocked worker crons remain intentionally disabled, and the late report problem is now tracked as a timeout-sizing issue rather than a generic worker stall.
- [x] Tightened live `/home/node/.openclaw/openclaw.json` permissions from `755` to `600` and confirmed the deep audit dropped from `5 critical / 4 warn / 1 info` to `4 critical / 4 warn / 1 info`.
- [x] Added `projects/english-study/tools/export_delivery_docs.py`, refreshed the English-study test/deploy docs, and generated Word copies under `projects/english-study/delivery/docx/`.
- [x] Repaired the polluted English-study editor source from `web/dist/libs/editor/main.js.map`, re-localized the most visible UI/error-page text, and reverted the stray `label_studio/core/static_build/*.js` compiled-asset edits back to git baseline.
- [x] Kept `用户指南.md` as an in-repo Chinese operator guide with English-study wording, and explicitly downgraded untracked `roadmap.md` to upstream historical context rather than a delivery commitment.
- [x] Feishu DM channel paired and working.
- [x] Gateway token mismatch cleared.
- [x] Initialized `.learnings/` with `ERRORS.md`, `LEARNINGS.md`, and `FEATURE_REQUESTS.md`.
- [x] Verified `tavily` with the new API key via a live search.
- [x] Confirmed `find-skill` has no runtime-visible install under `/home/gaga/openclaw/var/workspace`, `/home/gaga/.openclaw`, or `/home/node/.openclaw`; treat it as not installed.
- [x] Root cause found for missing runtime skills: active runtime reads `/home/node/.openclaw` and `/home/node/.openclaw/workspace` skill roots.
