# 工具层（tooling/）

> **文档类型**：Concept（概念说明 — 工具层说明）
> **更新频率**：工具/版本变更时
> **维护者**：AI自动维护
> **读者**：AI代理和人类（使用工具前）

---

## 是什么

把 Bob 大叔的确定性质量工具**引入本地、可复用**的一层。核心策略是 **vendor 模式**（AGENTS.md §3.1）：上游仓库克隆到 `vendor/`（不入库），引用信息（URL/版本/用途）作为版本卡入库。

## 组成

| 路径 | 作用 |
|------|------|
| `upstream/` | 6 张上游工具版本卡（swarm-forge / crap4clj / crapper / clj-mutate / mutator / uml-viewer） |
| `bin/install-tools.sh` | 一键安装：vendor 克隆全部上游工具 + 优先走官方安装器 |
| `bin/generate-project.sh` | 问答式项目生成器：按 Bob 流水线生成新项目骨架 |
| `vendor/`（gitignored） | 上游克隆缓存（install-tools.sh 产物） |

## 为什么 vendor 而不是直接依赖网络

1. 上游是 Bob 个人项目，**持续迭代、无版本发布**（无 tag/release 常见）——vendor + 版本卡 + 追踪脚本是最稳的引用方式；
2. 本地有缓存，**离线可用**；
3. 上游变更时可 diff 后决定是否跟进，**不被强绑定**。

## 使用

```bash
# 安装/更新上游工具
tooling/bin/install-tools.sh

# 生成新项目
tooling/bin/generate-project.sh
```

## 新增一个上游工具（SOP）

1. 在 `upstream/` 建版本卡（参考现有卡格式）；
2. 在 `docs/UPSTREAM_TRACKING.md` 基线表加一行；
3. `install-tools.sh` 的仓库清单加一项；
4. 若影响生成器（新质量关卡/新角色）→ 同步 templates/ 与 generate-project.sh；
5. CHANGELOG 记一条。
