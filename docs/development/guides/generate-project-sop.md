# SOP：生成新项目（generate-project-sop）

> **文档类型**：Process（操作流程）
> **更新频率**：生成器/模板变更时
> **维护者**：AI自动维护
> **读者**：AI代理（执行生成任务前）

---

## 1. 何时用

用户说"用 clean-code-gauntlet 生成一个 XX 项目"、"用这套理论开发"时。**必须走生成器，不要手搓项目结构**（AGENTS.md §3.3）。

## 2. 前置

- `tooling/bin/install-tools.sh` 已跑过（上游工具 vendor 到 `tooling/vendor/`，生成的项目要用它们跑质量关卡）。

## 3. 执行步骤

```bash
tooling/bin/generate-project.sh
```

问答式输入：
1. **项目名**：小写字母/数字/短横线（如 `my-service`）；
2. **语言**：clojure / java / go / typescript / python / rust；
3. **流水线**：two-pack / four-pack / six-pack（默认 six-pack，完整六角色，推荐）；
4. **CI 模板**：Y/n。

## 4. 产物检查（生成后必查，可能失败处重点）

- [ ] `generated/<项目名>/` 存在，且含 `README.md`、`AGENTS.md`、`quality-gates/`、`constitution/`、`roles/`、`docs/`、`src/`、`test/`；
- [ ] **占位符已全部替换**：`grep -r '{{' generated/<项目名>/` 应为空；
- [ ] quality-gates 命令与所选语言匹配（对照 `templates/project/quality-gates/README.md` 命令映射）；
- [ ] 若选了"不带 CI"：`quality-gates/ci.yml` 不存在；
- [ ] 六角色 prompts 齐全（six-pack：specifier/coder/cleaner/architect/hardender/QA）。

## 5. 生成后引导用户

输出"下一步"（见生成器末尾打印）：
1. `cd generated/<项目名>`
2. 安装上游工具（若尚未安装）
3. `get-swarm-forge six-pack && ./swarm` 启动流水线
4. 提交 New Task 给 specifier，**人工审批**其 Gherkin 与 QA 程序

## 6. 排错

| 现象 | 处理 |
|------|------|
| 项目名含非法字符 | 提示只允许小写字母/数字/短横线，重新输入 |
| 输出目录已存在 | 换名或先确认清理（不擅自删除） |
| sed 替换失败 | 检查模板文件占位符拼写与脚本 sed 表达式一致 |
| 生成后占位符残留 | 手动补齐替换或修模板/脚本后重新生成 |

## 7. 维护联动

- 上游流水线变化（swarm-forge 新 pack/角色）→ 更新 `templates/project/constitution/`、`roles/`、本 SOP §4 检查项；
- 工具命令变化（crapper/mutator 等）→ 更新 `templates/project/quality-gates/README.md` 与生成器内的工具映射表；
- 任何模板改动 → 实跑一次生成器验证（AGENTS.md §3.5）。
