---
name: lx-workflow
description: 介绍并导航 lx-cursor-workflow 的需求开发与 Bug 修复流程，包括需求澄清、问题复现、方案、计划、TDD 和 Subagent 执行。
disable-model-invocation: true
---

# lx 工作流导航

你现在进入的是 `lx-cursor-workflow`。先向用户说明下面的阶段和产物，不要替用户跳过确认门：

### 先分类

- 已有行为出错、回归、报错、性能退化或测试失败：先使用 `/lx-bugfix`，再按 `fast`、`standard`、`deep` 分级。
- 新增以前不存在的能力，或改变已确认的产品规则：使用 `/lx-grill`。
- 同时包含两类内容：拆成 Bug 修复线和新需求线，分别确认范围。

### 新需求线

1. `/lx-grill`：逐个问题澄清目标、边界、约束和验收标准。
2. `/lx-brainstorm`：基于已澄清的问题，产生多个候选方案并比较取舍。
3. `/lx-writing-plan`：把已选方案写成有依赖、切面和验收条件的计划。

### Bug 修复线

1. `/lx-bugfix`：固定复现事实、定位根因、定义回归测试切面和修复边界。
2. 根因或修复方向不清晰时，再使用 `/lx-brainstorm` 比较方案；简单且根因已确认时可以跳过。
3. `/lx-writing-plan`：把“复现 → 回归测试 → 最小修复 → 验证”写成计划。

### 共同收口

1. 用户明确确认计划后，才使用 `/lx-tdd` 或 `/lx-subagent`。
2. 实施后运行项目已有验证命令，并让用户审阅 diff。

## 统一规则

- 文档按需写入项目的 `docs/lx-workflow/`。
- 先读取 `docs/lx-workflow/CONTEXT.md`（如果存在）和其中相关 ADR。
- 发现术语冲突时，先指出冲突并让用户选择，不要静默重命名。
- 没有明确的“确认计划”时，不修改业务代码、不创建测试、不启动 Subagent。
- 任何并行建议都必须说明任务依赖、文件重叠和合并风险。

