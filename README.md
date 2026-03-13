# Assistant State Backup

This repository stores rollback-friendly snapshots of the assistant file-based state.
It is intentionally separate from the main OpenClaw repo so assistant rollbacks do not touch unrelated product code.

## Included

- `config/openclaw.json`
- `workspace/`
- `workspace-builder-a/`
- `workspace-builder-b/`
- `workspace-research/`
- `workspace-watchdog/`

## Excluded

- `.git/`
- `.openclaw/`
- `.perm_test`
- `assistant-state-backup/`
- common runtime artifacts such as `*.log`, `*.db`, `*.sqlite`, `node_modules/`

## Save a new rollback point

```bash
./save-point.sh "describe what changed"
```

If you omit the message, the script creates a UTC timestamped snapshot commit.

## Restore a previous snapshot

1. Inspect history:

```bash
git log --oneline --decorate
```

2. Check out the snapshot you want to restore into the backup repo working tree:

```bash
git checkout <commit>
```

3. Sync that snapshot back into the live assistant paths:

```bash
./restore-settings.sh
```

4. Return to the branch tip when done:

```bash
git switch main
```

## Remote backup later

This repo is ready for a private remote.
Before pushing remotely, confirm `config/openclaw.json` still contains only env placeholders instead of literal secrets.
