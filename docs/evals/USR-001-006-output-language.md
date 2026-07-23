---
covers: USR-001 USR-002 USR-003 USR-004 USR-005 USR-006
type: stories
artifact_version: 2
date: 2026-07-21
scorer: pm-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { value_slicing: 2, acceptance_criteria: 2, size_independence: 2, dependency_order: 2, ui_states: N/A }
total: 8/8
verdict: PASS
previous_total: 8/8
---

## Artifact: USR-001..USR-006 (user-story set, decomposes PRD-001, v2)
Non-UI feature (CLI / config / agent behavior). Criterion 5 (UI states) is N/A and
the total is rescaled to /8; threshold >= 6/8 AND no criterion at 0.

Supersedes `docs/evals/USR-001-004-output-language.md` (the v1 four-story set). The set
grew to six: USR-003 (global install prompt) and USR-004 (change-anytime command) were
added to close the R5 UX gap the human flagged, and the prose/warning stories were
renumbered to USR-005/006.

## Scores

- **Value slicing: 2** — Every story delivers something a user can feel, no disguised
  technical layer. The two new stories are cast as outcomes, not config plumbing.
  USR-003: "I want to be asked my preferred language once when I install the plugin ...
  so that all my projects default to my language without per-project setup." USR-004:
  "I want to change my output language at any time from a simple command, so that I am
  not locked into the setup choice and never have to hand-edit files." Even the
  guardrail (USR-001) is framed as maintainer-felt safety: "so that turning on another
  language can never corrupt my project's mechanics or break gates." 2.

- **Acceptance criteria: 2** — Every criterion observable and binary. The Round-1
  optional fix on the warning threshold is now closed: USR-006 pins it — "whose prose
  region is detected as predominantly (more than half) a language other than German"
  and "its exit stays 0, it only warns." USR-003 nails the once-only edge: "asked for a
  language exactly once ... The install prompt is not shown again during later project
  setups." USR-004 makes reject-invalid decidable: "an unsupported code is rejected and
  the allowed set is listed." The canonical-form fix is also in: USR-004 writes
  "the same canonical form as setup (`output_language: <code>`), so the resolver and the
  no-leak guardrail read it identically." No "user-friendly"/"works well" anywhere. 2.

- **Size & independence: 2** — All six sit in the 0.5-2 day INVEST band and say so:
  USR-001 "~1 day", USR-002 "~1 to 1.5 days", USR-003 "~1 day", USR-004 "~1 day",
  USR-005 "~1.5 to 2 days ... the largest story", USR-006 "~0.5 to 1 day". Coupling is
  real but minimal and named per story, not entangled. 2.

- **Dependency order: 2** — Explicit build order that respects technical dependencies,
  guard-and-setting first. `order:` runs 1->6; `depends_on:` is stated and coherent
  throughout: USR-003 "depends_on: USR-002 (resolution + storage model)"; USR-004
  "depends_on: USR-002, USR-003"; USR-005 "depends_on: USR-002 (the setting), USR-001
  (guard in place first)"; USR-006 "depends_on: USR-002, USR-005". The setting and the
  guardrail land before anything that generates or could leak; the global store lands
  before the change-anytime command that writes to it. 2.

- **UI states coverage: N/A** — CLI/config/agent behavior, no UI surface; rubric line 25
  directs N/A + rescale. Correctly excluded, not a defect.

## Total: 8/8   ## Verdict: PASS  (threshold: >= 6/8, no criterion at 0)

## Ceiling
Achievable ceiling is **8/8** (not 10). Criterion 5 is structurally N/A for a non-UI
feature, so max reachable = 4 criteria x 2 = 8. No remaining criterion is capped below 2
by the artifact's nature, so full marks were reachable and were reached. This is not
"8 out of a possible 10".

## PRD-001 coverage (R1-R7)
The six-story set now covers all seven PRD requirements — the R5 gap from Round 1 is
closed:
- **R1 resolution by precedence** — USR-002: "resolves by precedence: the project line,
  else the global default, else English."
- **R2 localized surfaces** — USR-005: "PRDs, stories, memos, plans, review explanations,
  and nudges, chat."
- **R3 English-always surfaces** — USR-001 (guard enumerates the surfaces) + USR-005 AC2
  ("code, identifiers, filenames, git branch names, conventional-commit type+scope, and
  frontmatter field names + enum values remain English").
- **R4 public Odeo repo stays English** — USR-005: "The public Odeo repo (its own
  CLAUDE.md override = `en`) generates English prose even when the global default is
  German, Croatian, or French."
- **R5 language UX (set + change)** — now fully covered across three stories:
  (a) global install prompt = USR-003; (b) per-project setup prompt = USR-002;
  (c) change-anytime command that shows the current value = USR-004 ("shows the current
  effective language and its scope"). In Round 1 only (b) existed; (a) and (c) were the
  flagged gap.
- **R6 no-leak guardrail** — USR-001: deterministic check, exit non-zero on any
  non-allowlisted/non-ASCII token in a machine surface, gates stay green.
- **R7 prose-language check** — USR-006: soft warn-only check over the prose region,
  never hard-fails, mixed technical terms don't trigger it.

No remaining coverage gap against PRD-001 as written.

## Top fixes
None required to pass; the set is at ceiling and fully covers R1-R7. Optional hardening
(does not change the score):
1. R5(c) scope semantics — USR-004 says the command "can target either the project
   override or the global default." The default scope when the user omits a scope flag is
   not pinned (project vs global). Naming the default target would remove one implementer
   decision.
2. PRD open question (global storage location: user-level CLAUDE.md line vs install config)
   is still open; USR-003's verification note allows either. Resolving it would let
   USR-003 and USR-004 agree on one store by construction rather than "the resolver reads
   whichever".

## History
- Round 1 (2026-07-21, opus-4-8, strongest): 8/8 PASS on the FOUR-story set
  (USR-001..004), recorded in `USR-001-004-output-language.md`. Human then flagged an
  R5 coverage gap — the global install prompt (R5a) and a change-anytime affordance (R5c)
  were missing.
- Round 2 (2026-07-21, opus-4-8, strongest): 8/8 PASS on the SIX-story set
  (USR-001..006). Set grew by two stories; prose/warning renumbered to USR-005/006.
  Rubric score is **same (8/8 -> 8/8)** on every criterion — the set was already at
  ceiling and stayed there. The real movement is in **PRD coverage**, not the rubric:
  R5 went from partial (only R5b) to complete (R5a/b/c), so the set now decomposes
  PRD-001 in full. The Round-1 optional fixes also landed: USR-006 pins the warning
  threshold ("more than half"), and USR-004 pins the canonical `output_language: <code>`
  form shared by setup, resolver, and guardrail.
