# Jev advisory decision layer

Jev is TypeSafe AI's System One model: it answers typed questions with calibrated probabilities and writes no prose. In this configuration it is wired as a read-only MCP tool plus a skill. It is advice, never a gate.

## What is wired

| Piece | Location | Purpose |
| --- | --- | --- |
| `typesafe` MCP server | `opencode/opencode.jsonc` (`mcp.typesafe`) | Runs upstream's `evaluate` server (MIT) and exposes one tool, `typesafe_evaluate` |
| `jev-decisions` skill | `opencode/skills/jev-decisions/` | When and how to ask, thresholds, boundaries, failure handling |

## Setup

The server binary installs to `~/.local/bin` like the other local MCP servers:

1. Install `evaluate` (release binary, or `go install github.com/itsmostafa/typesafe-mcp/cmd/evaluate@latest`); `evaluate update` upgrades it later.
2. Export the key in the shell that launches OpenCode: `TYPESAFE_API_KEY` for TypeSafe direct, or `OPENROUTER_API_KEY` to route through OpenRouter. Never add it to this repository.
3. Run `agentctl sync`, restart OpenCode, and confirm with `opencode mcp list` that `typesafe` is connected.

No credential is referenced in tracked config. `{env:TYPESAFE_API_KEY}` is deliberately not used in `opencode.jsonc`: OpenCode fails the whole file to load when the variable is unset, which would break `agentctl check` and every Mac without the key. The MCP child inherits the shell environment instead.

`agentctl check` validates this file on OpenCode v1 by loading an isolated copy. OpenCode v2 has no isolated, non-interactive config-load probe — it resolves configuration through its background service and starts even with a malformed file — so that one step reports SKIP on v2 while the content checks still assert agents, permissions, prompts, and skills from the file.

## Boundaries

- MCP tools are not covered by OpenCode's `permission` rules. Treat every Jev answer as advisory input: it can order work, choose a route, or flag something for a look, but it must not be the only thing standing between an action and the repository. Commits, pushes, merges, auth, migrations, RLS, and review verdicts keep their deterministic gates and agent authority.
- `state` leaves the machine for the TypeSafe API. Never include credentials, `.env` contents, or customer personal data.
- Jev 1.13 has documented jaggedness — literal reading, arithmetic, dates, counting, contradictory criteria. Keep those tasks with normal models or code.
- Use `jev-latest` while experimenting. Pin an immutable version (for example `jev-1.13.0`) and log the returned version when a threshold depends on a specific calibration.

## Cost and latency

About $0.042 per million input tokens with free output, and typically 70–500 ms per call. Cheap enough for per-task routing and triage; not worth a call per tool invocation.

## Removal

Delete the `mcp.typesafe` entry from `opencode/opencode.jsonc` and the `opencode/skills/jev-decisions/` directory, then run `agentctl sync`. No other state is created; the binary and the key live outside this repository.

## Deferred candidates

- **Skill routing** (`skillranker` and similar) targets a real cost here, because skill descriptions compete for selection. Deferred: the current tools are Linux-first and hook into Claude Code rather than OpenCode. Re-evaluate before wiring.
- **Compaction** (`fast-jev-compaction` and ports) is the most publicized Jev use, but it is contested (compaction is not a filter) and compaction is a prompt-injection surface. Not wired.
- **Local alternates**: Kev (Apache-2.0, Jev-compatible `/v1/systemone`) and `simple-jev` speak the same interface, so a local fallback is possible without changing how the skill is used.
