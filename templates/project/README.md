# {{PROJECT_NAME}}

> 由 clean-code-gauntlet 生成（2026-10-08）｜流水线：{{PACK_LABEL}}｜语言：{{LANG}}
> 上游方法论：Bob 大叔（Robert C. Martin）确定性 AI 代码质量体系

---

## 快速开始

```bash
# 1. 安装上游工具（vendor 模式）
<GAUNTLET_DIR>/tooling/bin/install-tools.sh

# 2. 启动流水线（{{PACK_LABEL}}）
get-swarm-forge {{PACK_NAME}}
./swarm
```

## 质量关卡（quality-gates/）

本项目已内置确定性质量关卡配置：

| 关卡 | 工具 | 命令（{{LANG}}） |
|------|------|------------------|
| 复杂度/CRAP | {{CRAP_TOOL}} | `{{CRAP_CMD}}` |
| 变异测试 | {{MUTATE_TOOL}} | `{{MUTATE_CMD}}` |
| 覆盖率 | {{COV_TOOL}} | `{{COV_CMD}}` |
| 架构约束 | {{ARCH_TOOL}} | 见 quality-gates/ |

**规则**：Agent 产出的代码必须通过全部关卡才允许交接；CI 再跑一遍兜底。

## 宪法与角色（constitution/ · roles/）

- `constitution/`：三层宪法（project > engineering > workflow），所有 Agent 必读必守；
- `roles/`：六角色 prompts（specifier → coder → cleaner → architect → hardender → QA）；
- 流程：`New Task → specifier → 人工审批 → coder → cleaner → architect → hardender → QA → Done`。

## 人工闸口（不可省略）

1. **specifier 产出（Gherkin + QA 程序）必须人工审批**——业务语义这层由人兜底；
2. **QA 程序必须人审**（彻底或抽查，按关键性分级）；
3. 架构决策由人拍板（审问 Agent → 人设计 → 工具固化）。

## 目录

```
{{PROJECT_NAME}}/
├── README.md / AGENTS.md
├── quality-gates/     # 质量关卡配置
├── constitution/      # 三层宪法
├── roles/             # 六角色 prompts
├── docs/              # 项目文档骨架
├── src/               # 源码（生成后按语言初始化）
└── test/              # 测试（生成后按语言初始化）
```
