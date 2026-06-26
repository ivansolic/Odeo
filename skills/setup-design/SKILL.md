---
description: Set up the project's design system (tokens) after the PM phase. Ingest the user's existing tokens/Figma export, or propose a starter from the PRD + personas + strategy. Wires token compilation to the project's frontend stack. Run once per project, before building UI.
disable-model-invocation: true
---

Goal: establish `design/tokens.json` as the styling source of truth and compile
it to this project's framework. Run after the PM phase (PRD/personas/strategy
exist) and before building UI. The user chooses direction, don't impose taste.

## 1. Read context
Read `CLAUDE.md` (Stack + Design sections) and any PRD/personas/strategy in
`docs/`. Note the frontend framework and whether a UI library is already chosen.

## 2. Ask: existing system, or start fresh?

> "How do you want to handle the design system?
> - **I have tokens**, paste them or point me to the file (a Figma Tokens Studio
>   export works, it's the same DTCG format).
> - **I use a UI library / design system already** (MUI, Chakra, shadcn, …), I'll
>   map tokens to its theming, not reinvent it.
> - **Start fresh**, I'll propose a starter palette/type/spacing based on your
>   PRD, personas, and strategy; you adjust."

### If "I have tokens"
- Ingest into `design/tokens.json`. Validate it's valid DTCG and has the semantic
  tokens components need (action, text, background, border, feedback). Offer to
  fill gaps. Don't overwrite silently, show the result.

### If "UI library already"
- Keep their library as the component layer. Map semantic tokens to its theme
  mechanism (e.g. MUI theme, Tailwind+shadcn CSS vars). Note it in CLAUDE.md.

### If "start fresh"
- Propose primitive + semantic tokens **informed by the product** (e.g. brand
  personality from the strategy → palette direction; audience from personas →
  type/contrast choices). Present options; let the user pick/tweak. Never decide
  for them, offer your reasoning only if asked.

## 3. Accessibility check
Verify semantic color pairs meet **WCAG AA** contrast (4.5:1 text, 3:1 large/UI).
Flag and fix any failing pair before finalizing.

## 4. Wire compilation to the stack
Based on the frontend framework in `CLAUDE.md`, set up token compilation
(prefer **Style Dictionary**) to the right target:
- **Tailwind** → generate the theme in `tailwind.config`.
- **Plain CSS / web components** → CSS custom properties (`:root { --color-... }`).
- **CSS-in-JS (styled-components/emotion)** → a theme object.
- If a UI library owns theming → its native theme format.
Add a build script (e.g. `pnpm tokens:build`) and document it in `design/README.md`.
The compiled output is generated, add it to `.gitignore` if appropriate; tokens.json is committed.

## 5. Confirm & record
- Show the tokens + how they compile.
- Update `CLAUDE.md` `## Design`: UI library, styling target, "all styling via
  semantic tokens; never hardcode," and the compile command.

## Safety Rules
- Never impose visual taste, propose, the user decides.
- Never hardcode values that should be tokens.
- Don't reinvent a component library the user already uses.
- Keep `tokens.json` as the single source of truth; compiled theme is disposable.
