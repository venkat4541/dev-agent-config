---
description: Produce an evidence-based implementation plan without editing
agent: architect
---

Create an implementation plan for: $ARGUMENTS

First inspect local instructions and relevant code. Preserve established architecture. State scope, affected files, design choices, API/data/RLS implications, test plan, migration/deployment concerns, risks, and which parts (if any) are genuinely independent enough for separate worktrees. Recommend the specialist agents for implementation, verification, and independent review by name; their models are set centrally in `opencode.jsonc`. Do not implement.

If the request is underspecified enough that two readings would produce different work, use the `brainstorming` skill to settle it before planning. For a high-risk or hard-to-reverse plan, hand the finished plan to `/grill` before implementation.
