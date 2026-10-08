# demo-python — clean-code-gauntlet 示例项目（Python）

生成自 `tooling/bin/generate-project.sh` 的跨语言验证示例（与 examples/demo-go 对照）。

## 这是什么

购物车价格计算（满减 + 会员折扣 + 优惠券），与 Go demo 同逻辑，
验证 Bob 四件套在 Python 上的真实可运行性（落地 3 实测结论见 docs/ROADMAP.md）。

## 质量门（quality-gates）

- `quality-gates/gates.yaml`：维度 + 阈值 + 触发时机
- `quality-gates/tools/python.yaml`：Python 工具映射表（命令实测口径）
- `.github/workflows/quality-gates.yml`：GitHub Actions 工作流（CI 内联 vendor 克隆）
- `pyproject.toml`：pytest 声明 + coverage + import-linter 契约（crapper 检测 pytest 需配置文件含 "pytest" 字样）

## 本机一键质检

```bash
# 前置：安装 vendor 工具 + 补丁（网络受限环境）
bash <GAUNTLET_DIR>/tooling/bin/install-tools.sh
bash <GAUNTLET_DIR>/tooling/bin/patch-treesitter.sh

# 一键质检（六维度：CRAP/变异/覆盖率/架构/DRY）
bash <GAUNTLET_DIR>/tooling/bin/quality-check.sh --with-dry --equiv-ok
```

## 实测成绩（2026-10-08）

| 关卡 | 结果 |
|---|---|
| CRAP/复杂度 | 全过（CC≤5 / CRAP≤5，覆盖率 100%） |
| 变异测试 | 94.1%（16 杀 1 活 = 等价变异体，已人工核验见 EQUIVALENT-MUTANTS.md） |
| 覆盖率 | 100% |
| 架构约束 | import-linter 2 契约 KEPT |
| DRY | dryer 0 候选 |
