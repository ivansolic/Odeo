---
covers: USR-007 USR-008 USR-009 USR-010 USR-011 USR-012 USR-013 USR-014 USR-015 USR-016 USR-017 USR-018 USR-019 USR-020 USR-021 USR-022 USR-023 USR-024 USR-025 USR-026 USR-027
type: stories
artifact_version: 3
date: 2026-10-27
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
reviewed_commit: 48abcc5
scores: { value_slicing: 2, acceptance_criteria: 1, size_independence: 1, dependency_order: 2, ui_states: N/A }
total: 6/8
previous_total: 6/8
verdict: PASS
---

## Artifact: USR-007..USR-027 (user-story set, decomposes PRD-002 R1 to R18, round 3)
Twenty-one stories at commit 48abcc5. Every surface is chat, files, git hooks or the
session-start text, and no story renders a screen, so criterion 5 is N/A. The total is
rescaled to /8, and the threshold is >= 6/8 with no criterion at 0. These stories feed a build
in this repo, so a "Verification note (this repo)" may carry HOW. Only the ACs are held to
observable WHAT.

This is round 3, the last round the cap allows. All seven round-2 fixes are applied, and I
checked each one against the files. The two round-2 deciding defects are closed. The score is
unchanged, because three defects remain. Two of them were present before this round and I
missed them in rounds 1 and 2. One was introduced by this round's USR-025 list.

## Scores

- **Value slicing: 2.** No story is a technical layer in disguise. USR-022 is
  maintainer-facing and says what the maintainer gets: "so that this class of leftover cannot
  reach users however it slips in". The founder-facing stories are unchanged, for example
  USR-016 "I never need to know or type a command". PRD-002 section 1 names the maintainer
  as a user, so maintainer stories are legitimate. 2.

- **Acceptance criteria: 1.** Every round-2 AC defect is fixed:
  - USR-025 AC2 now lists each 0.5.0 change and its fate, for example "the review record is
    committed once per branch (ships)". Each fate can be checked. I confirmed that the three
    "ships" rules are in today's `docs/eval-framework.md` (the stop-condition and
    record-commit sections). I could not check that the list is complete, because the source
    is a `git diff --stat` I cannot run. I scored it on the dispatcher's statement.
  - USR-026 AC2 now reads "a transcript of the build conversation is kept; when the builder
    is a person, every message the user sent them is kept word for word". AC3 can now be
    decided.
  - USR-020 AC4: "The session-start overview names the four core steps first, and any other
    skill only under a heading of its own." This removes the round-2 ambiguity.
  - USR-024 AC8: "When the user says the prototype holds real or personal data, Odeo does
    not publish it and asks for it to be replaced with seed data first." Odeo's action is
    now observable.
  - USR-015 AC5, the R17 clause: "the list of those references and where each rule now
    lives is kept with the check". The AC is binary.

  One AC still needs interpretation:
  - **USR-022 AC1, and through it AC5:** the check "fails ... when a published file names any
    item the cut removes". The AC does not say what counts as naming an item. Several removed
    items are ordinary English words: the skills `build`, `merge`, `deploy`, `ci`, `focus`,
    `query`, `optimize` and `learn`, and the agents `builder`, `architect` and `debugger`.
    The new positioning uses these words. USR-020 AC1 requires the README and the plugin
    description to say "a package ready for delivery to any builder". PRD-002 uses "builder"
    12 times in that sense, and USR-017 AC5 talks about a "build tool". A tester cannot tell
    whether "any builder" in the README fails AC5 without first deciding how names are
    matched. The verification note says only that "the list of names is the file USR-009
    writes". This AC is unchanged in this round, and I missed it in rounds 1 and 2.

  No vague words appear, and no HOW appears in an AC. 1.

