---
name: writing-skills
description: Author or revise a skill in this configuration repository — use when adding a skill, when an existing one is not triggering or triggers too often, or when deciding whether a piece of guidance belongs in a skill, an agent prompt, or AGENTS.md.
---

A skill is a procedure loaded on demand. It costs context every session through its description, and costs more when loaded, so it has to change behaviour to be worth having.

## Does this belong in a skill at all?

| Guidance | Where it belongs |
| --- | --- |
| Applies to every change, always | `opencode/AGENTS.md` |
| Defines one agent's role, output contract, and escalation rules | `opencode/agents/<agent>.md` |
| A procedure needed only in specific situations | a skill |
| An invocable multi-step request the user types | `opencode/commands/` |

If the content would duplicate an agent prompt, strengthen the prompt instead. Overlap between a skill and a prompt guarantees drift, and the reader cannot tell which is authoritative.

## The bar for content

Write only what the model would not already do. "Inspect the code before changing it", "prefer clear names", "validate input" are default behaviour — a skill made of these is pure overhead however well written.

What clears the bar:

- **A decision rule** that resolves a real fork: use X when A, Y when B.
- **A specific footgun** with its symptom and its fix — the `USING` versus `WITH CHECK` distinction, not "write careful policies".
- **A procedure** with an order that matters, where doing step three first breaks it.
- **A checklist** anchored to concrete failure modes rather than virtues.
- **Local specifics**: this repo's conventions, this stack's version-dependent behaviour, this tool's exact flag.

Test a draft by asking: if the model had not loaded this, what specifically would it get wrong? If there is no crisp answer, do not add the skill.

## Descriptions decide whether it works

Selection happens from the description alone. Name the **situation**, not the topic:

- Weak: "Apply TypeScript safety and repository-native type patterns." Matches every TypeScript change, so an on-demand skill becomes permanently on.
- Strong: "Resolve type problems without weakening safety — use when fighting a type error, designing a shared signature, or tempted to reach for `as` or `any`."

Include the trigger conditions and the symptoms a user would describe. Prefer naming the moment of use ("use when a test is flaky", "use when a page is reported slow") over the subject area. If two skills could both match a request, make each description say what the other is for.

## Shape

Keep it to roughly 40–80 lines. Past that it stops being read closely and starts duplicating itself. Front-load the rule; put rationale after it, and only where the rule is counterintuitive.

Use tables for decision matrices and checklists for verification steps — both are scanned reliably. Include a code example only where prose cannot convey the distinction, and keep it minimal and correct. Cross-reference sibling skills by name rather than restating them.

Be concrete about failure. "An update policy without `WITH CHECK` lets a user reassign their row to another tenant" teaches; "be careful with update policies" does not.

## Mechanics in this repo

One directory per skill under `opencode/skills/`, containing `SKILL.md`. The frontmatter `name` **must** match the directory name, and `description` must be present — `agentctl check` fails the build on either fault, because both break selection silently rather than loudly.

After adding or renaming a skill:

```bash
agentctl check
agentctl sync
```

`sync` is only needed if the skills directory link is not already in place; the link points at the directory, so new files inside it are picked up without re-syncing. Verify discovery with `opencode agent list`, whose resolved permissions include one entry per registered skill.

## Revising an existing skill

If a skill is not triggering, the description is wrong — rewrite it around situations and symptoms before touching the body. If it triggers constantly and adds nothing, either narrow the description or delete the skill. Deleting a skill that never changed an outcome is a real improvement, not a loss.
