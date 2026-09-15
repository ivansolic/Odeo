---
artifact: docs-rename-odeo
type: code
branch: docs/rename-odeo-and-readme
reviewed_commit: 33d7e4c
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 5
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

## Scope reviewed

Closure round, deliberately bounded by the dispatch brief: this round answers
two questions only, (a) are the two v4 Importants genuinely closed, and (b) is
this safe to publish publicly. No new investigation lines were opened; anything
noticed in passing is listed in one line under "Noted, not investigated".

Commit `33d7e4c` (`fix(install): make a skipped file in bin/ impossible to
miss, and unblind the test`), reviewed as the delta `fa972fd..33d7e4c`
(`install.sh`, `tests/install-bin.test.sh`, `README.md:126-131`, and the two
one-character comment fixes in `tests/language-guard.test.sh:2` and
`tests/localized-prose.test.sh:102`).

Provenance: ORCHESTRATING SESSION, not an isolated builder, so
`build_model_as_dispatched:` is omitted by design.

`git rev-parse --short HEAD` == `33d7e4c`, verified by me. The working tree is
bit-identical to the `33d7e4c` blobs at both ends of this review; the only
modification reported by `git status --porcelain` is this record. Every mutation
ran against `git archive 33d7e4c` copies under `/tmp/mutrepo*`; nothing was
written into the repository and no command ran against a real `$HOME`.

## (a) The two open v4 Importants

**v4 Important 1, the shebang predicate's silent-skip residual and the
structurally blind test: CLOSED on both sides, re-proved by mutation.**

The fix is the structural one, not the instance patch. `install.sh` now
accumulates skipped basenames on the else branch and refuses to finish:
`[[ -z "$skipped" ]] || { ... exit 1; }`, naming every offender on stderr with a
remediation line. So "installed nothing" and "skipped something" are both
unrepresentable as a clean exit, which is what makes the comment's promise
("every program in bin/") enforceable rather than aspirational.

The test is unblinded at the source of the blindness: `expected` is now counted
from the DIRECTORY (`[[ -f ]]` only), with no shebang predicate anywhere in its
derivation, so the expectation can no longer be filtered by the rule under test.

Two mutations re-run, chosen as the load-bearing pair rather than all five:

| mutation (on a `/tmp` copy of `33d7e4c`) | expected | observed |
|---|---|---|
| delete the skip-fail guard from `install.sh` | case 4 RED, nothing else | exactly 2 FAILs, `a shebang-less file was skipped SILENTLY (install exited 0)` and `failed without naming the skipped file`; suite exit 2 |
| the above PLUS re-derive `expected` with the implementation's own shebang predicate (the exact v4 blindness restored) | still RED, because case 4 no longer depends on the count | identical 2 FAILs, suite exit 2 |

That second row is the finding closed. In v4 I planted a shebang-less
`bin/odeo-helper` and the suite printed "all 5 assertions passed" at exit 0.
At this head, with the blind `expected` deliberately restored, the same plant
still reddens: the count is no longer the only witness, so the defect cannot
hide behind an agreeing expectation. Baseline on the unmutated copy: 9/9
assertions pass. `bash -n install.sh` exits 0.

I also re-ran the marker-drift case, since the awk extraction is the instrument
the two mutations above depend on: deleting `# END bin-install` makes the range
run to EOF (122 lines extracted) and the suite aborts with
`instrument broken: extracted 122 lines ... A marker in install.sh moved or was
removed` before any assertion runs. Marker drift therefore fails loud and is
diagnosed as an instrument fault, never as a behaviour finding. That is the
correct fail direction for a text-range extraction, and it is what lets me read
the two reds above as real.

The three v4 nitpicks against the suite are closed as a side effect and I
confirmed each: the instrument line now increments `pass` (9 `ok` lines, "all 9
assertions passed", the summary and the README total agree), case 3 asserts the
stderr text and not merely a non-zero exit, and the extraction is keyed on named
markers instead of code lines. Keeping `run_loop_err` separate from `run_loop`
rather than making one helper both print and set a status is the right call and
is the rule recorded in `lessons.md` (2026-08-13); the comment at
`tests/install-bin.test.sh:70-73` says so explicitly, so the next editor cannot
merge them by accident.

**v4 Important 2, the stale cross-cutting clause at `README.md:130`: CLOSED, and
all three claims in the replacement independently verified.**

- **27 suites.** `ls tests/*.test.sh | wc -l` = 27. All 27 exit 0.
- **827 assertions.** Counted from a real full run, both house formats
  (`^ok` and `^ok:`), summed per suite: **827 exactly**. The new suite
  contributes 9.
- **"21 of the 22 programs have their own suite (session-end-check.sh has none
  yet)".** `bin/` holds 22 files. Twenty have an exact-name suite; `init-project.sh`
  is covered by `tests/init-project.language.test.sh`, which is a suite dedicated
  to that one program, giving 21; `session-end-check.sh` has none. The claim is
  true under the only reading that makes "their own suite" mean anything, and it
  is now stated as a fact that does not move when a suite is added, which is the
  point of the rewrite. The contested count (six versus seven cross-cutting) is
  correctly no longer asserted.

