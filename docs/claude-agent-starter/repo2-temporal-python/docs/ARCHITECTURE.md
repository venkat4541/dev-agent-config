# Architecture Map — Temporal / Python

Purpose: orient agents quickly without forcing broad repository exploration.

## Execution Flow
`Fastify Temporal client -> workflow -> activities/child workflows -> external systems/scanners -> persistence/result/status`

Replace with actual names:
1. Workflow starter/client: `<external repo path/symbol or contract>`
2. Workflow: `<path/symbol>`
3. Activities: `<path/symbols>`
4. Worker registration: `<path/symbol>`
5. Task queue: `<queue>`
6. Persistence/result sink: `<system/path>`

## Workflow Inventory
| Workflow | Purpose | Task queue | Key activities | Status/result source |
|---|---|---|---|---|
| `<name>` | `<...>` | `<...>` | `<...>` | `<...>` |

## Signals / Queries / Child Workflows
- `<name>`: `<purpose + path/symbol>`

## Reliability Semantics
- Activity retries: `<policy/source>`
- Timeouts: `<policy/source>`
- Cancellation: `<behavior>`
- Idempotency: `<strategy>`
- Replay/versioning: `<strategy>`

## High-Risk Boundaries
- `<boundary and why>`

## Where To Start
- Workflow not starting -> client contract/task queue/worker registration
- Workflow stuck -> workflow history/state + pending activity/timer
- Activity failure -> activity implementation + retry/error mapping
- Wrong final status -> persistence/status propagation + cross-repo contract
