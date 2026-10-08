# 变更日志

> **文档类型**：Active（过程记录）
> **更新频率**：每次重要变更后
> **维护者**：AI自动维护
> **读者**：AI代理+人类

> 本文档记录项目的所有重要变更，遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式。

### 变更
- **落地 3-Rust（Rust 全链路真跑通，完成；四语言落地全量收尾）**：Rust demo（examples/demo-rust 入库）六维度全 PASS（CRAP CC≤5/CRAP≤5、变异 93.8% 15 杀 1 活=等价、覆盖率 100%、cargo archtest 0 违规、dryer 0 候选）。**Rust 特有坑实测修正并回流**：① macOS Homebrew rust 无 llvm-tools-preview 组件（cargo-llvm-cov 报 failed to find llvm-tools-preview，rustup component 对 Homebrew rust 无效）→ quality-check.sh 对 rust 自动探测 brew llvm（keg-only）导出 LLVM_COV/LLVM_PROFDATA，crapper/llvm-cov 子进程继承，GitHub Actions ubuntu 镜像自带组件无需处理；② 生成器 Rust 骨架补 Cargo.toml（库 crate）/src/lib.rs（模块入口占位）/architecture.json（cargo-archtest-cli 配置）；③ patch-treesitter.sh 补 tree-sitter-rust；④ 本机 cargo 已配 USTC 镜像，工具安装无网络问题。**至此 Python/Go/TS/Rust 四语言全链路真装真跑，落地 3 全量完成**；examples 四语言对照齐（demo-python/go/ts/rust），运行产物统一 gitignore；CI 实测覆盖 Go（仓库根 workflow），TS/Rust 命令口径本地全 PASS。
- **落地 3-TS（TypeScript 全链路真跑通，完成）+ examples/demo-python 入库**：TS demo（examples/demo-ts 入库）六维度全 PASS（CRAP CC≤5/CRAP≤5、变异 90.5% 19 杀 2 活=等价、覆盖率 100%、dependency-cruiser 0 违规、dryer 0 候选）。**TS 特有坑实测修正并全部回流**：① 测试函数名与 vitest 全局 describe 冲突→改名 describeAmount；② c8 对 vitest 无效（crapper 源码注释）→ 映射表 TS 覆盖率命令改 `npx vitest run --coverage`；③ vitest 必须显式输出 LCOV（reporter: ["text","lcov"]），否则 crapper 读不到覆盖率→mutator 假 PASS；④ ESM 项目依赖巡航配置须 .cjs（.js 被当 ESM 报错且 exit 0=假 PASS）→ architecture_config 改 .dependency-cruiser.cjs；⑤ tree-sitter-typescript 0.23.x 旧 API（language_typescript() 非 language()）→ patch-treesitter.sh 特判已入，语法包补 tree-sitter-typescript/javascript。**生成器改进**：TS 骨架自动生成 package.json/tsconfig.json/vitest.config.ts（LCOV+thresholds）/.dependency-cruiser.cjs。**examples/demo-python 入库**：Python demo（唯一跑通 Python 全链路成品）收进 examples/，与 Go/TS 三语言对照；examples 运行产物统一 gitignore（node_modules/coverage/.metrics/target）。ROADMAP 决策记录落档。
- **落地 3-Go + GitHub Actions 实测（完成）**：Go demo（examples/demo-go 入库）六维度全 PASS（CRAP CC≤5/CRAP≤5、变异 89.5% 剩 2 等价、覆盖率 100%、go-arch-lint check OK、dry4go 0 候选）。实测修正：① Go 测试须同包 src/；② go-arch-lint v1.19.0 配置 v3 格式 + check 子命令，Go 1.22 可装（推翻"需 1.25+"）；③ GOPATH/bin 不在 PATH → 映射表命令改 `$(go env GOPATH)/bin/` 完整路径；④ 生成器 ci.yml 移动到 `.github/workflows/`（GitHub Actions 标准位置）；⑤ CI 内联 vendor 克隆五 job 全绿（CRAP/变异/覆盖率/架构/DRY），修复 GitHub Actions `bash -e` 下 mutator 退出码 3 豁免失效（set +e 包住调用，模板+examples+自测 workflow 三处同步）；patch-treesitter.sh 支持 tree-sitter-go；examples/demo-go 运行产物（.metrics/target）加 gitignore 不入库。
- **落地 3（实战 demo 全链路验证与回流，完成）**：生成器造 Python 最小业务项目 demo-cart/demo-gen，`generate → install → 四件套+DRY 质检` 真跑通。**实测修正三处**：① crapper/mutator 无 PyPI 包（pipx 安装无效）→ 4 张映射表 `*_install/*_cmd` 全部改为 vendor 模式（install-tools.sh + patch-treesitter.sh + `<GAUNTLET_DIR>/tooling/vendor/...` 命令），install-tools.sh 补 dryer 进 REPOS；② crapper 检测 pytest 需项目根有 pytest.ini/conftest.py 或配置含 "pytest" → 生成器 Python 骨架自动写入 pyproject.toml（pytest 声明 + coverage + import-linter 契约，含 include_external_packages=true）；③ 三工具依赖 tree_sitter_language_pack 从 GitHub 下载语法包（国内直连超时，URL 暴露 xberg-io releases）→ 新增 `tooling/bin/patch-treesitter.sh`：patch 各工具 treesitter.py 为独立语法包优先（PyPI 镜像）+ 独立包装进各 .venv（mutator 另装 pytest/coverage，因其自用 .venv 跑测试）。**机制新增**：变异等价变异体人工核验豁免——EQUIVALENT-MUTANTS.md 清单 + quality-check.sh `--equiv-ok`（mutator 退出码 3=有存活，核验清单存在时豁免）；demo 实测 CRAP 全过（CC≤5/CRAP≤5）、覆盖率 100%、变异 94.1%（16 杀 1 活=等价）、架构 2 契约 KEPT、DRY 0 候选。ci.yml 模板改为 CI 内联 vendor 克隆（GitHub 环境可直连，无需本地 install-tools）。ROADMAP 决策记录落档。
- **落地 4（项目裁剪讨论）四项决策落地（完成）**：① 4 张 tools/<语言>.yaml 补"可选工具清单"段（每语言社区备选按需选用，主命令不变）：TS→eslint-plugin-complexity/nyc/Stryker/archlint，Go→gocyclo/go-coverprofile/arch-go/dryer，Rust→cargo-tarpaulin/cargo-mutants/cargo-modules，Python→radon/pytest-cov/mutmut/pydeps；② gates.yaml 每维度加 `when` 触发时机四档（commit/merge/optional/on-demand）+ 阈值默认值声明（Bob 建议：人 ≤4 / agent 6~8、覆盖率底线 ≥80%，使用中可调）；③ quality-check.sh 新增 `--stage commit|merge`（commit=CRAP+覆盖率，merge=四件套+可选 DRY，默认 merge；非法值报错），实测三语言 --list 与过滤逻辑全过；④ ROADMAP 决策记录追加四条决策（工具齐全+可选 / 关卡按成本裁剪 / 阈值默认建议值 / 多 Agent 流水线判为有价值 on-demand）。
- **P3 验收流水线规格校准（完成）**：核验 unclebob/Acceptance-Pipeline-Specification（190★）README 与四份规格清单（parser/ir-dry-checker/acceptance-generator/mutator）；QA.prompt 补"验收流水线（对齐 APS 规格）"一节——正常验收链（feature→JSON IR→可选 IR-DRY→验收入口→runner）与验收变异链（基础 IR→复用入口→Gherkin 变异→runner adapter→killed/survived/error）+ 步骤文本 DRY 检查（duplicate-in-scenario/near-duplicate/possible-synonym）。
- **P4 实验数据佐证阈值（完成）**：核验 unclebob/negative-test-experiment 三份实验文档（abstract/conclusion/summary，8 次独立 Hunt the Wumpus：测试纪律×CRAP）；THEORY.md §3.1 补 CRAP 实验证据（CRAP-on=拆 CC≤3+补测试；买覆盖率/花可读性/不改善设计；C²+C 无覆盖率不可用；331-396 行→478-603 行膨胀）、§3.2 补变异实验证据（operator 第二套测试 9-63 examples/55-119 sites；等价变异体 `1→0` no-op 案例；验收 25/25 全过对套件质量无感知）；TERMS.md 新增"等价变异体"条目。**至此 P1-P5 全部完成。**
> 版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [未发布]

