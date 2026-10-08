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

# 2. 网络受限环境补丁（可选但推荐）
#    crapper/mutator/dryer 需从 GitHub 下载 tree-sitter 语法包，直连常超时；
#    本补丁改为优先用 PyPI 独立语法包（国内镜像可装）。GitHub 可达的环境可跳过。
#    注意：重跑 install-tools.sh（fetch 覆盖源码）后需重跑本脚本。
tooling/bin/patch-treesitter.sh

# 3. 生成一个新项目（问答式）
tooling/bin/generate-project.sh

# 4. 在生成项目内一键质检（六维度：CRAP/变异/覆盖率/架构/DRY）
cd generated/<your-project>
../../tooling/bin/quality-check.sh --with-dry --equiv-ok

# 5. 检查 Bob 上游仓库是否有更新
scripts/upstream-sync.sh
```

## 目录结构（概览）

```
clean-code-gauntlet/
├── README.md / AGENTS.md / CHANGELOG.md / LICENSE
├── docs/            # 知识层：理论手册、术语表、SOP、上游追踪、ADR
├── tooling/         # 工具层：上游工具卡、安装器、项目生成器
├── templates/       # 新项目模板（宪法/角色/质量关卡）
├── examples/        # 四语言示例项目（真装真跑验证过的成品）
└── scripts/         # 上游追踪等维护脚本
```

**示例项目（examples/，四语言全链路真跑通的对照）**：

| 目录 | 语言 | 变异成绩 | 说明 |
|------|------|---------|------|
| examples/demo-python | Python | 94.1%（1 等价） | 购物车 demo + pyproject（crapper 识别 pytest 依赖） |
| examples/demo-go | Go | 89.5%（2 等价） | 购物车 demo + .go-arch-lint.yml（v3 格式） |
| examples/demo-ts | TypeScript | 90.5%（2 等价） | 购物车 demo + vitest LCOV + .dependency-cruiser.cjs |
| examples/demo-rust | Rust | 93.8%（1 等价） | 购物车 demo + Cargo.toml/lib.rs/architecture.json |

每份示例含：README（踩坑记录）、EQUIVALENT-MUTANTS.md（等价变异体豁免清单）、quality-gates/、`.github/workflows/quality-gates.yml`（可在独立仓库触发）。运行产物（node_modules/coverage/.metrics/target）不入库。

**端到端实战示例**：`generated/csv2md/`（TS，CSV→Markdown 表格）——由生成器生成、六维度全 PASS（变异 21/21 100% 无等价）、已推 GitHub（[byte886/csv2md](https://github.com/byte886/csv2md)），其自带 CI 在独立仓库实测全绿。

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

**理论一手来源（访谈原稿）**：Bob 本人 2026-08-19 完整访谈《Software Fundamentals in the Age of AI》（56:39）的中文整理稿与英文逐字稿，存档于 [docs/reference/](docs/reference/)——理论层表述均以该原稿为准。
