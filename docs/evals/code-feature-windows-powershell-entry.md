---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: b3b66f7
artifact_version: 7
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 10/12
verdict: APPROVE WITH COMMENTS
previous_total: 12/12
---

## Artifact

Round 7, at `b3b66f7`. Same artifact scope as rounds 1 to 6. Like round 6 this exists for a gate
reason (every record on the branch must cover the commit being merged), but unlike round 6 the
commit moved something REAL inside this artifact: `b3b66f7` touched `bin/docs-claims-check.sh`
and `README.md`, both of which this record owns, and the change it made is the one rounds 5 and
6 asked for.

`git diff --stat 0125901..HEAD` over the scope lists exactly those two files. `install.ps1`,
`install.sh`, `.gitattributes`, `INSTALL.md`, the language-allowlist suite, the
community-refresh suite and the publish-guard suite are byte-identical to `cebc0a0`;
`install.ps1` itself has not moved since `4416477` (sha `594ed21c...`). `tests/install-ps1.test.sh`
is byte-identical to `994ede8`. So rounds 1 to 6's findings on those files carry forward
unchanged and were not re-litigated. The rest of `b3b66f7` (`bin/ledger-backup.sh`,
`tests/ledger-backup.test.sh`) is the sibling ledger-backup program, scored in
`docs/evals/code-ledger-backup.md`, which is still sitting at `0125901` with REQUEST CHANGES
6/12 and needs its own round before this branch can merge. It is not re-scored here; it was
read only where it feeds this artifact's skip accounting. No plan exists in `docs/plans/` for
this branch, so there is no contract to compare against.

## The change, verified against the tree

**The note.** `bin/docs-claims-check.sh:98-101` used to print one cause, "an optional tool is
missing". It now prints three: an optional tool is missing, the case cannot run as this user, or
this shell refuses what it needs. All three are real and were counted, not taken from the commit
body: `grep -nE '^\s*(echo|printf).*SKIP' tests/*.test.sh` returns nine emitters, and every one
of them falls into one of the three (one pwsh gate in `install-ps1.test.sh:40`, six `running as
root` guards in `ledger-backup.test.sh:405,480,499,540,565,592`, one SHELLOPTS refusal at
`:849`; the tenth hit, `docs-claims-check.test.sh:65`, is a fixture). There is no fourth cause
in the tree that the note fails to name.

**It went live, exactly as rounds 5 and 6 predicted.** This is no longer theoretical about root
containers. Measured here: `bash --version` is 3.2.57, `SHELLOPTS=allexport bash -c 'echo
$SHELLOPTS'` prints `braceexpand:hashall:interactive-comments` and the error `SHELLOPTS:
readonly variable`, so `ledger-backup.test.sh:837`'s guard is false on this machine and the case
skips. `bash bin/docs-claims-check.sh --assertions` therefore prints `note: 1 check(s) were
SKIPPED here` on an ordinary run of this repo. Under the old wording that note would have read
"an optional tool is missing", which is false: nothing is missing, the shell refused. The
builder fixed a live falsehood, not a hypothetical one.

**The README.** `README.md:169-173` moved `1027` -> `1053` and rewrote the sentence to match the
note. Verified against the TREE: `--assertions` returns `ok: assertions = 1053`, plus `ok: bin
executables = 24`, `ok: test suites = 33`, `ok: programs with their own suite = 24`, exit 0,
`every countable claim matches the tree`.

## Findings

### Critical

None.

### Important

**`README.md:169`+`README.md:171-173` and `bin/docs-claims-check.sh:98-101`. The documented
number is now taken from a run that SKIPPED, and both the note and the README bound the error in
one direction only.** Round 6 verified `1027` the strong way: no `note:` line printed, therefore
nothing was skipped, therefore `1027` was a FULL count and every other machine could only read
LOW, which is precisely what the note excuses. That property is gone. At this head the note DOES
print on the reference machine, so `1053` is the count of a run with one case unrun.
`tests/ledger-backup.test.sh` reports `all 140 assertions passed` with the SKIP line, and the
guarded branch at `:837-848` contains two `ok` calls (`under allexport the caller's index is
still byte-identical`, `and the backup still ran (exit 0)`). So the number is 1053 here and 1055
wherever that branch runs, and `1053` is neither a maximum nor a minimum, it is one machine's
reading.

