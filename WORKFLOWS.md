# Development workflows

This is the operating guide for the reusable `dev-agent-config` repository. It separates what happens once per Mac, once per repository, and once per independently mergeable task.

## Core model

```text
Mac setup (once)
  └─ Project onboarding (once per repository; committed)
       └─ Superset worktree (one independently mergeable task)
            └─ OpenCode session in that worktree
```

Use **one worktree = one independently mergeable unit of work**. Do not create one worktree per agent role. Explorers, reviewers, and implementers can all work on the same task worktree when appropriate; parallel code changes need separate worktrees only when their work does not overlap.

## Once per Mac

### Bootstrap the reusable configuration

```bash
git clone git@github.com:venkat4541/dev-agent-config.git ~/projects/dev-agent-config
cd ~/projects/dev-agent-config
./scripts/bootstrap-mac.sh
agentctl doctor
```

The bootstrap installs the Brewfile tools, links the reusable OpenCode files from this repository into `~/.config/opencode`, links `agentctl` into `~/.local/bin`, and ensures Homebrew tools precede legacy Node shims in new terminal sessions.

Open a new terminal after bootstrap. If `agentctl` is not found, run:

```bash
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
agentctl doctor
```

### Complete local authentication

Credentials remain local to each Mac. Do not copy them through Git.

```bash
gh auth login
superset start
superset auth login
supabase login
```

Open OpenCode and run `/connect`, then choose **OpenCode Go**. Run `/models` to confirm the account’s currently available models.

Install and connect Tailscale interactively:

```bash
brew install --cask tailscale-app
tailscale up
```

The Tailscale installer may ask for an administrator password and System Settings approval. Do not expose an OpenCode server directly to the public Internet; any later T3 remote UI should use authenticated, private Tailscale access.

### Update an existing Mac

```bash
cd ~/projects/dev-agent-config
git pull --ff-only
./scripts/install-tools.sh
agentctl sync
agentctl doctor
agentctl review-models
```

Run `agentctl review-models` whenever OpenCode Go releases models, or monthly if you actively use several model roles. Use its generated brief in an OpenCode planning session, then run `agentctl review-models --apply` to select and confirm a validated routing update. Review, commit, and push that configuration checkpoint.

## Existing project workflow

### 1. Start with a clean project checkout

```bash
cd /path/to/existing-project
git status --short
```

If the command prints anything, review, commit, or stash it before onboarding. This prevents an agent setup change from being mixed with unrelated work.

### 2. Create or preserve project instructions

```bash
agentctl init-existing .
```

The command inspects the repository and creates a non-prescriptive `AGENTS.md` only if one does not already exist. It never replaces an existing file. Review the result and commit it so every developer and worktree receives the same project conventions.

```bash
git add AGENTS.md
git commit -m "docs: add project agent instructions"
```

### 3. Investigate before changing code

Run OpenCode from the project root:

```bash
opencode .
```

For a non-trivial request, use this sequence:

1. `/route-task <request>` — cheap read-only scope classification and recommended agent/model route.
2. `/analyze-project <request>` — read-only architecture, conventions, dependencies, and affected files when the route is not a contained quick fix.
3. `/plan-feature <request>` — evidence-based implementation plan, risks, migrations, tests, and genuinely independent workstreams for a feature or high-risk task.
4. Implement only the approved scope.
5. `/verify <scope>` — use the repository’s actual typecheck, lint, test, and build commands.
6. `/review <scope>` — independent read-only review.

Preserve the repository’s architecture and conventions. The global setup must never impose the greenfield stack on an established project.

The same classification runs automatically before implementation requests. Run `/route-task` explicitly when you want to inspect and approve the route before the work begins.

### 4. Add Superset support after project-specific inspection

Inspect the package manager, lockfile, environment files, services, ports, and monorepo layout first. Create `.superset/config.json` only after that review.

For a typical pnpm project, the shape is:

```json
{
  "setup": ["./.superset/setup.sh"],
  "run": ["pnpm dev"]
}
```

The setup script should be idempotent, normally run `pnpm install --frozen-lockfile`, and copy only necessary ignored local environment files from the primary checkout. Commit `.superset/config.json` and `.superset/setup.sh`; keep `.superset/config.local.json` ignored for personal extensions.

### 5. Register the repository with Superset on each host Mac

Run this once on every Mac that will create worktrees for the project:

```bash
superset projects create --local \
  --name existing-project \
  --import /absolute/path/to/existing-project
```

Capture the returned `projectId`. You can list registered projects with:

```bash
superset projects list --local --json
```

### 6. Create a task worktree

For normal feature work, start from a clean checkout of the desired already-pushed base branch and run:

```bash
agentctl start-task concise-task-name
```

The command detects the local Superset project by repository path, verifies the base branch exists on `origin`, and creates `feat/concise-task-name`. Use `agentctl start-task concise-task-name other-pushed-branch` only when deliberately branching from a different base. If the repository has not yet been registered on this Mac, the command registers it before creating the task worktree. Superset worktrees are based on remote branch history, so commit and push shared project setup before using it as a worktree base.

Inside the new worktree:

```bash
cd <Superset-worktree-path>
opencode .
code .
```

Run focused verification, then production build verification before merge. Keep the independent reviewer separate from the implementation pass for substantial changes.

## Example: start a new feature and assign agents

This is the normal sequence for a feature in an already configured project. Start with one task worktree; create additional worktrees only after planning proves that code changes can be independently merged.

### 1. Prepare a clean, pushed base

```bash
cd /absolute/path/to/project
git fetch origin
git switch <base-branch>
git pull --ff-only
git status --short
```

Resolve any output from `git status --short` before continuing. The base branch must be pushed because Superset worktrees are created from remote history.

### 2. Create the feature worktree

```bash
agentctl start-task account-notifications
```

Open the returned worktree path in OpenCode and VS Code:

```bash
cd <Superset-worktree-path>
opencode .
code .
```

### 3. Explore and plan before editing

In OpenCode, run:

```text
/route-task Add account notification preferences, including email delivery controls.
/analyze-project Add account notification preferences, including email delivery controls.
/plan-feature Add account notification preferences, including email delivery controls.
```

Those commands first assign the low-cost read-only `explorer` route classifier, then the `explorer` and `architect` agents for investigation and planning. Review the route and plan before implementation. They should identify the existing data/API/UI conventions, authorization and RLS impact, tests, rollout concerns, appropriate models, and whether any work is truly independent.

### 4. Assign implementation specialists deliberately

For most features, keep all work in this single worktree and tell the primary OpenCode session:

```text
Implement the approved notification-preferences plan. Use the database agent for any
schema, migration, query, or RLS change; use backend for server/API boundaries; use
frontend for the React UI and interaction states; and use tester for relevant tests.
Keep the work focused and preserve the existing architecture. Do not create additional
worktrees unless the plan identifies independent, non-overlapping mergeable units.
```

Role selection is based on affected boundaries, not a fixed pipeline:

| Need | Agent |
| --- | --- |
| Repository investigation only | `explorer` |
| Difficult tradeoffs or feature decomposition | `architect` |
| Contained, well-understood bug with focused regression coverage | `quick-fix` |
| General focused implementation | `implementer` |
| React/Next.js/UI/accessibility work | `frontend` |
| Server actions, APIs, integrations, Node work | `backend` |
| Supabase/Postgres migrations, queries, RLS | `database` |
| Unit, integration, E2E tests and verification | `tester` |
| Independent correctness/maintainability review | `reviewer` |
| Auth, authorization, RLS, secrets, input-boundary review | `security-reviewer` |

### 5. Parallelize only independent work

For example, after architecture defines stable API/type contracts, a database migration/RLS change and a UI component change may be independently mergeable. Create one worktree per resulting branch, give each clear file ownership, and merge in the dependency order from the plan. Do not parallelize agents that will modify the same schema, shared types, routes, or UI primitives.

### 6. Verify, review, checkpoint, and merge

In the task worktree, run:

```text
/verify account notification preferences
/review account notification preferences
```

For a feature that touches authentication, authorization, RLS, secrets, or sensitive data, also ask for an independent security review:

```text
Use the security-reviewer agent to review this feature's auth, authorization, RLS,
server/client boundaries, secrets handling, and input validation. Do not edit code.
```

After the project’s relevant typecheck, lint, tests, and production build pass, inspect the diff, commit with a clear message, and push the feature branch. Record the commit SHA, checks run, remaining risks, and next action in the handoff or pull request.

## New project workflow

### 1. Create the initial project

```bash
cd ~/projects
agentctl init-next my-app
cd my-app
```

