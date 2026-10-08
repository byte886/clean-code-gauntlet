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

### P2：DRY 维度进映射表（✅ 已完成）
- **结论（已核验官方 README）**：**dryer（unclebob，19★）是多语言版**——Clojure/Java/Go/TypeScript/Rust/Python 全支持，一次运行按文件语言自动归一化结构指纹（Jaccard 相似度，`--threshold` 默认 0.82，`--edn`/`--min-lines`/`--min-nodes`），**覆盖全部 4 种目标语言**（更正此前"TS/Rust 无 Bob 版"的判断）；dry4go（25★，Go 专用）作 Go 备选（`dry4go --json .`，按函数/方法 AST 归一化）。
- **实施**：4 张 tools/<语言>.yaml 均写入 `dry_tool/dry_install/dry_cmd`；gates.yaml 可选维度说明更新；quality-check.sh 支持 `--with-dry` 一键跑 DRY。

### P3：参考 Acceptance-Pipeline-Specification 校准模板（✅ 已完成）
- **仓库**：unclebob/Acceptance-Pipeline-Specification（Go，190★）——可移植验收流水线规格。
- **规格要点（已核验 README + 组件清单）**：正常验收运行 = `.feature` → gherkin 解析（JSON IR）→（可选 IR-DRY 检查）→ 验收入口生成 → 项目 runner；验收变异运行 = feature → 基础 IR → 复用入口 → **Gherkin 变异**（只变异示例值，非源码）→ runner adapter → killed/survived/error 报告。含 parser-spec / ir-dry-checker-spec / acceptance-generator / mutator-spec 四份规格；项目专用组件（入口生成器/runtime/step handlers/adapter）由 agent 写。
- **校准动作**：`roles/QA.prompt` 补"验收流水线（对齐 APS 规格）"一节（两条运行链 + 步骤文本 DRY 规范化：duplicate-in-scenario/near-duplicate/possible-synonym + 目的：示例数据真的连到被测应用）。APS 亦可为后续"验收测试进入生成骨架"提供安装流程参考。

### P4：吸收 negative-test-experiment 数据佐证阈值（✅ 已完成）
- **仓库**：unclebob/negative-test-experiment（Clojure，19★）——"8 次独立 Hunt the Wumpus 实验：测试纪律 × CRAP"。
- **已核验数据（experiment-abstract/conclusion/summary）**：4 种测试纪律 × CRAP 强制开关 = 8 棵独立程序树，全部通过 25/25 验收（含零单元测试组）——**验收容易满足、对套件质量无感知**；CRAP-on 只做两件事（拆分高 CC 函数至 CC≤3 + 补测试，None 组凭空造 40 examples/150 assertions），买覆盖率、花可读性、不改善设计；clj-mutate 对冻结程序长出 operator 测试套（9-63 examples/55-119 sites，~0.06-0.09 s），等价变异体实案：`1→0` 打在父 if/cond 行、字面量在子分支 → no-op。
- **动作**：THEORY.md §3.1 补 CRAP 实验证据（含 C²+C 无覆盖率不可用、规模膨胀数据）、§3.2 补变异实验证据（第二套测试、等价变异体案例、验收局限）；TERMS.md 新增"等价变异体"条目。

