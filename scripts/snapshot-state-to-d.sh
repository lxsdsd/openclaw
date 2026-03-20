#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

dest_root="${1:-/mnt/d/OpenClaw/state-bundles/openclaw}"
timestamp="$(date +%Y-%m-%dT%H-%M-%S%z)"
snapshot_dir="$dest_root/snapshots/$timestamp"
current_dir="$dest_root/current"

mkdir -p "$snapshot_dir"

copy_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude '.git/' \
      --exclude 'node_modules/' \
      --exclude '.venvs/' \
      "$src" "$dest"
  else
    cp -a "$src" "$dest"
  fi
}

copy_tree var/config/ "$snapshot_dir/config/"
copy_tree var/workspace/ "$snapshot_dir/workspace/"
if [[ -d var/xiaohongshu-mcp ]]; then
  copy_tree var/xiaohongshu-mcp/ "$snapshot_dir/xiaohongshu-mcp/"
fi
if [[ -d var/qmd-memory-service ]]; then
  copy_tree var/qmd-memory-service/ "$snapshot_dir/qmd-memory-service/"
fi

mkdir -p "$snapshot_dir/meta"
cp -a docker-compose.yml docker-compose.agent-reach.yml Dockerfile.agent-reach LOCAL_SETUP.md "$snapshot_dir/meta/"
cp -a scripts/start-local-runtime.sh scripts/verify-local-runtime.sh "$snapshot_dir/meta/"

cat > "$snapshot_dir/MANIFEST.txt" <<EOF
created_at=$timestamp
repo_root=/home/gaga/openclaw
config_dir=var/config
workspace_dir=var/workspace
xiaohongshu_dir=var/xiaohongshu-mcp
qmd_service_dir=var/qmd-memory-service
startup_script=scripts/start-local-runtime.sh
verify_script=scripts/verify-local-runtime.sh
EOF

"$(dirname "$0")/capture-git-repos-to-d.sh" "$snapshot_dir/git-repos" >/dev/null 2>&1 || true

rm -rf "$current_dir"
mkdir -p "$current_dir"
copy_tree "$snapshot_dir"/ "$current_dir"/

printf 'Snapshot created: %s\n' "$snapshot_dir"
printf 'Current bundle: %s\n' "$current_dir"
