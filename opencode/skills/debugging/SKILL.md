---
name: debugging
description: Find the root cause of a defect methodically — use when a test fails for unclear reasons, behaviour differs between environments, a bug is intermittent, or a fix attempt did not work.
---

The goal is a causal explanation, not a change that makes the symptom disappear. If you cannot say why the defect occurred, you are not ready to fix it.

## Procedure

1. **Reproduce deterministically.** Find the smallest reliable trigger before changing anything. A bug you cannot reproduce on demand cannot be verified as fixed. If it is intermittent, find what varies: ordering, timing, concurrency, leftover state, timezone, locale, cache.
2. **Read the actual error.** Full stack trace, innermost frame first. Identify the first frame in project code. Note the real values in scope, not the assumed ones.
3. **Bisect the distance between working and broken.** Across time, use `git bisect` or `git log -S<symbol>` to find the introducing commit. Across space, cut the input or code path in half repeatedly. Across environments, diff config, versions, env vars, and data.
4. **Form one falsifiable hypothesis.** State it as "X happens because Y, so if I change Z the behaviour becomes W." A hypothesis that cannot be wrong is not a hypothesis.
5. **Instrument to test that hypothesis.** Log or inspect the specific value that would confirm or refute it. Prefer a debugger or a targeted assertion over scattered prints.
6. **Confirm the cause before fixing.** You should be able to explain the full chain from trigger to symptom. If two candidate causes remain, distinguish them with one more observation.
7. **Fix the cause, then write the regression test.** Confirm the test fails without the fix. A test that passes either way documents nothing.

## Anti-patterns

- Changing several things at once, then losing track of which mattered.
- Adding a null check, try/catch, or retry around the symptom without knowing why the value was absent or the call failed. That converts a visible bug into a silent one.
- Re-running the failing command hoping for a different result.
- Concluding "race condition" or "caching" without evidence — both are real, and both are also where guesses go to hide.
- Assuming your change worked because the symptom went away once; verify against the deterministic reproduction.

## Environment-divergence checklist

When it works locally but not elsewhere, compare in this order: runtime and dependency versions (lockfile actually installed?), environment variables and their absence, build mode (dev versus production build behaves differently, especially around caching and error handling), data differences, filesystem case sensitivity, timezone and locale, network egress and timeouts, and concurrency level.

## Intermittency checklist

Test-order dependence, shared mutable state between tests, real clocks and timeouts, unawaited promises, missing cleanup, database state left by a previous run, parallel workers sharing a resource, and animation or network timing in E2E. Run the suite in a randomized order and repeatedly to characterize it before fixing.

## When to escalate

Escalate to `architect` rather than continuing when the root cause is a design problem rather than a defect, when the fix would cross boundaries the plan did not cover, or when the cause is understood but every available fix has a significant trade-off. Report the confirmed cause and the options.

## Report

The reproduction, the confirmed root cause and the evidence for it, the fix and why it addresses the cause rather than the symptom, the regression test and confirmation that it fails without the fix, and anything you ruled out along the way.
