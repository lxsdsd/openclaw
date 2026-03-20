#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

dest_root="${1:-/mnt/d/OpenClaw/state-bundles/openclaw/current/git-repos}"
mkdir -p "$dest_root"

mapfile -t repos < <(
  find . -type d -name .git -prune -print |
    while read -r path; do
      repo="${path#./}"
      repo="${repo%/.git}"
      if [[ "$repo" == ".git" ]]; then
        repo="."
      fi
      printf '%s\n' "$repo"
    done | sort -u
)

for repo in "${repos[@]}"; do
  if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    continue
  fi

  safe_name="$(printf '%s' "$repo" | tr '/ ' '__')"
  [[ "$safe_name" == "." ]] && safe_name="repo-root"
  repo_dest="$dest_root/$safe_name"
  mkdir -p "$repo_dest"

  git -C "$repo" rev-parse HEAD > "$repo_dest/HEAD.txt" 2>/dev/null || true
  git -C "$repo" branch --show-current > "$repo_dest/BRANCH.txt" 2>/dev/null || true
  git -C "$repo" status --short > "$repo_dest/STATUS.txt" 2>/dev/null || true
  git -C "$repo" remote > "$repo_dest/REMOTES.txt" 2>/dev/null || true

  if git -C "$repo" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$repo" bundle create "$repo_dest/repo.bundle" --all >/dev/null 2>&1 || true
    git -C "$repo" diff --binary HEAD > "$repo_dest/WORKTREE.diff" 2>/dev/null || true
  fi

  if git -C "$repo" ls-files --others --exclude-standard --directory -z | grep -qz .; then
    tmp_list="$(mktemp)"
    git -C "$repo" ls-files --others --exclude-standard --directory -z > "$tmp_list"
    tar -C "$repo" --null -T "$tmp_list" -czf "$repo_dest/UNTRACKED.tgz"
    rm -f "$tmp_list"
  fi
done

printf 'Git repo capture root: %s\n' "$dest_root"
