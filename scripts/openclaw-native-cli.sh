#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

profile="${OPENCLAW_NATIVE_PROFILE:-native-main}"
state_dir="${OPENCLAW_NATIVE_STATE_DIR:-$HOME/.openclaw-native-main}"
config_path="${OPENCLAW_NATIVE_CONFIG_PATH:-$state_dir/openclaw.json}"
gateway_port="${OPENCLAW_NATIVE_GATEWAY_PORT:-19089}"

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"
export OPENCLAW_PROFILE="$profile"
export OPENCLAW_STATE_DIR="$state_dir"
export OPENCLAW_CONFIG_PATH="$config_path"
export OPENCLAW_GATEWAY_PORT="$gateway_port"

exec openclaw --profile "$profile" "$@"
