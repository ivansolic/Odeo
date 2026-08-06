---
artifact: .gitattributes + tests/line-endings.test.sh + merge-gate reorder (cases 56, 57)
type: code
branch: chore/line-endings-and-gate-nits
reviewed_commit: 2715c2c
artifact_version: 2
date: 2026-08-06
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 10/12
verdict: APPROVE WITH COMMENTS
previous_total: 6/12
---

## Artifact

Branch `chore/line-endings-and-gate-nits` at `2715c2c` (v1 reviewed at `d1aa566`):

1. Line endings: `.gitattributes` (`* text=auto` plus `eol=lf` pins for
   `*.sh *.py *.md *.txt *.json *.yml *.yaml LICENSE .gitignore .gitattributes`),
   `tests/line-endings.test.sh` (rewritten in v2 to ask git instead of grep),
   `.gitattributes` classified PUBLIC, platform and recovery prose in `README.md` and
   `INSTALL.md`.
2. Gate nits: `tests/merge-gate.test.sh` cases 56 and 57, plus the reorder in
   `bin/merge-gate.sh` putting the `docs/evals` stray check above the clean-tree
   precondition.

## History

- v1 (`d1aa566`): REQUEST CHANGES, 6/12, three Criticals (a recovery command that did not
  recover, and a guard that reported ALL PASS with a CRLF file present in two ways).
- v2 (`2715c2c`): APPROVE WITH COMMENTS, 10/12. All three Criticals closed and verified by
  re-measurement, not by reading the fix. Regression note: BETTER (6 -> 10), correctness
  0 -> 1, testing 0 -> 1, readability 1 -> 2 (see the calibration note under Scores),
  conventions 1 -> 2.
- Working-tree note (not part of `2715c2c`): while this review ran, an uncommitted edit
  appeared in `tests/line-endings.test.sh` applying nitpick 5 (split on TAB so a path with
  a space is named in full). I verified it: baseline green, `my script.sh` now reported by
  its full name, no regression on an ordinary planted CRLF file. It is NOT covered by this
  record. Committing it moves a non-evals file past `2715c2c`, so merge-gate will refuse
  until this record is regenerated; reverting it leaves this record valid as written.

## Criticals: closed, each re-measured

- **C1 `INSTALL.md:16-26`, CLOSED.** Rebuilt my own fixture (origin with LF blobs, clone
  with `core.autocrlf=true`, then pull `.gitattributes`) and ran the NEW command end to
  end: before, `i/lf w/crlf` and the script dies with `set: pipefail: invalid option name`
  plus `syntax error near unexpected token`; after `git rm --cached -r . && git reset
  --hard`, `i/lf w/lf`, the script prints `RAN`, and `git status` is clean. The
  discards-uncommitted-work warning and the "renormalize does not help here, the blobs are
  already LF" explanation are both present and both accurate. `tests/line-endings.test.sh:71-75`
  now prints the same corrected remediation, so the two cannot drift apart silently.
- **C2 `tests/line-endings.test.sh:66-68`, CLOSED.** grep is gone from the detection path
  (`git ls-files --eol`). With a tracked CRLF script planted AND a fake grep on PATH that
  exits 2 on `-U`, the run is RED (`FAIL: CRLF/mixed endings in: tests/planted.test.sh`,
  exit 1). The v1 false green is unreachable.
- **C3 `tests/line-endings.test.sh:22-33`, CLOSED.** A non-git tree with a CRLF script
  present now refuses immediately (`not inside a git work tree, so nothing could be
  checked`, exit 1), and a 3-file git repo trips the floor (`only 3 tracked files
  visible`) while still naming the CRLF file. Both RED.
- **Pin coverage (v1 Important), CLOSED.** Re-ran every mutation: deleting `*.json`,
  `*.yml`, `*.yaml`, `LICENSE` or `* text=auto` is RED, each with an accurate message
  (`probe.json(unspecified)`, `an unpinned type resolves text=unspecified`). `check-attr`
  is the right mechanism: behavioural, reformat-proof, nested-`.gitattributes`-proof.
