#!/usr/bin/env bash
# openclaw-secret-backup.sh — Encrypt and backup secret-bearing runtime state
# Targets: devices/, identity/, credentials/, gh/, .env, openclaw.json (auth section)
# Encryption: openssl aes-256-cbc with passphrase (PBKDF2)
# Storage: /mnt/d/openclaw-backups/secrets/
set -euo pipefail

OPENCLAW_HOME="${OPENCLAW_HOME:-/home/node/.openclaw}"
BACKUP_DIR="/mnt/d/openclaw-backups/secrets"
TIMESTAMP=$(date -u +%Y%m%d-%H%M%S)
ARCHIVE_NAME="openclaw-secrets-${TIMESTAMP}.tar.gz"
ENCRYPTED_NAME="${ARCHIVE_NAME}.enc"
TMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "=== OpenClaw Secret Backup ==="
echo "Timestamp: $TIMESTAMP"

# Collect secret files
mkdir -p "$TMP_DIR/secrets"

for dir in devices identity credentials gh; do
  src="$OPENCLAW_HOME/$dir"
  if [ -d "$src" ] && [ "$(ls -A "$src" 2>/dev/null)" ]; then
    cp -r "$src" "$TMP_DIR/secrets/$dir"
    echo "  ✓ $dir"
  else
    echo "  - $dir (empty/missing, skipped)"
  fi
done

# Copy openclaw.json (contains auth tokens)
if [ -f "$OPENCLAW_HOME/openclaw.json" ]; then
  cp "$OPENCLAW_HOME/openclaw.json" "$TMP_DIR/secrets/openclaw.json"
  echo "  ✓ openclaw.json"
fi

# Copy .env if accessible
for envfile in /home/gaga/openclaw/.env "$OPENCLAW_HOME/../.env"; do
  if [ -f "$envfile" ]; then
    cp "$envfile" "$TMP_DIR/secrets/dot-env"
    echo "  ✓ .env ($envfile)"
    break
  fi
done

# Create tarball
tar -czf "$TMP_DIR/$ARCHIVE_NAME" -C "$TMP_DIR" secrets/
echo "Archive: $(du -h "$TMP_DIR/$ARCHIVE_NAME" | cut -f1)"

# Encrypt
if [ -z "${BACKUP_PASSPHRASE:-}" ]; then
  echo "ERROR: Set BACKUP_PASSPHRASE env var before running."
  echo "  export BACKUP_PASSPHRASE='your-strong-passphrase'"
  exit 1
fi

openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
  -in "$TMP_DIR/$ARCHIVE_NAME" \
  -out "$TMP_DIR/$ENCRYPTED_NAME" \
  -pass env:BACKUP_PASSPHRASE

# Store
mkdir -p "$BACKUP_DIR"
cp "$TMP_DIR/$ENCRYPTED_NAME" "$BACKUP_DIR/$ENCRYPTED_NAME"
echo "=== Backup saved ==="
echo "  $BACKUP_DIR/$ENCRYPTED_NAME"
echo "  Size: $(du -h "$BACKUP_DIR/$ENCRYPTED_NAME" | cut -f1)"

# Prune old backups (keep last 5)
ls -t "$BACKUP_DIR"/openclaw-secrets-*.tar.gz.enc 2>/dev/null | tail -n +6 | xargs -r rm -v
echo "=== Done ==="
