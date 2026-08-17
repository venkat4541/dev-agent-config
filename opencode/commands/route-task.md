---
description: Classify a request by scope and recommend the least-cost safe agent route
agent: explorer
---

Classify this request before implementation: $ARGUMENTS

Inspect relevant local instructions, architecture, conventions, affected boundaries, and existing tests. Do not edit files. Classify it as one of:

- `quick-fix`: a well-understood, localized bug with a focused regression test; recommend the `quick-fix` agent.
- `bounded-change`: a coherent implementation affecting one primary boundary; recommend the appropriate implementation specialist (`frontend`, `backend`, `database`, or `implementer`).
- `feature`: cross-boundary behavior, significant uncertainty, or non-trivial design; recommend `architect` planning, then the appropriate implementation specialists.
- `high-risk`: authentication, authorization, RLS, migrations, sensitive data, production incidents, or difficult debugging; recommend `architect` planning plus independent `reviewer` and `security-reviewer` passes alongside the relevant specialists.

Recommend agents by name only. Each agent's model is set centrally in `opencode.jsonc`; naming a model here would go stale the moment routing changes.

Return evidence by path, the recommended agents, required verification, risks, and whether separate Superset worktrees are justified. Prefer the least complex route that is safe; never use scope classification as a reason to skip tests or security review.