- **`LC_ALL=C` (v1 Important), CLOSED.** Exported once at the top, so it covers the git,
  awk and sed calls rather than a `head` that no longer exists.
- **Windows wording (v1 Important), CLOSED.** `README.md:21-23` and `INSTALL.md:6-13` now
  say macOS and Linux are what this is developed and tested on, and that Windows is
  expected to work under WSL or Git Bash but is not verified end to end. That matches the
  evidence, which only ever showed CRLF breaking bash on any platform.

## Findings at 2715c2c

### Important
1. `tests/line-endings.test.sh:80-88`, **the canary does not cover check 2, which is the
   one thing it was added for.** It re-implements the detection inline with its own awk
   instead of calling check 2's code path. Measured: with a tracked CRLF file present, I
   replaced check 2's awk program with `{ }` and the run printed
   `ok: detector fires on a planted CRLF file` and `ALL PASS`, exit 0. So the guard CAN
   still report green with a CRLF file present, via a one-line edit to the very check the
   canary claims to prove. This is the third condition, and it is why the commit body's
   "check 2 would otherwise pass silently if the reporting ever changed" is still wider
   than the mechanism. Fix, verified: one shared detector, both callers using it.
   ```bash
   crlf_offenders() { git -C "${1:-.}" ls-files --eol | awk '$2 ~ /^w\/(crlf|mixed)$/ { print $NF }'; }
   offenders="$(crlf_offenders)"                       # check 2
   [ -n "$(crlf_offenders "$scratch")" ] || bad "..."  # canary
   ```
   With that, the same awk mutation goes RED through the canary
   (`FAIL: detector did NOT fire on a planted CRLF file`).
