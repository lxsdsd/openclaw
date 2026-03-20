#!/usr/bin/env bash
# openclaw-secret-restore.sh — Decrypt and restore secret backup
set -euo pipefail

BACKUP_DIR="/mnt/d/openclaw-backups/secrets"
OPENCLAW_HOME="${OPENCLAW_HOME:-/home/node/.openclaw}"
TMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Find latest backup or use provided path
ENCRYPTED="${1:-$(ls -t "$BACKUP_DIR"/openclaw-secrets-*.tar.gz.enc 2>/dev/null | head -1)}"
if [ -z "$ENCRYPTED" ] || [ ! -f "$ENCRYPTED" ]; then
  echo "No backup found. Usage: $0 [path-to-encrypted-backup]"
  exit 1
fi

echo "=== OpenClaw Secret Restore ==="
echo "Source: $ENCRYPTED"

if [ -z "${BACKUP_PASSPHRASE:-}" ]; then
  echo "ERROR: Set BACKUP_PASSPHRASE env var."
  exit 1
fi

# Decrypt
openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 100000 \
  -in "$ENCRYPTED" \
  -out "$TMP_DIR/archive.tar.gz" \
  -pass env:BACKUP_PASSPHRASE

tar -xzf "$TMP_DIR/archive.tar.gz" -C "$TMP_DIR"

echo "Contents:"
ls -la "$TMP_DIR/secrets/"

echo ""
echo "Restore targets:"
for dir in devices identity credentials gh; do
  if [ -d "$TMP_DIR/secrets/$dir" ]; then
    echo "  $dir → $OPENCLAW_HOME/$dir"
  fi
done
if [ -f "$TMP_DIR/secrets/openclaw.json" ]; then
  echo "  openclaw.json → $OPENCLAW_HOME/openclaw.json"
fi
if [ -f "$TMP_DIR/secrets/dot-env" ]; then
  echo "  .env → /home/gaga/openclaw/.env"
fi

echo ""
echo "⚠️  This will OVERWRITE existing files. Press Enter to continue or Ctrl+C to abort."
read -r

for dir in devices identity credentials gh; do
  if [ -d "$TMP_DIR/secrets/$dir" ]; then
    cp -r "$TMP_DIR/secrets/$dir" "$OPENCLAW_HOME/$dir"
    echo "  ✓ $dir restored"
  fi
done
if [ -f "$TMP_DIR/secrets/openclaw.json" ]; then
  cp "$TMP_DIR/secrets/openclaw.json" "$OPENCLAW_HOME/openclaw.json"
  echo "  ✓ openclaw.json restored"
fi
if [ -f "$TMP_DIR/secrets/dot-env" ]; then
  cp "$TMP_DIR/secrets/dot-env" /home/gaga/openclaw/.env
  echo "  ✓ .env restored"
fi

echo "=== Restore complete. Restart OpenClaw to apply. ==="
