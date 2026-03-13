# OpenClaw Security Report - 2026-03-12

## Scope

Initial read-only review followed by targeted hardening changes focused on exposure reduction and secret-handling safety.

## Environment

- OS: Debian GNU/Linux 12 (bookworm)
- OpenClaw install: stable channel, pnpm install
- Gateway target: `ws://127.0.0.1:18789`
- Tailscale: off / unavailable in this environment

## Changes applied

1. Changed gateway bind from `lan` to `loopback`
2. Rotated gateway token to a new long random value
3. Disabled elevated execution by default: `tools.elevated.enabled: false`
4. Disabled browser evaluate execution: `browser.evaluateEnabled: false`
5. Tightened browser SSRF posture: `browser.ssrfPolicy.dangerouslyAllowPrivateNetwork: false`
6. Added local access rules and a sensitive-path policy in workspace docs

## Current status after changes

- `openclaw status --all` shows `Bind: loopback`
- `openclaw security audit --deep` now reports `0 critical · 1 warn · 1 info`
- Remaining warning: `gateway.trusted_proxies_missing`
  - This is expected if the gateway stays local-only and is not placed behind a reverse proxy.
  - If a reverse proxy is introduced later, explicitly configure `gateway.trustedProxies`.

## Key local risks now

1. Browser control remains enabled. Even with stricter settings, it still expands capability and should be kept only if you actually use it.
2. Control UI / gateway auth continuity changed because the token was rotated. Existing clients may need to reconnect using the new local configuration.
3. Public-web research is still only partially complete for billing/cost footguns.

## Publicly disclosed OpenClaw security issues found

Using GitHub security advisories, I found at least these recent published advisories:

1. `GHSA-vhwf-4x96-vqx2` - skills installer path-rebinding write-outside-tools-root issue
   - Affected: `<= 2026.3.7`
   - Fixed: `2026.3.8`
   - Relevance here: avoid running older versions; be cautious with skill installation paths.

2. `GHSA-g7cr-9h7q-4qxq` - Microsoft Teams sender allowlist bypass in a route-allowlist edge case
   - Affected: `<= 2026.3.7`
   - Fixed: `2026.3.8`
   - Relevance here: channel/group allowlists must be explicit and version should stay current.

3. `GHSA-rchv-x836-w7xp` - Dashboard leaked gateway auth material via browser URL/query and localStorage
   - This is directly relevant to your concern about secret exposure.
   - Practical control: keep gateway local-only, avoid leaking auth material into browser-facing flows, and avoid unnecessary browser persistence of tokens.

## Version posture

- Local install is on stable `2026.3.11`
- That is newer than the `2026.3.8` fixes noted above

## Data-handling policy adopted for this workspace

- Do not read passwords, `.env` files, API keys, tokens, cookies, browser profiles, or private chat stores by default
- Never read WeChat-related files by default
- Feishu project files may be read when task-related, but any Feishu secret/credential remains sensitive and ask-first
- If accidental access occurs, stop and report the category/path without repeating the secret value
- Do not enable potentially paid providers without explicit approval and cost controls

## Recommended next changes

1. Decide whether to disable browser control entirely
2. Do a focused pass on cost/billing-footgun reports from issues/PRs
3. Finalize identity/bootstrap cleanup so startup is less noisy and less ambiguous
