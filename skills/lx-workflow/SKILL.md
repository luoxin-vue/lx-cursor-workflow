---
name: lx-workflow
description: 介绍并导航 lx-cursor-workflow 的需求澄清、方案发散、计划、TDD 和 Subagent 执行流程。
disable-model-invocation: true
---

# lx 工作流导航

你现在进入的是 `lx-cursor-workflow`。先向用户说明下面的阶段和产物，不要替用户跳过确认门：

1. `/lx-grill`：逐个问题澄清目标、边界、约束和验收标准。
2. `/lx-brainstorm`：基于已澄清的问题，产生多个候选方案并比较取舍。
3. `/lx-writing-plan`：把已选方案写成有依赖、切面和验收条件的计划。
4. 用户明确确认计划后，才使用 `/lx-tdd` 或 `/lx-subagent`。
5. 实施后运行项目已有验证命令，并让用户审阅 diff。

## 统一规则

- 文档按需写入项目的 `docs/lx-workflow/`。
- 先读取 `docs/lx-workflow/CONTEXT.md`（如果存在）和其中相关 ADR。
- 发现术语冲突时，先指出冲突并让用户选择，不要静默重命名。
- 没有明确的“确认计划”时，不修改业务代码、不创建测试、不启动 Subagent。
- 任何并行建议都必须说明任务依赖、文件重叠和合并风险。

