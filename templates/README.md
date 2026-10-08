# 模板层（templates/）

> **文档类型**：Reference（参考资料 — 模板素材）
> **更新频率**：上游流水线/工具变化时
> **维护者**：AI自动维护
> **读者**：AI代理（生成器维护者）

---

## 是什么

`generate-project.sh` 生成新项目时使用的**素材库**。上游（swarm-forge 六角色/宪法）或质量工具变化时，先改这里，再重新生成验证。

## 组成

```
templates/project/
├── README.md            # 新项目 README 模板（生成时替换 {{PROJECT_NAME}} 等占位符）
├── AGENTS.md            # 新项目 AGENTS 模板（引用本仓库规则）
├── quality-gates/       # 质量关卡配置模板（CRAP/变异/覆盖率/架构 + CI）
├── constitution/        # 三层宪法 prompts（project/engineering/workflow）
├── roles/               # 六角色 prompts（specifier/coder/cleaner/architect/hardender/QA）
└── docs/                # 新项目文档骨架
```

## 修改纪律

- 改动任一模板后：**实跑一次 `generate-project.sh`**，检查产物占位符已替换、命令与语言匹配；
- 角色/宪法模板以 Bob six-pack 官方 role 职责为权威源（见 tooling/upstream/swarm-forge.md）；
- 质量关卡命令以上游工具 README 为准（crap4clj/crapper/clj-mutate/mutator）。