The consequence is a false verdict with actively wrong remediation. A machine whose shell
imports SHELLOPTS gets `DRIFTED: assertions , README says 1053, the tree has 1055`, exit 1, and
then `bin/docs-claims-check.sh:117`: "Fix the NUMBER in the document, never this check". The
note above it says only that the count "can read LOW on this machine without the README being
wrong", which does not cover reading HIGH, so the reader follows the instruction, edits the
README to 1055, and breaks it on the author's machine. That is the exact confusion the note
exists to prevent, one direction over.

Honesty about the instrument, per `lessons.md:15` and `:19`: the macOS side is MEASURED (skip
fires, note prints, 1053, 140). The other side is NOT, because this machine has no bash >= 4 and
no container runtime, so I could not run the branch. The finding does not rest on that
measurement, because it forks and both arms land in the same place: either some shell runs the
branch, in which case `1053` is wrong there and the note misdirects, or NO shell anywhere runs
it, in which case `ledger-backup.test.sh:837-848` is unreachable everywhere and the repo carries
a permanent SKIP note plus two assertions that can never execute, which is the builder's own
stated objection ("a test that cannot fail is decoration that reads like a guard") one level out.

Fix, and it is one change, not two: when `n_skipped > 0`, the assertions claim must stop being a
pass/fail comparison, because the checker KNOWS its own number is partial and says so two lines
earlier. Report it as `UNVERIFIED: assertions , README says N, this machine ran M (K check(s)
skipped)` and do not set `fail` for that claim; leave the three deterministic claims fatal as
they are. Then say in `README.md:171-173` what the number is a count OF (a machine where nothing
skipped), so the documented value has one defined meaning instead of one per machine. Do not fix
this by making the skipped case emit its two `ok` lines unconditionally; that is the decoration
the builder correctly refused.

### Nitpicks

Seven carried from round 6, plus two from this commit. None weakens a claim.

- **NEW. `tests/docs-claims-check.test.sh:55-58`.** The old single-cause premise survives in a
  third copy: "a machine missing an optional tool reads as a drifted README, which sends the
  reader to fix a document that is correct." `grep -rn "optional tool"` over the tracked tree
  returns exactly three non-evals hits, and this commit updated two of them. This is
  `lessons.md:17` verbatim ("grep the ENTIRE repository for the old premise, not the file I was
  pointed at"). Fix: widen the header comment to the same three causes the note now names, or
  point it at the note rather than restating it.
- **NEW. Nothing pins the note's causes.** `tests/docs-claims-check.test.sh:73-80` asserts that
  the note FIRES when something skipped and stays QUIET when nothing did, which is the right
  behavioural pair and it is green. But no assertion touches what the note SAYS, so the wording
  can narrow again silently, and it just demonstrated that it can: the third copy above drifted
  in the same commit that widened the other two. `CLAUDE.md`'s own rule for this
  ("When a written lesson repeats") says a nitpick that recurs needs a MECHANISM at the point of
  use, not a third phrasing, and this round received a third phrasing. A cheap mechanism exists:
  assert that the note names more than one cause (e.g. that it contains both `tool` and
  `shell`), which is far less brittle than pinning the sentence and would have caught the stale
  copy.
- `tests/install-ps1.test.sh:349-351`. Carried. The warm-up is the one mechanism in this file
  that can fail without saying so: its exit status is discarded and it produces no assertion,
  while every other instrument refuses loudly or carries a canary. If it ever no-ops, case 9b
  reverts to round-4 behaviour and prints `install.ps1 modified the filesystem itself`, which is
  the misattribution the warm-up exists to prevent. Still a nitpick and not an Important because
  the failure mode is a LOUD red with the wrong name on it, not a silent pass. One `ok`/`bad`
  pair fixes it (and moves the suite to 39, the README to 1054).
- `tests/install-ps1.test.sh:350` vs `:313-316`. Carried. The warm-up respells `HOME` and `PATH`
  instead of going through `run_ps1`, so an edit that repoints `run_ps1`'s HOME warms the wrong
  directory and silently restores the ordering dependency. Warming THROUGH the helper kills this
  and the previous nitpick together, and also closes the residual in the comment's "every
  directory at once, present and future" (the warm-up launches `-Command exit`, every case
  launches `-File install.ps1`).
