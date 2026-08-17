# Project agent notes

## Commands

- Install: `pnpm install`
- Development: `pnpm dev`
- Typecheck: inspect `package.json` for the project command
- Lint: `pnpm lint`
- Test: add and document Vitest/Playwright commands before relying on them
- Production build: `pnpm build`

## Architecture guardrails

- Prefer a simple Next.js application with clear feature boundaries; do not add services without a demonstrated need.
- Keep service-role use server-only. Use public Supabase credentials only where the browser client is intended to use them.
- Define RLS before exposing a table through the client. Test allowed and denied access paths.
- Validate external input with Zod at route/server-action boundaries.
- Use accessible semantic UI and preserve the selected component conventions.
- Before large implementation, document architecture, data model, auth/RLS, route boundaries, UI organization, and test strategy in `docs/architecture.md`.

