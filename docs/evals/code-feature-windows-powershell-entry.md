---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 2e7c740
artifact_version: 4
date: 2026-09-17
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 12/12
---

## Artifact

Round 4, a re-anchor at `2e7c740` after non-evals files moved past the round-3 sha. Same
artifact scope as rounds 1 to 3. Two things inside that scope moved since `cebc0a0`:
`tests/install-ps1.test.sh` (18 lines, closing two of the five round-3 nitpicks) and one
README line (the suite and assertion counts). Everything else in `cebc0a0..2e7c740` belongs
to the ledger-backup program, reviewed separately in `docs/evals/code-ledger-backup.md`; it
is not re-scored here, but it was checked for collateral damage to this artifact and there
is none (see Verification). Scope still excludes `skills/build/SKILL.md`. No plan exists in
`docs/plans/` for this branch, so there is no contract to compare against.

`install.ps1` itself is byte-identical to the round-3 sha. The only movement in this round is
in the harness that guards it.

## What moved, verified one by one

| # | Round-3 nitpick | Status at `2e7c740` |
|---|---|---|
| n1 | the snapshot comment lists `chmod +x` among what the old `-type f` missed, but modes were still invisible | **Closed, by mechanism.** `tests/install-ps1.test.sh:300-303` now records the mode column alongside the hash, and `:426-443` adds a fourth canary shape that flips the exec bit on a file whose BYTES do not change. Reproduced here: `ok - the comparison notices a planted mode (canary: case 9b can fail)`. The bytes are identical and no mtime is recorded, so the mode column is the only thing that can have made the two snapshots differ; the canary means what it says. |
| n2 | `-not -path './.cache/powershell/*'` excludes the children but not the directory itself | **Half closed, see I1.** `:295-296` replaces the `-not -path` with a `-prune` pair, which does exclude the directory entry. It does not close the hazard the nitpick named, because `.cache/powershell` is not the only tree pwsh creates in a fresh HOME. |
| n3 | `find -print` into `read -r` splits a path containing a newline | Not taken. Carried forward. |
| n4 | the arm-count failure message names only one of the two causes | Not taken. Carried forward. |
| n5 | the commit body's "235 paths" versus the code's `>= 50` | Moot, that commit body is history; the tree now feeds 240. |
| README | `32 suites, 932 assertions` -> `33 suites, 1007 assertions` | **Verified against the tree**, not against the diff: `bin/docs-claims-check.sh --assertions` reports `test suites = 33`, `assertions = 1007`, `bin executables = 24`, `programs with their own suite = 24`, all `ok`. The neighbouring `24 of the 24 programs` line is still true: `bin/ledger-backup.sh` already existed at `cebc0a0` and already had a suite. |

## Verification (by measurement, on this machine)

- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`, pwsh 7.6.6 present. 37 -> 38
  is the new mode canary.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, `the real tree feeds 240 tracked paths
  into the guard`, zero unclassified. This is the collateral-damage check on the sibling
  artifact: the files the ledger-backup work added are classified, so this artifact's
  real-tree case is not broken by them.
- `bash bin/docs-claims-check.sh --assertions` -> four `ok` lines, `every countable claim
  matches the tree`.
- Snapshot probe, the shipped `snapshot()` lifted verbatim into a scratch HOME (see I1 for the
  numbers): a fresh HOME plus one pwsh launch yields six spurious entries; a second launch
  after that yields zero.
- Prune-necessity probe, the same function with the prune removed: two consecutive launches
  differ on `.cache/powershell/StartupProfileData-NonInteractive`. The prune is still load
  bearing; the fix below adds to it rather than replacing it.
- Language allowlist, the sixth copy: `tests/language-allowlist-agreement.test.sh:120-125`
  asserts exactly one `ValidateSet` in `install.ps1` and compares the WHOLE set, so an added
  code is caught as well as a missing one. Unchanged this round, re-read because the scope
  line names it.
- Em/en dash scan over the in-scope diff: clean.

## Findings

### Critical

None.

### Important

- `tests/install-ps1.test.sh:292-296`. **The prune closes one instance of the hazard the
  round-3 nitpick named, and the comment reads as if it closed the hazard.** The comment's
  stated reason is "the first run that created it would report a change that install.ps1 did
  not make". Measured against the shipped function, with a fresh HOME and one pwsh launch,
  that is still true after the fix:

  ```
  > D .
  > D ./.cache
  > D ./.local
  > D ./.local/share
  > D ./.local/share/powershell
  > D ./.local/share/powershell/Modules
  ```

  `~/.local/share/powershell` is host-runtime bookkeeping by exactly the definition the
  comment above it uses, and it is not excluded; the parents `.cache` and `.local` are not
  excluded either, and neither is HOME itself. Case 9b is green today only because cases 7
  and 8 launch pwsh under the same HOME before the `before` snapshot at `:390` is taken, and
  nothing in the file says so. A reordering, a new first case, or a future pwsh that invents a
  seventh directory turns the anti-port guarantee into a false FAIL attributed to
  `install.ps1`. This is the repo's own recurring class (`lessons.md`, 2026-09-16: a guard's
  comment may name only what it verifies) reappearing one directory over, and it is worth
  saying that round 3's suggested fix was itself partial, so applying it literally inherited
  the gap.
  Fix, which removes the class rather than enumerating a second directory: warm the HOME up
  once before any snapshot is taken, right after `PWSH` is resolved, e.g.
  `env -i HOME="$TMP/home" PATH="$TMP/empty-bin:/usr/bin:/bin" "$PWSH" -NoProfile -Command exit >/dev/null 2>&1`,
  with a comment saying that every later comparison therefore straddles a HOME whose runtime
  bookkeeping already exists, whatever directories that runtime invents. Keep the prune: I
  measured that `.cache/powershell/StartupProfileData-NonInteractive` is rewritten on every
  launch, so it is churn the warm-up cannot fix. If the warm-up is rejected, the honest
  minimum is a line in the comment stating that case 9b depends on an earlier case having
  launched pwsh under this HOME.

### Nitpicks

- `tests/install-ps1.test.sh:288`. "Links are recorded by TARGET, directories by name, files by
  hash" is now incomplete in the good direction: files are recorded by mode AND hash as of
  this round. Add the word so the enumeration keeps matching the code it describes.
- `tests/install-ps1.test.sh:297`. Carried forward from round 3, not taken: `find -print` piped
  into `while IFS= read -r p` splits a path containing a newline into two entries. Sandbox
  only, but `-print0` plus `read -r -d ''` costs one line and removes the class.
- `tests/install-ps1.test.sh:106-107`. Carried forward from round 3, not taken: when the `;;`
  count disagrees because an arm BODY contains `;;` inside a string, the message sends the
  reader after a missing arm that does not exist. Name both causes in the second line.
- `tests/install-ps1.test.sh:441`. `chmod 644 "$TMP/home/mode-probe"` runs on all four
  iterations though only one dirties it. Harmless, and arguably the safer shape; noted only so
  the next reader does not hunt for the reason.

## Scores

correctness 2/2 - `install.ps1` did not move, and what did move asserts more than it did
before without asserting anything false. The mode canary cannot pass for the wrong reason: the
probe file's bytes are unchanged between the two snapshots and no mtime is recorded, so the
mode column is the only possible source of the difference. The `-prune` rewrite is correct
find semantics (prune is true, the `-o` short-circuits, nothing is printed for the pruned
subtree) and I confirmed the suite is green at 38.

security 2/2 - unchanged and still clean: every element pasted into a bash command line goes
through `ConvertTo-BashSingleQuoted`, the harness stays sealed (`env -i`, redirected HOME,
replaced PATH, no-op `install.sh`), no secrets, no PII, no network. The new canary writes only
inside `$TMP`.

performance 2/2 - the snapshot now forks `ls` per regular file on top of `shasum`. The trees
are a sandbox HOME and a four-file fixture repo, and the suite still finishes in seconds.
Nothing in a hot path.

readability 2/2 - both new comments say what was measured and why the old shape was wrong,
which is the standard this file set for itself. Held rather than raised: the comment at
:292-294 is true sentence by sentence but leaves a reader believing a hazard is closed that is
not, which is why the finding is filed against the mechanism rather than the prose.

testing 1/2 - lowered from 2, on a measurement rather than on a regression in intent. The mode
shape is a genuine widening with a canary that proves it can fail, and that part is round-3
quality work. But the other half of this round's diff is a fix for a named hazard that does
not close it, and the suite now depends on case ORDER for the correctness of its flagship
guarantee with nothing written down and nothing asserting it. A harness whose green depends on
an undeclared precondition is the shape this file is otherwise unusually good at refusing.

conventions 2/2 - countable claims re-verified against the tree rather than against the
commit body, no em or en dashes, comments English, `docs/evals` record regenerated at the new
head rather than re-dated (`lessons.md`, 2026-08-19), publish classification intact at 240
paths.

total 11/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

## Ceiling

12/12 is reachable and was reached at `cebc0a0`. Nothing about this change structurally caps
it; the single Important is a ten-line edit plus a comment, and closing it returns testing to
2/2. The Windows-unverifiable half (PowerShell 5.1, UTF-16 `wsl -l -q`, real `wslpath`, native
symlink permission) is handled the way this repo accepts, as a stated residual in the suite
header and in INSTALL.md, so it does not cap the score.

## What's good

- The mode canary is the right response to nitpick n1. Recording the mode without a canary
  would have been a claim; the probe file with fixed bytes and a flipped exec bit makes the
  claim falsifiable, and it is the shape a port of `install.sh`'s `bin/` step would actually
  leave behind.
- Both new comments name the OLD behaviour and why it was insufficient, so the next reader
  inherits the reasoning rather than the conclusion. That is why this round's gap is a
  mechanism gap and not a misleading file.
- The README count was moved in the same commit range as the suite that changed it, and
  `docs-claims-check` confirms it against the tree. The countable claims in this repo have
  stayed true across four rounds, which is rare.
- The sibling ledger-backup work added tracked files without breaking this artifact's
  real-tree publish case, and the classification lists were updated rather than the assertion
  loosened.

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
