# lx-cursor-workflow

一套面向 Cursor 的全局 AI 工程工作流：区分新需求和 Bug 修复，先澄清或复现问题，再沉淀计划，最后用 TDD 和 Subagent 小步实施。

## 工作流

```text
请求分类
   ├─ 新需求 → lx-grill
   │             ↓
   │         lx-brainstorm（可选）
   │             ↓
   └─ Bug   → lx-bugfix（fast / standard / deep）
                 ↓
             lx-brainstorm（根因/方案不清时可选）
                 ↓
          lx-writing-plan
                 ↓  用户确认计划
          lx-tdd / lx-subagent
                 ↓
          人工验收与代码审查
```

前半段只分析和写文档；没有明确确认计划，后半段不得改业务代码。

规范优先：在系统和用户明确范围允许的前提下，目标公司的编码规范、公共组件、模板页面、项目配置、测试构建和发布约定优先级最高。LX、Karpathy、Ponytail 和 CodeGraph 只负责提高开发效率与准确率，不能覆盖项目规范；无法协调的冲突会在计划阶段明确提出。本仓库只固化优先级和冲突处理方法，不把某一家公司的具体规则推广到所有项目。

## 先看完整效果

不要只看安装命令，先看一个从模糊需求到可执行任务的完整案例：

👉 [员工花名册高级筛选与自定义表头：一眼看懂 lx 工作流](docs/case-study-order-bulk-archive.md)

这个案例展示了每一步实际输入什么、Agent 应该问什么、会生成什么文档，以及什么时候才开始写测试和代码。

## 安装

### Windows PowerShell

```powershell
git clone https://github.com/luoxin-vue/lx-cursor-workflow.git
cd lx-cursor-workflow
.\install.ps1
```

如果要在指定项目中启用 CodeGraph 检测：

```powershell
.\install.ps1 -ProjectPath D:\Project\your-project
```

预览安装：

```powershell
.\install.ps1 -WhatIf
```

### macOS / Linux

```bash
git clone https://github.com/luoxin-vue/lx-cursor-workflow.git
cd lx-cursor-workflow
./install.sh
```

如果要在指定项目中启用 CodeGraph 检测：

```bash
./install.sh --project /path/to/your-project
```

安装器写入 Cursor 官方支持的用户级目录：

```text
Windows: %USERPROFILE%\\.cursor\\skills\\
macOS/Linux: ~/.cursor/skills/
```

安装器只新增清单中的工作流目录（包括 `lx-*`、`karpathy-guidelines` 和 `ponytail`）。目标目录已经存在且内容不同就报告冲突并停止，不覆盖任何个人 Skill；内容相同则跳过。

安装完成后，如果指定项目没有 `.codegraph`，安装器会展示 CodeGraph 的用途并询问是否安装最新 CLI 到个人全局。选择确认后会安装 CLI 并执行 `codegraph init` 建立该项目的本地索引；选择拒绝则只跳过 CodeGraph，不影响工作流安装。安装器不会自动修改其他 Agent 的全局配置。

## 使用

新需求在 Cursor Agent 中按顺序输入：

```text
/lx-workflow
/lx-grill
/lx-brainstorm
/lx-writing-plan
```

Bug 修复从专用入口开始：

```text
/lx-workflow
/lx-bugfix
```

它会先固定复现事实、定位根因并选择 `fast`、`standard` 或 `deep` 模式；根因和修复方向不清晰时再使用 `/lx-brainstorm`。简单 Bug 不会被强行拉成长流程。

速度规则：单字段、单参数、单函数或单条件 Bug，入口明确且有稳定断言时默认走 `fast`。前端调用后端不自动升级；只有接口契约未知、真实响应矛盾、竞态/权限/数据风险或范围扩大时才进入 `standard/deep`。快路径仍保留项目规范、CodeGraph、回归断言、轻量计划确认和必要验证。

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
skills/                  全局安装的 Cursor Skills（含需求、Bug 修复和编码约束入口）
docs/spec.md             本项目规格
docs/CONTEXT.md          术语表
docs/adr/                 关键架构决策
scripts/                  本地验证脚本
install.ps1 / install.sh  安装器
uninstall.ps1 / ...       卸载器
```

## 上游致谢

本项目的工作流思想和部分规范参考 Matt Pocock 的公开 Skills，并以独立的 `lx-*` 命名空间重新组织和补充中文说明。请见 [NOTICE.md](NOTICE.md) 与 [LICENSE](LICENSE)。
