#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

state_root=/home/gaga/openclaw/var/config
qmd_main_state_root="${OPENCLAW_QMD_MAIN_DIR:-/mnt/d/OpenClaw/qmd-memory/openclaw-main-qmd}"

if [[ -n "${DOCKER_BIN:-}" ]]; then
  docker_bin="$DOCKER_BIN"
elif [[ -x /usr/bin/docker ]]; then
  docker_bin=/usr/bin/docker
elif [[ -x "$HOME/bin/docker" ]]; then
  docker_bin="$HOME/bin/docker"
else
  docker_bin="$(command -v docker)"
fi

mkdir -p "$state_root"
mkdir -p "$qmd_main_state_root"
mkdir -p /home/gaga/openclaw/var/workspace/config
if [[ ! -f "$state_root/openclaw.json" && -f /home/gaga/.openclaw/openclaw.json ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a /home/gaga/.openclaw/ "$state_root"/
  else
    cp -a /home/gaga/.openclaw/. "$state_root"/
  fi
fi

mkdir -p "$state_root/devices" "$state_root/credentials" "$state_root/logs" "$state_root/gh"
if [[ ! -f /home/gaga/openclaw/var/workspace/config/mcporter.json ]]; then
  cat > /home/gaga/openclaw/var/workspace/config/mcporter.json <<'EOF'
{
  "mcpServers": {
    "xiaohongshu": {
      "baseUrl": "http://xiaohongshu-mcp:18060/mcp"
    },
    "exa": {
      "baseUrl": "https://mcp.exa.ai/mcp"
    },
    "weibo": {
      "command": "mcp-server-weibo"
    }
  },
  "imports": []
}
EOF
fi

export OPENCLAW_CONFIG_DIR="$state_root"
export OPENCLAW_WORKSPACE_DIR=/home/gaga/openclaw/var/workspace

if [[ "${1:-}" == "--print-config" ]]; then
  exec "$docker_bin" compose \
    -f docker-compose.yml \
    -f docker-compose.agent-reach.yml \
    config
fi

"$docker_bin" compose \
  -f docker-compose.yml \
  -f docker-compose.agent-reach.yml \
  up -d --force-recreate openclaw-gateway openclaw-cli xiaohongshu-mcp