### 变更
- **P5 一键质检脚本 quality-check.sh（完成）**：读 tools/<语言>.yaml 自动拼装四件套命令 + 阈值判定（命令退出码 = 维度 PASS/FAIL）；支持 `--list` 预览、`--with-dry` 可选 DRY 维度、语言自动推断（命令行参数 > 项目目录映射表 > 模板）；实测三语言 + 项目内自动推断验证通过（修复 bash 3.2 全角字符变量名坑）。
- **P2 DRY 维度落地（完成，更正重要判断）**：核验官方 README 确认 **dryer 为多语言版**（Clojure/Java/Go/TypeScript/Rust/Python 全覆盖，Jaccard 结构指纹 + --threshold 0.82/--edn/--min-lines），**推翻此前"TS/Rust 无 Bob DRY 工具"的结论**；dry4go（Go 专用，--json）作备选。4 张 tools/<语言>.yaml 写入 dry_tool/dry_install/dry_cmd，gates.yaml 可选维度同步。
- **P1 解耦重构实施完成（用户决策落地）**：quality-gates 从"绑定 Bob 工具"重构为两层结构——`gates.yaml`（维度+阈值声明，语言无关）+ `tools/{typescript,go,rust,python}.yaml`（每语言：<维度>_tool/_install/_cmd + architecture_config + optional 增强）；`ci.yml` 改为占位符模板，命令由生成器按语言注入；`generate-project.sh` 语言菜单收敛为 TypeScript/Go/Rust/Python（去掉 clojure/java），工具命令改为从映射表读取（get_yaml，bash 3.2 兼容）、生成后只保留当前语言映射表。实测 TS/Rust 两个 demo 生成验证通过（无残留占位符）。
- **P1 Rust 依赖工具调研完成**：主选 **cargo-archtest-cli**（0.2.6，2026-09-22，Rust 原生 cargo 子命令：architecture.json 声明分层访问规则 MayOnlyAccess/MayNotAccess/MayNotBeAccessedBy/MayOnlyBeAccessedBy + 循环检测 + 外部 crate 白黑名单 + Subdomain 域内规则，可集成 rust test）；备选 cargo-modules（可视化 + `--acyclic` 循环检测 + orphans）。纠正此前"Rust 无分层约束工具"的判断。
- **工具-语言解耦原则（用户决策）**：质量关卡只声明"查什么维度+阈值"，工具按语言延迟注入——ROADMAP 新增该原则，P1 重构为"gates.yaml（维度/阈值）+ tools/<语言>.yaml（工具映射表）+ 生成器注入"，P2 的 DRY 维度进映射表，P5 的 quality-check.sh 改为读映射表自动拼装命令。
- **目标语言约束确认（用户明确）**：TypeScript / Go / Rust / Python，不使用 Clojure / Java。ROADMAP 按约束调整：P1 从"补收 Bob dependency-checker"改为"各目标语言通用依赖工具补位（TS→dependency-cruiser、Python→import-linter、Go/Rust 待调研）"；P2 聚焦 dry4go/dryer；P5 并入生成器语言清单收敛（去掉 clojure/java）；上游 Clojure 工具（crap4clj/clj-mutate/swarm-forge/uml-viewer）降级为参考实现。
- **新增 docs/ROADMAP.md（改进路线图）**：对 Bob 全部 100 个公开仓库全量盘点后登记 5 项改进（P1 补收 dependency-checker 架构依赖专职工具 / P2 评估 DRY 检查家族 dry4clj·dry4go·dry4java·dryer 作潜在第五件套 / P3 参考 Acceptance-Pipeline-Specification 校准模板 / P4 吸收 negative-test-experiment 实验数据佐证 CRAP 阈值 / P5 一键质检脚本 quality-check.sh），并列明排除项（crap4java 等已被多语言版覆盖、arch-view 是 uml-viewer 前身、教学/游戏仓库非工具）。
- **理论一手来源入库（方案 A）**：新增 `docs/reference/`——Bob 本人完整访谈《Software Fundamentals in the Age of AI》（Matt Pocock 频道，56:39，2026-08-19）的中文整理稿 + 英文逐字稿（YouTube 自动字幕清洗稿）。该访谈即抖音「大小飞」16 分钟中文剪辑版的原始来源。
- THEORY.md 全面校准（标注 `〔原稿〕`）：① 修正变异测试耗时口径（原稿："agent 30 秒跑完"而非"30 分钟完成"）；② 修正速度优势口径（单 agent 比人快 3–5 倍、流水线 4–5 倍）；③ 补全 QA Agent 职责原稿表述（QA 程序→可执行脚本→端到端操作 UI→确定性通过/失败）；④ 补全 §4"放弃 spec"（盖房子比喻、Agent 爱写计划原文）、§5 人的位置（轻量 spot check、不把 TDD 强加给 agent）、§7 新生代忠告重构为原稿五条+学徒制模型、§8 结语出处修正（Bob 自称记不清出处，普遍认为是 Dijkstra 名言）。
- TERMS.md 校准：CRAP 阈值（人 ≤4、agent 6 可能 8）、TDD"拐杖"说法、来源标注指向 reference/。
- README.md / DOCUMENTATION_MAP.md 登记新资料。
- **追加吸收 2 场关联访谈**（同批次下载，未整理中文稿，仅字幕存档）：①《There's A Pattern To Follow》（u85ZrRfZDyE，CTO 播客，58,302 字）——金句"敏捷的目的就是摧毁希望"原始出处；②《当 AI 能写代码时怎样才算好工程师》（rNdfQ6mRXAQ，Product Engineer 播客，29,158 字）——依赖约束工具/确定性工具主题，与仓库同题。均存 `docs/reference/`，UPSTREAM_TRACKING 理论来源表已登记。

