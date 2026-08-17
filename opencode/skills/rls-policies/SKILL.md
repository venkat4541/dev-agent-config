---
name: rls-policies
description: Write, review, and test Postgres/Supabase row-level security policies — use when adding a table the browser can reach, changing tenant isolation, or debugging a query that returns too many or zero rows.
---

RLS is the authorization boundary in a Supabase project. A table the browser's anon key can reach is protected by its policies and nothing else.

## Order of operations

1. `alter table <t> enable row level security;` — do this in the same migration that creates the table. A table with RLS enabled and no policies denies everything, which is the correct failure direction.
2. Write one policy per operation. `for all` hides which operation is actually permitted; prefer explicit `select`, `insert`, `update`, `delete` policies.
3. Test the deny path before the allow path (see the matrix below).

## USING versus WITH CHECK

This distinction causes most RLS bugs:

- `using` filters rows that already exist. It applies to `select`, `update`, `delete`.
- `with check` validates the row's new contents. It applies to `insert` and `update`.

An `update` policy needs **both**: `using` decides which rows you may touch, `with check` decides what you may turn them into. A policy with only `using` on an update lets a user move their own row to another tenant:

```sql
-- Wrong: user can reassign their row to any org
create policy "update own" on documents for update
  using (owner_id = auth.uid());

-- Correct: the row must still be theirs afterwards
create policy "update own" on documents for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());
```

An `insert` policy needs only `with check`.

## Tenant isolation

Derive the tenant from the session, never from a client-supplied argument. If membership lives in another table, keep the lookup in a `security definer` function so the policy does not recurse into a table that is itself protected:

```sql
create or replace function auth_org_ids()
returns setof uuid
language sql stable security definer set search_path = ''
as $$ select org_id from public.memberships where user_id = auth.uid() $$;

create policy "read own orgs" on public.documents for select
  using (org_id in (select auth_org_ids()));
```

Always set `search_path = ''` on a `security definer` function and schema-qualify every reference inside it; without that it is a privilege-escalation vector.

## Test matrix

Every policy change needs all five cases, as tests, not manual checks:

| Case | Expectation |
| --- | --- |
| Owner reads own row | returns the row |
| Authenticated user reads another tenant's row | returns zero rows, not an error |
| Anonymous user reads any row | returns zero rows |
| User writes a row assigned to another tenant | rejected by `with check` |
| Update that moves a row out of the user's tenant | rejected by `with check` |

Cross-tenant reads return **empty**, not an error — a test asserting "no exception" proves nothing. Assert row counts and IDs.

## Performance

A policy predicate runs per row. Index the columns it filters on (`owner_id`, `org_id`). Wrap a per-statement function call in a scalar subquery so Postgres evaluates it once rather than per row:

```sql
using (owner_id = (select auth.uid()))
```

## Review checklist

- RLS enabled on every table reachable with the anon or authenticated key.
- No `update` policy with `using` but no `with check`.
- No policy trusting a client-supplied tenant or role argument.
- No `security definer` function without `set search_path = ''`.
- Service-role usage confined to server code; it bypasses RLS entirely, so never let a service-role client take a tenant ID from a request without re-checking it.
- Policy predicates indexed.
- Denied paths covered by tests.
