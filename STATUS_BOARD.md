# STATUS_BOARD.md

Last updated: 2026-03-21 02:40 BJT

## GitHub 仓库状态

| 仓库 | 默认分支 | 状态 |
|---|---|---|
| `lxsdsd/openclaw` | `workspace-main-v2` | 扁平 workspace 结构，今日推送 |
| `lxsdsd/English_study` | `main` | main 混有 recovery 提交；`dev` 分支从 `label-studio-2026-03-13` 拉出，待继续开发 |
| `lxsdsd/openclaw-disk-cleanup-skill` | `main` | 干净，独立技能仓库 |

## 基础设施

- 飞书 DM 通道正常，streaming card 已关闭（修复消息丢失）
- Gateway token + port 已写入 wsl-host ~/.bashrc
- GITHUB_TOKEN 已配置，gh auth + git push 正常
- 加密备份脚本已部署到 wsl-host ~/bin/，待用户设置 BACKUP_PASSPHRASE
- Sub-agent tools.deny 权限收紧已生效
- C 盘 47G 可用（compact 后）

## 任务板

- 单一数据源：飞书 Bitable `P1B0bfR5saT9bys80GPcMr8rnkf`
- 优先级已统一为 P0/P1/P2/P3（旧标签已清理）
- task-driver skill 已就绪
- builder-b 占位任务已关闭，按需分派

## 当前活跃待办（未完成）

| 优先级 | 任务 | 归属 |
|---|---|---|
| P1 | 决定是否轮换 gateway token | 用户 |
| P1 | 补配 BRAVE_API_KEY | 用户 |
| P2 | 决定 agent-reach 维持/补齐 | 用户 |
| P2 | agent-reach 授权/API key 事项 | 用户 |
| P2 | 恢复 native agent-reach 工具链 | 用户 |
| P2 | 恢复 browser-control 能力 | 用户 |
| P2 | 创建 agent-only 白名单群 | 用户 |
| P2 | 评估 claude-code-hub | research |
| P2 | 多 Agent 并行执行验证 | main |
| P3 | agent-reach 可选扩展 | 用户 |
| P3 | 编码项目目录/标签统一 | 用户 |
| P3 | 谋财 lane | monetization |
| P3 | 交付官 lane | delivery-lead |

## 用户待办（TODO_USER.md）

- 设置 BACKUP_PASSPHRASE 并跑第一次备份
- 申请 BRAVE_API_KEY
- Compact docker_data.vhdx ✅ 已完成
