---
description: Use when the user asks to critique, red-team, poke holes in, stress-test, or pre-mortem a PRD, strategy, or product direction before committing to build it.
---

# Critique (red-team + pre-mortem)

Find the holes while they're cheap. Two passes: a **red-team** that attacks the logic,
and a **pre-mortem** that imagines failure and works backward (the classic
pre-mortem technique).

## When to use
- After a `/odeo:prd` or `/odeo:strategy` draft, before committing to build.
- Re-run if the revisions are large.

## Pass 1, Red-team (attack it)
Challenge, specifically and without mercy:
- **The problem:** is it real, urgent, and worth solving? Whose evidence, or just a guess?
- **The assumptions:** which single assumption, if wrong, collapses the whole thing?
- **The outcome/metric:** is it truly measurable? Gameable? A vanity metric?
- **Scope:** is the "MVP" actually minimal, or a wishlist? What can be cut and still test the bet?
- **The alternative:** why won't users just keep doing what they do today?

## Pass 2, Pre-mortem (assume failure)
> "It's 6 months later and this shipped and failed. What happened?"
List the **top 3 failure modes** ranked by likelihood, and for each: the **leading signal**
you'd see early, and the cheapest way to test it now.

## Security pre-mortem (required for sensitive features)
If it touches auth, PII, payments, uploads, or anything private:
> "It's 6 months later and we had a breach/leak through this. What was the hole? Where
> does the data live, who can reach it, what's the worst path in?"
List the top 3 attack/leak scenarios and what the design must include to close them.

## Output
Findings + ranked failure modes + leading signals, in chat. Revise the PRD; capture
security findings as requirements. Re-run if changes were large.

**Route the follow-ups so they survive the session.** Any finding the user wants
to act on but not now (a test to run, a gate to satisfy, an assumption to check)
goes into `.claude/tasks/todo.md` as a checkable item, with a one-line why.
Long projects resume through `/odeo:start`, and /odeo:start can only surface what is
written down. If the PRD was revised, open the revised file in the editor
(`code -r <file>`, fallback `cursor -r`, else just give the path).

## Quality rules
- Be genuinely adversarial; a soft critique is useless. Attack the strongest version, not a strawman.
- Name the **one assumption** that would sink it; that's where to focus.
- Every failure mode gets a **leading signal** you could detect early.
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `resolve-language.sh <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
