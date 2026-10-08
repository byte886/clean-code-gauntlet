# demo-rust — clean-code-gauntlet 示例项目（Rust）

生成自 `tooling/bin/generate-project.sh` 的跨语言验证示例（与 examples/demo-go、demo-python、demo-ts 对照）。

## 这是什么

购物车价格计算（满减 + 会员折扣 + 优惠券），同逻辑四语言版，
验证 Bob 四件套在 Rust 上的真实可运行性（落地3-Rust 实测结论见 docs/ROADMAP.md）。

## 质量门（quality-gates）

- `quality-gates/gates.yaml`：维度 + 阈值 + 触发时机
- `quality-gates/tools/rust.yaml`：Rust 工具映射表（命令实测口径）
- `.github/workflows/quality-gates.yml`：GitHub Actions 工作流（CI 内联 vendor 克隆）
- `Cargo.toml` / `src/lib.rs`：库 crate（测试内联 #[cfg(test)]，crapper/mutator 跑 cargo test）
- `architecture.json`：cargo-archtest-cli 架构约束配置

## 本机一键质检

```bash
# 前置：Rust 工具链 + 覆盖率组件
cargo install cargo-llvm-cov cargo-archtest-cli cargo-mutants
# macOS Homebrew rust 无 llvm-tools-preview 组件时，quality-check.sh 自动探测 brew llvm
# 并导出 LLVM_COV/LLVM_PROFDATA（GitHub Actions ubuntu 镜像自带组件，无需处理）
bash <GAUNTLET_DIR>/tooling/bin/install-tools.sh
bash <GAUNTLET_DIR>/tooling/bin/patch-treesitter.sh   # 已支持 tree-sitter-rust

# 一键质检（六维度：CRAP/变异/覆盖率/架构/DRY）
bash <GAUNTLET_DIR>/tooling/bin/quality-check.sh --with-dry --equiv-ok
```

## 实测成绩（2026-10-09）

| 关卡 | 结果 |
|---|---|
| CRAP/复杂度 | 全过（CC≤5 / CRAP≤5，覆盖率 100%） |
| 变异测试 | 93.8%（15 杀 1 活 = 等价变异体，已人工核验见 EQUIVALENT-MUTANTS.md） |
| 覆盖率 | 100%（cargo llvm-cov，brew llvm 环境变量方案） |
| 架构约束 | cargo archtest 0 违规 |
| DRY | dryer 0 候选 |

## 实测踩坑（已回流）

1. **macOS Homebrew rust 缺 llvm-tools-preview**：cargo-llvm-cov 报 `failed to find llvm-tools-preview`；
   brew llvm 是 keg-only（不在 PATH）→ quality-check.sh 对 rust 自动探测并导出
   `LLVM_COV=$(brew --prefix llvm)/bin/llvm-cov` 与 `LLVM_PROFDATA`（crapper/llvm-cov 子进程继承）。
2. **crates.io 镜像**：本机 cargo 已配 USTC 镜像（稀疏索引），工具安装无网络问题。
3. **lib.rs 是模块入口**：cargo test 跑 0 个测试通常是 lib.rs 未声明 `pub mod cart`（生成器骨架占位，
   业务代码接入时须写模块声明）。
