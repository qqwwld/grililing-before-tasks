# Agent Skills

> [English](./README.md) | 简体中文

一套可复用的 **agent skills**，适用于 [opencode](https://opencode.ai)。每个 skill 是一个独立文件夹，内含一份 `SKILL.md`，教 agent 可靠地做好一件事——澄清问题、创建新 skill、整理学习笔记、辅导学习、搜索网络，或清理 Windows 磁盘垃圾。

## Skills 列表

| Skill | 作用 |
| --- | --- |
| [`grilling`](./grilling) | 项目开始时通过结构化访谈建立共识，把结果沉淀成设计文档。适合任务不清晰、或你和 AI 的理解已经跑偏时使用。 |
| [`grilling-simple`](./grilling-simple) | 精简版：帮你厘清目标或困难背后真正要解决的问题，并找到最有用的下一步。 |
| [`skill-creator`](./skill-creator) | 创建或改进 agent skill。动手写之前先判断：真的需要一个可复用 skill 吗？ |
| [`learning-notes`](./learning-notes) | 把学习记录整理成问答式笔记，保留真实的推进过程、学习者疑问和理解变化。 |
| [`tutor`](./tutor) | 面向任意学科的循证辅导。教原理和独立运用，而不是套用固定教学流程。 |
| [`web-finder`](./web-finder) | 快速网络搜索：打开有希望的结果，交回你要的链接，或基于已打开来源给出答案。 |
| [`disk-junk-scan`](./disk-junk-scan) | 扫描诊断 Windows 磁盘缓存/垃圾文件并分级报告。扫描阶段只读，**删除必须经你明确指示才会执行**。 |

## 安装

把需要的 skill 文件夹复制到 opencode 的 skills 目录：

```bash
# Linux / macOS
cp -r grilling grilling-simple skill-creator ~/.config/opencode/skills/

# Windows (PowerShell)
Copy-Item grilling, grilling-simple, skill-creator -Destination "$env:USERPROFILE\.config\opencode\skills\" -Recurse
```

或者克隆整个仓库再挑着复制：

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
cp -r */ ~/.config/opencode/skills/
```

重启 opencode。skill 会依据各自的 `description` 字段被自动识别，不需要手动指定名称调用。

## 仓库结构

```
<skill-name>/
├── SKILL.md          # agent 加载的指令
├── references/       # 可选的参考资料
└── scripts/          # 可选的可执行脚本
```

只有需要真正执行操作的 skill 才会有 `scripts/` 目录。`disk-junk-scan` 里是用于扫描和清理的 PowerShell 脚本，且**不经你明确确认不会执行任何删除**。

## 许可协议

[MIT](./LICENSE)
