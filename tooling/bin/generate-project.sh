#!/usr/bin/env bash
# =============================================================================
# generate-project.sh — 项目生成器（问答式）
# 按 Bob 大叔的确定性质量方法论生成新项目骨架：
#   质量关卡（CRAP/变异/覆盖率/架构）+ 三层宪法 + 六角色 prompts + 文档骨架
# 产物默认落在 ./generated/<project-name>/
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TPL_DIR="$REPO_ROOT/templates/project"
OUT_ROOT="$REPO_ROOT/generated"

echo "=============================================="
echo " clean-code-gauntlet 项目生成器"
echo " 按 Bob 大叔确定性质量方法论生成新项目骨架"
echo "=============================================="

# ---- 1. 项目名 ----
read -r -p "项目名（英文短横线，如 my-service）: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  echo "[失败] 项目名不能为空" >&2; exit 1
fi
if echo "$PROJECT_NAME" | grep -qE '[^a-z0-9-]'; then
  echo "[失败] 项目名只允许小写字母/数字/短横线" >&2; exit 1
fi

# ---- 2. 语言（目标语言收敛：TypeScript/Go/Rust/Python；Clojure/Java 明确不使用） ----
echo "选择语言："
echo "  1) typescript  2) go  3) rust  4) python"
read -r -p "输入序号 [1-4，默认 1]: " LANG_NUM
LANG_NUM="${LANG_NUM:-1}"
case "$LANG_NUM" in
  1) PROJ_LANG="typescript" ;;
  2) PROJ_LANG="go" ;;
  3) PROJ_LANG="rust" ;;
  4) PROJ_LANG="python" ;;
  *) echo "[失败] 无效选择" >&2; exit 1 ;;
esac

# ---- 3. 流水线 pack ----
echo "选择流水线："
echo "  1) two-pack   （coder → cleaner，最小）"
echo "  2) four-pack  （specifier → coder → refactorer → architect）"
echo "  3) six-pack   （specifier → coder → cleaner → architect → hardender → QA，完整，推荐）"
read -r -p "输入序号 [1-3，默认 3]: " PACK_NUM
PACK_NUM="${PACK_NUM:-3}"
case "$PACK_NUM" in
  1) PACK_NAME="two-pack";  PACK_LABEL="two-pack（coder→cleaner）" ;;
  2) PACK_NAME="four-pack"; PACK_LABEL="four-pack（specifier→coder→refactorer→architect）" ;;
  3) PACK_NAME="six-pack";  PACK_LABEL="six-pack（specifier→coder→cleaner→architect→hardender→QA）" ;;
  *) echo "[失败] 无效选择" >&2; exit 1 ;;
esac

# ---- 4. 是否带 CI ----
read -r -p "生成 CI 质量关卡模板（GitHub Actions）？[Y/n，默认 Y]: " WITH_CI
WITH_CI="${WITH_CI:-Y}"
case "$WITH_CI" in
  Y|y|Yes|yes|YES) WITH_CI=1 ;;
  N|n|No|no|NO)  WITH_CI=0 ;;
  *) echo "[失败] 无效选择" >&2; exit 1 ;;
esac

# ---- 工具映射（工具-语言解耦：从 tools/<语言>.yaml 读取，不硬编码） ----
get_yaml() {
  # usage: get_yaml <file> <key> —— 提取 "key: value" 的 value（bash 3.2 兼容）
  grep -E "^$2:" "$1" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//'
}

TOOLS_YAML="$TPL_DIR/quality-gates/tools/$PROJ_LANG.yaml"
if [ ! -f "$TOOLS_YAML" ]; then
  echo "[失败] 缺少工具映射表 $TOOLS_YAML" >&2; exit 1
fi
CRAP_TOOL=$(get_yaml "$TOOLS_YAML" crap_tool);    CRAP_INSTALL=$(get_yaml "$TOOLS_YAML" crap_install);    CRAP_CMD=$(get_yaml "$TOOLS_YAML" crap_cmd)
MUTATE_TOOL=$(get_yaml "$TOOLS_YAML" mutation_tool); MUTATE_INSTALL=$(get_yaml "$TOOLS_YAML" mutation_install); MUTATE_CMD=$(get_yaml "$TOOLS_YAML" mutation_cmd)
COV_TOOL=$(get_yaml "$TOOLS_YAML" coverage_tool);  COV_INSTALL=$(get_yaml "$TOOLS_YAML" coverage_install);  COV_CMD=$(get_yaml "$TOOLS_YAML" coverage_cmd)
ARCH_TOOL=$(get_yaml "$TOOLS_YAML" architecture_tool); ARCH_INSTALL=$(get_yaml "$TOOLS_YAML" architecture_install); ARCH_CMD=$(get_yaml "$TOOLS_YAML" architecture_cmd)

