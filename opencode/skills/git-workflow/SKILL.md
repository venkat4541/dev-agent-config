---
name: git-workflow
description: Use focused, reviewable Git changes and safe worktree handoffs.
---

Inspect status and diff before editing. Keep one independently mergeable unit of work per branch/worktree and do not rewrite unrelated history.

Create a durable Git checkpoint at these points:

- After project onboarding, architecture records, or Superset setup that other worktrees need.
- After a coherent, verified implementation unit that can be independently reviewed or merged.
- Before handing a task to another agent, moving to another Mac, or creating worktrees that depend on the branch.

At each checkpoint, inspect `git status` and `git diff`, confirm ignored/local files and secrets are excluded, run the applicable verification, then commit only the intended change with a clear, descriptive message and push it. Include the commit SHA, remote branch, verification evidence, remaining risks, and the next action in the handoff or pull request. Never use a commit or push as a substitute for verification, and never commit without explicit authorization.