- `tests/install-ps1.test.sh:288`. Carried from round 4. "Links are recorded by TARGET,
  directories by name, files by hash" still omits the mode column `:303` records. Add the word.
- `tests/install-ps1.test.sh:297`. Carried from round 3. `find -print` into `while IFS= read -r
  p` splits a path containing a newline. `-print0` plus `read -r -d ''` costs one line.
- `tests/install-ps1.test.sh:106-107`. Carried from round 3. When the `;;` count disagrees
  because an arm BODY contains `;;` inside a string, the message sends the reader after a
  missing arm that does not exist. Name both causes.
- `tests/install-ps1.test.sh:455`. Carried from round 4. `chmod 644 "$TMP/home/mode-probe"` runs
  on all four iterations though only one dirties it. Harmless, arguably the safer shape.

## Verification (by measurement, on this machine)

- `bash bin/docs-claims-check.sh --assertions` -> 24 / 33 / 24 / `assertions = 1053`, exit 0,
  `every countable claim matches the tree`, 2m22s, with `note: 1 check(s) were SKIPPED here`
  printed. The note's presence is what the Important above rests on.
- `bash tests/docs-claims-check.test.sh` -> `all 7 assertions passed`, including `--assertions
  totals the suites' ok lines (exit 0)`, `and it reports that 1 check was skipped`, `and it stays
  quiet when nothing was skipped`. The note's fire/quiet behaviour is still covered at this head;
  its causes and its direction are not.
- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`, 9.0s. Collateral check asked
  for by the brief: the sibling's larger change did not break this suite, and the count is
  unchanged from rounds 5 and 6, which is the arithmetic proof that nothing was added or lost.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, including `the real tree feeds 240 tracked
  paths into the guard`, `every tracked path in the real tree is classified public or internal`,
  and the planted-path canary. Still 240: `b3b66f7` added and removed no files, only content.
- `install.ps1` unchanged: `git diff cebc0a0..HEAD -- install.ps1` empty, last touching commit
  `4416477`, `shasum` `594ed21c9287a7708a953f5b50d53289f408253b`.
- `bash tests/ledger-backup.test.sh` -> `all 140 assertions passed` with one SKIP line, 24s. Run
  not to re-score the sibling but to establish that 140 (and therefore 1053) is a skipped-low
  count.
- Shell probe: `bash --version` 3.2.57, `SHELLOPTS=allexport bash -c` refused with `SHELLOPTS:
  readonly variable` and allexport not applied. `command -v docker podman colima nix` and
  `/opt/homebrew/bin/bash`, `/usr/local/bin/bash` all absent, which is why the other arm of the
  Important is reasoned rather than measured, and is labelled as such.
- SKIP census across all suites, and `grep -rn "optional tool"` over the tracked tree, as tabled
  above.
- Em/en dash scan over the in-scope diff (`0125901..HEAD` on `README.md` and
  `bin/docs-claims-check.sh`): clean.
- Round 5's warm-up probes and round 6's order-independence measurements were NOT re-run:
  `tests/install-ps1.test.sh` is byte-identical to `994ede8`, so re-running them would be
  redundant work on unchanged text. Their results carry forward and the immobility that licenses
  that is stated above.

## Is the round-5/6 note nitpick closed?

**Partly.** The part that mattered is closed and was closed properly: the note is no longer
FALSE. It named one cause, the tree has three, and it now names three, verified against a census
of every SKIP emitter rather than against the commit message. A reader who sees the note on this
repo is no longer sent to install a tool that was never missing.

Three residuals keep it from being fully closed. The old premise survives verbatim in
`tests/docs-claims-check.test.sh:55-58`, the third of three copies. Nothing asserts the causes,
so the widening has no mechanism and can narrow again, which is `CLAUDE.md`'s "a lesson that
recurs has a PLACEMENT problem" applied to a note that has now been discussed in three
consecutive reviews. And fixing the wording surfaced the larger instance of the same class: the
note still names ONE DIRECTION ("can read LOW") for a mismatch that is now possible in both, and
that one is an Important rather than a nitpick because the reference number itself moved onto
the skipped side of the line.

## Scores

correctness 1/2 - `install.ps1` has not moved since `4416477` and the harness not since
`994ede8`, and both collateral suites are green, so nothing in the Windows entry path regressed.
The drop is the claims mechanism this artifact owns: it produces `DRIFTED` plus exit 1 plus
remediation that makes things worse on any machine whose shell runs a case this one skips, and
the number it is compared against is a partial count. That is a wrong verdict from a gate whose
entire purpose is being right about numbers.

security 2/2 - unchanged and clean. Nothing in `0125901..HEAD` touches `install.ps1`, the
quoting path (`ConvertTo-BashSingleQuoted`), or the sealed harness (`env -i`, redirected HOME,
replaced PATH, no repo, no network). The publish path is whole: 240 of 240 tracked paths
classify and the planted-path canary fires, so the sibling's new content opened no leak through
this artifact's guard.

performance 2/2 - install-ps1 9.0s, publish-guard instant, docs-claims-check 2m22s for 33 suites,
all in line with prior rounds. The two-line note costs nothing.

readability 2/2 - the note and the README sentence are both clearer than what they replaced, and
the code comment at `:90-95` does the thing this repo is good at: it records WHY the wording is
plural ("because it used to name one") so the next editor cannot innocently re-narrow it. The
stale third copy is a comment in a test header, nitpick weight, not enough to pull this to 1.

testing 2/2 - held. The suite that owns this behaviour is green and tests behaviour rather than
text (fires when something skipped, silent when nothing did), install-ps1 is 38/38 with the
flagship case 9b still order-independent and still canaried, publish-guard still pins the
real tree. The untested gap (nothing pins the note's causes or its direction) is scored once,
under conventions and the Important, rather than three times.

conventions 1/2 - two documented rules were broken by this commit, and they are the two this
exact nitpick has been circling. `lessons.md:17` says grep the ENTIRE repository for the old
premise before calling a wording fix done; two of three copies were updated. `CLAUDE.md`'s rule
for a recurring written lesson says give it a MECHANISM at the point of use rather than another
phrasing; this round produced another phrasing, and the stale third copy is that rule's
prediction coming true inside the same commit. Everything else is right: the countable claim
moved in the same commit as the assertions that caused it, English throughout, no em or en
dashes, and this record was REGENERATED at the new head rather than re-dated.

total 10/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

## Ceiling

12/12 is reachable; this round did not reach it. Nothing about the change structurally caps a
criterion. The Windows-unverifiable half (PowerShell 5.1, UTF-16 `wsl -l -q`, real `wslpath`,
native symlink permission) stays a stated residual in the suite header and in `INSTALL.md`,
which is how this repo accepts an unrunnable platform: it bounds what the suite CLAIMS, and the
claims are narrowed to match, so it does not cap the score. The one thing genuinely outside
reach on this machine is the second arm of the Important (no bash >= 4, no container runtime);
that limits my EVIDENCE, not the score, and the finding is framed so it holds either way.

## What's good

- The fix went at the right thing. Two rounds running, this record said the note's single stated
  cause was false; the builder did not narrow the note or delete it, it went and counted the
  actual causes and named all three, and wrote into the comment why the list is plural so the
  next editor cannot innocently undo it.
- The SKIP for the SHELLOPTS case is the right call and the commit says why in one sentence: the
  outcome assertion cannot fail on bash 3.2, so it is reported unrun rather than passed. Choosing
  a visible skip over a green line that stands for nothing is the same discipline `lessons.md:14`
  and `:28` were written from, applied without being asked.
- The artifact stayed inert under a substantial sibling change, and that is checkable rather than
  asserted: `install.ps1` byte-identical across three commits, the harness across two, and the
  one assertion a sibling CAN break by touching the tree (240 classified paths) is green.
- Both surviving in-scope defects are the SAME defect at two sizes (a note that describes less
  than its mechanism does), which means one fix shape closes both. That is a much better place
  to be than two unrelated findings.

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
</content>
</invoke>
