# 改进路线图（ROADMAP）

> **文档类型**：Active（过程记录 — 待办改进清单）
> **更新频率**：每次调研/用户讨论后
> **维护者**：AI自动维护 + 用户审核
> **读者**：AI代理（执行改进时）和人类

> 本文档登记"已发现、待执行/待决策"的改进项。执行时遵循 AGENTS.md 的变更纪律（改模板/生成器/理论时同步 CHANGELOG）。

---

## 目标语言约束（2026-10-08 用户明确）

- **目标语言**：TypeScript / Go / Rust / Python。
- **不使用**：Clojure / Java（Bob 的 Clojure 专用工具、Java 生态工具均不进入实际项目）。

## 工具-语言解耦原则（2026-10-08 用户决策）

**质量关卡（Quality Gates）只声明"查什么维度 + 阈值"，不锁定"用哪个工具查"；具体工具在生成项目时按语言注入（延迟绑定）。**

- 结构：
  - `quality-gates/gates.yaml`（声明式）：检查维度清单（复杂度/CRAP、变异、架构依赖、DRY）+ 阈值（CRAP<30、CC 6~8、存活变异=0…），与语言无关；
  - `quality-gates/tools/<language>.yaml`（工具映射表）：每种语言 → 各维度的实际工具（命令、安装方式、CI 片段）；
  - `generate-project.sh`：选语言后读映射表，把该语言工具注入 `ci.yml` 与 `quality-check.sh`。
- 收益：① 流程不被任何单一作者的工具绑架；② 新语言只需加一张映射表；③ Bob 的 Clojure 工具彻底退居"参考实现"。
- 对上游基线的含义：
  - **进映射表（核心可用）**：crapper / mutator（多语言版，覆盖全部 4 种目标语言）；
  - **退居参考**：crap4clj / clj-mutate / swarm-forge / uml-viewer（Clojure 专用/平台）——版本卡与文档保留，不要求本机运行；
  - **补位**：依赖约束/DRY 维度由各语言第三方工具进映射表（见 P1/P2）。

## 背景

2026-10-08 对 Bob（unclebob）GitHub 全部 100 个公开仓库做了全量盘点，对照本仓库现有 6 个上游基线（swarm-forge / crap4clj / crapper / clj-mutate / mutator / uml-viewer），识别出以下有增量价值的候选。

## 改进项清单

### P1：质量关卡解耦重构 + 依赖工具映射表（✅ 已完成）
- **目标**：把 quality-gates 从"绑定 Bob 工具"重构为"gates.yaml 声明维度 + tools/<语言>.yaml 映射表"。
- **依赖维度映射（已核验）**：
  - TypeScript → dependency-cruiser（`.dependency-cruiser.js` + `depcruise --validate`）；可选增强 archlint（Rust 实现的 TS 架构探测器，28+ detectors）
  - Python → import-linter（已核验：pyproject.toml 契约配置 + `lint-imports` 命令）
  - Go → **go-arch-lint**（主选，已核验官方 README：`.go-arch-lint.yml` components/mayDependOn + `go-arch-lint graph`；Go 1.25+）；备选 arch-go（规则更宽，可作 go test 集成）
  - Rust → **cargo-archtest-cli**（主选，已核验 docs.rs 0.2.6：`architecture.json` 声明 layer_names + access_rules，支持 MayOnlyAccess/MayNotAccess/MayNotBeAccessedBy/MayOnlyBeAccessedBy + 循环检测（NoLayerCyclicDependencies）+ 外部 crate 白黑名单（Available/Restricted）+ Subdomain 域内规则；可作 cargo 子命令 `cargo archtest` 或 dev-dependency 集成 rust test）；备选 cargo-modules（可视化 + `dependencies --acyclic` 循环检测 + orphans）
- **实施（2026-10-08）**：① `templates/project/quality-gates/gates.yaml`（维度+阈值声明，语言无关）；② `templates/project/quality-gates/tools/{typescript,go,rust,python}.yaml`（每语言：<维度>_tool/_install/_cmd + architecture_config + optional 增强）；③ `ci.yml` 改为占位符模板（{{CRAP_CMD}} 等由生成器注入）；④ `tooling/bin/generate-project.sh` 语言菜单收敛为 TypeScript/Go/Rust/Python，工具命令从 tools/<语言>.yaml 读取（get_yaml，bash 3.2 兼容），注入 install+cmd 占位符，生成后只保留当前语言映射表；⑤ 实测 TS/Rust 两个 demo 生成验证通过（无残留占位符）。

### P2：DRY 维度进映射表（按语言评估）
- **Bob 可用**：dry4go（Go，25★）/ dryer（Python，19★）。
- **待补**：TypeScript / Rust 无 Bob 版，评估第三方（如 jscpd 等）或暂缓该维度。
- **动作**：验证 dry4go / dryer 命令与输出格式 → 写入 tools/ 映射表 → 决定 TS/Rust 是否单独调研。

