#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MESSAGE="${*:-assistant state snapshot $(date -u +"%Y-%m-%d %H:%M UTC")}"

"$REPO_DIR/sync-settings.sh"

git -C "$REPO_DIR" add -A
if git -C "$REPO_DIR" diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git -C "$REPO_DIR" commit -m "$MESSAGE"

echo "Created rollback point: $MESSAGE"
