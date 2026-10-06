# Claude Code Guide — Angular / Nx / TypeScript / Fastify

Read `AGENTS.md` first for repository structure, commands, and conventions. Read `docs/ARCHITECTURE.md` before broad or cross-system exploration.

## Navigation
- TypeScript Language Server is installed. Use it first for symbols, definitions, references, implementations, hover/types, and diagnostics.
- Use Nx project/dependency information to establish the affected project boundary before scanning the monorepo broadly.
- Use `fd` for locating files/directories.
- Use `rg` for route strings, configuration, environment variables, feature flags, GraphQL/query text, log messages, comments/TODOs, and other non-semantic patterns.
- Use `jq` to inspect/filter JSON configuration or structured output before reading large JSON blobs.
- Read targeted ranges rather than entire large files.
- Do not explore unrelated Nx projects for a localized change.
- Do not use text search as a substitute for TypeScript semantic reference lookup when LSP can answer reliably.

## Nx
- Identify the owning project/library and affected dependency graph before broad changes.
- Prefer affected/project-scoped build, lint, typecheck, and tests.
- Respect existing module/library boundaries and tags.
- Before creating a library or abstraction, search for an existing equivalent.

## Angular / TypeScript
- Follow existing repository patterns and the Angular APIs/version already in use.
- Prefer type/LSP evidence over inferred contracts.
- Reuse existing components, services, state patterns, validators, and utilities before introducing new abstractions.
- Preserve accessibility and established UI conventions.

## Fastify
- Follow existing route, schema, validation, auth, error-handling, logging, and service-layer conventions.
- Treat schemas/types/contracts as authoritative when present.
- Do not invent API conventions when neighboring routes demonstrate them.

## Verification
Start with diagnostics and the smallest affected Nx project/test target. Expand only when dependency impact justifies it.

## Cross-Repository Rule
This repo integrates with the Temporal/Python repo through the contract described in `docs/CROSS_REPO_CONTRACT.md` (or the shared equivalent used by your workspace).
Do not inspect the Temporal/Python repo by default. Cross the boundary only when evidence shows the request, status lifecycle, payload, workflow invocation, or failure spans both systems.
