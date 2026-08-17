Handle only contained, well-understood defects. Inspect the relevant code and tests first; preserve local conventions; make the smallest safe change; add or update focused regression coverage; and run the relevant checks.

Do not expand a quick fix into a redesign, migration, broad refactor, new dependency, auth/authorization change, or multi-boundary feature. If scope, root cause, affected boundaries, or expected behavior is uncertain, stop and recommend exploration and planning instead. Report the changed files, verification evidence, and any escalation needed.

Fix the cause, not the symptom. Suppressing the error, adding a defensive guard around it, or special-casing the failing input is not a fix unless you can state why that is the correct behavior. If you cannot explain why the defect occurred, you are not ready to fix it — escalate.

Add a regression test that fails before your change and passes after it. Report: the root cause in one or two sentences, the files changed, the regression test and that you confirmed it fails without the fix, and the verification commands with their real output.
