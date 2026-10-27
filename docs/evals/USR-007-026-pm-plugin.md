---
covers: USR-007 USR-008 USR-009 USR-010 USR-011 USR-012 USR-013 USR-014 USR-015 USR-016 USR-017 USR-018 USR-019 USR-020 USR-021 USR-022 USR-023 USR-024 USR-025 USR-026 USR-027 USR-028
type: stories
branch: docs/stories-prd-002
artifact_version: 4
date: 2026-10-27
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
reviewed_commit: ad694d6
scores: { value_slicing: 2, acceptance_criteria: 1, size_independence: 2, dependency_order: 2, ui_states: N/A }
total: 7/8
previous_total: 6/8
verdict: PASS
---

## Artifact: USR-007..USR-028 (user-story set, decomposes PRD-002 R1 to R18, round 4)
Twenty-two stories at commit ad694d6. USR-028 is new: it was split from USR-022. Every surface
is chat, files, git hooks or the session-start text, and no story renders a screen, so
criterion 5 is N/A. The total is rescaled to /8, and the threshold is >= 6/8 with no criterion
at 0. These stories feed a build in this repo, so a "Verification note (this repo)" may carry
HOW. Only the ACs are held to observable WHAT.

This is round 4, one round above the three-round cap in `docs/eval-framework.md`. The
dispatcher states that the maintainer explicitly approved this round on 2026-10-27, after
choosing to apply round-3 fixes 1 to 5 and to "remove everything that belongs to the build
phase". I scored it on that statement, because I cannot read the conversation.

All five round-3 fixes are applied. I checked each one against the files:
1. **Reference definition.** USR-028 AC1 defines a reference as one of five qualified forms
   and says "Ordinary words are not references: the README sentence 'ready for delivery to
   any builder' passes." USR-022 AC1 counts "a reference (as USR-028 defines it)".
2. **Exemptions in one place.** USR-028 AC3 names them and requires that "the check prints
   them". USR-008 AC4 is gone. USR-008's note now says "Leftover mentions of these tools in
   published files are cleaned by USR-022 and guarded by USR-028."
3. **Build-only files.** USR-009 AC2 removes "the build plan format, its decision record
   about plans, the stack presets, the design and knowledge project templates, and the tests
   of the removed scripts". USR-009 AC3 makes the removed-items list "the one definition of
   what leaves". USR-025 AC2's plan-format fate is now produced by a story.
4. **USR-009's note** says "fix pointers in the files this story touches; USR-022 owns every
   other mention".
5. **USR-022 estimate and split.** The estimate is now "~2 days (measured count above; split
   by folder if the count at the start is above 300)". It rests on "437 references in 55
   published files" at bb3122f. The guard moved to USR-028 (~0.5 day, order 17), after the
   cleanup.

I could not reproduce the count of 437 without a shell, so I note it as unverified.

## Scores

- **Value slicing: 2.** No story is a technical layer in disguise.
  - USR-022's card is now founder-facing: "so that I am never sent to a step Odeo cannot
    take".
  - USR-028 is maintainer-facing and states what the maintainer gets: "so that this class of
    leftover cannot reach users however it slips in later". PRD-002 section 1 names the
    maintainer as a user, so a maintainer guard is legitimate value.
  - The other stories are unchanged from round 3, for example USR-016: "I never need to know
    or type a command". 2.

- **Acceptance criteria: 1.** The round-3 deciding defect is closed. USR-028 AC1 makes the
  name check binary, and AC7 states its limit: "a mention written without one of these
  forms (for example 'the code reviewer') is not found". USR-028 AC4 to AC6 can each be
  decided: "Run on commit 2c3f8ab (before the cut), it fails", "On the tree after USR-022,
  it passes", and "planting it into an exempt file does not" fail.

  Two ACs added to USR-022 in this round need interpretation:
  - **USR-022 AC3:** "A text that is about the build phase as a whole (for example the code
    and design reviewer scenarios in the review calibration checklist, the build half of the
    evaluation framework) is removed, not reworded".
    - "About the build phase as a whole" is a judgment, and "for example" leaves the set
      open. A tester cannot tell which sections of `docs/eval-framework.md` make up its
      "build half".
    - That file holds the code and UI rows of the threshold table, the "Code comments"
      bullet, the plan-loop paragraph and the record-commit paragraph. USR-025 AC2 says that
      last rule ships.
    - Without a list, "removed, not reworded" cannot be checked. Compare USR-009 AC2, which
      lists its files and so passes.
  - **USR-022 AC5:** "The rules AGENTS.md keeps for Odeo's own maintenance are still in
    AGENTS.md or in the repository-only tooling of USR-008, and no published file loses a
    privacy or honesty rule."
    - Which rules are "for Odeo's own maintenance", and which are "privacy or honesty"
      rules, is not fixed anywhere. A tester has to classify them before the AC can pass or
      fail.
    - USR-015 AC5 solved the same problem with a list kept with the check: "the list of
      those references and where each rule now lives is kept with the check". USR-022 has
      no such list.

  No vague words appear, and no HOW appears in an AC. All other ACs are binary. 1.

