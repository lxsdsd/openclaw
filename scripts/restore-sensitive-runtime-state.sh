#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_BASE="/mnt/d/OpenClaw/tmp"
ARCHIVE=""
PASSPHRASE_FILE=""
OUTPUT_DIR=""
APPLY=0

usage() {
  cat <<'EOF'
Usage:
  scripts/restore-sensitive-runtime-state.sh --archive <file.tar.gz.gpg> [--passphrase-file <file>] [--output-dir <dir>] [--apply]

Notes:
  - Default mode only decrypts and stages files under /mnt/d for inspection.
  - Add --apply to rsync the staged files back into the repo root.
  - In public-key mode, GPG uses your local private key; in symmetric mode, also provide --passphrase-file.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --archive)
      ARCHIVE="${2:-}"
      shift 2
      ;;
    --passphrase-file)
      PASSPHRASE_FILE="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --apply)
      APPLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$ARCHIVE" ]; then
  echo "Missing --archive." >&2
  exit 1
fi

mkdir -p "$TMP_BASE"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="${OUTPUT_DIR:-$(mktemp -d "$TMP_BASE/sensitive-restore-$TIMESTAMP-XXXXXX")}"
DECRYPTED_ARCHIVE="$WORK_DIR/archive.tar.gz"
STAGE_DIR="$WORK_DIR/stage"

mkdir -p "$WORK_DIR" "$STAGE_DIR"

if [ -n "$PASSPHRASE_FILE" ]; then
  gpg --batch --yes --pinentry-mode loopback --passphrase-file "$PASSPHRASE_FILE" --decrypt --output "$DECRYPTED_ARCHIVE" "$ARCHIVE"
else
  gpg --batch --yes --decrypt --output "$DECRYPTED_ARCHIVE" "$ARCHIVE"
fi

tar -xzf "$DECRYPTED_ARCHIVE" -C "$STAGE_DIR"

echo "Decrypted backup staged."
echo "stage=$STAGE_DIR"

if [ "$APPLY" -eq 1 ]; then
  rsync -a "$STAGE_DIR/" "$ROOT_DIR/"
  echo "Applied staged files back to $ROOT_DIR"
else
  echo "Dry-run only. Re-run with --apply to restore into $ROOT_DIR"
fi
