---
name: ux-design
description: Use when building or reviewing any user interface, components, screens, layouts, forms, or user flows (frontend/UI work): enforces usability heuristics, UX laws, UI foundations (spacing/type/grid/color), all interaction + data states, and accessibility. Do NOT use for pure backend/logic, config files, or non-visual work.
---

# UX / UI Design

When building or reviewing UI, apply these. They make interfaces **usable,
consistent, and accessible by default**, the design equivalent of the security
baseline. Test *behavior*, not appearance (appearance = tokens + design review).

## When this applies
- Building or changing any UI: components, screens, layouts, forms, navigation, flows.
- Reviewing UI work.
**Skip** for pure backend/logic, config, scripts, or non-visual code.

## Always use the design system
- Style **only** via the project's semantic design tokens (`design/tokens.json`,
  compiled to the framework's theme). **Never hardcode** colors, spacing, font
  sizes, radii, shadows.
- Use the project's component library; **don't reinvent** components that exist.

## The two kinds of states (cover both)

**Data/screen states**, every data-driven view handles all that apply:
- **Loading** (skeleton/spinner) · **Empty** (no data yet, with a helpful next
  action) · **Error** (plain-language + recovery/retry) · **Populated** (content)
  · **No-results** (for search/filter, distinct from empty)

**Interaction states**, every interactive element handles:
- **Default · Hover · Focus (visible ring, mandatory for keyboard a11y) ·
  Active/Pressed · Disabled · Selected/Checked · Loading** (e.g. submitting button)

## UI foundations (all token-driven)
- **Spacing:** one scale (4/8px base), never arbitrary values.
- **Grid/layout:** consistent columns, gutters, max width, defined breakpoints; align to grid.
- **Typography:** limited type scale, line-height ~1.4-1.6 body, few weights, clear hierarchy, line length ~45-75 chars.
- **Color:** semantic roles from tokens; WCAG AA contrast (4.5:1 text, 3:1 large/UI).
- **Sizing/touch:** min 44×44px touch targets.
- **Elevation/radius:** consistent shadow + corner-radius scales.
- **Motion:** consistent duration/easing; feedback <400ms (Doherty); respect `prefers-reduced-motion`.

## Accessibility baseline (WCAG AA)
- Semantic HTML; one `<h1>`; logical heading order.
- All interactive elements keyboard-operable with a **visible focus indicator**.
- Labels on every input; errors linked to fields and announced.
- Sufficient contrast; never color alone to convey meaning.
- Images have alt text; icons that act have accessible names.
- Respect reduced-motion.

## Nielsen's 10 usability heuristics (evaluate every screen)
1. **Visibility of system status**, always show what's happening (feedback, the 4 states).
2. **Match the real world**, users' language and conventions, not jargon.
3. **User control & freedom**, clear exits, undo/cancel.
4. **Consistency & standards**, same word/action means the same thing; follow platform conventions.
5. **Error prevention**, design out errors; confirm destructive actions.
6. **Recognition over recall**, show options; don't make users remember.
7. **Flexibility & efficiency**, shortcuts for experts, simple for novices.
8. **Aesthetic & minimalist**, remove the irrelevant; reduce noise.
9. **Help users with errors**, plain language, name the problem, offer the fix.
10. **Help & documentation**, in-context, task-focused, when needed.

## Laws of UX (apply the relevant ones)
- **Cognitive load / simplicity:** Hick's (fewer/simpler choices = faster decisions), Miller's (~7±2 in working memory → chunk), Cognitive Load, Chunking, Tesler's (irreducible complexity, absorb it, don't dump on the user), Occam's Razor, Choice Overload.
- **Perception / grouping (Gestalt):** Proximity, Common Region, Similarity, Uniform Connectedness, Prägnanz (simplest form), group related things, separate unrelated.
- **Attention / memory:** Von Restorff (make the key action distinct), Serial Position (important items first/last), Selective Attention (don't make key info look like ads/noise).
- **Familiarity:** Jakob's Law (work like the sites users already know), Mental Model (match expectations), Postel's (be liberal in input, strict in output).
- **Motivation / completion:** Goal-Gradient (show progress), Peak-End (nail the peak + the ending), Zeigarnik (surface incomplete tasks), Flow.
- **Speed / targets:** Doherty Threshold (<400ms feedback), Fitts's Law (bigger/closer targets for frequent actions).
- **Aesthetics:** Aesthetic-Usability Effect (clean design feels more usable and buys goodwill).

## How to apply (build flow)
1. From the story: identify the **user flow**, the **screens**, and **which states** apply.
2. Plan components, reuse the component library; map each required state.
3. Build using **semantic tokens** only; implement every interaction + data state; meet a11y.
4. Test **behavior** (which state renders when, focus, keyboard, validation), appearance is verified by tokens + the `design-reviewer`.
5. Self-check against Nielsen's 10 and the accessibility baseline before "done."

## Honest limit
This delivers **functional, consistent, accessible, convention-correct** UI. It
does **not** guarantee distinctive *visual taste* or novel interaction design, 
flag when a human/designer eye would materially help.

## Going deeper
For domain-specific patterns (forms, e-commerce, navigation, mobile, data tables),
consult established usability research (e.g. nngroup.com) for that domain rather than guessing.
