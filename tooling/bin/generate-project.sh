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

# ---- 2. 语言 ----
echo "选择语言："
echo "  1) clojure     2) java      3) go"
echo "  4) typescript  5) python    6) rust"
read -r -p "输入序号 [1-6，默认 4]: " LANG_NUM
LANG_NUM="${LANG_NUM:-4}"
case "$LANG_NUM" in
  1) PROJ_LANG="clojure" ;;
  2) PROJ_LANG="java" ;;
  3) PROJ_LANG="go" ;;
  4) PROJ_LANG="typescript" ;;
  5) PROJ_LANG="python" ;;
  6) PROJ_LANG="rust" ;;
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

# ---- 工具映射（按语言） ----
CRAP_TOOL="crapper"; MUTATE_TOOL="mutator"; COV_TOOL=""; ARCH_TOOL=""
case "$PROJ_LANG" in
  clojure)
    CRAP_TOOL="crap4clj"; MUTATE_TOOL="clj-mutate"; COV_TOOL="Cloverage"; ARCH_TOOL="dependency-checker"
    CRAP_CMD="bb crap"; MUTATE_CMD="clj -M:mutate src/"; COV_CMD="clj -M:cov"; ARCH_CMD="dependency-checker"
    ;;
  java)
    CRAP_CMD="crapper"; MUTATE_CMD="mutator"; COV_CMD="JaCoCo"; ARCH_CMD="ArchUnit"
    ;;
  go)
    CRAP_CMD="crapper"; MUTATE_CMD="mutator"; COV_CMD="go test -cover ./..."; ARCH_CMD="go-arch-lint"
    ;;
  typescript)
    CRAP_CMD="crapper"; MUTATE_CMD="mutator"; COV_CMD="c8"; ARCH_CMD="dependency-cruiser"
    ;;
  python)
    CRAP_CMD="crapper"; MUTATE_CMD="mutator"; COV_CMD="coverage.py"; ARCH_CMD="import-linter"
    ;;
  rust)
    CRAP_CMD="crapper"; MUTATE_CMD="mutator"; COV_CMD="cargo-llvm-cov"; ARCH_CMD="cargo modules"
    ;;
esac

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

# 替换占位符
replace_placeholders() {
  local f="$1"
  sed -i '' \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{LANG}}/$PROJ_LANG/g" \
    -e "s/{{PACK_NAME}}/$PACK_NAME/g" \
    -e "s/{{PACK_LABEL}}/$PACK_LABEL/g" \
    -e "s/{{CRAP_TOOL}}/$CRAP_TOOL/g" \
    -e "s/{{CRAP_CMD}}/$CRAP_CMD/g" \
    -e "s/{{MUTATE_TOOL}}/$MUTATE_TOOL/g" \
    -e "s/{{MUTATE_CMD}}/$MUTATE_CMD/g" \
    -e "s/{{COV_TOOL}}/$COV_TOOL/g" \
    -e "s/{{COV_CMD}}/$COV_CMD/g" \
    -e "s/{{ARCH_TOOL}}/$ARCH_TOOL/g" \
    -e "s|<GAUNTLET_DIR>|$REPO_ROOT|g" \
    "$f"
}

find "$OUT_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  replace_placeholders "$f"
done

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
