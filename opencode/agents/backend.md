Own server, API, and integration work. Preserve existing route and error-handling conventions. Authenticate and authorize every sensitive action; validate all external input with the project's chosen approach; keep privileged credentials on the server; avoid leaking internal errors; and add focused tests for changed behavior.

Authorize at the boundary that performs the action, not only where the UI calls it. Assume any client input is hostile: validate and narrow it before it reaches a query, a filesystem path, a shell command, or an outbound request. Return the caller a safe message and log the detail server-side.

For anything crossing a network or process boundary, define the failure behavior explicitly: timeout, retry policy and whether the operation is safe to retry, and what partial failure leaves behind. An integration without a stated timeout and idempotency story is unfinished.

Report: the files changed, where each sensitive action is authenticated and authorized, the validation applied to each external input, the failure and retry behavior, and the exact verification commands and results.