2. `tests/line-endings.test.sh:81-89`, **the canary mutates the real repo's index and
   worktree**, with four measured consequences: (a) there is no `trap`, so a run
   interrupted inside the canary window leaves an `intent-to-add` entry behind, which makes
   `git status` dirty and `bin/merge-gate.sh` REFUSE with `uncommitted changes present`,
   and the next run then mis-blames the canary itself
   (`FAIL: CRLF/mixed endings in: .line-endings-canary.tmp`); (b) a read-only worktree root
   gives a spurious RED (`Permission denied`, then `detector did NOT fire`) even though the
   repo's line endings are fine; (c) a stale `.git/index.lock` gives the same spurious RED,
   because the `git add` failure is swallowed by `>/dev/null 2>&1`; (d) if that path were
   ever tracked, the run DELETES the worktree file and leaves a staged deletion (measured:
   `D .line-endings-canary.tmp`, file gone). One fix removes all four: plant the canary in
   a scratch repo, which touches nothing.
   ```bash
   scratch="$(mktemp -d)"; trap 'rm -rf "$scratch"' EXIT
   git -C "$scratch" init -q .; printf 'x\r\n' > "$scratch/c.txt"; git -C "$scratch" add -A
   ```
   Verified to report `w/crlf` both with default config and with `core.autocrlf=true` (the
   Windows user's own setting), and the dirty-tree case is clean today: a run against a
   tree with staged and unstaged edits left `git status --porcelain` byte-identical.
3. `tests/line-endings.test.sh:66-68`, **lone-CR content is now a blind spot, a narrowing
   versus the grep it replaced.** git classifies a file containing CRs without LFs as
   binary, so `--eol` reports `w/-text` and the awk never sees it. Measured in a scratch
   repo carrying THIS repo's `.gitattributes`: `cronly.sh` (`a\rb\rc\n`) and `midcr.sh`
   (one stray CR mid-line) both report `i/-text w/-text attr/text eol=lf` and are NOT
   flagged, while `grep -U` flagged both. Neither arises from `core.autocrlf` (which
   produces CRLF), so this is not a Critical, but a CR-only `.sh` does not run either. Fix,
   verified to flag both with no false positive on an unpinned binary (a real PNG resolves
   `attr/text=auto`, not `attr/text`):
   ```awk
   $2 ~ /^w\/(crlf|mixed)$/ { print $NF }
   $3 == "attr/text" && $2 == "w/-text" { print $NF }   # pinned as text, yet binary = CR or NUL
   ```

### Nitpicks
4. `tests/line-endings.test.sh:38`, the new `.gitignore` and `.gitattributes` pins are
   unasserted: deleting the `.gitignore` pin leaves the suite ALL PASS. Both are real path
   names, so adding them to the probe list costs one word each. Cosmetic only, because I
   measured at v1 that git tolerates CR in both (`check-attr` still resolves `eol: lf`
   from a CRLF `.gitattributes`, and a CRLF `.gitignore` still matches).
5. `tests/line-endings.test.sh:67`, `$NF` truncates a path containing spaces: I planted
   `spaced name.txt` and it was reported as `FAIL: CRLF/mixed endings in: name.txt`. It is
   still caught, just misnamed, and no tracked path has a space today. `--eol -z` plus a
   cut on the tab would fix the name.
6. Declined nits, and my position: neither matters. Leaving `bin/merge-gate.sh` untouched
   is the better call now that its behaviour is cleared, so the 142-char comment and the
   orphaned `# 2. Clean working tree` header can wait for the next commit that edits the
   file for a real reason. Case 56 asserting the exit code only is acceptable because I
   proved by mutation that it pins the flag: rewriting it to bare `git status --porcelain`
   makes it RED with `rc=0`.

## Carried forward from v1 (still true, unchanged code)

The reorder remains behaviour-preserving: restoring the original order leaves 72/73 with
only case 57 RED, deleting the stray block entirely also leaves 72/73 with only case 57
RED, both blocks are read-only git queries, and `git ls-files --others --exclude-standard
docs/evals` exits 0 silently when the directory is absent. Accept/reject set unchanged,
message only. Case 57 pins the reorder on the message, which is what makes the
eval-framework sentence "refused explicitly, by name" observably true.

## Scores

correctness 1/2 (recovery command verified end to end, reorder proven equivalent,
`LC_ALL=C` correct; the point is held by the canary's side effects on the real index and
worktree, which can leave the repo in a state that blocks merge-gate and can fail
spuriously in three environments) - security 2/2 (read-only git queries, no injection
surface, no secrets; the canary writes a predictable temp name in the repo root, no
privilege or disclosure issue; `.gitattributes` correctly PUBLIC and reaching the
snapshot) - performance 2/2 (one `ls-files` pass over 206 files plus nine `check-attr`
calls) - readability 2/2 (the rewrite is clearer than what it replaced, checks are
numbered and the comments state what is proven; calibration note: v1 scored this 1 on the
strength of a NITPICK, which was inconsistent with my own rubric, so the move to 2 is
partly a correction of my own scoring, not only the author's work) - testing 1/2 (the
canary does not cover the check it exists for, lone-CR is a blind spot, two pins
unasserted) - conventions 2/2 (claims now match mechanisms and every one was
mutation-proven; the commit body records the author's own broken fixture and broken probe
rather than hiding them, which is exactly the lessons.md 2026-08-03 rule being followed)
-> total 10/12 (threshold: >=9, no zero) -> APPROVE WITH COMMENTS

## Ceiling

12/12 is reachable. Nothing structurally caps a criterion here: the change has a real
security surface (publish classification, gate refusal logic) and scored full marks, and
the two remaining points are held by concrete defects with proven one-line fixes, not by
absent scope.

## What is good

The fix went at the root rather than the symptom: instead of hardening `grep -U`, the
detector now asks git, which removes the portability question entirely and makes both
assertions behavioural, so a reformatted or nested `.gitattributes` cannot fake a pass.
`check-attr` probing every type is a strictly better mechanism than matching the file's
text, and giving `* text=auto` its own assertion is a subtle catch: the explicit pins
resolve without it, so nothing else would have noticed it disappear. The scanned-file
floor and the not-a-git-worktree refusal turn "I saw nothing" into a refusal instead of a
pass, which is the correct direction for a guard a user is told to trust as a diagnostic.
Two reported self-caught errors (a fixture that had `.gitattributes` already present, and a
probe that read `$?` after the wrong command) are worth more than a clean report would
have been.
