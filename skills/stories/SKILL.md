---
description: Break a PRD into small, independent, testable user stories with observable acceptance criteria, ordered by dependency. Use after a PRD is critiqued and you're ready to hand work to the build, or standalone on any product (a PRD from elsewhere, a company feature) . Produces stories in docs/stories/. Based on INVEST and the 3 C's.
disable-model-invocation: true
---

# User stories

A story is a **promise of a conversation** about a small slice of user value, with a
clear way to know it's done. Built on the 3 C's (Card, Conversation, Confirmation)
and the INVEST checklist.

## When to use
- After a `/prd` is critiqued; to decompose work into buildable, reviewable pieces.
- Greenfield especially: scope the PRD to a thin slice, then sequence stories for it.

## Process
1. **Slice by user value**, each story delivers something a user can feel, not a technical layer ("the database" is not a story).
2. **Write the card:** "As a [user] I want [capability] so that [outcome]."
3. **Acceptance criteria (the Confirmation):** observable and **binary**, each either
   passes or fails. "User-friendly" is not a criterion; "error shows inline within the
   form, not as an alert" is.
   **Write them in words, for the reader in front of you.** "At least one
   ingredient", not "≥1"; plain sentences, not notation. And match technicality
   to the audience: when the stories feed THIS repo's build, verification detail
   (test fixtures, endpoints) may ride along in a "verification note" under the
   AC; when /stories is used standalone (a company product, no codebase here),
   keep ACs purely user-observable, the reader is a stakeholder, not a builder.
4. **For UI stories**, fold design expectations into the same ACs: the **flow**, the
   **screens**, and **which states** apply (loading / empty / error / no-results, plus
   focus/disabled). Keep them behavioral and token-independent ("shows an empty state
   with an invite action"), not visual ("uses blue").
5. **Check INVEST:** Independent, Negotiable, Valuable, Estimable, Small (0.5 to 2 days;
   bigger -> split), Testable.
6. **Order by dependency:** what must be built first (data model -> auth -> core flow -> polish).

## Output
`docs/stories/USR-NNN-<slug>.md` each, ordered. One story = one branch = one PR downstream.

**Show them to the human.** When the set is saved, open the story folder's new
files in their editor (`code -r <files>`, fallback `cursor -r`; neither -> give
the paths). Mention Cmd+Shift+V once for the formatted view. "Stop opening
files" stops it for the session.

## Quality gate (before handing to /build)
Score the story set with the **`pm-reviewer`** agent against
`skills/stories/rubric.md` (installed copy: `~/.claude/skills/stories/rubric.md`);
eval record goes to `docs/evals/`. Below threshold = fix the named gaps first.

## Quality rules
- Acceptance criteria are **observable and binary**; no "user-friendly."
- Small and independent; if it's more than ~2 days or can't be tested, split it.
- Slice by value, never by technical layer.
- Fold UI states into ACs; keep them behavioral, not visual (look comes from design tokens).
