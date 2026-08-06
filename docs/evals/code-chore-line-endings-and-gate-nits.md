---
artifact: .gitattributes + tests/line-endings.test.sh + merge-gate reorder (cases 56, 57)
type: code
branch: chore/line-endings-and-gate-nits
reviewed_commit: d1aa566
artifact_version: 1
date: 2026-08-06
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 0, security: 2, performance: 2, readability: 1, testing: 0, conventions: 1 }
total: 6/12
verdict: REQUEST CHANGES
previous_total: n/a
---

## Artifact

Commit `d1aa566` on `chore/line-endings-and-gate-nits`, two bundled parts:

1. Line endings: new `.gitattributes` (`* text=auto` plus `eol=lf` pins for
   `*.sh *.py *.md *.txt *.json *.yml LICENSE`), new `tests/line-endings.test.sh`,
   `.gitattributes` classified PUBLIC in `docs/public-paths.txt`, platform-support and
   recovery prose in `README.md` and `INSTALL.md`.
2. Gate nits: `tests/merge-gate.test.sh` cases 56 and 57, plus a reorder in
   `bin/merge-gate.sh` moving the `docs/evals` stray check above the generic clean-tree
   precondition.

No prior record exists for this branch (lineage: the previous record in this line is
`docs/evals/code-fix-gate-ignore-untracked-evals.md`, v2, APPROVE WITH COMMENTS, 11/12,
for a different branch), so `previous_total` is n/a and there is no regression comparison.

## What I verified myself (measured, not read)

- `git rev-parse --short HEAD` = `d1aa566`, matches the record.
- Baseline: `tests/line-endings.test.sh` ALL PASS; `tests/merge-gate.test.sh` 73/73.
- **Reorder is behaviour-preserving.** Restoring the original order (clean-tree first,
  stray second) in an isolated clone leaves 72/73 with only case 57 RED, and deleting the
  stray block entirely also leaves 72/73 with only case 57 RED (the refusal survives with
  the generic message). Both blocks are read-only git queries; `git ls-files --others
  --exclude-standard docs/evals` on a repo with no `docs/evals` exits 0 silently, so the
  earlier position introduces no new failure path. The accept/reject SET is unchanged; only
  the message changes. No regression.
- **Case 56 pins the flag.** Rewriting `git status --porcelain --untracked-files=normal`
  to `git status --porcelain` makes case 56 RED with `rc=0`: without the flag an untracked
  `src-new.go` merges. The asymmetry claim holds.
- **Case 57 pins the reorder** (RED under the old order, on the message, not the code).
- **The new guard fails OPEN, twice** (both reproduced with a CRLF script present):
  a grep without `-U` -> `ALL PASS`, exit 0; a tree where `git ls-files` yields nothing
  -> `ALL PASS`, exit 0.
- **The INSTALL recovery command is a no-op** on the state it claims to fix (simulated
  Windows clone: `core.autocrlf=true`, CRLF worktree, LF index, clean status).
  `git add --renormalize . && git checkout .` -> "Updated 0 paths from the index", CR
  still present. `git rm --cached -r . && git reset --hard` -> CR gone.
- **The pin assertions cover 4 of 7 pins.** Deleting `*.json`, `*.yml`, `LICENSE` and
  `* text=auto` from `.gitattributes` leaves the test ALL PASS.
- `.gitattributes` classification: present in `docs/public-paths.txt`, publish-guard does
  not report it unclassified. `tests/` is public, so the INSTALL reference to
  `tests/line-endings.test.sh` resolves in the snapshot.
- Tracked-type census: only `.md .sh .json .txt .yml .py`, `LICENSE`, `.gitignore`,
  `.gitattributes` and two symlinks (`.claude/agents`, `.claude/skills`). All 25
  exec-bit files are `.sh`. No binaries. So the pin list has no LIVE gap.
- Measured, so NOT findings: git tolerates CR in both `.gitattributes` (`check-attr` still
  resolves `eol: lf`) and `.gitignore` (patterns still match), so the unpinned pair is not
  a bootstrap self-defeat; the ugrep shell function on the interactive PATH is not exported
  to child shells, and ugrep 7.5.0 handles `-qU $'\r'` identically anyway; `head -1 | grep
  -q` does not lose to `pipefail` even on a 400 KB first line.

## Findings

### Critical
1. `INSTALL.md:14-18`, the documented recovery is a proven no-op for the described state.
   Replace with the measured-working sequence and the destructive-command warning:
   "commit or stash first, then `git rm --cached -r . && git reset --hard` (this discards
   uncommitted changes), or simply clone again."
