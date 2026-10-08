#!/usr/bin/env bash
# =============================================================================
# patch-treesitter.sh — 网络受限环境本地补丁（crapper / mutator / dryer）
# 背景：三个 Bob 工具都依赖 tree_sitter_language_pack 从 GitHub
#       （github.com/xberg-io/tree-sitter-language-pack）下载语法包；
#       直连 GitHub 经常超时。本补丁：
#         1. patch 各工具 src/*/treesitter.py：优先用 PyPI 独立语法包
#            （tree-sitter-python 等，国内镜像可装），下载仅作 fallback；
#         2. 把 tree-sitter-python 装进各工具的 .venv（mutator 另装 pytest/coverage，
#            因为它用自己 .venv 的 python 跑测试命令）。
# 注意：install-tools.sh 的 git fetch 会覆盖 vendor 源码，覆盖后需重跑本脚本。
# 用法：bash tooling/bin/patch-treesitter.sh
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VENDOR_DIR="$REPO_ROOT/tooling/vendor"

# 各工具：src 相对路径 与 额外 pip 包（独立语法包按目标语言装；python/go/ts 已实测，其余语言按需加）
TOOLS=(
  "crapper|src/crapper/languages/treesitter.py|tree-sitter-python tree-sitter-go tree-sitter-typescript tree-sitter-javascript"
  "mutator|src/mutator/treesitter.py|tree-sitter-python tree-sitter-go tree-sitter-typescript tree-sitter-javascript pytest coverage"
  "dryer|src/dryer/treesitter.py|tree-sitter-python tree-sitter-go tree-sitter-typescript tree-sitter-javascript"
)

NEW_PARSER_FOR='@lru_cache(maxsize=None)
def parser_for(language: str):
    # [local-patch] 独立语法包优先（PyPI 镜像），下载仅作 fallback —— 见 tooling/bin/patch-treesitter.sh
    from tree_sitter import Language, Parser

    mod_name = {
        "python": "tree_sitter_python",
        "javascript": "tree_sitter_javascript",
        "typescript": "tree_sitter_typescript",
        "rust": "tree_sitter_rust",
        "go": "tree_sitter_go",
        "java": "tree_sitter_java",
    }.get(language)
    if mod_name:
        try:
            mod = __import__(mod_name)
            fn = getattr(mod, "language", None)
            if fn is None and language == "typescript":
                # tree-sitter-typescript ≤0.23 的 API 是 language_typescript()（旧风格）
                fn = getattr(mod, "language_typescript", None)
            if fn is not None:
                return Parser(Language(fn()))
        except Exception:
            pass
    from tree_sitter_language_pack import download, get_parser

    download([language])
    return get_parser(language)
'

for entry in "${TOOLS[@]}"; do
  IFS='|' read -r name rel_path extra_pkgs <<< "$entry"
  dir="$VENDOR_DIR/$name"
  if [ ! -d "$dir" ]; then
    echo "-- ${name}：未安装，跳过"
    continue
  fi
  target="$dir/$rel_path"
  if [ ! -f "$target" ]; then
    # 部分工具（如 mutator）没有自有 treesitter.py（复用 crapper 的），跳过 patch，仍装 venv 包
    echo "== ${name}：无自有 treesitter.py（复用 crapper），跳过源码 patch，仅装 venv 包"
    SKIP_PATCH=1
  fi
  if [ -z "${SKIP_PATCH:-}" ]; then
  echo "== ${name}：patch ${target}"
  python3 - "$target" "$NEW_PARSER_FOR" <<'PYEOF'
import re, sys
path, new_block = sys.argv[1], sys.argv[2]
src = open(path, encoding="utf-8").read()
pattern = re.compile(r"def parser_for\(language: str\):.*?return get_parser\(language\)\n", re.S)
if pattern.search(src):
    open(path, "w", encoding="utf-8").write(pattern.sub(new_block, src))
    print("   ✓ parser_for 已替换")
else:
    print("   - 未找到旧 parser_for（可能已打过补丁或格式不同），跳过")
PYEOF
  fi
  unset SKIP_PATCH
  # 安装独立语法包进 .venv
  if [ -x "$dir/.venv/bin/pip" ]; then
    echo "== ${name}：venv 安装 ${extra_pkgs}"
    "$dir/.venv/bin/pip" install $extra_pkgs -q 2>&1 | tail -1
  else
    echo "-- $name：.venv 尚未创建（首次运行工具时自动创建），需先运行一次工具再补补丁"
  fi
done

echo ""
echo "==> 完成。若之后运行 install-tools.sh（git fetch 覆盖源码），请重跑本脚本。"
