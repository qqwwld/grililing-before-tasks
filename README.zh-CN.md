# grilling-before-tasks

> [English](./README.md) | 简体中文

大多数失败的任务不是执行失败，而是**定义失败**——活儿干得很忠实，只是对着一个从没对齐过的理解在干。

**grilling-before-tasks**：先对齐，再动手。这是实现这一习惯的三个 opencode skills，按深度排列。

## 三个核心 skills

| Skill | 什么时候用 |
| --- | --- |
| [`grilling-simple`](./grilling-simple) | **分诊。** 你有目标或困难，但真正要解决的问题还很模糊。它帮你厘清问题本质，并定位最有用的下一步。最轻量，默认先用它。 |
| [`grilling`](./grilling) | **深挖。** 项目刚起步，或你和 AI 的理解已经跑偏。通过结构化访谈对齐目标、约束、权衡与未知，最后沉淀成一份可执行的设计文档。 |
| [`skill-creator`](./skill-creator) | **固化。** 同样的理解缺口反复出现。它先判断是否真值得做一个可复用 skill，再写出能真正改变行为的最小实现。 |

递进关系：**分诊 → 深挖 → 固化。** 先用 `grilling-simple`；值得投入时升级到 `grilling`；模式反复出现就用 `skill-creator` 固化下来。

## 进行中

[`in-progress/`](./in-progress) 放尚未打磨完成、不属于核心流程的 skills：`disk-junk-scan`、`learning-notes`、`tutor`、`web-finder`。

它们保留在仓库里，但刻意没有提升到顶层。

## 安装

把三个核心 skill 复制到 opencode 的 skills 目录：

```bash
# Linux / macOS
cp -r grilling grilling-simple skill-creator ~/.config/opencode/skills/

# Windows (PowerShell)
Copy-Item grilling, grilling-simple, skill-creator -Destination "$env:USERPROFILE\.config\opencode\skills\" -Recurse
```

重启 opencode。skill 会依据各自的 `description` 字段被自动识别，不需要手动指定名称调用。

## 仓库结构

```
grilling-before-tasks/
├── grilling/           # 深度结构化澄清 → 设计文档
├── grilling-simple/    # 轻量分诊 → 真实问题 + 下一步
├── skill-creator/      # 把反复出现的缺口固化为 skill
└── in-progress/        # 尚未提升为核心的部分
```

## 许可协议

[MIT](./LICENSE)
