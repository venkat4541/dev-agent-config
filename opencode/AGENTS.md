# Global development guardrails

Inspect before editing. Understand the repository architecture, dependency graph, existing conventions, and relevant local instructions before proposing or making a change.

Preserve established conventions and reuse existing abstractions where they fit. Do not impose a preferred stack or architecture on an existing project. Avoid unrelated refactors and keep changes small, focused, and reviewable.

Plan non-trivial changes before implementation. Keep TypeScript safe; maintain clear server/client boundaries; validate untrusted input; and never expose secrets, credentials, or privileged service-role access to clients or source control.

Verify changes with the project’s relevant typecheck, lint, tests, and production build. Make database changes through reviewed migrations, maintain least-privilege authorization (including Supabase RLS where applicable), and document required operational steps.

Build accessible, secure software. For substantial changes, request independent review before declaring completion.

