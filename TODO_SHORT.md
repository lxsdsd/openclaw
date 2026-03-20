# TODO_SHORT.md

## Purpose

One-time actionable tasks. Clear completed items quickly so this file stays focused on active work only.

## Priority legend

- `P0` urgent, start now
- `P1` important, do next
- `P2` useful, schedule after higher priorities
- `P3` backlog, low urgency

## Active

- [x] ~~[P1] Tighten agent tool profiles per security audit~~ — tools.deny 已配置并验证生效。
- [x] ~~[P1] Encrypted backup path for secret-bearing runtime state~~ — 备份/恢复脚本已部署到 wsl-host ~/bin/，存储到 D:/openclaw-backups/secrets/，AES-256 加密，保留最近 5 份。用户需设置 BACKUP_PASSPHRASE。
- [x] ~~[P1] Keep rightcode-blocked worker jobs disabled~~ — 已确认无残留 worker jobs，仅剩 3 个正常 cron（日报x2 + 磁盘检查）。
- [x] ~~[P1] Fixate OPENCLAW_GATEWAY_TOKEN + OPENCLAW_GATEWAY_PORT=18789 into wsl-host ~/.bashrc~~ — 已写入。
- [P2] Multi-agent parallel execution validation — run a real parallel dispatch test.
- [x] ~~Workspace git commit + push for today's changes~~ — pushed to `workspace-main-v2` on lxsdsd/openclaw。

## Blocked (needs user)

- [P1] BRAVE_API_KEY — user needs to apply at brave.com/search/api and add to .env.
- [P2] Gateway bind loopback hardening — user decision on network topology.

## Done recently (2026-03-20)

- [x] operator.read rebuild + verify — 修复完全生效，resolveStoredOperatorDeviceToken 在 33 个 dist 文件命中，gateway probe Reachable: yes。
- [x] vhdx compact — C 盘从 7.8G → 47G，回收约 39G。
- [x] Git proxy fix — 修正为 172.22.144.1:7897。
- [x] disk-cleanup skill — 补上 vhdx 压缩手动流程，推到 GitHub。
- [x] Cron jobs rebuilt — daily-report-2000-bjt + daily-report-2200-bjt 重建完成。
- [x] Plugin allowlist expanded to 44 entries.
- [x] context-safe updated to v0.4.1.
- [x] Dockerfile.agent-reach FROM changed to openclaw:local.
- [x] start-local-runtime.sh enhanced with --build flag (by Codex).
- [x] Agent tools.deny 配置验证生效 — research/watchdog/builder-a/b/monetization 等全部收紧。
- [x] 飞书 streaming card 关闭 — 修复消息投递静默丢失问题。
