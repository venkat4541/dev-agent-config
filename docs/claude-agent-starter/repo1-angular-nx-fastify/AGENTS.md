# Agent Development Guide — Angular / Nx / Fastify

## Repository Map
Replace placeholders with the real project names; keep this section short.

- Angular app(s): `<apps/...>`
- Fastify API/service(s): `<apps/...>`
- Shared UI: `<libs/...>`
- Feature libraries: `<libs/...>`
- Data-access/API clients: `<libs/...>`
- Shared types/contracts: `<libs/...>`

## Dependency Direction
Document only non-obvious boundaries, for example:
`UI -> feature -> data-access -> API`

Important Nx tags/boundary rules:
- `<rule>`

## Canonical Commands
Use repo-defined scripts; replace these placeholders with exact commands.
- Install: `<command>`
- Project graph/show project: `<command>`
- Typecheck: `<command>`
- Lint: `<command>`
- Unit test: `<command>`
- Affected checks: `<command>`
- Build: `<command>`
- Dev Angular: `<command>`
- Dev Fastify: `<command>`

## Conventions / Surprise Minimizers
Record facts agents repeatedly get wrong or cannot cheaply infer:
- `<non-obvious convention>`
- `<forbidden dependency/import>`
- `<source of truth for status/data>`
- `<backward compatibility requirement>`

## Definition of Done
- Relevant diagnostics are clean.
- Affected tests/checks pass.
- API/schema/type changes remain compatible or are intentionally migrated.
- No unnecessary unrelated refactor is included.
