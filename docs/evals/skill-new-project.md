---
artifact: skills/new-project
type: skill
branch: feature/plugin-install
reviewed_commit: 0f29848
artifact_version: 3
date: 2026-09-23
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---
# Skill review: new-project (explicit command), round 3

Output language: en (handed at dispatch). Tier note: `strong` is declared because the
judging model is Opus class, which is certainly "sonnet class and up"; whether it is the
top tier on this subscription was not verified live, so `strongest` is not claimed.

## Scores
- trigger clarity: 2, "Create a new Claude-ready project folder ... Explicit command; run it once per new project, then open the folder and run /setup-project. Example: \"/new-project my-app\"." This is the plain what-you-get format an explicit command needs.
- structure: 2, essence, When to use, numbered Process (8 steps), Worked example, Output, Rules, 83 lines, no supporting files.
- worked example: 2, `cd -- '/Users/ana/code' && pwd -P && init-project.sh 'invoice-tracker' --ui --language de`, "First line `/Users/ana/code`, exit 0, no `hooks skipped` line", plus the refusal of `my app`. Real values, directly imitable.
- precision: 2. Every claim checked against `bin/init-project.sh` and `bin/resolve-language.sh` holds:
  - The name pattern is the same as script line 49.
  - The language source order (parent folder's `CLAUDE.md`, then the global default) matches `resolve-language.sh` lines 60-62.
  - The warning texts match lines 143 and 166.
  - The script's own "Next steps" with `--push` (line 292) is named and ruled out.
  - The Output list is accurate (two commits, `.gitignore`, `.claude/settings.json` only when the template ships one).
  - The round-2 finding is closed. Lines 28-30 check `test -e '<parent>/<name>'` before the run. Lines 44-46 treat the script's `already exists` exit (lines 55-58) as "the user's own and was not touched", separately from an incomplete scaffold.
- safety integration: 2. Lines 18-23 check the name on Claude's side before any shell. Lines 25-26 refuse a `'` in the parent folder and single-quote it. Line 36 runs everything in one call and reports the path from `pwd -P`. Lines 52-55 and 81-82 point to `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 1 for the outward step, without restating it. The new `test -e` interpolates only the already-checked name and the single-quoted parent, so it opens no new way into the shell.

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

Two edge cases fail safely and are not findings: a named parent folder that does not exist makes `cd` fail before anything is created, and a `~` inside single quotes does not expand, which also fails at `cd`.

## Map duty
Done: `docs/system-map.md` line 21 lists `/new-project`.

## Integrity
Odeo's own skill, not a community contribution; no copied text was found.

## Behavior
Form only was reviewed; behavior was not tested. A short `/improve` subagent run is still recommended because the skill tells Claude what to run. Suggested inputs:
- the names `my app` and `x;touch pwned`, which should be refused before any shell
- a parent folder containing a space
- an existing `<name>` folder, which should be caught by the step 2 `test -e`.

## Vs previous version
Trajectory: 8/10 -> 9/10 -> 10/10.
- Round 1 (0e42972): 8/10, FAIL on a Critical (user text reached the shell unchecked, and the `cd` and the run were separate calls). Precision 1, safety integration 1.
- Round 2 (387fc3a): 9/10, PASS. Safety integration went from 1 to 2 (check on Claude's side, quoting, one-call run). Precision stayed at 1 because the rewritten failure branch called a pre-existing folder "incomplete".
- Round 3 (0f29848): 10/10, PASS. Precision went from 1 to 2: step 2 now checks up front whether the folder exists, and the failure branch treats `already exists` separately from an incomplete scaffold.

## History
- 2026-09-23, round 1: FAIL 8/10 at 0e42972.
- 2026-09-23, round 2: PASS 9/10 at 387fc3a.
- 2026-09-23, round 3: PASS 10/10 at 0f29848. Record regenerated, not re-dated. The loop ends at round 3 on PASS at max score, within the cap.
