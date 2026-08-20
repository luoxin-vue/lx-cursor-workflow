---
name: lx-writing-plan
description: 把已确认的需求和方案拆成可执行、可验证、有依赖关系的实施计划，并写入 docs/lx-workflow/plans/。
disable-model-invocation: true
---

# lx Writing Plan：把方案变成任务

## 前置条件

- 读取 `docs/lx-workflow/CONTEXT.md` 和相关 ADR（如果存在）。
- 检查当前对话中是否已经确认目标、范围、方案和验收方向；缺少关键决策时，停止并指出缺口。
- 不把“看起来合理”当成用户确认。

## 计划内容

在 `docs/lx-workflow/plans/` 创建一个描述性 Markdown 文件，包含：

- 背景、目标和明确的非目标；
- 已确认的方案和关键实现决策；
- 任务清单，每项只包含一个可交付的垂直切片；
- 任务之间的阻塞关系和可并行关系；
- 每项任务的公共测试切面、验收条件和验证命令；
- 需要用户决策的事项；
- 风险、回滚方式和完成定义。

## 确认门

计划写完后，在文件中加入：

```yaml
plan_status: awaiting-user-confirmation
```

等待用户明确回复“确认计划”或等价表达。只有确认后，才将状态改为 `plan_status: approved`，并允许使用 `lx-tdd` 或 `lx-subagent`。

本 Skill 不写业务代码、不创建测试、不启动 Subagent。

