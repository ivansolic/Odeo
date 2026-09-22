---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 5972c27
artifact_version: 8
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 10/12
---

## Artifact

Round 8, at `5972c27`. Same artifact scope as rounds 1 to 7. Inside this artifact the commit
touched exactly three files, `bin/docs-claims-check.sh`, `tests/docs-claims-check.test.sh` and
`README.md`, and it is the fix for round 7's single Important. The rest of `5972c27`
(`bin/ledger-backup.sh`, `tests/ledger-backup.test.sh`, `docs/system-map.md`,
`skills/retro/SKILL.md`) is the sibling ledger-backup program, scored in
`docs/evals/code-ledger-backup.md`; it was read here only where it feeds this artifact's skip
accounting, and is not re-scored.

Immobility, measured rather than assumed: `git diff cebc0a0..HEAD -- install.ps1` is empty,
`shasum install.ps1` is still `594ed21c9287a7708a953f5b50d53289f408253b`, last touching commit
`4416477`. `git diff 994ede8..HEAD --stat` over `tests/install-ps1.test.sh`,
`tests/publish-guard.test.sh`, `install.sh`, `.gitattributes` and `INSTALL.md` is empty, so all
of those are byte-identical to the round-5 head and rounds 1 to 7's findings on them carry
forward unchanged. No plan exists in `docs/plans/` for this branch, so there is no contract to
compare against. Working tree at review time: only `docs/evals/skill-build.md` and
`docs/evals/skill-retro.md` modified (sibling records being regenerated in parallel); every
non-evals path is clean at `5972c27`.

## The round-7 Important: closed, and measured on both arms

Round 7 said the claims check bounded its own error in ONE direction: the note excused a count
reading LOW, the comparison failed any mismatch, so a machine that ran MORE of the suite than
the author's counted HIGH, got `DRIFTED`, exit 1, and the instruction "Fix the NUMBER in the
document, never this check", i.e. it was told to edit a correct README.

**1. The UNVERIFIED path works, and it does not swallow a real drift.** Probed on a miniature
tree with a positive control first (`lessons.md:15`): documented 2 == measured 2 with one skip
prints `ok: assertions = 2`, exit 0, so the instrument reports a match as a match. Bend the
document to 5 and the same run prints `UNVERIFIED: assertions , README says 5, this run measured
2`, the reason, "Do not edit either one from this run", exit 0, and the word `DRIFTED` never
appears. Remove the skip from that same tree and a mismatch goes straight back to `DRIFTED` +
exit 1 (control D below), so the exemption is keyed on the skip and on nothing else.

**2. The machine that counts HIGH, on the real tree, before and after.** Constructed the exact
situation round 7 described, on a full copy of this repo at `5972c27` with the README bent to
`1089` while the tree measures `1090` (documented < measured is arithmetically the same branch a
bash-5 machine reaches by running the SHELLOPTS case this one skips; stated as the emulation it
is, because this machine still has no bash >= 4 and no container runtime). Same fixture, two
scripts:

- `b3b66f7` (pre-fix): `DRIFTED: assertions , README says 1089, the tree has 1090` /
  `docs-claims-check: a documented claim no longer matches the tree.` / `Fix the NUMBER in the
  document, never this check` / **exit 1**.
- `5972c27` (HEAD): `UNVERIFIED: assertions , README says 1089, this run measured 1090` + the
  reason + `Do not edit either one from this run.` / **exit 0**, no `DRIFTED`.

The harm named in round 7 is gone at its own reproduction.

**3. The exemption is correctly SCOPED, measured two ways.** Only the assertions claim is passed
a fourth argument (`:124`); the three deterministic claims are called with three
(`:80`, `:81`, `:90`), so `unverifiable` is empty for them and they take the `DRIFTED` branch.
Built the case the suite does not build, one claim unverifiable AND another genuinely drifted at
the same time (README `999 executables` + `3 assertions`, tree 1 and 2, one skip): output is
`DRIFTED: bin executables` plus `UNVERIFIED: assertions`, **exit 1**. One skipped case does not
switch off the claims this run can measure completely. `MISSING` also stays fatal by
construction: the empty-`documented` branch at `:54-59` returns before `unverifiable` is ever
consulted.

