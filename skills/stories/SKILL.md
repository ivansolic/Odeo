---
description: Break a PRD into small, independent, testable user stories with observable acceptance criteria, ordered by dependency. Use after a PRD is critiqued and you're ready to hand work to the build, or standalone on any product (a PRD from elsewhere, a company feature). Produces stories in docs/stories/. Based on INVEST and the 3 C's.
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

## Worked example
PRD-014 (saved searches) has requirements R1 (save a search), R2 (rerun one), R3 (delete
one). One story from that set:

> **USR-021, Save a search**, `prd: PRD-014` · `covers: R1` · order 1 · ~1 day
>
> **Card:** As a shopper, I want to save my current search filters under a name, so that I
> can find the same results later without rebuilding them.
>
> **Acceptance criteria**
> - Saving with a name shows the saved search in the "Saved" list immediately.
> - Saving with an empty name is blocked, with the reason shown inline beside the field.
> - Saving a name that already exists is blocked, with an inline "name already used" message.
> - A saved search stores the filters, not the results.
>
> Traceability: `R1 -> USR-021`.

## PRD coverage (traceability, a precondition)
When the set decomposes a PRD, before the quality gate, build a **traceability map**: every
PRD requirement (R1, R2, ...) maps to at least one story. Show it (`Rn -> USR-NNN`). A
requirement with no covering story is a **coverage gap** that blocks `/build`, close it by
adding or splitting a story. Coverage is separate from the rubric (which grades how WELL the
stories are written); a set can score 8/8 and still fail coverage.

Make it deterministic: each story declares a `covers:` frontmatter field listing the
requirement IDs it satisfies (e.g. `covers: R1 R5`), and `bin/coverage-check.sh <prd-file>
docs/stories` verifies every requirement is covered, exit 1 on any gap. That is the `[E]`
enforced backstop for the map above.

## Quality gate (before handing to /build)
Score the story set with the **`pm-reviewer`** agent against
`${CLAUDE_PLUGIN_ROOT}/skills/stories/rubric.md`;
eval record goes to `docs/evals/`. Below max score = fix the named gaps and
re-dispatch pm-reviewer to verify, looping automatically (AGENTS.md review-loop
rule, max 3 cycles); show first -> final score.

## Quality rules
- Acceptance criteria are **observable and binary**; no "user-friendly."
- Small and independent; if it's more than ~2 days or can't be tested, split it.
- Slice by value, never by technical layer.
- Fold UI states into ACs; keep them behavioral, not visual (look comes from design tokens).
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `resolve-language.sh <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
  The localized title goes in the document's H1 below the closing `---`; the frontmatter
  `title:` stays English and ASCII, because the guard checks every frontmatter value.
