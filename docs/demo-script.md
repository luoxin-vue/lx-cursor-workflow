# 技术分享演示脚本

## 1. 先说明痛点（2 分钟）

“Agent 不是不会写代码，而是经常在需求还没说清楚时就开始写。我们把工作拆成四个阶段，每个阶段都有产物和人工确认点。”

## 2. 展示安装（2 分钟）

```powershell
.\install.ps1 -WhatIf
.\install.ps1
```

强调三件事：全局用户目录、`lx-` 前缀、冲突不覆盖。

## 3. Grill（5 分钟）

在 Cursor 输入：

```text
/lx-grill 我想给订单列表增加批量归档能力
```

演示 Agent 一次只问一个问题，并把术语、边界和验收标准收敛下来。

## 4. Brainstorm（4 分钟）

```text
/lx-brainstorm
```

让 Agent 产生三个方向，比较实现成本、用户体验、数据一致性和回滚风险。

## 5. Writing plan（4 分钟）

```text
/lx-writing-plan
```

展示 `docs/lx-workflow/plans/` 中的垂直任务、测试切面和依赖关系。指出此时还没有改业务代码。

## 6. 计划确认门（1 分钟）

用户明确输入：

```text
确认计划，可以进入实现阶段。
```

## 7. TDD / Subagent（6 分钟）

```text
/lx-tdd
/lx-subagent
```

展示一个 Red → Green → Refactor 切片，再说明什么条件下允许并行 Subagent。

## 8. 收尾（2 分钟）

回顾每个阶段的输入、输出、确认点和反馈回路。最后展示测试结果与 diff，让大家看到“可控”比“自动”更重要。

