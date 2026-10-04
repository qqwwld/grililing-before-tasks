---
name: skill-creator
description: Create or refine effective agent skills. Use when the user explicitly asks to create a new skill or revise an existing skill.
---

First determine whether a reusable skill is actually needed. Prefer ordinary context or instructions when they are sufficient. A skill is justified when a recurring need or meaningful behavior gap benefits from reusable guidance or resources.

Define the behavior the skill must make reliable, then create the smallest skill that achieves it.

Assume a capable model. Include only information that materially changes behavior, improves reliability, or cannot be inferred.

First align:

- **Purpose & Trigger** — what the skill is for and when it should apply
- **Intended Behavior** — what the agent should do differently when the skill is active
- **Success Criteria** — what observable behavior would show that the skill is working

Then identify only the additional details needed to make that behavior reliable, such as inputs, workflow, sources, outputs, constraints, quality criteria, or bundled resources.

Start from the conversation, existing skills, project files, examples, tools, and other available evidence. **Facts are the agent's job to find. Material design decisions are the user's to make; low-risk, reversible implementation details may be handled by the agent.**

Before each question, reason backward from the intended behavior and success criteria, starting from first principles: reduce to the user's underlying need and purpose, then derive the minimal path that satisfies it instead of inheriting conventions or analogies:

1. What must still be known or decided for the skill to reliably produce the intended behavior?
2. What is already known or can be discovered from available evidence?
3. Which remaining uncertainties or decisions could materially change the skill's behavior, trigger, constraints, or success?
4. Which of those are factual questions the agent can resolve, and which are material design decisions that require the user's judgment?
5. Which unresolved design decision is most upstream and should be aligned first?

Resolve discoverable facts yourself. For material design decisions, surface relevant options and trade-offs, give a recommendation when useful, and let the user decide. Handle low-risk, reversible implementation details without unnecessary questioning.

Ask **one question at a time**, then reassess based on the new answer or evidence. Resolve upstream design decisions before dependent details. When intended behavior is ambiguous, use concrete usage examples, contrasts, or boundaries to align it.

Once the design is aligned, derive the simplest reliable implementation.

Use only as much structure as necessary:
- keep context-dependent behavior flexible;
- make recurring or failure-prone decisions explicit;
- use `references/` for detailed or conditional knowledge that should be loaded when needed;
- use `scripts/` for repeated or deterministic operations;
- use `assets/` only for files needed in outputs.

Use the minimal skill template as a scaffold:

```markdown
---
name: skill-name
description: What the skill does and when to use it.
---

[Only the instructions needed to produce the intended behavior.]
```

Write the skill as concise, imperative guidance for another capable agent. Add constraints only where model freedom could cause meaningful failure, and avoid generalizing isolated examples, preferences, or past failures into universal rules. Remove instructions that do not meaningfully change behavior.

When revising an existing skill, do not assume the requested change is correct. Challenge the revision from first principles: return to the underlying need and purpose the change is meant to serve, and derive the minimal path from there. Ask:

1. How should the skill be modified to bring it closest to the user's goal?
2. What observed failure or recurring need motivates this change, and does the skill actually fail to produce the intended behavior?
3. Is each existing instruction accurate, consistent, and unambiguous for a capable agent to execute?
4. Does each instruction materially change behavior, or can it be removed or merged without effect?
5. Is the proposal the **minimal change** that closes the confirmed gaps and preserves all working behavior?

Resolve these from evidence where possible and report what you find. Preserve what already works, propose the **minimal change** that closes the confirmed gaps, and modify the skill only after the user reviews and approves that change.

Test the resulting skill against a few representative cases, preferably in isolated runs when available. Check whether it produces the intended behavior and meets the success criteria. When useful, compare it with the baseline behavior without the skill to confirm that the skill adds meaningful value. Revise only in response to observed failures or recurring needs rather than speculative ones.

Stop when further changes are unlikely to materially improve the skill. Prefer the smallest skill that reliably meets the success criteria.