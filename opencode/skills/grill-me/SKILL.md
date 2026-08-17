---
name: grill-me
description: Adversarially pressure-test a plan or design before implementation — use when a plan is written and about to be built, when the change is high-risk or hard to reverse, or when the user asks to have their thinking challenged.
---

Attack the plan, not the person, and attack it now while changing it is still cheap. A plan that survives this is worth building; a plan that does not has just saved you the implementation.

This runs **against a plan that already exists**. Use `brainstorming` when there is no design yet, and `reviewer` when there is code.

## Stance

Your job is to find the flaw, not to validate the work. Agreeing with a plan you have not tried to break is worth nothing to the person who has to ship it.

Do not soften findings into suggestions. If a step will not work, say it will not work and why. If you cannot find a real problem, say that plainly rather than manufacturing minor objections to appear thorough — a plan can genuinely be sound, and false balance wastes the reader's judgement.

Ask one question at a time and follow the answer. The second and third questions in a chain are where plans actually break; a list of ten parallel questions gets shallow answers to each.

## Lines of attack

**The unstated assumption.** What must be true for this plan to work that nobody has verified? Does that table have an index? Does that API return in bounded time? Does that field already contain nulls? Check the ones you can check rather than asking.

**The failure path.** Every step: what happens when it fails halfway? What state is left behind? Is that state recoverable, and by whom? A plan that only describes success is half a plan.

**Reversibility.** If this ships and is wrong, what is the cost of backing it out? Data destroyed, a migration already applied, an API consumers now depend on, a published event — each is a one-way door and deserves proportionally more scrutiny than a reversible change.

**Concurrency and scale.** Two of these at once? A thousand times the current data? What is the slowest query in the plan at production row counts?

**Boundaries.** Which trust boundary does this cross, and who authorizes at it? Where does untrusted input enter? What does a response newly expose?

**The simpler alternative.** What would you do with half the time? Why is the extra machinery earning its place? Which part could be dropped without the user noticing?

**Verification.** How would we know this worked — not "tests pass", but which specific observation would distinguish a working implementation from a subtly broken one? If the plan cannot be verified, it cannot be finished.

**The disconfirming case.** Ask what evidence would prove the plan wrong. A plan whose author cannot describe that has not been thought about adversarially yet.

## Escalation triggers

Stop and require an `architect` pass rather than continuing to interrogate when the grilling reveals: the plan requires an irreversible step with no rollback, an authorization boundary is unresolved, the correct behaviour for existing data is unknown, or two of the plan's steps contradict each other. Those are design problems, not gaps to be papered over with more detail.

## Output

- Blocking objections, each with the specific failure it predicts and what would resolve it.
- Non-blocking concerns, marked as such.
- Assumptions the plan depends on that remain unverified, and how to verify each.
- An explicit verdict: proceed, proceed with named changes, or return to design — and if the plan is sound, say so directly.