### 变更
- 初始版本 0.1.0（2026-10-08）：仓库创建。形态=**工具型知识库**（ADR-001）：Bob 确定性质量方法论（CRAP/变异测试/架构约束/多 Agent 流水线）的**理论手册 + 可装配工具层 + 上游追踪机制**三合一。
- 治理壳（参考 accounting-kb 模式）：README 边界表、AGENTS.md（AI 操作手册：vendor 模式/上游追踪/生成器纪律）、CHANGELOG、LICENSE（MIT）、.gitignore、docs 分层（THEORY/TERMS/WORKFLOW/UPSTREAM_TRACKING/DOCUMENTATION_MAP/DIRECTORY_STRUCTURE/ADR）。
- 工具层（参考 swarm-forge 模式）：6 张上游工具卡（swarm-forge/crap4clj/crapper/clj-mutate/mutator/uml-viewer，含 2026-10-08 抓取版本快照）、`install-tools.sh`（vendor 安装器）、`generate-project.sh`（问答式项目生成器：六角色 prompts + 三层宪法 + 质量关卡配置 + 文档骨架）。
- 上游追踪：`scripts/upstream-sync.sh`（GitHub API 比对默认分支最新 commit sha → 版本卡/基线/CHANGELOG 更新）。
- 基线：6 个上游仓库默认分支 2026-10-08 状态已记入 `docs/UPSTREAM_TRACKING.md`（swarm-forge f4f5fbc / crap4clj e90be2e / crapper 9f1bead / clj-mutate cea397d / mutator c57f038 / uml-viewer f65dafe）。
- 脚本兼容性（macOS 自带 bash 3.2）：修复 `${var,,}` 语法不支持（WITH_CI 判断改 case 全量匹配）、`$var` 后紧跟全角字符被误解析为变量名（全部改 `${var}` 大括号形式）、sed 匹配带 `- ` 前缀的版本卡行（`^[- ]*`）。三个脚本均实跑验证通过。

