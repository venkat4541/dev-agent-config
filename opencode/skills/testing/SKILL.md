---
name: testing
description: Decide what to test and at which level, then write tests that would actually catch a regression — use when adding coverage for a change, when a test is flaky or slow, or when deciding whether a behaviour needs a unit, integration, or end-to-end test.
---

Discover the project's package scripts, test runner, and existing conventions first, and follow them. A test that does not match local fixture and helper patterns is a maintenance cost even when it passes.

## Choosing the level

Pick the cheapest level that can actually observe the behaviour:

- **Unit** — pure logic, branching, formatting, calculations, reducers, validation rules. Fast, so cover the edge cases here.
- **Integration** — anything crossing a boundary: a handler with its validation and database, a component with its data layer, a policy with a real query. This is where most real defects live and where coverage usually pays off most.
- **End-to-end** — a small number of critical user journeys, and flows whose value is in the wiring: sign-in, permissions, checkout, the primary task. See `playwright`.

Authorization and RLS behaviour belongs at integration level with real queries. A mocked authorization check tests the mock.

## What makes a test worth having

A test earns its place by failing when the behaviour breaks. Before writing one, ask what change would make it fail — if the answer is "a rename", it is testing structure, not behaviour.

- Test observable behaviour through the public interface. Asserting on internal state, private methods, or implementation details makes refactoring expensive and catches nothing.
- Cover the paths that break: empty input, boundary values, the error path, the denied path, concurrent or repeated execution. Happy-path-only coverage is coverage without confidence.
- Prefer specific assertions over "did not throw" or a snapshot of everything. A large snapshot fails on every unrelated change and gets regenerated without being read.
- For a bug fix, the regression test must fail against the unfixed code. If you cannot make it fail, you have not yet identified the defect.

## Determinism

A flaky test is worse than no test — it trains everyone to re-run rather than investigate. Sources, in rough order of frequency:

- Shared state between tests, or state left in the database by a previous run. Each test sets up what it needs and cleans up after itself.
- Test-order dependence. Randomize order to expose it.
- Real clocks and real timers. Inject or fake time rather than sleeping.
- Unawaited promises and missing `await`.
- Parallel workers contending for one resource — a fixed port, a shared row, a single fixture user.
- Real network calls. Mock at the boundary, or use a controlled local service.

## Mocking

Mock at the trust boundary — third-party APIs, payment providers, email, clocks. Do not mock your own modules to make a unit test possible; that usually means the test is at the wrong level. Every mock is an assumption about someone else's behaviour that can silently drift from reality, so keep them few and keep at least one integration test that exercises the real path.

## Rules

- Never weaken an assertion, add a retry, or increase a timeout to make a failing test pass. Investigate what the failure is telling you; if the test is genuinely wrong, explain why before changing it.
- Never edit application code to satisfy a test that is asserting the wrong thing — report the conflict instead.
- Do not delete or skip a failing test to unblock yourself. A skipped test is invisible lost coverage.

## Report

The exact commands run with their real output, which tests are new and what regression each would catch, confirmation that a bug-fix test fails without the fix, what remains uncovered, and any flakiness observed with its suspected cause.
