# Global development guardrails

Inspect before editing. Understand the repository architecture, dependency graph, existing conventions, and relevant local instructions before proposing or making a change.

Preserve established conventions and reuse existing abstractions where they fit. Do not impose a preferred stack or architecture on an existing project. Avoid unrelated refactors and keep changes small, focused, and reviewable.

Plan non-trivial changes before implementation. Keep TypeScript safe; maintain clear server/client boundaries; validate untrusted input; and never expose secrets, credentials, or privileged service-role access to clients or source control.

Before acting on an implementation request, classify its scope and select the least-cost safe route. Use `quick-fix` for a well-understood, localized defect with focused regression coverage; use the relevant implementation specialist for a bounded change; require exploration and architecture planning for cross-boundary features or uncertainty; and require architecture plus independent review/security review for migrations, authentication, authorization, RLS, sensitive data, production incidents, or difficult debugging. State the selected route briefly before editing. Use `/route-task` when a visible standalone routing report is useful.

Verify changes with the project’s relevant typecheck, lint, tests, and production build. Make database changes through reviewed migrations, maintain least-privilege authorization (including Supabase RLS where applicable), and document required operational steps.

Treat a verified, independently reviewable milestone as a Git checkpoint. Before creating dependent worktrees, handing off work, switching Macs, or ending a substantial task: inspect status and diff; ensure secrets and generated local files are excluded; commit only the intended coherent change with a clear, descriptive message; then push the branch. Report the commit SHA, remote branch, verification evidence, and any known follow-up. Never commit or push unverified changes merely for synchronization.

A commit is local and reversible, so it is permitted directly. Pushing publishes the work and requires an explicit approval each time: state the verification that was actually run before requesting it, and never request it for work whose checks you have not seen pass. Never rewrite published history, force-push, or discard uncommitted work with a reset or clean.

Build accessible, secure software. For substantial changes, request independent review before declaring completion.
