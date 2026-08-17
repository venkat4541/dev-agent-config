---
name: frontend-design
description: Design a new user-facing surface or restyle an existing one — use when creating a page, layout, or component with no established pattern to copy, deciding visual hierarchy and spacing, or judging whether a UI is finished.
---

Inspect the existing UI before changing it: component library, tokens, typography, layout primitives, breakpoints, interaction patterns, and any design documentation. Preserve those conventions; do not introduce a new design system, font, icon set, animation library, or component framework without an explicit decision.

For new surfaces, establish the user goal and primary action first. Create a clear visual hierarchy with intentional grouping, readable content density, consistent spacing, and responsive layouts that work on narrow and wide screens. Design every meaningful state: loading, empty, error, disabled, success, and long-content overflow.

Prefer durable, accessible UI over decorative novelty. Use semantic controls, visible focus, keyboard operation, sufficient contrast, touch-friendly targets, reduced-motion-safe animation, and status messaging that assistive technology can understand. Avoid generic dashboard filler, arbitrary gradients, and one-off pixel values when the project has reusable primitives or tokens.

Work in the project's scale, not in arbitrary values. Use the existing spacing, type, radius, and colour tokens; a one-off `13px` or a hand-picked hex among tokenized siblings reads as unfinished and drifts on the next theme change. If a needed value genuinely does not exist in the scale, add it to the scale rather than inlining it once.

Judge a surface as finished against this list, not by how it looks in the happy path:

| Dimension | Question |
| --- | --- |
| States | Loading, empty, error, disabled, success, partial all designed? |
| Content | Longest realistic string, missing optional field, zero and very many items? |
| Viewport | Narrow phone through wide desktop, no horizontal scroll or clipped control? |
| Theme | Both light and dark if the project supports them, with contrast held? |
| Density | Readable line length and grouping, not evenly-spread filler? |

Before handing off, compare the result with adjacent product surfaces, exercise representative viewport sizes and states, and run the project's relevant lint, typecheck, tests, and visual/E2E checks. Accessibility is not a separate polish pass — see `accessibility` for the keyboard and announcement requirements this surface must already meet.
