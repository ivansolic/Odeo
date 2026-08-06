---
artifact: .gitattributes + tests/line-endings.test.sh + merge-gate reorder (cases 56, 57)
type: code
branch: chore/line-endings-and-gate-nits
reviewed_commit: c63b879
artifact_version: 4
date: 2026-08-06
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 9/12
---

## Artifact

Branch `chore/line-endings-and-gate-nits` at `c63b879`:

1. Line endings: `.gitattributes` (`* text=auto` plus `eol=lf` pins for
   `*.sh *.py *.md *.txt *.json *.yml *.yaml LICENSE .gitignore .gitattributes`),
   `tests/line-endings.test.sh` (git-based detector, shared `crlf_offenders()`,
   two-arm scratch-repo canary), `.gitattributes` classified PUBLIC, platform and recovery
   prose in `README.md` and `INSTALL.md`.
2. Gate nits: `tests/merge-gate.test.sh` cases 56 and 57, plus the reorder in
   `bin/merge-gate.sh` putting the `docs/evals` stray check above the clean-tree
   precondition.

## Trajectory (4 cycles, cycle 4 on an explicit human waiver of the 3-cycle cap)

6/12 -> 10/12 -> 9/12 -> **12/12**. Max reached, which is the first stop condition in
`AGENTS.md`, so the loop closes here with no residual handed to the human as an open
decision.

- v1 (`d1aa566`): REQUEST CHANGES, 6/12. Three Criticals: a recovery command that did not
  recover, and a guard reporting ALL PASS with CRLF present two ways (grep `-U` fail-open,
  nothing-scanned vacuity).
