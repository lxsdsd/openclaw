#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

script_dir="$(pwd)/scripts"
profile="${OPENCLAW_NATIVE_PROFILE:-native-main}"
state_dir="${OPENCLAW_NATIVE_STATE_DIR:-$HOME/.openclaw-native-main}"
config_path="${OPENCLAW_NATIVE_CONFIG_PATH:-$state_dir/openclaw.json}"
gateway_port="${OPENCLAW_NATIVE_GATEWAY_PORT:-19089}"
unit_name="${OPENCLAW_NATIVE_SYSTEMD_UNIT:-openclaw-gateway-${profile}.service}"
unit_path="$HOME/.config/systemd/user/$unit_name"
run_dir="$state_dir/run"
log_dir="$state_dir/logs"
pid_file="$run_dir/openclaw-gateway-${profile}.pid"
log_file="$log_dir/openclaw-gateway-${profile}.log"

if [[ ! -f "$config_path" || -L "$state_dir" ]]; then
  "$script_dir/prepare-wsl-native-profile.sh"
fi

mkdir -p "$run_dir" "$log_dir"

if systemctl --user show-environment >/dev/null 2>&1; then
  if [[ ! -f "$unit_path" ]]; then
    "$script_dir/openclaw-native-cli.sh" gateway install
  fi
  systemctl --user daemon-reload
  systemctl --user restart "$unit_name"
  systemctl --user --no-pager --full status "$unit_name" || true
  exit 0
fi

if [[ -f "$pid_file" ]]; then
  existing_pid="$(cat "$pid_file" 2>/dev/null || true)"
  if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
    printf 'Native gateway already running under pid %s\n' "$existing_pid"
    exit 0
  fi
fi

nohup "$script_dir/openclaw-native-cli.sh" gateway run \
  --port "$gateway_port" \
  --bind loopback \
  --tailscale off \
  >"$log_file" 2>&1 &

pid="$!"
printf '%s\n' "$pid" >"$pid_file"
sleep 3

if ! kill -0 "$pid" 2>/dev/null; then
  printf 'Native gateway failed to stay up. Recent log output:\n' >&2
  tail -n 80 "$log_file" >&2 || true
  exit 1
fi

printf 'Native gateway started in fallback mode.\n'
printf 'Profile: %s\n' "$profile"
printf 'PID: %s\n' "$pid"
printf 'Log file: %s\n' "$log_file"
