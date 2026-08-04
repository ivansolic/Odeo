---
artifact: docs/plan-format.md
covers: docs/plan-format.md docs/skill-authoring-standard.md skills/build/SKILL.md
type: standard
branch: chore/adr-001-contracts-not-code
commit: f8f8da6
artifact_version: 2
date: 2026-08-04
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 1, safety_integration: 1 }
total: 7/10
verdict: CHANGES-REQUIRED
previous_total: 6/10
---

Scope: form re-review at HEAD `f8f8da6` of the instruction changes covered by v1,
judged as an AUTHORING STANDARD (a format agents must produce plus a rubric a gate
scores), not as a `SKILL.md`. `agents/architecture-reviewer.md` and `AGENTS.md` were
read as EVIDENCE for finding closure only; `agents/` definitions are
`agent-reviewer`'s artifact and are not scored here.

Verification method note: this session had no shell, so state was verified by
READING every file at HEAD and comparing against the line-quoted content in v1 of
this record, not by reading the diff. Every closure claim below is anchored to a
line that exists at HEAD.

## Artifact: docs/plan-format.md + 2 coordinated files  (format spec, not invoked)

## Scores
- trigger clarity 2 (unchanged): `:5-8` "**What \"exactly\" binds** (this list is
  canonical; other files cite it rather than restating it): signatures, paths,
  behavior rules, INVARIANTS, named mechanisms, test cases, verify commands, and
  boundaries. NOT the implementation shape". The list now declares itself canonical
  and names the two additions, so the one-name-per-concept rule has a single home
  the other files point at. Scope, audience and binding force still in the first
  eleven lines.
- structure 2 (was 1): the three defects that decided the 1 are closed. Only one
  `Consumes / Produces:` field survives, at `:90-91`, placed before `Verify:` (F1).
  The optionality convention now exists in two places, per-section escapes at
  `:44`, `:50-51`, `:97`, `:108-109` and the general rule at `:117-120` ("A
  deliberate `none` plus its one-line reason is NOT a placeholder ... An EMPTY
  heading is a failure"), so the small-story walk no longer produces an empty
  heading (F2). `## Design decisions` `:42` and `## Contracts` `:48` now precede
  `## File map` `:67` and `## Tasks` `:73`, so nothing is cited before it is
  declared (F7). Reorder checked for positional breakage: `:67` "(before any
  tasks)", `:51` "Declared BEFORE the tasks that cite it", `:9` "see the Implement
  field and the Rules below" and `:89` "under the exception in Rules below" are all
  still true at the new order; no section is referenced by position anywhere. 183
  lines, no supporting files, so the size and one-level rules are not at risk.
