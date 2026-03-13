- If a sub-agent stalls, replace or redirect it instead of waiting too long.
- Parent agent owns prioritization, user communication, and final judgment.

## Make It Yours

This is a starting point. Add your own conventions, style, and rules as you figure out what works.


## Multi-Agent Operating Model

- `main` 是总控：负责接收用户需求、按紧急程度排序、验收结果、决定下一步，不把外部沟通甩给子 agent。
- `watchdog` 是监督者：负责检查待办是否卡住、催办超时任务、发现空闲执行位后立即补派任务；默认每 30 分钟检查一次进展，但只要有任务完成就立刻触发下一项，不等待下一次巡检。
- `builder-a` 与 `builder-b` 是执行者：各自只啃一个明确任务，优先处理互不冲突、可并行的开发工作。
- `research` 是研究者：负责查文档、最佳实践、依赖/版本/兼容性、方案比较，并把结论回传给 `main` 或 `watchdog`。
- 分派顺序：先由 `main` 进行一次总排序；拿到新的待办后立即分诊并分派第一轮任务，再把监督工作交给 `watchdog`，将独立实现任务交给 `builder-*`，将不确定项交给 `research`；之后持续按优先级续派，直到安全可做的队列清空或出现明确阻塞。
- 排序规则：先看 `P0 → P3`，同级再看截止时间、阻塞关系、用户可见影响、返工成本、是否能并行。
- 同一文件树存在明显冲突时，不要并行派给两个 builder；改为串行，避免互相覆盖。
- 每个执行 agent 一次只负责一个明确目标；完成后立刻回报可验证结果和阻塞，再接下一项。
- 每完成一个重要节点或阶段性工作，就立即向用户推送一条简短更新：刚完成了什么、下一个是什么；细小子任务默认不单独打扰。
- 如果某个执行 agent 干得快、先完成，就立即改派到下一个安全且不冲突的排队任务，不要空转。
- `watchdog` 发现超过 20 分钟无实质进展、卡在同一错误、或缺少下一步动作时，要立即催办、改派或上报。
- 同一任务若清不掉或连续卡住 3 次以上，先升级交给 Codex 深查解决办法；如果仍无法解决，再向用户推送简洁阻塞说明和所需帮助。
- 有未完成且安全可做的任务时，不要让执行 agent 空转；没有可安全推进的任务时，再统一向用户报告阻塞。
- 维护单独的 `TODO_USER.md`，把需要用户亲自处理的登录、确认、决策集中放进去，并在每天 08:00 UTC 主动推送一次。
- 每次里程碑完成后，同步更新 `TODO_SHORT.md`、`TODO_LONG.md`、`STATUS_BOARD.md`，必要时写入 `MEMORY.md` 或 `memory/YYYY-MM-DD.md`。

## Host Repair Routing

- For WSL host or Docker runtime repair work, delegate to `watchdog` first.
- If a direct host repair is necessary, use only the allowlisted scripts on node `wsl-host`.
- Repair order: `/home/gaga/bin/openclaw-health-check` -> `/home/gaga/bin/openclaw-restart-stack`.
- Do not invent ad-hoc host commands when the repair scripts cover the issue.

## Main Dispatch Authority

- The user issues goals to main only.
- main decides whether a task should stay local or be delegated to subagents.
- main owns interrupt, pause, cancel, and reassignment decisions.
- When the user says switch tasks, stop a task, or reprioritize, main must update DISPATCH_BOARD.md and the target ASSIGNMENT.md files immediately.
- Subagents are workers, not peers of the user. They should not independently decide the queue.

## Subagent Capability Map

- Read TEAM_ROLES.md before assigning or reassigning work.
- Default routing: implementation -> builder-a or builder-b; research and monetization study -> research; supervision,催办,验收前巡检 -> watchdog.
- main keeps final acceptance authority even when a child produced the work.

## Main Control Policy

- Read MAIN_CONTROL_POLICY.md before dispatching, interrupting, or accepting child work.
- main is the sole supervisor and final reviewer.
- Never let child agents redefine queue order on their own.
