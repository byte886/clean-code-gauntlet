---
name: clean-code-gauntlet
description: 基于 Bob 大叔（Robert C. Martin）确定性方法论的代码质量验证工具。支持 TypeScript/Go/Rust/Python 四语言，核心能力：新项目骨架生成、一键质量质检（CRAP 复杂度、变异测试、覆盖率、架构约束、DRY 重复检查）、多 Agent 流水线模板、上游工具更新追踪。必须用本技能的场景：要新建高质量代码项目、要给代码（尤其 AI 生成的代码）做确定性质量检查、要验证"AI 写的代码能不能信"。
compatibility: macOS 实测通过；Linux（GitHub Actions ubuntu，四语言 15 job）实测通过；Windows 未适配
---

# clean-code-gauntlet · 确定性代码质量验证工具

> 把 Bob 大叔访谈《Software Fundamentals in the Age of AI》提出的方法论——**多 Agent 流水线 + 确定性质量检查 + 规则代替文字**——变成可复用工具：生成新项目骨架、一键跑质量关卡、追踪上游工具更新。
> 理论一手来源与完整手册见 [`docs/`](docs/)；飞书归档见文末指针。

---

## 一、执行原则（硬规矩，先读）

1. **工具 vendor 必须放在项目外**：本地用本仓库 `tooling/vendor/`；CI 用 `$RUNNER_TEMP/gauntlet/`。放进项目内会被 crapper 当项目源码扫描（会去跑工具自身的测试）。
2. **变异测试必须先跑 crapper**：mutator 的覆盖率数据来自 crapper 产物，顺序不能反（否则假 FAIL / 假 PASS）。
3. **存活变异体 = 0 才放行**；人工核验为**等价变异体**（改了但行为不变，如边界数学等价）的，登记 `EQUIVALENT-MUTANTS.md` 后用 `--equiv-ok` 豁免。
4. **规则代替文字**：质量要求写成可执行的关卡配置（gates.yaml + 工具映射表），不写成靠人自觉的文字说明。

---

## 二、脚本列表

### 工具入口（`tooling/bin/`）

| 脚本 | 用途 |
|---|---|
| `install-tools.sh` | 安装/更新 7 个上游工具（vendor 克隆到 `tooling/vendor/`） |
| `patch-treesitter.sh` | 国内网络补丁：独立 tree-sitter 语法包 + 装进各工具 .venv（install 后必跑） |
| `generate-project.sh` | **问答式生成新项目骨架**（项目名 / 语言 / 流水线档位 / 是否 CI） |
| `quality-check.sh` | **一键质检入口**：`--stage commit`（CRAP+覆盖率）/ `--stage merge`（六维度全量）；`--with-dry`、`--equiv-ok`、`--list` |

### 维护脚本（`scripts/`）

| 脚本 | 用途 |
|---|---|
| `upstream-sync.sh` | 经 GitHub API 比对 7 个 Bob 仓库最新 commit 与本地版本卡，有变更回写并提示决策流程 |

---

## 三、场景 → 服务映射

| 你要做什么 | 用什么 |
|---|---|
| 建一个新代码项目 | `generate-project.sh`（四语言可选，自带质量关卡与 CI） |
| 开发中每次提交前自检 | `quality-check.sh --stage commit` |
| 合并 / 发布前全量质检 | `quality-check.sh --stage merge --with-dry --equiv-ok` |
| 查复杂度 / CRAP 指标 | **crapper**（多语言通用；注意 crap4clj 仅 Clojure 专用，我们不用） |
| 做变异测试 | **mutator**（多语言通用；clj-mutate 仅 Clojure） |
| 查架构 / 依赖约束 | 各语言架构工具：Python `import-linter`、Go `go-arch-lint`、TS `dependency-cruiser`、Rust `cargo-archtest`（uml-viewer 仅做可视化） |
| 查重复代码（DRY） | **dryer**（Bob 多语言版，`--with-dry` 时启用） |
| 检测 Bob 上游工具更新 | `upstream-sync.sh` |
| 了解方法论 / 术语 | [`docs/THEORY.md`](docs/THEORY.md)、[`docs/TERMS.md`](docs/TERMS.md) |

---

## 四、核心流程（5 步）

```bash
# 1. 安装上游工具（首次），再跑国内网络补丁
bash tooling/bin/install-tools.sh
bash tooling/bin/patch-treesitter.sh

# 2. 生成新项目（输入：项目名 / 语言 1=TS 2=Go 3=Rust 4=Python / 流水线 two|four|six-pack / CI y|n）
printf 'my-project\n4\n3\ny\n' | bash tooling/bin/generate-project.sh

# 3. 开发中：每次提交跑 commit 门（CRAP + 覆盖率）
bash tooling/bin/quality-check.sh --stage commit

# 4. 合并 / 发布前：merge 门（CRAP/变异/覆盖率/架构/DRY 全量，等价变异体可豁免）
bash tooling/bin/quality-check.sh --stage merge --with-dry --equiv-ok

# 5. 跟踪上游变更（Bob 仓库更新 → 更新版本卡 → 评估是否同步模板）
bash scripts/upstream-sync.sh
```

生成项目自带 `.github/workflows/quality-gates.yml`，推到 GitHub 后 CI 自动跑六维度（工具内联克隆到 `$RUNNER_TEMP`）。

---

## 五、四语言关键策略（实测结论）

| 语言 | 覆盖率 | 架构 | 关键坑（详见各 examples README） |
|---|---|---|---|
| TypeScript | vitest（须显式输出 LCOV；c8 对 vitest 无效） | dependency-cruiser（ESM 项目配置须 `.cjs`，否则 exit 0 假 PASS） | crapper 用 `npm run coverage`，CI 需先 npm install |
| Go | go test（覆盖率） | go-arch-lint（v3 配置 + `check` 子命令） | 测试须同包；GOPATH/bin 可能不在 PATH |
| Rust | cargo-llvm-cov | cargo-archtest | macOS Homebrew rust 无 llvm-tools-preview，脚本自动探测 brew llvm；CI 需 `rustup component add llvm-tools-preview` |
| Python | coverage.py + pytest | import-linter（契约写在 pyproject.toml `[tool.importlinter]`） | crapper 用系统 python3 跑 pytest，CI 需先 `pip install pytest coverage` |

四语言六维度实测成绩与等价变异体豁免清单见 [`examples/`](examples/)（demo-python / demo-go / demo-ts / demo-rust）。

---

## 六、质量关卡阈值（硬性）

| 维度 | 阈值 |
|---|---|
| 圈复杂度（Cyclomatic Complexity） | ≤ 8 |
| CRAP 指标 | < 30 |
| 覆盖率（核心模块） | ≥ 80% |
| 存活变异体 | 0（等价变异体经人工核验 + 清单豁免） |
| 架构违规 / 循环依赖 | 0 |
| DRY 重复候选 | 0（dryer 阈值默认 0.82） |

阈值依据与调整记录见 [`templates/project/quality-gates/gates.yaml`](templates/project/quality-gates/gates.yaml)。

---

## 七、进阶指针

- **完整理论手册 / 术语表 / SOP**：[`docs/`](docs/)（THEORY、TERMS、ADR、ROADMAP、CHANGELOG）
- **四语言示例项目（真跑通的成品）**：[`examples/`](examples/)
- **端到端实战项目**：`generated/csv2md/`（TS，变异 21/21 全杀；GitHub `byte886/csv2md`）
- **飞书知识库归档**：https://my.feishu.cn/docx/KokddBfUXosMrZxxMWjcFHUpnTh
- **GitHub 仓库**：https://github.com/byte886/clean-code-gauntlet
