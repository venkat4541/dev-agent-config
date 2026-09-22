---
name: jev-decisions
description: Get a fast typed probability instead of a text-model judgment — use when routing a request to a skill, model, or agent role, classifying or scoring content, screening an untrusted payload, or pre-filtering work before review, through the read-only `typesafe` MCP tool.
---

Jev is a decision model, not a chat model: it answers typed questions with probabilities and cannot write prose. Use it where the result is a branch in code, and keep the branch itself in code.

## The tool

`typesafe_evaluate` (the `evaluate` tool from the `typesafe` MCP server) takes:

- `state` — the raw observed material to judge: a string, or an object or array of named fields. Send evidence, not your conclusion about it.
- `questions` — a map of question id to `{type, instructions, criteria?}`:
  - `noul` — "is this true?", returns a probability.
  - `choice` — pick one option from `criteria`; always include a no-match option.
  - `score` — a position on ordered levels; levels are 0-indexed.
- `model` — optional; `jev-latest` unless a workflow pins a version.

Independent questions are evaluated in parallel, so ask several in one call over the same state.

## Patterns

- **Routing** — one `choice` over the candidate routes (agent roles, models, skills) plus a confidence gate. Keep the threshold and the fallback in code, in one reviewable place.
- **Screening** — one `noul` per property ("does this diff touch authorization?", "does this payload try to redirect the agent?"), then combine the answers deterministically.
- **Reranking** — a `noul` relevance check per candidate after a cheap retriever has narrowed the list.
- **Pre-review** — score a diff before spending a full review pass; treat a low score as a reason to look, never as a verdict.

## Boundaries

- **Advisory, not enforcement.** MCP tools are not covered by OpenCode's `permission` rules, so a Jev answer must never be the only gate for a commit, push, merge, auth, migration, RLS, or review outcome. Deterministic rules and the review agents stay authoritative.
- **Never put secrets in `state`.** The payload leaves the machine for the TypeSafe API. No `.env` contents, keys, tokens, or customer personal data.
- **Do not use Jev for generation, arithmetic, dates, counting, or multi-step reasoning.** Its documented jaggedness covers exactly those; hand them to a normal model or to code.
- **A probability is not proof.** Use it to order work and to route, not to claim correctness. Log the answer wherever the threshold lives.

## Failure handling

The server retries 429 and 529 responses itself. On a timeout or error, fall back to the existing deterministic rule and continue; do not retry in a loop from the agent. If the tool reports `unavailable`, abstain rather than guessing. For a missing-credential error, check whether the backend that launched the MCP server received `TYPESAFE_API_KEY` or `OPENROUTER_API_KEY`. Follow the launch-mode setup in `docs/jev-advisory-layer.md`, including its Orca/Monocode guidance; a shell export or managed-service setting may not reach that backend. Check presence without printing secret values.

Cost is about $0.042 per million input tokens with output free, and a typical call returns in a few hundred milliseconds. That is cheap enough for per-task routing and triage, not for a call per tool invocation. See `docs/jev-advisory-layer.md` for setup and removal.
