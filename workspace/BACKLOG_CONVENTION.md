# BACKLOG_CONVENTION.md

## Purpose

Define one clean way to track future capability work so ideas do not sprawl across random notes.

## Core model

Use three layers only:

1. `TODO_SHORT.md` for one-time active tasks that should be closed soon.
2. `TODO_LONG.md` for durable tracks that stay alive across days or weeks.
3. Track notes like this file only when a stable operating rule or reusable structure is needed.

## What belongs where

### `TODO_SHORT.md`

Use for:
- concrete user asks
- next-step implementation work
- time-based reminders or follow-ups
- unblock tasks that are waiting on auth, confirmation, or a single action

Rules:
- Keep entries short and action-oriented.
- Prefer one line per task.
- Remove completed items quickly.
- If a task keeps generating more follow-up work, promote the broader theme into `TODO_LONG.md`.

### `TODO_LONG.md`

Use for:
- ongoing capability tracks
- multi-step product or workflow improvements
- recurring operational improvements
- longer horizon work that should survive cleanup of short tasks

Rules:
- Write each entry as a track, not a micro-task.
- Keep only durable items here.
- When a track gets an immediately actionable next step, mirror that step into `TODO_SHORT.md`.
- When a track is established and no longer needs active shaping, either retire it or convert it into a reference doc.

## Standard track format

Write durable tracks in this pattern:

- `[P1] Build/Improve/Establish <track name>: <brief outcome>`

Examples:
- `[P1] Build Feishu todo capture: inbox entry, triage, editable priority, and todo view.`
- `[P1] Establish multi-project workspace convention: folders, labels, and task ownership.`

## Priority meaning

- `P0`: blocks important work now or carries urgent user/security impact
- `P1`: important active work that should move soon
- `P2`: valuable improvement that can wait behind active work
- `P3`: later idea, optional exploration, or low-pressure polish

## Time buckets for planning views

When summarizing the queue for the user, group work into:
- today
- this week
- this month

Only include items that have a realistic path in that window.

## Promotion and cleanup rules

- Promote from short to long when a task becomes a repeatable theme or capability track.
- Break out a dedicated Markdown doc when the rule/process will be reused.
- Retire long-track entries when the convention is stable and captured elsewhere.
- Keep `STATUS_BOARD.md` aligned with whichever tracks are currently front-of-queue.
- Add any new durable operational doc to `KNOWLEDGE_INDEX.md`.

## Current usage decision

For this workspace:
- use `TODO_SHORT.md` as the live execution queue
- use `TODO_LONG.md` as the capability roadmap
- use dedicated docs like this one to lock in conventions once they are clear
