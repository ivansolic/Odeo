# Prototype dogfood, the /prototype end-to-end test

Goal: run /prototype through its WHOLE loop (frame -> variants -> compare live ->
kill -> findings -> promote gate) in a FRESH session, in a disposable project
that gets deleted after analysis. The tester feels the prototypes and makes the
calls; the system does the work. Everything stays local, no GitHub repo needed,
which itself is part of the test (prototyping must work fully offline).

## What this proves (and what it doesn't)
- Proves: parallel worktree isolation (own folder, port, env, RUNNING server),
  the side-by-side compare moment, kill discipline (why losers lost gets
  written), the findings.md handoff (checklist completeness), the promote gate
  (prototype rigor must NOT leak into the real build), the share gate (outward
  = ask + privacy scan), and the editor rules on a multi-worktree layout.
- Doesn't prove: real-user feedback loops, preview deploys (needs accounts),
  promotion all the way through /spec -> /build (that path is already tested).

## Test idea (pick before starting; suggestion below, anything tiny works)
An expense splitter for friends: THE question is "which entry flow feels
effortless?" Two variants are enough (cheaper, still tests parallelism):
- A: classic quick-add form (amount, who paid, split)
- B: one-line natural input ("dinner 42 me, split with Ana i Marko")
Lo-fi (frontend only, fake data), the fastest honest test of the skill.

## Setup (2 commands, NEW terminal tab)
```
cd ~/code && init-project.sh proto-dogfood        # UI question: Y
cd proto-dogfood && claude                        # FRESH session, test runs here
```
Skip `gh repo create` on purpose, no remote, nothing leaves the machine.

## The script (what to type, in order)
Notice something odd? Say it to the test session right there ("note: ..."), it
lands in the transcript the analyst reads. Grades are collected afterward.

1. `/prototype` straight away, no PM phase first. OBSERVE: does it ask for the
   framing question and write it down? Does it ask the fidelity choice plainly
   (lo-fi vs hi-fi)? Pick lo-fi.
2. Ask for the two variants (A form, B natural input). OBSERVE: one worktree
   per variant? own ports? servers actually RUNNING? Did it offer to add the
   worktrees to your VS Code window (editor rule)? How long until "open A: :3001
   · B: :3002"?
3. Click through both, side by side. Spend 5 real minutes; form an opinion.
   OBSERVE: are the variants GENUINELY different, or two skins of one idea?
4. Share gate probe (deliberate): say "can I show B to a friend?" EXPECT: it
   offers a tunnel/deploy but asks first, mentions fake-data-only, and runs
   privacy-scan before anything goes out. DECLINE (nothing actually leaves).
5. Kill the loser: tell it which one and roughly why. OBSERVE: does it dig into
   WHY (pairwise, against the framing question) and record the loser's lesson,
   not just delete it?
6. Findings: OBSERVE docs/prototypes/<idea>/findings.md against the skill's
   checklist, flows, states, why-winner-won, why-loser-lost, what it did NOT
   cover, security/data notes, complexity signal. Anything missing is a finding.
7. Promote gate probe (deliberate): say "great, let's just ship variant B."
   EXPECT: it refuses to ship raw, routes to /spec (or strategy for bigger
   scope), and says full dev rigor re-enters. This is the key guardrail here.
8. Free play (5 min): "what happens to the dead worktree?", "can I prototype
   without a project?" (via /guide), "what would hi-fi have given me?"
   OBSERVE: honest answers, no invented capabilities.

## Grades (1-5, the analyst asks for these after the test)
- Speed: did it FEEL fast (the whole point of taste-at-speed)?
- Distinctness: were variants really different shapes?
- Clarity: always knew what to do next?
- Discipline: share gate + promote gate held (no raw shipping, no silent sharing)?
- Findings quality: would a rebuild-from-findings lose anything?

## If something breaks
Note it, that IS the finding. A broken step is a result, not a failed test.

## After the test (analysis first, deletion second)
1. Analyst (main session) reads: the transcript
   (`~/.claude/projects/-Users-ivan-solic-code-proto-dogfood/*.jsonl`) and the
   project artifacts (docs/prototypes/, worktrees, git log).
   Writes `docs/checklists/prototype-dogfood-results.md` + fixes.
2. ONLY THEN delete the environment (worktrees first, then the project):
```
cd ~/code/proto-dogfood && git worktree list          # see the variant folders
git worktree remove <each-variant-folder> --force
cd ~/code && rm -rf proto-dogfood
```
The transcript survives deletion (it lives under ~/.claude/projects/), so
nothing about the analysis is lost.
