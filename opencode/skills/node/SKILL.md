---
name: node
description: Implement or review Node.js server, API, and tooling code — use when handling async resources, adding an outbound call, designing error and timeout behaviour, adding logging, or reading configuration at startup.
---

Inspect the runtime version, package manager, scripts, and existing error and logging conventions before writing anything. Node's built-ins now cover much of what used to need a dependency — check the platform first (see `dependencies`).

## Configuration

Read and validate configuration once at startup, and fail loudly if something required is missing. A server that boots with an absent variable and fails on the first request that needs it converts a deployment error into a user-facing incident. Never scatter `process.env` reads through business logic; export a validated, typed config object.

## Async and resource handling

- `await` everything, or explicitly handle the promise. An unawaited promise loses its error and its ordering; in a request handler it can also outlive the response.
- Use `Promise.all` for independent work, and `Promise.allSettled` when partial failure is acceptable — but know which you mean. `Promise.all` rejects on the first failure and leaves the others running unobserved.
- Release what you acquire — file handles, database clients, streams, listeners — in a `finally` or with the project's scoped helper. A connection leaked per request exhausts the pool under load.
- Do not block the event loop. Synchronous file I/O, large JSON parsing, and crypto or compression on the request path stall every concurrent request. Move heavy CPU work off the main path.
- Stream large payloads rather than buffering them into memory, and respect backpressure with `pipeline` instead of manual `pipe` chains, which drop errors.

## Outbound calls

Every network call needs a timeout — the default is often none, which turns a slow dependency into an outage. Use `AbortSignal.timeout` and propagate the caller's abort signal so a cancelled request does not leave work running.

Decide and state whether an operation is safe to retry. Retry only idempotent operations, with backoff and a cap; retrying a non-idempotent write creates duplicates. For anything that charges money or sends a message, use an idempotency key rather than hoping.

Define what partial failure leaves behind. If step two fails after step one succeeded, is the system consistent? If not, either make it atomic or make it recoverable and say which.

## Errors

Throw `Error` instances, never strings, and preserve the original with the `cause` option instead of discarding the stack. Distinguish expected operational failures (invalid input, not found, upstream unavailable) from programmer errors (a bug); handle the first, and let the second surface loudly rather than being swallowed.

At the boundary, return the caller a safe, generic message and log the detail server-side. Never let a stack trace, SQL fragment, or internal hostname reach a response.

Catch nothing you cannot handle. An empty catch block, or one that logs and continues with a broken invariant, converts a visible failure into silent corruption.

## Logging

Use the project's logger and its structured format — never bare `console.log` in server code if a logger exists. Log at the boundary with enough context to trace a request (a correlation ID, the operation, the outcome, the duration). Do not log tokens, passwords, keys, full request bodies, or personal data; be aware that serializing an error or a config object can include a secret you did not intend.

## Shutdown

For long-running processes, handle `SIGTERM`: stop accepting new work, let in-flight requests finish within a bounded grace period, close database pools and other resources, then exit. Without this, deploys drop live requests. Register handlers for `unhandledRejection` and `uncaughtException` to log and exit rather than continuing in an unknown state.

## Review checklist

- Config validated at startup; no scattered `process.env`.
- Every outbound call has a timeout; retries only on idempotent operations.
- Acquired resources released on every path, including errors.
- No blocking work on the request path; large payloads streamed.
- Errors preserve `cause`; responses leak no internals; no empty catch.
- Logs carry request context and no secrets.
