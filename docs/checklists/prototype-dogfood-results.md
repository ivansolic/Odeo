# Prototype dogfood results, /prototype end-to-end test

Analyst: Claude (main session) · Test: 2026-07-15, one fresh session (~260 KB
transcript), disposable project `proto-dogfood`, model per session default.
Tester: Ivan (drove all decisions). Idea: expense splitter, framing question
"which entry flow feels more effortless, quick-add form (A) vs one-line natural
input (B)?", lo-fi, 2 variants. Verdict of the test itself: **A won, B killed
with recorded rationale; the loop closed end to end.**

## What worked (verified in the transcript)

- **Framing question**: asked, written as one sentence, confirmed before any
  build (AskUserQuestion used well: describe-it vs help-me, lo-fi vs hi-fi,
  stack choice with an honest recommendation).
- **Isolation exactly as designed**: two worktrees (`prototype/expense-a|b`),
  own ports (3001/3002), background static servers, SHARED seed data so the
  comparison isolated the one variable (entry flow). Clean experiment design.
- **Kill discipline**: the tester's own words about WHY B lost ("commands like
  `split all` need to be written, not intuitive") were captured verbatim into
  the kill rationale, exactly the "record why losers lost" rule.
- **findings.md is a model artifact**: every checklist item present, flows,
  states, implied stories, edge cases (penny rounding!), security notes that
  feed a future PRD pre-mortem (PII, IDOR, money-as-integer), what was NOT
  covered, complexity signal. Rebuild-from-findings would lose nothing.
- **Promote gate presented correctly**: winner shown with "your call" options;
  no attempt to ship raw. Git discipline held ("commit needs a branch, only
  when you say so").
- **Honesty**: B's parser named "genuinely naive" so the comparison read fair;
  free-play questions (whole process? prototype without a project? what would
  hi-fi add?) answered without invented capabilities.
- **Self-improvement loop fired in the test session itself**: after the
  tester's correction it drafted the lesson, asked before writing, and recorded
  it in the project's lessons.md, the exact corrections protocol.
- **Cleanup on request**: servers killed, worktrees force-removed, verified.

## Findings

### P1, "present live" never opened anything (HIGH, the tester caught it live)
The URLs were printed as text; the browser was NOT opened (`open http://...`)
and VS Code was never offered, the editor rule (reuse, never multiply) was
added to /build but not to /prototype. Tester: "you did not offer to open vs
code for me and you did not automatically open localhost in browser."
**Fix**: /prototype step 4 opens each variant in the browser and offers adding
the worktrees to the existing editor window (`code --add`), same ladder as
/build (code -> cursor -> graceful skip).

### P2, findings.md left UNTRACKED (MEDIUM)
The "durable handoff" was never committed (session correctly refused to commit
to main and then the test ended). An untracked findings file dies with the next
cleanup, durable must mean committed.
**Fix**: /prototype step 7 commits the findings on a `chore/prototype-findings`
branch and offers /merge (docs-only PR), stated explicitly in the skill.

### P3, variants built inline, not by builder agents (OBSERVATION, not a defect)
The skill says builders "may" work in parallel; for two vanilla lo-fi pages the
session built them inline, which was faster than dispatching agents. Fine as
is; worth keeping the "may" wording (agents pay off at hi-fi or 3+ variants).

### P4, coverage gaps (protocol, not product)
The deliberate share-gate probe ("can I show B to a friend?") and the explicit
promote-refusal probe ("let's just ship B") were not exercised; the share gate
remains UNTESTED end to end (privacy-scan-before-tunnel). Promote gate was
half-covered (options presented properly, refusal path not provoked).

### P5, DOGFOOD-NOTES.md never materializes (PROTOCOL fix)
Second test in a row with no notes file and no written grades, but the
tester's in-session message WAS the perfect observation channel (it landed in
the transcript, the analyst found it immediately).
**Fix**: dogfood protocols drop the notes-file ritual; the official mechanism
becomes "tell the test session your observation as it happens" (it lands in
the transcript), plus grades asked by the analyst afterward.

## Tester grades (1-5): PENDING, to be added
Speed: _ · Distinctness: _ · Clarity: _ · Discipline: _ · Findings quality: _
(Qualitative from the session: variants genuinely distinct; decision was easy
and clear; the one friction named was P1.)

## Sample artifact
The test's findings.md is preserved as `docs/examples/prototype-findings-example.md`
(fake data only), it doubles as the reference example of what /prototype's
handoff should look like.

## Environment
Deleted after this analysis per protocol (worktrees were already removed by the
session; the project folder removal is the analyst's last step, transcript
survives in ~/.claude/projects/).