2. `tests/line-endings.test.sh:31,47`, `grep -qU` fails open: an erroring grep is
   indistinguishable from a clean file, and check 2 hides the error with `2>/dev/null`.
   Self-test the detector against a CRLF canary and `bad` if it does not fire, or drop grep
   for `git ls-files --eol` (`w/crlf` / `w/mixed`).
3. `tests/line-endings.test.sh:26-34,42-49`, no assertion that anything was scanned; zero
   files reads as clean. Count scanned files and `bad` below a floor.

### Important
4. `tests/line-endings.test.sh:18-25`, pin assertions cover 4 of 7 pins and skip
   `* text=auto`; a partial revert stays GREEN, so "asserts the pins exist" is wider than
   the mechanism (repeat of lessons.md 2026-08-03). Assert behaviour via
   `git check-attr eol -- x.sh x.py x.md x.txt x.json x.yml LICENSE` (verified: each
   resolves `lf`), which also covers formatting variants and nested `.gitattributes`.
5. `tests/line-endings.test.sh:47`, `LC_ALL=C` is applied to `head`, not to the `grep` that
   does the byte test, so the stated locale independence is not achieved in check 3.
6. `README.md:21-22`, `INSTALL.md:6-11`, Windows support is asserted flatly; the commit
   measures only the CRLF failure modes, which reproduce on any bash. Either run the
   install on Git Bash and WSL, or label the claim as expected-not-yet-verified.

### Nitpicks
7. `bin/merge-gate.sh:56-58`, the reorder mangled the comment (142-char line, two sentences
   jammed together) and left `# 2. Clean working tree` orphaned above the stray check while
   the actual clean-tree check has no header. The deleted "belt for the same hole" rationale
   is worth keeping.
8. `INSTALL.md:14`, "cloned BEFORE 2026-08-06" is meaningless to a public reader; key the
   advice to the symptom.
9. `.gitattributes:14-21`, add `*.yaml`, `.gitignore`, `.gitattributes` for completeness and
   one line stating that `* text=auto` auto-detects binaries so a future binary needs an
   explicit `-text` line.
10. `tests/merge-gate.test.sh:652`, case 56 asserts exit code only; assert the message too.
11. `bin/merge-gate.sh:59-65`, with both conditions present the stray message wins, so a
    user with a dirty tree needs two round trips; mention that other uncommitted changes
    may remain.
12. Two unrelated changes in one commit (line endings, gate nits); bundling was agreed, so
    noted only for the record.

### Mutation the suite misses
Deleting `*.json`, `*.yml`, `LICENSE` and `* text=auto` from `.gitattributes`: fully GREEN.
Finding 4 closes it.

## Scores

correctness 0/2 (the gate reorder is provably equivalent and cases 56/57 pin what they
claim; the 0 is entirely the shipped recovery command that does not recover, plus the
misplaced `LC_ALL=C`) - security 2/2 (read-only git queries, no injection surface, no
secrets, `.gitattributes` correctly classified PUBLIC and reaches the snapshot) -
performance 2/2 (two extra read-only git calls at gate start; one pass over ~200 tracked
files) - readability 1/2 (mangled comment and orphaned section header from the reorder) -
testing 0/2 (the new guard reports ALL PASS with a CRLF script present under two
reproduced conditions, and three of seven pins plus `text=auto` are unasserted) -
conventions 1/2 (repeats the lessons.md 2026-08-03 claim-wider-than-mechanism pattern and
the merge-gate's own documented "whichever grep is on PATH" lesson; unverified platform
claim) -> total 6/12 (threshold: >=9, no zero) -> REQUEST CHANGES

## Ceiling

12/12 is reachable. Nothing here structurally caps a criterion: the change has a real
security surface (publish classification, gate refusal logic) and it scored 2, and the
failing dimensions fail on defects, not on absent scope.

## What is good

The root-cause instinct is right: a macOS-only `.DS_Store` fix generalized into a
platform-general cause, and the failure was measured (`set: pipefail: invalid option name`)
rather than assumed. `.gitattributes` carries its own reason so it cannot be deleted as
noise. The reorder is the smallest edit that makes the eval-framework sentence "refused
explicitly, by name" observably true, and case 57 pins it on the message rather than the
exit code. Case 56 is genuinely load-bearing: the asymmetry argument is correct and the
mutation confirms an untracked source file would otherwise have merged.
