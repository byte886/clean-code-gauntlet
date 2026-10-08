# Quality Gates — 质量关卡配置

> 生成自 clean-code-gauntlet 模板。这些关卡是**机器强制**的：Agent 产出的代码必须全部通过才能交接；CI 再跑一遍兜底。

## 按语言命令映射

| 语言 | CRAP/复杂度 | 变异测试 | 覆盖率 | 架构约束 |
|------|------------|---------|--------|---------|
| Clojure | `bb crap`（crap4clj） | `clj -M:mutate <src>`（clj-mutate） | `clj -M:cov`（Cloverage） | `dependency-checker` + uml-viewer |
| Java | `crapper`（unclebob） | `mutator`（unclebob）/ PITest | JaCoCo | ArchUnit |
| Go | `crapper` | `mutator` / go-mutesting | go test -cover | go-arch-lint |
| TypeScript | `crapper` / crap4ts | `mutator` / Stryker | c8 / LCOV | dependency-cruiser / ArchUnitTS |
| Python | `crapper` | `mutator` / mutmut | coverage.py | import-linter |
| Rust | `crapper` | `mutator` / cargo-mutants | cargo-llvm-cov | cargo modules |

> 说明：`crapper` / `mutator` 是 Bob 本人的多语言实现（Python），输出 uml-viewer 可读快照；其余为社区成熟替代（按项目实际选择）。

## 阈值约定（默认）

- **圈复杂度**：≤6（Bob 对 Agent 的放宽阈值；人类标准 ≤4）；
- **CRAP 分**：≥30 视为高风险，必须重构或补测试；
- **覆盖率**：核心模块 100% 行覆盖；其余 ≥80%（项目可按实际调整）；
- **变异测试**：存活变异体 = 0 才允许交接；
- **架构**：依赖方向只允许高层→低层；循环依赖 = 0。

## 关卡脚本（CI 用）

- `ci.yml`：GitHub Actions 模板（按语言分发跑 CRAP/变异/覆盖率/架构）；
- 本地入口：`tooling/bin/install-tools.sh` 安装上游工具后，按上表命令运行。

## 修改纪律

- 阈值/命令修改必须同步：本文件 + constitution/engineering.prompt + README.md；
- 上游工具命令变化（见 tooling/upstream/*.md 版本卡）→ 更新本文件。
