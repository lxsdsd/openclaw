#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec "$HOME/bin/docker" compose -f docker-compose.yml -f docker-compose.wsl.yml logs -f openclaw-gateway
