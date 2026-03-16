# TODO_SHORT.md

## Purpose

One-time actionable tasks. Clear completed items quickly so this file stays focused on active work only.

## Priority legend

- `P0` urgent, start now
- `P1` important, do next
- `P2` useful, schedule after higher priorities
- `P3` backlog, low urgency

## Active

- [P1] Finish the English-study closeout pass: review which upstream-restored `label_studio/` and `web/` files should remain, decide how to handle the local `.aptlibs/` and `.playwright-browsers/` workaround, and prepare the second rollback commit.
- [P1] Keep `projects/english-study/delivery/docx/` in sync with the Markdown delivery docs and spot-check layout edge cases after each export.
- [P1] Check whether `github` should be fully activated next; if yes, prompt for `gh auth` and verify.
- [P1] Confirm final reminder time for tomorrow's hiking pack/check reminder.
- [P2] Align `SECURITY_TODO.md` with the current active work split.

## Done recently

- [x] Added `projects/english-study/tools/export_delivery_docs.py`, refreshed the English-study test/deploy docs, and generated Word copies under `projects/english-study/delivery/docx/`.
- [x] Feishu DM channel paired and working.
- [x] Gateway token mismatch cleared.
- [x] Initialized `.learnings/` with `ERRORS.md`, `LEARNINGS.md`, and `FEATURE_REQUESTS.md`.
- [x] Verified `tavily` with the new API key via a live search.
- [x] Confirmed `find-skill` has no runtime-visible install under `/home/gaga/openclaw/var/workspace`, `/home/gaga/.openclaw`, or `/home/node/.openclaw`; treat it as not installed.
- [x] Root cause found for missing runtime skills: active runtime reads `/home/node/.openclaw` and `/home/node/.openclaw/workspace` skill roots.
