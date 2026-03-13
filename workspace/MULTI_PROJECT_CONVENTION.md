# MULTI_PROJECT_CONVENTION.md

## Purpose

Keep parallel projects separated cleanly so code, task state, and agent work do not bleed into each other.

## Folder model

Use one top-level workspace bucket for active code projects:

- `projects/<project-slug>/`

Each project folder should keep its own code, local docs, and project-specific notes.

Example:

```text
projects/
  feishu-todo/
  data-pipeline/
  personal-site/
```

## Project minimums

Each active project should have these basics:

- repo or code files inside its own folder
- `README.md` for what the project is
- `STATUS.md` for current state, blockers, and next step
- `TASKS.md` for project-local actionable items that are too detailed for workspace-wide todo files

## Workspace-level vs project-level tracking

### Keep at workspace level

Use workspace files for:
- user-visible priorities
- cross-project roadmap items
- blockers that affect multiple projects
- reminders, auth steps, and external dependencies

Main files:
- `TODO_SHORT.md`
- `TODO_LONG.md`
- `STATUS_BOARD.md`
- `TODO_USER.md`

### Keep inside the project folder

Use project-local files for:
- implementation subtasks
- technical notes and decisions
- command snippets that only matter for that project
- repo-specific setup and validation steps

Main files:
- `projects/<project-slug>/STATUS.md`
- `projects/<project-slug>/TASKS.md`

## Naming rules

- Use short lowercase slugs with hyphens for project folders.
- Reuse the same slug in task references when possible.
- Do not mix unrelated codebases in one shared scratch folder.
- If a repo already has strong conventions, follow the repo and keep only a thin local `STATUS.md` if needed.

## Agent routing rules

- Assign one builder agent to one project task at a time.
- Do not send two builders into the same file tree unless the task split is clearly non-conflicting.
- Put research or design comparisons outside the project folder unless they become project-specific decisions.
- When handing work back, update the project `STATUS.md` before switching focus.

## Task promotion rules

- Put only the project's next meaningful user-visible step into `TODO_SHORT.md`.
- Keep durable project themes in `TODO_LONG.md` only if they matter beyond one coding session.
- Move detailed checklists into `projects/<project-slug>/TASKS.md` instead of bloating workspace-wide todo files.

## Suggested bootstrap for a new project

1. Create `projects/<project-slug>/`
2. Add `README.md`
3. Add `STATUS.md`
4. Add `TASKS.md`
5. Add one workspace-level todo only if the project is active now

## Guardrails

- Do not copy secrets or auth dumps into project notes.
- Keep cross-project standards in workspace docs, not duplicated in every repo.
- Prefer explicit status files over relying on chat history.

## Current usage decision

For this workspace, new parallel efforts should default to `projects/<project-slug>/` with local `STATUS.md` and `TASKS.md`, while the top-level todo files remain the control tower for prioritization.