**v4 Important 3, `ivansolic/Odeo-knowledge` 404: CARRIED FORWARD, unchanged,
by the human's decision. Not re-investigated this round and not a publish
blocker.** Re-confirmed only that the install path still degrades gracefully:
`install.sh:181-189` wraps the clone in an `if`, so a 404 prints
"community knowledge repo not reachable yet, skipped" and the install
continues. The user-visible residual remains `skills/contribute-lesson/SKILL.md:54`,
which instructs a fork-and-PR against that repo. Recommendation unchanged:
create the empty repo before announcing publicly.

## (b) Publish assessment

**Nothing blocks publishing. Every check below was run at this head, not
inherited.**

| check | command | result |
|---|---|---|
| syntax | `bash -n install.sh` | exit 0 |
| lint | `bash bin/skills-lint.sh .` | exit 0, "all invariants hold" |
| suites | all 27 `tests/*.test.sh` | 27/27 exit 0, 0 failing |
| snapshot | `bash bin/publish-snapshot.sh /tmp/odeo-snap` | **exit 3** |
| personal data | grep for the work-email local part, the employer name, and the real home-directory prefix, over the whole snapshot | **no matching file, grep exit 1** |

**Exit code 3 is the clean outcome here, and it is worth being precise about
why.** In this tool's documented contract (`bin/publish-snapshot.sh:6-9`), exit
1 is a verification FAILURE (an internal or unclassified path, snapshot
removed) and exit 3 is advisory privacy findings only, snapshot KEPT for human
review. The run produced **zero** `internal path present` lines and **zero**
`unclassified path` lines, so every path in the snapshot is classified and the
fail-closed half of the guard is satisfied. The 24 advisory lines are the same
class confirmed false-positive in v3 and v4; I re-ran the scanner against three
of them this round as a spot check and all three fire on the word "tokens" in
ordinary prose or in a build command (a design-token build script in a template
settings file and in a skill, and a sentence about session cookies in the global
baseline). No credential, no key, no personal data.

Internal directories confirmed ABSENT from the materialized snapshot, each
checked individually: `.claude/`, `knowledge/`, `docs/evals/`, `docs/plans/`,
`docs/prds/`, `docs/stories/`, `docs/research/`, `docs/decisions/`.
`docs/internal-paths.txt` itself is present, which is correct and deliberate: it
is a list of path names, allowlisted for publication, and it carries no content.

The wider name sweep I ran over the snapshot returns only the two structural
classes this project already classified as ownership rather than leaked personal
data: the copyright holder in `LICENSE:3`, and the public GitHub handle inside
repo URLs (`install.sh`, `INSTALL.md`, `README.md`, `.claude-plugin/plugin.json`,
`.github/ISSUE_TEMPLATE/config.yml`, `skills/contribute-lesson/SKILL.md`). The
only address-shaped and home-path-shaped strings in the snapshot are synthetic
fixtures inside the guards' own tests (invented users under an `example` domain)
and the documented pattern description in `docs/privacy-guard.md:33`.

**Publish answer: YES.**

## Critical (must fix before merge)

None.

## Important (should fix)

None open against this change. The one carried item (`Odeo-knowledge` 404) is
pre-existing, outside this branch's diff, explicitly owned by the human, and
non-blocking; it is recorded above rather than scored here.

## Noted, not investigated

One line each, as instructed. None of these was investigated and none affects
the verdict.

- `install.sh:9` still lists `~/bin/init-project.sh` as the bin destination
  while section 3 installs all of `bin/` (v4 nitpick 3, unchanged).
- `README.md:131` "the remaining suites are cross-cutting rather than
  per-program" is a shade loose for `install-bin`, which pins one program
  (`install.sh`, just not a `bin/` one).
- A subdirectory inside `bin/` would be skipped by `[[ -f ]]` without entering
  the `skipped` list; directories are not programs, so this is behaviour, not a
  defect.
- `run_loop_err` cleans its `mktemp` file inline rather than via `trap`, the
  same minority pattern noted in v4.

