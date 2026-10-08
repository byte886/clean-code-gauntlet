# AGENTS.md — AI代理操作手册

> **文档类型**：Governance（治理规范 — AI操作手册）
> **更新频率**：每次流程/工具/规范变更时
> **维护者**：AI自动维护 + 用户审核
> **读者**：AI代理（每次启动自动加载）

> 本文档是AI代理的操作手册，命令式、可执行。与README.md（给人看的项目介绍）互补。
> 执行任何任务前必须先阅读本文档对应部分，**核心规则在第 3 章，必须优先阅读**。
> 写作原则：只包含AI无法推断的内容，已在其他文档中的内容只链接不重复。

---

## 1. 文档边界

| 维度 | 本文档（AGENTS.md） | 其他文档 |
|------|---------------------|----------|
| **定位** | AI操作手册，命令式、可执行 | - |
| **读者** | AI代理（每次启动自动加载） | - |
| **包含** | 核心规则、执行前必读、禁止事项、常用命令 | - |
| **不包含** | 项目介绍、目录概览 | → [README.md](README.md) |
| **不包含** | 方法论理论手册 | → [docs/THEORY.md](docs/THEORY.md) |
| **不包含** | 使用流程与操作步骤 | → [docs/WORKFLOW.md](docs/WORKFLOW.md) |
| **不包含** | 上游版本与变更记录 | → [docs/UPSTREAM_TRACKING.md](docs/UPSTREAM_TRACKING.md) |
| **不包含** | 文档索引 | → [docs/DOCUMENTATION_MAP.md](docs/DOCUMENTATION_MAP.md) |

---

## 2. 执行前必读（强制）

先判断本次属于哪种，再按对应路径读；**不靠对话记忆猜测**。

### 路径 A · 冷启动（首次接触 / 跨任务切换 / 用户要求全面梳理）
按序读：
1. `README.md` — 项目概览、快速开始
2. `docs/THEORY.md` — 方法论理论手册（本仓库的核心知识资产，必须掌握）
3. `docs/WORKFLOW.md` — 使用流程（安装/生成/更新）
4. `docs/DOCUMENTATION_MAP.md` — 文档地图
5. `docs/UPSTREAM_TRACKING.md` — 上游版本基线

### 路径 B · 续接（用户说"继续/生成/更新 X"且已熟悉本仓库）
只读：
1. `docs/WORKFLOW.md` 对应环节
2. `docs/UPSTREAM_TRACKING.md`（仅涉及上游更新时）
3. `CHANGELOG.md` 最新条目

**判不准走 A 还是 B 时，就高走 A。**

---

## 3. 核心规则（强制，必须遵守）

### 3.1 vendor 模式，禁止 fork
- 上游工具（swarm-forge / crap4clj / crapper / clj-mutate / mutator / uml-viewer）**一律 vendor 引用**：本地克隆进 `tooling/vendor/`（gitignored），版本记录在 `tooling/upstream/*.md` 与 `docs/UPSTREAM_TRACKING.md`。
- **不 fork、不复制上游源码入库**（LICENSE/来源头注记保留在 vendor 目录内即可）。上游工具若有官方安装方式（如 get-swarm-forge），优先走官方安装器。

### 3.2 上游追踪是常设机制
- 每次会话若涉及"检查更新/维护"：运行 `scripts/upstream-sync.sh`，**如实报告**比对结果（已是最新 / 有变更：哪些仓库、旧→新 sha、变化说明）。
- 上游有变更时：更新对应 `tooling/upstream/<repo>.md` 的版本字段 → 更新 `docs/UPSTREAM_TRACKING.md` 基线 → `CHANGELOG.md` 记一条 → 若变更影响生成器/模板，同步更新 `templates/` 与 `generate-project.sh`。
- GitHub API 抓取失败时**如实报告失败**，不得用旧快照冒充"已是最新"。
- **理论原稿也在追踪范围**：Bob 的新访谈/演讲/长文（一手理论来源）→ 存入 `docs/reference/`（见该目录 README 的校准规则）并记 CHANGELOG；抖音等二手解说稿只作辅助，理论表述以 `docs/reference/` 原稿为准。

### 3.3 生成项目必须走生成器
- 用户要"用这套理论开发/生成项目"时，**必须**走 `tooling/bin/generate-project.sh`（或其对应 SOP），不要手搓项目结构。
- 生成器产出的项目：自带 `quality-gates/`（按语言的 CRAP/变异/覆盖率/架构测试配置）、`constitution/`（三层宪法）、`roles/`（六角色 prompts）、`docs/` 骨架。
- 生成后检查：目录完整、占位符已替换、质量关卡命令与所选语言匹配。

### 3.4 文档纪律
- README 只做概览与边界；理论/流程/术语进 `docs/`；AI 规则只进 AGENTS.md；变更只进 CHANGELOG.md；**不双写**。
- 理论手册（THEORY.md）与术语表（TERMS.md）更新时，必须基于**上游一手资料**（优先 `docs/reference/` 访谈原稿，其次 Bob 的 GitHub README / 官方文档），并标注来源；音译存疑标注 `〔存疑〕`。
- 事实性内容（版本号、sha、日期）必须来自上游抓取或可复现计算，禁止编造。

### 3.5 交付前验证
- 修改生成器/模板后，**实跑一次生成器**验证产物完整；修改上游同步脚本后，**实跑一次**验证输出格式。
- 推送 GitHub 前检查：`git status` 无运行产物、无 `tooling/vendor/`、无 `generated/` 误入库。

---

## 4. 常用命令

```bash
# 安装/更新上游工具（vendor 到 tooling/vendor/）
tooling/bin/install-tools.sh

# 生成新项目（问答式）
tooling/bin/generate-project.sh

# 检查上游变更
scripts/upstream-sync.sh

# 仓库体检
git status && git log --oneline -5
```
