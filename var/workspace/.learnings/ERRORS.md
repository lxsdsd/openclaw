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

## [ERR-20260315-001] agent-reach host-side recovery

**Logged**: 2026-03-15T08:18:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary

Large single-shot install commands timed out in the exec harness, and a retry hit npm `ENOTEMPTY` because `mcporter` was already half-installed.

### Error

```
TIMEOUT: node invoke timed out
npm error code ENOTEMPTY
npm error syscall rename
npm error path /home/gaga/agent-reach-env/lib/node_modules/mcporter
npm error dest /home/gaga/agent-reach-env/lib/node_modules/.mcporter-7EgWGV12
npm error ENOTEMPTY: directory not empty, rename /home/gaga/agent-reach-env/lib/node_modules/mcporter -> /home/gaga/agent-reach-env/lib/node_modules/.mcporter-7EgWGV12
```

### Context

- Command/operation attempted: host-side `agent-reach` toolchain recovery in `/home/gaga/agent-reach-env`
- Large `npm install` and `curl+tar+install` one-shot commands were more likely to time out under the current exec harness.
- The useful recovery path was: inspect the env first, verify whether the binaries already landed, then finish wiring via symlink/config updates instead of retrying the same large install blindly.

### Suggested Fix

Break long installs into smaller verifiable steps, prefer post-failure inspection before retry, and treat partially populated `node_modules` as evidence rather than assuming the install failed completely.

### Metadata

- Reproducible: yes
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md
- See Also: none

---

## [ERR-20260315-002] host github download path

**Logged**: 2026-03-15T08:22:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary

Direct host `curl` downloads from `github.com:443` timed out twice during host-side `gh` bootstrapping, while the container already had a working `gh` binary and valid auth.

### Error

```
curl: (28) Failed to connect to github.com port 443 after 135121 ms: Couldnt
## [ERR-20260315-002] host github download path

**Logged**: 2026-03-15T08:22:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
Direct host `curl` downloads from `github.com:443` timed out twice during host-side `gh` bootstrapping, while the container already had a working `gh` binary and valid auth.

### Error
```

curl: (28) Failed to connect to github.com port 443 after 135121 ms: Couldn't connect to server
curl: (28) Failed to connect to github.com port 443 after 135108 ms: Couldn't connect to server

```

### Context
- Command/operation attempted: download `gh_2.88.1_linux_amd64.tar.gz` onto the host for a true host-local `gh` install.
- The low-risk fallback that worked was to wrap the container's existing `/usr/bin/gh` into `/home/gaga/agent-reach-env/bin/gh` and verify `gh auth status` through that path.

### Suggested Fix
When host GitHub egress is flaky, prefer the already-healthy container-backed `gh` path before retrying direct host downloads.

### Metadata
- Reproducible: unknown
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md
- See Also: ERR-20260315-001

---
## [ERR-20260315-001] python

**Logged**: 2026-03-15T10:26:00Z
**Priority**: low
**Status**: pending
**Area**: docs

### Summary
Attempted to run a workspace edit script with `python`, but this environment only exposes `python3`.

### Error
```

/bin/sh: 1: python: not found

````

### Context
- Command/operation attempted: multi-file docs cleanup script
- Input or parameters used: `python - <<'PY' ...`
- Environment details: WSL/OpenClaw runtime with `python3` available and `python` absent

### Suggested Fix
Use `python3` for future ad-hoc edit scripts in this workspace.

### Metadata
- Reproducible: yes
- Related Files: projects/english-study/repo/README.md

---
## [ERR-20260316-001] execution-board-injected-only

**Logged**: 2026-03-16T00:25:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
A background check failed because `EXECUTION_BOARD.md` was available in injected session context but missing from the real workspace filesystem.

### Error
```text
System: stat: cannot statx '/home/node/.openclaw/workspace/EXECUTION_BOARD.md': No such file or directory
System: stat: cannot statx '/home/node/.openclaw/workspace/STATUS_BOARD.md': No such file ...
````

### Context

- Operation attempted: async runtime board check on the node-side workspace mirror
- Trigger: handling an exec-event completion after a background command exited with code 1
- Environment: OpenClaw workspace on WSL host with injected project-context files available separately from on-disk files

### Suggested Fix

When a board file appears in injected context, confirm it also exists on the real filesystem before using it in shell checks or node-side stat commands; materialize the file locally if it only exists in injected context.

### Metadata

- Reproducible: unknown
- Related Files: EXECUTION_BOARD.md, STATUS_BOARD.md

---

## [ERR-20260316-002] shell-backquote-substitution

**Logged**: 2026-03-16T04:57:17Z
**Priority**: low
**Status**: pending
**Area**: orchestration

### Summary

An async shell command failed before execution because the generated `/bin/sh` snippet had an unterminated backquote substitution.

### Error

```text
/bin/sh: 1: Syntax error: EOF in backquote substitution
```

### Context

- Command/operation attempted: background `exec` shell invocation from this session
- Trigger: handling a prior async workspace command completion event
- Environment details: `/bin/sh` on the current OpenClaw runtime
- Extra note: the system event did not preserve the full original shell snippet, so the exact offending backquote location is unknown

### Suggested Fix

Avoid backticks in generated shell one-liners; prefer `$(...)`, single-quoted heredocs, or direct file tools for edits, and run `sh -n` on complex shell snippets before backgrounding them.

### Metadata

- Reproducible: unknown
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md
- See Also: ERR-20260315-001

---

## [ERR-20260316-003] live-cli-gateway-normal-closure

**Logged**: 2026-03-16T08:39:45Z
**Priority**: low
**Status**: pending
**Area**: infra

### Summary

A live OpenClaw CLI probe failed once because the gateway connection closed with code `1000 normal closure`, even though adjacent runtime probes succeeded.

### Error

```text
gateway connect failed: Error: gateway closed (1000): Error: gateway closed (1000 normal closure): no close reason
```

### Context

- Command/operation attempted: a live `scripts/openclaw-live-cli.sh` probe during supervisor-state verification
- Trigger: handling runtime-state checks from the workspace against the local loopback gateway `ws://127.0.0.1:18789`
- Environment details: WSL2 + Docker OpenClaw deployment with loopback gateway access
- Adjacent evidence: nearby `status --all` and `cron list --all --json` probes still succeeded, so this looked transient rather than a full runtime outage

