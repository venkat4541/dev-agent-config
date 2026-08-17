---
name: test-driven-development
description: Drive an implementation from failing tests — use when the user asks to work test-first, when a behaviour's contract is clearer than its implementation, or when fixing a defect where the test must prove the fix.
---

Write the test, watch it fail for the right reason, make it pass with the smallest change, then improve the design with the test holding it in place.

This is a deliberate choice, not a default. It pays off when the contract is clear and the implementation is uncertain, and for defect fixes where a test that fails first is the only proof the cause was found. It pays less for exploratory work where you do not yet know the shape of the interface — prototype first, then lock the behaviour in with tests.

## The loop

**Red.** Write one failing test for the next smallest behaviour. Run it. Confirm it fails *for the reason you expect* — a test failing on a typo, an import error, or a missing fixture has told you nothing. Read the failure message and check it describes the absent behaviour.

**Green.** Write the minimum code that makes it pass. Do not build the general case yet; do not add the next feature because you can see it coming. Run the test and watch it pass.

**Refactor.** Now improve the structure — extract, rename, remove duplication — with the test proving behaviour is unchanged. Run the tests again. Commit here; the checkpoint is at a green, refactored state.

Then repeat with the next behaviour.

## What makes the discipline work

The order is the whole point. Writing the test after the implementation tests what you built rather than what was required, and can never demonstrate that it would have caught the bug.

Watching red before green is non-negotiable. A test that has never failed may be asserting nothing at all — a wrong matcher, a mocked-away subject, an unawaited promise. Seeing it fail proves it is connected to the behaviour.

One behaviour per cycle. A test asserting five things fails as a unit and localizes nothing.

Never adjust a test to match the code's actual output when the test was expressing the intended output. That inverts the entire method: the test becomes a description of the bug. If the test was genuinely wrong, say why before changing it.

## For defects

The regression test comes first and must fail against the unfixed code. If you cannot make it fail, you have not identified the cause yet — go back to `debugging` rather than proceeding to a fix. Once it fails for the right reason, fix the cause, watch it pass, and keep the test.

## Where it does not fit

Do not force the loop onto: a pure formatting or rename change, generated code, configuration, or a spike whose purpose is to learn what the interface should be. In those cases say plainly that you are not working test-first and why, rather than writing a ceremonial test that asserts nothing.

For which level a test belongs at, and what makes an assertion worth having, see `testing`.

## Report

The cycles you completed, and for each: the behaviour, that you observed red before green, and the final command output. For a defect fix, state explicitly that you confirmed the test fails without the fix.
