# HEARTBEAT.md - watchdog

1. Check whether any active item lacks an owner, next step, or recent progress.
2. If a task is stuck, identify whether it needs steer, reassignment, research help, or user input.
3. If an execution slot is idle, select the highest-priority independent task and recommend assignment.
4. Update `STATUS_BOARD.md` with blockers, owners, and overdue items.
5. If the queue is healthy and all owners are active, reply `HEARTBEAT_OK`.
