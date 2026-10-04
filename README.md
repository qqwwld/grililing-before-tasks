# grilling-before-tasks

> English | [简体中文](./README.zh-CN.md)

Most failed tasks are not execution failures. They are specification failures — the work was done faithfully against an understanding that was never shared.

**Grilling before tasks** is the habit of establishing that shared understanding *before* acting. These are three opencode skills that implement it, in order of depth.

## The three skills

| Skill | When to use it |
| --- | --- |
| [`grilling-simple`](./grilling-simple) | **Triage.** You have a goal or a difficulty, but the real problem is still fuzzy. It identifies what actually needs solving and the single most useful next step. Lightest weight — use it by default. |
| [`grilling`](./grilling) | **Depth.** Starting a project, or user and AI understanding have drifted. A structured interview that surfaces goal, constraints, trade-offs and unknowns, then records the result as a design document you can execute against. |
| [`skill-creator`](./skill-creator) | **Codify.** The same clarity gap keeps recurring. It decides whether a reusable skill is actually justified, then writes the smallest one that changes behavior. |

The progression: **triage → depth → codify.** Reach for `grilling-simple` first; escalate to `grilling` when the stakes justify it; promote a recurring pattern into a skill with `skill-creator`.

## In progress

[`in-progress/`](./in-progress) holds skills that are still being shaped and are not part of the core workflow: `disk-junk-scan`, `learning-notes`, `tutor`, `web-finder`.

They ship in the repository but are deliberately not promoted to the top level.

## Installation

Copy the three skills into your opencode skills directory:

```bash
# Linux / macOS
cp -r grilling grilling-simple skill-creator ~/.config/opencode/skills/

# Windows (PowerShell)
Copy-Item grilling, grilling-simple, skill-creator -Destination "$env:USERPROFILE\.config\opencode\skills\" -Recurse
```

Restart opencode. Each skill is discovered from its `description` field — no need to invoke it by name.

## Layout

```
grilling-before-tasks/
├── grilling/           # deep, structured clarification → design doc
├── grilling-simple/    # light triage → real problem + next step
├── skill-creator/      # turn recurring gaps into reusable skills
└── in-progress/        # not yet promoted
```

## License

[MIT](./LICENSE)
