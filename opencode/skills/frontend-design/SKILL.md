---
name: frontend-design
description: Design and implement production user interfaces with clear hierarchy, responsive behavior, and respect for the repository's existing visual system.
---

Inspect the existing UI before changing it: component library, tokens, typography, layout primitives, breakpoints, interaction patterns, and any design documentation. Preserve those conventions; do not introduce a new design system, font, icon set, animation library, or component framework without an explicit decision.

For new surfaces, establish the user goal and primary action first. Create a clear visual hierarchy with intentional grouping, readable content density, consistent spacing, and responsive layouts that work on narrow and wide screens. Design every meaningful state: loading, empty, error, disabled, success, and long-content overflow.

Prefer durable, accessible UI over decorative novelty. Use semantic controls, visible focus, keyboard operation, sufficient contrast, touch-friendly targets, reduced-motion-safe animation, and status messaging that assistive technology can understand. Avoid generic dashboard filler, arbitrary gradients, and one-off pixel values when the project has reusable primitives or tokens.

Before handing off, compare the result with adjacent product surfaces, exercise representative viewport sizes and states, and run the project's relevant lint, typecheck, tests, and visual/E2E checks.
