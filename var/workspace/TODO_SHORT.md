# TODO_SHORT.md

## Purpose

One-time actionable tasks. Clear completed items quickly so this file stays focused on active work only.

## Priority legend

- `P0` urgent, start now
- `P1` important, do next
- `P2` useful, schedule after higher priorities
- `P3` backlog, low urgency

## Active

- [P1] Slim or split the `report-2200-bjt` board-report prompt so the late report stops timing out; keep `report-2000-bjt` as the healthy reference path.
- [P1] Keep the current `rightcode`-blocked worker jobs disabled until quota recovers or a different working model path is chosen; do not let them resume empty-spin.
- [P1] Finish the last English-study closeout slice: continue from the new `web/dist` vs `web/src`, `core/static` shell-vs-sample, `annotation_templates` vs `core/examples`, the closed `sample-task-sin-headless.csv` dead-reference finding, the Django app runtime-chain split, and the new root-entry-vs-test-helper split, then decide which remaining upstream-restored `label_studio/` assets still need long-term retention.
- [P1] Keep `projects/english-study/delivery/docx/` in sync with the Markdown delivery docs and spot-check layout edge cases after each export.
- [P1] Check whether `github` should be fully activated next; if yes, prompt for `gh auth` and verify.
- [P1] Confirm final reminder time for tomorrow's hiking pack/check reminder.
- [P2] Align `SECURITY_TODO.md` with the current active work split.

## Done recently

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
