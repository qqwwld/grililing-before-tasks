# grilling-before-tasks

> English | [简体中文](./README.zh-CN.md)

![Agent Skills](https://img.shields.io/badge/Agent%20Skills-open%20standard-2f6f4f)
![License](https://img.shields.io/badge/license-MIT-blue)

Most failed tasks are not execution failures. They are **specification failures** — the work was done faithfully against an understanding that was never shared.

These three skills enforce the habit of establishing shared understanding *before* acting. They follow the [Agent Skills](https://skill.md) open format, so they work in any compatible agent.

## The three skills

Reach for them in this order:

| Skill | Stage | Use it when |
| --- | --- | --- |
| [`grilling-simple`](./grilling-simple) | **Triage** | You have a goal or a difficulty, but the real problem is still fuzzy. Identifies what actually needs solving and the single most useful next step. Start here. |
| [`grilling`](./grilling) | **Depth** | Starting a project, or you and the agent have drifted. A structured interview over goals, constraints, trade-offs and unknowns, recorded as a design doc you can execute against. |
| [`skill-creator`](./skill-creator) | **Codify** | The same clarity gap keeps recurring. Decides whether a reusable skill is justified, then writes the smallest one that changes behavior. |

**Triage → Depth → Codify.** Escalate only when the stakes justify it; promote a recurring pattern into a skill.

## Install

**Option A — the `skills` CLI (installs to every agent you have):**

```bash
npx skills add <owner>/<repo> -g -y -s grilling grilling-simple skill-creator
```

**Option B — copy the folders yourself:**

```bash
git clone https://github.com/<owner>/<repo>.git
cp -r <repo>/grilling <repo>/grilling-simple <repo>/skill-creator ~/.agents/skills/
```

Agents discover skills from a few standard locations:

| Agent | Path |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| OpenCode | `~/.config/opencode/skills/` or `~/.agents/skills/` |
| Codex, Gemini CLI | `~/.agents/skills/` |
| Cursor | `~/.cursor/skills/` |
| Project-level (any) | `.claude/skills/`, `.opencode/skills/`, `.agents/skills/` |

No restart needed in most agents — each skill is picked up from its `description` field and loaded only when a task matches.

## How it works

Skills use [progressive disclosure](https://skill.md): at startup the agent sees only each skill's name and description, and reads the full instructions only when a task matches. Carrying all three costs almost no context.

## In progress

[`in-progress/`](./in-progress) holds four skills still being shaped — `disk-junk-scan`, `learning-notes`, `tutor`, `web-finder`. They ship in the repository but are deliberately not promoted to the core workflow.

## Contributing

Issues and PRs welcome. Before writing a new skill, check whether a plain instruction would do — [`skill-creator`](./skill-creator) is the test for that.

## License

[MIT](./LICENSE)
