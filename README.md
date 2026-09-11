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
| Commands | `opencode/commands/` | `/route-task`, `/analyze-project`, `/plan-feature`, `/grill`, `/implement-feature`, `/review`, `/verify` |
| Skills | `opencode/skills/` | On-demand procedures for the stack and workflow (see below) |
| Project templates | `templates/` | Existing-project onboarding and a Next/Supabase starting point |
| Repository checks | `scripts/check.sh`, `.github/workflows/check.yml` | Lint, secret scan, and config-load validation |

`agentctl` subcommands: `doctor` (environment health), `check` (repository health), `sync` / `unsync` (link management), `review-models [--apply]`, `start-task`, `init-existing`, `init-next`.

## Model routing

All choices live in `opencode/opencode.jsonc`; change that file and run `agentctl sync` to apply a new policy. Account-level availability requires an OpenCode Go login; `agentctl review-models` verifies the configured IDs against the live catalog, so no model list is pinned to a date here.

Run `agentctl review-models` occasionally (and after an OpenCode Go catalog update). It compares the live catalog with the configured routing, remembers newly seen models locally on that Mac, and prints a planning brief for a deliberate task-specific routing review. After choosing replacements, run `agentctl review-models --apply`; it validates every selection against the live catalog, rewrites routing only after an interactive confirmation, then proves the result loads in OpenCode before replacing the file. The previous config is kept as a timestamped backup, and a candidate that fails to load is rejected with the original untouched.

Scope routing runs automatically before implementation requests through the global guardrails. `/route-task <request>` remains available when you want the same routing decision as a standalone, read-only report before starting work.

| Work | Agent(s) | Model |
| --- | --- | --- |
| Cheap exploration/context gathering | explorer | `opencode-go/mimo-v2.5` |
| Contained, well-understood bug fix | quick-fix | `opencode-go/gpt-5.6-luna` |
| Default interactive and substantial coding (Synara **Build**) | default sessions, implementer, frontend, backend, database | `opencode-go/deepseek-v4.1-flash` |
| Cost-efficient tests | tester | `opencode-go/gpt-5.6-luna` |
| Architecture, difficult debugging, final/security review | architect, reviewer, security-reviewer | `opencode-go/glm-5.3` |

The configured defaults centralize normal model routing without limiting the picker. Use OpenCode’s `/models` picker to select any model currently available to your authenticated OpenCode Go account.

## OpenCode agents

Planning and review agents are read-only, and that is enforced rather than asserted. `edit: deny` alone does not make an agent read-only, because it does not constrain the shell — an allowlisted `sed -i` or `find -exec` would write files and ignore the directory rules entirely. So `explorer`, `architect`, `reviewer`, `security-reviewer`, and `tester` each restate the shell allowlist with no mutating command in it, and deny `git commit` and `git push` explicitly. `agentctl check` asserts this, so the guarantee cannot quietly regress.

Implementers can edit only in the current worktree; outside-worktree access remains approval-gated. Shell commands require approval unless they are read-only inspection commands. `sed` and `find` are deliberately not allowlisted for any agent. A focused commit is allowed directly because it is local and reversible; pushing requires an explicit approval each time, and force-push, `git reset --hard`, and `git clean` are denied outright.

Reading is broadly allowed, but paths that hold credentials — `.env` files, keys, `.ssh`, `auth.json` — require an approval, so no agent pulls a secret into a session transcript in passing.

- `explorer`: read-only architecture/convention investigation.
- `architect`: read-only decisions and decomposition.
- `quick-fix`: contained, well-understood bug fixes; escalates unclear or risky scope.
- `implementer`: focused general implementation.
- `frontend`: React/Next.js/UI/accessibility specialization.
- `backend`: Node/server/API specialization.
- `database`: Postgres, Supabase migrations, and RLS specialization.
- `tester`: test design and verification; edits require approval.
- `reviewer`: independent read-only diff review.
- `security-reviewer`: independent read-only auth, RLS, secrets, and boundary review.

## Skills

Skills are loaded on demand, selected by their description, so each one states the situation that should pull it in rather than a topic label. They carry procedures, decision rules, and footgun lists — not restatements of the agent prompts.

| Skill | Pulled in when |
| --- | --- |
| `typescript` | fighting a type error, designing a shared signature, or tempted by `as`/`any` |
| `react` | deciding where state lives, writing or removing an effect, diagnosing re-renders |
| `nextjs` | routes, server actions, server/client boundary, or stale-data caching problems |
| `node` | async resources, outbound calls, timeouts, errors, logging, shutdown |
| `supabase` | client selection, sessions in SSR, generated types, storage, anon vs service-role |
| `rls-policies` | any table the browser can reach, tenant isolation, `USING` vs `WITH CHECK` |
| `migrations` | schema changes, backfills, expand/migrate/contract, lock avoidance |
| `security` | new endpoint or action, untrusted input, secrets, what a response exposes |
| `testing` | choosing the test level, or a test that is flaky, slow, or proves nothing |
| `playwright` | E2E journeys, locator choice, auth state reuse, trace-based flake diagnosis |
| `debugging` | unclear failure, environment divergence, intermittency, a fix that didn't work |
| `performance` | a measured slowness — queries, waterfalls, bundle size, re-render storms |
| `dependencies` | adding, upgrading, or removing a package; audit findings |
| `accessibility` | any interactive UI, dialog, form, or focus and announcement behaviour |
| `frontend-design` | a new surface with no pattern to copy; judging whether a UI is finished |
| `git-workflow` | commit scope, checkpoints, worktree splits, handoff reports |

