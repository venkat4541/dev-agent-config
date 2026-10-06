# Claude Code Skills Strategy

This guide complements the global CLAUDE.md. The goal is to minimize always-on context and accidental heavyweight workflows while keeping useful skills available.

## Why configure skills

Claude Code normally exposes model-invocable skill names/descriptions so Claude can decide when to load them. Full skill content is loaded when invoked. Skills configured with `disable-model-invocation: true` are hidden from Claude until you invoke them manually, eliminating their normal always-visible skill context.

## Recommended buckets

| Bucket | Examples | Behavior |
|---|---|---|
| Auto-capable | lightweight/context-efficient repo exploration such as Caveman Explore | Claude may invoke when targeted tools are insufficient |
| Available/selective | useful specialized Superpowers workflows; pstack primary workflow | Invoke only when task complexity warrants |
| Manual-only | arena, interrogate, deep architecture, swarm/multi-agent, expensive review | User explicitly invokes |
| Hide/disable | duplicate workflows, skills never used, side-effecting skills not meant for autonomous use | Not model-invocable |

Treat examples as categories: use the exact skill names installed on your machine.

## Preferred decision path

```text
Semantic question?      -> TypeScript/Python semantic tooling
Need a file?            -> fd
Need text/config/log?   -> rg
Need JSON fields?       -> jq
Need history/change?    -> git
Need Nx scope?          -> Nx
Need Python types?      -> Pyright
Still unclear?          -> targeted read
Broad unknown?          -> lightweight exploration / Haiku
Structured workflow?    -> ONE specialized skill
Normal implementation?  -> Sonnet
Architecture/hard bug?  -> Opus
```

## Manual-only frontmatter

For a skill you own, add this to its SKILL.md frontmatter:

```yaml
---
name: expensive-workflow
description: Use for <specific narrow trigger>.
disable-model-invocation: true
---
```

Do this for rarely used, expensive, overlapping, or side-effecting skills that you want to invoke explicitly.

## Third-party/plugin skills

Do not modify vendor/plugin SKILL.md files merely to control invocation. Use Claude Code's skill controls/overrides. Open `/skills` to review available skills; current Claude Code supports hiding skills from Claude/the slash menu and saving those overrides.

## Suggested policy for this workstation

### Keep auto-capable
- One lightweight/context-efficient exploration skill, if installed.
- Only other skills that are frequent, cheap, narrowly described, and have no risky side effects.

### Keep available but selective
- pstack primary engineering workflow, if installed.
- Specialized Superpowers skills that add a procedure you actually use.

### Make manual-only
- arena
- interrogate
- deep architecture/design workflows
- swarm/multi-agent workflows
- heavyweight planning/review workflows
- deployment/release/side-effecting skills
- overlapping alternatives you want to retain for occasional use

### Hide/disable
- skills never used
- duplicate planning/debugging/brainstorming skills with no unique value
- obsolete skills

## Avoid skill competition

Do not keep multiple vague descriptions such as "use for complex coding tasks" model-visible. Overlapping descriptions make automatic selection less predictable. Make each auto-capable skill's description narrow and trigger-oriented.

Example:
- weak: "Helps investigate code."
- better: "Use when a bug spans multiple files and targeted LSP/rg searches have not identified the responsible implementation."

## Subagents

Do not preload large skill sets into every subagent. Give a subagent only the skills required for its bounded task. Keep investigation outputs concise and evidence-based.

## Maintenance

Revisit `/skills` after installing a plugin/skill pack. Sort/review by token cost when useful, manualize or hide overlaps, and keep the global CLAUDE.md focused on policy rather than copying full skill instructions into it.
