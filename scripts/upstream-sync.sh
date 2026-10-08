#!/usr/bin/env bash
# =============================================================================
# upstream-sync.sh — 上游变更检测与更新
# 经 GitHub API 读取 Bob（unclebob）工具仓库默认分支最新 commit，
# 与 tooling/upstream/*.md 版本卡记录比对；有变更则更新版本卡并提示
# 同步 UPSTREAM_TRACKING / CHANGELOG / templates。
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UP_DIR="$REPO_ROOT/tooling/upstream"

# 仓库清单：名称 默认分支 版本卡文件
REPOS=(
  "swarm-forge main swarm-forge.md"
  "crap4clj master crap4clj.md"
  "crapper main crapper.md"
  "clj-mutate master clj-mutate.md"
  "mutator main mutator.md"
  "uml-viewer master uml-viewer.md"
  "dryer main dryer.md"
)

if ! command -v curl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
  echo "[失败] 需要 curl 与 python3" >&2
  exit 1
fi

echo "==> 上游变更检测（GitHub API，默认分支最新 commit）"
echo ""

ANY_CHANGE=0
API_FAIL=0

for entry in "${REPOS[@]}"; do
  read -r repo branch card <<< "$entry"
  card_path="$UP_DIR/$card"

  # 读取本地记录（latest_sha 行；无记录则为空=基线建立）
  local_sha=""
  if [ -f "$card_path" ]; then
    local_sha="$(sed -n 's/^[- ]*latest_sha: //p' "$card_path" | tr -d ' ')"
  fi

  # 抓上游信息
  resp="$(curl -sS --max-time 20 "https://api.github.com/repos/unclebob/$repo")"
  if [ -z "$resp" ] || echo "$resp" | python3 -c "import sys,json; json.load(sys.stdin)" >/dev/null 2>&1 || true; then
    :
  fi
  # 用 python 解析（兼容 JSON 解析失败）
  up_sha="$(echo "$resp" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('default_branch',''))
    print((d.get('pushed_at') or '').strip())
except Exception:
    print('__FAIL__')
    print('__FAIL__')
" 2>/dev/null)"
  branch_now="$(echo "$up_sha" | sed -n 1p)"
  pushed_at="$(echo "$up_sha" | sed -n 2p)"

  if [ "$branch_now" = "__FAIL__" ] || [ -z "$branch_now" ]; then
    echo "[$repo] GitHub API 不可达/解析失败 —— 如实报告，未检查"
    API_FAIL=1
    continue
  fi

  # 取最新 commit sha
  up_commit="$(curl -sS --max-time 20 "https://api.github.com/repos/unclebob/$repo/commits/$branch_now" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('sha',''))
except Exception:
    print('')
" 2>/dev/null)"

  if [ -z "$up_commit" ]; then
    echo "[$repo] 获取最新 commit 失败 —— 如实报告，未检查"
    API_FAIL=1
    continue
  fi

  up_short="${up_commit:0:7}"

  if [ -z "$local_sha" ]; then
    # 首次建立基线
    echo "[$repo] 基线建立：$branch_now @ ${up_short}（${pushed_at}）"
    sed -i '' "s|^[- ]*latest_sha: .*|- latest_sha: $up_commit|" "$card_path"
    sed -i '' "s|^[- ]*updated_at: .*|- updated_at: $pushed_at|" "$card_path"
  elif [ "$local_sha" != "$up_commit" ]; then
    echo "[$repo] ★ 有变更：${local_sha}（旧）→ ${up_short}（新，${pushed_at}）"
    sed -i '' "s|^[- ]*latest_sha: .*|- latest_sha: $up_commit|" "$card_path"
    sed -i '' "s|^[- ]*updated_at: .*|- updated_at: $pushed_at|" "$card_path"
    ANY_CHANGE=1
  else
    echo "[$repo] 已是最新：${up_short}（${pushed_at}）"
  fi
done

echo ""
if [ "$ANY_CHANGE" -eq 1 ]; then
  echo "==> 有上游变更！请继续执行："
  echo "  1. 更新 docs/UPSTREAM_TRACKING.md 基线表与『上游变更日志』"
  echo "  2. CHANGELOG.md 记一条（含变更内容评估）"
  echo "  3. 若影响流水线/工具用法 → 同步 templates/ 与 generate-project.sh（见 AGENTS.md §3.2）"
else
  echo "==> 全部已是最新（或基线已建立）。"
fi

if [ "$API_FAIL" -eq 1 ]; then
  echo ""
  echo "[提示] 部分仓库 API 检查失败（网络/限流）。上述结论不含失败项，勿视为已全部核验。" >&2
  exit 1
fi
