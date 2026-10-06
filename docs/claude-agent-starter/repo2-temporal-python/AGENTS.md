# Agent Development Guide — Temporal / Python

## Repository Map
Replace with real paths/names:
- Workflows: `<path>`
- Activities: `<path>`
- Workers: `<path>`
- Temporal clients/starters: `<path>`
- Models/contracts: `<path>`
- Persistence/integrations: `<path>`
- Tests: `<path>`

## Temporal Map
- Main workflow(s): `<name -> path/symbol>`
- Main activity groups: `<name -> path/symbol>`
- Worker entrypoint(s): `<path/symbol>`
- Task queue(s): `<name>`
- Signals/queries: `<name/purpose>`

## Canonical Commands
Replace with exact repo commands:
- Install/bootstrap: `<command>`
- Unit tests: `<command>`
- Targeted workflow/activity tests: `<command>`
- Integration tests: `<command>`
- Lint: `<command>`
- Format/check: `<command>`
- Typecheck: `<command>`
- Worker/dev start: `<command>`

## Conventions / Surprise Minimizers
- `<workflow determinism/replay rule specific to repo>`
- `<where status is persisted>`
- `<retry ownership convention>`
- `<serialization/versioning constraint>`
- `<external service mocking/testing convention>`

## Definition of Done
- Relevant diagnostics/types/lint are clean.
- Targeted tests pass.
- Workflow changes preserve determinism/replay expectations.
- Contract changes are synchronized with the TypeScript/Fastify boundary.
