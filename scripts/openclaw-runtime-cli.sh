#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -n "${DOCKER_BIN:-}" ]]; then
  docker_bin="$DOCKER_BIN"
elif [[ -x /usr/bin/docker ]]; then
  docker_bin=/usr/bin/docker
elif [[ -x "$HOME/bin/docker" ]]; then
  docker_bin="$HOME/bin/docker"
else
  docker_bin="$(command -v docker)"
fi

exec "$docker_bin" compose \
  -f docker-compose.yml \
  -f docker-compose.agent-reach.yml \
  exec openclaw-gateway \
  openclaw "$@"
