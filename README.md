# Dev agent config

Reusable, non-secret configuration for a Mac development workflow built around OpenCode, Superset worktrees, GitHub, VS Code, Supabase, and Tailscale.

For the complete operating guide, see [WORKFLOWS.md](WORKFLOWS.md).

## Design

`opencode/` holds the global OpenCode configuration and is linked item-by-item into `~/.config/opencode/`. This deliberately leaves unrelated files already in that directory alone (such as provider packages and credentials). The repository never stores API keys, OAuth tokens, SSH keys, Supabase service-role keys, or `.env` files.

Global rules are intentionally framework-neutral. A project-local `AGENTS.md`, project config, and `.opencode/` directory take precedence where they provide more specific instructions. This protects established repositories from a global preference for any particular framework.

| Area | Location | Purpose |
| --- | --- | --- |
| Global guardrails | `opencode/AGENTS.md` | Architecture preservation, safety, verification, accessibility |
| Agent registrations and model policy | `opencode/opencode.jsonc` | Centralized routing and permissions |
| Agent role prompts | `opencode/agents/` | Reusable specialist behavior |
| Commands | `opencode/commands/` | `/analyze-project`, `/plan-feature`, `/implement-feature`, `/review`, `/verify` |
| Skills | `opencode/skills/` | On-demand TypeScript, React, frontend design, Supabase, testing, accessibility, security guidance |
| Project templates | `templates/` | Existing-project onboarding and a Next/Supabase starting point |

## Model routing

All choices live in `opencode/opencode.jsonc`; change that file and run `agentctl sync` to apply a new policy. The installed OpenCode 1.18.18 catalog was inspected on 2026-08-17 and confirmed these OpenCode Go IDs. Account-level availability still requires an OpenCode Go login; use `/models` after connecting to confirm it for that Mac.

Run `agentctl review-models` occasionally (and after an OpenCode Go catalog update). It compares the live catalog with the configured routing, remembers newly seen models locally on that Mac, and prints a planning brief for a deliberate task-specific routing review. After choosing replacements, run `agentctl review-models --apply`; it validates every selection against the live catalog and rewrites routing only after an interactive confirmation.

| Work | Agent(s) | Model |
| --- | --- | --- |
| Cheap exploration/context gathering | explorer | `opencode-go/mimo-v2.5` |
| Default interactive and substantial coding | default sessions, implementer, frontend, backend, database | `opencode-go/kimi-k2.7-code` |
| Cost-efficient tests | tester | `opencode-go/gpt-5.6-luna` |
| Architecture, difficult debugging, final/security review | architect, reviewer, security-reviewer | `opencode-go/glm-5.3` |

The configured defaults centralize normal model routing without limiting the picker. Use OpenCode’s `/models` picker to select any model currently available to your authenticated OpenCode Go account.

## OpenCode agents

Planning and review agents are read-only. Implementers can edit only in the current worktree; outside-worktree access remains approval-gated. Shell commands require approval unless they are low-risk, read-only inspection commands; focused Git commits and pushes are allowed after a verified checkpoint. This makes verified work available for cross-Mac handoff.

- `explorer`: read-only architecture/convention investigation.
- `architect`: read-only decisions and decomposition.
- `implementer`: focused general implementation.
- `frontend`: React/Next.js/UI/accessibility specialization.
- `backend`: Node/server/API specialization.
- `database`: Postgres, Supabase migrations, and RLS specialization.
- `tester`: test design and verification; edits require approval.
- `reviewer`: independent read-only diff review.
- `security-reviewer`: independent read-only auth, RLS, secrets, and boundary review.

## Install and synchronize

Review the Brewfile, then run:

```bash
cd /path/to/dev-agent-config
./scripts/bootstrap-mac.sh
agentctl doctor
```

`bootstrap-mac.sh` runs Homebrew Bundle, creates only missing configuration-parent directories, and makes symlinks for the five OpenCode items. If a target already exists and is not already the intended link, `sync-config.sh` first moves it to a timestamped backup beside the target. It does not delete or overwrite it.

Bootstrap also adds one clearly marked, idempotent line group to `~/.zprofile` which puts `/opt/homebrew/bin` before older `/usr/local/bin` shims and adds `~/.local/bin` (where `agentctl` is linked). Open a new terminal after bootstrap.

The bundled Brewfile includes pnpm, Supabase CLI, Superset CLI, OpenCode, GitHub CLI, Tailscale, VS Code, and a few small development utilities. It does not run any login or put credentials into this repository.

