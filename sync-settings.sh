#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/gaga/openclaw/var"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

copy_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$REPO_DIR/$dest"
  rsync -a --delete \
    --exclude ".git/" \
    --exclude ".openclaw/" \
    --exclude ".perm_test" \
    --exclude "assistant-state-backup/" \
    --exclude "node_modules/" \
    --exclude "*.log" \
    --exclude "*.db" \
    --exclude "*.sqlite" \
    "$src/" "$REPO_DIR/$dest/"
}

copy_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$REPO_DIR/$dest")"
  cp "$src" "$REPO_DIR/$dest"
}

copy_file "$ROOT/config/openclaw.json" "config/openclaw.json"
copy_tree "$ROOT/workspace" "workspace"
copy_tree "$ROOT/workspace-builder-a" "workspace-builder-a"
copy_tree "$ROOT/workspace-builder-b" "workspace-builder-b"
copy_tree "$ROOT/workspace-research" "workspace-research"
copy_tree "$ROOT/workspace-watchdog" "workspace-watchdog"

{
  echo "Last sync: $STAMP"
  echo
  find "$REPO_DIR/config" "$REPO_DIR/workspace" "$REPO_DIR/workspace-builder-a" "$REPO_DIR/workspace-builder-b" "$REPO_DIR/workspace-research" "$REPO_DIR/workspace-watchdog" -type f \
    | sed "s#^$REPO_DIR/##" \
    | sort
} > "$REPO_DIR/MANIFEST.txt"

echo "$STAMP" > "$REPO_DIR/LAST_SYNC.txt"
echo "Synced assistant settings into $REPO_DIR"
