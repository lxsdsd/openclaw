---
name: multi-agent-dispatch
description: Orchestrate a standing multi-agent workflow for active todo queues. Use when Codex needs to triage tasks, rank work by priority, assign work across `main`, `watchdog`, `builder-a`, `builder-b`, and `research`, keep workers busy, escalate repeated blockers, maintain a separate user-action list, and report only major milestones instead of noisy task-by-task updates.
---

# Multi-Agent Dispatch

Keep the parent agent in control. Use sub-agents as workers, not as independent owners.

## Core loop

1. Read the current queue from `TODO_SHORT.md`, `TODO_LONG.md`, `STATUS_BOARD.md`, and `TODO_USER.md` when relevant.
2. Rank work by `P0 -> P3`, then by deadline, blockers, user-visible impact, rework risk, and whether tasks can run in parallel.
3. Assign the first wave immediately instead of waiting for repeated user prompts.
4. Keep reassigning completed workers to the next safe queued task until the runnable queue is empty or blocked.
5. Update the tracking files after meaningful milestones.

## Agent roles

- `main`: triage, prioritize, assign, verify results, decide next steps, and handle all user-facing communication.
- `watchdog`: watch for stalls, empty worker slots, missing next actions, and queue drift; trigger the next task as soon as one finishes.
- `builder-a` and `builder-b`: execute one concrete implementation task at a time; avoid parallel edits in the same conflict-prone file tree.
- `research`: investigate docs, dependencies, compatibility, best practices, and uncertain decisions.

## Assignment rules

- Do not stop at one round of delegation; lay out the whole safe queue and keep it moving.
- If a worker finishes early, reassign it immediately to the next safe, non-conflicting task.
- If a task depends on user input, move that action into `TODO_USER.md` and continue other runnable work.
- Keep `watchdog` on a roughly 30-minute review cadence for progress checks, but do not wait for the timer when a worker has just finished.
- If a task repeats the same blockage three times, escalate to deeper troubleshooting; if it still cannot be resolved, send the user a concise blocker update with the required help.

## Reporting rules

- Report as the overall owner, not as a stream of raw worker logs.
- Push updates for major milestones, phase completions, meaningful blockers, and user-action requests.
- Do not spam the user with tiny subtask completions.
- Maintain `TODO_USER.md` as the single list of user-owned actions and push it at 08:00 UTC each day.
- In each user update, state what just finished, what is next, and whether the user needs to do anything.
- As the queue grows, also provide a planning view grouped by time horizon: today, this week, and this month, with the expected completion target for each major track.

## File hygiene

- Keep one-time actionable work in `TODO_SHORT.md`.
- Keep durable tracks in `TODO_LONG.md`.
- Keep user-owned actions in `TODO_USER.md`.
- Keep queue state, blockers, and current focus in `STATUS_BOARD.md`.
- Record durable preferences or operating rules in `MEMORY.md`.
- When the user defines new operating rules, fold them into this local custom skill or another local user-specific skill instead of mixing them into external/shared skills.
- Rewrite verbose user guidance into a cleaner operating model before recording it.

## Conflict and safety checks

- Do not assign two builders to the same conflict-prone file tree at the same time.
- Do not claim a task is complete until the responsible agent has returned a verifiable result.
- Do not push risky external actions to workers without an explicit user-approved path.
- When the queue is empty, tell the user clearly instead of inventing busywork.
