---
name: nextjs
description: Work safely in Next.js App Router projects — use when adding or changing a route, server action, route handler, or data fetch, when deciding server versus client components, or when stale or missing data suggests a caching problem.
---

Follow the repository's existing router and rendering conventions; if the project uses the Pages Router, do not mix in App Router patterns.

## Server and client boundary

Components are server components by default. Add `"use client"` only when the component needs interactivity, state, effects, browser APIs, or a client-only library. Push the directive to the leaf that needs it — marking a layout or page client-side pulls its whole subtree along.

What must never cross into a client component: secrets, privileged keys, service-role clients, server-only modules, and unfiltered records. Anything passed as a prop from a server to a client component is serialized into the HTML payload and is readable by the user. Filter and shape data on the server, then pass the minimum.

Environment variables: only `NEXT_PUBLIC_*` are exposed to the browser, and they are exposed at build time and permanently public. Never give a secret that prefix. A server-only variable read in a client component is `undefined`, not an error — check the boundary before debugging the value.

## Data fetching

Fetch in server components, close to where the data is used. Run independent fetches concurrently with `Promise.all` rather than sequential awaits, which serialize into a waterfall. Do not fetch in a client component through an effect when a server component could fetch it directly.

## Caching

Caching is the most common source of surprising behaviour, and the defaults differ by Next.js major version — check the version in `package.json` and the project's existing conventions before assuming. Determine which of these is in play before changing anything:

- **Request memoization** — identical fetches within one render pass are deduplicated.
- **Data cache** — persists fetch results across requests; controlled per fetch (`cache`, `next.revalidate`) or by route segment config.
- **Full route cache** — a statically rendered route's HTML. Using a dynamic API (cookies, headers, searchParams) opts the route into dynamic rendering.
- **Router cache** — client-side, holds visited segments for a short window.

When data is stale, identify *which* cache served it rather than sprinkling `revalidate` and `no-store` until it changes. Invalidate deliberately with `revalidatePath` or `revalidateTag` after a mutation, and prefer tags for anything read by several routes.

A route that must never be cached needs an explicit declaration, not an assumption. Verify caching behaviour with a production build — `next dev` does not cache the same way.

## Server actions and route handlers

A server action is a public HTTP endpoint. Being defined next to the component that calls it grants no protection:

- Authenticate and authorize inside the action itself, every time. Never rely on the UI having hidden the button, or on a value the client passed claiming who they are.
- Validate and narrow every argument before use — arguments are attacker-controlled.
- Revalidate affected paths or tags, and return a serializable result.

Use a route handler for webhooks, third-party callbacks, and non-form APIs; use a server action for mutations driven by your own UI. Webhook handlers must verify their signature before trusting the payload.

## Route conventions

For each route you add or change, decide the behaviour of `loading`, `error`, and `not-found` rather than leaving them to the nearest ancestor's default. `error.tsx` must be a client component. Errors thrown in server components reach the client with details stripped in production, so log the detail server-side. Set `metadata` for user-facing routes.

## Middleware

Middleware runs on every matched request, so keep it cheap and scope the matcher tightly. It runs in a limited runtime — no Node built-ins or heavy dependencies. Treat it as routing and coarse gating, never as the only authorization check: enforce authorization again where the action or query happens.

## Verify

Run the production build, not just the dev server: build-time type errors, static/dynamic rendering decisions, bundle composition, and caching behaviour only surface there.
