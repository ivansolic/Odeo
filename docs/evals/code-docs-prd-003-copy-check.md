---
artifact: docs-prd-003-copy-check
type: code
branch: docs/prd-003-pm-content-depth
reviewed_commit: 75c14e1
date: 2026-10-30
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: copy-check.sh and its test (PRD-003 R24, USR-029), round 2

Scope: `.claude/maintainer/copy-check.sh` and `.claude/maintainer/tests/copy-check.test.sh`
as committed in `75c14e1` (I resolved the sha myself with `git rev-parse --short HEAD`; it
matches the one I was handed). The working tree carries no change to either file.

Output language: en (handed at dispatch). Model: claude-opus-5-5, tier strongest. I did not
re-check the live lineup in this run.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `.claude/maintainer/copy-check.sh:28-30`: the round-1 fix (`-v src="$SRC"` plus
  `FILENAME == src`) introduced two new silent false negatives. Both are rare, but both fail
  OPEN (exit 0, "no shared run"):
  1. `awk -v` processes backslash escapes in the value, but awk opens the file operand
     verbatim. A source path that contains a backslash then never equals `FILENAME`, so every
     word goes into `o[]`, `s[]` stays empty, and the script exits 0. Reproduced, relative and
     absolute: identical text, rc=0.
  2. The same path passed twice (`copy-check.sh a.md a.md`) puts both reads into `s[]`, so
     the script exits 0. Before the change it exited 1. Reproduced.
  The fix removes the whole class (no filename comparison at all): pass a marker operand
  between the files, `awk -v min="$MIN" '{ ... if (!f) s[++ns] = w[i]; else o[++no] = w[i] ... }' "$SRC" f=1 "$ODEO"`,
  and drop `-v src`. awk applies the assignment after the source file is read, so it also
  handles an empty source, the reason for the round-1 comment. I rate this a nitpick, as I
  rated the analogous `x=y.md` issue in round 1: maintainer-only tool, paths under repo
  control.
- `.claude/maintainer/tests/copy-check.test.sh:18-19`: the M6 claim is partly wrong. With the
  min-words check deleted, `min-words 0` FAILS as claimed. But `min-words abc` HANGS: awk
  compares `j < min` as strings, and every digit string sorts below `"abc"`, so the loop
  never ends. The suite has no timeout, so whoever runs M6 sees the suite never finish, not
  a FAIL line. (I killed the hung awk, and the case then reported rc=143.) Fix the recipe
  text: "-> the min-words 0 case FAILS; the abc case hangs (awk string comparison), so kill
  it". This matters because CLAUDE.md requires a coverage claim to describe the observed
  RED.
- `.claude/maintainer/tests/copy-check.test.sh`: two round-1 fixes have no test. Mutant X2
  (remove the `./` prefix) SURVIVES, because every fixture path comes from `mktemp` and is
  absolute. Mutant X6 (accept 4 arguments) SURVIVES. Fix: one case that runs `cd "$TMP"`,
  copies the source to `a=b.md`, calls `bash "$CC" odeo.md a=b.md` and expects exit 1. And
  one case with 4 arguments that expects exit 2. The `FILENAME` change (mutant X1, revert to
  `FNR == NR`) cannot be caught by any exit code: with an empty source the correct answer is
  always 0, and both versions give 0. No test is owed there.
- `.claude/maintainer/copy-check.sh:23`: the name `abs()` is wrong. The function does not make
  a path absolute; it guards a relative one. Rename it `safe_operand()` or `guard_path()`.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. The remaining comments are nitpicks. None of them causes a wrong result on
the inputs this tool is actually run on: a skill file against a gitignored source copy, paths
without backslashes, two different files.

## Evidence (what I ran)
- Suite at `75c14e1`: 13/13 ok, rc=0.
- Mutation testing, done on COPIES in the session scratchpad with the repo's directory layout
  (runner: perl substitution, then a `cmp` check that the mutation applied). The repository
  files were never modified.
  - M1 (default 10): RED, 5 FAIL.
  - M2 (no gsub): RED, 2 FAIL.
  - M3 (exit 0): RED, 6 FAIL.
  - M4 (a unique token appended per line, so no run can cross a line): RED, 1 FAIL (line
    break). This is the round-1 survivor, now killed.
  - M5a (`ns` bound): RED, 2 FAIL. M5b (`no` bound): RED, 1 FAIL (whole file). Both
    round-1 survivors are now killed.
  - M6 (min check deleted): RED. `0` FAILS; `abc` hangs, see the nitpick. The round-1
    survivor is now killed.
  - Extra: ignore the third argument RED (1 FAIL); no `tolower` RED (1 FAIL); mark only the
    first word of a hit RED (1 FAIL). The `./` prefix removed SURVIVED. 4 arguments accepted
    SURVIVED. `FNR == NR` restored SURVIVED, and is unobservable by construction.
- Path probes against the real script: `a=b.md` relative, as source and as odeo file: 1
  (correct, the `./` fix works). A file named `-`: 1 (correct, no stdin read). `dir/src.md`:
  1. The same file under two spellings: 1. Min `08`: 1. Min empty string: falls back to 9,
  result 1. A backslash in the source path, relative and absolute: 0 (WRONG, nitpick 1).
  The same path twice: 0 (WRONG, nitpick 1).
- The header (lines 4-9) now describes printed stretches correctly. README line 80 still
  matches the script's command. No non-ASCII and no em or en dashes in either file.

## History
- Round 1 (`a8f82f7`, files uncommitted then): APPROVE WITH COMMENTS, 11/12 (testing 1/2).
  Two Importants: no line-break case, and no case where the run fills the file edge, so the
  loop-bound mutants survived. Nitpicks: min-words untested, the header overstated "maximal
  run", `FNR == NR` with an empty source, the awk `name=value` operand.
- Round 2 (this record, `75c14e1`): APPROVE WITH COMMENTS, 12/12. Regression note: BETTER
  (+1, testing 1 -> 2). All six round-1 comments were applied, and each one I re-verified
  holds (the mutants are killed, the probes are correct). One new low-severity defect came in
  with the `FILENAME` fix: a backslash path or the same path twice gives a silent exit 0.
  The marker-operand fix above removes it.
