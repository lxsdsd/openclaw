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
do_snapshot=1
do_verify=1
do_pull=1

usage() {
  cat <<'EOF'
Usage: ./scripts/update-local-runtime.sh [options]

Options:
  --no-snapshot  Skip D-drive snapshot before update
  --no-verify    Skip post-update verification
  --no-pull      Skip docker build --pull
  -h, --help     Show this help

This is the canonical host-side update path for the local Docker runtime.
It preserves mounted state in var/config and var/workspace.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-snapshot)
      do_snapshot=0
      ;;
    --no-verify)
      do_verify=0
      ;;
    --no-pull)
      do_pull=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$do_snapshot" -eq 1 ]]; then
  ./scripts/snapshot-state-to-d.sh
fi

build_args=()
if [[ "$do_pull" -eq 1 ]]; then
  build_args+=(--pull)
fi

"$docker_bin" compose \
  -f docker-compose.yml \
  -f docker-compose.agent-reach.yml \
  build "${build_args[@]}" openclaw-gateway openclaw-cli

./scripts/start-local-runtime.sh

if [[ "$do_verify" -eq 1 ]]; then
  ./scripts/verify-local-runtime.sh
fi

printf 'Local runtime update completed.\n'
