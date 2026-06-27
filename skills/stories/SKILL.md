---
description: Break a PRD into small, independent, testable user stories with observable acceptance criteria, ordered by dependency. Use after a PRD is critiqued and you're ready to hand work to the build. Produces stories in docs/stories/. Based on INVEST (Bill Wake) and the 3 C's (Ron Jeffries).
disable-model-invocation: true
---

# User stories

A story is a **promise of a conversation** about a small slice of user value, with a
clear way to know it's done. Based on Ron Jeffries's 3 C's (Card, Conversation,
Confirmation) and Bill Wake's INVEST.

## When to use
- After a `/prd` is critiqued; to decompose work into buildable, reviewable pieces.
- Greenfield especially: scope the PRD to a thin slice, then sequence stories for it.

## Process
1. **Slice by user value**, each story delivers something a user can feel, not a technical layer ("the database" is not a story).
2. **Write the card:** "As a [user] I want [capability] so that [outcome]."
3. **Acceptance criteria (the Confirmation):** observable and **binary**, each either
   passes or fails. "User-friendly" is not a criterion; "error shows inline within the
   form, not as an alert" is.
4. **For UI stories**, fold design expectations into the same ACs: the **flow**, the
   **screens**, and **which states** apply (loading / empty / error / no-results, plus
   focus/disabled). Keep them behavioral and token-independent ("shows an empty state
   with an invite action"), not visual ("uses blue").
5. **Check INVEST:** Independent, Negotiable, Valuable, Estimable, Small (0.5 to 2 days;
   bigger -> split), Testable.
6. **Order by dependency:** what must be built first (data model -> auth -> core flow -> polish).

## Output
`docs/stories/USR-NNN-<slug>.md` each, ordered. One story = one branch = one PR downstream.

## Quality rules
- Acceptance criteria are **observable and binary**; no "user-friendly."
- Small and independent; if it's more than ~2 days or can't be tested, split it.
- Slice by value, never by technical layer.
- Fold UI states into ACs; keep them behavioral, not visual (look comes from design tokens).