- v2 (`2715c2c`): APPROVE WITH COMMENTS, 10/12. Criticals closed; three Importants opened
  (canary did not guard check 2, canary mutated this repo's index, lone-CR blind spot).
- v3 (`68232e9`): REQUEST CHANGES, 9/12. Those three closed, but the fix introduced a new
  Critical: a failed `mktemp -d` left `$scratch` empty, and `git -C ""` is a no-op, so the
  canary ran against THIS repo, staged the real tree, found the file it had just staged,
  and called that proof (ALL PASS with a CRLF file present).
- v4 (`c63b879`): APPROVE, 12/12. Both closed with the fix as verified, no new defect.
  What moved the score: every claim in the guard is now proven by a mutation that was
  actually run, and the guard fails closed in every degraded environment tested.

## The two closures, re-measured at c63b879

- **Critical, failed `mktemp -d`, CLOSED** (`tests/line-endings.test.sh:104-107`). Re-ran the
  exact fixture that produced the false green: `mktemp` shadowed by one that exits 1, in a
  clone holding an untracked CRLF file plus untracked junk. Result:
  `FAIL: could not create a scratch dir, so the detector could not be proven`, `SOME
  FAILED`, exit 1, and the real repository untouched (`git diff --cached` empty, both files
  still `??`). The `trap` is armed only inside the `else`, so an empty path cannot reach
  `rm -rf`.
- **Important, one canary file per detector arm, CLOSED**
  (`tests/line-endings.test.sh:113-121`). Deleting the lone-CR arm:
  `FAIL: detector fired on 1 of 2 planted files`. Deleting the `w/crlf` arm: same, RED.
  Gutting the shared awk with a tracked CRLF file present: `fired on 0 of 2`, RED. So check
  2, both arms, and the canary now stand or fall together, which is what makes the coverage
  claim true rather than asserted.

## Robustness probes on the new block (all fail closed or pass correctly)

- `mktemp` returning a path that is a FILE, not a directory: RED
  (`could not create a scratch dir`), so the `[ ! -d ]` half of the guard earns its place.
- Scratch path containing spaces: ALL PASS, and zero leftover directories, so the quoting
  is right throughout and the `trap` cleans a spaced path.
- This repo's `.gitattributes` moved away entirely: canary still green, because the scratch
  pin is WRITTEN rather than copied. That was the reason for writing it, and it holds.
- Repo state after every probe: `git status --porcelain` empty. The guard no longer has any
  effect on the repository it guards.

## Findings at c63b879

None that block, and none that need a fix. Residue, all measured cosmetic, recorded so it
is not rediscovered as news:

- `tests/line-endings.test.sh:38`, the `.gitignore` and `.gitattributes` pins are not in
  check 1's probe list, so deleting the `.gitignore` pin leaves the suite green. Cosmetic
  because I measured that git tolerates CR in both: a CRLF `.gitattributes` still resolves
  `eol: lf` through `check-attr`, and a CRLF `.gitignore` still matches its patterns.
- `bin/merge-gate.sh:56-58`, the 142-char comment and the orphaned `# 2. Clean working
  tree` header from the reorder. Correctly declined: not worth touching a file whose
  behaviour is cleared, and the next commit that edits it for a real reason can tidy it.
- `tests/merge-gate.test.sh:652`, case 56 asserts the exit code only. Acceptable, because
  the mutation proves it pins the flag: reverting to bare `git status --porcelain` makes it
  RED with `rc=0`.

Out of scope for this change, and NOT counted against it: nothing invokes `tests/*.test.sh`
automatically (no CI workflow exists, `.github/` is allowlisted but absent), so the suite is
green by convention in `CLAUDE.md` rather than by enforcement. That is a repo-wide property
this commit inherits, not one it introduced, and it deserves its own story.

## Carried forward (unchanged code, verified in earlier cycles)

- The merge-gate reorder is behaviour-preserving: restoring the original order leaves 72/73
  with only case 57 RED; deleting the stray block entirely also leaves 72/73 with only case
  57 RED; both blocks are read-only git queries; `git ls-files --others --exclude-standard
  docs/evals` exits 0 silently when the directory is absent. The accept/reject set is
  unchanged, only the message differs, which is what makes the eval-framework sentence
  "refused explicitly, by name" observably true.
- Case 56 pins `--untracked-files=normal` (reverted, it goes RED with `rc=0`, meaning
  untracked code would have merged).
- The corrected INSTALL recovery command was verified end to end on my own fixture:
  `i/lf w/crlf` and a script dying on `set: pipefail: invalid option name`, then after
  `git rm --cached -r . && git reset --hard`, `i/lf w/lf`, the script runs, tree clean.
- Detector correctness: `cronly.sh` and `midcr.sh` flagged, a real PNG (`attr/text=auto`)
  not flagged, ordinary files not flagged. Non-git tree and a sub-floor file count both
  refuse. `check-attr` reads through to the INDEX when the worktree copy is missing or
  unreadable, which is the correct invariant, since index attributes govern checkout
  conversion.

## Scores

correctness 2/2 (the `mktemp` failure path refuses and leaves the index alone, non-directory
results are caught, spaced paths are quoted correctly, and the detector has no false
positives) - security 2/2 (read-only git queries, no injection surface, no secrets,
`rm -rf` only ever reaches a verified mktemp directory, `.gitattributes` correctly PUBLIC
and reaching the snapshot) - performance 2/2 (one `ls-files` pass over 206 files, nine
`check-attr` calls, one throwaway repo per run) - readability 2/2 (each comment records
what a mutation proved rather than what was intended, which is what the next person
needs) - testing 2/2 (check 2, both detector arms and the canary now fail together; the
vacuity, portability and scratch-dir paths all fail closed; every coverage claim was
observed RED) - conventions 2/2 (mutation-before-claim followed throughout, deviations and
self-caught fixture errors recorded in the commit bodies, no dashes, one honest verdict per
record) -> total 12/12 (threshold: >=9, no zero) -> APPROVE

## Ceiling

12/12, reached. No criterion structurally caps for this change: it had a real security
surface (publish classification, gate refusal logic) and a real testing surface, and both
scored full marks.

## What is good

The line-endings work ended up stronger than the bug that prompted it. The detector asks git
instead of grep, so there is no portability question and both assertions are behavioural;
`check-attr` probes every type, so a reformat or a nested `.gitattributes` cannot fake a
pass; the `attr/text` versus `attr/text=auto` distinction keeps a genuine binary from
false-positiving; and the canary now proves each arm of the detector through the same code
path the real check uses, which is the difference between a guard and a decoration. The
degraded-environment behaviour is the part worth keeping: a non-git tree, a file count below
the floor and a failed scratch directory all REFUSE rather than pass, which is the correct
direction for a guard that INSTALL tells users to trust as a diagnostic. Four cycles is more
than this should have taken, and the reason it converged is that each round the author
reproduced the finding, fixed the root cause rather than the symptom, and reported his own
broken fixtures and probes instead of hiding them.
