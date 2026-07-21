---
id: PRD-001
title: Output language option
status: draft
date: 2026-07-20
---

# PRD-001: Output language option

## 1. Problem
Odeo's skills and agents generate a lot of human-facing prose , PRDs, user stories,
signal memos, plan documents, review explanations, and nudge messages , and today all
of it comes out in English. A PM or builder whose working language is not English must
read, and often re-translate, every artifact the system produces. That friction
compounds across the whole lifecycle and hits hardest exactly the non-English
international users Odeo wants to reach.

Evidence: the **magnitude** is cited , the majority of the world's developers work outside
English-first regions (SlashData regional split; Stack Overflow 2024's 185-country base),
see `RES-001`; roughly 60% sit outside North America + Western Europe. The exact share of
non-native-English developers is **unverified** (no citable figure found). The specific pain
(friction reading English-only artifacts) is grounded in the maintainer's own use and still
needs user validation.

Why now: pre-launch is the cheap moment to design the setting in. Retrofitting language
handling after adoption costs more and risks inconsistent documents.

## 2. Outcome & success metrics
Outcome: a non-English PM/builder runs the full Odeo lifecycle and every artifact they
read is in their chosen language, after a single setup choice, while the codebase,
tooling, and collaboration stay language-neutral.

Success metrics (targets):
- **Setup cost:** language is set in <= 1 prompt at setup, default English; the
  single-language user takes 0 further config actions.
- **Consistency:** 100% of newly generated user-facing prose in a project follows the
  effective setting (spot-check on a sample of generated artifacts).
- **Zero mechanics leakage:** 0 cases of non-English text in machine-read fields,
  filenames, identifiers, branches, or commit types (enforced deterministically, see R6).
- **Adoption / value (the real signal):** among users offered the choice in a target
  locale, the share who set AND keep a non-English language, plus self-reported drop in
  re-translation friction. Target set after the pilot. Compliance alone is not value.

## 3. Context
- **Evidence (see `RES-001`):** most developers work outside English-first regions (~60%
  outside North America + Western Europe), so the audience is large; default English stays
  correct, the feature is additive.
- **Real alternative today** is the status quo "just use English": the user either works
  in English anyway (friction), asks Claude to translate each artifact ad hoc
  (inconsistent, repetitive), or post-edits every document (costly).
- Odeo already routes all machine-read structure through **English frontmatter fields and
  enums** and mandates English code/comments, which makes a prose-only localization
  boundary feasible without touching the mechanics.
- **Constraint:** Odeo does not translate its own system source (skills, agents, docs,
  README); those stay English (canonical). Localization applies to what the system
  GENERATES for the user, not to the system itself.
- This is a system capability, specified by dogfooding Odeo's own `/prd` skill.

## 4. Hypotheses & assumptions
- **H1:** a user's preferred language is stable across their projects, so a global default
  covers most cases. Wrong if users override per-project often, or want multiple languages
  inside one repo.
- **H2:** instructing the model to write prose in language X gives acceptable quality for
  the major languages Odeo's users speak, without translating the system. Wrong if users
  report low-quality or inconsistent generated prose.
- **H3:** keeping every machine-read field English fully protects gates/lint. Wrong if a
  gate or lint check fails on a non-English project despite English fields.
- **H4 (riskiest):** users in the target locales (DE/HR/FR) will actually set and keep a
  non-English language rather than defaulting to English. Wrong if the set-and-keep rate is
  low in the pilot (see Risks).

## 5. Scope
**In (v1):**
- A single setting `output_language`. **v1 selectable set: English (default), German
  (`de`), Croatian (`hr`), French (`fr`).** Further languages are deferred until the pilot
  validates prose quality on these four.
- **Global default:** set once at plugin install / first run; applies to all the user's
  projects.
- **Per-project override:** one line in the project's CLAUDE.md. Precedence:
  project override > global default > `en`.
- All Odeo skills and agents honor the effective setting for newly generated human-facing
  prose.
- A prompt at `setup-project` / `init-project`: one question, default English, skippable.

**Out (non-goals, v1):**
- Translating Odeo's own system docs, README, or skill/agent files.
- Retro-translating already-generated documents.
- Multiple simultaneous languages within one repo beyond the single setting.
- Locale/date/number formatting, right-to-left layout.

## 6. Requirements & acceptance criteria
- **R1 , resolution by precedence.** AC: on a project with an override, generated prose
  uses the override; remove it and it falls back to the global default; remove that and it
  defaults to English.
- **R2 , localized surfaces.** PRD/story/memo/plan bodies, review explanations and findings
  prose, nudge messages, chat responses, generated-doc prose. AC: a spot-check sample is in
  the set language.
- **R3 , English-always surfaces (hard).** Code + comments, identifiers, filenames
  (PRD-NNN slug), directory names, git branch names, conventional-commit type+scope, CLI
  flags, skill/agent names, gate/lint tokens, and machine-read frontmatter field names +
  enum values. AC: none of these change with the setting.
- **R4 , public Odeo repo stays English (MUST).** Its per-project override resolves to
  `en` regardless of any global setting. AC: generating an artifact in the Odeo repo yields
  English even when the global default is another language.
- **R5 , language UX (set + change).** (a) A one-time GLOBAL prompt at plugin install /
  first run sets the global default (default English, skippable). (b) A per-project prompt at
  `setup-project` sets the project override. (c) A change-anytime command/setting (e.g.
  `/language`) updates the effective language at the chosen scope without hand-editing files,
  and shows the current value. AC: install asks once and is not re-asked per project; setup
  asks once per project; `/language de` changes the effective language and the next generated
  artifact reflects it; skipping anywhere yields the inherited/default value.
- **R6 , no-leak guardrail (`[E]` enforced).** A deterministic check (`language-guard.sh`
  or a `skills-lint` invariant; exit 1 on violation) asserts that the R3 machine-read
  surfaces stay English/ASCII/allowlisted regardless of prose language: frontmatter field
  names + enum values, filenames (PRD-NNN slug), branch names, conventional-commit
  type+scope, identifiers. AC: with a non-English setting and non-English prose present, the
  check passes when mechanics are clean and FAILS (exit 1) on any non-allowlisted token in a
  machine surface; merge-gate/spec-gate/skills-lint stay green.
- **R7 , prose-language check (`[I]` + soft).** Skills/agents are instructed to write
  user-facing prose in the effective language; a best-effort language-detection check WARNS
  (never hard-fails) when generated prose does not match the setting. Not a guarantee (LLM
  output; mixed technical terms are legitimate); human review is the quality backstop. AC:
  under a German setting a generated PRD body is German; an English body under a German
  setting raises a warning.

## 7. Risks & dependencies
- **Feasibility/integrity (highest risk):** prose language leaks into machine-read fields
  and breaks gates/lint. Mitigation: the strict English-field boundary (R3, existing rule)
  + the R6 test. Early signal: R6 fails.
- **Usability:** users don't discover or trust the setting. Mitigation: prompt at setup
  with a clear default; document in the guide.
- **Quality (H2):** generated prose quality varies by language. Mitigation: rely on strong
  models; gather feedback post-launch.
- **Value (riskiest assumption, H4):** non-English users may PREFER English for technical
  work and never switch, leaving the feature unused. Early signal: low set-and-keep rate.
  Cheapest test now: a willingness check with ~5 DACH/German PMs before the full build
  (German business/PM docs are culturally expected there, the strongest willingness case).
  Mitigation: cheap to ship; default English means zero cost to English users.
- **Security pre-mortem: N/A** , the feature touches no auth, PII, payments, uploads, or
  private data; it is a language preference. Criterion rescaled to /8. (The integrity risk
  above is the real hazard and is treated as feasibility.)
- **Dependencies:** `setup-project` / `init-project` (prompt point), the CLAUDE.md
  convention (storage), and all generating skills/agents honoring the setting.

## 8. Open questions
- Global storage location: a user-level CLAUDE.md line vs an install-time config file.
  (Leaning: user-level CLAUDE.md line, mirroring the per-project mechanism.)
- Language identifier: a code (`hr`) vs a plain name ("Croatian"). (Leaning: accept either,
  normalize.)
- Should code comments ever follow the setting? (Current answer: no, English per the
  project rule; revisit only on real demand.)
