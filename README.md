# Agent Skills

> English | [简体中文](./README.zh-CN.md)

A collection of reusable **agent skills** for [opencode](https://opencode.ai). Each skill is a self-contained folder with a `SKILL.md` that teaches an agent how to do one thing reliably — clarify a problem, create a new skill, take learning notes, tutor, search the web, or clean up a Windows disk.

## Skills

| Skill | What it does |
| --- | --- |
| [`grilling`](./grilling) | Build shared understanding at the start of a project through structured interviewing, and record the result as a design document. Use when the task is unclear or user–AI understanding has drifted. |
| [`grilling-simple`](./grilling-simple) | A lighter version: clarify the real problem behind a goal or difficulty and identify the most useful next step. |
| [`skill-creator`](./skill-creator) | Create or refine agent skills. Decides whether a reusable skill is actually needed before writing one. |
| [`learning-notes`](./learning-notes) | Turn learning records into Q&A notes that preserve the actual progression, doubts, and changes in understanding. |
| [`tutor`](./tutor) | Adaptive, evidence-based tutoring for any subject. Teaches principles and independent application rather than imposing a fixed workflow. |
| [`web-finder`](./web-finder) | Fast web search that opens promising results and hands back either the link you are after or an answer built from opened sources. |
| [`disk-junk-scan`](./disk-junk-scan) | <div lang="zh-CN">扫描诊断 Windows 磁盘缓存/垃圾文件，分级报告。扫描阶段只读，删除必须经用户明确确认。</div> |

## Installation

Copy the skill folders you want into your opencode skills directory:

```bash
# Linux / macOS
cp -r grilling grilling-simple skill-creator ~/.config/opencode/skills/

# Windows (PowerShell)
Copy-Item grilling, grilling-simple, skill-creator -Destination "$env:USERPROFILE\.config\opencode\skills\" -Recurse
```

Or clone the whole repository and copy what you need:

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
cp -r */ ~/.config/opencode/skills/
```

Restart opencode. The skills are picked up automatically from their `description` field — you do not need to invoke them by name.

## Repository layout

```
<skill-name>/
├── SKILL.md          # Instructions the agent loads
├── references/       # Optional supporting material
└── scripts/          # Optional runnable scripts
```

`scripts/` is only present where a skill needs to execute something. `disk-junk-scan` contains PowerShell scripts for scanning and cleaning; nothing runs without your explicit confirmation.

## License

[MIT](./LICENSE)
