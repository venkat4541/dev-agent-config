---
name: migrations
description: Sequence a schema change safely — use when adding, renaming, retyping, or dropping a column or table, backfilling data, or when a migration must ship alongside an application deploy without downtime.
---

A migration runs against a database that already has data and an application version already talking to it. Both facts constrain what a single step may do.

## Never edit an applied migration

Once a migration has run anywhere other than your own machine, it is history. Fix forward with a new migration. Editing an applied file leaves every other environment silently divergent.

## Expand / migrate / contract

Any change that would break the currently-deployed application code must be split. The deployed app and the new schema have to be compatible at every intermediate point.

1. **Expand** — add the new structure, nullable or defaulted, alongside the old. Deploy. The running app ignores it.
2. **Migrate** — backfill existing rows; deploy app code that writes both old and new and reads new. Both shapes remain valid.
3. **Contract** — once no deployed version reads the old structure, drop it.

A "rename a column" request is this three-step sequence, not a `rename`. A direct rename breaks every running instance the instant it commits.

## Locks to avoid

The danger is not duration, it is the lock class. On a large table:

- `create index` takes a write lock — use `create index concurrently` (and note it cannot run inside a transaction block, so it needs its own migration).
- Adding a `not null` column with a non-constant default rewrites the table. Add nullable, backfill, then add the constraint.
- Adding a `not null` constraint validates the whole table under an exclusive lock. Instead: `add constraint ... check (col is not null) not valid;` then `validate constraint ...;` which takes a weaker lock.
- Changing a column type usually rewrites. Prefer a new column plus backfill.
- Adding a foreign key validates existing rows. Use `not valid` then `validate constraint`.

Set a short `lock_timeout` for migrations touching hot tables so a blocked migration fails fast instead of queueing every request behind it.

## Backfills

Backfill in bounded batches with a stable ordering key, committing per batch — a single `update` over millions of rows holds locks and bloats WAL. Make the backfill idempotent and re-runnable, since it will be interrupted at some point. For a large table, keep the backfill out of the migration itself and run it as an explicit, resumable step.

## Rollback

State the rollback for every migration before applying it, and be honest about which direction is recoverable:

- Additive changes roll back cleanly.
- A backfill that overwrote a column is **not** recoverable without a snapshot — say so explicitly.
- A `drop` is not recoverable. Contract steps should lag the deploy that stopped using the column, not accompany it.

If a step cannot be rolled back, the plan must say what data would be lost and what backup covers it.

## Report

State: the migration files in apply order, which step is expand/migrate/contract, the lock each step takes and on what table, whether a backfill is required and how it is batched, the deploy ordering relative to application code, and the rollback path with anything unrecoverable named.

For Supabase RLS policy changes accompanying a schema change, see the `rls-policies` skill — a new table needs its policies in the same migration that creates it.
