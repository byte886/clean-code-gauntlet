# reference/ — 理论一手来源（访谈原稿）

> **文档类型**：Reference（参考资料 — 一手来源存档）
> **更新频率**：新的一手资料（Bob 访谈/演讲/长文）获取时
> **维护者**：AI自动维护 + 用户审核
> **读者**：人类和AI（核对理论表述、引用 Bob 原话时）

---

## 目录用途

本仓库理论层（`docs/THEORY.md` / `docs/TERMS.md`）的**一手来源存档**。

> 与 `tooling/upstream/`（Bob 的**代码仓库**版本卡）分工：那边追踪工具代码，这里存**理论原稿**（访谈/演讲/文章）。两者共同构成"上游追踪"：代码变了查版本卡，理论变了查这里。

## 材料清单

| 文件 | 内容 | 来源 |
|------|------|------|
| `uncle-bob-ai-interview-notes.md` | 中文整理稿（八章主线 + 原话引用 + 金句表 + 全片 OCR 说明） | Matt Pocock 频道 LIVE 访谈《Software Fundamentals in the Age of AI》（56:39，2026-08-19 上传），由另一豆包任务窗口整理 |
| `software-fundamentals-in-the-age-of-ai-transcript-en.txt` | 英文逐字稿（YouTube 自动字幕清洗稿，42,589 字符，无时间戳） | 同上视频的 `.en-orig` 自动字幕 |
| `there-is-a-pattern-to-follow_[u85ZrRfZDyE]_en.txt` | 英文逐字稿（清洗稿，58,302 字符） | 《There's A Pattern To Follow: An Interview with Robert "Uncle Bob" Martin》——"How Many CTOs Does It Take" 播客（Brad Heftig + Scott 主持）。**本仓库金句表"敏捷的目的就是摧毁希望"的原始出处**；含敏捷起源、模式等观点 |
| `good-engineer-in-ai-era_[rNdfQ6mRXAQ]_en.txt` | 英文逐字稿（清洗稿，29,158 字符） | Product Engineer 播客（productengineers.com）："当 AI 能写代码时怎样才算好工程师，为什么深层技术专长仍重要"。**与仓库同题**：依赖约束工具（模块依赖方向、pass/fail 诊断）、确定性工具 vs 提示词遗忘、Gherkin/QA 测试、打孔卡历史类比 |

**原视频**：
- https://www.youtube.com/watch?v=zcLPGC-tvgk（主访谈，已整理中文稿）
- https://www.youtube.com/watch?v=u85ZrRfZDyE（CTO 播客访谈）
- https://www.youtube.com/watch?v=rNdfQ6mRXAQ（Product Engineer 播客访谈）

**访谈嘉宾**：Robert C. Martin（Uncle Bob）｜**主访谈主持人**：Matt Pocock（TypeScript 教育者）

## 本仓库与此原稿的关系

- 抖音「大小飞」视频（16:17）＝**这场访谈的 16 分钟中文解说剪辑版**；本仓库理论层最初基于该剪辑稿建立，2026-10-08 起用本目录的完整原稿**校准并补全**（见 `docs/THEORY.md` 来源节）。
- 理论文档中标注 `〔原稿〕` 的表述 = 已与 Bob 原话核对；标注 `〔视频〕` = 来自抖音剪辑版口播。

## 校准规则（AGENTS.md §3.2 联动）

1. 理论表述**以本目录原稿为准**；原稿与剪辑稿冲突时，保留原稿说法并可在文档中注明差异。
2. 上游有新访谈/演讲/长文 → 存入本目录 + 更新 `docs/UPSTREAM_TRACKING.md` 的"理论来源"段 + CHANGELOG。
3. 英文逐字稿为 YouTube 自动字幕，可能有识别错误；**引原话时优先用中文整理稿的引文**（已人工对照视频）；另外两场（u85ZrRfZDyE / rNdfQ6mRXAQ）目前只有字幕清洗稿、未出中文稿，引用时标注来源文件名与 ID。
4. 另两场访谈（`there-is-a-pattern-to-follow_*`、`good-engineer-in-ai-era_*`）内容与主访谈互补：涉及敏捷起源、"当 AI 能写代码时工程师价值"等，后续提炼进 THEORY.md 时按本目录为据。