Process skills, which gate work rather than describe a domain:

| Skill | Pulled in when |
| --- | --- |
| `brainstorming` | the ask is vague enough that two readings produce different work |
| `grill-me` | a plan exists and is about to be built, especially if hard to reverse |
| `test-driven-development` | working test-first by choice, or proving a defect fix with a failing test |
| `writing-skills` | authoring or revising a skill here, or fixing one that mis-triggers |

The intended sequence for substantial work is `brainstorming` → `/plan-feature` → `/grill` → implement → `/verify` → `/review`. Each stage is skippable for small work; the point is that skipping is a decision rather than an omission.

`agentctl check` verifies each skill's frontmatter name matches its directory and that a description is present, since either fault breaks selection silently.

## Install and synchronize

Review the Brewfile, then run:

```bash
cd /path/to/dev-agent-config
./scripts/bootstrap-mac.sh
agentctl doctor
agentctl check
```

`bootstrap-mac.sh` runs Homebrew Bundle, creates only missing configuration-parent directories, and links seven items: the five OpenCode items into `~/.config/opencode`, `agentctl` into `~/.local/bin`, and the Warp tab config. If a target already exists and is not already the intended link, `sync-config.sh` first moves it to a timestamped backup beside the target. It does not delete or overwrite it. `agentctl unsync` reverses this, removing only links that point into this checkout.

Bootstrap also adds one clearly marked, idempotent line group to `~/.zprofile`. It detects the real Homebrew prefix (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel), puts it ahead of older shims, and adds `~/.local/bin` — where `agentctl` is linked — under a separate guard, so `agentctl` resolves on either architecture. Open a new terminal after bootstrap.

If several clones of this repository exist on one Mac, the one that last ran `agentctl sync` owns `~/.config/opencode`. `agentctl doctor` verifies each link resolves into the checkout it is run from and fails with the offending path when it does not.

The bundled Brewfile includes pnpm, Supabase CLI, Superset CLI, OpenCode, GitHub CLI, Tailscale, VS Code, and a few small development utilities. It does not run any login or put credentials into this repository.

## Warp Agent Cockpit

`agentctl sync` links the versioned Warp Tab Config into `~/.warp/tab_configs/agent_cockpit.toml`. In Warp, choose **Agent Cockpit** from the new-tab `+` menu, select a project repository, and it opens an OpenCode pane beside live project usage and local Superset-workspace panes. Use the Superset desktop app as the authoritative live view for agent terminals across worktrees and Macs.

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

For daily use, run `agentctl start-task <task-name>` from a clean project checkout. It detects the registered local Superset project, verifies `origin/main`, and creates `feat/<task-name>` from `main`. Pass a second argument only when you intentionally want a different pushed base branch.

For a pnpm Next.js project, `templates/new-next-supabase/superset.config.json.example` shows the sensible `pnpm install` / `pnpm dev` default. Review the package manager, environment files, services, ports, and monorepo cwd for each real repository before moving that example to `.superset/config.json`. Keep machine-local additions in ignored `.superset/config.local.json`; arrange any environment copying locally rather than committing secrets. Validate each project config by creating a throwaway Superset workspace before relying on it.

## Multi-Mac replication

1. Create a private GitHub repository for this directory and push only the non-secret configuration.
2. On the other Mac: `git clone <config-repo> dev-agent-config && cd dev-agent-config`.
3. Run `./scripts/bootstrap-mac.sh` and `agentctl doctor`.
4. Complete the separate logins above and verify `/models` in OpenCode.

Use `agentctl sync` after pulling configuration changes. Keep credentials, local `.env` files, and Superset/OpenCode/Tailscale sessions local to each Mac. For application work, commit and push each verified milestone before switching Macs; see [Cross-Mac Git checkpoints](WORKFLOWS.md#cross-mac-git-checkpoints).

## Troubleshooting and updates

- `agentctl doctor` distinguishes missing tools/config links from separate sign-in warnings. Required tools (`git`, `node`, `pnpm`, `opencode`, `superset`, `gh`, `jq`) fail; optional ones (`supabase`, `tailscale`, the linters, VS Code, Warp) only warn, since the `tailscale-app` cask may install the app without a CLI.
- `agentctl check` runs `shellcheck` over the scripts, `gitleaks` over history, and confirms the OpenCode config loads and that the read-only agents still cannot commit or push. The same checks run in CI via `.github/workflows/check.yml`.
- `agentctl review-models` verifies the live OpenCode Go catalog against routing and flags new or unavailable models; `agentctl review-models --apply` updates chosen routing after confirmation. It stores only a local, non-secret model-name snapshot under `~/.cache/agentctl/`.
- If OpenCode does not see agents, run `opencode agent list` and check that the relevant path under `~/.config/opencode` is a symlink.
- If a model is unavailable, use OpenCode `/models` to confirm account availability, then update centralized default routing if needed and run `agentctl sync`.
- Superset CLI commands evolve while the product is in beta; update it with Homebrew and consult `superset --help` before relying on a new workflow.
- To update tools and configuration, pull this repository, review `git diff`, run `./scripts/install-tools.sh`, then `agentctl sync`.

## T3 and Tailscale later

Tailscale provides private network reachability between Macs; it should not expose OpenCode directly to the public Internet. If you later add T3 as a remote UI, bind any OpenCode server to loopback by default, use Tailscale’s authenticated/private access path, and add an explicit threat-model and authentication review before exposing it to another device.
