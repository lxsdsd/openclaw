#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

source_state="${OPENCLAW_SOURCE_STATE_DIR:-$HOME/.openclaw}"
native_state="${OPENCLAW_NATIVE_STATE_DIR:-$HOME/.openclaw-native-main}"
profile="${OPENCLAW_NATIVE_PROFILE:-native-main}"
gateway_port="${OPENCLAW_NATIVE_GATEWAY_PORT:-19089}"
qmd_bin="${OPENCLAW_NATIVE_QMD_BIN:-$HOME/.local/bin/qmd}"
timestamp="$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$source_state" ]]; then
  printf 'Source state dir missing: %s\n' "$source_state" >&2
  exit 1
fi

if [[ "$source_state" == "$native_state" ]]; then
  printf 'Source and native state dirs must differ: %s\n' "$source_state" >&2
  exit 1
fi

if [[ -L "$native_state" ]]; then
  backup_root="${OPENCLAW_NATIVE_BACKUP_ROOT:-$HOME/.openclaw-native-main-backups}"
else
  backup_root="${OPENCLAW_NATIVE_BACKUP_ROOT:-$native_state/.migration-backups}"
fi
backup_dir="$backup_root/$timestamp"

copy_tree() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete \
      --exclude '.env' \
      --exclude '.migration-backups' \
      "$src"/ "$dst"/
  else
    rm -rf "$dst"
    mkdir -p "$dst"
    cp -a "$src"/. "$dst"/
    rm -f "$dst/.env"
    rm -rf "$dst/.migration-backups"
  fi
}

backup_existing_state() {
  mkdir -p "$backup_dir"
  if [[ -L "$native_state" ]]; then
    mv "$native_state" "$backup_dir/native-main.symlink"
    return
  fi
  if [[ -d "$native_state" ]]; then
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$native_state"/ "$backup_dir"/
    else
      cp -a "$native_state"/. "$backup_dir"/
    fi
  fi
}

backup_existing_state
mkdir -p "$native_state"
copy_tree "$source_state" "$native_state"

config_path="$native_state/openclaw.json"
workspace_mcporter="$native_state/workspace/config/mcporter.json"

python3 - "$source_state" "$native_state" "$config_path" "$workspace_mcporter" "$qmd_bin" "$gateway_port" <<'PY'
import json
import os
import pathlib
import sys

source_state, native_state, config_path, mcporter_path, qmd_bin, gateway_port = sys.argv[1:]
native_workspace = os.path.join(native_state, "workspace")


def rewrite_value(value):
    if isinstance(value, dict):
        return {k: rewrite_value(v) for k, v in value.items()}
    if isinstance(value, list):
        return [rewrite_value(v) for v in value]
    if isinstance(value, str):
        updated = value.replace("/home/node/.openclaw", native_state)
        updated = updated.replace(source_state, native_state)
        if updated == "/usr/local/bin/qmd":
            return qmd_bin
        return updated
    return value


with open(config_path, "r", encoding="utf-8") as handle:
    config = json.load(handle)

config = rewrite_value(config)

gateway = config.setdefault("gateway", {})
gateway["bind"] = "loopback"
gateway["port"] = int(gateway_port)
gateway.setdefault("controlUi", {})
gateway["controlUi"]["enabled"] = True
origins = gateway["controlUi"].get("allowedOrigins") or []
required_origins = [
    f"http://127.0.0.1:{gateway_port}",
    f"http://localhost:{gateway_port}",
]
gateway["controlUi"]["allowedOrigins"] = required_origins + [
    item for item in origins if item not in required_origins
]
gateway.setdefault("tailscale", {})
gateway["tailscale"]["mode"] = "off"
gateway.setdefault("remote", {})
gateway["remote"]["url"] = f"ws://127.0.0.1:{gateway_port}"

agents = config.setdefault("agents", {})
defaults = agents.setdefault("defaults", {})
defaults["workspace"] = native_workspace

memory = config.setdefault("memory", {})
memory["backend"] = "qmd"
memory.setdefault("qmd", {})
memory["qmd"]["command"] = qmd_bin

with open(config_path, "w", encoding="utf-8") as handle:
    json.dump(config, handle, ensure_ascii=False, indent=2)
    handle.write("\n")

mcporter_file = pathlib.Path(mcporter_path)
mcporter_file.parent.mkdir(parents=True, exist_ok=True)
if mcporter_file.exists():
    with open(mcporter_file, "r", encoding="utf-8") as handle:
        mcporter = json.load(handle)
else:
    mcporter = {"mcpServers": {}, "imports": []}

mcp_servers = mcporter.setdefault("mcpServers", {})
xiaohongshu = mcp_servers.setdefault("xiaohongshu", {})
xiaohongshu["baseUrl"] = "http://127.0.0.1:18060/mcp"

with open(mcporter_file, "w", encoding="utf-8") as handle:
    json.dump(mcporter, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

printf 'Prepared native profile: %s\n' "$profile"
printf 'Source state dir: %s\n' "$source_state"
printf 'Native state dir: %s\n' "$native_state"
printf 'Backup dir: %s\n' "$backup_dir"
printf 'Config path: %s\n' "$config_path"
