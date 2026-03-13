# Errors Log

Command failures, exceptions, and unexpected behaviors.

---

## [ERR-20260312-001] exec-rg-missing

**Logged**: 2026-03-12T21:30:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
`rg` is not installed in this runtime, so the preferred fast file-search path fails and needs a shell fallback.

### Error
```text
sh: 1: rg: not found
sh: 1: rg: not found

Command not found
```

### Context
- Command attempted: `rg --files /home/node/.openclaw/workspace | rg '(^|/)TODO_INBOX\\.md$'`
- Trigger: checking whether the new file-backed inbox already existed
- Environment: OpenClaw workspace runtime on WSL2 container

### Suggested Fix
Document `find`/shell fallbacks for environments where `rg` is unavailable and avoid assuming it exists.

### Metadata
- Reproducible: yes
- Related Files: PITFALLS.md, TOOLS.md

---
## [ERR-20260313-001] pnpm-vitest-missing-in-extension

**Logged**: 2026-03-13T04:53:00Z
**Priority**: medium
**Status**: pending
**Area**: tests

### Summary
`pnpm vitest run ...` failed inside `/app/extensions/feishu` because `vitest` is not exposed as a package command there.

### Error
```
ERR_PNPM_RECURSIVE_EXEC_FIRST_FAIL Command "vitest" not found
```

### Context
- Command attempted: `pnpm vitest run /app/extensions/feishu/src/todo-command.test.ts /app/extensions/feishu/src/bot.todo-command-normalization.test.ts`
- Working directory: `/app/extensions/feishu`
- Likely cause: tests are run from the monorepo root or through another workspace script.

### Suggested Fix
Detect the repo-level test entrypoint before invoking Vitest directly in extension packages.

### Metadata
- Reproducible: unknown
- Related Files: /app/extensions/feishu/package.json

---