- worked example 1 (unchanged): the sentence that decided v1's 1 is still true at
  HEAD. `:90-91` cites "local `C1 (Invoice)`, cross-plan `<plan-file> C1
  (Invoice)`" while the only declared entry is `:52` "### C1: language status
  line", so the document's own single cross-reference example does not resolve
  inside the document, in the file whose rubric fails a plan for a dangling
  reference (F14). The Contracts entry itself is now genuinely worked (`:52-64`,
  real Kind, Declaration, Produced by, Consumed by, two real Invariants), Design
  decisions carries a real bullet (`:45-46`) and Success signal a real row
  (`:104`), which is the improvement; but the snippet exception, the one construct
  the rubric attaches a 0 to, still ships without a single labelled instance
  (`:145-147` states the label, shows none), and its placement is still
  unspecified (F6 open). One of the two hardest constructs worked, and the
  cross-reference broken, is not yet "directly imitable".
- precision 1 (unchanged): four of the five v1 ambiguities are closed. The snippet
  unit is now defined (`:139` "one fenced block containing one construct, so two
  regexes in one fence is two snippets and fails", F5), criterion 3 is scorable
  (`:166-176`, F3), `Kind:` multiplicity and the exit-contract Declaration are
  resolved by construction (`:53-56` "one entry may carry both when they are one
  observable surface; split them only if tasks consume them separately" plus a
  Declaration that enumerates "exit 0 on success, 2 on usage error", F10), and the
  duplicate field is gone (F1). Four exactness gaps remain and two are new: the
  label's position is still undefined (`:145`, F6), score 0 fires on "any
  unlabeled code block" with no scope limit while the format itself invites a
  fenced `Verify:` block (`:92`, F13), `Constraints:` at `:39-40` still claims the
  do-not-touch job that `:106-109` now also holds with no statement of which is
  authoritative (F8), and `C1 (Invoice)` names an entry that does not exist (F14).
  Two of those decide a gate outcome, so this is "mostly exact", not exact
  throughout.
- safety integration 1 (unchanged): the artifact still references rather than
  restates where it touches a guardrail (`:131-133` test-first "per the project's
  dev-rigor", `:76-80` Scrutiny non-coupling, `:109` and `:156-157`
  `docs/codebase-map.md` as the enforced boundary source). The specific gap named
  in v1 is still open IN THIS FILE: the cross-plan affordance at `:57-59` and
  `:172-176` never points at the rule that bounds it (`AGENTS.md:165-170`,
  "revising a declaring plan after approval invalidates its consumers' approval"),
  and the rubric header at `:159` still reads "checked at the human gate" alone.
  The system half of that gap IS closed, `AGENTS.md:169-170` now names
  "Detector: `architecture-reviewer` during plan review" and
  `agents/architecture-reviewer.md:17-24` carries the checks, but a human reading
  only `docs/plan-format.md` at the gate still cannot learn what approving a
  cross-plan reference binds. One clause at `:159` or `:57-59` moves this to 2.
  Nothing contradicts or restates a guardrail, so not 0.

## Total: 7/10   ## Verdict: CHANGES-REQUIRED (threshold 8/10, no zero)

## Ceiling
Max reachable 10/10, nothing structurally caps. Safety integration can reach 2
because a guardrail genuinely applies (plan approval, human floor) and needs only
a pointer; worked example can reach 2 with one name fix plus one labelled snippet;
precision can reach 2 with three wording edits. The three remaining blocking-class
items are each one or two lines of text, so the gap to PASS is small and mechanical.

## Prior findings: closure status at f8f8da6

| # | v1 severity | Status at HEAD | Evidence |
|---|---|---|---|
| F1 | High | CLOSED | Only one field remains, `:90-91` "- Consumes / Produces: <REFERENCES into the Contracts section, never new definitions>", placed before `Verify:` `:92`. No `<interfaces/types this task needs>` pair survives anywhere in the file. Criterion 3 is now scorable against a single definition site, and `:121-123` ("Interfaces declared once, in `Contracts`") agrees with it instead of the old consumes/produces wording. |
| F2 | High | PARTIALLY CLOSED | The convention exists and the probe passes: a one-script three-task plan can now be written with no empty heading, because `:117-120` authorizes `none` plus a reason generally ("it is how a small story fills the sections that genuinely do not apply") and `:97` allows a one-line `Task order`. Residual: two of the three per-section escapes are written for a NARROWER case than the one they must cover. `:50-51` says "Write `none` on a single-task plan with no shared interface", but my probe plan has THREE tasks and no interface crossing a boundary, which the section text does not authorize and only the general rule does; `:108-109` says "on a greenfield plan", which does not cover a brownfield repo with no `docs/codebase-map.md`. A strict scorer reading the section as the enumeration of allowed cases still finds a conflict. Fix: `:50-51` "Write `none` plus one line of why when no interface crosses a task boundary"; `:108-109` "Write `none` plus one line of why when this plan is near no existing boundary". |
| F3 | High | CLOSED (with one residual, see F13) | `:166-176` now assigns levels: 0 "vague steps, OR any unlabeled code block (a plan carrying an implementation is not a contract)", 1 "mixed, or one dangling reference", 2 a clean graph with set equality stated operationally ("the set of tasks listing `Consumes: C<n>` EQUALS that entry's `Consumed by:` set"), cross-plan checked "one-directionally, resolution only", and the Success-signal row count tied to the criterion count. Two-scorer test: the four common cases (clean graph, one dangling reference, an unlabeled block, vague steps) now land on the same level for both scorers. Two uncommon cases fall to the catch-all 1 by default rather than by statement, a `Consumed by:` set mismatch and a row-count mismatch, which agrees between scorers but means a broken graph cannot be blocked by this criterion alone. Worth one clause, not blocking. |
| F4 | High | PARTIALLY CLOSED | The operative half is closed: `agents/architecture-reviewer.md:17-24` now carries "the reference graph (every `Consumes:`/`Produces:` resolves to a named `Contracts` entry, within-plan `Consumed by:` sets match the tasks that cite them, cross-plan references cite `<plan-file> C<n>`), any code block missing the `illustrative-not-contract:` label, and any interface with two definition sites", and names itself the detector for the human-floor rule, matching `AGENTS.md:169-170`. The check now has a competent holder. Residual: `docs/plan-format.md:159` still reads "## Plan rubric (checked at the human gate; 0-2 per criterion)", so the format doc alone still assigns an N-task graph walk to a possibly non-engineer human. Fix as v1 proposed: "checked by `architecture-reviewer` during plan review and confirmed at the human gate". This same clause is what moves safety integration to 2. |
| F5 | Medium | CLOSED | `:139` "at most ONE such snippet per task, meaning one fenced block containing one construct, so two regexes in one fence is two snippets and fails". The formatting loophole named in v1 is closed by definition, and the `awk`-in-shell allowance at `:141-144` still reads correctly against it. |
| F6 | Medium | OPEN | `:145` is still "The literal label `illustrative-not-contract:` on the snippet", with no position. The rubric fails an unlabeled block at 0 (`:166-167`), so the greppability of a blocking condition is still undefined. Fix unchanged: "on the line immediately before the opening fence (or as the fence info string), so `grep -B1` finds it". |
| F7 | Medium | CLOSED | Order at HEAD: Header `:31`, Design decisions `:42`, Contracts `:48`, File map `:67`, Tasks `:73`, Task order `:95`, Success signal `:99`, Do-not-touch `:106`, Risks `:111`. Contracts is declared two sections before the task template that cites it. The author placed the pair BEFORE `File map` rather than between it and `Tasks` as v1 proposed; both satisfy declaration-before-use and no positional reference breaks, so this is an acceptable variant, not a deviation. |
| F8 | Medium | PARTIALLY CLOSED | `:108-109` now states the authority chain downward ("the enforced boundary list lives in docs/codebase-map.md, this section names only what THIS plan must respect"), which was the substance of the concern. Residual: `:39-40` `Constraints:` still reads "copied verbatim from the spec/story + do-not-touch boundaries that apply, from docs/codebase-map.md if it exists", so two plan-level fields still claim the same content and neither says which one an architect fills. Fix: trim `:39-40` to spec constraints and add "boundaries live in `## Do-not-touch boundaries`". |
| F9 | Medium | CLOSED (as asked) | `:52-64` is a filled entry: `### C1: language status line`, Kind "stdout format + exit contract", a Declaration with the literal output shape and both exit codes, `Produced by: Task 1`, `Consumed by: Task 4`, and two Invariants that are real constraints ("the `<code>` field always equals `resolve-language.sh`'s output; an invalid project value reports scope `global`, never `project`"). The second half of v1's fix note, "add one labelled-snippet example under Rules in the same pass", was NOT done, which is why worked example stays at 1 together with F14. |
| F10 | Low | CLOSED | `:53-54` "one entry may carry both when they are one observable surface; split them only if tasks consume them separately" answers the multiplicity choice, and `:55-56` shows the exit contract stated as an enumeration, which is the verbatim-referent gap v1 named. |
| F11 | Low | CLOSED | Repo-wide grep for `ADR-001` outside `docs/decisions/` returns nothing: `docs/plan-format.md`, `docs/skill-authoring-standard.md`, `agents/architect.md` and `agents/code-reviewer.md` are clean. `docs/plan-format.md:9` now points inside itself ("see the Implement field and the Rules below") and `docs/skill-authoring-standard.md:45-49` stands on its own text. No publish-snapshot dangle remains. |
| F12 | Low | CLOSED | `docs/skill-authoring-standard.md:71` now reads "a preserved write path once reported success while writing nothing", with no story id. The observed-evidence requirement at `:63-65` still holds (the claim is a real history, stated without the internal identifier), and the cell is one clause shorter, closer to the file's own "One line each" (`:60`). |

