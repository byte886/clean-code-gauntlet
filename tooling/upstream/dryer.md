# dryer 版本卡

> 上游：unclebob/dryer · 多语言版 DRY 检测工具
> 抓取时间：2026-10-09（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/dryer
- 默认分支: main
- latest_sha: 66ff6d21a42c04afcad89c78a80066176d1294b0
- updated_at: 2026-10-03T23:06:14Z

## 用途
DRY（Don't Repeat Yourself）重复代码检测：Jaccard 结构指纹比对，按函数/方法结构找重复；--threshold 默认 0.82、--edn 输出、--min-lines 控制最小行数。

## 获取方式
- vendor 克隆：`git clone https://github.com/unclebob/dryer.git tooling/vendor/dryer`
- 使用：`tooling/vendor/dryer/dryer --edn src/`

## 对生成器/模板的影响
- quality-gates 的 DRY 维度（可选）以此工具为准（TypeScript/Go/Python/Rust 通用）；
- 上游更新 → 检查命令参数是否变化，同步 quality-gates 模板与 quality-check.sh。
