---
name: git-workflow
description: Keep changes focused and hand work off safely across worktrees and Macs — use when committing, deciding what belongs in one change, preparing a handoff or pull request, or working inside a Superset worktree.
---

Inspect `git status` and `git diff` before editing, not only before committing. Keep one independently mergeable unit of work per branch and worktree, and do not rewrite unrelated history.

## What belongs in one commit

One coherent change that could be reviewed, reverted, or merged on its own. If the message needs "and" to describe unrelated work, it is two commits. Keep a mechanical change (a rename, a reformat, a dependency bump) separate from a behavioural one — mixed together, the behavioural change becomes invisible in review.

Stage deliberately. `git add -A` after a long session sweeps up scratch files, debug edits, and unrelated fixes. Review the staged diff before committing, and confirm no `.env`, credential, key, generated artifact, or local-only file is included.

## Checkpoints

Create a durable checkpoint:

- After project onboarding, an architecture record, or Superset setup that other worktrees need.
- After a coherent, verified implementation unit that can be independently reviewed or merged.
- Before handing a task to another agent, moving to another Mac, or creating a worktree that depends on the branch.

At each checkpoint: inspect status and diff, confirm secrets and local files are excluded, run the applicable verification, then commit only the intended change with a clear message, and push.

A commit is local and reversible, so it may be made directly. **Pushing requires an explicit approval each time** — it publishes the work and cannot be verified from configuration. State the verification you actually ran when requesting it, and never request it for work whose checks you have not seen pass. Force-push, `git reset --hard`, and `git clean` are denied: nothing that discards published history or uncommitted work.

Never use a commit or push as a substitute for verification.

## Commit messages

Subject line in the imperative, describing the change's effect rather than the activity ("Reject expired invite tokens", not "Fix bug in auth"). Explain *why* in the body when the reason is not obvious from the diff — the diff already shows what changed. Reference the issue or task when one exists.

## Superset worktrees

One worktree is one independently mergeable unit of work, not one agent role. Several agents — explorer, implementer, reviewer — can work in the same worktree; that is normal and preferred.

Create a second worktree only when the work is genuinely independent: no shared files, schema, generated types, routes, or UI primitives. Two agents editing the same files in parallel branches produces a merge conflict that costs more than the parallelism saved. When in doubt, keep it sequential.

Worktrees are created from pushed branch history, so shared setup must be committed and pushed to the base branch *before* a dependent worktree is created — otherwise the new worktree will not contain it. Local ignored environment files do not travel with a worktree; copy them through the project's setup script rather than committing them.

## Handoff

A local worktree is not a handoff until the intended, verified change is committed and pushed. A handoff report states:

- the commit SHA and remote branch,
- what was verified, with the exact commands and their results,
- what is deliberately incomplete,
- known risks and the next action.

Before switching Macs, push, then on the other machine fetch and fast-forward rather than merging divergent local state. If work must be shared before it is finished, use a clearly labelled draft branch and document its limitations — never present unverified work as a checkpoint.