# ---- 生成 ----
OUT_DIR="$OUT_ROOT/$PROJECT_NAME"
if [ -d "$OUT_DIR" ]; then
  echo "[失败] $OUT_DIR 已存在，请换名或先清理" >&2; exit 1
fi
mkdir -p "$OUT_DIR"

echo ""
echo "==> 生成中：$OUT_DIR"

# 复制模板
cp -R "$TPL_DIR/." "$OUT_DIR/"
# 额外目录
mkdir -p "$OUT_DIR/src" "$OUT_DIR/test"

# Python 骨架：pyproject.toml（pytest 声明 + coverage + import-linter 契约，落地 3 实测口径）
if [ "$PROJ_LANG" = "python" ]; then
  echo "  （python 骨架：保留 pyproject.toml 质量门配置）"
else
  rm -f "$OUT_DIR/pyproject.toml"
fi

# 替换占位符（分隔符统一用 |；替换文本先转义 & \ |，防止映射表命令中的特殊字符被 sed 吞掉）
esc_sed() {
  printf '%s' "$1" | sed 's/[&\\|]/\\&/g'
}

replace_placeholders() {
  local f="$1"
  sed -i '' \
    -e "s|{{PROJECT_NAME}}|$(esc_sed "$PROJECT_NAME")|g" \
    -e "s|{{LANG}}|$(esc_sed "$PROJ_LANG")|g" \
    -e "s|{{PACK_NAME}}|$(esc_sed "$PACK_NAME")|g" \
    -e "s|{{PACK_LABEL}}|$(esc_sed "$PACK_LABEL")|g" \
    -e "s|{{CRAP_TOOL}}|$(esc_sed "$CRAP_TOOL")|g" \
    -e "s|{{CRAP_INSTALL}}|$(esc_sed "$CRAP_INSTALL")|g" \
    -e "s|{{CRAP_CMD}}|$(esc_sed "$CRAP_CMD")|g" \
    -e "s|{{MUTATE_TOOL}}|$(esc_sed "$MUTATE_TOOL")|g" \
    -e "s|{{MUTATE_INSTALL}}|$(esc_sed "$MUTATE_INSTALL")|g" \
    -e "s|{{MUTATE_CMD}}|$(esc_sed "$MUTATE_CMD")|g" \
    -e "s|{{COV_TOOL}}|$(esc_sed "$COV_TOOL")|g" \
    -e "s|{{COV_INSTALL}}|$(esc_sed "$COV_INSTALL")|g" \
    -e "s|{{COV_CMD}}|$(esc_sed "$COV_CMD")|g" \
    -e "s|{{ARCH_TOOL}}|$(esc_sed "$ARCH_TOOL")|g" \
    -e "s|{{ARCH_INSTALL}}|$(esc_sed "$ARCH_INSTALL")|g" \
    -e "s|{{ARCH_CMD}}|$(esc_sed "$ARCH_CMD")|g" \
    -e "s|<GAUNTLET_DIR>|$(esc_sed "$REPO_ROOT")|g" \
    "$f"
}

find "$OUT_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  replace_placeholders "$f"
done

# 工具-语言解耦：只保留当前语言的工具映射表，删除其余语言
find "$OUT_DIR/quality-gates/tools" -name '*.yaml' ! -name "$PROJ_LANG.yaml" -delete 2>/dev/null || true

# CI 模板按选项保留/删除
if [ "$WITH_CI" -eq 0 ]; then
  rm -f "$OUT_DIR/quality-gates/ci.yml"
fi

echo ""
echo "==> 生成完成。下一步："
echo "  1. cd $OUT_DIR"
echo "  2. 安装上游工具：$REPO_ROOT/tooling/bin/install-tools.sh"
echo "  3. 启动流水线：get-swarm-forge $PACK_NAME && ./swarm（six-pack 需先装 get-swarm-forge，见 tooling/upstream/swarm-forge.md）"
echo "  4. 通过 dashboard 提交 New Task 给 specifier，并人工审批它的 Gherkin 与 QA 程序"
echo ""
echo "  质量关卡命令（${PROJ_LANG}）："
echo "    CRAP/复杂度 : $CRAP_CMD"
echo "    变异测试    : $MUTATE_CMD"
echo "    覆盖率      : $COV_CMD"
echo "    架构约束    : $ARCH_CMD"
