# 变更日志

> **文档类型**：Active（过程记录）
> **更新频率**：每次重要变更后
> **维护者**：AI自动维护
> **读者**：AI代理+人类

> 本文档记录项目的所有重要变更，遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式。
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
