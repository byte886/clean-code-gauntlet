#!/usr/bin/env bash
# =============================================================================
# install-tools.sh — 上游工具安装器（vendor 模式）
# 把 Bob 大叔（unclebob）的确定性质量工具 vendor 克隆到 tooling/vendor/
# 策略：不 fork、不复制源码入库；版本记录在 tooling/upstream/*.md
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VENDOR_DIR="$REPO_ROOT/tooling/vendor"
mkdir -p "$VENDOR_DIR"

# 仓库清单：名称 默认分支（仅用于 clone；版本比对见 scripts/upstream-sync.sh）
REPOS=(
  "swarm-forge main"
  "crap4clj master"
  "crapper master"
  "clj-mutate master"
  "mutator main"
  "uml-viewer master"
  "dryer main"
)

echo "==> 检查前置依赖"
for cmd in git curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[失败] 缺少 $cmd，请先安装" >&2
    exit 1
  fi
done
echo "    前置依赖 OK（git/curl）"

echo "==> vendor 目录：$VENDOR_DIR"

FAILED=0
for entry in "${REPOS[@]}"; do
  read -r repo branch <<< "$entry"
  target="$VENDOR_DIR/$repo"
  if [ -d "$target/.git" ]; then
    echo "-- $repo 已存在，尝试更新（git fetch）"
    if (cd "$target" && git fetch --all --quiet 2>&1); then
      echo "   ✓ 更新完成"
    else
      echo "   [失败] fetch 失败，保留现有缓存" >&2
      FAILED=1
    fi
  else
    echo "-- 克隆 ${repo}（分支 ${branch}，浅克隆）"
    ok=0
    for attempt in 1 2 3; do
      if git clone --depth 1 --branch "$branch" --quiet "https://github.com/unclebob/$repo.git" "$target" 2>&1; then
        ok=1
        break
      fi
      echo "   第 $attempt 次失败，5 秒后重试（网络可能不稳定）"
      sleep 5
    done
    if [ "$ok" -eq 1 ]; then
      echo "   ✓ 克隆完成"
    else
      echo "   [失败] 克隆失败（网络/仓库不存在？）" >&2
      FAILED=1
    fi
  fi
done

echo ""
echo "==> 各工具本地版本（默认分支 head）："
for entry in "${REPOS[@]}"; do
  read -r repo _ <<< "$entry"
  target="$VENDOR_DIR/$repo"
  if [ -d "$target/.git" ]; then
    sha="$(git -C "$target" rev-parse --short HEAD 2>/dev/null || echo '?')"
    echo "   $repo @ $sha"
  else
    echo "   $repo （未安装）"
  fi
done

if [ "$FAILED" -eq 1 ]; then
  echo ""
  echo "[提示] 部分仓库安装失败。请如实记录失败项；其余已可用。" >&2
  exit 1
fi

echo ""
echo "==> 完成。版本基线记录：docs/UPSTREAM_TRACKING.md；变更检测：scripts/upstream-sync.sh"
