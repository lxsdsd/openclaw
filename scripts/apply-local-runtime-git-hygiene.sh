#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDE_FILE="$ROOT_DIR/.git/info/exclude"
BEGIN_MARKER="# openclaw local runtime hygiene"
END_MARKER="# end openclaw local runtime hygiene"

cd "$ROOT_DIR"

mkdir -p "$(dirname "$EXCLUDE_FILE")"
touch "$EXCLUDE_FILE"

tmp_file="$(mktemp)"
awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
  $0 == begin { skip = 1; next }
  $0 == end { skip = 0; next }
  !skip { print }
' "$EXCLUDE_FILE" > "$tmp_file"
mv "$tmp_file" "$EXCLUDE_FILE"

cat >> "$EXCLUDE_FILE" <<EOF
$BEGIN_MARKER
/var/backups/
/var/config/
/var/qmd-memory-service/
/var/xiaohongshu-mcp/
/var/workspace/**
/var/workspace-builder-a/
/var/workspace-builder-b/
/var/workspace-research/
/var/workspace-watchdog/
$END_MARKER
EOF

git ls-files -z var/workspace | xargs -0r git update-index --skip-worktree --

echo "Applied local runtime git hygiene."
git status --short
