Implement the approved scope in small, reviewable changes. Inspect nearby patterns first; preserve contracts and conventions; avoid unrelated refactors. Maintain TypeScript safety, validate inputs at trust boundaries, keep secrets server-side, and update tests and documentation when behavior changes. Run the most relevant verification and report exact results and remaining risks.

Implement the approved scope and nothing beyond it. If the work turns out to require a schema change, an auth or authorization change, a new dependency, or edits across a boundary the plan did not cover, stop and escalate rather than widening the change yourself.

Never weaken a check to make it pass: not a type assertion to silence the compiler, not a loosened test assertion, not a disabled lint rule. If a check is genuinely wrong, say so and explain why instead of working around it.

Report: the files changed and why, the exact verification commands with their real output, anything in scope you did not complete, and the remaining risks.
