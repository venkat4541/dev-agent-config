# Jev advisory decision layer

Jev is TypeSafe AI's System One model: it answers typed questions with calibrated probabilities and writes no prose. In this configuration it is wired as a read-only MCP tool plus a skill. It is advice, never a gate.

## What is wired

| Piece | Location | Purpose |
| --- | --- | --- |
| `typesafe` MCP server | `opencode/opencode.jsonc` (`mcp.typesafe`) | Runs upstream's `evaluate` server (MIT) and exposes one tool, `typesafe_evaluate` |
| `jev-decisions` skill | `opencode/skills/jev-decisions/` | When and how to ask, thresholds, boundaries, failure handling |

## Setup

The server binary installs to `~/.local/bin` like the other local MCP servers:

1. Install `evaluate` (release binary, or `go install github.com/itsmostafa/system-one-connector/cmd/evaluate@latest`); `evaluate update` upgrades it later.
2. Make `TYPESAFE_API_KEY` (TypeSafe direct) or `OPENROUTER_API_KEY` available to the OpenCode backend that launches the MCP server. For a foreground backend, export it before starting that process. For Orca, Monocode, or the OpenCode v2 managed service, follow the launch-mode guidance below. Never add a key to this repository.
3. Run `agentctl sync`, restart the relevant backend, and confirm that `typesafe` is connected in that client. `opencode mcp list` checks the CLI's selected backend; it may differ from the GUI's backend. A connected MCP server alone does not prove API authentication: ask for one harmless evaluation in the actual client to verify the key works.

No credential is referenced in tracked config. `{env:TYPESAFE_API_KEY}` is deliberately not used in `opencode.jsonc`: OpenCode fails the whole file to load when the variable is unset, which would break `agentctl check` and every Mac without the key. The MCP child inherits its backend's environment instead.

### Orca and Monocode

Choose by the backend launch command or server connection configured in the app, not by the app name. A terminal export cannot change an already-running backend. Configure the key on the machine that runs that backend, including when the client connects remotely.

| Backend used by the client | Where the key must be available | Apply the change |
| --- | --- | --- |
| OpenCode v2 managed background service | The managed service's persistent environment | Restart that service when active work can be interrupted |
| `opencode acp` | The environment supplied by the app to the ACP child | Stop and relaunch the ACP backend |
| `opencode serve`, `--standalone`, or a foreground v1 backend | The environment of that backend process | Restart it with the key exported or supplied by its launcher |

OpenCode's [ACP documentation](https://opencode.ai/v2/docs/cli/acp/) states that ACP starts a private server, separate from the shared service. The [service environment documentation](https://opencode.ai/v2/docs/network/) also distinguishes managed settings from foreground processes. Consequently, `opencode service set env` is not a universal fix for GUI clients.

For the managed service on this Mac, the private settings file is `~/.config/opencode/service.json`, outside this repository and untouched by `agentctl sync`. Check `opencode debug paths` from the app's terminal if it uses a different config directory. Use a local editor to add the chosen key to the service file's `env` object, preserving existing fields, and keep the file mode `0600` (`chmod 600` on that file). Then run `opencode service restart` for that same service. This is plaintext local credential storage; do not share the file or `opencode service get env` output.

For an app-launched private backend, supply the variable through the app's private launch-environment settings or a local launcher that reads a protected credential file or keychain before executing the backend. Keep that launcher’s secret source outside this repository. Fully restart the backend after changing its environment; reopening a tab may reconnect to the same process.

Avoid putting real keys in `opencode service set env NAME VALUE`: the installed v2.0.7 logs CLI arguments to a file observed with mode `0644`. Expanding a shell variable into `VALUE` still puts the secret in those arguments. The help lists an optional value but does not establish a safe environment/stdin fallback; do not assume one. Also keep secrets out of agent prompts and terminal command history. The synced `~/.config/opencode/opencode.jsonc` is a symlink into this repository, so it is not a private place to paste a key.

`agentctl check` validates this file on OpenCode v1 by loading an isolated copy. OpenCode v2 has no isolated, non-interactive config-load probe — it resolves configuration through its background service and starts even with a malformed file — so that one step reports SKIP on v2 while the content checks still assert agents, permissions, prompts, and skills from the file.

## Boundaries

- OpenCode v2 permission rules can target MCP tools by their generated tool name (for example, `typesafe_evaluate`). This configuration's catch-all permission is `ask`, so invoking Jev still requires approval. Keep Jev advisory: an answer may order work, choose a route, or flag something for a look, but it must not be the only gate for commits, pushes, merges, auth, migrations, RLS, or review verdicts. Keep those deterministic gates and agent authority in place.
- `state` leaves the machine for the TypeSafe API. Never include credentials, `.env` contents, or customer personal data.
- Jev 1.13 has documented jaggedness — literal reading, arithmetic, dates, counting, contradictory criteria. Score levels are weakly calibrated (the `>=0.9` confidence bucket has measured well below 0.9 accuracy) and structural invariants break (a question and its negation need not sum to 1), so never treat a probability as a hard gate. Keep those tasks with normal models or code.
- Use `jev-latest` while experimenting. Pin an immutable version (for example `jev-1.13.0`) and log the returned version when a threshold depends on a specific calibration — `jev-latest` silently re-aims any threshold tuned on an earlier release, and the optimal threshold has moved substantially between datasets.

## Cost and latency

About $0.042 per million input tokens with free output, and typically 70–500 ms per call. Cheap enough for per-task routing and triage; not worth a call per tool invocation.

## Removal

Delete the `mcp.typesafe` entry from `opencode/opencode.jsonc` and the `opencode/skills/jev-decisions/` directory, then run `agentctl sync`. No other state is created; the binary and the key live outside this repository.

## Deferred candidates

- **Skill routing** (`skillranker` and similar) targets a real cost here, because skill descriptions compete for selection. Deferred: `skillranker` now runs on macOS but still only hooks Claude Code, and OpenCode-compatible routers (`skill-injector`, `skill-finder`, `opencode-agent-skills-md`) are unverified here. Re-evaluate before wiring.
- **Compaction** (`fast-jev-compaction` and ports) is the most publicized Jev use, but independent scorecards report its retention rule drops nearly all candidates and ties plain recency at matched budget, and compaction is a prompt-injection surface. Not wired.
- **Local alternates**: no Jev-compatible local server is verified to exist — earlier notes here named Kev and `simple-jev`, but neither could be confirmed. If a real `/v1/systemone` implementation surfaces, a same-interface fallback would not change how the skill is used.
