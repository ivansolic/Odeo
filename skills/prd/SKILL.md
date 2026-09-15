---
description: Write a problem-first Product Requirements Document, framed around a user outcome with measurable success criteria, not a feature list. Use once an idea has shape and you're ready to specify. Produces a structured PRD saved to docs/prds/. Includes a security pre-mortem for sensitive features.
disable-model-invocation: true
---

# PRD (problem-first)

A PRD exists to align everyone on **the problem, the intended outcome, and how we'll
know we succeeded**, before anyone builds. Problem before solution; outcomes over
features. Structure adapted from common product-spec practice (an 8-section layout).

## When to use
- An idea has shape (often after `/brainstorm`, `/personas`, `/market-segments`).
- For non-trivial work. Skip for a typo or a one-line fix.

## Walk through, in this order (do not jump to the solution)
1. **Problem**, who hurts, how much, how often, why now. Cite evidence (`/interview-synthesis`) or mark as assumption.
2. **Outcome & success metrics**, the measurable user outcome that means we won
   (e.g. "users who forgot their password regain access in <60s without support"),
   not "we shipped reset." Define the metric and target.
3. **Context**, relevant research, the real alternative / competitors (`/competitor-analysis`), constraints.
   If this section rests on assumptions instead of evidence, offer once:
   "shall I back this with `/research`? (cited sources, ~10 min quick scan)"
   and cite the resulting RES-NNN here.
4. **Hypotheses & assumptions**, what we're betting is true, and **how we'd know we're wrong**.
5. **Scope**, the thin slice (MVP) that tests the outcome. Explicit in / out. Non-goals.
6. **Requirements & acceptance criteria**, high-level, observable. (Detailed ACs live in `/stories`.)
7. **Risks & dependencies**, value/viability/feasibility/usability risks. **Security
   pre-mortem (required if the feature touches auth, PII, payments, uploads, or anything
   private):** "it's 6 months later and we had a breach through this, what was the hole?"
   Capture the answers as requirements, not afterthoughts.
8. **Open questions.**

## Output
`docs/prds/PRD-NNN-<slug>.md` (next number, lowercase-hyphen slug).

**Show it to the human.** Once the document is saved (finished, not every
intermediate edit), open it in their editor: `code -r <file>` (fallback `cursor -r`; if
neither exists, give the path and move on). Mention once: "opened it in VS Code,
Cmd+Shift+V shows the formatted view." Terminal markdown is hard to read; the
editor is where a PM reviews a document. If the user says "stop opening files,"
stop for the session.

## Quality gate (before moving on)
Score the PRD with the **`pm-reviewer`** agent against `skills/prd/rubric.md`
(installed copy: `~/.claude/skills/prd/rubric.md`). It writes the eval record to
`docs/evals/`. Below max score = fix the named gaps and re-dispatch pm-reviewer
to verify, automatically, looping to the AGENTS.md review-loop rule (max 3
cycles); show first -> final score. Then `/critique`, then `/stories`.

## Quality rules
- Problem and outcome before solution; if you're listing features first, stop.
- Success = a measurable **user outcome**, not "shipped X."
- Scope to a thin slice that tests the outcome; name non-goals.
- Security pre-mortem is mandatory for sensitive features (ties to the security baseline).
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
