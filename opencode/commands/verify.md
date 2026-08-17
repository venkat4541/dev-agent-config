---
description: Verify a change using the repository's actual tooling
agent: tester
---

Verify: $ARGUMENTS

Discover the repository's package manager and supported scripts before running anything. Execute the focused checks first, then appropriate typecheck, lint, test, and production build commands. Do not alter application code merely to make checks pass. Report exact commands, results, failures, and coverage gaps.

