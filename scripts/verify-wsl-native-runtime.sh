#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

script_dir="$(pwd)/scripts"
profile="${OPENCLAW_NATIVE_PROFILE:-native-main}"
state_dir="${OPENCLAW_NATIVE_STATE_DIR:-$HOME/.openclaw-native-main}"
config_path="${OPENCLAW_NATIVE_CONFIG_PATH:-$state_dir/openclaw.json}"
workspace_dir="$state_dir/workspace"
mcporter_path="$workspace_dir/config/mcporter.json"
cookies_path="$(pwd)/var/xiaohongshu-mcp/cookies.json"
qmd_service_root="$(pwd)/var/qmd-memory-service"
failures=0
warnings=0

pass() {
  printf 'PASS %s\n' "$1"
}

fail() {
  printf 'FAIL %s\n' "$1"
  failures=$((failures + 1))
}

warn() {
  printf 'WARN %s\n' "$1"
  warnings=$((warnings + 1))
}

expect_equals() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected: $expected, actual: $actual)"
  fi
}

port_open() {
  local port="$1"
  python3 - "$port" <<'PY'
import socket
import sys

port = int(sys.argv[1])
s = socket.socket()
s.settimeout(2)
try:
    s.connect(("127.0.0.1", port))
except OSError:
    raise SystemExit(1)
finally:
    s.close()
PY
}

if [[ -L "$state_dir" ]]; then
  fail "native state dir is still a symlink ($(readlink "$state_dir"))"
else
  pass "native state dir is isolated"
fi

if [[ -f "$config_path" ]]; then
  pass "native config exists"
else
  fail "native config exists"
fi

if "$script_dir/openclaw-native-cli.sh" config validate --json >/dev/null; then
  pass "config validate"
else
  fail "config validate"
fi

bind_mode="$("$script_dir/openclaw-native-cli.sh" config get gateway.bind --json | python3 -c 'import json,sys; print(json.load(sys.stdin))')"
gateway_port="$("$script_dir/openclaw-native-cli.sh" config get gateway.port --json | python3 -c 'import json,sys; print(json.load(sys.stdin))')"
workspace_path="$("$script_dir/openclaw-native-cli.sh" config get agents.defaults.workspace --json | python3 -c 'import json,sys; print(json.load(sys.stdin))')"
qmd_command="$("$script_dir/openclaw-native-cli.sh" config get memory.qmd.command --json | python3 -c 'import json,sys; print(json.load(sys.stdin))')"

expect_equals "gateway bind" "$bind_mode" "loopback"
expect_equals "gateway port" "$gateway_port" "19089"
expect_equals "agents.defaults.workspace" "$workspace_path" "$workspace_dir"
expect_equals "memory.qmd.command" "$qmd_command" "$HOME/.local/bin/qmd"

if [[ -f "$mcporter_path" ]]; then
  pass "native mcporter config exists"
  xiaohongshu_url="$(python3 - "$mcporter_path" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)
print(data.get("mcpServers", {}).get("xiaohongshu", {}).get("baseUrl", ""))
PY
)"
  expect_equals "xiaohongshu MCP baseUrl" "$xiaohongshu_url" "http://127.0.0.1:18060/mcp"

  while IFS=: read -r name command_name; do
    [[ -n "$name" ]] || continue
    if command -v "$command_name" >/dev/null 2>&1; then
      pass "configured MCP command present: $name"
    else
      fail "configured MCP command missing: $name -> $command_name"
    fi
  done < <(python3 - "$mcporter_path" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)
for name, spec in data.get("mcpServers", {}).items():
    command_name = spec.get("command")
    if command_name:
        print(f"{name}:{command_name}")
PY
)
else
  fail "native mcporter config exists"
fi

if command -v qmd >/dev/null 2>&1; then
  pass "qmd binary present"
else
  fail "qmd binary present"
fi

memory_output="$(mktemp)"
trap 'rm -f "$memory_output"' EXIT
if "$script_dir/openclaw-native-cli.sh" memory status --agent main --json >"$memory_output" 2>&1; then
  if rg -q '"backend": "qmd"' "$memory_output" && rg -q '"available": true' "$memory_output"; then
    pass "memory backend qmd available"
  else
    fail "memory backend qmd available"
  fi
else
  fail "memory backend qmd available"
fi

if [[ -f "$cookies_path" ]]; then
  pass "xiaohongshu cookies file present"
else
  fail "xiaohongshu cookies file present"
fi

if port_open 19089; then
  pass "gateway port 19089 listening"
else
  fail "gateway port 19089 listening"
fi

if "$script_dir/openclaw-native-cli.sh" health --json >/dev/null 2>&1; then
  pass "gateway health RPC"
else
  fail "gateway health RPC"
fi

if port_open 18060; then
  pass "xiaohongshu MCP port 18060 listening"
else
  fail "xiaohongshu MCP port 18060 listening"
fi

if port_open 19091; then
  pass "browser control port 19091 listening"
else
  warn "browser control port 19091 not listening"
fi

if [[ -f "$qmd_service_root/docker-compose.yml" ]]; then
  if port_open 16333; then
    pass "qmd sidecar port 16333 listening"
  else
    warn "qmd sidecar port 16333 not listening"
  fi
fi

printf '\n'
if [[ "$failures" -eq 0 ]]; then
  printf 'Native runtime verification passed'
  if [[ "$warnings" -gt 0 ]]; then
    printf ' with %s warning(s)' "$warnings"
  fi
  printf '.\n'
else
  printf 'Native runtime verification failed: %s failure(s)' "$failures"
  if [[ "$warnings" -gt 0 ]]; then
    printf ', %s warning(s)' "$warnings"
  fi
  printf '.\n'
  exit 1
fi
