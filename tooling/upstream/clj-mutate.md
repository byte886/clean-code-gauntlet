# clj-mutate 版本卡

> 上游：unclebob/clj-mutate · Clojure · 变异测试
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/clj-mutate
- 默认分支: master
latest_sha: cea397da5b10b27372e36b6764728c952058e802
updated_at: 2026-09-19T16:42:57Z

## 用途
Clojure 变异测试器（针对 speclj，易改其它测试框架）：给源码下毒（运算符翻转、布尔反转、删除调用等）→ 跑测试 → 报告被杀/存活变异体；产出快照供 uml-viewer 读取。

## 获取方式
- vendor 克隆：`git clone https://github.com/unclebob/clj-mutate.git tooling/vendor/clj-mutate`
- 使用：`clj -M:mutate <src-file>`（按 README 配置）

## 对生成器/模板的影响
- templates/project/quality-gates/ 的 Clojure 变异测试关卡以此工具为准；
- "存活变异体=测试盲区"概念写入 THEORY.md §3.2 与 TERMS.md。
