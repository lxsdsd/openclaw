# DISPATCH_BOARD.md

## Rule

- The user talks to main only.
- main is the sole dispatcher for subagents.
- Subagents do not self-assign work. They execute only what is written in their current ASSIGNMENT.md.
- Every active subagent must follow `agents/WORKER_PROTOCOL.md` and prove real start via its own `STATUS.md`.
- If the user says stop, pause, switch, reprioritize, or replace, main must update this board and the target ASSIGNMENT.md files immediately.

## Active assignments

## Supervisor pass - 2026-03-13 12:55 UTC

- runtime verified on `wsl-host`: gateway `127.0.0.1:18789` is healthy, Feishu is running, and `research` exists in the live agent config
- local host-side CLI checks can show false negatives when they fall back to missing `~/.openclaw/openclaw.json`; the live stack here is using `/home/gaga/openclaw/var/config/openclaw.json`
- no child lane is currently in a verified running state; rewrite the target `ASSIGNMENT.md` before the next worker run instead of assuming any lane is still live

### builder-a

- status: paused
- assignment file: `agents/builder-a/ASSIGNMENT.md`
- objective: resolve the remaining Feishu `记录待办` bottom-menu gap by proving whether it arrives as plain text, callback/event, or another route, then patch or prove the exact missing integration point
- current step: paused pending main review of the delivered explicit-text capture patch in `agents/builder-a/STATUS.md`; the next reactivation should target menu-path evidence directly instead of repeating the already-proven text path
- success output: real executable patch or exact blocker evidence recorded in `agents/builder-a/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority implementation task

### research

- status: completed
- assignment file: `agents/research/ASSIGNMENT.md`
- objective: ranked monetization shortlist for the current OpenClaw + Feishu + automation stack
- current step: idle until main assigns a new non-overlapping research task
- success output: updated `MONETIZATION_OPTIONS.md` plus concise rationale in `agents/research/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority research task

### builder-b

- status: completed
- assignment file: `agents/builder-b/ASSIGNMENT.md`
- objective: prepare the non-conflicting verification lane for the Feishu `记录待办` implementation
- current step: idle until main assigns the next non-conflicting validation or hardening task
- success output: minimal test patch or exact validation seam recorded in `agents/builder-b/STATUS.md`
- interrupt rule: pause immediately if main assigns a higher-priority non-conflicting implementation task

### watchdog

- status: completed
- assignment file: `agents/watchdog/ASSIGNMENT.md`
- objective: audit worker progress, detect stalls, and recommend rerouting without doing implementation work
- current step: idle; the latest supervision pass already verified runtime health and found no currently running child lane that needs immediate rescue
- success output: concrete supervision notes in `agents/watchdog/STATUS.md`

### monetization

- status: completed
- assignment file: `agents/monetization/ASSIGNMENT.md`
- objective: keep one realistic current赚钱方向 moving for the OpenClaw + Feishu + automation stack
- current step: idle; the latest pass accepted the current best wedge and handed validation back to main instead of opening another worker loop
- success output: updated `MONETIZATION_OPTIONS.md` and a concrete current focus in `agents/monetization/STATUS.md`

### delivery-lead

- status: completed
- assignment file: `agents/delivery-lead/ASSIGNMENT.md`
- objective: own review, integration, testing, polish, and delivery docs for long-running software projects near handoff
- current step: idle until main writes a fresh follow-up; the last completed item was the docs typo fix plus local commit `fbcc0dc` in `projects/english-study/repo`
- success output: project notes plus a browser-validation artifact or one additional safe code-level fix recorded in `agents/delivery-lead/STATUS.md`
