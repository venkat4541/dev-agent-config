---
name: accessibility
description: Make an interface usable by keyboard and assistive technology — use when building or reviewing any interactive UI, a dialog, menu, form, or custom control, and when verifying focus behaviour, announcements, or contrast.
---

Use the native element. A `button`, `a`, `input`, `select`, `details`, or `dialog` brings keyboard behaviour, focus handling, and assistive-technology semantics for free; a `div` with a click handler brings none of it and has to reimplement all of it. ARIA supplements semantics — it never adds behaviour, and a wrong role is worse than no role.

## Non-negotiables

Every interactive element must:

- be reachable and operable by keyboard alone (Enter and Space activate a button; Escape dismisses a dismissible surface),
- have an accessible name — visible label, `aria-label`, or `aria-labelledby`,
- show a clearly visible focus indicator (never remove an outline without replacing it),
- have a target large enough to hit comfortably on touch,
- not convey meaning by colour alone.

Contrast minimums: 4.5:1 for body text, 3:1 for large text and for the boundaries of interactive components. Check the real rendered colours, including disabled and hover states, and both themes if the project has them.

## Focus management

Focus is the keyboard user's cursor; losing it strands them.

- Opening a dialog or drawer moves focus into it, traps focus inside while open, and returns focus to the trigger on close.
- Removing the focused element (deleting a row, closing a panel) requires moving focus somewhere sensible first, not letting it fall to the document.
- Client-side route changes should move focus to the new page's heading or main landmark; otherwise focus silently stays behind.
- Focus order follows visual order. Avoid positive `tabindex`; use `tabindex="-1"` only for programmatic targets.
- Content that appears on hover must also appear on focus.

## Forms

Associate every input with a `label` (`for`/`id`, or wrapping) — placeholder text is not a label and disappears on input. Mark invalid fields with `aria-invalid`, link the message with `aria-describedby`, and put the error next to the field, not only in a summary. On failed submission, move focus to the first error or to a summary that lists them. Group related controls with `fieldset`/`legend`. Never rely on colour alone to mark a required or invalid field.

## Dynamic content

Anything that changes without a user action needs announcing: a live region (`aria-live="polite"`, or `role="alert"` for errors) for status messages, save confirmations, and async results. A toast that is only visual does not exist for a screen reader user. Announce loading state, and give a busy control an accessible busy or disabled state rather than only a spinner.

Respect `prefers-reduced-motion`: gate non-essential animation, parallax, and auto-playing motion behind it.

## Images and structure

Meaningful images need alt text describing their purpose; decorative images take `alt=""`, never a missing `alt`. Headings form a single outline with no skipped levels and are not chosen for their font size. Use landmarks (`main`, `nav`, `header`, `footer`) once each as appropriate, and give the page a descriptive, unique `title`.

## Verification procedure

Automated checks catch a minority of real issues. Do all three:

1. **Keyboard-only pass** — unplug the mouse conceptually: Tab through the whole flow, activate every control, open and close every overlay, submit the form with an error. Note anywhere focus disappears or a control is unreachable.
2. **Automated scan** — run the project's axe or lint-based accessibility checks and fix what they report.
3. **Semantics check** — inspect the accessibility tree for correct names, roles, and states, or listen with a screen reader for a critical flow.

Report which of the three you performed and what each found; "looks accessible" without a keyboard pass is not verification.
