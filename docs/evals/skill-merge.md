---
artifact: skills/merge/SKILL.md
type: skill
branch: docs/merge-two-history-guard
reviewed_commit: 86ad820
artifact_version: 2
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 8/10
---

Scope: the whole `skills/merge/SKILL.md` (126 lines, the only file in `skills/merge/`) at commit
`86ad820` on `docs/merge-two-history-guard`, the sha supplied at dispatch. Round 2. Read against
`docs/skill-authoring-standard.md` and its rubric; re-read every site round 1 named as an
unguarded copy (`AGENTS.md:142-153`, `global/CLAUDE.md:61`, `WORKFLOW.md:592-614`) and the four
sites the coordinator deliberately left alone (`WORKFLOW.md:352,833`, `README.md:99`,
`BEGINNERS-GUIDE.md:376`, `skills/build/SKILL.md:143`), plus `bin/merge-gate.sh:1-95`,
`bin/publish-snapshot.sh:19-33`, `docs/system-map.md:68`. Form only, no runtime behavior tested.
Output language `en`, supplied at dispatch.

## Skill: merge  (explicit command, `disable-model-invocation: true`, intentional: the merge is
the human floor)

## Scores

- trigger clarity **2** (was 2). `:2` keeps the explicit-command form ("what the user gets, when
  to run it") and closes round 1's residual: the description no longer promises the rebase
  unconditionally but names both outcomes, "Checks that the remote really is this branch's
  upstream, then rebases... when the remote is a publication rather than an upstream, it
  integrates locally instead and says so." Four sentences, still plain, still accurate to the
  body.
- structure **2** (was 2). 126 lines against the 500 limit, one file, so progressive disclosure is
  trivially satisfied. The standard's shape holds with a section added where the process now
  forks: essence `:6-8`, human floor `:10-13`, preconditions `:15-17`, steps `:19-76`, ordinary
  worked example `:78-88`, `## Two histories` `:90-105`, parallel and contributor cases
  `:107-115`, safety rules `:117-125`. The second transcript is not padding against "one
  excellent example beats several mediocre ones": the process genuinely forks at 1b, and each
  branch gets exactly one complete example. Residual, unchanged and not score-bearing: `1b.` is
  still not a CommonMark ordered-list marker, so `:27-47` renders as a continuation of step 1
  (the fenced block at `:29-32` survives it, since a fence may interrupt a paragraph). Agents
  read raw text and the numbers are now referenced from four other files, so stability is worth
  more than the wart.
- worked example **2** (was 1). The round-1 reason for the 1 was specific and is gone: the ordinary
  transcript now carries the guard at `:82`, "upstream check: main is an ancestor of origin/main
  -> ordinary upstream, rebase applies", so imitating the example no longer reproduces the
  sequence the change exists to prevent. The second transcript `:93-103` is concrete in the same
  way the first is (real branch name, real gate line, real commands) and ends where the process
  actually ends, on a sentence the reader can say out loud: "Publishing is a separate step".
  `:100` says "push: to the private working remote only" without naming it, which keeps the
  example true in a public clone. Two residuals, neither score-bearing, both in fixes below: the
  `--ff-only` integrate line assumes local `main` has not moved, and the record filename in the
  second gate line follows a different convention from the first.
- precision **2** (was 1). Both defects that held the 1 are gone, and the replacement is sharper
  than what round 1 proposed:
  1. The rotting present-tense measurement is gone. The counts survive only at `:104-105` as an
     illustration that explicitly refuses to decide: "The counts are worth seeing but never
     deciding on: a project can read `278  3` or `6  3` and be the same case." That is now true
     in a public clone, where the reader's own count is `0  0`, because the sentence no longer
     claims to describe the reader's repo.
  2. The size threshold is gone, replaced at `:30-31` by two exact, runnable commands
     (`git merge-base --is-ancestor` each way) and, for the genuinely diverged case, one binary
     question with three concrete signals: a pre-push hook that refuses the remote, a publish or
     snapshot script, a denylist of internal paths (`:34-38`). No number, no "large", and
     `:43-47` states in the file why no number is coming, which stops the next reader from
     reinstating one. Signals are named by KIND, not by this project's paths, so the block
     travels to other repos.
  Residuals, none score-bearing, all in fixes: `--is-ancestor` communicates by exit status and
  prints nothing, which the `# yes ->` comments do not say; `main` is still hardcoded while
  `merge-gate.sh` takes a base ref; and the "you are ahead" branch has no publication check.
- safety integration **2** (was 2). Unchanged level, strictly better content. The step-1b hazard is
  now stated at every point of use inside the file: step 2 is conditional and points back
  (`:48-50`), step 6 names its own `git pull` as "the same hazard as step 2 in a second costume"
  (`:64-65`), and the safety rule at `:119-122` now voids steps 2, 4, 5 **and** 6, with the reason
  attached to each. It still references the enforced guardrails rather than owning them
  (`merge-gate.sh`, `boundary-check.sh`, STOP on non-zero at `:20-25`), keeps the human floor and
  its three named rationalizations at `:10-13`, and keeps the honesty rule in its own voice at
  `:52-53`. One residual carried from round 1, still open (fix 4): step 0's enumeration of the
  gate's refusal reasons is a restatement that has already drifted from the script.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no criterion at 0)

## Ceiling: 10/10, reached

No criterion is structurally capped for this artifact: it is an explicit command (trigger clarity
scores natively), real enforced guardrails apply (safety integration can reach 2), and the process
has a worked example for each of its two paths. The remaining items below are fixes, not score
deductions; saying so explicitly so nobody reads 10/10 as "nothing left to do".

## Round-by-round

| Criterion | Round 1 | Round 2 | What moved it |
|---|---|---|---|
| trigger clarity | 2 | 2 | residual closed (description names both outcomes) |
| structure | 2 | 2 | a section added at the fork, still lean |
| worked example | 1 | **2** | guard line in the ordinary transcript + a second complete transcript |
| precision | 1 | **2** | rotting measurement removed; size threshold replaced by ancestry + one binary question |
| safety integration | 2 | 2 | same level, hazard now stated at all four points of use |

## The three things I was asked to check

**1. Did the placement fix miss a site? I found no missed instructing site.** Round 1's complaint
was that step 1b fired only for a reader starting at line 1. It now fires at every entry point I
can name: step 2 (`:48-50`, conditional, with a skip-to pointer for a reader who lands there
mid-flow), step 6 (`:64-65`, the hazard round 1 caught in its second costume), the frontmatter
description (`:2`), the ordinary transcript (`:82`), and a whole transcript for the other path
(`:93-103`). Outside the skill, all three INSTRUCTING sites now carry it: `AGENTS.md:148-152`,
`global/CLAUDE.md:61`, `WORKFLOW.md:601-604`.

**I agree with leaving the four one-liners unqualified**, and the line you drew is the right one,
so it is worth stating as a rule rather than as four decisions: qualify every site that tells
someone to RUN a rebase; leave every site that NAMES the command. `WORKFLOW.md:352,833`,
`README.md:99`, `BEGINNERS-GUIDE.md:376` and `skills/build/SKILL.md:143` all read "/merge (rebase
onto main, test, merge PR, cleanup)", which routes the reader into the file that holds the guard;
nobody rebases by hand from a table row. Qualifying them would also violate the standard's
don't-restate rule and create four more copies to keep in sync, which is the failure mode this
change was made to avoid. `docs/system-map.md:68` is the same class and I would leave it too.
The map duty is satisfied either way: no command was added and the map's claim about `/merge`
is still true.

