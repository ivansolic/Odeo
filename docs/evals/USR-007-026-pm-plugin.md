---
covers: USR-007 USR-008 USR-009 USR-010 USR-011 USR-012 USR-013 USR-014 USR-015 USR-016 USR-017 USR-018 USR-019 USR-020 USR-021 USR-022 USR-023 USR-024 USR-025 USR-026 USR-027
type: stories
artifact_version: 2
date: 2026-10-27
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
reviewed_commit: 16ede63
scores: { value_slicing: 2, acceptance_criteria: 1, size_independence: 1, dependency_order: 2, ui_states: N/A }
total: 6/8
verdict: PASS
---

## Artifact: USR-007..USR-027 (user-story set, decomposes PRD-002 R1 to R18, round 2)
Twenty-one stories at commit 16ede63. Round 1 scored twenty stories at 2c3f8ab. The round-1
USR-026 has been split into USR-026 "Run one pilot handoff" and USR-027 "Judge the pilot".
Every surface is chat, files, git hooks or the session-start text, and no story renders a
screen, so criterion 5 is N/A. The total is rescaled to /8, and the threshold is >= 6/8 with
no criterion at 0. These stories feed a build in this repo, so a "Verification note (this
repo)" may carry HOW. Only the ACs are held to observable WHAT.

All nine round-1 fixes are applied, and I checked each one against the files. The score is
unchanged. Two findings remain, both present since 2c3f8ab, and I missed both in round 1 (one
AC, one ownership gap). One further AC defect was introduced by the USR-026 split. Details
below.

## Scores

- **Value slicing: 2.** No story is a technical layer in disguise. The two new pilot stories
  each name who feels the result:
  - USR-026: "so that I see whether the package is enough for the builder to start".
  - USR-027: "so that I decide on facts whether the package is ready for delivery and what
    the brief must hold".
  The founder-facing stories are unchanged, for example USR-016 "I never need to know or type
  a command". The maintainer-facing stories remain legitimate because PRD-002 section 1 names
  the maintainer first. 2.

- **Acceptance criteria: 1.** All five round-1 defects are fixed:
  - USR-015 AC4 is now decidable: "the check lists every such reference it found, and the
    list is empty".
  - USR-019 AC5 ties the list to the search output: "returns every file a full-text search
    for the two merged setup skills' names returns at that commit (the list is fixed in the
    test ...)". The guide skill is no longer named, and every example it gives is in the
    search output the dispatcher supplied for 55dca67.
  - USR-021's Card now says "a short install guide and one guide that walks the core path",
    which agrees with AC3 "Neither guide".
  - USR-022 AC3 now reads "Run on commit 2c3f8ab (before the cut)". Every surface it names
    still carries a removed or merged name in the tree, including `skills/guide/SKILL.md`
    (1 hit) and `.github/ISSUE_TEMPLATE/bug_report.md`.
  - USR-025 AC5 now reads "starts with `publish/`, describes the release and contains no
    date".

  The criterion still requires every AC to be binary. These are not:
  - **USR-025 AC2:** "The PM-relevant parts of the prepared 0.5.0 are in this release." The
    repo has no list of the 0.5.0 changes and no record of which of them count as
    PM-relevant. A full-text search for "0.5.0" returns only `plugin.json`, PRD-002 and two
    stories. PRD-002 Scope item 8 calls the release "review-loop and merge-gate changes", and
    merge-gate is cut. A tester cannot decide pass or fail without making that call first.
    The AC was present at 2c3f8ab, and I missed it in round 1.
  - **USR-026 AC3:** "the transcript shows the user did not copy content ... or re-explain
    anything". AC2 lets the build be recorded as "a transcript or notes", and PRD-002 Scope
    item 7 says the same. When only notes are kept, AC3 cannot be decided. The split
    introduced this mismatch.
  - Minor, not deciding the score:
    - USR-020 AC3: "the session-start overview name[s] only PRD, critique, stories and
      package; other PM skills appear after them, under a separate heading". The guide and
      the README are limited to a "first" answer or section, but the overview has no such
      qualifier. One reading allows other skills in the overview under a separate heading.
      The other reading forbids them.
    - USR-024 AC8: "The prototype uses seed data only." This is copied from R14, but it does
      not say what Odeo does or what a tester checks.

  No vague words appear, and no HOW appears in an AC. 1.

