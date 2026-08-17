---
name: security
description: Apply and review application security boundaries — use when adding an endpoint, action, or auth check, handling untrusted input or credentials, changing what data a response exposes, or reviewing a change that touches authorization.
---

Identify the trust boundary first: where does data or a request arrive from someone you do not control, and what is the first line of your code that decides whether to honour it?

## Authorization

Enforce it at the boundary that performs the action, not where the UI invokes it. A hidden button, a disabled control, and a client-side route guard are user experience, not security — the endpoint behind them is reachable directly.

- Deny by default. A new endpoint or action starts unauthorized and is opened deliberately.
- Every request needs both questions answered: who is this (authentication), and may *this* actor act on *this* object (authorization). Checking only the first is the most common real vulnerability.
- Derive identity and tenant from the session, never from a request parameter. `orgId` in a body is a suggestion from the caller.
- Check ownership on the specific record being read or written, not just role membership. Missing object-level checks let one user pass another user's ID and get their data.
- Re-check on the write path even when the read path already filtered. Two requests, two checks.

In Supabase projects, RLS is the enforcement layer for anything reachable with the anon key — see `rls-policies`. Service-role clients bypass RLS entirely, so any server code holding one is fully trusted and must do its own authorization.

## Untrusted input

Validate and narrow at the boundary, then let typed values travel inward. Applies to bodies, query and path parameters, headers, cookies, webhook payloads, file uploads, and anything from a third-party API.

- Parameterize queries; never build SQL, a shell command, or a file path by string concatenation with input.
- Constrain redirects to a known-safe allowlist of paths — an open redirect is a phishing primitive.
- Validate file uploads by size and actual type, and never trust the client-supplied filename for a storage path.
- Treat input reaching a URL that your server then requests (SSRF) as dangerous: allowlist the destination.
- Never pass input into `eval`, dynamic `import`, template rendering, or `dangerouslySetInnerHTML` without sanitizing.

## Secrets

Keep credentials out of Git, browser bundles, logs, error messages, and analytics. In Next.js, only `NEXT_PUBLIC_*` reaches the browser and does so permanently — a secret with that prefix is disclosed. Read secrets from the environment on the server, validate their presence at startup, and never log them, including inside an error object being serialized.

If a secret has been committed, it is compromised: it needs rotation, not just removal from the working tree.

## Responses and errors

Return the caller a safe, generic message and log the detail server-side. Stack traces, SQL fragments, internal hostnames, and library versions in a response are reconnaissance. Distinguish "not found" from "forbidden" carefully — leaking existence can itself be the disclosure.

Send the minimum data. Serializing a whole record because it was convenient exposes columns the client never needed, and in a server-to-client component boundary that payload is readable in the page source.

## Change-type checklist

- **New endpoint or action** — authenticated? authorized on the object? input validated? rate limited if unauthenticated or expensive? response minimal?
- **New table reachable by the browser** — RLS enabled with tested deny paths?
- **Auth or session change** — session fixation, expiry, revocation on password change or logout, cookie flags (`httpOnly`, `secure`, `sameSite`)?
- **New dependency** — see the `dependencies` skill.
- **New logging** — could this line log a token, password, or personal data?

## Escalate

Request an independent `security-reviewer` pass, and do not self-approve, for changes to authentication, authorization, RLS, tenant isolation, secrets handling, or anything expanding what a response exposes.