- **Size & independence: 2.** All three round-3 coupling defects are closed:
  - **The collision is gone.** USR-008 AC4 is removed. USR-010's detector and test, USR-019's
    fixture, the removed-items list and the check's own test are named exemptions in USR-028
    AC3. USR-012 AC7 ("the pre-push guard older Odeo versions installed is no longer
    installed") no longer collides: the pre-push guard is not on the removed-items list
    (USR-009 AC3 lists only what its AC1 and AC2 remove), and its sentence uses no qualified
    form.
  - **One owner.** USR-022 owns every mention in a qualified form. USR-028 only guards, and
    it comes after the cleanup (`depends_on: USR-022`, order 17). That is the shape round 3
    asked for.
  - **The plan-format fate is produced.** USR-009 AC2 removes the file.

  Sizes stay within 0.5 to 2 days. USR-022 sits at the upper bound, but it has a measured
  basis and a stated split rule, and the files with the most references (WORKFLOW.md, the
  baseline, the template) are rewritten earlier by USR-021, USR-015 and USR-012. USR-026 is
  "~1 day of Odeo work per handoff" and its ACs describe one handoff, so I read the
  three-times run as three instances of one story, not as one 3-day story.

  These findings do not decide the score:
  - **Mentions of removed files that are not skills, agents or scripts have no AC owner.**
    - USR-009's note says "USR-022 owns every other mention". USR-022 measures only
      USR-028's five forms: commands, agent calls, skill folders, agent files and script
      files. A path such as `docs/plan-format.md` or `presets/` is not one of them.
    - Published mentions I found that no AC will remove: `README.md` line 249
      (`plan-format.md` in the tree), `README.md` line 235 (`presets/`), `docs/invariants.md`
      line 26 and `docs/public-paths.txt` line 46.
    - `scripts/skills-lint.sh` lines 283 to 301 (rule C17) compare plan layers against
      `docs/plan-format.md`, and `tests/skills-lint.test.sh` line 323 asserts that "C17
      flags a missing docs/plan-format.md". The lint therefore goes red when USR-009 removes
      the file. The test suite will force that fix during USR-009, so the gap is caught, but
      no story names it.
    - I did not score this as decisive for two reasons. No AC becomes unpassable, and PRD-002
      R2 requires clean pointers only for the skills, agents and scripts of the Cut item. It
      is the same class as round 2 and round 3 (see Loop status).
  - **Where USR-008 moves the tests.** USR-008 moves the merge-gate tests "from the new
    paths". USR-009 AC2 removes "the tests of the removed scripts" from the published tree.
    Both pass if USR-008 moves the merge-gate tests into the repository-only folder. Neither
    story says so, and a builder who leaves them in `tests/` would see USR-009 remove them.
  - **Unpublished files described as published.** USR-009 AC2 lists "its decision record
    about plans" among "published file[s]". `docs/decisions/` is not on
    `docs/public-paths.txt`, so ADR-001 is internal. Removing it is harmless, but the label
    is wrong. 2.

- **Dependency order: 2.** The order is explicit and unique, 1 to 22:
  - USR-022 is 16 and USR-028 is 17.
  - USR-023 to USR-027 are 18 to 22.

  Every story carries `depends_on:`:
  - USR-028 depends on USR-022.
  - USR-025 adds USR-028 and lists every earlier story.
  - USR-022's dependencies (USR-009, USR-012, USR-013, USR-015, USR-021) all come earlier.

  The surfaces USR-028 exempts already exist when it is built: USR-010 (order 4) and USR-019
  (order 13). The one exempted file that comes later, this release's notes from USR-025
  (order 20), is named in advance, which is harmless. USR-023 and USR-024 come after the
  guard, so the guard protects their edits. USR-022 AC1 reads its definition from the later
  USR-028. That is a reference between story texts, not a build dependency, because the
  definition exists in the spec from the start. 2.

- **UI states coverage: N/A.** No story renders a screen. Rubric line 25 directs N/A plus
  rescale.

## Total: 7/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, no criterion at 0)
The set passes, one point above the threshold. This is the first round in which a criterion
gained a point. The one lost point rests on two ACs added to USR-022 in this round, each
measured against an undefined set.

## Ceiling: 8/8
Criterion 5 is structurally N/A, so the most reachable is 4 x 2 = 8. Nothing caps a
remaining criterion below 2.

## PRD-002 coverage (traceability)
I could not run `scripts/coverage-check.sh` (no shell). The dispatcher reports 18 of 18
covered, and my manual map from each story's `covers:` agrees:

| Req | Stories |
|---|---|
| R1 package | USR-017, USR-026, USR-027 |
| R2 clean cut | USR-009, USR-021, USR-022, USR-028 |
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
| R16 one setup | USR-012, USR-013, USR-014, USR-021, USR-022, USR-028 |
| R17 PM baseline | USR-015 |
| R18 consistency check | USR-019 |

Coverage result: no coverage FAIL.

One round-3 thin clause is now closed:
- **PRD-002 Scope item 5 against the name check:** USR-022 AC5 keeps the maintenance rules
  "in AGENTS.md or in the repository-only tooling of USR-008".

Clauses that are still thinner than the requirement (none blocks):
- **R16, "no shipped skill, agent, instruction file or script output names `new-project` or
  `setup-project`":** USR-022 and USR-028 catch only qualified forms. A bare
  `` `setup-project` `` would pass. Today every in-scope mention I found is qualified. The
  only bare ones are in `INSTALL.md`, which USR-021 rewrites, and in `docs/invariants.md`,
  which is outside R16's list. USR-028 AC7 states the limit honestly.
- **R14, "the prototype uses seed data only":** unchanged. USR-024 AC8 covers only the case
  where the user says the prototype holds real data.
- **R1 and PRD-002 Scope item 7:** unchanged. The PRD allows "a transcript or notes", and
  USR-026 AC2 requires a transcript.

## Scope with no source in PRD-002 or the handed decisions
USR-009 AC2 removes files that the PRD's Cut item does not list: the plan format, ADR-001,
the stack presets, the design and knowledge templates, and the tests of removed scripts.
USR-022 AC3 removes build-phase texts. Both are sourced to the maintainer's decision of
2026-10-27, "remove everything that belongs to the build phase", which the dispatcher handed
to me. I cannot read that conversation.

PRD-002's Cut item and R2 still name only skills, agents and scripts, so the PRD and the
stories now disagree on the scope of the cut. Bringing the PRD in line is PRD work, outside
this rubric.

Unchanged from round 3: the separate archive repository (USR-007), the one PM guide
(USR-021) and the `publish/` branch rule (USR-025) carry sources I scored on the
dispatcher's statement.

## Loop status (docs/eval-framework.md)
The loop stops here:
- **Stop condition 1:** the verdict is PASS.
- **Stop condition 2:** this round is already one above the cap, run only because the
  maintainer approved it. I am not asking for a fifth.

Stop condition 3 applies to two findings, and I am naming both as the framework requires.

**Class A (criterion 2): a cleanup AC measured against an undefined set.**
- Round 3 instance: what counts as "naming" a removed item.
- Round 4 instances: which texts are "about the build phase as a whole", and which rules are
  "maintenance", "privacy" or "honesty" rules.
- The round-3 fix defined one set, the reference forms. This round's new ACs reintroduced the
  same shape. The structural fix is to make every cleanup AC in USR-022 check against a list
  that is fixed at the start and kept with the change, as USR-015 AC5 already does.

**Class B (criterion 3, not deciding this round): cleanup work implied by the cut that no AC
owns.**
- Round 2 instance: the merged setup names.
- Round 3 instance: the plan-format file.
- Round 4 instance: mentions of removed files that are not skills, agents or scripts.
- The structural fix is to tie the reference definition to every item on the one
  removed-items list. That fix is Top fix 2.

No Critical was found.

Applying any fix below changes a story, so spec-gate requires one more pm-reviewer round.
That round is above the cap, so whether to apply the fixes is the maintainer's call. Unapplied
fixes are reported here, not chased.

## Top fixes (for the human; a further round needs the maintainer's approval)
1. **USR-022 AC3 and AC5 (raise criterion 2 to 2):** extend AC1's count with two lists kept
   with the change:
   - each build-phase text to remove, by file and section;
   - each AGENTS.md maintenance rule and each privacy or honesty rule in a published file,
     with where it lives afterwards.

   Rewrite AC3 as "every text on that list is absent afterwards", and AC5 as "every rule on
   that list still exists where the list says". Both become binary, as in USR-015 AC5.
2. **USR-028 AC1 (closes class B):** add a sixth form, "the repository path of any other
   item on the removed list (for example `docs/plan-format.md`, `presets/`)". USR-022's count
   and USR-028's check then cover every item the cut removes. The README tree, the stale
   `docs/public-paths.txt` entry and `docs/invariants.md` fall under the count, and the
   C17 lint rule becomes visible work instead of a surprise in USR-009.
3. **USR-008 or USR-009 (clarity):** say that the maintainer tools' tests move with them into
   the repository-only folder. Then USR-009 AC2's "tests of the removed scripts" plainly
   excludes them.
4. **USR-009 AC2 (accuracy):** drop "published" for ADR-001, or say "files", because
   `docs/decisions/` is internal.

Fix 1 alone reaches 8/8. Fixes 2 to 4 do not move the score. Fix 2 removes a recurring class.

## Vs previous version
BETTER, 6/8 -> 7/8 (v3 at 48abcc5 -> v4 at ad694d6). No criterion regressed:
- **Value slicing:** 2 -> 2.
- **Acceptance criteria:** 1 -> 1.
  - The round-3 deciding defect, USR-022 AC1's undefined matching rule, is closed by USR-028
    AC1.
  - The point is now lost on USR-022 AC3 and AC5, both new in this round.
- **Size & independence:** 1 -> 2. All three round-3 defects are closed:
  - the USR-008 AC4, USR-022 AC5 and USR-010 collision;
  - USR-008 as a second cleanup owner;
  - the plan-format fate that no story produced.
- **Dependency order:** 2 -> 2. The renumbering is consistent, and USR-025 now depends on
  USR-028.

Trajectory across four rounds: 6/8 -> 6/8 -> 6/8 -> 7/8, PASS each time.

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
- Round 4 (2026-10-27, claude-opus-5-5, strongest, effort high, commit ad694d6): 7/8 PASS.
  Value slicing 2, AC 1, size and independence 2, dependency order 2, UI states N/A.
  - Run above the three-round cap with the maintainer's explicit approval (2026-10-27, as
    the dispatcher stated).
  - Covers USR-007 to USR-028 (USR-028 is new, split from USR-022).
  - All five round-3 fixes are applied and verified. No coverage FAIL, and the Scope item 5
    thin clause is closed.
  - The criterion 2 point is lost on USR-022 AC3 and AC5, both new in this round, each
    measured against an undefined set.
  - Criterion 3 rises to 2. Mentions of removed files that are not skills, agents or scripts
    have no AC owner (class B, third instance), but this does not decide the score.
  - The loop stops on stop condition 1. Stop condition 3 is named for class A and class B.
    Any further round needs the maintainer's approval.
  - The tier "strongest" reflects the Opus-class model my context reports. I did not
    re-check it against the live lineup.
- Reissued 2026-10-27 (claude-opus-5-5, strongest, effort high) to add the missing `branch:
  docs/stories-prd-002` frontmatter field, no rescoring. Round-4 scores, verdict and
  `reviewed_commit: ad694d6` are unchanged. I have no shell, so I could not run `git diff
  ad694d6 HEAD -- docs/stories/` myself. The dispatcher reports it empty at HEAD f6b0684. What
  I could check agrees: the HEAD reflog shows f6b0684 as the only commit after ad694d6, a
  `chore(evals)` commit for this record, and the story lines this record quotes (USR-022 AC3,
  AC5 and estimate, USR-028 AC1) read as quoted. The gate's own `reviewed_commit:` check is
  the deterministic backstop if anything did move.
