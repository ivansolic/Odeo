---
artifact: docs-prd-003-copy-check
type: code
branch: docs/prd-003-pm-content-depth
reviewed_commit: e8c3a25
date: 2026-11-04
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 12/12
---

# Code review: branch docs/prd-003-pm-content-depth after the rebase onto main, round 3

Scope: `git diff main...HEAD` at `e8c3a25` (I resolved the sha myself with
`git rev-parse --short HEAD`; it matches the one I was handed). The executable code in that
diff is `.claude/maintainer/copy-check.sh`, `.claude/maintainer/tests/copy-check.test.sh`
and the regenerated `scripts/odeo-legacy-hashes.txt`. I also checked the frontmatter change
that removes `disable-model-invocation` from 37 skills (commit `9582983`) against the human
floor, because it changes which skills the model may start on its own. The bodies of
`skills/critique/`, the PRD, the stories, the depth checklists and the agent files belong
to pm-reviewer, skill-reviewer, adoption-reviewer and agent-reviewer. I checked those only
for the no-dash house rule.

I reviewed this fresh. Afterwards I compared it with the round-2 record. `copy-check.sh` and
its test are byte-identical to `75c14e1` (`git diff 75c14e1 HEAD` on both paths is empty).

Output language: en (handed at dispatch). Model: claude-opus-5-5, tier strongest. I did not
re-check the live lineup in this run.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
- `.claude/maintainer/tests/copy-check.test.sh:18-19`: the mutation recipe claims that
  deleting the min-words check makes "the min-words 0 and abc cases FAIL". The abc case
  does not fail. It hangs. Without the check, `min` is the string `abc`, so awk compares
  `j < min` as strings. Every digit string sorts below `"abc"`, so the loop never ends.
  The project CLAUDE.md requires that a coverage claim describe the RED that was actually
  observed. This line asserts a RED that never happens. Round 2 flagged it, and it is still
  unfixed after the rebase. Fix: change the text to "-> the min-words 0 case FAILS; the abc
  case hangs (awk string comparison), kill it".

## Nitpicks (optional)
- `.claude/maintainer/copy-check.sh:28-30`: in two cases the checker reports a pass when it
  should report a match, and it says nothing. I reproduced both at `e8c3a25`:
  `copy-check.sh a.md a.md` exits 0, and a source path that contains a backslash
  (`'b\x.md'`, same text) exits 0. The cause is the comparison `FILENAME == src`: `-v`
  unescapes backslashes, and two identical paths both match `src`. The fix removes the
  whole class: drop `-v src`, pass a marker operand between the files
  (`... "$SRC" f=1 "$ODEO"`), and use `if (!f) s[++ns] = w[i]; else o[++no] = w[i]`. awk
  applies the assignment after it has read the source, so an empty source still works.
  This is a nitpick only because nobody runs the tool on these inputs.
- `.claude/maintainer/tests/copy-check.test.sh`: two guards have no test, so mutants of them
  survive. The first is the `./` prefix in `abs()`: every fixture path is an absolute
  mktemp path, so removing the prefix goes unnoticed. The second is the more-than-3-arguments
  refusal. Add a case that runs `cd "$TMP"; cp source.md a=b.md; bash "$CC" odeo.md a=b.md`
  and expects exit 1. Add a 4-argument case that expects exit 2. I probed the current
  script by hand and both behave correctly (exit 1 and exit 2), so this is a regression
  net, not a bug.
- `.claude/maintainer/copy-check.sh:23`: `abs()` does not make a path absolute. It guards
  a relative path against awk's `name=value` parsing. Rename it to `safe_operand()`.
- `docs/prds/PRD-003-pm-content-depth.md:123,365`: the PRD points to the invocation change
  as commit `e9288b6`. After the rebase that commit is `9582983`. The old object still
  resolves in this clone, but it is not on the branch. Update both references at the next
  PRD round (pm-reviewer's artifact, so changing it re-stales `docs/evals/PRD-003.md`).

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 1/2  -> total 11/12  (threshold: >=9, no zero)

## Ceiling
12/12 is reachable. Conventions is the one point missing, and fixing a single comment line
in the test file recovers it. Nothing in this change caps a dimension structurally.

## What's good
- `scripts/odeo-legacy-hashes.txt` is exactly what the generator produces. Running
  `gen-legacy-hashes.sh` at `e8c3a25` gives output identical to the committed file (545
  entries). Each of the 6 added hashes matches a version of `skills/critique/SKILL.md` or
  `agents/skill-reviewer.md` in a commit on this branch. None comes from another
  worktree's ref. Hashes cover content, not commits, so the rebase cannot invalidate them.
- `copy-check.sh` is small and readable. It refuses to run on bad input (usage, missing
  file, min-words not a positive integer: exit 2). The header names the ASCII-only limit as
  a heuristic. Earlier mutation evidence still applies to identical code: M1 to M5 go RED.
- The skill-invocation change keeps the human floor where PRD-002 R15 asks for it.
  `second-opinion-pm` keeps step 1's explicit yes "whoever started it". `prototype`
  shares stay "always your call" with an explicit go. `new-project` creates a remote only
  in step 8 after an explicit yes. `improve` keeps the human's keep or revert. `retro`
  writes nothing before approval. `skills-lint.sh` passes with every skill now linted.

## Evidence (what I ran)
- `bash .claude/maintainer/tests/copy-check.test.sh`: 13/13 ok, rc=0.
- `bash .claude/maintainer/tests/legacy-hashes.test.sh`: ALL PASS. `bash
  tests/odeo-legacy-hashes.test.sh`: ALL PASS. `bash tests/skills-lint.test.sh`: 93
  passed, 0 failed. `bash scripts/skills-lint.sh`: rc=0.
- `gen-legacy-hashes.sh` (stdout mode) compared with `diff` against the committed list:
  identical.
- Probes against the real script, in a scratch directory: the same path twice gives rc=0
  (WRONG). A backslash in the source path gives rc=0 (WRONG). The same file under two
  spellings (`a.md`, `./a.md`) gives rc=1. `k=v.md` as the source gives rc=1. 4 arguments
  give rc=2.
- I did not repeat the mutation runs. The two files are identical to `75c14e1`, where
  round 2 recorded every mutant. I confirmed the M6 abc hang by reading the code (string
  comparison in `j < min`).
- No em or en dash in any line the branch adds. No non-ASCII in the three code files.

## Note for the dispatcher (outside this record's scope, affects the merge)
`docs/evals/PRD-003-stories.md` still carries `reviewed_commit: 208d421`, and that commit
is NOT an ancestor of HEAD after the rebase. `merge-gate.sh` (line 305) refuses that
record until pm-reviewer regenerates it.

## History
- Round 1 (`a8f82f7`, files uncommitted then): APPROVE WITH COMMENTS, 11/12 (testing 1/2).
- Round 2 (`75c14e1`): APPROVE WITH COMMENTS, 12/12. Flagged as nitpicks: the fail-open
  `FILENAME` comparison, the wrong M6 recipe text, the untested `./` and 4-argument guards,
  and the `abs()` name.
- Round 3 (this record, `e8c3a25`, after the rebase onto main): APPROVE WITH COMMENTS,
  11/12. Regression note: the code is the SAME, but the score is WORSE by 1 (conventions
  2 -> 1). No code got worse. In this independent review I rate the false coverage claim
  in the M6 recipe as Important, because the project CLAUDE.md requires coverage claims to
  match the RED actually observed and this one has now survived a round unfixed. None of
  the round-2 nitpicks was applied. The regenerated legacy-hash list is new in this round,
  and it is correct.
