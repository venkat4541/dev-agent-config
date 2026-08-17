---
name: brainstorming
description: Turn a vague request into a specific, agreed design before any code exists — use when the ask is underspecified, when several interpretations would produce different work, or when you notice you are about to guess at a requirement.
---

The failure this prevents: implementing a confident interpretation of an ambiguous request, then discovering at review that the wrong thing was built. Cheap to prevent by asking, expensive to fix afterwards.

## When to invoke this rather than just building

Invoke when any of these is true:

- Two reasonable readings of the request lead to materially different implementations.
- The success condition is not stated — you could not write the acceptance test.
- The request names a solution ("add a cache", "use websockets") without the problem it solves.
- Scope boundaries are unclear: which users, which states, what happens on failure.

Do **not** invoke for a request that is already specific, or for a contained defect with an obvious correct behaviour. Interrogating a clear request is its own kind of waste.

## How to run it

**One question at a time.** A numbered list of eight questions gets a partial answer to three of them. Ask the highest-leverage question, absorb the answer, let it determine the next question. This is a conversation, not a form.

Ask about the problem before the solution. When handed a proposed mechanism, find out what outcome it is meant to produce — often a simpler mechanism serves it, and sometimes the underlying problem is already solved elsewhere in the repo.

Ground each question in evidence you gathered first. Read the relevant code before asking, so questions are "the existing invite flow expires tokens after 7 days — should this follow that, or does it need its own window?" rather than "how long should tokens last?" A question the repository already answers should not be asked.

Prefer concrete alternatives over open prompts. "Should deletion be immediate, or soft-delete with a 30-day window like `documents` already does?" is answerable; "how should deletion work?" hands the work back.

Surface what you are assuming. State the assumption you would proceed on and let it be corrected — that converts silent risk into a cheap confirmation.

## What to establish before stopping

- The user-visible outcome, stated concretely enough to test.
- Explicit non-goals — what this change deliberately does not do.
- The states that must be handled: empty, error, unauthorized, concurrent, partial.
- Which existing conventions and boundaries the change must respect.
- The rough shape of the solution, and one alternative that was rejected with a reason.

## The gate

Restate the agreed design in your own words and get confirmation before implementing. If the restatement surprises the user, the design was not agreed — that surprise arriving now instead of at review is the entire point.

Then hand off: `/plan-feature` for the staged implementation plan, or the `grill-me` skill first when the design carries real risk. Do not begin editing during the brainstorm.
