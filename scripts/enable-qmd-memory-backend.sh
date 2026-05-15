#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

qmd_main_state_root="${OPENCLAW_QMD_MAIN_DIR:-/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd}"
config_path="/home/gaga/openclaw/var/config/openclaw.json"
tmp_root="/mnt/d/OpenClaw/tmp"
tmp_file=""

mkdir -p "$qmd_main_state_root"
mkdir -p "$tmp_root"
tmp_file="$(mktemp "$tmp_root/openclaw-qmd-config.XXXXXX.json")"
trap 'rm -f "$tmp_file"' EXIT

python3 - "$config_path" "$tmp_file" <<'PY'
import json
import sys

config_path, tmp_file = sys.argv[1], sys.argv[2]

with open(config_path, "r", encoding="utf-8") as handle:
    config = json.load(handle)

config["memory"] = {
    "backend": "qmd",
    "citations": "auto",
    "qmd": {
        "command": "/home/gaga/.local/bin/qmd",
        "searchMode": "search",
        "includeDefaultMemory": True,
        "sessions": {
            "enabled": True,
            "retentionDays": 14,
        },
        "update": {
            "interval": "5m",
            "debounceMs": 15000,
            "onBoot": True,
            "waitForBootSync": False,
            "embedInterval": "60m",
        },
        "limits": {
            "maxResults": 6,
            "maxSnippetChars": 700,
            "maxInjectedChars": 4000,
            "timeoutMs": 4000,
        },
    },
}

with open(tmp_file, "w", encoding="utf-8") as handle:
    json.dump(config, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

mv "$tmp_file" "$config_path"

printf 'QMD backend configured for main agent.\n'
printf 'QMD state root: %s\n' "$qmd_main_state_root"
printf 'Config path: %s\n' "$config_path"