**4. Can a real drift in the assertion count now go unnoticed forever?** Yes, on any machine
that skips anything, and today that is every machine we know of. This one always skips
(bash 3.2 refuses `SHELLOPTS`, so `ledger-backup.test.sh:865` skips on every run); a Linux box
without pwsh skips the install-ps1 cases (`tests/install-ps1.test.sh:40` emits `SKIP` per case,
so those DO increment the counter, checked); a root container skips six more. A zero-skip
machine needs pwsh AND non-root AND bash >= 4 simultaneously, and nothing in this repo runs one:
`.github/` carries only issue and PR templates, and no script, skill or agent invokes
`docs-claims-check.sh` at all (`grep -rln` over `bin skills agents global project-templates
.github .claude` returns only `.claude/tasks/todo.md`). So in practice `1090` is now an
unenforced number everywhere.

Is that acceptable? **Yes, as the lesser evil, and the tradeoff should be stated where the human
can see it rather than only in a comment.** A false red corrupts the document for everyone: it
instructs a reader to edit a correct README and hands the next machine a wrong number. A missed
drift leaves a stale number that is still PRINTED, with both values side by side, on every run.
What it costs: the claim that historically rotted in this repo (README once said 31 assertions
when there were 818) no longer has a failing mechanism, only an advisory line, and the advisory
is currently contradicted by the run's own last line (Important 1 below). Cheap ways to buy the
coverage back, in ascending cost: fail on a suite that EXITS non-zero (Important 2, decidable
and unrelated to skips); name the reference configuration the documented number was measured on,
so a second machine can reproduce it exactly; or add `--require-complete`, which fails when
`n_skipped > 0`, to be run on one fully capable machine whenever the number is updated.

## Findings

### Critical

None.

### Important

**1. `bin/docs-claims-check.sh:142` and the exit contract at `:18`. After an UNVERIFIED claim the
run still ends with "every countable claim matches the tree" and exit 0, which is false, and it
is the only line a reader who scrolls to the bottom sees.** Measured, not reasoned: in probe B
above the output is `UNVERIFIED: assertions , README says 5, this run measured 2` followed four
lines later by `docs-claims-check: every countable claim matches the tree.` and `EXIT=0`. The
same pair prints on the real tree in the round-7 reproduction. The file's own usage block still
says `Exit: 0 every claim matches · 1 a claim drifted, or an expected claim is missing`, which
has been a two-outcome contract since before this commit introduced a third outcome. This is
`lessons.md`'s 2026-09-16 rule ("name above a guard only what the guard actually covers") one
level out: the summary names a class the mechanism no longer delivers, and it does it in the one
file whose entire subject is documents claiming more than the tree supports. Fix, small and
local: count unverified claims alongside `fail`, end with `every claim this run could measure
matches the tree; N claim(s) UNVERIFIED above` when that count is non-zero (exit stays 0, which
is the right call), and add the third outcome to the `Exit:` line at `:18`.

**2. `bin/docs-claims-check.sh:95-101`. A suite that ERRORS OUT is now excused as a skip on any
machine that skips anything, where before this commit it was loud.** `out=$(bash "$f" 2>&1)`
discards the suite's exit status, so a suite that dies after emitting no `ok` lines is
indistinguishable from a shrunken count. Measured, with a control: mini tree, honest README at
2, one skipped case, and `tests/foo.test.sh` replaced by `exit 1` gives `UNVERIFIED` + **exit 0**
+ `every countable claim matches the tree`; the identical broken suite with the skip removed
gives `DRIFTED` + **exit 1**. Pre-fix, the first case also exited 1 (mislabelled as drift, but
red). So this commit converted a loud red into a green for the broken-instrument case, on
exactly the machine the repo is developed on. A skip is a case declining to run; a non-zero exit
is an instrument that broke, and the two are not the same evidence. Fix: capture `rc=$?` per
suite in the loop, and on non-zero print `SUITE FAILED: $f (exit $rc)` and set `fail=1`
regardless of `n_skipped`. That is decidable, needs no bash 5, and restores the red the
exemption removed without re-opening the false-drift class.

### Nitpicks

