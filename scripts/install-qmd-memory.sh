#!/usr/bin/env bash
set -euo pipefail

service_root="${1:-/home/gaga/openclaw/var/qmd-memory-service}"
data_root="${2:-/mnt/d/OpenClaw/qmd-memory}"

if [[ -n "${DOCKER_BIN:-}" ]]; then
  docker_bin="$DOCKER_BIN"
elif [[ -x /usr/bin/docker ]]; then
  docker_bin=/usr/bin/docker
elif [[ -x "$HOME/bin/docker" ]]; then
  docker_bin="$HOME/bin/docker"
else
  docker_bin="$(command -v docker)"
fi

mkdir -p "$service_root" "$data_root/qdrant_storage"
touch "$service_root/.env"

cat > "$service_root/docker-compose.yml" <<EOF
services:
  qmd-qdrant:
    image: qdrant/qdrant:latest
    container_name: qmd-qdrant
    restart: unless-stopped
    ports:
      - "127.0.0.1:16333:6333"
      - "127.0.0.1:16334:6334"
    volumes:
      - $data_root/qdrant_storage:/qdrant/storage
EOF

cat > "$service_root/README.md" <<'EOF'
# QMD Memory Service

- Engine: Qdrant
- HTTP: `http://127.0.0.1:16333`
- gRPC: `127.0.0.1:16334`
- Persistent data: `/mnt/d/OpenClaw/qmd-memory/qdrant_storage`

This service is bound to loopback only and is intended to act as a durable
memory/vector backend for local tooling and future OpenClaw memory integration.
EOF

"$docker_bin" compose --project-directory "$service_root" -f "$service_root/docker-compose.yml" up -d

printf 'QMD service root: %s\n' "$service_root"
printf 'QMD data root: %s\n' "$data_root"