This creates a TypeScript, Tailwind, App Router Next.js application with pnpm, project `AGENTS.md`, `docs/architecture.md`, and runs `supabase init` when available. It does not create or store secrets.

### 2. Define architecture before substantial implementation

Complete `docs/architecture.md` with:

1. Users, primary journeys, requirements, and non-goals.
2. Route map and server/client boundaries.
3. Data entities, relationships, migrations, and rollout plan.
4. Authentication and authorization strategy.
5. Supabase RLS policy matrix for read, create, update, and delete paths.
6. Frontend feature/component organization.
7. Unit, integration, E2E, accessibility, and production-build strategy.
8. Only genuinely independent workstreams suitable for Superset worktrees.

Prefer a single coherent application. Do not add microservices or extra infrastructure without a specific need.

### 3. Configure secrets safely

Create local-only environment files such as `.env.local`; commit only a safe `.env.example` that lists names and non-secret placeholders.

Rules:

- Never commit API keys, tokens, SSH private keys, or Supabase service-role keys.
- Never use a `NEXT_PUBLIC_*` variable for `SUPABASE_SERVICE_ROLE_KEY`.
- Use service-role credentials only on trusted server-side code.
- Implement and test Supabase RLS before allowing browser access to a table.

### 4. Establish the skeleton and checks

Before parallel work, make a small working skeleton: routes, data boundary, authentication/RLS foundations, component conventions, test harness, and deployment/build command. Then commit and push that base branch.

### 5. Add project-specific Superset support

Review `superset.config.json.example`, adapt it to the project, commit it, register the project with Superset on each host Mac, and verify it with one disposable worktree before using it for real work.

## Working in a task worktree

1. Start from a clean, pushed base branch.
2. Create one Superset worktree for one mergeable task.
3. Run OpenCode inside that worktree.
4. Explore and plan before complex changes.
5. Make focused changes; avoid unrelated refactors.
6. Run the project’s typecheck, lint, focused tests, broader tests, and production build as applicable.
7. Run independent code review and security review for material data, auth, or authorization changes.
8. Commit and push only the intended task changes.
9. Open/review/merge the pull request only when verification passes.

## Cross-Mac Git checkpoints

GitHub is the synchronization point between Macs. A local worktree is not a handoff until its intended, verified change is committed and pushed.

Create a checkpoint after project onboarding or shared setup, after each independently reviewable task, and before switching Macs or creating dependent worktrees. At a checkpoint:

```bash
git status --short
git diff --check
git add <intended-files>
git commit -m "<focused description>"
git push -u origin HEAD
```

Before staging, inspect the diff and confirm `.env*`, credentials, service-role keys, and other local/generated files are not included. Run the project’s applicable checks before committing. Never push an incomplete or unverified change solely to make it available on another Mac; instead finish a coherent safe unit, or use a clearly labelled draft branch with its limitations documented.

On the other Mac, start from the pushed branch:

```bash
git fetch origin
git switch <branch>
git pull --ff-only
git status --short
```

Record the commit SHA, branch, checks run, remaining risks, and next action in the pull request or task handoff. OpenCode may commit and push a verified, focused checkpoint so it is available from any Mac.

## Current ai-central example

On this Mac, `ai-central` is registered with Superset as:

```text
projectId: baf869bd-ad04-49ca-ab8d-a38bb031f819
base branch: agent/publish-local-changes
```

Create a worktree from the current pushed branch with:

```bash
cd /Users/venkat/projects/ai-central
agentctl start-task moveassistant-feature
```

Then open OpenCode in that worktree. Its Superset setup runs the frozen pnpm install and locally copies the known ignored MoveAssistant environment files; it never commits them.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| `agentctl init-existing` refuses a dirty repo | Review, commit, or stash changes first; run it from the application repo, not `dev-agent-config`. |
| `agentctl` is missing | Open a new terminal, or prepend `/opt/homebrew/bin:$HOME/.local/bin` to `PATH`. |
| OpenCode has no models | Run `/connect` → OpenCode Go, then `/models`. |
| Superset host service is stale | `superset stop && superset start`, then `superset status`. |
| Worktree misses new setup files | Commit and push the setup branch first; Superset worktrees use remote branch history. |
| Local environment is missing in a worktree | Add an explicit, ignored-file copy rule to the project `.superset/setup.sh`; do not commit the environment file. |
| Tailscale is not available | Install `tailscale-app` interactively and complete System Settings approval. |
