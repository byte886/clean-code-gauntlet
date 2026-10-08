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
- **理论一手来源入库（方案 A）**：新增 `docs/reference/`——Bob 本人完整访谈《Software Fundamentals in the Age of AI》（Matt Pocock 频道，56:39，2026-08-19）的中文整理稿 + 英文逐字稿（YouTube 自动字幕清洗稿）。该访谈即抖音「大小飞」16 分钟中文剪辑版的原始来源。
- THEORY.md 全面校准（标注 `〔原稿〕`）：① 修正变异测试耗时口径（原稿："agent 30 秒跑完"而非"30 分钟完成"）；② 修正速度优势口径（单 agent 比人快 3–5 倍、流水线 4–5 倍）；③ 补全 QA Agent 职责原稿表述（QA 程序→可执行脚本→端到端操作 UI→确定性通过/失败）；④ 补全 §4"放弃 spec"（盖房子比喻、Agent 爱写计划原文）、§5 人的位置（轻量 spot check、不把 TDD 强加给 agent）、§7 新生代忠告重构为原稿五条+学徒制模型、§8 结语出处修正（Bob 自称记不清出处，普遍认为是 Dijkstra 名言）。
- TERMS.md 校准：CRAP 阈值（人 ≤4、agent 6 可能 8）、TDD"拐杖"说法、来源标注指向 reference/。
- README.md / DOCUMENTATION_MAP.md 登记新资料。

### 变更
- 初始版本 0.1.0（2026-10-08）：仓库创建。形态=**工具型知识库**（ADR-001）：Bob 确定性质量方法论（CRAP/变异测试/架构约束/多 Agent 流水线）的**理论手册 + 可装配工具层 + 上游追踪机制**三合一。
- 治理壳（参考 accounting-kb 模式）：README 边界表、AGENTS.md（AI 操作手册：vendor 模式/上游追踪/生成器纪律）、CHANGELOG、LICENSE（MIT）、.gitignore、docs 分层（THEORY/TERMS/WORKFLOW/UPSTREAM_TRACKING/DOCUMENTATION_MAP/DIRECTORY_STRUCTURE/ADR）。
- 工具层（参考 swarm-forge 模式）：6 张上游工具卡（swarm-forge/crap4clj/crapper/clj-mutate/mutator/uml-viewer，含 2026-10-08 抓取版本快照）、`install-tools.sh`（vendor 安装器）、`generate-project.sh`（问答式项目生成器：六角色 prompts + 三层宪法 + 质量关卡配置 + 文档骨架）。
- 上游追踪：`scripts/upstream-sync.sh`（GitHub API 比对默认分支最新 commit sha → 版本卡/基线/CHANGELOG 更新）。
- 基线：6 个上游仓库默认分支 2026-10-08 状态已记入 `docs/UPSTREAM_TRACKING.md`（swarm-forge f4f5fbc / crap4clj e90be2e / crapper 9f1bead / clj-mutate cea397d / mutator c57f038 / uml-viewer f65dafe）。
- 脚本兼容性（macOS 自带 bash 3.2）：修复 `${var,,}` 语法不支持（WITH_CI 判断改 case 全量匹配）、`$var` 后紧跟全角字符被误解析为变量名（全部改 `${var}` 大括号形式）、sed 匹配带 `- ` 前缀的版本卡行（`^[- ]*`）。三个脚本均实跑验证通过。
