---
artifact: release-0.3.5
type: code
branch: chore/release-0.3.5
reviewed_commit: 65e00cd
artifact_version: 2
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
---

# Code review: chore/release-0.3.5, round 2

## Scope reviewed

- `git rev-parse --short HEAD` is 65e00cd. That commit is
  `docs(research): drop an internal record path from two public comments`, and it is the
  tip: nothing comes after it.
- `git diff --stat 91566d1..65e00cd` lists three files. One is the round-1 record, which
  b830ac4 added unchanged. The other two are one-line comment edits in
  `scripts/research-check.sh:4` and `tests/research-check.test.sh:7`. Nothing else moved,
  so the round-1 coverage, bump, classification and count checks still hold for this
  commit. I did not repeat them.

## Checks

1. **Round-1 Important 2, the instance.** Both `(docs/evals/RES-002.md)` parentheticals are
   gone. `grep -rn docs/evals/RES-002` across scripts/, tests/, bin/, skills/ and README.md
   now finds nothing. Both comments still read correctly. The edit only touches comments,
   so the 145 assertions in the research-check suite are unaffected. I did not re-run
   them.
2. **The four older references the dispatcher's hand grep found.** All four come from
   before this release and are already on the public origin/main. None of them must block
   0.3.5:
   - `skills/merge/SKILL.md:102`, `docs/evals/skill-merge.md`. This sits in a line of
     sample output in a worked example. A reader takes it as an illustrative record name,
     not as a pointer to a file to open. No content is leaked, it is only a filename. It
     does collide with a real internal file, so the 0.3.6 tripwire will fire on it. The
     fix there is to rename it to a synthetic name that fits the example branch, such as
     `docs/evals/code-docs-fix-the-thing.md`.
   - `tests/localized-prose.test.sh:12` and `tests/fixtures/language-de-project/CLAUDE.md:4`,
     `docs/checklists/language-live-check.md`. This is the same class as the one just
     fixed. A public reader is pointed at a procedure the public tree does not ship. The
     first of the two goes further and says AC1's generated-output half "is proven by"
     that procedure, so on the public tree that claim cannot be checked. It is the
     strongest of the four and should be fixed first in 0.3.6: either say that the
     procedure is maintainer-internal, or drop the path. It does not block this release,
     because 0.3.5 neither adds nor changes it, and holding the release back would not
     unpublish it.
   - `tests/language-guard.test.sh:185,198`. This is not a reference. It is a filename used
     as a fixture, created under `$TMP`, which happens to match the tracked
     `docs/plans/2026-07-23-USR-001-no-leak-guardrail.md` (and line 192 matches the tracked
     story/eval name `USR-001-006-output-language.md`). It is a false positive for the
     tripwire. The 0.3.6 mechanism must deal with it, either by renaming the fixture to a
     synthetic id or by matching only outside `$TMP` heredoc targets. Otherwise the
     tripwire starts life with an exemption list, and that list will grow.
3. **Snapshot status.** The dispatcher reports publish-snapshot exit 3 with 35 advisory
   privacy findings, none on a file changed since dd566c2, and that the snapshot suites
   are running. I did not verify any of this. The merge decision should wait for those
   suites to come back green.

## Findings

Critical: none.

Important
- `skills/research/SKILL.md:35` and `:75` (carried over from round 1, routed to 0.3.6): the
  folder `~/.cache/odeo/research/RES-NNN/` is shared by every project on the machine.
  `read_sources` (`scripts/research-check.sh:264-288`) reads every file in it, so a quote
  found only in another project's page, or in an abandoned attempt's page, counts as
  verbatim. Round 1 showed this on the fixture: rc 1 without the page, rc 0 with it copied
  into a sibling directory. The fix is unchanged: give each project its own folder, and
  require the folder to be new or emptied with the human's OK. Add it to "Honest limits".
  It needs a skill-reviewer pass.

Nitpicks
- `bin/research-check.sh:2-3` (carried over, routed to 0.3.6): the reason the comment gives
  for the wrapper, 0.2.x callers, cannot apply to a program that is new in 0.3.5. It should
  name the bin/scripts parity rule in `tests/bin-wrappers.test.sh` instead.

## Routing to 0.3.6: is it acceptable for a patch release?

Yes for both items, on these terms:
- **(1) Shared cache folder: acceptable.** The fault weakens a check, it does not open a
  bypass. `research-check.sh` runs before review as an advisory check. No gate, hook or
  spec-gate reads it, and the research reviewer still judges quotes against the sources.
  The fault only shows up when two projects, or two attempts, reuse the same `RES-NNN`
  number and the planted page contains the quote. The fix changes the skill, which needs
  its own skill-reviewer loop, and a release-bump branch is the wrong place for that.
  Shipping 0.3.5 does not make anything worse than it was in 0.3.4, which had no quote
  check at all.
- **(2) The tripwire: acceptable.** The instance this release would have added is fixed.
  The four references left are already public, unchanged here, and leak only filenames,
  not content. Still, the class has now recurred across two releases, so under the
  placement rule (a lesson that recurs needs a mechanism, not another reminder) the
  tripwire must not slip past 0.3.6. Build it RED-first against a planted reference, and
  have it cover the `$TMP` fixture false positive described above.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 11/12 (threshold: >=9, no zero). PASS.

## Ceiling

The ceiling for this branch as scoped is 11/12. Correctness is held at 1 by the
shared-cache Important, which is shipped code and deliberately left for 0.3.6, because its
fix is a skill change with its own reviewer. 12/12 needs that fix, and it does not belong
on a release-bump branch.

Conventions went from 1 to 2. The diff no longer adds an internal path to public files. The
four older references are outside this release's diff and do not count against it, but
they are recorded above so that 0.3.6 owns them.

## Regression note

Better than round 1: 10/12 -> 11/12, and the verdict stays APPROVE WITH COMMENTS.
Conventions went up because the two parentheticals were removed. Correctness is unchanged,
because the finding was routed and not fixed.

## History

- Round 1, at 91566d1: 10/12, APPROVE WITH COMMENTS. Important 1 was the shared cache
  folder. Important 2 was `docs/evals/RES-002.md` named in two public comments, plus the
  request for a tripwire. There was one nitpick, the `bin/research-check.sh` comment. The
  release contents dd566c2..91566d1 were checked for coverage, bump type, classification,
  public surface, counts and dashes.
- Round 2, at 65e00cd: the instance of Important 2 is fixed. Important 1, the tripwire and
  the nitpick are routed to a 0.3.6 fix branch. The four older references to internal
  paths were judged and do not block the release. 11/12, APPROVE WITH COMMENTS.
