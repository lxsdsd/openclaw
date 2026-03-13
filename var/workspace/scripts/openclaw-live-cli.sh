#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$repo_root"

compose_args=(-f docker-compose.yml -f docker-compose.wsl.yml)
container_id="$($HOME/bin/docker compose "${compose_args[@]}" ps -q openclaw-gateway)"

if [ -z "$container_id" ]; then
  echo "openclaw-gateway is not running; start it with scripts/openclaw-wsl-up.sh" >&2
  exit 1
fi

exec docker exec "$container_id" openclaw "$@"