**2. The ancestry rewrite is correct and general.** It asks about lineage, which is the property
that actually distinguishes the cases, and it keeps the ordinary diverged case ordinary ("still
ordinary when someone else pushed while you worked", `:33-34`) before asking the publication
question. A contributor 200 commits behind a busy upstream is never flagged. It also holds on the
motivating case for a structural reason, not by luck: `bin/publish-snapshot.sh:32` materializes
the public tree with `git archive`, which copies content and no history, so the published
commits can never be ancestors of yours and yours can never be ancestors of theirs once the lines
have split. "Neither is an ancestor" is therefore the permanent state of that setup, not a
snapshot of it.

**3. Your rejection of my `git merge-base` suggestion is correct, and I would not have salvaged
it.** I cannot run git, so I take `1955085` as reported, but the measurement is what the
construction predicts: the public repo was seeded from this one, so the two lines share the
original root, and an emptiness test on a shared-root pair is silent by definition. My round-1
text did carry a fallback ("otherwise ask what the left-side commits ARE"), so the suggestion was
not wrong as written, but I gave first billing to a test that is sufficient and not necessary,
and that is silent on the exact case the change exists for. First billing to a silent test is bad
guidance whatever follows it; the prominence was the error and you were right to cut it. I also
checked whether a stronger merge-base test survives: the discriminating version is the POSITION
of the base (a base at the root means the lines split at the beginning), and that reintroduces a
magnitude judgement, "how old is old", which is precisely what you removed. So the rejection
stands on its own terms, and recording it in the file at `:45-47` is the right call: it stops the
next reader, including a future me reading this skill cold, from reinstating it.

## Remaining fixes (none score-bearing; ordered by value)

1. **Say that `--is-ancestor` answers with an exit status, not with output** (`:30-31`). The
   command prints nothing, and this step's whole value is being decisive at the moment of highest
   risk; "no output" is exactly where an agent reports "inconclusive", which is the state the old
   failure lived in. Make it unambiguous in the block:
   `git merge-base --is-ancestor main origin/main && echo "behind -> rebase applies"` and the
   mirror for the other direction. This is the one item that would have held precision at 1 if
   the skill were hand-typed by a human rather than executed by Claude.
2. **Close the "you are ahead" branch** (`:31`). A publication remote that was originally SEEDED
   by a direct push reads as "origin/main is an ancestor of main -> you are ahead", and a reader
   who takes "ahead" as "so origin is my upstream" walks into steps 4, 5 and 6, which is the
   push the guard exists to prevent. One clause: "ahead only means upstream if your commits are
   meant to reach that remote directly; if the project publishes through a separate step, ahead
   is what a publication ALWAYS looks like, so ask the question below anyway."
3. **Note the `--ff-only` precondition in the Two histories transcript** (`:98`). If local `main`
   moved since the branch was cut, `git merge --ff-only` fails, and that is the exact moment
   someone types `git rebase origin/main` from muscle memory. One parenthetical: "(main moved?
   rebase onto LOCAL `main` first, that rebase is safe.)"
