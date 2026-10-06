# Cross-Repository Contract — TypeScript/Fastify <-> Temporal/Python

Keep this intentionally small and synchronized with the corresponding document in the Temporal/Python repo.

## Boundary
`Angular -> Fastify -> Temporal client -> Temporal workflow -> Python activities -> result/status -> Fastify -> Angular`

## Invocation
- Fastify caller: `<path/symbol>`
- Temporal workflow type/name: `<name>`
- Task queue: `<queue>`
- Workflow ID format: `<format>`
- Input payload/schema: `<source of truth>`

## Status Lifecycle
Replace with actual states and transitions:
`SUBMITTED -> QUEUED -> RUNNING -> COMPLETED | FAILED | CANCELED`

Source of truth for status: `<database / workflow query / event / other>`

## Result / Error Contract
- Result schema: `<source>`
- Error mapping: `<source>`
- Retry ownership: `<Fastify / Temporal / activity>`

## Compatibility Rules
- `<fields that must remain backward compatible>`
- `<serialization/versioning constraints>`

## Debugging Boundary
Start in the TypeScript repo. Cross into Temporal/Python only when evidence shows workflow start, payload, task queue, activity execution, status propagation, or result mapping is implicated.