- **Size & independence: 1.** The round-2 ownership gap is closed structurally. USR-022 now
  owns the cleanup: "Every published file outside history that names a removed or merged
  item at the start of this story is changed". Its note says "this story owns the cleanup,
  so it depends on no other story having renamed anything". USR-009 AC2, USR-020 and
  USR-021 AC3 no longer repeat the rule.

  Three coupling defects remain:
  - **USR-008 AC4, USR-022 AC5 and USR-010 AC1 cannot all pass.**
    - USR-008 AC4: "Nothing a user installs refers to these tools: a search of the shipped
      plugin for their names finds none". The merge gate is one of these tools.
    - USR-022 AC2 exempts only "Dated history records (review records, older PRDs, stories
      and plans)", and AC5 requires "the check passes on the whole published tree".
    - USR-010 AC1 requires the shipped session-start check to name a hook that calls a
      removed script. Its note says to extend "the existing outdated-guards check in the
      session-start hook ... with the scripts the cut removes; test with a fixture hook that
      calls `merge-gate.sh`".
    - The shipped hook must therefore carry the removed script names. It already does:
      `hooks/odeo-context.sh` line 259 tests for `$HOME/bin/merge-gate.sh`.
    - The same collision applies to USR-009's name-list file, if it ships, to the check's own
      planted-name test (USR-022 AC6), and to USR-019's fixture list of the merged setup
      names. `tests/` is on `docs/public-paths.txt`.
    - USR-008 AC4 also clashes with USR-012 AC7: "Setup says that the pre-push guard older
      Odeo versions installed is no longer installed". The push guard is one of USR-008's
      tools.
  - **USR-008 AC4 is a second owner of the cleanup.** USR-008 is order 2, before the cut and
    before USR-015 and USR-021 rewrite the baseline and the guides. Its AC still requires
    every shipped mention of the merge gate, the code reviewer and the push guard to be gone.
    This is the duplicated rule that this round removed from USR-009, USR-020 and USR-021,
    and it survives here. USR-009's note also still says "remove the files, the hook entry,
    and every pointer".
  - **USR-025 AC2 assigns a fate that no story produces.** It says the "plan-format wording"
    will "leave with the cut, kept in the archive". `docs/plan-format.md` is a published file
    (`docs/public-paths.txt` line 46). The Cut item lists only skills, agents and scripts, and
    neither USR-009 AC1 nor any other story removes that file. USR-022 AC4 allows only
    "names the replacement" or "removed together with the sentence". That leaves a stripped
    file in the release, not the outcome USR-025 states. The same gap applies to other
    build-only files that are neither skills, agents nor scripts: the stack preset and the
    design and knowledge template READMEs under `project-templates/`. No AC rests on those,
    so they do not decide the score.

  A risk that does not decide the score: USR-022's "~1.5 days" is not supported by a
  count. I searched for 15 of the removed or merged names, without `builder`, `architect`,
  `debugger` or the bare skill names. After excluding the files the cut deletes, the
  maintainer tools USR-008 moves, history, and the guides and baseline USR-015 and USR-021
  rewrite, the search still hits about 50 published files. They include:
  - `AGENTS.md` (41 hits) and `docs/system-map.md` (24);
  - `docs/eval-framework.md` (14) and `docs/checklists/review-calibration.md` (13);
  - about a dozen remaining skills, six scripts, nine tests and three `.github` templates.

  Several of these edits need judgment, not just deletion. For example, PRD-002 Scope item 5
  says AGENTS.md keeps "the rules ... Odeo's own maintenance need", yet USR-022 forbids it to
  name the merge gate. 1.

- **Dependency order: 2.** The order is explicit (`order: 1` to `21`), and every story carries
  `depends_on:`. The round-2 gap is fixed: USR-022 now lists "USR-009, USR-012, USR-013,
  USR-015, USR-021". USR-010, USR-019 and USR-020 sit at orders 4, 13 and 14, before
  USR-022 at order 16, so their surfaces exist when the check is introduced. USR-025 lists
  every earlier story, and USR-027 is last. The collisions above are about scope, not order. 2.

- **UI states coverage: N/A.** No story renders a screen. Rubric line 25 directs N/A plus
  rescale.

## Total: 6/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, no criterion at 0)
The set passes at the threshold for the third time. Every finding raised in rounds 1 and 2 is
closed. The two lost points rest on one undefined matching rule (criterion 2) and on a scope
collision plus one unowned removal (criterion 3).

## Ceiling: 8/8
Criterion 5 is structurally N/A, so the most reachable is 4 x 2 = 8. Nothing caps a remaining
criterion below 2.

## PRD-002 coverage (traceability)
I could not run `scripts/coverage-check.sh` (no shell). The dispatcher reports 18 of 18
covered, and my manual map from each story's `covers:` agrees:

| Req | Stories |
|---|---|
| R1 package | USR-017, USR-026, USR-027 |
| R2 clean cut | USR-009, USR-021, USR-022 |
| R3 nothing PM lost | USR-025 |
| R4 protection stays | USR-012, USR-023, USR-025 |
| R5 positioning | USR-020 |
| R6 maintainer tooling | USR-008 |
| R7 package scanned | USR-018 |
| R8 removed scripts named | USR-010 |
| R9 no interviewee data | USR-018 |
| R10 archive private | USR-007 |
| R11 scripts that stay | USR-009 |
| R12 no model policy | USR-011 |
| R13 quick share | USR-023 |
| R14 lasting share | USR-024 |
| R15 start by asking | USR-016, USR-026 |
| R16 one setup | USR-012, USR-013, USR-014, USR-021, USR-022 |
| R17 PM baseline | USR-015 |
| R18 consistency check | USR-019 |

Coverage result: no coverage FAIL.

Both round-2 thin clauses are closed:
- R17, "every rule a remaining skill relies on is in that skill or in AGENTS.md": USR-015
  AC5.
- R16, re-pointing references to the merged setup skills: USR-022 AC4.

Clauses that are still thinner than the requirement (none blocks):
- **R14, "the prototype uses seed data only":** USR-024 AC8 covers only the case "When the
  user says the prototype holds real or personal data". Undeclared real data is caught only
  by the pattern-based privacy scan in AC3.
- **R1 and PRD-002 Scope item 7:** the PRD still allows "a transcript or notes of each
  build". USR-026 AC2 now requires a transcript. The story is stricter than the PRD, which is
  the right direction, but the two documents disagree.
- **Scope item 5 against USR-022:** the PRD keeps maintenance rules in AGENTS.md. USR-022's
  check forbids published files from naming the maintainer's tools. No story says where the
  rules that name them now live.

## Scope with no source in PRD-002 or the handed decisions
Unchanged from round 2. Three items carry a named source that is a conversation I cannot
read. They are the separate archive repository (USR-007, 2026-10-25), the one PM guide
(USR-021, 2026-10-27) and the `publish/` branch rule (USR-025, 2026-10-27). I scored them on
the dispatcher's statement. PRD-002 R10 and Scope item 3 still say "archive branch". The
USR-025 AC2 fate list is sourced to a `git diff --stat 1b0d4c1 96c525e` the dispatcher ran.
I could not run it.

## Loop status (docs/eval-framework.md)
The loop stops here, on two grounds.
- **Stop condition 1:** the verdict is PASS.
- **Stop condition 2:** this is the third round on this artifact. I am not asking for a
  fourth.

Stop condition 3 also applies to one finding, and I am naming it as the framework requires:
- **Class:** a story's AC presumes removal work that no story owns.
- **Round 2 instance:** the merged setup names.
- **Round 3 instance:** `docs/plan-format.md` (USR-025 AC2).
- Making USR-022 own every mention closed the mention-level instance. It does not cover
  whole build-only files that are neither skills, agents nor scripts.

The other two findings are a different class: a name check whose matching rule and
exemptions are undefined. No Critical was found.

What moved across the rounds:
- **Value slicing and dependency order:** steady at 2.
- **Acceptance criteria and size:** each lost its point every round, each time for a
  different reason. Every reason raised was fixed. In my judgment, the remaining reasons
  are design decisions about the name check and about which files the cut removes. More
  wording changes would not settle them, so they belong to the human.

## Top fixes (for the human; no further round is due)
1. **USR-022 AC1 (raises criterion 2):** define what counts as naming an item. For example,
   "a qualified reference: `/odeo:<skill>`, `skills/<name>/`, `agents/<name>.md`,
   `<script>.sh`, or the skill name in backticks". Add an AC that "ready for any builder" in
   the README passes.
2. **USR-022 AC2 and USR-008 AC4 (raise criterion 3):** list every legitimate published
   mention as an exemption the check names:
   - the session-start detector from USR-010 and its test;
   - USR-009's name list;
   - the check's own planted-name test;
   - USR-019's fixture;
   - the sentence in `setup` about the pre-push guard.

   Then replace USR-008 AC4 with "USR-022's check covers these tools' names". This removes
   the second owner and the conflict together.