4. **(carried from round 1, still open) Stop restating the gate's refusal list** (`:21-24`). The
   skill names one refusal reason; `bin/merge-gate.sh` also refuses when a record does not
   approve, when it omits `model_tier`, when it omits `reviewed_commit` after the cutoff, and
   when an untracked non-ignored file sits under `docs/evals/`. The copy has already drifted,
   which is the standard's reason for reference-don't-restate. Replace with: "It prints exactly
   which precondition failed (usually: run the reviewers so an approving record exists). Fix what
   it names, re-run, only then continue."
5. **(carried, minor) `main` is hardcoded** while `merge-gate.sh` accepts a base ref. One
   parenthetical at 1b ("or your project's base branch") covers `master` repos.
6. **(carried, cosmetic) `1b.` breaks the ordered list in rendered markdown.** Now that four other
   files cite "step 1b" by name, renumbering costs more than it saves; if it is ever done, update
   `:119`, `AGENTS.md:152` and `WORKFLOW.md:601-604` in the same commit.
7. **(consistency, trivial) The second gate line** (`:95`) names `docs/evals/skill-merge.md` for
   branch `docs/fix-the-thing`, while the first follows `code-<branch>.md`. Both are legal (the
   gate matches the frontmatter `branch:` field, not the filename), but a reader comparing the
   two transcripts may infer a rule that is not there.

**The durable fix is still a mechanism, and it is still not built.** Everything above is prose at
the point of use, which is a real improvement over a lesson in a ledger that did not fire, and it
is still something an agent can skim. `merge-gate.sh` already runs first, already refuses
deterministically, and does not need a fetch to see this: the existing `origin/main` ref is
enough to run both `--is-ancestor` tests and refuse when neither holds while a pre-push hook for
that remote exists. That is the version that cannot be skimmed past, and it is what the standard's
"pre-written scripts over agent-generated code for critical operations" points at.

**Recommended next step:** the form is now sound, so the open question is behavioral, which this
review does not test. Run an `/improve` subagent test before this is treated as settled: this is
a discipline-critical skill, so the framework's full rigor applies (5+ reps per variant), and at
least one variant should enter at step 2 rather than step 0, since that is the entry the round-1
finding was about.

**Integrity:** nothing in this skill reads as copied from another project; voice, named scripts
and offers are this system's own.

## History

- **Round 1, 2026-09-22, 8/10 PASS** (uncommitted working tree of `docs/merge-two-history-guard`;
  no sha was supplied and the change was not yet committed, so that record carried no valid
  anchor and said so). Scored the whole skill for the first time. The step-1b guard was correct in
  substance and correctly placed for a sequential reader, and was marked down for being
  incomplete: worked example **1** (the transcript still showed gate -> fetch -> rebase with no
  check, so the most imitated artifact in the file modelled the unsafe sequence) and precision
  **1** (a present-tense measured `278  3` plus a 42-file count, both of which rot and neither of
  which a public clone can reproduce; plus a magnitude threshold, "one side large and the other
  near zero", that is silent on a fresh split where two lineages are days old). Also raised: step
  2 readable standalone, step 6's `git pull` unguarded, three unqualified copies of the imperative
  outside the skill, and a stale restatement of the gate's refusal list.
- **Round 2, 2026-09-22, commit `86ad820`, 10/10 PASS** (previous 8/10, improved). Both 1s moved
  to 2 on evidence, not on effort: the ordinary transcript now carries the upstream check and a
  second complete transcript covers the publication path, and the rotting measurement and the size
  threshold are both gone, replaced by two ancestry commands plus one binary question that is
  numberless and portable. The placement finding is fully addressed at five points inside the file
  and three instructing sites outside it; leaving the four descriptive one-liners unqualified is
  correct and is now stated as a rule (qualify instructions, not command names). My own round-1
  `git merge-base` emptiness suggestion was measured and rejected, and the rejection is right: the
  two lines share a root, the test is sufficient but not necessary, and the only discriminating
  version of it reintroduces the magnitude judgement that was just removed; the file now records
  this so it is not reinstated. Seven fixes remain open, all non-score-bearing, led by the
  `--is-ancestor` exit-status wording and the "you are ahead" branch; the deterministic check in
  `merge-gate.sh` remains unbuilt and is still the only version of this guard that cannot be
  skimmed past.