### P5：一键质检脚本 quality-check.sh + 生成器语言收敛（✅ 已完成）
- **现状**：四件套检查命令分散在生成项目的 quality-gates/ 配置 + ci.yml 中，无"一条命令全检"脚本；generate-project.sh 语言清单**已随 P1 收敛**为 TypeScript/Go/Rust/Python。
- **实施**：① `tooling/bin/quality-check.sh`——读 tools/<语言>.yaml 自动拼装各维度命令 + 阈值判定（命令退出码 = 维度 PASS/FAIL），支持 `--list` 预览、`--with-dry` 可选维度、语言自动推断（命令行参数 > 项目目录映射表 > 模板）；② generate-project.sh 语言收敛（随 P1 完成）。实测三语言 --list + 项目内自动推断验证通过（修复 bash 3.2 全角字符变量名坑 `${LANG_NAME}`）。

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
- 2026-10-08：P2 DRY 调研完成并落地（抓取官方 README 核验）：**dryer 为多语言版**（支持 Go/TypeScript/Rust/Python，Jaccard 结构指纹 + --threshold/--edn/--min-lines），更正此前"TS/Rust 无 Bob DRY 工具"的判断；dry4go 作 Go 专用备选。4 张映射表写入 dry_* 字段。
- 2026-10-08：P5 一键质检脚本 quality-check.sh 完成——读映射表自动拼装四件套命令 + 阈值判定，支持 --list/--with-dry/语言自动推断；实测三语言 + 项目内自动推断验证通过（修复 bash 3.2 全角字符变量名坑）。P2/P5 全部完成，ROADMAP 仅剩 P3（Acceptance-Pipeline-Specification 模板校准）、P4（negative-test-experiment 数据佐证阈值）。
- 2026-10-08：P3 完成（核验 APS 规格 README/四份规格清单）：QA.prompt 补"验收流水线（对齐 APS）"（feature→IR→入口生成→run + Gherkin 变异链 + 步骤文本 DRY 检查四类发现）。
- 2026-10-08：P4 完成（核验 abstract/conclusion/summary 全文数据）：THEORY.md §3.1/§3.2 补 8 次实验证据（CRAP 买覆盖率花可读性不改善设计、C²+C 无覆盖不可用、operator 测试套、等价变异体 no-op 案例、验收对套件质量无感知）；TERMS.md 新增等价变异体条目。**至此 P1-P5 全部完成。**
- 2026-10-08：**落地 4（项目裁剪讨论）四项决策落档**——① 工具齐全+可选：每语言映射表补"可选工具清单"段（社区备选按需选用，主命令不变，quality-check.sh 只跑主命令）；② 关卡按成本裁剪：gates.yaml 每维度加 `when` 四档（commit/merge/optional/on-demand），quality-check.sh 新增 `--stage commit|merge`（commit=CRAP+覆盖率，merge=四件套+可选 DRY）——低成本高收益天天跑、贵的高收益关键时刻跑；③ 阈值默认 Bob 建议值写入配置（人 ≤4 / agent 6~8、覆盖率底线 ≥80%），使用中发现不对再按建议调整；④ 多 Agent 流水线判为有价值（on-demand），用户测试/评估体系时启用。
- 2026-10-08：**落地 3（实战 demo 全链路验证）完成**——生成器造 Python 最小业务项目（demo-cart→demo-gen），`generate → install → 四件套+DRY 质检` 真跑通，暴露并修复只靠配置验证看不到的问题：
  - **实测事实**：CRAP 5 函数 CC≤5/cov 100%/CRAP≤5（阈值 30/8 全过）；变异 17 sites 16 杀 1 活 94.1%（剩 1 个等价变异体 `base > 0`→`>=`，base=0 数学等价，人工核验豁免）；覆盖率 100%；架构 2 契约 KEPT（Layers + Tests do not leak）；DRY 0 候选。
  - **三处修正回流**：① crapper/mutator **不是 PyPI 包**（pipx 无效），正解=克隆仓库跑 `./crapper`/`./mutator`（首跑自动建 .venv，mutator 需 crapper 相邻）→ 4 张映射表 install/cmd 全部 vendor 化 + install-tools.sh 补 dryer；② crapper 的 pytest 检测=项目根有 pytest.ini/conftest.py 或配置文件含 "pytest" 字样 → 生成器 Python 骨架自动写 pyproject.toml（pytest 声明 + coverage + import-linter 契约 + include_external_packages=true，后者为 forbidden 外部模块契约必需）；③ 三工具经 tree_sitter_language_pack 从 GitHub（xberg-io releases）下载语法包，国内直连超时（PackConfig 无源覆盖）→ `tooling/bin/patch-treesitter.sh`：独立语法包优先（PyPI 镜像）+ 装进各 .venv（mutator 自用 .venv 跑 pytest，需另装 pytest/coverage）。
  - **机制新增**：等价变异体人工核验豁免——EQUIVALENT-MUTANTS.md 清单 + quality-check.sh `--equiv-ok`（mutator 退出码 3 豁免）。
  - **已知遗留**：generated/ 是否保留示例待用户拍板；quality-check.sh 的 `--stage commit` 在真实项目验证过 --list 但未跑全维度。
