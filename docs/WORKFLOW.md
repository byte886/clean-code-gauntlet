# 使用流程（WORKFLOW）

> **文档类型**：Process（操作流程）
> **更新频率**：流程/工具变更时
> **维护者**：AI自动维护
> **读者**：AI代理（执行操作前）和人类

---

## 1. 总体路线

```
安装工具（install-tools）→ 生成项目（generate-project）→ 在项目内开发（six-pack 流水线）→ 定期上游追踪（upstream-sync）
```

## 2. 安装上游工具

```bash
tooling/bin/install-tools.sh
```

作用：
1. 检查前置依赖（git/curl/clojure 等，按工具要求）；
2. 把 6 个上游仓库**vendor 克隆**到 `tooling/vendor/`（gitignored，不入库）；
3. 优先使用官方安装器（如 get-swarm-forge / get-uml-viewer）；
4. 打印各工具版本与本地路径。

> 若某个上游仓库 clone 失败：如实报告失败仓库与原因，其余继续；不要把失败仓库当作已安装。

## 3. 生成新项目

```bash
tooling/bin/generate-project.sh
```

问答式流程：
1. 项目名（英文短横线命名）；
2. 语言：clojure / java / go / typescript / python / rust；
3. 流水线：two-pack（coder→cleaner）/ four-pack（specifier→coder→refactorer→architect）/ **six-pack（完整六角色，推荐）**；
4. 是否生成 CI 质量关卡模板（GitHub Actions）。

产物（默认 `./generated/<project-name>/`）：
- `README.md`、`AGENTS.md`（引用本仓库规则或复制宪法）；
- `quality-gates/`：按语言的 CRAP / 变异 / 覆盖率 / 架构测试命令模板 + CI 配置；
- `constitution/`：project.prompt / engineering.prompt / workflow.prompt（三层宪法模板）；
- `roles/`：六个角色 prompt（specifier/coder/cleaner/architect/hardender/QA）；
- `docs/`：新项目的文档骨架。

详细 SOP：[docs/development/guides/generate-project-sop.md](docs/development/guides/generate-project-sop.md)

## 4. 在项目内开发（以 six-pack 为例）

1. 在生成的项目里安装 swarm-forge：`get-swarm-forge six-pack && ./swarm`（需先 `install-tools.sh`）；
2. 通过 dashboard 提交 New Task 给 specifier；
3. specifier 产出 Gherkin + QA 程序 → **人工审批**（这是人的关键闸口）；
4. coder → cleaner → architect → hardender → QA 依次流水；
5. QA 的最终结果回传所有角色，卡片置 Done。

> 质量关卡（CRAP/变异/覆盖率/架构测试）在流水线中由对应角色强制执行；CI 里再跑一遍兜底。

## 5. 上游追踪与迭代更新

```bash
scripts/upstream-sync.sh
```

流程：
1. 经 GitHub API 读取 6 个上游仓库默认分支的最新 commit sha 与更新时间；
2. 与 `tooling/upstream/*.md` 记录的最新 sha 比对；
3. 有变更 → 输出差异 → 更新版本卡 → 更新 `docs/UPSTREAM_TRACKING.md` → CHANGELOG 记一条 → **评估是否影响生成器/模板，影响则更新 templates/ 与 generate-project.sh**；
4. 无变更 → 输出"已是最新"；
5. GitHub API 不可达 → 如实报告失败，不冒充已检查。

## 6. 维护与体检

- 文档纪律：见 AGENTS.md §3.4；
- 修改生成器/模板后必须实跑一次验证；
- 推送前检查：`git status` 确认无 `tooling/vendor/`、`generated/` 误入库。
