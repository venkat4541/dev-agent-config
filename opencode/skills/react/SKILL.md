---
name: react
description: Build and review React components — use when adding or restructuring a component, deciding where state lives, writing or removing an effect, or diagnosing stale values, re-render loops, and unnecessary client state.
---

Inspect existing component, state, and data-fetching patterns first, and follow them. Do not introduce a new state manager, data-fetching library, or component architecture without a demonstrated need.

## State

Keep state as local as possible and lift it only when a second component genuinely needs it. Prefer, in order: derive it, keep it local, lift it to the nearest common parent, put it in context, reach for a store.

Do not store what you can derive. A value computed from props or other state should be computed during render, not mirrored into state and synchronized — that duplication is where stale-value bugs come from. Do not copy props into state unless you specifically want to snapshot the initial value, and then name it so that intent is obvious.

Server-owned data is not component state. In a framework with server components or a data-fetching library, fetching into `useState` via an effect gives up caching, deduplication, and revalidation, and reintroduces loading and error handling by hand.

## Effects

Most effects should not exist. An effect is for synchronizing with something outside React — a subscription, a browser API, a non-React widget, an imperative focus call. It is not the place for:

- Transforming data for rendering → compute during render.
- Responding to a user event → do it in the event handler.
- Resetting state when a prop changes → use a `key` to remount instead.
- Fetching data → use the framework's or library's mechanism.

When an effect is warranted: list every reactive value it reads in the dependency array, and clean up subscriptions, timers, and in-flight requests in the returned function. Do not silence the exhaustive-deps lint rule — a missing dependency is a stale-closure bug waiting to happen. If a dependency causes a loop, the fix is usually a stable identity or moving the logic out, not deleting the dependency.

## Identity and re-renders

Objects, arrays, and functions created during render are new every time. That matters when they are dependencies, context values, or props to a memoized child. A context value should be memoized, or the whole subtree re-renders on every parent render.

`memo`, `useMemo`, and `useCallback` are for measured problems. Applied preemptively they add cost and complexity for no benefit — see the `performance` skill before reaching for them.

`key` is identity, not a loop counter. Using an array index as a key on a reorderable or filterable list causes state to attach to the wrong item. Use a stable ID.

## Component structure

Keep a component focused on one responsibility; extract when it does two things, not when it reaches a line count. Extract logic to a hook when two components need the same behaviour, not to make a file shorter.

Every component displaying async data needs a defined loading, error, and empty state. An empty state is not the same as loading, and neither is the same as an error — a component that shows a blank area for all three is incomplete. Add an error boundary where a subtree failing should not take down the page.

## Forms and interaction

Follow the project's form approach. Associate every input with a label, surface validation errors next to the field and announce them, keep the submit button's disabled state tied to real submission state, and prevent double submission. See the `accessibility` skill for focus and announcement requirements.

## Review checklist

- No state that could be derived; no props mirrored into state without reason.
- No effect that should be an event handler, a computed value, or a `key`.
- Dependency arrays complete, with no suppressed lint rule.
- Context values and memoized-child props have stable identity.
- Keys are stable IDs, not indices.
- Loading, error, and empty states all present.
- No secret or unfiltered dataset passed into a client component.
