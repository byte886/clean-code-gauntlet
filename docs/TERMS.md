# 术语表（TERMS）

> **文档类型**：Reference（参考资料 — 术语索引）
> **更新频率**：遇到新术语/上游新增概念时
> **维护者**：AI自动维护
> **读者**：人类和AI（理解方法论时）

| 术语 | 通俗解释 | 技术细节 |
|---|---|---|
| **Bob 大叔（Robert C. Martin）** | 《代码整洁之道》作者、SOLID 原则提出者 | 1952 年生，12 岁（1964 年）开始编程 |
| **Agent（智能体）** | 能自主理解任务、调用工具、迭代执行的大模型程序 | 不再只是"聊天问答"，可写代码/跑测试/循环修正 |
| **CRAP 指标** | 给函数打"烂度分"：又复杂又没测试的分数高 | `CRAP = CC²×(1−cov)³+CC`；≥30 高风险；Bob 给人定 ≤4、给 agent 放宽到 6（可能 8）；工具：crap4clj/crapper/Crap4J |
| **圈复杂度（CC）** | 函数里独立执行路径数：if/循环/switch 各 +1 | McCabe 1976；1-5 简单、6-10 中等、>10 高险 |
| **变异测试（Mutation Testing）** | 故意改坏代码（+变−、<变>=、反转布尔），跑测试看能否抓出来 | 抓出来=被杀（测试有效）；没抓=存活（盲区）。工具：clj-mutate/mutator/Stryker/PIT |
| **存活变异体（Surviving Mutant）** | 代码被改坏但测试全绿 → 这条行为没测试守护 | 比覆盖率数字更诚实的测试质量测量 |
| **等价变异体（Equivalent Mutant）** | 变异后行为实际不变，测试抓不到是正常的，不属于测试缺陷 | 可人工标注后跳过；实证案例（negative-test-experiment）：clj-mutate 把 `1→0`（布尔翻转）打在父 `if`/`cond` 行、字面量却在子分支 → 文本替换是 no-op，手改真实字面量即杀死 |
| **Gherkin** | "人话"测试描述语言，Given/When/Then，可转成可执行测试 | BDD 核心语言；框架：Cucumber、Reqnroll（.NET） |
| **lost in the middle** | 大模型对 prompt 开头结尾记得牢、中间段被忽略（U 形注意力） | Liu et al. 2023 论文；中间段召回可降 10-40% |
| **聪明区/愚蠢区** | 上下文窗口里注意力强的区域（头尾）与弱的区域（中间） | 注意力稀释效应的通俗比喻 |
| **宪法（Constitution）** | 所有 Agent 必须遵守的规则体系 | swarm-forge 三层：project > engineering > workflow |
| **Role prompt** | 单个角色的职责边界 prompt | 定义可改什么、必须验证什么、交接给谁 |
| **Handoff（交接）** | Agent 之间通过 git commit + 消息传递工作 | swarm-forge 持久化 handoff 协议 |
| **深层模块（Deep Module）** | 接口极简、内部藏大量复杂实现的模块 | Ousterhout《A Philosophy of Software Design》；对 AI 友好 |
| **战术编程 vs 战略编程** | 战术=快速跑通功能；战略=从全局设计系统 | Ousterhout 提出；Agent 擅长战术、不擅长战略 |
| **TDD（测试驱动开发）** | 先写测试再写代码的人类纪律 | Bob 曾是坚定拥护者；他认为 TDD 是"给短程记忆差的人设计的拐杖"，**不要强加给 Agent**（但价值观要强加，阈值要调）〔原稿〕 |
| **QA 程序（QA Procedures）** | 人写的自然语言测试手册，Agent 可转成可执行脚本 | Bob：Agent 写、人审（按关键性彻底审或抽查） |
| **规格驱动开发（Spec-driven）** | 先写超详细规格再让 AI 一次性实现 | Bob 判断对 Agent 行不通（"1 美元盖房子"） |
| **属性测试（Property-based Testing）** | 声明"任何输入都应满足的性质"，工具生成随机输入验证 | FsCheck（.NET）/Hypothesis（Python）/fast-check（JS） |
| **架构查看器（uml-viewer）** | 动态 UML 图，点击下钻到源码，CRAP/变异着色，依赖违规标红 | Bob 官方项目；配 Grok agent 做 what-if 提案 |
| **Vendor（引入第三方代码）** | 把上游工具克隆进本地并记录版本，不 fork | 本仓库对 Bob 上游工具的统一策略 |

## 来源标注
- 主要依据：docs/THEORY.md（其来源见该文档"来源"节：一手访谈原稿见 `docs/reference/`）、crap4clj README、swarm-forge README（2026-10-08 抓取）
