# crap4clj 版本卡

> 上游：unclebob/crap4clj · Clojure · CRAP 复杂度检查
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/crap4clj
- 默认分支: master
latest_sha: e90be2e7aa02c2ec5d6544e9cecddc6b73ad3e4d
updated_at: 2026-09-17T17:58:56Z

## 用途
CRAP（Change Risk Anti-Pattern）指标实现：`CRAP(fn) = CC²×(1−cov)³+CC`，输出每个函数的圈复杂度/覆盖率/CRAP 分；产出 `.metrics/crap.edn` 供 uml-viewer 着色；已封装为 Claude Code Skill。

## 获取方式
- vendor 克隆：`git clone https://github.com/unclebob/crap4clj.git tooling/vendor/crap4clj`
- 使用：`bb crap` 或 `clj -M:crap`（按 README 配置 bb.edn/deps.edn）

## 对生成器/模板的影响
- templates/project/quality-gates/ 的 Clojure 质量关卡以此工具为准；
- 阈值约定（Bob：圈复杂度上限 6，社区：CRAP≥30 高风险）写入 THEORY.md §3.1。
