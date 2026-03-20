#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

canonical_config="var/config/openclaw.json"
legacy_config="$HOME/.openclaw/openclaw.json"
backup_config="var/workspace/assistant-state-backup/config/openclaw.json"
recovery_config="var/backups/main-session-fix-20260318T093556Z/openclaw.json"

print_status() {
  local label="$1"
  local status="$2"
  printf '%-36s %s\n' "$label" "$status"
}

has_key() {
  local pattern="$1"
  local file="$2"
  rg -q "$pattern" "$file"
}

print_key_status() {
  local label="$1"
  local pattern="$2"
  local file="$3"
  if [[ ! -f "$file" ]]; then
    print_status "$label" "MISSING_FILE"
    return
  fi
  if has_key "$pattern" "$file"; then
    print_status "$label" "PRESENT"
  else
    print_status "$label" "MISSING"
  fi
}

json5_key_pattern() {
  local key="$1"
  printf '^[[:space:]]*"?%s"?[[:space:]]*:' "$key"
}

printf '[runtime roots]\n'
for file in "$canonical_config" "$legacy_config" "$backup_config" "$recovery_config"; do
  if [[ -f "$file" ]]; then
    print_status "$file" "PRESENT"
  else
    print_status "$file" "MISSING"
  fi
done

printf '\n[canonical config keys]\n'
print_key_status "agents.list" '^[[:space:]]*"?list"?[[:space:]]*:[[:space:]]*\[' "$canonical_config"
print_key_status "channels" "$(json5_key_pattern channels)[[:space:]]*\\{" "$canonical_config"
print_key_status "channels.feishu" "$(json5_key_pattern feishu)[[:space:]]*\\{" "$canonical_config"
print_key_status "tools" "$(json5_key_pattern tools)[[:space:]]*\\{" "$canonical_config"
print_key_status "models" "$(json5_key_pattern models)[[:space:]]*\\{" "$canonical_config"

printf '\n[legacy config comparison]\n'
print_key_status "~/.openclaw channels.feishu" "$(json5_key_pattern feishu)[[:space:]]*\\{" "$legacy_config"
print_key_status "backup channels.feishu" "$(json5_key_pattern feishu)[[:space:]]*\\{" "$backup_config"
print_key_status "recovery channels.feishu" "$(json5_key_pattern feishu)[[:space:]]*\\{" "$recovery_config"

printf '\n[persistent integration surfaces]\n'
for path in \
  "var/config/devices/paired.json" \
  "var/config/devices/pending.json" \
  "var/config/gh" \
  "var/workspace/config/mcporter.json" \
  "var/xiaohongshu-mcp/cookies.json" \
  "var/qmd-memory-service/docker-compose.yml"
do
  if [[ -e "$path" ]]; then
    print_status "$path" "PRESENT"
  else
    print_status "$path" "MISSING"
  fi
done

printf '\n[live runtime mirrors]\n'
if docker ps --format '{{.Names}}' 2>/dev/null | rg -qx 'openclaw-openclaw-gateway-1'; then
  if docker exec openclaw-openclaw-gateway-1 sh -lc 'test -f /app/config/mcporter.json'; then
    print_status "gateway /app/config/mcporter.json" "PRESENT"
  else
    print_status "gateway /app/config/mcporter.json" "MISSING"
  fi
  if docker exec openclaw-openclaw-gateway-1 sh -lc 'rg -q "\"xiaohongshu\"" /app/config/mcporter.json'; then
    print_status "gateway mcporter xiaohongshu" "PRESENT"
  else
    print_status "gateway mcporter xiaohongshu" "MISSING"
  fi
else
  print_status "gateway /app/config/mcporter.json" "GATEWAY_NOT_RUNNING"
  print_status "gateway mcporter xiaohongshu" "GATEWAY_NOT_RUNNING"
fi

printf '\n[legacy runtime drift]\n'
legacy_volume_names="$(docker volume ls --format '{{.Name}}' 2>/dev/null || true)"
if [[ "$legacy_volume_names" == *"openclaw_openclaw_state"* ]]; then
  print_status "legacy volume openclaw_openclaw_state" "PRESENT"
else
  print_status "legacy volume openclaw_openclaw_state" "MISSING"
fi
if [[ "$legacy_volume_names" == *"openclaw_openclaw_gh_config"* ]]; then
  print_status "legacy volume openclaw_openclaw_gh_config" "PRESENT"
else
  print_status "legacy volume openclaw_openclaw_gh_config" "MISSING"
fi

printf '\n[tooling]\n'
for bin in git gh openclaw; do
  if command -v "$bin" >/dev/null 2>&1; then
    print_status "$bin" "$(command -v "$bin")"
  else
    print_status "$bin" "MISSING"
  fi
done

printf '\n[git repo]\n'
print_status "branch" "$(git -C . rev-parse --abbrev-ref HEAD 2>/dev/null || echo UNKNOWN)"
print_status "remotes" "$(git -C . remote | paste -sd ',' - 2>/dev/null || echo NONE)"
print_status "local user.name" "$(git -C . config --local --get user.name 2>/dev/null || echo MISSING)"
print_status "local user.email" "$(git -C . config --local --get user.email 2>/dev/null || echo MISSING)"

helper="$(git config --global --get credential.helper 2>/dev/null || true)"
if [[ -z "$helper" ]]; then
  print_status "git credential.helper" "MISSING"
else
  print_status "git credential.helper" "SET"
  if [[ "$helper" == *"docker-compose.wsl.yml"* ]]; then
    print_status "helper runtime target" "WRONG_STACK_docker-compose.wsl.yml"
  elif [[ "$helper" == *"scripts/gh-git-credential.sh"* ]]; then
    print_status "helper runtime target" "CANONICAL_SCRIPT"
  else
    print_status "helper runtime target" "NONSTANDARD"
  fi
fi

printf '\n[expected compose policy]\n'
print_status "start runtime" "scripts/start-local-runtime.sh"
print_status "verify runtime" "scripts/verify-local-runtime.sh"
print_status "update runtime" "scripts/update-local-runtime.sh"
print_status "git helper" "scripts/gh-git-credential.sh"
