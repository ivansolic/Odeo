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

### P4, coverage gaps (protocol, not product), share half CLOSED same day
The share path was then tested end to end in a follow-up run (see "Share test"
below); only the explicit promote-refusal probe ("just ship it") remains
unprovoked, options were presented properly, the refusal path awaits the first
real occasion.

### P5, DOGFOOD-NOTES.md never materializes (PROTOCOL fix)
Second test in a row with no notes file and no written grades, but the
tester's in-session message WAS the perfect observation channel (it landed in
the transcript, the analyst found it immediately).
**Fix**: dogfood protocols drop the notes-file ritual; the official mechanism
becomes "tell the test session your observation as it happens" (it lands in
the transcript), plus grades asked by the analyst afterward.

## Share test (follow-up, same day, same disposable project)

Ask: "can I show variant A to a friend?", then all the way to a live public URL.

**What held (the share gate worked as designed):**
- Multiple explicit consents before anything went out: fake-data-only stated,
  share-mode options offered (local / tunnel / preview deploy), a per-step OK.
- **Honest refusal of the risky path**: preview deploy via GitHub Pages would
  have made the repo PUBLIC and indexable; the session named that plainly and
  would not proceed without an explicit go, the user pivoted to a tunnel.
- Missing tool handled correctly: cloudflared absent -> asked before
  `brew install`, explained the tunnel is ephemeral (dies with the machine).
- Data verified before exposure (only the four fake names; no emails, tokens,
  IPs), then the tunnel URL was delivered, verified via curl, and opened.
- **P2 proved itself in practice**: the uncommitted variant was GONE and had to
  be rebuilt before sharing, exactly why findings/prototypes must be committed.
- Bonus, unscripted: the user iterated on the LIVE shared prototype (add a
  detail view). The session distinguished a real bug from browser cache, found
  a genuine CSS issue (author `.overlay{display:grid}` beating the built-in
  `[hidden]` rule), fixed and verified it through the tunnel.

**New findings:**
- **S1 (MEDIUM): no share teardown lifecycle.** The session ended with the
  tunnel + server still running; the analyst found the prototype still exposed
  and killed it. The user never said "stop sharing", but the skill must own
  the lifecycle: state the exposure plainly when the URL is handed over, and
  proactively offer teardown at any natural end of the conversation.
  **Fix**: /prototype share step gets an explicit teardown contract.
- **S2 (LOW): privacy-scan.sh not found, wrong lookup.** The script WAS
  installed (~/bin, on PATH) but the session looked in the skill's own folder,
  concluded "not installed", and ran a manual equivalent scan (which was
  honest and thorough, but [I] where [E] was available).
  **Fix**: the skill names the install location.
- **S3 (LOW): stale-cache friction on live-edited shared prototypes.** Edits
  behind a tunnel + `http.server` needed cache-busted reloads; the session
  coped (`?v=timestamp`) but only after user frustration. The skill's share
  step now notes cache-busting for live iteration.

## Tester grade
Overall: **4/5** (single overall grade; dimensions not graded separately).
Qualitative from the session: variants genuinely distinct; the decision was
easy and clear; the one named friction was P1 (nothing opened automatically).

## Sample artifact
The test's findings.md is preserved as `docs/examples/prototype-findings-example.md`
(fake data only), it doubles as the reference example of what /prototype's
handoff should look like.

## Environment
Deleted after this analysis per protocol (worktrees were already removed by the
session; the project folder removal is the analyst's last step, transcript
survives in ~/.claude/projects/).
