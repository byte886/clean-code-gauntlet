# 目录结构（DIRECTORY STRUCTURE）

> **文档类型**：Reference（参考资料 — 目录结构说明）
> **更新频率**：目录结构变更时
> **维护者**：AI自动维护
> **读者**：AI代理和人类

---

## 顶层结构

```
clean-code-gauntlet/
├── README.md                      # 项目介绍（给人看）
├── AGENTS.md                      # AI 操作手册（给 AI 看）
├── CHANGELOG.md                   # 变更日志（Keep a Changelog）
├── LICENSE                        # MIT
├── .gitignore                     # macOS + 运行产物
├── docs/                          # 【知识层】方法论与治理文档
│   ├── THEORY.md                  #   理论手册（核心知识资产）
│   ├── TERMS.md                   #   术语表
│   ├── WORKFLOW.md                #   使用流程
│   ├── UPSTREAM_TRACKING.md       #   上游版本基线
│   ├── DOCUMENTATION_MAP.md       #   文档地图
│   ├── DIRECTORY_STRUCTURE.md     #   本文档
│   ├── ADR/                       #   架构决策记录
│   │   └── 001-repo-shape.md      #     仓库形态决策
│   └── development/guides/        #   开发/操作 SOP
│       └── generate-project-sop.md
├── tooling/                       # 【工具层】可执行能力
│   ├── README.md                  #   工具层说明
│   ├── upstream/                  #   上游工具版本卡（每仓库一张）
│   │   ├── swarm-forge.md
│   │   ├── crap4clj.md
│   │   ├── crapper.md
│   │   ├── clj-mutate.md
│   │   ├── mutator.md
│   │   └── uml-viewer.md
│   ├── bin/
│   │   ├── install-tools.sh       #   上游安装器（vendor 模式）
│   │   └── generate-project.sh    #   项目生成器（问答式）
│   └── vendor/                    #   （gitignored）上游克隆缓存
├── templates/                     # 【模板层】生成器的素材
│   ├── README.md
│   └── project/                   #   新项目模板
│       ├── README.md              #     项目 README 模板
│       ├── AGENTS.md              #     项目 AGENTS 模板
│       ├── quality-gates/         #     质量关卡配置（CRAP/变异/覆盖率/架构/CI）
│       ├── constitution/          #     三层宪法 prompts
│       ├── roles/                 #     六角色 prompts
│       └── docs/                  #     项目文档骨架
└── scripts/
    └── upstream-sync.sh           # 上游变更检测与更新
```

## 分层职责

| 层 | 目录 | 一句话职责 |
|----|------|-----------|
| 知识层 | docs/ | 方法论、术语、流程、上游基线、决策记录——仓库的"大脑" |
| 工具层 | tooling/ | 可执行能力：安装、生成、引用上游——仓库的"双手" |
| 模板层 | templates/ | 生成器的素材库——"双手"用的"模具" |
| 维护层 | scripts/ | 常设维护脚本（上游追踪） |

## 边界约定

- `tooling/vendor/`（上游克隆）与 `generated/`（生成的项目）**不入库**（.gitignore）；
- 上游工具的**引用信息**（URL/版本/用途）入库，**源码不入库**（vendor 模式，见 AGENTS.md §3.1）；
- 新项目生成在 `./generated/`，用户后续可把项目移到任何位置独立建仓。