- **Size & independence: 1.** The round-1 size defect is fixed:
  - USR-026 is one handoff at "~1 day of Odeo work per handoff; elapsed time depends on the
    builder", and USR-027 is "~0.5 day after the three handoffs".
  - All 21 stories now state 0.5 to 1.5 days.
  - The round-1 hand-off is now explicit. USR-009's note says "This story also writes the
    list of every removed name into one file in the repository, which the name check in
    USR-022 reads."

  A hand-off of the same kind is still open, for the two merged setup skills:
  - USR-022 AC4: "After the cut, setup merge and guide stories, it passes." That AC can pass
    only if every published reference to `setup-project` and `new-project` has already been
    re-pointed to `setup`.
  - PRD-002's Out list names that re-pointing as required R16 work.
  - No story's AC or note owns it. USR-012's note says only "replaces `new-project` and the
    new-project half of `setup-project`". USR-013 says nothing about references.
  - Today these names appear outside history in files that no setup, guide, baseline or
    positioning story rewrites: `AGENTS.md`, `skills/start`, `skills/brainstorm`,
    `skills/language` (3 hits), `scripts/init-project.sh`, `scripts/set-project-language.sh`,
    `scripts/skills-lint.sh`, `docs/invariants.md`, `.github/ISSUE_TEMPLATE/bug_report.md`,
    a stack preset and two tests.
  - So the builder of USR-022 either absorbs cleanup across about ten files, outside a
    0.5-day estimate, or stops at a check it cannot make pass.

  A residual note that does not decide the score: one story id, USR-026, is run three times,
  and the constraints on those runs ("at least two different build setups", "an idea of a
  person who is not the maintainer") sit only in USR-027. They are judged after the runs
  instead of being stated before them. 1.

- **Dependency order: 2.** The order is explicit (`order: 1` to `21`), every story carries
  `depends_on:`, and the round-1 issues are fixed:
  - USR-016 now depends on "USR-009, USR-012", the story whose remote-repository offer AC4
    relies on.
  - USR-024 now depends on USR-009 instead of USR-023.
  - USR-027 depends on USR-026 and sits last.

  Small gap: USR-022's AC4 waits on the "setup merge" stories, plural, but `depends_on` lists
  USR-012 and not USR-013. The numeric order (7 before 16) still holds, so the build order is
  correct. 2.

- **UI states coverage: N/A.** No story renders a screen. Rubric line 25 directs N/A plus
  rescale.

## Total: 6/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, no criterion at 0)
The set passes at the threshold again. The points are now lost to one undecidable AC carried
over from the PRD, one AC mismatch introduced by the split, and one ownerless cleanup. The
round-1 reasons are all closed.

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

Both round-1 thin clauses are closed:
- R4 quick-share scan: USR-023 AC3, "The privacy scan runs on the prototype before a share
  opens".
- R1 no re-explaining: USR-026 AC3.

Clauses that are still thinner than the requirement:
- **R17, "every rule a remaining skill relies on is in that skill or in AGENTS.md".**
  USR-015 AC4 now checks only that "No remaining skill refers to a baseline section that no
  longer exists". Deleting a skill's reference passes that check even when the skill still
  depends on the rule. The AC is now binary but narrower than R17. To match R17, add: for
  each reference found at 2c3f8ab, the rule it cites is present afterwards in that skill or
  in AGENTS.md.
- **R16, re-pointing references to the merged setup skills.** USR-022 detects these
  references, but no story owns fixing them (see criterion 3).
- R4 is also exercised by USR-009 AC5, USR-018 and USR-024 without being declared there.
  This does not matter to the gate.

## Scope with no source in PRD-002 or the handed decisions
Round 1's list is resolved:
- Dropped: USR-014's ask-and-save AC, USR-017's "says what changed" and USR-024's reminder.
- Matches the PRD's "tagged" again: USR-007.
- Verified: USR-012's "reports the full path". `skills/new-project/SKILL.md` line 25 says
  "the full path it will get".
- Not verifiable by me: three items now carry a named source in their notes, but those
  sources are conversations not recorded in any file I can read. They are the separate
  archive repository and its restore and own-plugin purpose (USR-007, 2026-10-25), one PM
  guide (USR-021, 2026-10-27) and the `publish/` branch rule (USR-025, 2026-10-27). I scored
  them on the dispatcher's statement. PRD-002 R10 and Scope item 3 still say "archive
  branch".

## Loop status (docs/eval-framework.md)
This round is the one re-review that story comments cost, and it approves, so the loop ends
here. Stop condition 3 also applies, and I am naming it as required:
- **Class:** a downstream check presumes upstream work that no upstream AC owns.
- **Round 1 instance:** USR-022 reads a list that USR-009 did not produce.
- **Round 2 instance:** USR-022 must pass after setup stories that do not own the
  re-pointing.

The fix of the kind used in round 1, adding an owning line upstream, would close this
instance and leave the next one possible. A structural fix removes the class instead: make
USR-022 own the cleanup. Its AC would read "every hit outside history at 2c3f8ab is fixed,
then the check is enforced", with its estimate raised to match. The check story then owns
all residue, so no other story has to promise it. The human decides.

## Top fixes
1. **Ownership, USR-022 (raises criterion 3):** make USR-022 fix every remaining hit and then
   enforce, and re-estimate it. As an alternative, add to USR-012 an AC that no published
   file outside history names `setup-project` or `new-project`. Also add USR-013 to USR-022's
   `depends_on`.
2. **AC, USR-025 AC2 (raises criterion 2):** list the prepared 0.5.0 changes, and mark each
   as shipped in this release or dropped with the cut. A list kept with the release is
   enough. Then the AC checks that list.
3. **AC, USR-026 AC3 (raises criterion 2):** require a transcript of the build. As an
   alternative, say what the notes must record for AC3 to be decided, for example "every
   message the user sent the builder, verbatim".
4. **Comment, USR-020 AC3:** say whether the session-start overview may list other skills
   under a separate heading, or only the four.
5. **Comment, USR-024 AC8:** say what Odeo does and what is checked. For example: the
   prototype Odeo publishes holds only data Odeo generated, and the privacy scan's clean
   result is shown.
6. **Coverage, R17 clause:** add to USR-015 that the rule behind each reference found at
   2c3f8ab is present afterwards in that skill or in AGENTS.md.
7. **Note, USR-022:** "RED first on today's tree" should say "on 2c3f8ab", to match AC3.

Fix 1 raises criterion 3 to 2. Fixes 2 and 3 raise criterion 2 to 2. Together they reach 8/8.

## Vs previous version
SAME total, 6/8 -> 6/8 (v1 at 2c3f8ab -> v2 at 16ede63). No criterion moved, but the reasons
changed:
- **Value slicing:** 2 -> 2.
- **Acceptance criteria:** 1 -> 1. All five round-1 defects are fixed. The point is now lost
  on USR-025 AC2, which existed at 2c3f8ab and which I missed in round 1, and on USR-026
  AC3, which the split introduced.
- **Size & independence:** 1 -> 1. The USR-026 size defect and the USR-009 hand-off are
  fixed. The point is now lost on the setup re-pointing ownership gap, which existed at
  2c3f8ab and which I also missed in round 1.
- **Dependency order:** 2 -> 2.

No regression. Every round-1 finding is closed, and the set is cleaner than v1. The
unchanged number reflects what round 1 failed to report, not what the author failed to fix.

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
