# swarm-forge 版本卡

> 上游：unclebob/swarm-forge · Clojure · 多 Agent 编排平台
> 抓取时间：2026-10-08（初始基线）

## 引用信息
- GitHub: https://github.com/unclebob/swarm-forge
- 默认分支: main
latest_sha: f4f5fbcae0de6f7dcc26e82400334227647cfdb2
updated_at: 2026-09-07T14:45:22Z

## 用途
协调多个 AI Agent 在隔离 git worktree + tmux 会话中协作；提供 two-pack（coder→cleaner）、four-pack（specifier→coder→refactorer→architect）、six-pack（六角色完整流水线：specifier→coder→cleaner→architect→hardender→QA）三种装配；三层宪法（project>engineering>workflow）+ 持久化 handoff 协议 + 本地 dashboard。

## 获取方式
- 官方安装器：`get-swarm-forge`（一行装入现有项目，见仓库 main 分支 README）
- vendor 克隆：`git clone https://github.com/unclebob/swarm-forge.git tooling/vendor/swarm-forge`

## 对生成器/模板的影响
- templates/project/constitution/（三层宪法）与 roles/（六角色 prompts）以此仓库 role 定义为准；
- generate-project.sh 的"流水线选择"选项（two/four/six-pack）以此仓库产品线为准；
- 上游若新增 pack 或调整角色职责 → 必须同步 THEORY.md §3.4 + templates/。
