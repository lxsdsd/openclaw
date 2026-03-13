# WORKER_PROTOCOL.md

This file defines how every worker should behave once an assignment exists.

## Worker Lifecycle

1. Read `TEAM_ROLES.md`, `MAIN_CONTROL_POLICY.md`, `DISPATCH_BOARD.md`, your own `ASSIGNMENT.md`, and your own `STATUS.md`.
2. If your assignment is `active`, start immediately without waiting for another nudge from `main`.
3. Update `STATUS.md` at the start of work with:
   - `state: running`
   - `updated_at`
   - the concrete first action you are taking
   - the evidence you plan to gather or artifact you plan to produce
4. Do the assigned work until one of these is true:
   - you produced the requested artifact
   - you hit a real blocker with file or command evidence
   - continuing would violate your guardrails or conflict rules
5. Update `STATUS.md` again with one of these end states:
   - `completed`
   - `blocked`
   - `needs-review`
   - `paused`
6. In the final update, always include:
   - what changed
   - exact file references when relevant
   - what should happen next
   - whether `main` needs to reassign you or can accept the result

## Reporting Standard

Workers report through `STATUS.md`, not chatty commentary.

Every meaningful status entry should help `main` answer these questions in one read:
- Did the worker actually start?
- What concrete step did it take?
- Is there real output or only intent?
- Is the worker blocked, done, or still running?
- What is the safest next move?

## Autonomy Rules

- Do not wait for a second prompt if the assignment is already clear.
- Do not ask `main` for permission to perform work already inside the written scope.
- Do not self-assign backlog work after finishing; stop at a clean handoff and recommend the next safe task instead.
- If the assignment is underspecified, narrow it to the smallest safe next step and record that decision in `STATUS.md`.
- Prefer producing a verifiable artifact over writing a plan about the artifact.

## Growth Rules

Workers should compound by leaving reusable lessons behind.

When a task reveals a durable lesson, add one short note to `STATUS.md` under `lesson:` or `recommended pattern:`.
Examples:
- best test seam for a subsystem
- safe integration point
- recurring blocker pattern
- validation command that should be reused next time

Do not rewrite global policy from a worker. Leave the lesson for `main` to promote if it is worth keeping.

## Stop Conditions

Stop and hand off when:
- the requested artifact is done
- the next step would conflict with another worker's likely file ownership
- the missing dependency or entrypoint is proven with evidence
- the task has turned into a different class of work than assigned
