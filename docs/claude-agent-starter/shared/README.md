# Claude / Agent Starter Kit

## Suggested placement

Global policy:
- Copy `global/CLAUDE.md` to `~/.claude/CLAUDE.md`.

Angular/Nx/Fastify repo:
- Copy `repo1-angular-nx-fastify/CLAUDE.md` to repo root.
- Copy `repo1-angular-nx-fastify/AGENTS.md` to repo root.
- Copy its `docs/` files into the repo's docs directory (or adjust links).

Temporal/Python repo:
- Copy `repo2-temporal-python/CLAUDE.md` to repo root.
- Copy `repo2-temporal-python/AGENTS.md` to repo root.
- Copy its `docs/` files into the repo's docs directory (or adjust links).

## First customization pass
Replace every `<...>` placeholder. Most important:
1. exact build/test/lint/typecheck/dev commands;
2. Nx project names and dependency boundaries;
3. Temporal workflow names, task queues, worker entrypoints;
4. cross-repo payload/status/result sources of truth;
5. non-obvious constraints agents repeatedly get wrong.

## Maintenance rule
Keep these files concise. Add a rule only when it is stable, non-obvious, and likely to prevent repeated agent exploration or mistakes. Remove stale guidance promptly.

## Skills
Keep skill invocation policy global. Use Claude Code skill controls/settings for skills you want manual-only or unavailable rather than bloating project CLAUDE.md files with per-skill instructions.

## Installed developer tools assumed by this kit

This v2 configuration assumes `rg`, `fd`, `jq`, TypeScript Language Server, and `pyright` are installed. The instructions intentionally prefer these targeted tools before broad source reads or agent delegation. Repository-native lint, formatting, test, and build commands still take precedence over introducing alternate tools.
