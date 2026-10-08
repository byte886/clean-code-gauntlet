# crapper 版本卡

> 上游：unclebob/crapper · Python · CRAP 多语言版
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/crapper
- 默认分支: master
- latest_sha: 9f1bead298b5a9d576bdd6319289fcf426e5b18a
- updated_at: 2026-10-03T22:28:03Z

## 用途
CRAP 打分的多语言实现：Clojure / Java / Go / TypeScript / Rust / Python 六语言统一打分，产出 uml-viewer 可读的快照（`.metrics/`）。

## 获取方式
- vendor 克隆：`git clone https://github.com/unclebob/crapper.git tooling/vendor/crapper`
- 使用：见仓库 README（Python 实现，产出快照供 uml-viewer 读取）

## 对生成器/模板的影响
- templates/project/quality-gates/ 的非 Clojure 语言 CRAP 关卡以此工具为准（Java/Go/TS/Rust/Python）；
- 上游更新 → 检查多语言命令参数是否变化，同步 quality-gates 模板。
