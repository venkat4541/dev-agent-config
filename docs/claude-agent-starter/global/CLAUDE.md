# Global Claude Code Policy

## Goal
Optimize for correctness, low token/context usage, and fast feedback. Prefer the cheapest reliable tool/model. Avoid duplicate investigation.

## Installed Tooling
The following tools are installed and should be treated as known capabilities:
- `rg` for fast content/pattern search.
- `fd` for file and directory discovery.
- `jq` for filtering and transforming JSON.
- TypeScript Language Server for semantic TypeScript/JavaScript navigation and diagnostics.
- `pyright` for Python type checking/diagnostics.

Prefer repository-native wrappers/configuration when they exist. Do not replace project lint/test/format conventions merely because another tool is installed.

## Tool-First Hierarchy
Before spawning an agent or loading a workflow skill, prefer the cheapest sufficient operation.

### TypeScript / JavaScript
1. TypeScript Language Server for definitions, references, implementations, workspace/document symbols, hover/types, and diagnostics.
2. `fd` for file/directory discovery.
3. `rg` for strings, configuration, route paths, environment variables, logs, comments/TODOs, and non-semantic patterns.
4. `jq` for JSON/config/structured command output.
5. `git` for diffs/history (`diff --stat` before large diffs; `log -S/-G` for behavior history).
6. Repository-native tools such as Nx, compiler, linter, and test runner.
7. Targeted file/range reads.
8. Context-efficient exploration/Haiku for broader investigation.
9. Sonnet for substantial well-defined implementation.
10. Opus for architecture, ambiguity, hard debugging, security/privacy, cross-system reasoning, and difficult final decisions.

### Python
1. Python semantic navigation when exposed by the environment.
2. `pyright` for type/interface diagnostics.
3. `fd` for file/directory discovery.
4. `rg` for textual/pattern search.
5. `jq` for JSON/config/structured output.
6. `git` and repository-native Python/Temporal tools.
7. Targeted file/range reads.
8. Context-efficient exploration/Haiku for broader investigation.
9. Sonnet for implementation.
10. Opus for difficult reasoning and high-risk decisions.

Do not spawn an agent when 1-2 targeted tool operations can answer the question reliably.
Do not use `find` when `fd` is available or recursive `grep` when `rg` is available.
Do not use `rg` as a substitute for semantic symbol references when the TypeScript Language Server can answer reliably.

## JSON Efficiency
Use `jq` to reduce JSON before bringing it into context. Extract only relevant fields from large configuration files, logs, or command responses rather than dumping complete JSON documents.

## Model Routing
### Haiku
Use for bounded investigation/mechanical work: locate files/symbols/references, trace callers, summarize relevant code, inspect filtered logs, gather evidence, run targeted checks, identify existing patterns.

### Sonnet
Use for well-defined implementation: components/APIs, tests, refactors, straightforward bugs, repetitive multi-file changes, implementation after approach is established.

### Opus
Reserve for ambiguous requirements, architecture/planning, difficult root-cause analysis, security/privacy-sensitive decisions, cross-system reasoning, conflicting evidence, repeated failures, and high-risk final review.

Escalate Haiku -> Sonnet when implementation or substantial reasoning is needed. Escalate Sonnet -> Opus when architecture/ambiguity/security appears or repeated attempts fail.

## Context Efficiency
- Return concise findings, not source dumps.
- Prefer file paths, symbols, and line ranges as evidence.
- Read only relevant ranges of large files.
- Filter/summarize logs and command output.
- Do not reread code already investigated unless verification is necessary.
- Stop investigating once evidence is sufficient for the next decision.
- If two targeted searches fail or evidence conflicts, escalate instead of searching indefinitely.

## Delegation
Every delegated task should state: objective, scope, expected output, whether edits are allowed, and required verification.
Keep scopes narrow. Avoid overlapping agents unless intentionally testing independent hypotheses.
Parallelize only independent work when latency savings justify extra token use.

## Skills / Workflow Policy
Use skills when their procedure materially improves correctness or saves exploration. Do not invoke heavyweight planning, architecture, arena, swarm, interrogation, multi-agent review, or full TDD workflows for routine changes.
For small well-defined changes: targeted investigation -> implementation -> targeted verification.
For complex/ambiguous/cross-system/high-risk work: use the appropriate workflow skill.
Prefer context-efficient exploration for broad localization when exact files/symbols are unknown.

## Verification
Use the narrowest useful check first:
1. LSP diagnostics
2. affected type/type-check diagnostics
3. directly affected unit tests
4. affected package/project tests
5. integration tests
6. full suite only when justified

## Git
Use `git diff` to review changes before rereading modified files. Use history tools when the question is historical. Do not use `git blame` unless ownership/history is relevant.

## General
Follow repository-local `CLAUDE.md`, `AGENTS.md`, and architecture docs for project-specific rules. Repository-local rules override generic workflow preferences when necessary.
