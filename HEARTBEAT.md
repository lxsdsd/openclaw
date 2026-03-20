# HEARTBEAT.md

- Read `skills/task-driver/SKILL.md` rules first.
- Check Feishu Bitable task board (`app_token=P1B0bfR5saT9bys80GPcMr8rnkf`, `table_id=tblMVX0NKSoy3Oyb`) for actionable P0/P1 items.
- Read user comments on active task records for new instructions.
- If the top safe P0 or P1 item can move, continue it.
- If the top item is blocked on the user or an external dependency, record the blocker in `STATUS_BOARD.md` and move to the next safe task.
- Check `DISPATCH_BOARD.md` only when subagent work is active or likely needed.
- If a child task finished, review it and either accept it, reassign it, or leave the worker idle explicitly.
- If a child task is stalled or repeating the same failure without new evidence, steer, reroute, or escalate.
- Message the user only for meaningful completions, new blockers, user-action needs, or fresh security/cost/network risks.
- Keep `TODO_USER.md` current for actions that require the user directly.
- If there is no active safe work left, say you are ready for the next task.

## Multi-Agent Loop

1. Read `TODO_SHORT.md` and `STATUS_BOARD.md`.
2. Identify the highest-priority safe next action.
3. If the work is small or tightly coupled, do it in `main`.
4. If the work can benefit from delegation, use `TEAM_ROLES.md` and `MAIN_CONTROL_POLICY.md` to assign the right worker.
5. Prefer event-driven follow-up; use periodic checks only as a fallback.

## Guardrails

- Do not repeat the same waiting check every heartbeat unless status changed or enough time passed.
- Prefer work that produces runnable or verifiable output over administrative churn.
- Index and note maintenance are secondary; do them after real progress, not instead of it.
- If there is no new progress, no changed blocker, and no useful next action, reply `HEARTBEAT_OK`.