## Verified correct, do NOT "fix"

- The strictness of the new skip guard (a non-program file in `bin/` stops the
  install). It is deliberate, documented in place, and it is what converts the
  comment's promise into an enforced invariant. The dotfile case that would make
  it annoying on macOS cannot arise: `bin/*` does not match dotfiles without
  `dotglob`.
- Splitting `run_loop` and `run_loop_err` instead of one helper that prints and
  returns. That shape is the recorded cause of an earlier empty-string bug.
- `bin/coverage-check.sh:23` and the `- **R<n> , ...` fixtures in
  `tests/coverage-check.test.sh`, carried from v3 and v4: they document the form
  `/prd` emits and the parser tolerates.

## Scores

correctness 2 · security 2 · performance 2 · readability 2 · testing 2 ·
conventions 2 -> **12/12** (threshold: >=9, no zero)

Testing moves 1 -> 2: the expected set no longer passes through the rule under
test, the skip direction has a dedicated case, "loud" is asserted as a message
and not only as a status, the instrument aborts loud on marker drift, and I
reproduced the reds myself rather than reading them.

Conventions moves 1 -> 2: the README sentence is now true in all three of its
claims, each re-derived from a real run, and it is phrased so that adding a
suite cannot falsify it again. `CLAUDE.md`'s "coverage claims are proven by
mutation, not asserted" is satisfied by the commit and independently re-proved
here.

## Ceiling

12/12 was reachable for this change and is reached. Nothing structurally caps a
criterion: the diff is small, has a real behavioural contract, ships a test that
mutation-proves both directions of that contract, touches no security surface
(no network, no user input, no privilege), and has no performance dimension
beyond a two-byte read per file in `bin/`. The carried `Odeo-knowledge` 404 is
deliberately not scored: it predates this branch, lives outside the diff, and is
an open product decision rather than a defect in the code under review.

## Regression note

**Better: 10/12 -> 12/12.** Per dimension: correctness 2 -> 2, security 2 -> 2,
performance 2 -> 2, readability 2 -> 2, testing 1 -> 2, conventions 1 -> 2.

Both points were won the right way. The testing point was not won by adding
assertions but by removing the agreement between the test and the implementation
that made the old assertions unfalsifiable, which is the difference between more
tests and a better instrument. The conventions point was not won by patching a
number but by restating the claim as something measurement can settle, so the
class of "documented count goes stale on the next commit" is closed rather than
the instance.

Nothing previously verified has regressed at this head: 27/27 suites green, lint
green, publish classification clean with internal directories absent, personal
data absent from the snapshot.

## What's good

The fix chose the invariant over the heuristic, twice. On the implementation
side, the answer to "the predicate can be wrong" was not a cleverer predicate
but a second guard that makes a wrong predicate impossible to hide: zero
installed is loud, and any skip is loud. On the test side, the answer to "the
expectation was blind" was not another assertion using the same filter but
deriving the expectation from a different source entirely. Both are the shape
`CLAUDE.md` and `lessons.md` ask for, eliminate the class rather than guard the
instance, and both survived mutation when I tried to reopen them.

The README rewrite is the better kind of retreat. Rather than defend a
contestable count, it states the fact that does not depend on how one classifies
`init-project.language.test.sh`, and it names the one real gap
(`session-end-check.sh`) out loud instead of rounding it away. A claim that
cannot go stale on the next commit is worth more than a precise one that can.

The marker rework deserves a note too. Keying the extraction on named
`BEGIN`/`END` markers instead of code-line text fixed a fail-open instrument that
had already misfired once (swallowing 123 lines when the code grew a second
guard), and bounding it means a future refactor of `install.sh` gets a clear
"the marker moved" instead of an inscrutable behaviour failure. That is
maintenance cost paid by the person who created it rather than by whoever edits
next.

## History

- **v1, `8c85a3e`, 2026-09-15, APPROVE WITH COMMENTS, 11/12.** First record for
  this branch. Verified the product-name rename left every URL and path
  byte-identical to `main`, re-derived 818 assertions, confirmed the WORKFLOW
  command table. Three Importants: stale "Cofounder" in
  `project-templates/design/README.md:36`; `bin/` undercounted as 21 scripts;
  `README.md:127` falsely claimed "one per guard script". Three nitpicks:
  skills-lint's understated scope, `docs/examples/` missing from the docs tree,
  and the surviving ` , ` artifacts. Also reported an unexplained mid-review
  working-tree mutation and judged the rename it contained to be a latent
  Critical, a conclusion v2 corrected.
