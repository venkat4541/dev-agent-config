---
name: supabase
description: Work with Supabase clients, auth sessions, generated types, storage, and data access — use when wiring a client, handling sessions in server rendering, regenerating database types, or deciding between anon and service-role access.
---

For row-level security policies see `rls-policies`; for schema change sequencing see `migrations`. This skill covers the client and application layer.

## Pick the right client

Three distinct clients, and confusing them is the main source of security bugs here:

- **Browser client** (anon key) — safe to expose. Every query it makes is subject to RLS. This is the intended path for user-scoped reads and writes.
- **Server client** (anon key, carrying the user's session) — runs as the user, still subject to RLS. Use this in server components, actions, and route handlers for anything acting on behalf of the signed-in user.
- **Service-role client** — bypasses RLS entirely and is fully privileged. It must never be constructed anywhere reachable by the browser, and its key must never carry a `NEXT_PUBLIC_` prefix. Confine it to server-only modules for administrative work.

The critical consequence: a service-role client does its own authorization or none at all. Taking a tenant or user ID from a request and querying with the service-role client is an authorization bypass, because the policy layer that would have caught it is switched off. Prefer the user-scoped server client, and reach for service-role only when the operation genuinely is administrative.

## Sessions in server rendering

Auth state lives in cookies, so a server client must be constructed per request with that request's cookie access — never share a client instance across requests, or one user's session leaks into another's. Refresh handling has to be able to write cookies back, which means constructing it where a response is available.

When checking who the user is on the server, verify with the auth server rather than trusting a decoded token from the cookie; a value read straight out of a cookie is client-controlled. Handle the unauthenticated case explicitly on every protected path rather than assuming a user exists.

## Generated types

Regenerate database types from the schema after every migration and commit the result — never hand-edit them. A stale generated type is worse than no type: it type-checks against a schema that no longer exists. If typecheck passes but a query fails at runtime on a missing column, suspect stale types first.

Let query results carry their generated types inward instead of asserting a shape. Note that a join or a selected subset produces a different type than the whole row; assert nothing, derive instead (see `typescript`).

## Data access

Select the columns you need rather than everything; a whole-row select over a server/client boundary exposes columns the UI never uses. Paginate anything unbounded — a query with no limit grows until it becomes an incident.

Handle the error branch of every call. The client returns `{ data, error }` rather than throwing, so ignoring `error` and using `data` yields a confusing null-shaped failure at the point of use, far from the cause. Distinguish "no rows" from "failed": an empty result under RLS is what a denied read looks like, so treat empty and error differently and never report a permission denial as an application bug without checking policies first.

## Storage

Storage buckets have their own access policies, and a public bucket is public to the internet — decide that deliberately. Never build a storage path from a client-supplied filename; generate the path server-side and validate the upload's size and type. Use signed URLs with a short expiry for private objects rather than proxying bytes through your server, and never expose a service-role-signed URL to a user who should not have that scope.

## Local development

Use the Supabase CLI for local work: run the stack locally, apply migrations there first, and verify policies against real data before touching a hosted project. Keep local credentials in ignored environment files, commit only a `.env.example` with names and safe placeholders, and never point a local `.env` at a production project.

## Review checklist

- No service-role client reachable from client code or a `NEXT_PUBLIC_*` variable.
- Server clients constructed per request, never shared.
- Server-side user identity verified, not decoded from a cookie.
- Generated types regenerated and committed after schema changes.
- Every `error` branch handled; empty results distinguished from failures.
- Queries select specific columns and paginate.
- Storage paths generated server-side; bucket visibility intentional.