3. **USR-025 AC2 and USR-009 (raise criterion 3):** decide the fate of `docs/plan-format.md`.
   One option: add it, the stack preset and the design and knowledge template files to
   USR-009's removed list and its AC1. The other: change the AC2 fate to "stays, with the
   build sentences removed by USR-022". The first option removes the class: the cut's list
   becomes the one definition of what leaves.
4. **Note, USR-009:** replace "every pointer" with "pointers in the files this story touches;
   USR-022 owns the rest".
5. **Estimate, USR-022:** re-estimate from a count of hits at the story's start. If you
   split it, the enforcing check must stay in the last part, so that no check presumes
   cleanup another story owns.

Fixes 1 and 2 raise criterion 2 and criterion 3 to 2, if fix 3 is also applied. Together
they reach 8/8.

## Vs previous version
SAME total, 6/8 -> 6/8 (v2 at 16ede63 -> v3 at 48abcc5). No regression on any criterion:
- **Value slicing:** 2 -> 2.
- **Acceptance criteria:** 1 -> 1. Both round-2 deciding defects (USR-025 AC2, USR-026 AC3)
  and both round-2 comments (USR-020, USR-024 AC8) are fixed. The point is now lost on
  USR-022 AC1's undefined matching rule. That AC was unchanged this round, and I missed it in
  rounds 1 and 2.
- **Size & independence:** 1 -> 1. The round-2 ownership gap is closed structurally. The
  point is now lost on three items:
  - the collision between USR-008 AC4, USR-022 AC5 and USR-010 AC1, missed in earlier
    rounds;
  - the duplicate owner left in USR-008, also missed earlier;
  - the plan-format fate, introduced by this round's USR-025 list.
- **Dependency order:** 2 -> 2. The missing USR-013 dependency is fixed.

Across three rounds the set improved materially, and every finding raised was fixed. The
unchanged number partly reflects findings I failed to report earlier. It is not a lack of
fixes.

## History
- Round 1 (2026-10-27, claude-opus-5-5, strongest, effort high, commit 2c3f8ab): 6/8 PASS.
  Value slicing 2, AC 1, size and independence 1, dependency order 2, UI states N/A. No
  coverage FAIL. R4's quick-share privacy-scan clause and R1's no-re-explaining pilot clause
  were only partly covered. Nine fixes were proposed.
- Round 2 (2026-10-27, claude-opus-5-5, strongest, effort high, commit 16ede63): 6/8 PASS.
  Value slicing 2, AC 1, size and independence 1, dependency order 2, UI states N/A.
  - Covers USR-007 to USR-027 (USR-027 is new, split from USR-026).
  - All nine round-1 fixes are applied and verified. No coverage FAIL, and both round-1 thin
    clauses are closed.
  - The criterion 2 point is lost on USR-025 AC2 (missed in round 1) and USR-026 AC3
    (introduced by the split). The criterion 3 point is lost on the unowned re-pointing of
    the merged setup names (missed in round 1).
  - Loop ends: approve on the one re-review, and stop condition 3 is named, with a
    structural fix proposed.
  - The tier "strongest" reflects the Opus-class model my context reports. I did not
    re-check it against the live lineup.
- Round 3 (2026-10-27, claude-opus-5-5, strongest, effort high, commit 48abcc5): 6/8 PASS.
  Value slicing 2, AC 1, size and independence 1, dependency order 2, UI states N/A.
  - All seven round-2 fixes are applied and verified, including the structural fix: USR-022
    now owns the cleanup. No coverage FAIL, and both round-2 thin clauses (R17, R16
    re-pointing) are closed.
  - The criterion 2 point is lost on USR-022 AC1's undefined matching rule ("any builder").
  - The criterion 3 point is lost on three items: USR-008 AC4 and USR-022 AC5 colliding with
    USR-010's shipped detector, USR-008 AC4 as a second cleanup owner, and USR-025 AC2's
    plan-format fate that no story produces.
  - The loop stops on stop conditions 1 and 2 (cap reached). Stop condition 3 is named for
    the plan-format instance. The remaining fixes go to the human.
  - The tier "strongest" reflects the Opus-class model my context reports. I did not
    re-check it against the live lineup.
