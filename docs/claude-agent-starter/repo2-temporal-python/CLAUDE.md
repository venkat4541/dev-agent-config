# Claude Code Guide — Temporal / Python

Read `AGENTS.md` first. Read `docs/ARCHITECTURE.md` before broad workflow exploration and `docs/CROSS_REPO_CONTRACT.md` before cross-repository investigation.

## Navigation
- `pyright` is installed. Use it before manual investigation of suspected Python type/interface problems.
- Prefer Python semantic navigation when exposed for symbols, references, definitions, and types.
- Use `fd` for file/directory discovery and `rg` for targeted textual/pattern search.
- Use `jq` to filter JSON configuration, payload samples, or structured output before bringing large blobs into context.
- Identify the workflow/activity/task queue involved before exploring unrelated workflows.
- Read targeted ranges rather than whole large modules.
- Do not infer parameter/return/Optional/protocol compatibility when Pyright can determine it.

## Temporal
- Preserve workflow determinism and replay compatibility.
- Be especially cautious with workflow state, timers, signals, queries, child workflows, activity signatures, retry/timeouts, workflow IDs, task queues, serialization, and versioning.
- Keep non-deterministic I/O and side effects in activities, not workflow code.
- Follow the repository's established Temporal patterns rather than introducing new ones casually.

## Python
- Follow existing typing, linting, formatting, async, dependency, and testing conventions.
- Prefer repository-configured tools over introducing alternatives.
- Use type information rather than inferring contracts when annotations/models exist.

## Verification
Use Pyright diagnostics as an early check for affected Python code, then run the smallest relevant workflow/activity/unit tests. Expand to integration/replay/full-suite checks only when the change affects shared workflow behavior or infrastructure.

A clean Pyright result does not establish Temporal correctness. Still verify determinism, serialization/contracts, workflow/activity boundaries, retries/timeouts, and replay compatibility where relevant.

## Cross-Repository Rule
The TypeScript/Fastify boundary is described in `docs/CROSS_REPO_CONTRACT.md`.
Do not inspect the Angular/Nx/Fastify repo unless evidence implicates the caller contract, payload, workflow start/cancel behavior, status propagation, or result mapping.