## New findings introduced by the fixes

**F13 (Medium) `docs/plan-format.md:166-167` vs `:92`, the new score 0 has no
scope limit.** Criterion 3 now blocks a plan for "any unlabeled code block", and
the same document tells the architect to write "Verify: <exact command(s) and
expected output>" (`:92`), which architects routinely fence. Two scorers can
disagree on whether a fenced verify command or an expected-output block is an
unlabeled code block, and that disagreement decides a 0, which the threshold
blocks outright. The rewrite turned a soft over-reach in v1's wording into a hard
one. Fix: "0 vague steps, OR an unlabeled code block in `Implement:` (a plan
carrying an implementation is not a contract); verify commands and expected output
are not snippets and need no label."

**F14 (Medium) `docs/plan-format.md:90-91` vs `:52`, the doc's own cross-reference
is dangling.** The task template cites `C1 (Invoice)` twice; the declared entry is
`C1: language status line`. An architect imitating the template writes a reference
to a name the Contracts section does not carry, and this is the exact class
criterion 3 caps at 1 ("one dangling reference"). Fix, one line: change `:90-91`
to "local `C1 (language status line)`, cross-plan `<plan-file> C1 (language status
line)`". This is the cheapest single edit in this record and it is what holds
worked example at 1.

**F15 (Low) `docs/plan-format.md:45-46`, `:52-64`, `:69-71`, `:104`, four unrelated
example threads.** The install `--overwrite` flag, the language status line, the
billing invoice files and a German PRD test each illustrate one section. Separate
threads are acceptable for a template where sections are read independently, but
NOT for the two sections that must cross-reference each other, which is how F14
arose. Fix (optional, after F14): keep the language thread in `Contracts`, the
task template and the File map, and leave the other two as they are.

## ADR change-table conformance (the three sites in scope)
| # | Site | Status at HEAD |
|---|---|---|
| 1 | Implement field + snippet exception | met (`:81-89` behavior/invariants/mechanism/no code, conditions at `:134-149`), F5 closed, still weakened by F6 |
| 2 | reframe "complete code does not waive test-first" | met, `:129-133`, replaced not reworded |
| 3 | five sections + Consumes/Produces become references + inline generic examples | met on the definition-site change (F1) and on a worked Contracts entry (F9); still PARTIAL on the escape wording (F2) and on the internal reference (F14); no denylisted `docs/plans/` path referenced |
| 4 | criterion 3 resolution clause | met and now scorable (`:166-176`), held by a competent detector (`agents/architecture-reviewer.md:17-24`, `AGENTS.md:169-170`); `:159` still names the human gate alone |
| 5 | criterion 1 equivalence definition | met, `:161-164` |
| 6 | define what "exactly" binds, plan-format + build SKILL | met and strengthened: `:5-8` declares itself canonical and adds INVARIANTS and named mechanisms; `skills/build/SKILL.md:30,97-98` still agrees |
| 11 | skill-authoring-standard row REPLACED | met, and F12 closed (no internal id, tighter cell) |
| 12 | privacy-scan principle scoped | met, `docs/skill-authoring-standard.md:45-49` |

## skills/build/SKILL.md
Unchanged in substance and still consistent with the canonical list: `:30`
("builder agent builds to that plan's contract in its own worktree") and `:97-98`
("holds the plan's contract exactly"). No new finding. Its own record
(`docs/evals/skill-build.md` v5, 10/10) is not invalidated by anything here.

## House style
No em or en dashes and no non-Latin characters in `docs/plan-format.md`,
`docs/skill-authoring-standard.md` or `skills/build/SKILL.md`. English throughout.
No versions, dates or "currently" introduced. No internal path or story id in a
publish-allowlisted file (F11, F12 closed).

## Map duty
Still no command surface added or altered (a format spec plus wordings), so no
`docs/system-map.md` delta is required. Checked `docs/system-map.md:77`, it does
not carry the "exactly" wording and is not stale. Not a finding.

## Top fixes (in cost order, all three reach 10/10)
1. `:90-91`: rename the cited entry to `C1 (language status line)` so the doc's own
   reference resolves (F14), and add one labelled snippet under Rules with the
   label on the line before the fence (F9 remainder + F6). Moves worked example to
   2 and removes one precision gap.
2. `:159`: "checked by `architecture-reviewer` during plan review and confirmed at
   the human gate", and one clause at `:57-59` pointing at the approval rule a
   cross-plan reference invokes (`AGENTS.md` Guardrails 1). Moves safety
   integration to 2 and closes F4.
3. `:166-167` scope the score-0 trigger to `Implement:` blocks (F13), `:39-40` trim
   `Constraints:` to spec constraints (F8), `:50-51` and `:108-109` widen the two
   narrow escapes (F2 residual). Moves precision to 2.

## Round-by-round
- Round 1 (2026-08-04, Opus 5 (1M), strongest): 6/10 CHANGES-REQUIRED. Four
  blocking findings, five Medium, three Low.
- Round 2 (2026-08-04, Opus 5 (1M), strongest), at `f8f8da6`: 7/10
  CHANGES-REQUIRED. Blocking set essentially closed (F1, F3, F5 fully; F2 and F4
  on their operative half), structure moved 1 to 2, and three of the four
  remaining items are one-line text edits. Two new Medium defects were introduced
  by the fixes themselves (F13 by the criterion-3 rewrite, F14 by filling C1 with
  a name the task template does not cite).

## Vs previous version
6/10 to 7/10, improved, no criterion regressed. Structure 1 to 2 (F1, F2, F7).
Worked example, precision and safety integration each stay at 1, and each for a
DIFFERENT reason than a lack of effort: worked example because the exact v1
sentence ("the doc's own reference does not resolve inside the doc") survives the
fix in a new form (F14) and the snippet still has no instance; precision because
one of the five v1 gaps (F6) is untouched and two new ones appeared (F13, F14);
safety integration because the pointer that would close it moved into
`agents/architecture-reviewer.md` and `AGENTS.md` but not into this file. The
reorder (F7) introduced no defect: no section is referenced by position, and
`Contracts` forward-citing `Task 1` is inherent to declaring before use and is
resolved by `:60-63` making the task-side `Consumes:` authoritative. The
criterion-3 rewrite left no level unreachable and no case double-counted; its only
flaw is the unscoped score-0 trigger (F13).

## History
- v1 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, commit `aee5ab1`):
  6/10 CHANGES-REQUIRED, record created. F1-F4 blocking.
- v2 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, commit `f8f8da6`):
  7/10 CHANGES-REQUIRED, record REGENERATED at the new HEAD (v1 was stale for the
  gate). Changed: closure status for F1-F12 recorded with HEAD evidence, structure
  rescored 1 to 2, two new findings added (F13, F14) plus one Low (F15), and the
  top-fix list reduced to three one-line edits. Verdict unchanged in value, and it
  is now held by a much smaller set of defects than in v1.

Note: this remains a FORM review, verified by reading the files at HEAD (no shell
in this session). Once F13, F14 and the F4 clause are closed, what is left is
BEHAVIORAL: does the architect declare each interface once and reference it, and
does `architecture-reviewer` actually catch a dangling reference and a missing
label in a real plan. That is an `/improve` subagent test, not a form review, and
this record should not be read as evidence about it.
