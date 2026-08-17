---
name: playwright
description: Write or repair Playwright end-to-end tests — use when adding coverage for a user journey, choosing locators, setting up authenticated state, or diagnosing a flaky, slow, or timing-dependent browser test.
---

E2E tests are the most expensive and most fragile tests in the suite, so they cover a small set of journeys whose value is in the wiring: sign-in, authorization boundaries, the primary user task, and anything spanning several systems. Push everything else down to integration or unit level.

Reuse the project's existing fixtures, helpers, and config rather than establishing a parallel setup.

## Locators

Prefer, in order:

1. Role with accessible name — `getByRole("button", { name: "Save" })`. This asserts the accessible name as a side effect, so an accessibility regression breaks the test.
2. Label, placeholder, or visible text for form fields and content.
3. An explicit test id, when the above cannot identify the element unambiguously.

Avoid CSS and XPath tied to structure or generated class names; they break on unrelated markup changes without indicating a real regression. Prefer a user-visible attribute over a structural path.

## Waiting

Playwright locators auto-wait for the element to be actionable, and web-first assertions like `expect(locator).toBeVisible()` retry until they pass or time out. Rely on that.

Never use a fixed sleep. A `waitForTimeout` is either too short (flaky) or too long (slow), and it hides the condition you actually meant to wait for. When you need to wait for something specific, wait for the condition: a response, a URL, an element state, a network idle event. If a test needs a sleep to pass, there is an unidentified race — find it (see `debugging`).

## Isolation and data

Each test creates the state it needs and does not depend on another test having run. Tests that share one mutable fixture row will fail unpredictably under parallel execution.

Prefer creating data through an API or a setup helper over driving the UI, which is slow and couples every test to the creation flow. Scope data to the test with a unique identifier so parallel runs do not collide, and clean up afterwards — or use a per-worker isolated database or namespace if the project provides one.

Authenticate once and reuse storage state rather than signing in through the UI in every test. Keep at least one test that does exercise the real sign-in flow.

## What to assert

Assert what the user can observe: visible text, URL, element state, and the presence or absence of a control. Include the negative cases that matter — a user without permission does not see the action, an invalid submission shows the error next to the field.

Avoid asserting on exact copy that changes frequently, and avoid full-page screenshot comparisons unless the project has deliberately adopted visual regression testing with a review workflow.

## Diagnosing failures

Read the trace before changing the test. The trace viewer shows the DOM at each step, the network activity, and where the locator failed to resolve — that usually identifies the cause immediately. Use the built-in debug and UI modes to step through interactively. Check whether the failure reproduces headed versus headless, and in isolation versus in the full parallel run; a test that only fails in parallel is a data-isolation problem, not a timing one.

Do not fix a flaky E2E test by increasing its timeout or adding a retry. Retries hide a real defect that users will hit.

## Report

The journeys covered, the commands run with their results, any test you had to make more specific and why, and any flakiness observed with its identified cause.
