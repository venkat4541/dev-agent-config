---
description: Classify a request by scope and recommend the least-cost safe agent and model route
agent: explorer
---

Classify this request before implementation: $ARGUMENTS

Inspect relevant local instructions, architecture, conventions, affected boundaries, and existing tests. Do not edit files. Classify it as one of:

- `quick-fix`: a well-understood, localized bug with a focused regression test; recommend `quick-fix` (GPT-5.6 Luna).
- `bounded-change`: a coherent implementation affecting one primary boundary; recommend the appropriate implementation specialist (Kimi K2.7 Code).
- `feature`: cross-boundary behavior, significant uncertainty, or non-trivial design; recommend `architect` planning (GLM-5.3), then the appropriate implementation specialists.
- `high-risk`: authentication, authorization, RLS, migrations, sensitive data, production incidents, or difficult debugging; recommend architecture plus independent security/review and relevant specialists (GLM-5.3 review, Kimi K2.7 Code implementation).

Return evidence by path, the recommended agents and models, required verification, risks, and whether separate Superset worktrees are justified. Prefer the least complex route that is safe; never use scope classification as a reason to skip tests or security review.
