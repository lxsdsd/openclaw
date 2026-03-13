# WSL runtime notes

This install uses the official OpenClaw image with a local WSL override file:

- base: `docker-compose.yml`
- WSL override: `docker-compose.wsl.yml`

## Why the override exists

Docker Desktop in this distro is currently not exposing WSL bind mounts correctly to the Linux containers.
To keep the installation working and isolated, runtime state is stored in the named Docker volume `openclaw_openclaw_state` instead of bind-mounting config directly from WSL.

## Common commands

- Start: `scripts/openclaw-wsl-up.sh`
- Stop: `scripts/openclaw-wsl-down.sh`
- Logs: `scripts/openclaw-wsl-logs.sh`

## Manual changes you still need

- Edit `.env` and replace `YOUR_OPENCLAW_GATEWAY_TOKEN_HERE`.
- Edit `.env` and replace `YOUR_RIGHTCODE_API_KEY_HERE`.
- Add your model/provider credentials manually.
- Tailscale Serve still needs manual completion if tailnet HTTPS is not enabled on this node/tailnet.

## Volume-backed config check

`$HOME/bin/docker compose -f docker-compose.yml -f docker-compose.wsl.yml run --rm --no-deps --entrypoint sh openclaw-gateway -lc 'sed -n "1,200p" /home/node/.openclaw/openclaw.json'`
