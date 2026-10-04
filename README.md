# grilling-before-tasks

> English | [简体中文](./README.zh-CN.md)

![Agent Skills](https://img.shields.io/badge/Agent%20Skills-open%20standard-2f6f4f)
![License](https://img.shields.io/badge/license-MIT-blue)

Most failed tasks are not execution failures. They are **specification failures** — the work was done faithfully against an understanding that was never shared.

These three skills enforce the habit of establishing shared understanding *before* acting.

## Core skills

One idea, three situations.

| Skill | Reach for it when | You come away with |
| --- | --- | --- |
| [`grilling`](./grilling) | A complex or long-running task is about to start, or you and the agent have drifted apart | A design doc — goal, constraints, blockers, execution path — that the agent executes against |
| [`grilling-simple`](./grilling-simple) | You need to think a problem through quickly | The real problem, plus the single most useful next step |
| [`skill-creator`](./skill-creator) | You are writing or revising a skill | A minimal skill, aligned before it is written |

## Install

**Option A — the `skills` CLI (installs to every agent you have):**

```bash
npx skills add qqwwld/grililing-before-tasks -g -y -s grilling grilling-simple skill-creator
```

**Option B — copy the folders yourself:**

```bash
git clone https://github.com/qqwwld/grililing-before-tasks.git
cp -r grililing-before-tasks/grilling grililing-before-tasks/grilling-simple grililing-before-tasks/skill-creator ~/.agents/skills/
```

Agents discover skills from a few standard locations:

| Agent | Path |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| OpenCode | `~/.config/opencode/skills/` or `~/.agents/skills/` |
| Codex, Gemini CLI | `~/.agents/skills/` |
| Cursor | `~/.cursor/skills/` |
| Project-level (any) | `.claude/skills/`, `.opencode/skills/`, `.agents/skills/` |

## In progress

[`in-progress/`](./in-progress) holds four skills still being shaped — `disk-junk-scan`, `learning-notes`, `tutor`, `web-finder`. They ship in the repository but are deliberately not promoted to the core workflow.

## License

[MIT](./LICENSE)
