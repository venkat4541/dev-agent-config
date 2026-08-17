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
```

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

1. `/analyze-project <request>` — read-only architecture, conventions, dependencies, and affected files.
2. `/plan-feature <request>` — evidence-based implementation plan, risks, migrations, tests, and genuinely independent workstreams.
3. Implement only the approved scope.
4. `/verify <scope>` — use the repository’s actual typecheck, lint, test, and build commands.
5. `/review <scope>` — independent read-only review.

Preserve the repository’s architecture and conventions. The global setup must never impose the greenfield stack on an established project.

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

Start from the desired already-pushed base branch:

```bash
superset ws create --local \
  --project <project-id> \
  --name concise-task-name \
  --branch feat/concise-task-name \
  --base-branch <pushed-base-branch>
```

Superset worktrees are based on remote branch history. Commit and push shared project setup before using it as a worktree base.

Inside the new worktree:

```bash
cd <Superset-worktree-path>
opencode .
code .
```

Run focused verification, then production build verification before merge. Keep the independent reviewer separate from the implementation pass for substantial changes.

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

## Current ai-central example

On this Mac, `ai-central` is registered with Superset as:

```text
projectId: baf869bd-ad04-49ca-ab8d-a38bb031f819
base branch: agent/publish-local-changes
```

Create a worktree from the current pushed branch with:

```bash
cd /Users/venkat/projects/ai-central
superset ws create --local \
  --project baf869bd-ad04-49ca-ab8d-a38bb031f819 \
  --name moveassistant-feature \
  --branch feat/moveassistant-feature \
  --base-branch agent/publish-local-changes
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

