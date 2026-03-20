# Integration Audit — 2026-03-19

## Canonical live paths

- Runtime config root: `../config/`
- Runtime workspace root: `.`
- Pairing state: `../config/devices/`
- GitHub auth state: `../config/gh/`
- MCP config: `config/mcporter.json`
- Xiaohongshu cookie state: `../xiaohongshu-mcp/cookies.json`
- QMD service definition: `../qmd-memory-service/docker-compose.yml`

## Root cause found

- The machine had more than one apparent OpenClaw state root.
- Docker control was also split between WSL-native Docker and a Windows wrapper.
- A separate Git credential helper still pointed at a compose chain containing `docker-compose.wsl.yml`.
- `docker-compose.wsl.yml` introduces Docker-managed volumes (`openclaw_state`, `openclaw_gh_config`) that are not the same persistence model as the canonical bind-mounted `var/config/` + `var/workspace/`.
- That mismatch is sufficient to make OpenClaw appear “fresh”, lose auth surfaces, or read a different state snapshot.
- Legacy named volume forensics confirmed that Feishu-specific state existed under the old volume path (`credentials/feishu-default-allowFrom.json`, `feishu/dedup/default.json`) while current canonical config roots lacked `channels.feishu`.

## Current facts

- `agents.list` exists in `../config/openclaw.json`.
- `channels.feishu` was not present in the accessible canonical config roots during the first audit pass.
- Legacy named-volume forensics later confirmed the previously active Feishu config lived in the old Docker volume's `openclaw.json`, not in the canonical bind-mounted config root.
- `channels.feishu` has now been restored into the canonical config root from that legacy volume.
- `config/mcporter.json` exists.
- `../xiaohongshu-mcp/cookies.json` exists.
- Pairing files exist under `../config/devices/`.
- Host `gh` exists, but Git auth persistence must be anchored to `../config/gh/` and the canonical helper script.

## Required operating rules

- Start or recreate the runtime only through `../../scripts/start-local-runtime.sh`.
- Verify only through `../../scripts/verify-local-runtime.sh`.
- Update only through `../../scripts/update-local-runtime.sh`.
- Host Git credential flow must use `../../scripts/gh-git-credential.sh`.
- Manual OpenClaw CLI calls must use `../../scripts/openclaw-runtime-cli.sh`.
- Do not add `docker-compose.wsl.yml` to the steady-state runtime or helper chain for this machine.
- Before cleanup, rebuild, re-pair, or reconfigure channels, run `../../scripts/snapshot-state-to-d.sh` and `../../scripts/audit-local-integrations.sh`.

## What still needs intentional recovery

- Feishu channel config is recovered into the canonical config root, but end-to-end runtime verification should still be done from a real Feishu message.
- Legacy named volumes still exist and should remain quarantined until the user confirms the canonical runtime is stable.
