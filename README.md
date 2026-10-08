# Clean Code Gauntlet — 确定性 AI 代码质量工具库

> **文档类型**：Concept（概念说明 — 项目介绍）
> **更新频率**：项目结构/工具/理论变更时
> **维护者**：AI自动维护 + 用户审核
> **读者**：人类（新加入项目者）和AI（首次了解项目时）

---

## 文档边界

| 维度 | 本文档（README.md） | 其他文档 |
|------|---------------------|----------|
| **定位** | 项目介绍，给人看的概览 | - |
| **读者** | 人类（新加入项目者）和AI（首次了解项目时） | - |
| **包含** | 项目目标、仓库地址、查询话术、目录结构、快速开始 | - |
| **不包含** | AI执行规则、命令、Things to Avoid | → [AGENTS.md](AGENTS.md) |
| **不包含** | 详细操作流程、各环节步骤 | → [docs/WORKFLOW.md](docs/WORKFLOW.md) |
| **不包含** | 方法论理论手册 | → [docs/THEORY.md](docs/THEORY.md) |
| **不包含** | 术语解释 | → [docs/TERMS.md](docs/TERMS.md) |
| **不包含** | 文档索引、所有文档清单 | → [docs/DOCUMENTATION_MAP.md](docs/DOCUMENTATION_MAP.md) |

---

## 项目介绍

把《代码整洁之道》作者 **Bob 大叔（Robert C. Martin）** 的"确定性质量验证"方法论——**复杂度检查（CRAP）、变异测试、架构约束、多 Agent 流水线**——变成你自己的**可复用工具 + 知识库**。

你最终会得到：

1. **一个可生成新项目的工具** — 一条命令按 Bob 的流水线（six-pack：规格→编码→清理→架构→强化→QA）生成新开发项目骨架，自动带上质量关卡配置与宪法规则
2. **一份可移植的理论手册** — Bob 的完整方法论、术语表、落地 SOP，不依赖任何特定 Agent 或环境
3. **一套上游追踪机制** — Bob 在 GitHub 上持续迭代他的工具（swarm-forge / crap4clj / uml-viewer…），本仓库自动检测变更、记录版本、迭代更新

## 仓库地址

- GitHub: https://github.com/byte886/clean-code-gauntlet （公有）

## 常用查询话术（直接复制使用）

想了解项目状态时，直接复制下面的话术发送给AI：

| 你想知道 | 直接复制 |
|----------|----------|
| 生成一个新项目 | `用 clean-code-gauntlet 生成一个 [语言] 项目，six-pack 流水线` |
| 检查上游是否有更新 | `运行上游追踪：检查 Bob 的工具仓库是否有新版本` |
| 安装/更新工具 | `运行工具安装：把上游工具 vendor 到本地` |
| 理论速查 | `Bob 的确定性方法论是什么？关键术语有哪些？` |
| 项目体检 | `以项目架构师身份做一次维护检查：结构一致性+文档健康度，出报告` |

**完整速查表**：[docs/DOCUMENTATION_MAP.md](docs/DOCUMENTATION_MAP.md)

## 快速开始

```bash
# 1. 安装上游工具（vendor 模式，不 fork）
tooling/bin/install-tools.sh

# 2. 生成一个新项目（问答式）
tooling/bin/generate-project.sh

# 3. 检查 Bob 上游仓库是否有更新
scripts/upstream-sync.sh
```

## 目录结构（概览）

```
clean-code-gauntlet/
├── README.md / AGENTS.md / CHANGELOG.md / LICENSE
├── docs/            # 知识层：理论手册、术语表、SOP、上游追踪、ADR
├── tooling/         # 工具层：上游工具卡、安装器、项目生成器
├── templates/       # 新项目模板（宪法/角色/质量关卡）
└── scripts/         # 上游追踪等维护脚本
```

**详细结构**：[docs/DIRECTORY_STRUCTURE.md](docs/DIRECTORY_STRUCTURE.md)

---

## 上游来源（Bob 大叔本人开源）

| 工具 | 仓库 | 用途 |
|------|------|------|
| swarm-forge | github.com/unclebob/swarm-forge | 多 Agent 编排（two/four/six-pack 流水线） |
| crap4clj / crapper | github.com/unclebob/crap4clj · crapper | CRAP 复杂度检查（Clojure / 多语言） |
| clj-mutate / mutator | github.com/unclebob/clj-mutate · mutator | 变异测试（Clojure / 多语言） |
| uml-viewer | github.com/unclebob/uml-viewer | 架构查看器 + 依赖约束可视化 |

**上游版本追踪**：[docs/UPSTREAM_TRACKING.md](docs/UPSTREAM_TRACKING.md)
