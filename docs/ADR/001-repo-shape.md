# ADR-001：仓库形态决策（工具型知识库）

> **文档类型**：Decision（架构决策记录）
> **日期**：2026-10-08
> **状态**：已采纳（用户确认）

---

## 背景

用户需要为 Bob 大叔（Robert C. Martin）的"确定性 AI 代码质量方法论"（CRAP/变异测试/架构约束/多 Agent 流水线）建立一个 GitHub 仓库，要求：
1. 后续用这套理论开发时，能当**工具**生成新的开发项目；
2. 作者/理论有变更时，仓库有**迭代更新机制**；
3. 参考桌面 `accounting-kb`（用户既有知识库治理模式）与 Bob 本人仓库（swarm-forge 等）的风格。

## 候选方案

| 方案 | 形态 | 优点 | 缺点 |
|------|------|------|------|
| A | 纯知识库（accounting-kb 治理壳） | 维护简单、AI 友好 | 不能生成新项目，达不到"当工具用"目标 |
| B | 纯工具脚手架（复刻 Bob 装配器） | 能生成项目 | 与 Bob 仓库功能重叠、无知识沉淀、迭代追踪混乱 |
| C | **工具型知识库**（Bob 装配哲学做工具核 + accounting-kb 治理壳） | 既能生成项目，又能沉淀知识、追踪上游 | 结构稍复杂、初期工作量略大 |

## 决策

**采纳方案 C**，仓库命名 `clean-code-gauntlet`（Bob 自用词 Gauntlet"测试墙"，致敬来源且好搜）。用户已确认（2026-10-08）。

## 关键设计

1. **双层结构**：`docs/`（知识层：THEORY/TERMS/WORKFLOW/UPSTREAM_TRACKING/ADR）+ `tooling/`（工具层：vendor 上游卡/安装器/生成器）+ `templates/`（模板层）+ `scripts/`（上游追踪）。
2. **vendor 而非 fork**：上游工具克隆进 `tooling/vendor/`（gitignored），版本记入版本卡与基线；不 fork、不复制源码入库，避免被上游强绑定（借鉴 accounting-kb 对 okf_validate.py 的 vendor 先例）。
3. **生成器**：`generate-project.sh` 问答式生成新项目骨架（六角色 prompts + 三层宪法 + 质量关卡配置 + 文档骨架），产物默认落 `./generated/`。
4. **上游追踪**：`scripts/upstream-sync.sh` 经 GitHub API 比对默认分支 commit sha，变更时更新版本卡/基线/CHANGELOG，并评估是否影响模板与生成器。
5. **治理壳**：README 边界表、AGENTS.md（AI 操作手册）、CHANGELOG、docs 分层、ADR——照 accounting-kb 模式，保证任何 AI 可接手维护。

## 影响

- 初始化工作量集中在模板与生成器的编写；
- 长期维护负担：上游变更响应 + 生成器/模板同步（已有脚本支撑，属轻量）。
