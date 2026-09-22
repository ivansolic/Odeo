---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 15b168f
artifact_version: 9
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

## Artifact

Round 9, the final anchor, at `15b168f`. Same artifact scope as rounds 1 to 8. Four commits
landed since round 8; exactly one of them, `ad00988`, is inside this artifact, and it is the fix
for both round-8 Importants. `git diff 5972c27..HEAD --stat` over the artifact's files lists
`bin/docs-claims-check.sh` (+28), `tests/docs-claims-check.test.sh` (+55) and `README.md` (+1,
the assertion count). The other three commits (`1b3c72d`, `853d03a`, `15b168f`) are the sibling
ledger-backup program, scored in `docs/evals/code-ledger-backup.md`; they are not re-scored here
and were read only where they feed this artifact's count and skip accounting.

Immobility, measured rather than assumed: `git diff cebc0a0..HEAD -- install.ps1` is empty,
`shasum install.ps1` is still `594ed21c9287a7708a953f5b50d53289f408253b`, last touching commit
`4416477`. `git diff 994ede8..HEAD --stat` over `tests/install-ps1.test.sh`,
`tests/publish-guard.test.sh`, `install.sh`, `.gitattributes` and `INSTALL.md` is empty, so those
are byte-identical to the round-5 head across nine commits and rounds 1 to 8's findings on them
carry forward unchanged. No plan exists in `docs/plans/` for this branch, so there is no contract
to compare against. Working tree clean at `15b168f` outside `docs/evals/`.

## The two round-8 Importants: both CLOSED, run rather than read

**1. A suite that fails is no longer excused, and the path cannot be swallowed.** The loop now
reads `rc` (`:99-115`) and a non-zero exit prints `SUITE FAILED: <file> exited <rc>, so the
assertion count below is not a measurement.` and sets `fail=1` outside the claim machinery
entirely, so nothing about skips or unverifiability can reach it. Probed three ways, including
the one the brief asked for specifically:

- **The swallow test, one suite that BOTH skips AND exits non-zero** (emits `SKIP - b`,
  `ok - c`, then `exit 3`), with an honest README so the count claim reports `ok`: output is
  `SUITE FAILED: tests/skippy.test.sh exited 3`, **exit 1**. The skip it emitted excused nothing.
- **Same suite, count also mismatched** (documented 9 vs measured 2): the count claim reports
  `UNVERIFIED` as designed AND the run still ends **exit 1** on the suite failure. The two
  outcomes coexist and the fatal one wins, which is the ordering that matters.
- **A suite that emits nothing at all and exits 1**, no skip anywhere: `SUITE FAILED` + exit 1.

Round 8's measurement was the inverse of this (exit 0 + a green summary for the same broken
suite), so the regression it named is gone at its own reproduction.

**2. The summary no longer outlives the run, and the clean line kept its meaning.** Measured on
four runs, both directions, because a line that is never wrong in one direction is how this class
hides:

- skip present, count mismatched -> `docs-claims-check: every claim this run could measure
  matches; 1 UNVERIFIED (see above).`, exit 0.
- no skip, everything measured and matching -> `docs-claims-check: every countable claim matches
  the tree.`, exit 0. The unqualified sentence still exists and still means what it says, so it
  has not degraded into a line readers learn to skip.
- skip present but the count matched -> the plain clean line, exit 0 (see the carried nitpick).
- the real repo at this head -> 24 / 33 / 24, `ok: assertions = 1129`, the `note:` block, no
  `SUITE FAILED` line anywhere in 33 suites, and the plain clean summary, exit 0.

The header's exit table at `:18-20` now names the third outcome and names the suite failure as a
cause of exit 1, which was the documentation half of the same finding.

**Canary, run not trusted.** HEAD's suite against `5972c27`'s script in a copy of this tree ->
exactly **3 FAILURES**, and they are the right three: `a broken suite passed as an unverified
count`, `it failed without naming the broken suite`, and `the summary claims everything matches
while a claim went unverified`. The fourth new assertion (a fully measured run still says every
claim matches) passes on both versions, correctly, because it is a regression guard on behaviour
the fix had to preserve rather than change. The builder's claimed canary reproduces exactly.

## Findings

### Critical

None.

### Important

