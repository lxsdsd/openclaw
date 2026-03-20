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

### 2026-03-18 - Reading `.env` during auth debugging leaked the wrong kind of context
- What happened: Token debugging drifted into reading `.env` directly even after the user had already said not to inspect that file.
- Fix: Treat `.env` and other secret-bearing files as path-only references by default; report file path, key name, and presence or absence without reading values.
- Rule: If the user asks where a setting lives, answer with the file path first and stop there unless a sensitive read is explicitly required.

### 2026-03-18 - `.env` edits did not reach the running gateway after restart-only attempts
- What happened: Gateway auth debugging kept failing because `.env` had changed, but the Docker service was only restarted, not recreated, so the running container kept stale env state.
- Fix: After changing `.env`, recreate the relevant Docker service instead of relying on `docker compose restart`.
- Rule: In this stack, `.env` changes are a container-recreation event, not a plain restart event.

### 2026-03-18 - Browser auth failure had two layers, not one
- What happened: The UI first failed on gateway token mismatch or missing token, and after that was corrected it still failed on `pairing required`.
- Fix: Treat browser access as a two-step auth flow: first gateway token, then device pairing approval.
- Rule: Do not assume `pairing required` means the token is wrong, and do not assume a token fix resolves device pairing automatically.

### 2026-03-18 - Pairing approval must target the live container runtime
- What happened: Device-pair approval attempts were easy to send at the wrong runtime or through a CLI path that was itself failing to handshake with the local gateway.
- Fix: Verify pending requests in the live gateway container runtime and approve against that state source only.
- Rule: For this machine, device pairing source of truth is the running gateway container state under `/home/node/.openclaw`, not host-side guesses.

### 2026-03-20 - Security audit findings still need manual skill review
- What happened: `openclaw security audit --deep` flagged the local `tavily-search` skill for environment-harvesting because it reads `TAVILY_API_KEY` and sends it to a remote API.
- Fix: Read the actual script before trusting or deleting it; in this case the code only sends the Tavily API key plus user-provided query/URL to Tavily's own endpoints, so the finding is security-significant but not enough on its own to prove malicious exfiltration.
- Rule: Treat audit hits on local skills as a mandatory manual review trigger, not as automatic proof of compromise and not as something to wave away without reading the code.

### 2026-03-20 - Workspace live-cli wrappers may fail from runtimes without Docker
- What happened: `scripts/openclaw-live-cli.sh` was the right conceptual path for container-truth checks, but it exited immediately because the current agent runtime does not have a usable `docker` binary.
- Fix: Do not assume workspace helper scripts are runnable from every agent runtime; check local tool availability first and keep a direct-state fallback such as reading files under the live container runtime when possible.
- Rule: When a diagnosis depends on container-truth, verify Docker availability in the current runtime before routing through a wrapper script.
