# lx-cursor-workflow

一套面向 Cursor 的全局 AI 工程工作流：先把想法问清楚，再发散方案、沉淀计划，最后用 TDD 和 Subagent 小步实施。

## 工作流

```text
lx-grill
   ↓
lx-brainstorm
   ↓
lx-writing-plan
   ↓  用户确认计划
lx-tdd / lx-subagent
   ↓
人工验收与代码审查
```

前半段只分析和写文档；没有明确确认计划，后半段不得改业务代码。

## 安装

### Windows PowerShell

```powershell
git clone https://github.com/<你的用户名>/lx-cursor-workflow.git
cd lx-cursor-workflow
.\install.ps1
```

预览安装：

```powershell
.\install.ps1 -WhatIf
```

### macOS / Linux

```bash
git clone https://github.com/<你的用户名>/lx-cursor-workflow.git
cd lx-cursor-workflow
./install.sh
```

安装器写入 Cursor 官方支持的用户级目录：

```text
Windows: %USERPROFILE%\\.cursor\\skills\\
macOS/Linux: ~/.cursor/skills/
```

安装器只新增 `lx-*` 目录。目标目录已经存在且内容不同就报告冲突并停止，不覆盖任何个人 Skill；内容相同则跳过。

## 使用

在 Cursor Agent 中按顺序输入：

```text
/lx-workflow
/lx-grill
/lx-brainstorm
/lx-writing-plan
```

阅读并确认 `docs/lx-workflow/plans/` 中的计划后，再输入：

```text
/lx-tdd
/lx-subagent
```

推荐先在一个真实但范围小的功能上演示，展示每个阶段的输入、产物和人工确认点。

## 卸载

```powershell
.\install.ps1 -Uninstall
```

或：

```bash
./uninstall.sh
```

卸载器只删除本安装器记录且未被用户修改的目录；被修改过的目录会保留并报告。

## 目录

```text
skills/                  全局安装的 Cursor Skills
docs/spec.md             本项目规格
docs/CONTEXT.md          术语表
docs/adr/                 关键架构决策
scripts/                  本地验证脚本
install.ps1 / install.sh  安装器
uninstall.ps1 / ...       卸载器
```

## 上游致谢

本项目的工作流思想和部分规范参考 Matt Pocock 的公开 Skills，并以独立的 `lx-*` 命名空间重新组织和补充中文说明。请见 [NOTICE.md](NOTICE.md) 与 [LICENSE](LICENSE)。

