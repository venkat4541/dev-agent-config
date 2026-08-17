---
description: Adversarially pressure-test a plan or design before implementation
agent: architect
---

Pressure-test this plan or design before any implementation begins: $ARGUMENTS

Use the `grill-me` skill. Read the relevant code first and verify the assumptions you can verify yourself rather than asking about them. Attack the plan on unstated assumptions, failure paths, reversibility, concurrency and scale, trust boundaries, the simpler alternative, and how the result would be verified.

Ask one question at a time and follow each answer. Do not edit files. End with an explicit verdict — proceed, proceed with named changes, or return to design — and state plainly if the plan is sound.