**`bin/docs-claims-check.sh:150-153`. The FATAL summary was not given the same treatment as the
clean one, so a run that failed only because a suite broke still tells the reader "a documented
claim no longer matches the tree" and "Fix the NUMBER in the document, never this check".**
Measured, in the swallow probe above: the README was correct (the count claim printed `ok`), the
only defect was a suite exiting 3, and the run's last two lines instruct the reader to edit a
correct document. That is round 7's harm shape (a correct README plus an instruction to change
it) reached through the branch this commit made reachable. In a repo operated by agents, the
trailing instruction is the one that gets acted on.

Calibrated honestly, because it is the bottom of this tier: the VERDICT is right (red is
correct), and the true diagnosis is printed six lines above with the file name and the sentence
"so the assertion count below is not a measurement", which is a real mitigation the round-7 and
round-8 defects did not have. The footer is also partly pre-existing: it has always been generic
and it reads correctly for the drift and MISSING causes. What is new is a cause for which its
remediation is actively wrong. It is filed as Important rather than as a nitpick for consistency
with round 8, where the mirror-image sentence on the green path was scored Important on the same
reasoning, and because the fix is four lines: count suite failures alongside `fail`, and when
that count is non-zero say `a suite failed to run; fix the suite, not the document` (keeping the
drift remediation for the drift and MISSING causes). The comment the builder wrote at `:155-157`
("THE SUMMARY MUST NOT OUTLIVE THE RUN IT SUMMARISES") is exactly the principle this branch is
still missing; the finding is that the principle was applied to one of the two summaries.

### Nitpicks

One new observation, two carried from round 8, six carried from earlier rounds on files that have
not moved since `994ede8`. None weakens a claim.

- **NEW, carried by design rather than by oversight. `UNVERIFIED` keys on MISMATCH, not on
  measurability.** A partial run whose count happens to match prints the unqualified `every
  countable claim matches the tree`, which is what this repo's own real run does today: 1129
  matched with one case skipped. Strictly, a partial measurement that agrees is not verification
  either. The tradeoff is real and points the other way: reporting it would print an advisory on
  every run on every machine that skips anything, i.e. always, which is the noise the builder
  deliberately protected against in case 7's second half. Recorded so the choice is visible and
  deliberate, not as a change request.
- Carried, still open. **R2 from round 7: nothing pins the note's CAUSES.** Checked at this head:
  case 4 asserts only the substring `1 check(s) were SKIPPED`, and no assertion anywhere touches
  the words `tool` or `shell`, so the note can silently re-narrow to the single cause that made
  it false in rounds 6 and 7. The outcome half of R2 is closed and now doubly so (cases 5, 6 and
  7 all assert exit codes and words the reader acts on). Cheap mechanism, unchanged across three
  rounds: assert the note text contains both `tool` and `shell`.
- Carried. `bin/docs-claims-check.sh:122` vs `:123-125`: the cause sentence is still written
  twice, two lines apart, once into `skip_reason` and once into the `note:` echo. They agree
  today. Build it once and print the note from it.
- Carried. `tests/docs-claims-check.test.sh:119-129`: the scoping case is named "while another is
  unverified" but its fixture documents a count that MATCHES, so that run reports `ok`, not
  `UNVERIFIED`. The behaviour is correct (measured in round 8: `999 executables` + `3 assertions`
  gives `DRIFTED` + `UNVERIFIED` + exit 1); the label is wider than the fixture. Documenting
  `3 assertions` there makes the name true.
- Carried. Nothing asserts that `MISSING` stays fatal when a run is unverifiable, though the
  comment at `:48-50` claims it. True by code path; one case buys the guarantee.
- `README.md:171-172`. "counts the `ok` lines one full run reports, so it moves with the machine"
  still pulls two ways; "a run of every suite on this machine" says it once.
- `tests/install-ps1.test.sh:349-351`, `:350` vs `:313-316`, `:288`, `:297`, `:106-107`, `:455`.
  All carried unchanged from rounds 3 and 4 on a file that is byte-identical to `994ede8`: the
  warm-up asserts nothing and discards its exit status, it respells `HOME`/`PATH` instead of
  going through `run_ps1`, the snapshot comment omits the mode column, `find -print` into
  `read -r p` splits a path containing a newline, the `;;` mismatch message names one of two
  causes, and `chmod 644` runs on all four iterations. None was re-measured this round and none
  needed to be; the immobility is recorded above instead.

## Q4 re-checked: can a real drift still go unnoticed forever?

