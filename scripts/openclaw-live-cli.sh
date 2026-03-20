#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$repo_root"

compose_args=(-f docker-compose.yml -f docker-compose.wsl.yml)

# Prefer the WSL-native Docker CLI so the running container sees the same local files.
if [ -x "/usr/bin/docker" ]; then
  docker_bin="/usr/bin/docker"
elif [ -x "$HOME/bin/docker" ]; then
  docker_bin="$HOME/bin/docker"
elif [ -x "/home/gaga/bin/docker" ]; then
  docker_bin="/home/gaga/bin/docker"
elif command -v docker >/dev/null 2>&1; then
  docker_bin="$(command -v docker)"
else
  echo "docker is not available in this runtime" >&2
  exit 1
fi

container_id="$($docker_bin compose "${compose_args[@]}" ps -q openclaw-gateway)"

if [ -z "$container_id" ]; then
  echo "openclaw-gateway is not running; start it with scripts/openclaw-wsl-up.sh" >&2
  exit 1
fi

exec "$docker_bin" exec "$container_id" openclaw "$@"