- **v2, `9802526`, 2026-09-15, APPROVE WITH COMMENTS, 11/12.** All three v1
  Importants closed and re-verified by independent derivation; the GitHub rename
  confirmed legitimate against the live remote; the v1 "Environment warning"
  section replaced with the corrected account. Two new Importants (dead
  Discussions link at `config.yml:4`, `token-report.py` not installed at
  `install.sh:81`), one v1 nitpick carried forward.
- **v3, `fa972fd`, 2026-09-15, APPROVE WITH COMMENTS, 9/12.** Both v2 Importants
  and all four v2 nitpicks closed and independently re-derived. Four Importants
  this round: the exec-bit predicate's silent-zero failure mode in the install
  fix (demonstrated, 0 installed vs 21 previously), the absence of any test
  pinning the install contract, the unswept remainder of the ` , ` class in two
  shipping test files, and the pre-existing 404 on `ivansolic/Odeo-knowledge`.
  Publish path re-verified end to end at this head: exit 3, advisory only, all
  24 findings individually confirmed false positives, no personal data in the
  snapshot.
- **v4, `e732848`, 2026-09-15, APPROVE WITH COMMENTS, 10/12.** Three of the four
  v3 Importants closed and independently re-verified: the install loop
  reproduced 22/22 on a normal checkout, 22/22 with exec bits stripped, exit 1
  with a stderr message on an empty and on a missing `bin/`, and 0/40 wrong
  counts under a pipefail flakiness probe; the new suite re-mutated five ways
  (glob, exec-bit, neutered guard, and both marker drifts) with the right reds
  each time, and both instrument fixes independently re-derived; the ` , ` class
  grepped over the computed publish allowlist (173 shipping files) with only the
  10 deliberate keeps remaining; 27 suites and 824 assertions re-counted from a
  real run. Two Importants: the shebang predicate's remaining silent-skip
  residual, which the new suite was structurally blind to (demonstrated with a
  planted shebang-less program: 22 of 23 installed, suite still green), and the
  stale "five are cross-cutting" at `README.md:130`. The `Odeo-knowledge` 404
  carried forward as an open item by the human's decision. Publish rebuilt at
  this head: exit 3, advisory only, 173 files all classified, internal
  directories absent, personal-data grep clean.
- **v5, `33d7e4c`, 2026-09-15, APPROVE, 12/12.** Closure round, scope bounded to
  the two open Importants plus the publish decision. Both closed and re-proved
  independently: deleting the new skip-fail guard reddens the suite on exactly
  the two case-4 assertions, and restoring the v4 blindness in `expected` on top
  of it still reddens, which is the structural proof that the count is no longer
  the only witness; marker drift aborts as an instrument fault (122 lines
  extracted) rather than as a behaviour finding; and all three claims in the
  rewritten `README.md:129-131` re-derived from a real run (27 suites, **827**
  assertions counted, 21 of 22 programs with a dedicated suite,
  `session-end-check.sh` the one gap). The three v4 suite nitpicks closed as a
  side effect. Publish re-verified at this head: `bash -n` clean, lint exit 0,
  27/27 suites green, snapshot exit 3 (advisory only, zero unclassified and zero
  internal paths), internal directories absent, personal-data grep clean. The
  `Odeo-knowledge` 404 remains open by the human's decision and does not block
  the push. Verdict raised to APPROVE.

### Correction carried forward (first made in v2)

The v1 record reported a mid-review working-tree mutation by an unknown writer
and concluded it "would have broken the clone URL and every installed path",
i.e. a latent Critical. **Both halves of that conclusion are wrong**, and the
correction is preserved here so no false Critical survives on this file.

- The writer was the ORCHESTRATING SESSION, editing the same files under review.
  Not an unknown tool, not a corrupted repo. Nothing committed was ever at risk.
- The edit was not a break. While that review was running, the human renamed the
  GitHub repos; `ivansolic/Odeo` is the live name, confirmed by `git ls-remote`
  and the GitHub API in v2, by the API again in v3, and by the API plus a 200 on
  the Discussions URL in v4. The premise v1 reasoned from (repo still named
  `claude-cofounder`) was true when it was dispatched and false by the time it
  concluded. **The rename in the tree is the CORRECT state.**
- The one real defect v1 caught in that edit, the mangled tree line
  `│   └── Odeo/← the cloned repo`, was genuine and is fixed at
  `INSTALL.md:250`.

The transferable lesson is about method: a review's conclusions are only as good
as the world-state premises it was handed, and a premise about an external
system (a remote's name, a feature flag) must be re-verified against that
system rather than inherited from the dispatch brief.
