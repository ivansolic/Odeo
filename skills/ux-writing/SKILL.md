---
description: Use when writing or reviewing any interface text, button labels, error messages, empty/loading/success states, headings, links, tooltips, microcopy. Produces clear, scannable, trustworthy UI copy. Based on established UX-writing and microcopy research.
---

# UX writing (content design)

The words ARE the interface. Clear microcopy reduces confusion, builds trust, and drives
action. This auto-applies whenever you write or review user-facing text. Based on established
UX-writing principles, strategic-UX-writing practice, and microcopy craft
(Microcopy).

## When this applies
- Any user-facing text: buttons, labels, error / empty / loading / success states,
  headings, links, tooltips, onboarding, confirmations, form hints.
- Skip for backend, logs, and internal text users never see.

## Principles
- **Plain language + brevity.** Easy to read; get to the point. No jargon unless the audience truly uses it in everyday speech.
- **Scannable.** People scan, not read. Front-load meaning, the first 2 words of headings and links carry the weight. Inverted pyramid (most important first); chunk content.
- **Specific buttons and links.** Name the outcome ("Send invoice", "Delete project"), never generic "Submit", "OK", "Learn more", or "Click here".
- **Constructive errors.** Say what happened, why, and how to fix it, in plain, blame-free language. Keep the user in control. **Never expose codes, internal paths, or stack traces** (ties to the security baseline).
- **States talk.** Empty / loading / success states tell the user what's happening and the next action (an empty state invites the first action).
- **Voice and tone.** Consistent across the product; tune four dials (humor, formality, respect, enthusiasm) to the moment, calm and serious in errors, lighter in success.
- **Language accessibility.** Numerals for numbers; expand acronyms on first use; meaningful link text for screen readers (not "click here").

## Process when writing copy
1. Identify the **context + user goal + emotional state** at this exact moment.
2. Lead with the user's outcome; cut words that don't add meaning.
3. For actions: label **verb + object** and match the consequence (a destructive action says "Delete", not "OK").
4. For errors: plain cause + fix; the user stays in control; no raw codes/jargon.
5. Check tone fits the moment **and** the product voice; read it aloud.

## Output
The copy itself, in the UI/components. The `design-reviewer` agent reviews microcopy
alongside states and accessibility; the visual side comes from design tokens (`ux-design`).

## Anti-patterns
- Generic labels: "Submit", "OK", "Learn more", "Click here".
- Error messages that blame the user or dump codes/stack traces.
- Jargon, walls of text, buried key information.
- Cute copy in a serious or error moment.

## Quality rules
- Clarity over cleverness; the user's task beats brand voice when they conflict.
- Never expose internals in user-facing errors (security baseline).
- Consistent terms, don't call it "project" here and "workspace" there.
