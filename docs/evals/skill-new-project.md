---
artifact: skills/new-project
type: skill
branch: feature/plugin-install
reviewed_commit: 63f73d9
artifact_version: 3
date: 2026-09-24
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---
# Skill review: new-project (explicit command), round 3, re-anchored

Output language: en (handed at dispatch). Tier note: `strong` is declared because the
judging model is Opus class, which is certainly "sonnet class and up"; whether it is the
top tier on this subscription was not verified live, so `strongest` is not claimed.

## Re-anchor (not a new review round)
This record replaces the round-3 record written at 0f29848. merge-gate refused that record because non-evals files had changed since that commit. This is a regeneration, not a re-date. It is not a fourth review round, so the round count stays at 3.

What I checked myself: I have no shell, so I could not run `git diff`. Instead I re-read the three inputs from the working tree and compared them with what I read in earlier rounds.
- `skills/new-project/SKILL.md`: identical to the round-3 text, all 83 lines.
- `bin/init-project.sh`: identical to the text read in rounds 1 to 3, all 304 lines.
- `bin/resolve-language.sh`: one changed line, line 37, now `GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md}"`. Everything else is unchanged.

This matches the diff the coordinator reported. Limit: I read the working tree, and cannot prove it equals commit 63f73d9. That equivalence rests on the coordinator's sha.

Step 4 still holds. Lines 33-34 say "the parent folder's own `CLAUDE.md` setting if it has one, otherwise the global default". The script's order is unchanged (lines 59-62: the project's `CLAUDE.md`, then `GLOBAL_CONFIG`, then `en`). Only WHERE the global default file lives has changed: it now follows `CLAUDE_CONFIG_DIR` when that is set. The skill never names a path for the global default, so no wording is now wrong. The worked example (`resolve-language.sh '/Users/ana/code'` prints `de`) is unaffected.

## Scores
Carried forward from round 3, since the inputs are unchanged apart from the line above.
- trigger clarity: 2, "Create a new Claude-ready project folder ... Explicit command; run it once per new project, then open the folder and run /setup-project. Example: \"/new-project my-app\"."
- structure: 2, essence, When to use, numbered Process (8 steps), Worked example, Output, Rules, 83 lines, no supporting files.
- worked example: 2, `cd -- '/Users/ana/code' && pwd -P && init-project.sh 'invoice-tracker' --ui --language de`, "First line `/Users/ana/code`, exit 0, no `hooks skipped` line", plus the refusal of `my app`.
- precision: 2. Every claim holds against `bin/init-project.sh` and `bin/resolve-language.sh` as they stand:
  - The name pattern is the same as script line 49.
  - The language order matches lines 59-62.
  - The warning texts match lines 143 and 166.
  - The script's own "Next steps" with `--push` (line 292) is named and ruled out.
  - The Output list is accurate.
  - Lines 28-30 check `test -e '<parent>/<name>'` before the run, and lines 44-46 handle the script's `already exists` exit (lines 55-58) correctly.
- safety integration: 2. The name is checked on Claude's side before any shell (lines 18-23). A `'` in the parent folder is refused, and the folder is otherwise single-quoted (lines 25-26). Everything runs in one call and the path is reported from `pwd -P` (line 36). Guardrails 1 is referenced for the outward step (lines 52-55, 81-82).

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)
Every criterion is at 2 and nothing is Critical. This is stop condition 1 in `docs/eval-framework.md`.

## Ceiling: 10/10
Reached.

## Findings
None under the stated threat model:
- nothing is created in a folder the user did not confirm
- nothing goes outward without an explicit yes
- no user text reaches a shell outside the check on Claude's side plus quoting
- no mismatch with the scripts
- no criterion below 2

The `CLAUDE_CONFIG_DIR` change opens no shell path and creates no files, since `resolve-language.sh` only reads. Two edge cases fail safely and are not findings: a missing parent folder, and a `~` inside quotes. Both fail at `cd` before anything is created.

## Map duty
Done: `docs/system-map.md` line 21 lists `/new-project`.

## Integrity
Odeo's own skill, not a community contribution; no copied text was found.

## Behavior
Form only was reviewed. A short `/improve` subagent run is still recommended. Suggested inputs:
- the names `my app` and `x;touch pwned`
- a parent folder containing a space
- an existing `<name>` folder.

## Vs previous version
Trajectory: 8/10 -> 9/10 -> 10/10, unchanged by this re-anchor.
- Round 1 (0e42972): 8/10, FAIL on a Critical (user text reached the shell unchecked, and the `cd` and the run were separate calls).
- Round 2 (387fc3a): 9/10, PASS. Safety integration went from 1 to 2. Precision stayed at 1 because the failure branch called a pre-existing folder "incomplete".
- Round 3 (0f29848): 10/10, PASS. Precision went from 1 to 2.
- Re-anchor (63f73d9): 10/10, PASS. The skill and `init-project.sh` are unchanged. The one-line `CLAUDE_CONFIG_DIR` change in `resolve-language.sh` leaves the step 4 wording true.

## History
- 2026-09-23, round 1: FAIL 8/10 at 0e42972.
- 2026-09-23, round 2: PASS 9/10 at 387fc3a.
- 2026-09-23, round 3: PASS 10/10 at 0f29848.
- 2026-09-24, re-anchor: PASS 10/10 at 63f73d9, regenerated after reading the changed input. Not re-dated.