## Separate per-Mac logins

Perform these on each Mac after bootstrap:

```bash
gh auth login
superset auth login
supabase login
```

Then open OpenCode and use `/connect` → **OpenCode Go** to authenticate, and sign in to Tailscale through its app or `tailscale up`. Do not copy any of these resulting credentials through Git. VS Code is installed by Homebrew; use its **Shell Command: Install 'code' command in PATH** command if you want the optional `code` shell launcher.

## Existing-project workflow

From a clean checkout:

```bash
cd /path/to/existing-project
agentctl init-existing .
opencode .
```

`init-existing` refuses a dirty Git state, detects the package manager, and creates `AGENTS.md` only if one does not already exist. It never overwrites an existing project instruction file. In OpenCode, run `/analyze-project <task>` and then `/plan-feature <task>` for non-trivial work. Use OpenCode `/init` to enrich the project file with repository-specific build/test details when you want its interactive analysis.

Implement only after the plan identifies the affected boundaries. Split work into Superset worktrees only when the work is actually independent. Then use `/verify <scope>`, `/review <scope>`, and run the project’s production build. Merge only after the relevant checks and independent review succeed.

## Greenfield workflow

Create a standard TypeScript/Tailwind/App Router Next.js project without secrets:

```bash
cd /path/to/projects
agentctl init-next my-app
cd my-app
```

The command uses `pnpm create next-app`, writes a project `AGENTS.md` plus `docs/architecture.md`, and runs `supabase init` when the CLI is available. Before substantial implementation, complete the architecture record: requirements and non-goals, data model, authentication/authorization, RLS matrix, route/API boundaries, feature/component organization, and testing strategy. Keep the design as a coherent application unless a separate service is justified.

Add local environment values only to ignored files such as `.env.local`; commit a `.env.example` containing names and safe placeholders, never real values. Treat `SUPABASE_SERVICE_ROLE_KEY` as server-only and never expose it through `NEXT_PUBLIC_*`.

## Superset worktrees

Superset workspaces are isolated Git worktrees. Use this rule:

> One worktree = one independently mergeable unit of work.

It is not a mapping of worktrees to agent roles. An explorer and reviewer can investigate the same worktree read-only; parallel implementation needs separate branches/worktrees with clear file ownership.

For a pnpm Next.js project, `templates/new-next-supabase/superset.config.json.example` shows the sensible `pnpm install` / `pnpm dev` default. Review the package manager, environment files, services, ports, and monorepo cwd for each real repository before moving that example to `.superset/config.json`. Keep machine-local additions in ignored `.superset/config.local.json`; arrange any environment copying locally rather than committing secrets. Validate each project config by creating a throwaway Superset workspace before relying on it.

## Multi-Mac replication

1. Create a private GitHub repository for this directory and push only the non-secret configuration.
2. On the other Mac: `git clone <config-repo> dev-agent-config && cd dev-agent-config`.
3. Run `./scripts/bootstrap-mac.sh` and `agentctl doctor`.
4. Complete the separate logins above and verify `/models` in OpenCode.

Use `agentctl sync` after pulling configuration changes. Keep credentials, local `.env` files, and Superset/OpenCode/Tailscale sessions local to each Mac. For application work, commit and push each verified milestone before switching Macs; see [Cross-Mac Git checkpoints](WORKFLOWS.md#cross-mac-git-checkpoints).

## Troubleshooting and updates

- `agentctl doctor` distinguishes missing tools/config links from separate sign-in warnings.
- `agentctl review-models` verifies the live OpenCode Go catalog against routing and flags new or unavailable models; `agentctl review-models --apply` updates chosen routing after confirmation. It stores only a local, non-secret model-name snapshot under `~/.cache/agentctl/`.
- If OpenCode does not see agents, run `opencode agent list` and check that the relevant path under `~/.config/opencode` is a symlink.
- If a model is unavailable, use OpenCode `/models` to confirm account availability, then update centralized default routing if needed and run `agentctl sync`.
- Superset CLI commands evolve while the product is in beta; update it with Homebrew and consult `superset --help` before relying on a new workflow.
- To update tools and configuration, pull this repository, review `git diff`, run `./scripts/install-tools.sh`, then `agentctl sync`.

## T3 and Tailscale later

Tailscale provides private network reachability between Macs; it should not expose OpenCode directly to the public Internet. If you later add T3 as a remote UI, bind any OpenCode server to loopback by default, use Tailscale’s authenticated/private access path, and add an explicit threat-model and authentication review before exposing it to another device.
