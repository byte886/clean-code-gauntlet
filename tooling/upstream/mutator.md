# mutator 版本卡

> 上游：unclebob/mutator · Python · 变异测试多语言版
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/mutator
- 默认分支: main
latest_sha: c57f03879a08d2afe8c7e044e86c80bb164afd30
updated_at: 2026-10-03T23:06:14Z

## 用途
变异测试多语言实现：Clojure / Java / Go / TypeScript / Rust / Python 六语言统一变异测试，产出 uml-viewer 可读快照。

## 获取方式
- vendor 克隆：`git clone https://github.com/unclebob/mutator.git tooling/vendor/mutator`
- 使用：见仓库 README

## 对生成器/模板的影响
- templates/project/quality-gates/ 的非 Clojure 语言变异测试关卡以此工具为准；
- 上游更新 → 检查多语言命令参数是否变化，同步 quality-gates 模板。