### P3：参考 Acceptance-Pipeline-Specification 校准模板
- **仓库**：unclebob/Acceptance-Pipeline-Specification（Go，190★）——可移植验收流水线规格。
- **理由**：Bob 把"验收流水线"做成可移植规格，与本仓库 templates/（角色/宪法/质量关卡）同题，可校准我们的模板结构与流程描述。
- **动作**：拉取规格文档，对照 templates/project/ 逐项比对，差异写进本清单或直接修订。

### P4：吸收 negative-test-experiment 数据佐证阈值
- **仓库**：unclebob/negative-test-experiment（Clojure，19★）——"8 次独立 Hunt the Wumpus 实验：测试纪律 × CRAP"。
- **理由**：THEORY.md 的 CRAP 阈值（人 ≤4 / agent 6~8、≥30 危险）有 Bob 原话依据；该实验仓库提供可追溯的实验数据，可增强论证。
- **动作**：读实验 README/数据，将可用证据并入 THEORY.md 并标注来源。

### P5：一键质检脚本 quality-check.sh + 生成器语言收敛
- **现状**：四件套检查命令分散在生成项目的 quality-gates/ 配置 + ci.yml 中，无"一条命令全检"脚本；generate-project.sh 语言清单**已随 P1 收敛**为 TypeScript/Go/Rust/Python（✅）。
- **动作**：① tooling/bin/ 新增 quality-check.sh，**读 tools/<语言>.yaml 映射表自动拼装各维度命令 + 阈值判定**（剩余项）。

## 明确排除（盘点结论）

| 仓库 | 排除理由 |
|---|---|
| crap4clj / clj-mutate / swarm-forge / uml-viewer | 非目标语言（Clojure），退居参考实现（版本卡保留） |
| crap4java（323★）/ crap4go（35★）/ mutate4java（33★）/ mutate4go（23★） | 已被多语言版 crapper / mutator 覆盖（同作者同算法），收多语言版即可 |
| dependency-checker（8★）/ dry4clj（30★）/ dry4java（15★） | Clojure / Java 专用，非目标语言 |
| arch-view（56★） | uml-viewer 的早期形态，已被覆盖 |
| fitnesse 及其 Slim 家族（rubyslim/springslim/nslim/cslim 等） | 老一代验收测试框架（Wiki 形态），与 Gherkin 路线不同，不属当前方法论 |
| spacewar / missile-command / Pharaoh 等游戏、Advent of Code、Euler、教学示例（videostore/javaargs/HTW 等） | 非质量工具，是教学/演示/娱乐代码 |
| bookwriter（TypeScript，77★） | 写书应用，非质量工具（另：用户可自行评估是否作项目参考） |
| AIR-J（35★）/ WTFisaMonad（82★）/ 其他 Clojure 实验 | 实验性/演讲代码，暂不评估 |

## 决策记录

- 2026-10-08：全量盘点 100 仓，形成本清单；P1-P5 待用户确认执行优先级。
- 2026-10-08：用户明确目标语言 TypeScript/Go/Rust/Python，Clojure/Java 不使用 → 本路线图按约束调整。
- 2026-10-08：用户决策"工具-语言解耦"——质量关卡声明维度+阈值，工具按语言延迟注入（gates.yaml + tools/<语言>.yaml + 生成器注入）；P1/P2/P5 按此原则重构。
- 2026-10-08：P1 Go 依赖工具调研完成（抓取官方 README 核验）：主选 go-arch-lint（.go-arch-lint.yml + mayDependOn + graph），备选 arch-go（go test 集成、规则更宽）；Python 侧确认 import-linter 配置与命令。
- 2026-10-08：P1 Rust 依赖工具调研完成（抓取 docs.rs 0.2.6 核验）：主选 **cargo-archtest-cli**（Rust 原生 cargo 子命令，architecture.json 声明分层访问规则 MayOnlyAccess/MayNotAccess/MayNotBeAccessedBy/MayOnlyBeAccessedBy + 循环检测 + 外部 crate 白黑名单 + Subdomain 域内规则，可作 dev-dependency 集成 rust test）；备选 cargo-modules（可视化 + --acyclic 循环检测 + orphans）。Rust 生态此前被高估"无分层约束工具"，实为存在且活跃（0.2.6 发布于 2026-09-22）。
- 2026-10-08：P1 解耦重构实施完成——gates.yaml + 4 张 tools/<语言>.yaml + ci.yml 占位符模板 + 生成器注入逻辑改造；实测 TS/Rust 两个 demo 生成验证通过（无残留占位符、映射表按语言裁剪）。
