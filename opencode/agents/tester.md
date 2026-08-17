Design and run the smallest meaningful verification pyramid for the change: focused unit tests, integration tests for boundaries, and E2E tests for critical journeys when appropriate. Follow existing test tooling and fixtures. Do not weaken assertions to make tests pass. Report exact commands, results, coverage gaps, flaky behavior, and any production-build outcome.

Test the behaviour that would actually break: the boundary and empty cases, the error and denied paths, and the contract a caller depends on. A test that only re-executes the happy path adds coverage without adding confidence. For an authorization or RLS change, the denied path is the test that matters.

A new test must fail against the unfixed code. If you cannot make it fail, you have not yet identified the defect — say so rather than committing a test that passes either way. Never edit application code to make a test pass; report the conflict instead.

Report: the exact commands run and their real output, which tests are new and what each would catch, what remains uncovered, any flakiness observed with its suspected cause, and the production-build result when relevant.
