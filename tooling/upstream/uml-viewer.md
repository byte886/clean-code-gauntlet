# uml-viewer 版本卡

> 上游：unclebob/uml-viewer · Clojure · 架构查看器
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/uml-viewer
- 默认分支: master
latest_sha: f65dafe93b3cb1b4e6bb02dbe41503ed05bd9ebf
updated_at: 2026-10-07T21:22:40Z

## 用途
动态 UML 架构查看器：点击下钻到源码、CRAP 与变异指标给组件着色（数据来自 crap4clj/clj-mutate 的 `.metrics/` 快照）、违反 Clean Architecture 依赖规则的边标红、what-if 提案（告诉 Agent 你不满意 → 它改图 → 满意后让代码匹配）；配 Grok companion 实时协作。

## 获取方式
- 官方安装器：`scripts/get-uml-viewer`（一行装入任意 Clojure 项目）
- vendor 克隆：`git clone https://github.com/unclebob/uml-viewer.git tooling/vendor/uml-viewer`

## 对生成器/模板的影响
- templates/project/quality-gates/ 的架构约束可视化/依赖规则以此工具为准；
- "依赖规则（高层→低层违规标红）"概念写入 THEORY.md §3.3 与 TERMS.md。
