---
name: typescript
description: Resolve type problems without weakening safety — use when fighting a type error, designing a shared type or public API signature, handling data from an untyped boundary, or when tempted to reach for `as`, `any`, or a ts-expect-error.
---

Read the local `tsconfig.json`, lint rules, and nearby code before changing types. Strictness settings determine which of the patterns below are even necessary, and existing domain types usually already model what you need.

## A type error is information

The compiler is reporting a real mismatch. Silencing it moves the failure to runtime. Before reaching for an escape hatch, identify which of these it is:

- The type is right and the code is wrong → fix the code.
- The type is too loose to express the invariant → improve the type.
- The value genuinely comes from outside the type system → validate it at that boundary.

## Escape hatches, and what to use instead

| Instead of | Use |
| --- | --- |
| `as SomeType` on unvalidated data | a runtime validation at the boundary that returns the type |
| `any` | `unknown`, then narrow |
| `as any` to reach a property | a type guard, or fix the source type |
| `!` non-null assertion | an explicit check, or a type that cannot be null |
| `@ts-expect-error` | a correct type; if unavoidable, a comment stating why and what would remove it |
| `as unknown as T` | nothing — this is always a bug or a missing validation |

`as const` and `satisfies` are not escape hatches: `satisfies` checks a value against a type while keeping its narrow inferred form, which is what you usually want for config objects and lookup tables.

## Untrusted and untyped boundaries

Data from a network response, `JSON.parse`, `process.env`, a form submission, a query parameter, or a database driver is `unknown` regardless of what its declared type says. Declaring `const user = await res.json() as User` is a lie the compiler will not catch and runtime will.

Validate at the boundary with the project's existing approach and let the validated result carry the type inward. Then the interior can be strictly typed without assertions. Validate environment variables once at startup rather than reading `process.env` throughout.

## Modelling

Prefer making invalid states unrepresentable over checking for them everywhere:

- Use a discriminated union rather than optional fields that are only valid in combination — `{ status: "loading" } | { status: "ok"; data: T } | { status: "error"; error: E }` beats an object with three optional properties and an implicit contract.
- Get exhaustiveness checking by switching on the discriminant and giving the default branch a `never` type, so adding a variant becomes a compile error at every handler.
- Prefer a union of string literals to a loose `string` for a closed set.
- Derive types rather than duplicating them: `keyof`, `typeof`, indexed access, and `Pick`/`Omit` keep a derived type in sync with its source; a hand-copied parallel type will drift.
- Reach for generics only when a relationship between inputs and output must be preserved. A generic that appears once and is immediately constrained to one type is noise.

## Public contracts

Changing an exported signature is a breaking change for every caller. Widen parameters and narrow return types freely; the reverse breaks callers. When a change is genuinely breaking, find and update the call sites in the same change rather than leaving them to type-check later.

## Verify

Run the project's typecheck, not just the editor's. Editor and CLI can disagree on project references, path aliases, and generated types. If the project has generated types (from a schema or database), regenerate them rather than hand-editing, and commit the result.
