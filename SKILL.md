---
name: clean-code-gauntlet
description: 代码项目质量验证工具。基于Bob大叔（《代码整洁之道》作者）的确定性方法论，提供新项目生成、复杂度检查、变异测试、架构约束、多Agent流水线。适用于要建高质量代码项目、要做代码质量检查、要做架构验证时。
compatibility: 有可执行脚本，macOS/Linux可用
---

# clean-code-gauntlet · 代码质量验证工具

> 把Bob大叔的"确定性质量验证"方法论变成可复用工具：生成新项目骨架、自动带上质量关卡、追踪上游工具更新。

---

## 遇到什么问题，用什么

| 你遇到什么问题 | 用什么 |
|---|---|
| 要建一个新的代码项目 | `tooling/bin/generate-project.sh`（问答式生成骨架） |
| 要检查代码复杂度 | `tooling/vendor/crap4clj/`（CRAP复杂度检查） |
| 要做变异测试 | `tooling/vendor/clj-mutate/`（变异测试） |
| 要看架构、检查依赖约束 | `tooling/vendor/uml-viewer/`（架构可视化） |
| 要多Agent流水线开发 | `tooling/vendor/swarm-forge/`（two/four/six-pack流水线） |
| 要了解Bob的方法论 | `docs/THEORY.md`（理论手册） |

---

## 核心概念
- **six-pack流水线**：规格→编码→清理→架构→强化→QA，六个环节每个都有质量关卡
- **CRAP复杂度**：Change Risk Anti-Patterns，衡量代码复杂度和修改风险
- **变异测试**：自动改代码，看测试能不能抓住错误

> 详细说明见 [docs/](docs/)
