#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/gaga/openclaw/var"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

restore_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  rsync -a --delete \
    --exclude ".git/" \
    --exclude ".openclaw/" \
    --exclude ".perm_test" \
    --exclude "assistant-state-backup/" \
    --exclude "node_modules/" \
    --exclude "*.log" \
    --exclude "*.db" \
    --exclude "*.sqlite" \
    "$REPO_DIR/$src/" "$dest/"
}

cp "$REPO_DIR/config/openclaw.json" "$ROOT/config/openclaw.json"
restore_tree "workspace" "$ROOT/workspace"
restore_tree "workspace-builder-a" "$ROOT/workspace-builder-a"
restore_tree "workspace-builder-b" "$ROOT/workspace-builder-b"
restore_tree "workspace-research" "$ROOT/workspace-research"
restore_tree "workspace-watchdog" "$ROOT/workspace-watchdog"

echo "Restored assistant settings from $REPO_DIR"