- 2026-10-09：**落地 3-Go（跨语言验证）+ GitHub Actions 实测完成**——
  - **Go demo（examples/demo-go 入库）六维度全 PASS**：CRAP 全过（CC≤5/CRAP≤5，cov 100%）；变异 89.5%（17 杀 15 活 2 = 等价变异体：`base>0`→`>=` 与 `qty<=0`→`<`，人工核验豁免）；覆盖率 100%；架构 go-arch-lint check OK；DRY dry4go 0 候选。
  - **实测修正（跨语言通用性验证）**：① Go 测试须同包 src/ 目录（生成器 test/ 目录分离仅 Python 适用）；② go-arch-lint v1.19.0 配置为 v3 格式（components 为 map + deps.mayDependOn/anyProjectDeps），命令需 `check` 子命令，Go 1.22 可安装运行（推翻调研时"需 Go 1.25+"判断）；③ GOPATH/bin 不在默认 PATH → Go 映射表 architecture/dry 命令改 `$(go env GOPATH)/bin/...` 完整路径（eval 展开，不依赖用户 PATH）；④ dry4go 实测可用（Go DRY 主选保持正确）。
  - **生成器修正**：ci.yml 生成时移动到 `.github/workflows/quality-gates.yml`（GitHub Actions 只识别仓库根 .github/workflows/，原 quality-gates/ 位置不会被 CI 执行）。
  - **CI 实测结论**：仓库根 `.github/workflows/examples-demo-go-quality-gates.yml` 五 job 全绿（CRAP 24s / 变异 25s / 覆盖率 22s / 架构 1m18s / DRY 25s）；CI 内联 vendor 克隆 + 工具安装 + 六维度命令在真实 GitHub Actions（ubuntu-latest）可用。**关键坑**：GitHub Actions 默认 shell 为 `bash -e`（set -e），mutator 退出码 3 时脚本立即终止、豁免分支永不执行 → mutation job 需 `set +e` 包住 mutator 调用再恢复（已修 ci.yml 模板 + examples + 仓库根自测 workflow 三处）。
  - **已知遗留**：TS/Rust 仍未真装真跑；examples/demo-go 的 .github/workflows 在真实独立仓库（项目推到自己仓库根）尚未验证触发。
- 2026-10-09：**落地 3-TS（TypeScript 全链路真跑通，examples/demo-ts 入库）**——
  - **TS demo 六维度全 PASS**：CRAP 全过（CC≤5/CRAP≤5，cov 100%）；变异 90.5%（21 sites 19 杀 2 活 = 等价变异体：`qty<=0`→`<` 与 `base>0`→`>=`，三语言同款边界，人工核验豁免）；覆盖率 100%（vitest v8 + LCOV）；架构 dependency-cruiser 0 违规；DRY dryer 0 候选。
  - **实测修正（TS 特有坑，全部回流）**：① 测试导入函数名与 vitest 全局 `describe` 冲突 → 业务函数改名（describeAmount）；② **c8 对 vitest 无效**（crapper 源码注释：c8 看不到 vitest worker 进程覆盖率）→ TS 覆盖率命令改 `npx vitest run --coverage`（映射表已改）；③ **vitest 必须显式输出 LCOV**（coverage 默认只有 text 报告，crapper 读 target/coverage 或 coverage/**/lcov.info，否则覆盖率 0 → mutator 全 n/a 假 PASS）→ `reporter: ["text","lcov"]`；④ **ESM 项目配置须 .cjs**（package.json "type":"module" 下 .dependency-cruiser.js 被当 ESM 报错，且报错仍 exit 0 → 架构假 PASS）→ 映射表 config 改 `.dependency-cruiser.cjs`；⑤ **tree-sitter-typescript 旧 API**（0.23.x 无 `language()`，须 `language_typescript()`，否则独立语法包 import 失败走 GitHub 下载超时 fallback）→ patch-treesitter.sh 特判已入。
  - **生成器改进**：TS 骨架自动生成 package.json（vitest 脚本）/ tsconfig.json / vitest.config.ts（LCOV + thresholds）/ .dependency-cruiser.cjs（"type":"module" 兼容）。
  - **新增 examples/demo-python 入库**：Python demo（唯一跑通 Python 全链路的成品）收进 examples/，与 Go/TS 形成跨语言三对照。
  - **已知遗留**：Rust 未真装真跑；TS/Go 的 CI 实测只覆盖 Go（仓库根 workflow）；examples/demo-ts 在真实独立仓库触发未验证。