Two new from this commit, two carried from round 7 (one of them now half-closed), six carried
from earlier rounds on files that have not moved since `994ede8`. None weakens a claim.

- **NEW. `bin/docs-claims-check.sh:119` vs `:120-122`.** The cause sentence is now written
  twice, two lines apart: once into `skip_reason` for the UNVERIFIED body, once into the `note:`
  echo. They agree today. This is the same "one premise, N copies" shape that produced round 7's
  stale third copy, created in the commit that fixed it. Fix: build the sentence once
  (`skip_reason="..."`) and print the note from it, so there is one string and no way for the two
  to disagree.
- **NEW. `tests/docs-claims-check.test.sh:119-129`.** The scoping case is named "a claim that CAN
  be measured still fails while another is unverified", but its fixture documents `2 assertions`
  against a measured 2, so the assertions claim in that run reports `ok`, not `UNVERIFIED`. The
  co-occurrence the name claims is never built. The behaviour is in fact correct, I measured it
  above (`999 executables` + `3 assertions` -> `DRIFTED` + `UNVERIFIED` + exit 1), which makes
  this a label wider than its fixture rather than a hole, i.e. `lessons.md` 2026-09-16 again.
  One-character fix: document `3 assertions` in that fixture and the case name becomes true.
- Carried, now HALF-closed. Nothing pins what the note SAYS. Case 5 pins the OUTCOME in both
  directions, which was the important half and is the right shape (the previous version passed
  while the harm was live precisely because only prose was covered). But the wording can still
  re-narrow to a single cause silently, which is how round 6 and round 7 got here. Cheap
  mechanism, unchanged from round 7: assert the note text contains both `tool` and `shell`.
- Carried. Nothing asserts that `MISSING` stays fatal when a run is unverifiable, though the new
  comment at `:48-50` claims it. It is true by code path, and one case buys the guarantee: a
  README with no assertions claim, `--assertions`, one skip, expect exit 1.
- `README.md:171-172`. "counts the `ok` lines one full run reports, so it moves with the machine"
  pulls two ways in one sentence: "full run" reads as "nothing skipped", which is exactly what
  this number is not. Say "a run of every suite on this machine".
- `tests/install-ps1.test.sh:349-351`. Carried. The warm-up's exit status is discarded and it
  produces no assertion; if it ever no-ops, case 9b reverts to round-4 behaviour and misattributes
  pwsh's own bookkeeping to `install.ps1`. Loud red with the wrong name on it, not a silent pass.
- `tests/install-ps1.test.sh:350` vs `:313-316`. Carried. The warm-up respells `HOME` and `PATH`
  instead of going through `run_ps1`, so repointing `run_ps1`'s HOME warms the wrong directory.
- `tests/install-ps1.test.sh:288`. Carried from round 4. The comment omits the mode column `:303`
  records.
- `tests/install-ps1.test.sh:297`. Carried from round 3. `find -print` into `read -r p` splits a
  path containing a newline; `-print0` plus `read -r -d ''` costs one line.
- `tests/install-ps1.test.sh:106-107`. Carried from round 3. A `;;` count disagreement caused by a
  `;;` inside an arm body sends the reader after a missing arm that does not exist.
- `tests/install-ps1.test.sh:455`. Carried from round 4. `chmod 644` runs on all four iterations
  though only one dirties the probe. Harmless.

## Verification (by measurement, on this machine)

- `bash bin/docs-claims-check.sh --assertions` on the real tree -> `ok: bin executables = 24`,
  `ok: test suites = 33`, `ok: programs with their own suite = 24`, the `note: 1 check(s) were
  SKIPPED` block now reading "LOW or HIGH", `ok: assertions = 1090`, exit 0. The README's number
  and its other three claims are verified against the tree at this head.
- `bash tests/docs-claims-check.test.sh` -> `all 15 assertions passed`, 1.4s (was 7). The six new
  ones are the two directions x (exit 0, UNVERIFIED present, DRIFTED absent), plus the two
  scoping assertions.
- Canary, run rather than trusted: HEAD's suite against `b3b66f7`'s script in a copy of this tree
  -> exactly **6 FAILURES**, all six in case 5 (`an unmeasurable count exited 1, telling the
  reader to edit a correct README (high)` and its low twin, etc.), the other nine green. The
  builder's claimed canary reproduces exactly. Note what it also shows: the two scoping
  assertions pass on BOTH versions, so they pin an invariant against a future over-broad
  exemption rather than attributing this change, which is what their comment says they do.
