# grilling-before-tasks

> [English](./README.md) | 简体中文

![Agent Skills](https://img.shields.io/badge/Agent%20Skills-open%20standard-2f6f4f)
![License](https://img.shields.io/badge/license-MIT-blue)

大多数失败的任务不是执行失败，而是**定义失败**——活儿干得很忠实，只是对着一个从没对齐过的理解在干。

这三个 skills 强制一个习惯：**先对齐，再动手**。它们遵循 [Agent Skills](https://skill.md) 开放格式，任何兼容的 agent 都能用。

## 三个核心 skills

一个思想，三个场景。

| Skill | 什么时候用 | 你会得到 |
| --- | --- | --- |
| [`grilling`](./grilling) | **复杂长任务即将开跑**，或你和 agent 的理解已经跑偏 | 一份设计文档——目标、约束、障碍、执行路径——agent 照着执行 |
| [`grilling-simple`](./grilling-simple) | **快速理清一个思路** | 真正要解决的问题 + 最有用的下一步 |
| [`skill-creator`](./skill-creator) | 正在写或改一个 skill | 一份先对齐再写就的最小 skill |

**共同的骨架。** 三者一致：事实由 agent 自己去查，只把需要你判断的决定交给你；一次只问一个问题；从目标反向推理；先解决上游问题，再处理下游依赖。`skill-creator` 就是把这套方法用在写 skill 上。

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

多数 agent 不需要重启——依据各自的 `description` 字段识别，任务匹配时才加载。

## 工作原理

Skills 采用[渐进式披露](https://skill.md)：启动时 agent 只看得到名称和描述，只有任务匹配时才读入完整指令。三个全带着也几乎不占上下文。

## 进行中

[`in-progress/`](./in-progress) 放四个尚在打磨的 skills——`disk-junk-scan`、`learning-notes`、`tutor`、`web-finder`。它们保留在仓库里，但刻意没有进入核心流程。

## 参与贡献

欢迎 issue 和 PR。新增 skill 前先想想：普通指令是不是就够了——[`skill-creator`](./skill-creator) 就是判断这件事的标准。

## 许可协议

[MIT](./LICENSE)
