# Design

The design system for this project. **`tokens.json` is the source of truth** for
all styling.

## How it works
- **`tokens.json`**, design tokens in W3C DTCG format, two layers:
  - **primitive**, raw values (colors, spacing scale, type scale, radii).
  - **semantic**, intent that references primitives (`action.primary`,
    `feedback.danger`, `text.default`). **Components use semantic tokens only.**
- Tokens **compile** to your framework's theme (CSS variables / Tailwind config /
  theme object), set up by `/setup-design` for your stack.
- The compiled theme is **generated output**, never hand-edit it; change
  `tokens.json` and recompile.

## Rules (enforced by the `ux-design` skill + `design-reviewer`)
- Never hardcode colors, spacing, font sizes, radii, reference semantic tokens.
- New components follow existing token-based patterns.
- Dark mode / rebrand = swap primitive values or semantic references; recompile.

## Setup / change
- Run **`/setup-design`** to: ingest your existing tokens (or a Figma export), or
  generate a starter from your brand, then wire compilation to your stack.
- Already have a UI library / design system (MUI, Chakra, shadcn…)? `/setup-design`
  maps tokens to its theming instead of reinventing.

## Importing existing tokens (how it actually works)
If you already have tokens, `/setup-design` **ingests** them, three ways to hand
the file over:
1. **Paste** the JSON into the chat.
2. **Save it here** (e.g. `design/my-tokens.json`) and say *"read it."*
3. **From Figma:** install the **Tokens Studio** plugin (Figma has no native DTCG
   export), define/export your tokens as a DTCG JSON, then provide that file via
   method 1 or 2.

It's a **manual export-then-ingest, not a live sync**, Odeo consumes the
file you give it; it doesn't reach into Figma on its own. On ingest, `/setup-design`
validates the JSON is DTCG, ensures the semantic tokens components need exist
(fills gaps), checks WCAG contrast, merges into `tokens.json`, and wires compilation.

## Accessibility
Semantic color pairs must meet WCAG AA contrast (4.5:1 text, 3:1 large/UI).
`/setup-design` checks this when generating.
