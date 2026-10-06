# Architecture Map — Angular / Nx / Fastify

Purpose: give agents a map, not an encyclopedia. Keep this roughly 100-300 lines as the system evolves.

## Request Flow
`User -> Angular -> API client/data-access -> Fastify route -> service/domain -> persistence and/or Temporal boundary`

Replace with actual names:
1. UI entry point: `<project/symbol>`
2. Frontend data-access/client: `<project/symbol>`
3. Fastify route/plugin: `<project/symbol>`
4. Domain/service: `<project/symbol>`
5. Persistence: `<system/module>`
6. Temporal client boundary: `<project/symbol>`

## Nx Project Boundaries
| Area | Project(s) | Responsibility | May depend on |
|---|---|---|---|
| UI | `<...>` | `<...>` | `<...>` |
| Feature | `<...>` | `<...>` | `<...>` |
| Data access | `<...>` | `<...>` | `<...>` |
| API | `<...>` | `<...>` | `<...>` |

## Sources of Truth
- Scan/job status: `<source>`
- API contract/schema: `<source>`
- Auth identity/authorization: `<source>`
- Temporal workflow identifier mapping: `<source>`

## High-Risk Boundaries
- `<boundary and why>`

## Where To Start
- UI rendering issue -> `<area>`
- API validation/response issue -> `<area>`
- status stuck/incorrect -> `<area/source-of-truth>` then cross-repo contract if needed
- workflow start/cancel issue -> `<Temporal client boundary>`