### 变更
- **上游变更机制实测（scripts/upstream-sync.sh 全路径验证）**：① 无变更路径——6 仓真实 API 核对全部"已是最新"；② 模拟变更路径——篡改 mutator 版本卡 sha 后重跑，正确检测 `★ 有变更` 并自动回写真实 latest_sha/updated_at，输出决策流程提示（更新 UPSTREAM_TRACKING → CHANGELOG → 必要时同步 templates）。**补齐缺口**：upstream-sync 仓库清单从 6 仓补到 7 仓（新增 dryer，与 install-tools.sh 对齐），建立 dryer 基线版本卡（66ff6d2）。机制结论：迭代更新机制可用；真实上游变更时可人工评估变更内容决定是否同步模板。

### 变更
- **TS/Rust GitHub Actions 实测完成（三语言 11 job 全绿）**：仓库根 workflow（examples-demo-quality-gates）扩展 ts-*/rust-* 组（CRAP/变异/覆盖率/架构），复用 examples/demo-ts 与 demo-rust 六维度命令；Rust coverage job 补 `rustup component add llvm-tools-preview`。修复：① Go job 工具路径 `../.$RUNNER_TEMP` 拼接 bug（绝对路径直接引用）；② TS job 安装依赖步骤漏 cd。实测：ts-mutation 38s、rust-mutation 1m47s，11 job 全部 ✓。
- **小收尾**：README 补 examples 四语言示例对照表与端到端实战项目（generated/csv2md → byte886/csv2md）说明；generated/ 旧 demo 清理（demo-cart/demo-gen/demo-go 已被 examples 吸收）。

### 变更
- **Python CI 实测完成（四语言 CI 全绿收尾）**：仓库根 workflow（examples-demo-quality-gates）加 py-* 组（CRAP/变异/覆盖率/架构），15 job 全绿（py-mutation 25s）。修正：crapper 对 Python 用系统 python3 跑 pytest/coverage，模板 python.yaml 的 `crap_ci_cmd`（`pip install pytest coverage && crapper`）与 `coverage_install`（`pip install pytest coverage`）补齐；examples/demo-python workflow 同步。至此四语言本地六维度 + CI 双通道全部实测通过。
