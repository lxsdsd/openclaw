# PITFALLS.md

## Purpose

Record real mistakes, false starts, hazards, and near-misses so they are not repeated.

## Entries

### 2026-03-12 - Missing startup memory files created noisy ENOENT errors
- What happened: Fresh workspace startup looked broken because daily memory files did not exist yet.
- Fix: Created the expected memory files and base memory.
- Rule: Initialize required memory files early in a fresh workspace.

### 2026-03-12 - Gateway was exposed on LAN by default config
- What happened: OpenClaw gateway bind was `lan`, which contradicted the desired local-only posture.
- Fix: Changed bind to `loopback` and rotated the token.
- Rule: Treat network exposure as a first-pass audit item on every new setup.

### 2026-03-12 - Global npm install for helper CLI failed with EACCES
- What happened: `npm i -g clawhub` failed due to no permission for `/usr/local/lib/node_modules`.
- Fix: Installed `clawhub` locally under workspace `.local-tools/` instead.
- Rule: Prefer workspace-local tooling over global installs unless global scope is necessary.

### 2026-03-12 - Registry inspect hit rate limits
- What happened: `clawhub inspect` returned rate-limit errors while trying to review remote skill files.
- Fix: Avoided repeated calls; captured pending review in `SKILL_INDEX.md`; proceeded with a local skill-first path.
- Rule: When registry/API limits hit, record the pending review and continue with local controls instead of brute forcing.

### 2026-03-12 - Token rotation broke existing client auth until reconnect
- What happened: After rotating the gateway token, some existing local clients still used the old token and started failing with `gateway token mismatch`.
- Fix: Keep the safer rotated token, do not widen exposure again, and reconnect clients so they pick up the current token.
- Rule: Expect auth continuity breaks after token rotation and treat client reconnect as part of the change.
- Follow-on effect: gateway-backed actions like `cron` may also fail until auth continuity is restored.

### 2026-03-12 - `rg` is not available in this runtime
- What happened: A quick file-existence check failed because the preferred `rg`/`rg --files` path is not installed here.
- Fix: Fall back to plain shell tools such as `find`, `test -f`, or `ls` instead of retrying `rg`.
- Rule: Probe for `rg` implicitly by handling command-not-found cleanly; keep a portable fallback ready for workspace maintenance tasks.
