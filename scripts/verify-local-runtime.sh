#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

compose_files=(-f docker-compose.yml -f docker-compose.agent-reach.yml)
if [[ -n "${DOCKER_BIN:-}" ]]; then
  docker_bin="$DOCKER_BIN"
elif [[ -x /usr/bin/docker ]]; then
  docker_bin=/usr/bin/docker
elif [[ -x "$HOME/bin/docker" ]]; then
  docker_bin="$HOME/bin/docker"
else
  docker_bin="$(command -v docker)"
fi
service="openclaw-gateway"
container="openclaw-openclaw-gateway-1"
health_wait_seconds=120
qmd_main_state_root="${OPENCLAW_QMD_MAIN_DIR:-/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd}"

failures=0

check() {
  local label="$1"
  shift
  if "$@"; then
    printf 'PASS %s\n' "$label"
  else
    printf 'FAIL %s\n' "$label"
    failures=$((failures + 1))
  fi
}

check_output_contains() {
  local label="$1"
  local needle="$2"
  shift 2
  local output
  output="$("$@" 2>/dev/null || true)"
  if printf '%s' "$output" | rg -Fq "$needle"; then
    printf 'PASS %s\n' "$label"
  else
    printf 'FAIL %s\n' "$label"
    failures=$((failures + 1))
  fi
}

check_output_contains "container exists" "$container" \
  "$docker_bin" ps -a --format '{{.Names}}'
check_output_contains "compose override loaded" "docker-compose.agent-reach.yml" \
  "$docker_bin" inspect "$container" --format '{{ index .Config.Labels "com.docker.compose.project.config_files" }}'
check_output_contains "custom image active" "openclaw-agent-reach:local" \
  "$docker_bin" inspect "$container" --format '{{ .Config.Image }}'
check_output_contains "workspace mount active" "/home/node/.openclaw/workspace  <-  /home/gaga/openclaw/var/workspace" \
  "$docker_bin" inspect "$container" --format '{{range .Mounts}}{{println .Destination " <- " .Source}}{{end}}'
check_output_contains "config mount active" "/home/node/.openclaw  <-  /home/gaga/openclaw/var/config" \
  "$docker_bin" inspect "$container" --format '{{range .Mounts}}{{println .Destination " <- " .Source}}{{end}}'
check_output_contains "gh config mount active" "/home/node/.config/gh  <-  /home/gaga/openclaw/var/config/gh" \
  "$docker_bin" inspect "$container" --format '{{range .Mounts}}{{println .Destination " <- " .Source}}{{end}}'
check_output_contains "mcporter config mount active" "/app/config/mcporter.json  <-  /home/gaga/openclaw/var/workspace/config/mcporter.json" \
  "$docker_bin" inspect "$container" --format '{{range .Mounts}}{{println .Destination " <- " .Source}}{{end}}'
check_output_contains "qmd main state mount active" "/home/node/.openclaw/agents/main/qmd  <-  ${qmd_main_state_root}" \
  "$docker_bin" inspect "$container" --format '{{range .Mounts}}{{println .Destination " <- " .Source}}{{end}}'
check_output_contains "container healthy" "healthy" \
  bash -lc '
    deadline=$((SECONDS + '"$health_wait_seconds"'))
    while (( SECONDS < deadline )); do
      status=$("'"$docker_bin"'" inspect "'"$container"'" --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}" 2>/dev/null || true)
      if [[ "$status" == "healthy" ]]; then
        echo healthy
        exit 0
      fi
      sleep 2
    done
    "'"$docker_bin"'" inspect "'"$container"'" --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}" 2>/dev/null || true
    exit 1
  '
check "health endpoint live" python3 - <<'PY'
import time
import urllib.request
deadline = time.time() + 60
while time.time() < deadline:
    try:
        with urllib.request.urlopen("http://127.0.0.1:18789/healthz", timeout=5) as r:
            raise SystemExit(0 if r.status == 200 else 1)
    except Exception:
        time.sleep(2)
raise SystemExit(1)
PY
check "workspace marker exists" "$docker_bin" exec "$container" sh -lc 'test -f /home/node/.openclaw/workspace/TEAM_ROLES.md'
check "config dir writable" "$docker_bin" exec "$container" sh -lc 'test -w /home/node/.openclaw'
check "config file present" "$docker_bin" exec "$container" sh -lc 'test -f /home/node/.openclaw/openclaw.json'
check "runtime agents present" "$docker_bin" exec "$container" sh -lc 'test -d /home/node/.openclaw/agents'
check "device state present" "$docker_bin" exec "$container" sh -lc 'test -d /home/node/.openclaw/devices'
check "devices dir writable" "$docker_bin" exec "$container" sh -lc 'mkdir -p /home/node/.openclaw/devices && test -w /home/node/.openclaw/devices'
check "gh config dir writable" "$docker_bin" exec "$container" sh -lc 'mkdir -p /home/node/.config/gh && test -w /home/node/.config/gh'
check "mcporter live config present" "$docker_bin" exec "$container" sh -lc 'test -f /app/config/mcporter.json'
check "qmd state dir writable" "$docker_bin" exec "$container" sh -lc 'mkdir -p /home/node/.openclaw/agents/main/qmd && test -w /home/node/.openclaw/agents/main/qmd'
check "qmd binary available" "$docker_bin" exec "$container" sh -lc 'command -v qmd >/dev/null 2>&1'
check_output_contains "xiaohongshu container exists" "xiaohongshu-mcp" \
  "$docker_bin" ps -a --format '{{.Names}}'
check_output_contains "xiaohongshu running" "xiaohongshu-mcp Up" \
  "$docker_bin" ps --format '{{.Names}} {{.Status}}'

printf '\n'
if [[ "$failures" -eq 0 ]]; then
  printf 'Runtime verification passed.\n'
else
  printf 'Runtime verification failed: %s check(s).\n' "$failures"
  exit 1
fi
