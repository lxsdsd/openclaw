# WSL + Docker Runtime Plan - 2026-03-13

## What is actually happening

This OpenClaw install is running on WSL2 + Docker.
The live runtime state is inside the gateway container at `/home/node/.openclaw`.
The workspace is bind-mounted from the host at `/home/gaga/openclaw/var/workspace`.

That means host-side checks can produce false negatives if they read a different local state path.
In this environment, diagnostics should prefer the live container runtime instead of the host-side default CLI path.

## Confirmed findings

- The gateway container can see and register Feishu tools: `feishu_doc`, `feishu_app_scopes`, `feishu_drive`, `feishu_perm`, `feishu_bitable`, and related Feishu chat/wiki tools.
- The gateway container can list live cron jobs for `main`, `watchdog`, `builder-a`, `research`, `monetization`, and `delivery-lead`.
- Earlier host-side checks were misleading because they could fall back to a bad local CLI state path and probe the wrong gateway target.
- Current disk pressure is not yet in the emergency zone. The most obvious removable-heavy item observed in runtime state is Playwright browser storage, but it should not be cleaned casually.

## Best operating mode for this machine

1. Keep the current WSL2 + Docker deployment.
2. Keep runtime state in Docker volumes.
3. Keep the workspace as a bind mount so project files stay easy to inspect and back up.
4. Do not do broad `docker system prune` or ad-hoc cache deletion on this machine.
5. Treat `assistant-state-backup/`, workspace recovery files, and Docker volumes as protected until a deliberate cleanup plan exists.
6. Run diagnostics against the live container runtime, not the host-side default CLI path.

## Safe diagnostic entrypoint

Use:

```bash
var/workspace/scripts/openclaw-live-cli.sh gateway status --no-probe
var/workspace/scripts/openclaw-live-cli.sh cron list
var/workspace/scripts/openclaw-live-cli.sh doctor
var/workspace/scripts/openclaw-live-cli.sh status
```

This uses `docker compose exec` against the running gateway container, so it reads the same runtime state the app is actually using.

## Auth-specific operating notes

- Do not inspect `.env` values during routine auth debugging unless the user explicitly asks for that exact read.
- If the user asks where a token or auth setting lives, reply with the file path first.
- In this stack, changing `.env` requires Docker service recreation to apply new env values; restart-only is not enough.
- Browser access is two-stage:
  1. gateway token
  2. device pairing
- Device pairing state is stored in the live container runtime under `/home/node/.openclaw/devices`.
- If the UI says `pairing required`, verify pending requests in the live gateway container runtime before changing any other auth setting.

## Why this is safer than cleanup-first

- It fixes the current source-of-truth problem without moving data.
- It avoids risky deletion under tight `C:` free space.
- It preserves restored state and current auth/runtime bindings.
- It gives one repeatable path for checking agents, Feishu tools, cron, and health.

## Next safe follow-ups

- Add low-disk monitoring and thresholds before any cleanup automation.
- Separate optional browser assets from critical runtime state before considering any space-reduction work.
- Use the live CLI path to audit cron errors, then fix the failing jobs one by one.
