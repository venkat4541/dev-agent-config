---
name: dependencies
description: Evaluate, add, upgrade, or remove a third-party package — use when a change would introduce a new dependency, bump a major version, resolve an audit finding, or when deciding whether to build something in-repo instead.
---

Every dependency is permanent maintenance, supply-chain surface, and — for client code — bytes shipped to users. The default answer is no.

## Before adding

Ask in order:

1. **Does the repo already solve this?** Search for an existing utility, wrapper, or a transitive dependency already present. Two libraries doing one job is worse than either alone.
2. **Does the platform solve this?** Modern Node and browsers cover fetch, crypto, UUID generation, structured clone, date formatting via `Intl`, and argument parsing. A dependency for a one-line platform call is not worth it.
3. **Is it small enough to own?** If the need is a few dozen lines with no ongoing spec churn, writing it is usually cheaper than a dependency with its own transitive tree.

If it still looks necessary, evaluate the candidate:

- **Maintenance**: recent releases, issues being triaged, more than one maintainer, and a changelog. An unmaintained package is a future migration you have already scheduled.
- **Transitive weight**: how many packages does it actually install? A dependency with a large tree multiplies the audit and update surface.
- **Client bundle cost**: for anything reaching the browser, check the shipped size and whether it tree-shakes. A server-only dependency is far cheaper than a client one — verify which side it lands on.
- **Licence**: confirm it is compatible with the project. Copyleft in a distributed product is a decision, not a detail.
- **Types**: first-party TypeScript types, or a maintained `@types` package.
- **Install-time behaviour**: postinstall scripts, native builds, and binary downloads are all supply-chain risk. Prefer packages without them.

## Adding

Use the project's package manager — never mix (`pnpm` here unless the lockfile says otherwise) — and commit the lockfile in the same change. Put it in `dependencies` versus `devDependencies` deliberately: a build-time or test-only package in `dependencies` ships to production. Pin according to the repo's existing convention rather than introducing a new range style.

## Upgrading

Upgrade one meaningful thing at a time so a regression is attributable. For a major bump, read the changelog and migration guide first and treat it as its own reviewable change — never bundled into a feature. Run typecheck, lint, tests, and a production build; a major upgrade that only passes unit tests is unverified. Check for peer-dependency conflicts rather than forcing resolution.

## Audit findings

Establish whether the vulnerable path is actually reachable in your usage before acting — an advisory in a dev-only transitive dependency is a different urgency from one in a request path. Prefer upgrading the direct dependency that pulls it in over pinning an override, which hides the problem from the next audit. Record the reasoning for anything deliberately not fixed.

## Removing

When a dependency's last usage goes away, remove it in the same change. Search for the import rather than trusting memory, and drop the lockfile entry too.

## Report

What need it serves, the alternatives considered including doing it in-repo, its install and bundle cost, which side of the server/client boundary it lands on, its licence, and the verification you ran.