- Real-tree before/after on the HIGH-counting fixture (README `1089`, tree `1090`, one skip):
  `b3b66f7` -> `DRIFTED` + exit 1 + "Fix the NUMBER in the document"; `5972c27` -> `UNVERIFIED` +
  exit 0. Both arms run on the same copied tree, full `--assertions` pass each.
- Scoping probe -> `DRIFTED: bin executables` and `UNVERIFIED: assertions` in one run, exit 1.
- Broken-suite probe (C) and its no-skip control (D) -> exit 0 + green summary vs exit 1 +
  `DRIFTED`. This is Important 2's evidence, and D is the positive control that proves the probe
  can produce a red at all.
- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`, 9.2s. Collateral, unchanged
  count from rounds 5 to 7, which is the arithmetic proof that nothing was added or lost.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, including `the real tree feeds 240 tracked
  paths into the guard`, `every tracked path in the real tree is classified public or internal`,
  and the planted-path canary. Still 240: this commit added and removed no files.
- `install.ps1` unchanged: empty diff since `cebc0a0`, `shasum 594ed21c...`, last touched by
  `4416477`. `tests/install-ps1.test.sh`, `tests/publish-guard.test.sh`, `install.sh`,
  `.gitattributes`, `INSTALL.md` byte-identical to `994ede8`.
- SKIP census re-run at this head: `tests/install-ps1.test.sh:40` (`skip()` helper, per case),
  six root guards at `ledger-backup.test.sh:405,480,499,540,565,592`, and the SHELLOPTS refusal
  at `:865`. Checked specifically that `install-ps1.test.sh:581`'s summary line ("install-ps1: N
  check(s) SKIPPED") is NOT what the counter reads, because it does not start at column 0; the
  per-case `SKIP - ` lines from `:40` are, so a pwsh-less machine does increment `n_skipped` and
  is covered by the exemption. That was the one way this fix could have had a hole in its most
  common configuration, and it does not.
- Em/en dash scan over the added lines of the in-scope diff (`b3b66f7..HEAD` on `README.md`,
  `bin/docs-claims-check.sh`, `tests/docs-claims-check.test.sh`): clean.
- Round 5's warm-up probes and round 6's order-independence measurements were NOT re-run: the
  files they measure are byte-identical to `994ede8`, and the immobility is recorded above
  instead.

## Round 7's residuals

- **Residual 1, the stale premise at `tests/docs-claims-check.test.sh:55-58`: CLOSED.** The
  header now names all three causes ("install-ps1.test.sh without pwsh, a root guard, a shell
  that refuses SHELLOPTS") and describes the harm in the direction-neutral form ("a machine that
  ran a different amount of the suite"). Grepped the tracked tree rather than the file I was
  pointed at: no copy of the single-cause premise survives outside `docs/evals/`.
- **Residual 2, nothing asserted the note's behaviour: mostly CLOSED.** Case 5 asserts the
  OUTCOME (exit code, `UNVERIFIED` present, `DRIFTED` absent) in both directions plus the scoping
  pair, and it is canary-proven to redden 6 times against the predecessor. What still stands is
  the narrower half: nothing pins the note's CAUSES, so the wording can re-narrow silently. Kept
  as a nitpick with the same one-line mechanism.
- **Residual 3, the Important (one-directional bound): CLOSED**, verified on both arms at the
  real tree, with the exemption scoped correctly. It is replaced, at lower severity, by the two
  Importants above: the run's final sentence does not yet know about the third outcome it can
  now produce, and the exemption currently also covers a case that is not a skip at all.

## Scores

correctness 1/2 - the round-7 defect is genuinely fixed, at its own reproduction, in both
directions, with the exemption scoped to the one claim that cannot be measured completely and
`MISSING` still fatal. Held back by the two Importants, both measured with controls: after an
UNVERIFIED claim the run's last line still says every countable claim matches the tree, and a
suite that exits non-zero is now excused as if it had skipped, which is a red this commit
converted into a green on the repo's own development machine. Neither is the old class returning;
both are the new outcome not yet propagated to the edges of the program.

security 2/2 - unchanged and clean. Nothing in `b3b66f7..HEAD` touches `install.ps1`, the quoting
path (`ConvertTo-BashSingleQuoted`) or the sealed harness (`env -i`, redirected HOME, replaced
PATH, no repo, no network). The publish path is whole: 240 of 240 tracked paths classify and the
planted-path canary fires. The new fourth argument is an internal string built from a counter,
never from a document or an environment value, so widening `claim()`'s interface opened nothing.

performance 2/2 - `docs-claims-check.test.sh` 1.4s for 15 assertions (the new case reuses the
miniature-tree pattern rather than the repo, which is why it doubled in size without costing
time), `install-ps1.test.sh` 9.2s, publish-guard instant, the full `--assertions` pass in line
with prior rounds. The exemption adds one string assignment.

readability 2/2 - the comment above `claim()` records WHY the fourth argument exists in terms of
the harm it prevents, including what the old asymmetry did, which is the shape that stops the
next editor from innocently "simplifying" it back. Case 5's header states the rule under test and
why it is asserted on the outcome rather than the prose. The duplicated cause sentence and the
README's "one full run" wobble are nitpicks, not enough to pull this to 1.

testing 2/2 - this is the round's strongest part. The suite went 7 -> 15, the new assertions are
on OUTCOMES (exit code and the words the reader acts on), both directions are built, the
scoping invariant is pinned separately, and the canary against the predecessor reproduces at
exactly 6 failures when I ran it myself. `install-ps1.test.sh` is 38/38 with case 9b still
order-independent and canaried, `publish-guard.test.sh` still pins the real tree at 240. The
label-wider-than-fixture in the scoping case is a naming defect over correct behaviour, scored as
a nitpick.

conventions 2/2 - recovered from round 7. Both violations that cost the point are addressed: the
whole repository was grepped for the old premise this time (the third copy is fixed and no fourth
survives), and the recurring lesson finally received a MECHANISM at the point of use rather than
a fourth phrasing, which is exactly what `CLAUDE.md`'s "When a written lesson repeats" asks for.
The countable claim moved in the same commit as the code that caused it, English throughout, no
em or en dashes, and this record was REGENERATED at the new head rather than re-dated.

total 11/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

## Ceiling

12/12 is reachable and was missed by two Importants, neither of which is structural. Nothing
about this change caps a criterion. The Windows-unverifiable half (PowerShell 5.1, UTF-16
`wsl -l -q`, real `wslpath`, native symlink permission) stays a stated residual in the suite
header and in `INSTALL.md`, which is how this repo accepts an unrunnable platform: it bounds what
the suite CLAIMS, so it limits coverage, not the score. The one thing genuinely outside reach on
this machine is a real bash >= 4 run (no bash >= 4, no container runtime), so the HIGH-counting
machine was reproduced by bending the document instead of the shell; that limits the FORM of the
evidence, not its conclusion, since both routes enter the same branch, and it is labelled as an
emulation above rather than glossed.

## What's good

- The fix went at the decidable thing. The tempting fix was a cleverer heuristic (bound the
  drift, guess the skipped case's assertion count, tolerate a delta). The builder instead
  recognised that an incomplete measurement is not evidence in either direction and stopped
  treating it as such, which eliminates the class rather than trading one failure shape for
  another. That is `CLAUDE.md`'s "stop patching a recurring class" applied without being told.
- The exemption is narrow by construction, not by care: it is an argument only the assertions
  claim passes, so a future claim is fatal by default and has to opt out explicitly. Defaults
  that fail closed are worth more than the test that checks them, and the test is there too.
- Case 5 asserts what the READER experiences (exit code, the word UNVERIFIED, the absence of
  DRIFTED) rather than the sentence the code prints, and its header says why that distinction
  matters: the previous version passed a prose assertion while the harm was live. The canary
  count in the commit body reproduced exactly when I ran it independently.
- The README stopped claiming a property the number does not have. It now says what the number
  counts, that it moves with the machine, in which direction, and what the checker does about it,
  which turns a number that read as a constant into one that reads as a measurement.

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
</content>
