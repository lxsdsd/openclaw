# OpenClaw 基建缺口清单（2026-03-20）

基于本地只读核查：`openclaw status`、`openclaw security audit --deep`、`openclaw update status`、`openclaw skills check`、`openclaw memory status --deep --agent main`、`openclaw cron status --json`。

## 已确认正常

- 主会话 memory 索引健康：`20/20 files`，vector ready。
- Feishu 通道可用。
- GitHub 鉴权与推送链路已恢复。
- `rightcode` 已知阻塞 worker 处于停用态，没有继续空转。
- 运行时技能可见性问题已澄清：当前是“可见但依赖不全”，不是“技能消失”。

## 优先级缺口

### P0

1. `tavily-search` 技能安全风险
   - 现状：`openclaw security audit --deep` 报 1 个 critical。
   - 证据：`skills/tavily-search/scripts/extract.mjs:18`、`skills/tavily-search/scripts/search.mjs:42` 命中 environment-harvesting。
   - 目标：完成代码审查，确认是否移除、隔离、或重写为安全实现。
   - 处理人：我可先继续审查；若确认不可信，可进入移除/隔离方案。

### P1

2. 本地控制面读权限链异常（`operator.read`）
   - 现状：`openclaw status` 显示 gateway unreachable（missing scope: `operator.read`）；`openclaw cron status --json` 直接 normal closure。
   - 影响：无法稳定做 live cron / nodes / 深度 probe 检查。
   - 目标：修复本地 CLI 凭证选择，让 cached operator device auth 能用于 live 读操作。
   - 处理人：我继续排查。

3. 定时任务真实状态与看板不一致
   - 现状：`/home/node/.openclaw/cron/jobs.json` 当前为空；`report-2000-bjt` / `report-2200-bjt` 不在 live 调度器中。
   - 影响：晚报问题当前不是单纯 prompt 超时，而是先要确认任务是否被清空、迁移或需要重建。
   - 目标：完成 scheduler truth 对账，并按结果重建或清理看板描述。
   - 处理人：我继续查；若最终需要重建具体提醒时间，你来定时点。

4. 仓库边界还没完全收口
   - 现状：恢复分支已推送，但长期默认分支/默认落点还没整理完成。
   - 新规则：每个活跃项目都要有自己对应的仓库；没有时应创建，避免继续混仓。
   - 目标：把 OpenClaw 与 `English_study` 的长期工作流彻底分开，后续默认提交不再混线。
   - 处理人：我继续推进。

5. Gateway token 偏短
   - 现状：`openclaw security audit` 报 warn，当前 token 长度 13。
   - 风险：虽然当前边界是个人助理模式，但长期不建议保留短 token。
   - 目标：换成长随机 token，并验证客户端重连。
   - 处理人：需要挑安全窗口执行，我可做。

6. 技能依赖分层尚未整理
   - 现状：`openclaw skills check` = 61 总数 / 19 ready / 42 missing requirements。
   - 含义：这不是故障本身，但说明“哪些是必装、哪些是可选”还没形成一份清楚名单。
   - 目标：把 42 项拆成“当前环境刻意不装”和“真正缺的必需项”。
   - 处理人：我可继续整理。

### P2

7. Feishu 文档创建能力需要继续收口使用边界
   - 现状：`feishu_doc create` 可把文档权限授给当前可信请求者，审计为 warn。
   - 目标：保留能力，但只在明确文档任务中使用，并继续限制在可信边界。
   - 处理人：执行时注意即可。

8. 宿主重启恢复演练仍缺一次人工验证
   - 现状：还缺一次 Docker Desktop 全停全起后的状态连续性确认。
   - 目标：确认 Windows/WSL/Docker 重启后 OpenClaw 仍能回到相同状态。
   - 处理人：需要你亲手做一次。

## 需要用户动作

- 确认明天徒步收拾/检查提醒的北京时间。
- 找一个方便时段做一次 Docker Desktop 全停全起恢复测试。
- 之后如要执行 gateway token 轮换，我会单独挑窗口处理。

## 我接下来的顺序

1. 先审 `skills/tavily-search`，确认它到底是误报还是应隔离。
2. 并行继续查 `operator.read` 本地凭证选择链。
3. 然后把 cron 真相对账和仓库边界收口接起来。
