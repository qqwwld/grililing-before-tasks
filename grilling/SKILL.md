---
name: grilling
description: Build the shared understanding needed to achieve the user's goal by clarifying the task, execution path, and necessary information through questioning, while recording the result in a design document. Use when starting a project, when the task is unclear, or when user–AI understanding has drifted.
---

Build enough shared understanding to support reliable execution and achieve the user's real goal through interviewing user.

Start from the conversation, project files, existing docs, code, tool results, and other available evidence. **Facts are the AI's job to find. Ask the user only for information that requires their intent, preference, judgment, trade-off, or decision.**

First align the essential information, don't give execution path before you align these information:

- **Goal** — what the user actually wants to achieve
- **Current state** — existing work, approaches and attempts, relevant facts, conditions, and available resources
- **Constraints** — requirements and limits that affect the solution
- **Output requirements** — what must ultimately be delivered
- **Success criteria** — observable results that show the goal has been achieved
- **Blockers** — what currently stands between the present state and the goal, including where the existing approach breaks down and the evidence for it

Before each question, reason backward from the goal:

1. What must still be known or decided to achieve the goal well?
2. What is already known or can be discovered from the project, tools, or evidence?
3. Which remaining unknowns could materially affect the execution path, constraints, output, or result?
4. Which of those genuinely require the user's input?
5. Which unresolved question is most upstream and should be resolved first?

Ask **one question at a time**, then reassess based on the new answer and evidence. Resolve upstream uncertainty before dependent details.

When an important concept is ambiguous in a way that could affect execution, align its meaning with a concise example, contrast, boundary, or restatement.

Before presenting an execution plan, summarize the design document's six aligned dimensions with assumptions and open questions, and wait for explicit user confirmation. After confirmation, compare feasible paths against the aligned goal, conditions, and bottleneck; recommend the best-supported path with its necessary scope and validation. Re-align direction-changing premises before finalizing; keep preliminary paths provisional.

Do not change the user's goal, constraints, or confirmed decisions without explicit agreement.

Maintain one concise design document using [the document format](references/design-doc.md). Record only information that materially helps achieve the goal or guide later execution: aligned goals, facts, constraints, output requirements, success criteria, blockers, execution path, key decisions, and other necessary information.

Update the document when the shared understanding materially changes. Organize it according to the document format; do not mechanically summarize the conversation or preserve irrelevant discussion history.

Stop questioning when the user and AI share enough understanding for reliable execution, and the remaining uncertainty is unlikely to cause meaningful deviation from the user's goal.