#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

legacy_volume="${1:-openclaw_openclaw_state}"
forensics_root="${2:-/mnt/d/OpenClaw/forensics/openclaw_state_volume}"
temp_container="openclaw-state-inspect"

cleanup() {
  /usr/bin/docker rm -f "$temp_container" >/dev/null 2>&1 || true
}

trap cleanup EXIT

mkdir -p "$forensics_root"

if ! /usr/bin/docker volume inspect "$legacy_volume" >/dev/null 2>&1; then
  echo "Missing legacy volume: $legacy_volume" >&2
  exit 1
fi

/usr/bin/docker rm -f "$temp_container" >/dev/null 2>&1 || true
/usr/bin/docker create -v "$legacy_volume":/state --name "$temp_container" alpine true >/dev/null
/usr/bin/docker cp "$temp_container":/state/. "$forensics_root"/

mkdir -p var/config/credentials var/config/feishu

if [[ -f "$forensics_root/credentials/feishu-default-allowFrom.json" ]]; then
  cp -f "$forensics_root/credentials/feishu-default-allowFrom.json" var/config/credentials/
  echo "RESTORED var/config/credentials/feishu-default-allowFrom.json"
fi

if [[ -d "$forensics_root/feishu" ]]; then
  rm -rf var/config/feishu
  mkdir -p var/config/feishu
  cp -a "$forensics_root/feishu"/. var/config/feishu/
  echo "RESTORED var/config/feishu/"
fi

if [[ -f "$forensics_root/openclaw.json" ]]; then
  echo "FORENSICS $forensics_root/openclaw.json"
fi

echo "DONE legacy volume inspection and safe-state migration"
