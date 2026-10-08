# demo-ts — clean-code-gauntlet 示例项目（TypeScript）

生成自 `tooling/bin/generate-project.sh` 的跨语言验证示例（与 examples/demo-go、examples/demo-python 对照）。

## 这是什么

购物车价格计算（满减 + 会员折扣 + 优惠券），同逻辑三语言版，
验证 Bob 四件套在 TypeScript 上的真实可运行性（落地3-TS 实测结论见 docs/ROADMAP.md）。

## 质量门（quality-gates）

- `quality-gates/gates.yaml`：维度 + 阈值 + 触发时机
- `quality-gates/tools/typescript.yaml`：TS 工具映射表（命令实测口径）
- `.github/workflows/quality-gates.yml`：GitHub Actions 工作流（CI 内联 vendor 克隆）
- `package.json` / `vitest.config.ts`：vitest 测试 + coverage（**必须输出 LCOV**——crapper/mutator 读 coverage/**/lcov.info 才有覆盖率；c8 看不到 vitest worker 进程，勿换回 c8）
- `.dependency-cruiser.cjs`：架构约束（ESM 项目须 .cjs，.js 会被当 ESM 报错）

## 本机一键质检

```bash
# 前置：npm 依赖 + vendor 工具 + treesitter 补丁
npm install -D vitest @vitest/coverage-v8 dependency-cruiser
bash <GAUNTLET_DIR>/tooling/bin/install-tools.sh
bash <GAUNTLET_DIR>/tooling/bin/patch-treesitter.sh   # 已支持 tree-sitter-typescript/javascript

# 一键质检（六维度：CRAP/变异/覆盖率/架构/DRY）
bash <GAUNTLET_DIR>/tooling/bin/quality-check.sh --with-dry --equiv-ok
```

## 实测成绩（2026-10-09）

| 关卡 | 结果 |
|---|---|
| CRAP/复杂度 | 全过（CC≤5 / CRAP≤5，覆盖率 100%） |
| 变异测试 | 90.5%（19 杀 2 活 = 等价变异体，已人工核验见 EQUIVALENT-MUTANTS.md） |
| 覆盖率 | 100%（vitest v8 provider + LCOV） |
| 架构约束 | dependency-cruiser 0 违规 |
| DRY | dryer 0 候选 |

## 实测踩坑（已回流模板）

1. **vitest 与函数名冲突**：测试导入函数名 `describe` 与 vitest 全局冲突 → 业务函数改名 describeAmount
2. **c8 对 vitest 无效**：c8 看不到 vitest worker 进程覆盖率（crapper 源码注释明说）→ 覆盖率命令用 `npx vitest run --coverage`
3. **LCOV 必须显式输出**：vitest coverage 默认只有 text 报告，crapper 读不到 → `reporter: ["text", "lcov"]`
4. **ESM 项目配置须 .cjs**：package.json `"type":"module"` 下 `.dependency-cruiser.js` 被当 ESM 报错（且报错仍 exit 0 → 假 PASS）→ 改 `.dependency-cruiser.cjs`
5. **tree-sitter-typescript 旧 API**：0.23.x 无 `language()`，须用 `language_typescript()`（已入 patch-treesitter.sh）
