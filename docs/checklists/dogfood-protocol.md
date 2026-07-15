# Dogfood protocol, the end-to-end system test

Goal: run ONE small, real product slice through the whole system in a FRESH
session, exactly as a new user would, and record where it shines and where it
grinds. The tester makes decisions and approves gates; the system does the work.

## What this test proves (and what it doesn't)
- Proves: the full loop works end to end (setup -> spec -> build -> merge ->
  learn), the gates actually fire, the guidance (/start, /guide) actually guides,
  the instructions survive a real session (context weight), and where a
  non-developer feels lost.
- Doesn't prove: multi-week loops (/product-signal, /outcome need real usage
  over time), community flows, marketplace install. Those get their own checks.

## Test product (pick before starting)
Something tiny but real, ONE epic, 3-4 stories. Default suggestion: a Pomodoro
focus timer with a session log (data model, timer, log view, daily summary).
Anything the tester actually wants also works, scope it to one thin slice.

## Setup (2 commands, in a NEW terminal tab)
```
cd ~/code && init-project.sh dogfood-app        # answer the UI question (Y)
cd dogfood-app && claude                        # FRESH session, the test runs here
```
Fresh session matters: the system must load clean, no help from an ongoing chat.

## The script (what to type, in order)
Each step lists WHAT TO OBSERVE. When you notice something odd, SAY IT TO THE
TEST SESSION right there ("note: X didn't happen / felt heavy"), it lands in
the transcript, which is what the analyst reads. No separate notes file needed;
grades are collected by the analyst afterward.

1. `/start` , empty project. OBSERVE: does it give clear entry points?
2. `/setup-project` , new project path; pick a simple stack or say "you choose";
   accept the dev-rigor default; turn "teach me as I go" ON.
   OBSERVE: plain language? question count bearable? CLAUDE.md filled correctly?
3. Ask in plain words: "how do I get from an idea to shipped here?"
   OBSERVE: does /guide auto-activate and give a route (not an essay)?
4. `/prd` for the test product. Answer its questions from your own head.
   OBSERVE: problem-first? does it stop you from jumping to features?
   Then: does it OFFER the pm-reviewer scoring gate by itself? Let it score.
5. `/critique` , OBSERVE: findings feel real or theatrical? revise if real.
6. `/stories` , OBSERVE: dependency order? binary acceptance criteria?
   pm-reviewer gate again.
7. `/build` , say your work is "clearly defined" (Mode B expected).
   OBSERVE the pipeline IN ORDER: worktree-parallel-check ran? architect produced
   a plan file in docs/plans/ (header, file map, exact tasks, no placeholders)?
   You APPROVED before any code? builders ran in worktrees? reviewers scored and
   wrote eval records (docs/evals/, with branch: field)? Try 2 independent
   stories in parallel if offered.
8. Gate test (deliberate): try `git push origin main` from the project.
   EXPECT: pre-push hook refuses. Try staging a fake secret
   (`echo 'API_KEY="sk_live_test123456789012"' > x.ts && git add x.ts && git commit -m t`).
   EXPECT: commit blocked. Note both results, then clean up (`git checkout . ; rm -f x.ts`).
9. Create the project's own PRIVATE repo for the PR step:
   `gh repo create dogfood-app --private --source=. --remote=origin --push`
   (this exposes NOTHING of the system, only the test app).
10. `/merge` the first approved story. OBSERVE: merge-gate ran FIRST? refused
    anything it should have? PR flow clean? serialized for the second story?
11. `/learn` , did anything non-trivial get solved? OBSERVE the draft-first gate.
12. `/retro` , OBSERVE: lessons routed with your approval only.
13. Free play (5 min): ask anything ("what now?", "can this do X?").
    OBSERVE: /start//guide answers vs confusion; any invented commands (must be none).

## What to grade (the tester's verdict, 1-5 each, in DOGFOOD-NOTES.md)
- Clarity: did you always know what to do next?
- Trust: did gates and reviews feel real (not theater)?
- Friction: how often did process feel heavier than the work deserved?
- Honesty: any fabricated data, invented commands, false "done"?
- Language: plain enough? teach-me asides useful?

## If something breaks or you get lost
Note it (that IS the finding), ask /guide once; if truly stuck, stop the step
and move on. A broken step is a result, not a failed test.

## After the test (analysis, back in the main session)
Everything is readable from disk, nothing manual to export:
- the session transcript (Claude Code saves every session as .jsonl under
  `~/.claude/projects/<project-path>/`),
- the project itself (git history, docs/plans, docs/evals, lessons.md),
- your `DOGFOOD-NOTES.md`.
The analyst reads all three, writes the findings + fixes into
`docs/checklists/dogfood-results.md`, and turns them into lessons and /improve runs.
