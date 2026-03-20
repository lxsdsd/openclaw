#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="/mnt/d/OpenClaw/encrypted-backups"
TMP_BASE="/mnt/d/OpenClaw/tmp"
RECIPIENT=""
PASSPHRASE_FILE=""
MODE=""
INCLUDE_ROOT_ENV=0

usage() {
  cat <<'EOF'
Usage:
  scripts/backup-sensitive-runtime-state.sh --recipient <gpg-recipient> [--output-dir <dir>] [--include-root-env]
  scripts/backup-sensitive-runtime-state.sh --symmetric --passphrase-file <file> [--output-dir <dir>] [--include-root-env]

Notes:
  - Uses GPG encryption and writes the encrypted archive under /mnt/d by default.
  - Does not print secret contents.
  - By default, root .env is excluded to respect minimal secret handling.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --recipient)
      RECIPIENT="${2:-}"
      MODE="recipient"
      shift 2
      ;;
    --symmetric)
      MODE="symmetric"
      shift
      ;;
    --passphrase-file)
      PASSPHRASE_FILE="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --include-root-env)
      INCLUDE_ROOT_ENV=1
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

if [ "$MODE" = "recipient" ] && [ -z "$RECIPIENT" ]; then
  echo "Missing --recipient value." >&2
  exit 1
fi

if [ "$MODE" = "symmetric" ] && [ -z "$PASSPHRASE_FILE" ]; then
  echo "Symmetric mode requires --passphrase-file." >&2
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Choose either --recipient or --symmetric." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR" "$TMP_BASE"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="$(mktemp -d "$TMP_BASE/sensitive-backup-$TIMESTAMP-XXXXXX")"
STAGE_DIR="$WORK_DIR/stage"
MANIFEST_FILE="$WORK_DIR/MANIFEST.txt"
ARCHIVE_BASENAME="openclaw-sensitive-state-$TIMESTAMP"
ARCHIVE_FILE="$WORK_DIR/$ARCHIVE_BASENAME.tar.gz"
OUTPUT_FILE="$OUTPUT_DIR/$ARCHIVE_BASENAME.tar.gz.gpg"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$STAGE_DIR"

declare -a RELATIVE_PATHS=(
  "var/config/devices"
  "var/config/identity"
  "var/config/gh"
  "var/config/credentials"
  "var/xiaohongshu-mcp/cookies.json"
  "var/qmd-memory-service/.env"
)

if [ "$INCLUDE_ROOT_ENV" -eq 1 ]; then
  RELATIVE_PATHS+=(".env")
fi

INCLUDED_COUNT=0
for relative_path in "${RELATIVE_PATHS[@]}"; do
  source_path="$ROOT_DIR/$relative_path"
  if [ -e "$source_path" ]; then
    mkdir -p "$STAGE_DIR/$(dirname "$relative_path")"
    if [ -d "$source_path" ]; then
      rsync -a "$source_path/" "$STAGE_DIR/$relative_path/"
    else
      cp "$source_path" "$STAGE_DIR/$relative_path"
    fi
    INCLUDED_COUNT=$((INCLUDED_COUNT + 1))
  fi
done

if [ "$INCLUDED_COUNT" -eq 0 ]; then
  echo "No configured sensitive paths were found." >&2
  exit 1
fi

(
  cd "$STAGE_DIR"
  find . -mindepth 1 | sed 's#^./##' | sort > "$MANIFEST_FILE"
  tar -czf "$ARCHIVE_FILE" .
)

if [ "$MODE" = "recipient" ]; then
  gpg --batch --yes --trust-model always --recipient "$RECIPIENT" --encrypt --output "$OUTPUT_FILE" "$ARCHIVE_FILE"
else
  gpg --batch --yes --pinentry-mode loopback --passphrase-file "$PASSPHRASE_FILE" --symmetric --cipher-algo AES256 --output "$OUTPUT_FILE" "$ARCHIVE_FILE"
fi

cp "$MANIFEST_FILE" "$OUTPUT_DIR/$ARCHIVE_BASENAME.manifest.txt"
sha256sum "$OUTPUT_FILE" > "$OUTPUT_DIR/$ARCHIVE_BASENAME.sha256"

echo "Encrypted backup created."
echo "archive=$OUTPUT_FILE"
echo "manifest=$OUTPUT_DIR/$ARCHIVE_BASENAME.manifest.txt"
echo "sha256=$OUTPUT_DIR/$ARCHIVE_BASENAME.sha256"
echo "items=$INCLUDED_COUNT"
