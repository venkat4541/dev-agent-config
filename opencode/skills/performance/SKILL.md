---
name: performance
description: Diagnose and fix a real performance problem with measurements — use when a page or query is reported slow, a bundle grew, a request times out, or before accepting a change justified as an optimization.
---

Optimize only what you have measured. An unmeasured optimization is a guess that adds complexity and may be a regression.

## Procedure

1. **Name the metric and the target.** "Slow" is not actionable. Which operation, measured how, at what percentile, currently what, acceptable at what? p95 server response, time to interactive, query duration, bundle bytes.
2. **Measure the current state** and record the number. Without a baseline you cannot prove improvement.
3. **Find where the time actually goes** before theorizing. Profile, trace, or instrument. The bottleneck is routinely not where it feels like it should be.
4. **Fix the largest contributor**, one change at a time.
5. **Re-measure and report both numbers.** If the improvement is within measurement noise, revert it — you added complexity for nothing.

## Where the time usually is

Check these before micro-optimizing anything:

**Database** — the most common real cause.
- A missing index on a filtered, joined, or ordered column. Read the query plan; a sequential scan on a large table is the finding.
- N+1 queries: one query per item in a loop. Batch into a single query or a join.
- Over-fetching: `select *` and whole-row fetches where a few columns are used; unbounded result sets with no pagination.
- RLS policy predicates on unindexed columns (see `rls-policies`).

**Request waterfalls** — sequential awaits that have no data dependency. Run them concurrently with `Promise.all`. In a component tree, a parent that fetches before rendering a child that then fetches serializes both.

**Client bundle** — a component marked client-side that did not need to be, a heavy library imported for one function, a barrel file defeating tree-shaking, or a large dependency imported eagerly rather than lazily. Measure the built output, not the source.

**Rendering** — re-render storms from an unstable object or callback identity in a dependency array or context value; large lists rendered without virtualization; layout thrash from reading geometry in a loop.

**Caching** — a cache that is not being hit at all, or one being hit when it should have revalidated. Verify which is happening rather than assuming.

## Rules

- Never trade correctness for speed. A faster wrong answer is a bug.
- Do not add a cache to hide a slow query; fix the query, then decide whether a cache is still warranted. A cache adds an invalidation problem forever.
- `useMemo`, `memo`, and `useCallback` have a cost and are not free wins — apply them to a measured re-render problem, not preemptively.
- Measure in a production build. Development mode has different rendering, caching, and error-handling behaviour, so dev-mode timings are not evidence.
- Beware measuring a warm cache and comparing against a cold one, or a single run against a single run — repeat and compare medians.

## Report

The metric and target, the baseline number, where the time was going with the evidence (query plan, profile, bundle report), the change made, the new number, and anything you chose not to optimize and why.
