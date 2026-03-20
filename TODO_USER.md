# TODO_USER.md

## Purpose

Tasks that require the user's direct action, decision, login, or confirmation.
Keep this list short and actionable. Move items out as soon as they are resolved.

## Active

- [P0] **Compact docker_data.vhdx**：C盘目前 7.8G 可用，但 `docker_data.vhdx` 占 68G（实际使用远小于此）。需要管理员 PowerShell 执行：
  ```
  wsl --shutdown
  # PowerShell (管理员):
  Optimize-VHD -Path "C:\Users\Lenovo\AppData\Local\Docker\wsl\disk\docker_data.vhdx" -Mode Full
  ```
  预计可回收 20-40G。
- [P1] When convenient, do one full Docker Desktop stop/start test and confirm OpenClaw still opens the same state after Windows-side restart.
- [P1] Choose the first encrypted secret-backup mode for migration: either a GPG recipient key or a symmetric passphrase-file workflow.
- [P1] Decide whether Claude Code Hub should stay standalone on `127.0.0.1:23000` or be explicitly integrated into OpenClaw workflows.
- [P1] Decide whether to wait for the current `rightcode` quota/package window to recover or switch background jobs to a different working model path.
- [P2] Decide whether to finalize bootstrap/identity cleanup now or later.
- [P2] Decide whether any browser-control capability should be re-enabled for specific tasks.
- [P3] Decide when to start designing the multi-agent workbench.

## Done recently

- [x] C盘空间清理：从 2.7G 恢复到 7.8G，清理了 Temp/wsl-crashes、assistant-state-backup、openclaw_recovery、var/backups、agent-reach-env、Docker dangling volumes
- [x] Fixed GitHub auth chain: the stale hardcoded `GITHUB_TOKEN` override was removed, runtime now reads the intended value, and `gh` / private-repo access work again.
- [x] Feishu DM channel paired and working.
- [x] Gateway token mismatch cleared.
- [x] Xiaohongshu MCP login restored from persisted cookies.