- 2026-10-09：**落地 3-Rust（Rust 全链路真跑通，examples/demo-rust 入库）**——
  - **Rust demo 六维度全 PASS**：CRAP 全过（cov 100%）；变异 93.8%（16 sites 15 杀 1 活 = 等价变异体 `qty<=0`→`<`，与 TS/Go 同款边界，人工核验豁免）；覆盖率 100%（cargo llvm-cov）；架构 cargo archtest 0 违规；DRY dryer 0 候选。
  - **实测修正（Rust 特有坑，全部回流）**：① **macOS Homebrew rust 无 llvm-tools-preview 组件**（cargo-llvm-cov 报 failed to find llvm-tools-preview；rustup component 对 Homebrew rust 无效）→ quality-check.sh 对 rust 自动探测 brew llvm（keg-only 不在 PATH）并导出 LLVM_COV/LLVM_PROFDATA，crapper/llvm-cov 子进程继承；GitHub Actions ubuntu 镜像自带组件无需处理；② **lib.rs 是模块入口**：cargo test 跑 0 个测试通常是 lib.rs 未声明 pub mod <module>（生成器骨架占位，业务接入须写模块声明）；③ 本机 cargo 已配 USTC 镜像（稀疏索引），工具安装无网络问题。
  - **生成器改进**：Rust 骨架自动生成 Cargo.toml（库 crate）/ src/lib.rs（模块入口占位）/ architecture.json（cargo-archtest-cli 配置）。
  - **至此四语言（Python/Go/TS/Rust）全部真装真跑，落地 3 全量完成**；CI 实测覆盖 Go（仓库根 workflow），TS/Rust 的 CI 命令口径经本地全 PASS 验证（ubuntu 环境自带组件/镜像，预期可跑，未在 Actions 上实测）。
  - **已知遗留**：TS/Rust 的 GitHub Actions 实测未跑（可后续加 job）；examples/demo-* 在真实独立仓库触发未验证；generated/ 旧 demo（demo-cart/demo-gen/demo-go）为 gitignore 本地载体。
- 2026-10-09：**端到端实战验证（任务 #19，byte886/csv2md 全绿闭环）**——
  - 用生成器生成真实项目 **csv2md**（TS，CSV→Markdown 表格，12 用例），走完"生成→开发→commit 门→merge 门→推 GitHub（公开）→自带 CI 触发"全流程。
  - 本地六维度全 PASS，**变异 21/21 全杀 100%（无等价变异体）**——四语言 demo 里唯一满分。
  - 推 GitHub 后 CI 首跑 3 连败，实测揪出 **3 个 CI 模板级 bug（全部回流模板/映射表/生成器/examples）**：
    ① **mutation job 必须先跑 crapper**：mutator 覆盖率数据来自 crapper 产物（coverage.load_bundle），不跑则覆盖率空 → 假 FAIL/假 PASS（Go CI 之前"全绿"是豁免掩盖的假 PASS，已同步修复）；② **TS 的 crapper/mutator job 需先 npm install**：crapper 对 TS 用 npm run coverage（vitest），无 node_modules 时覆盖率 0% → CRAP 虚高、mutator 全 uncovered；③ **工具必须 clone 在项目外（$RUNNER_TEMP/gauntlet/）**：clone 在项目内 .gauntlet/ 时 crapper 扫描把工具自身源码当项目一部分，跑工具自带 145 个 pytest（缺 bb/uml）→ exit 2。本机 vendor 在 gauntlet 仓库 tooling/vendor/（天然项目外）所以本地从未暴露。
  - 模板新增 {{CRAP_CI_CMD}} 注入点（含语言测试依赖安装）；映射表加 crap_ci_cmd 字段（TS=npm install && crapper，Go/Python/Rust=crapper）。
- 2026-10-09：**剩余任务 #20（upstream-sync 实测）/ #21（TS/Rust CI job 实测）/ #22（README 收尾）待推进**。
- 2026-10-09：**#21 TS/Rust GitHub Actions 实测完成 + #22 收尾**——
  - 仓库根 workflow 扩展为三语言 11 job（go-*/ts-*/rust-* 各含 CRAP/变异/覆盖率/架构，Go 另有 DRY），**实测全绿**（ts-mutation 38s、rust-mutation 1m47s，含 rustup llvm-tools-preview 组件与 cargo-llvm-cov 编译）。
  - 修复两处：① 原 Go job 工具路径 `../.$RUNNER_TEMP/...` 拼接错误（$RUNNER_TEMP 为绝对路径应直接引用，此前该步可能未真正执行）；② TS job 独立安装依赖步骤漏 cd examples/demo-ts（仓库根无 package.json → ENOENT）。
  - #22：README 补 examples 四语言示例表与端到端实战项目（csv2md）说明；generated/ 旧 demo（demo-cart/demo-gen/demo-go）清理（已被 examples 吸收），保留 csv2md。
  - **至此四步（端到端实战→上游变更实测→TS/Rust CI 实测→小收尾）全部完成**，主目标闭环：生成器可生成新项目、六维度质检四语言真跑通、CI 三语言实测全绿、上游变更可检测迭代。