### Suggested Fix

Treat isolated `1000 normal closure` failures as transient until a second live probe also fails; retry once with the same CLI command before escalating to host self-repair.

### Metadata

- Reproducible: unknown
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md, /home/gaga/openclaw/var/workspace/EXECUTION_BOARD.md

---

## [ERR-20260317-001] truncated-placeholder-text-written-into-real-files

**Logged**: 2026-03-17T01:05:00Z
**Priority**: medium
**Status**: pending
**Area**: workspace-editing

### Summary

A read/edit path allowed placeholder truncation text like `[94 more lines in file. Use offset=221 to continue.]` to end up inside real workspace files, which broke source files and Markdown docs.

### Error

```text
[94 more lines in file. Use offset=221 to continue.]
[153 more lines in file. Use offset=201 to continue.]
```

### Context

- Affected files included `projects/english-study/repo/web/libs/editor/src/components/App/App.jsx` and `projects/english-study/repo/用户指南.md`
- The safe recovery path was to trust the real filesystem, search for the placeholder pattern with `rg`, and rebuild damaged files from source maps or other canonical artifacts instead of continuing to edit the truncated file
- This presented as injected/read-view content diverging from the actual file on disk

### Suggested Fix

Before editing a large file that may have been truncated in a tool view, verify the real on-disk content first. If placeholder truncation text is present in a source file, recover from a canonical source such as a source map, prior commit, or generated artifact before making further edits.

### Metadata

- Reproducible: unknown
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md, /home/gaga/openclaw/var/workspace/projects/english-study/repo/web/libs/editor/src/components/App/App.jsx, /home/gaga/openclaw/var/workspace/projects/english-study/repo/用户指南.md

---

## [ERR-20260317-002] wrong-openclaw-live-cli-script-path

**Logged**: 2026-03-17T02:08:00Z
**Priority**: low
**Status**: pending
**Area**: infra

### Summary

I retried live OpenClaw CLI probes with the old root-level script path, but this workspace uses `var/workspace/scripts/openclaw-live-cli.sh` instead.

### Error

```text
/bin/sh: 1: scripts/openclaw-live-cli.sh: not found
/bin/sh: 1: /home/gaga/openclaw/scripts/openclaw-live-cli.sh: not found
```

### Context

- Command/operation attempted: runtime verification during supervisor-state follow-up
- The working script path discovered on disk was `/home/gaga/openclaw/var/workspace/scripts/openclaw-live-cli.sh`
- The failure was not a runtime outage; it was a stale path assumption in the command itself

### Suggested Fix

When running live OpenClaw CLI probes from this workspace, prefer `/home/gaga/openclaw/var/workspace/scripts/openclaw-live-cli.sh` or resolve the script with `find`/`rg` first instead of assuming a root-level `scripts/` path.

### Metadata

- Reproducible: yes
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md, /home/gaga/openclaw/var/workspace/TOOLS.md
- See Also: ERR-20260316-003

---

## [ERR-20260317-003] export-delivery-docs-missing-python-docx

**Logged**: 2026-03-17T02:09:30Z
**Priority**: low
**Status**: pending
**Area**: docs

### Summary

The delivery doc export script failed under the default system Python because `python-docx` is not installed there.

### Error

```text
ModuleNotFoundError: No module named 'docx'
```

### Context

- Command/operation attempted: `python3 /home/gaga/openclaw/var/workspace/projects/english-study/tools/export_delivery_docs.py`
- The next safe fallback is to retry with the project-local virtualenv before considering any package install

### Suggested Fix

Run the export script with the project virtualenv that already carries doc-generation dependencies, or document that `python-docx` is a prerequisite for this helper.

### Metadata

- Reproducible: yes
- Related Files: /home/gaga/openclaw/var/workspace/.learnings/ERRORS.md, /home/gaga/openclaw/var/workspace/projects/english-study/tools/export_delivery_docs.py

---
