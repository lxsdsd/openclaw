# Folder Lockdown Guide

## Principle

If a directory contains credentials, chat identity state, browser sessions, or personal app data, lock it down at the filesystem level and treat it as forbidden-by-default for the assistant.

## Strongly recommended: lock these down

### Never read by default

- `~/.openclaw/credentials/`
- `~/.openclaw/*.env`
- `~/.env`
- `~/**/.env`
- browser profiles such as `~/.config/google-chrome/`, `~/.config/BraveSoftware/`, `~/.mozilla/`
- WeChat-related directories, exports, caches, databases, attachments, backups
- SSH / GPG / age / 1Password / Bitwarden / KeePass key material

### Usually safe to allow when task-related

- OpenClaw workspace docs, notes, code, scripts
- Feishu project files that are task artifacts rather than secrets
- Public docs and repository files

## Practical permission pattern on Linux

Use your own user as owner, and remove group/other access from sensitive directories:

```bash
chmod 700 ~/.openclaw/credentials
chmod 700 ~/.ssh
chmod 700 ~/.gnupg
chmod 700 ~/.config/BraveSoftware
chmod 700 ~/.config/google-chrome
```

For individual secret files:

```bash
chmod 600 ~/.env
chmod 600 ~/.openclaw/openclaw.json
chmod 600 ~/.ssh/id_ed25519
```

## Optional segregation pattern

Keep work files and private app data physically separate:

- allow assistant work only in `~/work/` or the OpenClaw workspace
- keep private exports in `~/private/`
- keep chat backups in `~/private/chat-archives/`
- keep tokens in a password manager rather than plaintext dotfiles when possible

## OpenClaw-specific note

Based on local docs, WhatsApp auth state is stored under paths such as `~/.openclaw/credentials/whatsapp/<accountId>/creds.json`. I will not read those files unless you explicitly ask.

Feishu can be worked with more safely when using project files or bot configuration you intentionally point me at, but any app secret / verification token / account credential is still sensitive and remains ask-first.
