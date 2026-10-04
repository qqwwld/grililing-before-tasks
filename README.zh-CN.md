# grilling-before-tasks

> [English](./README.md) | 简体中文

![Agent Skills](https://img.shields.io/badge/Agent%20Skills-open%20standard-2f6f4f)
![License](https://img.shields.io/badge/license-MIT-blue)

大多数失败的任务不是执行失败，而是**定义失败**——活儿干得很忠实，只是对着一个从没对齐过的理解在干。

这三个 skills 强制一个习惯：**先对齐，再动手**。

## 核心 skills

一个思想，三个场景。

| Skill | 什么时候用 | 你会得到 |
| --- | --- | --- |
| [`grilling`](./grilling) | **复杂长任务即将开跑**，或你和 agent 的理解已经跑偏 | 一份设计文档——目标、约束、障碍、执行路径——agent 照着执行 |
| [`grilling-simple`](./grilling-simple) | **快速理清一个思路** | 真正要解决的问题 + 最有用的下一步 |
| [`skill-creator`](./skill-creator) | 正在写或改一个 skill | 一份先对齐再写就的最小 skill |

## 安装

**方式 A —— `skills` CLI（一次装到你所有 agent）：**

```bash
npx skills add <owner>/<repo> -g -y -s grilling grilling-simple skill-creator
```

**方式 B —— 手动复制文件夹：**

```bash
git clone https://github.com/<owner>/<repo>.git
cp -r <repo>/grilling <repo>/grilling-simple <repo>/skill-creator ~/.agents/skills/
```

各 agent 的标准查找路径：

| Agent | 路径 |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| OpenCode | `~/.config/opencode/skills/` 或 `~/.agents/skills/` |
| Codex、Gemini CLI | `~/.agents/skills/` |
| Cursor | `~/.cursor/skills/` |
| 项目级（通用） | `.claude/skills/`、`.opencode/skills/`、`.agents/skills/` |

## 进行中

[`in-progress/`](./in-progress) 放四个尚在打磨的 skills——`disk-junk-scan`、`learning-notes`、`tutor`、`web-finder`。它们保留在仓库里，但刻意没有进入核心流程。

## 许可协议

[MIT](./LICENSE)
