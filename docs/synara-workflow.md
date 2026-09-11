# Synara workflow

How to run the current Synara-only agent stack on top of this repository's OpenCode configuration.

Synara is the orchestrator and UI. The only enabled providers are **Codex** (planning, verification, review) and **OpenCode Go** (implementation). Claude, Grok, Cursor, Pi, and the rest are intentionally off.

## Roles and models

| Role | Runtime | Model | Invoke |
| --- | --- | --- | --- |
| Plan | Codex | `gpt-6-astra` (high) | `codex -p plan` |
| Explore / second angle | Codex | `gpt-5.6-luna` (high) | `codex -p explore` |
| Build | OpenCode Go | `deepseek-v4.1-flash` | default session |
| Verify (tests/typecheck only) | Codex | `gpt-5.6-terra` (medium) | `codex -p verify` |
| Review / PR | Codex | `codex-auto-review` (high) | `codex -p review` |

Heavy Build work may escalate to `deepseek-v4-pro` or `qwen3.8-max`. The review fallback in OpenCode is `glm-5.3`.

> **Guardrail.** The default Codex model with no profile is Plan-tier `gpt-6-astra` at `high`. Always pass `-p verify` for Verify and `-p review` for review, or flagship reasoning is spent on tests.

## The loop

One objective per Synara task + worktree. Never reuse the Build thread for Verify.

1. **Plan** — `codex -p plan`. Turn the request into a spec and tickets (`to-spec`, `to-tickets`), and pressure-test it (`grilling`).
2. **Build** — OpenCode Go in the task worktree (`implement`, `tdd`). Search with `fffind`/`ffgrep`.
3. **Explore** — `codex -p explore` only when Build stalls or a second angle is worth it. This replaced Grok.
4. **Verify** — `codex -p verify` on a **fresh thread**, tests and typecheck only (`testing`, `diagnosing-bugs`).
5. **Review / PR** — `codex -p review` or OpenCode Go `glm-5.3` (`code-review`, `git-workflow`). Use `handoff` to carry context between roles.

## Where configuration lives

| Concern | Location |
| --- | --- |
| Model policy and guardrails | `~/.codex/AGENTS.md` (mirrored to `~/.synara/codex-home-overlay/AGENTS.md`) |
| Codex role profiles | `~/.codex/{plan,explore,verify,review}.config.toml` (mirrored to the Synara overlay) |
| Synara provider toggles | `~/.synara/userdata/settings.json` (restart Synara after editing) |
| OpenCode routing and LSP | `opencode/opencode.jsonc` in this repository, linked into `~/.config/opencode` |
| Shared skills | `~/.agents/skills` (symlinked into Codex) |
| Codex file-search MCP (`fff`) | `~/.codex/config.toml` and the Synara overlay |

## Tools

- **fff** gives Codex the `fffind`, `ffgrep`, and `fff-multi-grep` search tools. OpenCode uses fff natively. Homebrew installation is blocked while Xcode is out of date; install the release binary to `~/.local/bin/fff-mcp` instead.
- **LSP** is enabled globally in `opencode/opencode.jsonc` (`"lsp": true`). Language servers start on demand for detected project types. Disable it per project if a repository's servers are heavy.

## Maintenance

```bash
agentctl doctor         # environment health
agentctl check          # repo guarantees (read-only agents, skills, config loads)
agentctl review-models  # validate routing against the live OpenCode Go catalog
agentctl sync           # re-link this repo into ~/.config/opencode
```

Change OpenCode model routing only in `opencode/opencode.jsonc`, then `agentctl sync` and commit. Change Synara role models in the Codex profile files above.
