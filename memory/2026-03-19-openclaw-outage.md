# 2026-03-19 OpenClaw 宕机复盘

## 现象

- Web / Feishu 侧表现为 OpenClaw 打不开或连接失败。
- `openclaw-openclaw-gateway-1` 持续重启或启动失败。

## 直接原因

- 网关启动时读不到配置文件，报：
  - `Missing config. Run openclaw setup or set gateway.mode=local`
- 后续把配置文件补进容器后，又因为必需环境变量缺失而失败，报：
  - `missing env var "RIGHTCODE_API_KEY"`
  - `Gateway failed to start: required secrets are unavailable`

## 根因

- 实际运行的容器不是预期的完整组合运行态，而是退回到了只用基础 `docker-compose.yml` 的状态。
- 结果导致：
  - 自定义镜像 `openclaw-agent-reach:local` 没有生效。
  - 预期的额外挂载和工具链没有生效。
  - 容器内 `/home/node/.openclaw` 没有拿到 `openclaw.json`，只剩 `workspace/`。
- 同时配置里启用了 `rightcode` provider，但当前运行环境没有注入 `RIGHTCODE_API_KEY`，导致即使配置文件存在，网关仍会被 secrets 检查拦下。

## 追加根因（2026-03-19 晚）

- 这次进一步确认：最容易反复出错的点不是“workspace 文件丢了”，而是 **Docker runtime state 根目录挂载错了或只挂进去一半**。
- 在当前 WSL + Docker Desktop 组合下：
  - 直接把运行态指到别的 state 根（尤其是临时拆分态）很容易出现“workspace 在，但 `/home/node/.openclaw` 里的 runtime state 不完整”的情况。
  - 一旦 `/home/node/.openclaw` 只剩 workspace，没有 `openclaw.json` / `devices` / `agents` / `exec-approvals.json`，OpenClaw 就会表现得像新实例，用户会误以为“skills / agents / 聊天记录都丢了”。
- 进一步确认还有第二层根因：**这台机器同时存在多套 state root，加上 Docker 控制路径曾混用 Windows `docker.exe` 包装器和 WSL 原生 Docker CLI**。
- 这会造成一种很危险的假象：宿主机里你刚改过的 `openclaw.json` 是新的，但容器实际读到的仍然可能是另一份旧快照。
- 这也是为什么本次故障不是只表现为 Feishu 掉线，而是会一起表现为：
  - Feishu 消失
  - agents 消失
  - skills / 待办 / 角色设定看起来一起没了
  - 浏览器又要求重新 pairing
- 本机已改成：
  - 启动前先把 `~/.openclaw/` runtime state 同步到 `openclaw/var/config/`
  - Docker 只挂 `openclaw/var/config` + `openclaw/var/workspace`
  - 以后禁止裸 `docker compose up` 直接启动本地 OpenClaw
  - `openclaw/var/config` 作为 Docker 唯一 canonical runtime state 根
  - D 盘快照目录固定为 `/mnt/d/OpenClaw/state-bundles/openclaw/current`
  - 迁移不再靠到处找散文件，而是直接打包 `var/config` + `var/workspace`

## 这次学到的规则

- 不要只看宿主机文件存在；必须验证容器内是否真的看得到：
  - `/home/node/.openclaw/openclaw.json`
  - `/home/node/.openclaw/bin/...`
- 不要只看“compose 配置打印出来没问题”；还要确认实际运行容器读到的配置内容与宿主机当前文件一致。
- 每次改配置目录、挂载目录、Docker 组合文件后，都要做容器内验证，而不是只看宿主机路径。
- 启动 OpenClaw 时要明确区分：
  - 基础运行：`docker-compose.yml`
  - 你的长期运行态：基础 compose + `docker-compose.agent-reach.yml`（以及需要时的其他 override）
- 本机本地生命周期命令优先使用 WSL 原生 `/usr/bin/docker`，不要把 Windows `docker.exe` 包装器当成等价路径。
- 新增或切换到依赖 env secret 的 provider 前，要先确认容器环境里真的有对应变量；否则应该先禁用该 provider，避免整机起不来。
- D 盘路径可用于数据或工具，但只要涉及核心配置目录，必须先验证 Docker Desktop / WSL 的 bind mount 是否真实生效。

## 下次排障顺序

1. 看容器是否在重启循环。
2. 看最新日志是：
   - 缺配置
   - 缺 secret
   - 端口冲突
   - 运行时错误
3. 直接进入容器验证：
   - `/home/node/.openclaw/openclaw.json` 是否存在
   - `/home/node/.openclaw/workspace` 是否存在
4. 确认当前容器镜像是否正确：
   - 应优先是 `openclaw-agent-reach:local`
   - 而不是回退成官方 `ghcr.io/openclaw/openclaw:latest`
5. 确认 compose 实际用了哪些文件，不要只凭记忆判断。
6. 确认所有必需 provider secret 是否注入容器。

## 给 OpenClaw 的长期要求

- 任何“修改配置目录 / compose / 启动方式 / provider secrets”的操作，完成后必须自动执行一次自检：
  - 当前镜像
  - 当前 compose 来源
  - 当前挂载
  - 配置文件是否存在
  - 必需 secrets 是否存在
- 如果发现 `provider secret` 缺失，不要让整机直接起不来；应优先降级禁用相关 provider，并把风险写入状态报告。
- 如果发现运行态偏离预期组合（例如 override 丢失），要立即上报“当前不是标准运行态”。
