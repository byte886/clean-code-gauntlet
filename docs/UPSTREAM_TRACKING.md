# 上游追踪（UPSTREAM TRACKING）

> **文档类型**：Active（过程记录 — 上游版本基线）
> **更新频率**：每次 upstream-sync 后
> **维护者**：AI自动维护（scripts/upstream-sync.sh）
> **读者**：AI代理（判断上游是否变更）和人类

> 本仓库的理论与工具均来自 **Robert C. Martin（Bob 大叔）** 的公开 GitHub 项目。Bob 持续迭代这些工具，因此本仓库建立"版本基线 + 变更检测 + 迭代更新"机制。
> 基线由 `scripts/upstream-sync.sh` 自动比对更新；**初始基线：2026-10-08 抓取**。

---

## 上游仓库基线（2026-10-08 首次 sync 建立）

| 仓库 | 默认分支 | 最新 commit（基线） | 更新于 |
|------|---------|--------------------|--------|
| unclebob/swarm-forge | main | f4f5fbc | 2026-09-07 |
| unclebob/crap4clj | master | e90be2e | 2026-09-17 |
| unclebob/crapper | master | 9f1bead | 2026-10-03 |
| unclebob/clj-mutate | master | cea397d | 2026-09-19 |
| unclebob/mutator | main | c57f038 | 2026-10-03 |
| unclebob/uml-viewer | master | f65dafe | 2026-10-07 |
| unclebob/dryer | main | 66ff6d2 | 2026-10-03 |

> 完整 sha 见各版本卡 `tooling/upstream/*.md`；基线由 `scripts/upstream-sync.sh` 自动比对更新，检测到变更即回写版本卡并提示更新本表。
> 注：crapper 默认分支实测为 **master**（2026-10-08 用 git ls-remote 核实，非 main）。

## 理论来源（一手资料）追踪

| 日期 | 资料 | 说明 | 存档 |
|------|------|------|------|
| 2026-10-08 | Bob 访谈《Software Fundamentals in the Age of AI》（Matt Pocock 频道，56:39，2026-08-19 上传） | 中文整理稿（八章）+ 英文逐字稿；即抖音「大小飞」剪辑版的原始来源 | [docs/reference/](reference/) |
| 2026-10-08 | Bob 访谈《There's A Pattern To Follow》（u85ZrRfZDyE，CTO 播客） | 英文逐字稿（58,302 字）；"敏捷的目的就是摧毁希望"出处 | [docs/reference/](reference/) |
| 2026-10-08 | Bob 访谈《当 AI 能写代码时怎样才算好工程师》（rNdfQ6mRXAQ，Product Engineer 播客） | 英文逐字稿（29,158 字）；依赖约束/确定性工具主题 | [docs/reference/](reference/) |

## 变更日志（上游侧）

| 日期 | 仓库 | 变更 | 本仓库响应 |
|------|------|------|-----------|
| 2026-10-08 | 全部 6 仓 | 首次基线建立（见上表） | — |
| 2026-10-09 | 机制实测 | upstream-sync 两条路径实测：① 无变更→"已是最新"（真实 API 核对 6 仓）；② 模拟变更（篡改 mutator 版本卡 sha 为全 0）→ 正确检测 ★ 并自动回写真实 sha/updated_at，提示决策流程 | 实测通过，无真实上游变更；同日补齐 dryer 跟踪（7 仓全覆盖，基线 66ff6d2） |

## 变更响应规则

1. **工具功能变更**（CRAP/变异/架构相关算法或命令变化）→ 更新 THEORY.md/TERMS.md 对应条目 + templates 质量关卡模板；
2. **流水线结构变更**（swarm-forge 角色/宪法/handoff 变化）→ 更新 THEORY.md §3.4 + templates 角色/宪法模板 + generate-project.sh；
3. **新增工具/仓库**（Bob 开源新的确定性工具）→ 新增 tooling/upstream 版本卡 + 本表 + install-tools.sh；
4. **纯文档/示例变更** → 只记 CHANGELOG，不动模板。

## 与 vendor 的关系

- `tooling/vendor/` 保存上游仓库的本地克隆（gitignored），版本与本表一致；
- 本表是"上游变更检测"的权威基线；vendor 目录是"可用工具"的本地缓存；
- 两者不一致（vendor 比基线新/旧）时以本表为准，运行 install-tools.sh 对齐。
