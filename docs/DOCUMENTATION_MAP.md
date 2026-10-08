# 文档地图（DOCUMENTATION MAP）

> **文档类型**：Reference（参考资料 — 文档索引）
> **更新频率**：每次新增/删除/移动文档时
> **维护者**：AI自动维护
> **读者**：AI代理（快速定位文档）和人类（查找文档时）

> 类似 llms.txt 的作用：文档地图，快速定位。

---

## 快速入口（按场景）

### 首次接触本仓库（冷启动）
1. `README.md` — 项目概览、快速开始
2. `AGENTS.md` — AI 操作手册（核心规则 §3 优先读）
3. `docs/THEORY.md` — 方法论理论手册（必读）
4. `docs/TERMS.md` — 术语表

### 想用这套理论开发（生成项目）
1. `docs/WORKFLOW.md` §3 — 生成项目流程
2. `docs/development/guides/generate-project-sop.md` — 生成器详细 SOP
3. `tooling/bin/generate-project.sh` — 生成器本体

### 想检查/更新上游工具
1. `docs/UPSTREAM_TRACKING.md` — 上游版本基线
2. `scripts/upstream-sync.sh` — 变更检测脚本
3. `tooling/upstream/*.md` — 各上游工具版本卡

### 想理解某个术语/概念
- `docs/TERMS.md` — 术语表（含通俗解释与技术细节）
- `docs/reference/` — 理论一手来源（Bob 访谈原稿 + 英文逐字稿，核对表述时用）

### 想了解仓库为什么长这样
- `docs/ADR/001-repo-shape.md` — 仓库形态决策记录

---

## 全量文档清单

| 文档 | 类型 | 用途 |
|------|------|------|
| README.md | Concept | 项目介绍、快速开始 |
| AGENTS.md | Governance | AI 操作手册（规则） |
| CHANGELOG.md | Active | 变更日志 |
| LICENSE | — | MIT 许可 |
| docs/THEORY.md | Concept | 方法论理论手册 |
| docs/TERMS.md | Reference | 术语表 |
| docs/WORKFLOW.md | Process | 使用流程 |
| docs/UPSTREAM_TRACKING.md | Active | 上游版本基线 |
| docs/reference/README.md | Reference | 理论一手来源目录说明 |
| docs/reference/uncle-bob-ai-interview-notes.md | Reference | Bob 访谈中文整理稿（八章主线，2026-08-19 LIVE） |
| docs/reference/software-fundamentals-in-the-age-of-ai-transcript-en.txt | Reference | 同访谈英文逐字稿（YouTube 自动字幕） |
| docs/reference/there-is-a-pattern-to-follow_[u85ZrRfZDyE]_en.txt | Reference | Bob 访谈英文逐字稿（CTO 播客，"敏捷目的"金句出处） |
| docs/reference/good-engineer-in-ai-era_[rNdfQ6mRXAQ]_en.txt | Reference | Bob 访谈英文逐字稿（Product Engineer 播客，依赖约束主题） |
| docs/DOCUMENTATION_MAP.md | Reference | 本文档 |
| docs/DIRECTORY_STRUCTURE.md | Reference | 目录结构说明 |
| docs/ADR/001-repo-shape.md | Decision | 仓库形态 ADR |
| docs/development/guides/generate-project-sop.md | Process | 生成项目 SOP |
| tooling/README.md | Concept | 工具层说明 |
| tooling/upstream/*.md | Reference | 上游工具版本卡（6 张） |
| templates/README.md | Reference | 模板层说明 |
| tooling/bin/install-tools.sh | Executable | 上游安装器 |
| tooling/bin/generate-project.sh | Executable | 项目生成器 |
| scripts/upstream-sync.sh | Executable | 上游同步脚本 |
