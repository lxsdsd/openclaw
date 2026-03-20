#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

src_root="${1:-/mnt/d/OpenClaw/state-bundles/openclaw/current}"

if [[ ! -d "$src_root/config" || ! -d "$src_root/workspace" ]]; then
  echo "Missing bundle directories under: $src_root" >&2
  exit 1
fi

mkdir -p var/config var/workspace

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$src_root/config"/ var/config/
  rsync -a --delete "$src_root/workspace"/ var/workspace/
  if [[ -d "$src_root/xiaohongshu-mcp" ]]; then
    mkdir -p var/xiaohongshu-mcp
    rsync -a --delete "$src_root/xiaohongshu-mcp"/ var/xiaohongshu-mcp/
  fi
  if [[ -d "$src_root/qmd-memory-service" ]]; then
    mkdir -p var/qmd-memory-service
    rsync -a --delete "$src_root/qmd-memory-service"/ var/qmd-memory-service/
  fi
else
  rm -rf var/config var/workspace
  mkdir -p var/config var/workspace
  cp -a "$src_root/config"/. var/config/
  cp -a "$src_root/workspace"/. var/workspace/
  if [[ -d "$src_root/xiaohongshu-mcp" ]]; then
    rm -rf var/xiaohongshu-mcp
    mkdir -p var/xiaohongshu-mcp
    cp -a "$src_root/xiaohongshu-mcp"/. var/xiaohongshu-mcp/
  fi
  if [[ -d "$src_root/qmd-memory-service" ]]; then
    rm -rf var/qmd-memory-service
    mkdir -p var/qmd-memory-service
    cp -a "$src_root/qmd-memory-service"/. var/qmd-memory-service/
  fi
fi

printf 'State restored from: %s\n' "$src_root"
