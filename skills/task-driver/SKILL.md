# task-driver

Proactive task detection, triage, and continuous execution skill.

## Purpose

Ensure the assistant always has work to do by:
1. Periodically checking the Feishu Bitable task board for actionable items
2. Reading user comments on task records for new instructions
3. Auto-dispatching safe tasks to sub-agents when appropriate
4. Marking tasks that need user action with a clear flag
5. Continuously clearing the queue without waiting for repeated nudges

## Task Board

- **Bitable**: `app_token=P1B0bfR5saT9bys80GPcMr8rnkf`, `table_id=tblMVX0NKSoy3Oyb`
- **Priority field**: `重要紧急程度` (values: P0, P1, P2, P3)
- **Status field**: `进展` (values: 待开始, 进行中, 已完成, 已停滞)
- **Owner field**: `任务归属` (values: 用户, main, watchdog, builder-a, builder-b, research, monetization, delivery-lead)
- **Progress field**: `最新进展记录`

## Priority Rules

- P0: urgent, start immediately
- P1: important, do next
- P2: useful, schedule after higher priorities
- P3: backlog, low urgency

## Execution Rules

### When to trigger
- On heartbeat: check task board for actionable P0/P1 items
- After completing any task: immediately check for next safe task
- When user sends a message referencing tasks: re-read board first

### Task selection
1. Sort by priority (P0 first), then by start date (oldest first)
2. Skip tasks with `任务归属=用户` (these need user action)
3. Skip tasks with `进展=已停滞` unless the blocker is resolved
4. Prefer tasks that don't conflict with currently running sub-agent work

### Before starting old tasks
- If a task was created more than 7 days ago and hasn't been touched, re-validate it first
- Check if the context/environment has changed since the task was created
- Update the task description if the original scope is outdated

### Dispatch rules
- Tasks assigned to `main`: execute directly
- Tasks assigned to `builder-a` or `builder-b`: spawn sub-agent with task context
- Tasks assigned to `watchdog`: spawn monitoring sub-agent
- Tasks assigned to `research`: spawn research sub-agent
- Do not run conflicting file-tree tasks in parallel

### User-action tasks
- Tasks with `任务归属=用户` must have clear instructions in `最新进展记录`
- Keep `TODO_USER.md` in sync with user-action tasks from the board
- Do not nag the user about these unless priority is P0

### After completion
- Update `进展` to `已完成`
- Fill `实际完成日期`
- Update `最新进展记录` with completion summary
- Check for next task immediately

## User Comments

When starting work on a task, read the Bitable record to check if the user has added comments or updated the description since last check. Incorporate any new instructions.

## Sync Rules

- The Feishu Bitable is the single source of truth for task status
- `TODO_SHORT.md` is a local working copy for quick reference during heartbeats
- When updating one, update the other
- `TODO_USER.md` mirrors user-action items from the board