Narrower than in round 8, and now down to one case. A broken suite is no longer excused anywhere
(measured above, including when it also skips), so the "green on a broken instrument" path is
closed. What remains is exactly the accepted trade: on a machine that skips something and whose
suites all pass, a genuine drift in the assertion count reports `UNVERIFIED` and exits 0. That is
still every machine we know of (bash 3.2 always skips the SHELLOPTS case here; a pwsh-less box
skips install-ps1; root skips six), and nothing in the repo runs a zero-skip configuration
(`.github/` holds only templates; nothing in `bin/`, `skills/` or `agents/` invokes the check).

The answer stands: acceptable, and better than the alternative. The failure mode is now a stale
number that the run PRINTS with both values side by side, above a summary line that says how many
claims went unverified, rather than a false red that instructs a reader to corrupt a correct
document. The residual cost is that the count is advisory on every current machine, and the two
cheap ways to buy it back are unchanged: name in the README the reference configuration the
number was measured on, or add `--require-complete` (fail when `n_skipped > 0`) to be run on one
fully capable machine whenever the number is updated.

## Verification (by measurement, on this machine)

- `bash bin/docs-claims-check.sh --assertions` on the real tree at `15b168f` -> `ok: bin
  executables = 24`, `ok: test suites = 33`, `ok: programs with their own suite = 24`, the `note:`
  block, `ok: assertions = 1129`, no `SUITE FAILED` line, `docs-claims-check: every countable
  claim matches the tree.`, exit 0. The README's moved number and its other three claims are
  verified against the tree at this head.
- `bash tests/docs-claims-check.test.sh` -> `all 21 assertions passed` (was 15), including `a
  suite that FAILS makes the run red even when another skipped (exit 1)`, `and the failure names
  the suite that broke`, `and the summary says how many claims went unverified`, `a fully
  measured run still exits 0`, `and still says every claim matches`.
- Canary against `5972c27` in a copy of this tree -> exactly **3 FAILURES**, named above.
- Swallow probe: one suite emitting `SKIP` and exiting 3, honest README -> `SUITE FAILED:
  tests/skippy.test.sh exited 3` + exit 1. With the README also bent (documented 9) -> the same
  red plus `UNVERIFIED` for the count. A silent failing suite (no output, exit 1) -> same red.
- Summary probes, four runs: unqualified clean line on a fully measured matching run; `every
  claim this run could measure matches; 1 UNVERIFIED (see above).` on a skip + mismatch; exit 0
  in both.
- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`. Unchanged count since round 5,
  which is the arithmetic proof that nothing was added or lost across nine commits.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, `the real tree feeds 240 tracked paths into
  the guard`, every tracked path classified, planted-path canary fires. Still 240 at this head.
- `install.ps1` unchanged: empty diff since `cebc0a0`, `shasum 594ed21c...`, last touched by
  `4416477`. `tests/install-ps1.test.sh`, `tests/publish-guard.test.sh`, `install.sh`,
  `.gitattributes`, `INSTALL.md` byte-identical to `994ede8`.
- Note-cause check for R2: `grep` over `tests/docs-claims-check.test.sh` finds no assertion on
  the words `tool` or `shell`; case 4 pins only `1 check(s) were SKIPPED`.
- Em/en dash scan over the added lines of the in-scope diff (`5972c27..HEAD`): clean.

## Scores

correctness 1/2 - both round-8 Importants are genuinely closed and were verified by running, not
by reading: a broken suite is red even when it skips in the same breath, and the summary now
matches the run in both directions with the clean line intact. Held at 1 by the one Important
above: the fatal summary still misdescribes a suite failure as document drift and hands the
reader the remediation that round 7 identified as the actively harmful one. Lower severity than
either predecessor (the verdict is correct and the true diagnosis prints above it), which is
stated in the finding rather than hidden in the score.

security 2/2 - unchanged and clean. Nothing since `cebc0a0` touches `install.ps1`, the quoting
path (`ConvertTo-BashSingleQuoted`) or the sealed harness (`env -i`, redirected HOME, replaced
PATH, no repo, no network). The publish path is whole at 240 of 240 classified tracked paths with
the planted-path canary firing. The new code reads an exit status and prints a filename from a
glob of `tests/`, so it adds no input surface.

performance 2/2 - `docs-claims-check.test.sh` 21 assertions in ~1.5s (the new cases reuse the
miniature-tree pattern, so the suite grew 40% without measurable cost), `install-ps1.test.sh`
38/38 in ~9s, publish-guard instant, the full `--assertions` pass in line with prior rounds. One
extra `rc` read per suite.

readability 2/2 - both new comment blocks state the harm they prevent and name the measurement
that proved it, which is the shape that survives the next editor. `SUITE FAILED: <file> exited
<rc>, so the assertion count below is not a measurement` tells the reader what broke, where, and
why the number under it means nothing, in one line. The duplicated cause sentence stays a nitpick.

testing 2/2 - case 6 builds the mixed tree (one failing suite, one skipping suite) and requires
both the red and the broken suite's NAME, so the test cannot pass on a red for the wrong reason;
case 7 pins BOTH summary lines, which is what stops the clean line from being quietly retired. The
suite went 15 -> 21, its canary against the predecessor reproduces at exactly 3 when run
independently, and the assertions are on outcomes rather than prose. The remaining gaps (the
note's causes, the scoping case's label, MISSING under unverifiability) are nitpicks, scored once
there.

conventions 2/2 - held. The reviewer's fix suggestions were applied as MECHANISMS with tests in
the same commit rather than as another phrasing, the countable claim moved in the same commit as
the code that moved it, English throughout, no em or en dashes, and this record was REGENERATED
at the new head rather than re-dated.

total 11/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS. No Critical, no zero, so this
record clears the merge gate; the one Important is a four-line follow-up, not a blocker.

## Ceiling

12/12 is reachable and was missed by one Important, which is not structural. The Windows
half that cannot be executed here (PowerShell 5.1, UTF-16 `wsl -l -q`, real `wslpath`, native
symlink permission) stays a stated residual in the suite header and in `INSTALL.md`: it bounds
what the suite CLAIMS, so it limits coverage rather than the score. Unlike round 8, nothing this
round needed emulating: every claim in the fixes was reachable on this machine with real runs,
including the swallow case, so the evidence has no reasoned arm.

## What's good

- Both fixes went at the mechanism, not at the message. The suite's exit status is now READ
  rather than the count being second-guessed, which is the decidable question, and the summary is
  DERIVED from a counter rather than being a constant string that happened to be true most of the
  time.
- The failing-suite check sits outside the claim machinery, so no future exemption argument can
  reach it. That is the fail-closed shape: a new outcome would have to opt into being excused.
- Case 7 pins the clean line as well as the qualified one. Most authors would have tested only
  the new behaviour, and the line that then rots is the old one; testing both directions is why
  "the summary became noise" cannot happen quietly here.
- The commit comment records the harm in the past tense with its measurement ("a suite that
  ERRORS reports fewer `ok` lines, the mismatch is excused as unverified, and the run ends GREEN
  on every machine that skips anything, which here is every machine"), so the next editor who is
  tempted to simplify the rc check away can see what it costs.

## History

- 2026-09-16 (`fab5c0d`, claude-opus-5[1m], effort high): round 1. REQUEST CHANGES, 7/12
  (correctness 1, security 2, performance 2, readability 1, testing 1, conventions 0). One
  Critical (`install.ps1` in neither classification list, hard-blocking the publish path), seven
  Important, six nitpicks. No prior record, so no regression comparison.
- 2026-09-16 (`663e63c`, claude-opus-5[1m], effort high): round 2. APPROVE WITH COMMENTS, 9/12.
  Improved, +2: correctness 1 -> 2, conventions 0 -> 1. The Critical and all seven Importants
  addressed, but three findings remained and all three were the SAME class narrowed rather than
  eliminated (a comment claiming more than its mechanism covers).
- 2026-09-16 (`cebc0a0`, subject `4416477`, claude-opus-5[1m], effort high): round 3. APPROVE,
  12/12. **Improved, +3**: readability 1 -> 2, testing 1 -> 2, conventions 1 -> 2; correctness,
  security and performance held at 2. All three round-2 Importants closed by mechanism and
  independently re-measured here, plus two of the four nitpicks. The recurring class (comment
  claims a class, mechanism covers an instance) did not survive this round: each guard now keys
  on a signal it does not itself produce. Five nitpicks remain, none of which weakens a claim.
- 2026-09-17 (`2e7c740`, claude-opus-5[1m], effort high): round 4, a re-anchor after the
  ledger-backup work moved the tree. APPROVE WITH COMMENTS, 11/12. **Worse, -1**: testing
  2 -> 1; the other five held at 2. Two round-3 nitpicks were addressed in scope. The mode
  canary (n1) is fully closed and measured. The `.cache/powershell` prune (n2) is not: on a
  fresh HOME the snapshot still reports six entries pwsh created, because `~/.local/share/
  powershell` and the parent directories are the same host-runtime bookkeeping and are not
  excluded, so case 9b stays green only by case ORDER. The drop is a NEW measurement, not new
  damage: the hazard predates round 3, which recorded it as a nitpick and proposed a fix that
  was itself partial, and the builder applied that fix literally. Round 3's 12/12 was a
  half-point generous in hindsight on the same code path. No Critical, no security or
  correctness movement, `install.ps1` byte-identical since `cebc0a0`.
- 2026-09-17 (`994ede8`, claude-opus-5[1m], effort high): round 5. APPROVE, 12/12.
  **Improved, +1**: testing 1 -> 2; the other five held at 2. The round-4 Important is CLOSED.
  The one-time HOME warm-up landed and was verified against the hazard itself rather than
  against the suite's normal ordering: the suite's own functions were lifted into a probe that
  runs the anti-port comparison as the FIRST pwsh launch, which passes with the warm-up and
  fails without it on exactly the six entries round 4 recorded. The warm-up introduces nothing
  a later case can attribute to `install.ps1` (everything it writes predates the first
  snapshot), and the repo half of the comparison is clean too, which is the part a fresh
  `mkrepo` per case would have hidden. The prune's stated justification re-measured and still
  true. Seven nitpicks stand, four carried from earlier rounds, none weakening a claim; the new
  ones are a drift hazard (the warm-up duplicates `run_ps1`'s sandbox literals and asserts
  nothing) and one sibling-induced wording gap in the skip note, flagged not scored.
- 2026-09-18 (`0125901`, claude-opus-5[1m], effort high): round 6, a gate re-anchor after the
  ledger-backup program moved again. APPROVE, 12/12. **Same, 0**: all six criteria held at 2.
  Nothing regressed. One in-scope change, `README.md` `1016` -> `1027`, verified against the
  tree by `docs-claims-check --assertions` (exit 0, and no `note:` line, so the count was full
  rather than skipped-low). Collateral checks green: `install-ps1.test.sh` 38/38 and
  `publish-guard.test.sh` ALL PASS with the real tree still at 240 classified paths. Both
  re-checked nitpicks stand unchanged: the warm-up still asserts nothing (a misattribution risk,
  not a silent-pass risk, so still a nitpick), and the root-skip accounting gap did NOT grow,
  `tests/ledger-backup.test.sh` carries six `id -u` guards at `994ede8` and six at HEAD, so the
  four new cases (34, 34b, 35, 36) are not root-gated. Round 5's warm-up probes were not re-run
  because the code they measure is byte-identical; the immobility is recorded instead.
- 2026-09-22 (`b3b66f7`, claude-opus-5[1m], effort high): round 7, the first round since round 3
  in which this artifact's own files actually changed. APPROVE WITH COMMENTS, 10/12. **Worse,
  -2**: correctness 2 -> 1, conventions 2 -> 1; security, performance, readability and testing
  held at 2. The round-5/6 skip-note nitpick is PARTLY closed: the note now names all three
  causes present in the tree (censused, not taken from the commit body) and is no longer false
  on an ordinary run, which matters because the case went live here (bash 3.2 refuses SHELLOPTS,
  so `ledger-backup.test.sh:837` skips and the note prints). What it cost: `1053` is now the
  count of a run that SKIPPED, where round 6 could prove `1027` was a full count, and both the
  note and `README.md:171-173` bound the error only downward ("can read LOW"), so a machine that
  runs the skipped branch reads 1055, gets `DRIFTED` + exit 1, and is told by `:117` to edit a
  correct README. Filed as one Important with a single fix (make the assertions claim UNVERIFIED
  rather than fatal whenever `n_skipped > 0`, and say what the documented number counts). Two
  new nitpicks, both the same class one size down: the old single-cause premise survives in the
  third of three copies (`tests/docs-claims-check.test.sh:55-58`, `lessons.md:17`), and nothing
  asserts the note's causes, so the widening is a third phrasing where `CLAUDE.md` asks for a
  mechanism. Collateral green and measured: `install-ps1.test.sh` 38/38 in 9.0s,
  `publish-guard.test.sh` ALL PASS at 240 classified paths, `docs-claims-check.test.sh` 7/7,
  `install.ps1` byte-identical since `4416477`. The second arm of the Important is reasoned, not
  measured: no bash >= 4 and no container runtime on this machine, stated rather than glossed.
- 2026-09-22 (`5972c27`, claude-opus-5[1m], effort high): round 8. APPROVE WITH COMMENTS, 11/12.
  **Improved, +1**: conventions 1 -> 2; correctness held at 1; security, performance, readability
  and testing held at 2. The round-7 Important is CLOSED and verified at its own reproduction: on
  a copy of this tree with the README bent to `1089` against a measured `1090` (the HIGH-counting
  machine's arithmetic), `b3b66f7` returns `DRIFTED` + exit 1 + "Fix the NUMBER in the document"
  while `5972c27` returns `UNVERIFIED` + exit 0, and a mismatch with no skip present still
  returns `DRIFTED` + exit 1. The exemption is scoped: only the assertions claim passes the
  fourth argument, `MISSING` returns before it is consulted, and a run with one claim UNVERIFIED
  and another genuinely drifted exits 1. Suite 7 -> 15 assertions, outcome-based, and its canary
  against `b3b66f7` reproduced at exactly 6 failures when run independently. Residual 1 (the
  stale premise copy) is closed with a whole-tree grep; residual 2 is mostly closed (the outcome
  is pinned, the note's causes still are not, kept as a nitpick). Two new Importants, both the
  new third outcome not yet propagated to the program's edges: after an UNVERIFIED claim the run
  still ends with "every countable claim matches the tree" and the `Exit:` contract at `:18`
  still describes two outcomes, and a suite that EXITS non-zero is now excused as a skip
  (measured with a no-skip control: exit 0 + green summary where the same broken suite used to
  give exit 1). Judgment recorded for the human: the count is now unenforced on every machine
  that skips anything, which today is all of them (no CI, no zero-skip configuration, nothing in
  the repo invokes the check); that is the right trade against a false red that corrupts a
  correct README, and the cheap ways to buy the coverage back are listed above. Collateral green
  and measured: `install-ps1.test.sh` 38/38 in 9.2s, `publish-guard.test.sh` ALL PASS at 240,
  README's other three claims 24 / 33 / 24, `install.ps1` byte-identical since `4416477`.
- 2026-09-22 (`15b168f`, subject `ad00988`, claude-opus-5[1m], effort high): round 9, the final
  anchor. APPROVE WITH COMMENTS, 11/12. **Same, 0**: all six criteria unchanged (correctness 1,
  the other five 2), but the composition moved, both round-8 Importants closed and one new one
  opened at lower severity. Verified by running, not by reading: a suite that BOTH skips and
  exits 3 still produces `SUITE FAILED: tests/skippy.test.sh exited 3` and exit 1 (the swallow
  case the brief asked for), the same red survives when the count claim is simultaneously
  UNVERIFIED, a silent failing suite is red too, and the failing-suite check sits outside the
  claim machinery so no exemption can reach it. Both summary lines pinned and measured: `every
  claim this run could measure matches; 1 UNVERIFIED (see above).` on a skip + mismatch, and the
  unqualified `every countable claim matches the tree.` still printed on a fully measured run, so
  the clean line kept its meaning. Header exit table now names the third outcome. Suite 15 -> 21,
  canary against `5972c27` reproduced at exactly 3 failures, and the 4th new assertion correctly
  passes on both versions because it guards preserved behaviour. New Important, the unfinished
  half of round 8's: the FATAL summary at `:150-153` still says "a documented claim no longer
  matches the tree / Fix the NUMBER in the document" when the only failure is a broken suite, so
  a correct README gets an instruction to change it; lower severity than its predecessors (the
  verdict is right and `SUITE FAILED` prints the true diagnosis above it), four-line fix. R2
  (nothing pins the note's CAUSES) STILL STANDS, checked at this head: no assertion touches the
  words `tool` or `shell`. Q4 re-checked and narrowed: with broken suites no longer excused, the
  only way a real drift goes unnoticed is a skipping machine whose suites all pass, which is
  still every machine, still the right trade, and still printed with both numbers side by side.
  Collateral green and measured across nine commits of sibling churn: `install-ps1.test.sh`
  38/38, `publish-guard.test.sh` ALL PASS at 240 tracked paths, real tree 24 / 33 / 24 /
  `assertions = 1129` with no `SUITE FAILED` line, `install.ps1` byte-identical since `4416477`.
</content>
