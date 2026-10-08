#!/usr/bin/env bash
# =============================================================================
# quality-check.sh — 一键本地质量检查（读映射表自动拼装命令）
# 按 Bob 大叔确定性方法论跑四件套：CRAP/复杂度 → 变异测试 → 覆盖率 → 架构约束
# 命令来自 quality-gates/tools/<语言>.yaml（工具-语言解耦；阈值见 gates.yaml）
# 用法：
#   quality-check.sh [语言]            # 执行四件套（语言缺省时自动推断）
#   quality-check.sh --list [语言]     # 只打印将执行的命令，不执行
#   quality-check.sh --with-dry [语言] # 额外执行 DRY 重复代码维度（可选）
# 语言推断：命令行参数 > 当前目录 quality-gates/tools/*.yaml（生成项目只有一张）> 模板默认
# 退出码：任一维度失败 → 1；全部通过 → 0
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TPL_TOOLS="$REPO_ROOT/templates/project/quality-gates/tools"
MODE="run"
WITH_DRY=0

# ---- 参数解析 ----
POS=()
for arg in "$@"; do
  case "$arg" in
    --list) MODE="list" ;;
    --with-dry) WITH_DRY=1 ;;
    *) POS+=("$arg") ;;
  esac
done

# ---- 定位映射表 ----
TOOLS_YAML=""
if [ "${#POS[@]}" -gt 0 ]; then
  LANG_ARG="${POS[0]}"
  if [ -f "$TPL_TOOLS/$LANG_ARG.yaml" ]; then
    TOOLS_YAML="$TPL_TOOLS/$LANG_ARG.yaml"
  else
    echo "[失败] 没有 $LANG_ARG 的工具映射表（支持：typescript/go/rust/python）" >&2
    exit 1
  fi
elif ls "$PWD/quality-gates/tools/"*.yaml >/dev/null 2>&1; then
  TOOLS_YAML="$(ls "$PWD/quality-gates/tools/"*.yaml | head -1)"
else
  echo "[失败] 无法确定语言：请传语言参数，或在项目目录（含 quality-gates/tools/）下运行" >&2
  exit 1
fi

# ---- 提取（bash 3.2 兼容） ----
get_yaml() {
  grep -E "^$2:" "$1" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//'
}

LANG_NAME="$(get_yaml "$TOOLS_YAML" language)"
CRAP_CMD="$(get_yaml "$TOOLS_YAML" crap_cmd)"
MUTATE_CMD="$(get_yaml "$TOOLS_YAML" mutation_cmd)"
COV_CMD="$(get_yaml "$TOOLS_YAML" coverage_cmd)"
ARCH_CMD="$(get_yaml "$TOOLS_YAML" architecture_cmd)"
DRY_CMD="$(get_yaml "$TOOLS_YAML" dry_cmd)"

echo "=============================================="
echo " clean-code-gauntlet 质量检查（${LANG_NAME}）"
echo " 映射表：$TOOLS_YAML"
echo "=============================================="

# 维度定义：名称 命令 阈值说明
DIMS=(
  "CRAP/复杂度|$CRAP_CMD|圈复杂度 ≤8 且 CRAP <30（gates.yaml）"
  "变异测试|$MUTATE_CMD|存活变异体 = 0（gates.yaml）"
  "覆盖率|$COV_CMD|核心模块 ≥80%，其余 ≥60%（gates.yaml）"
  "架构约束|$ARCH_CMD|依赖违规 = 0、循环依赖 = 0（gates.yaml）"
)
if [ "$WITH_DRY" -eq 1 ] && [ -n "$DRY_CMD" ]; then
  DIMS+=("DRY重复代码|$DRY_CMD|相似结构候选需人工复核（可选维度）")
fi

FAILED=0
for dim in "${DIMS[@]}"; do
  IFS='|' read -r name cmd threshold <<< "$dim"
  if [ -z "$cmd" ]; then
    echo "  [跳过] $name（映射表无命令）"
    continue
  fi
  echo ""
  echo "==> $name"
  echo "    命令：$cmd"
  echo "    阈值：$threshold"
  if [ "$MODE" = "list" ]; then
    echo "    （--list 模式，不执行）"
    continue
  fi
  if eval "$cmd"; then
    echo "    ✓ PASS"
  else
    echo "    ✗ FAIL（退出码 $?）"
    FAILED=1
  fi
done

echo ""
if [ "$MODE" = "list" ]; then
  echo "==> 以上为将执行的命令（--list 预览）"
  exit 0
fi

if [ "$FAILED" -eq 1 ]; then
  echo "==> 质量检查未通过：存在失败维度，禁止交接"
  exit 1
fi
echo "==> 质量检查全部通过 ✓"
