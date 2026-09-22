---
artifact: skills/merge/SKILL.md
type: skill
branch: docs/merge-two-history-guard
reviewed_commit: none-supplied-working-tree
artifact_version: 1
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
previous_total: n/a
---

Scope: the whole `skills/merge/SKILL.md` (94 lines, the only file in `skills/merge/`), read as it
stands in the WORKING TREE of branch `docs/merge-two-history-guard`. The step-1b change is
UNCOMMITTED at review time, so no commit contains the text scored here. Round 1, so the whole
skill is scored, not only the change. Read against `docs/skill-authoring-standard.md` and its
rubric; cross-read `bin/merge-gate.sh:1-95`, `docs/system-map.md:12-14,68-72,137`,
`docs/internal-paths.txt`, `docs/public-paths.txt:15`, `AGENTS.md:142-148`,
`global/CLAUDE.md:61,198`, `WORKFLOW.md:592-611`. Form only, no runtime behavior tested.
Output language `en`, supplied at dispatch.

**This record is incomplete on purpose.** The dispatcher asked me to resolve `reviewed_commit:`
with `git rev-parse HEAD`; I have no shell, and I was handed no sha. I will not transcribe or
guess one. Beyond that, the reviewed change is uncommitted, so there is no commit that contains
the scored text: even a correct HEAD sha would anchor this record to a tree that does not have
step 1b in it. Commit the change, then re-dispatch me with the sha of the commit that carries it
and I will regenerate this record. Until then `reviewed_commit:` does not name a real commit and
`merge-gate.sh` will refuse, which is the safe failure.

## Skill: merge  (explicit command, `disable-model-invocation: true`, intentional: the merge is
the human floor)

## Scores

- trigger clarity **2**. Explicit-command form, which the standard defines as "say what the user
  gets and when to run it, in plain language": `:2` does both, "Integrate a finished, reviewed
  story branch into main, safely and with a clean linear history... Run once per story when it is
  approved and ready. Claude does the git mechanics; you approve." The invocation shape is
  obvious and is shown anyway at `:67`. `disable-model-invocation: true` is set, so the "Use
  when..." rule for auto-invoked skills does not apply. One residual, not scoring: the same line
  promises "Rebases onto the latest main" unconditionally, which is exactly the claim step 1b now
  qualifies (see fix 3).
- structure **2**. The standard's body shape, in order: essence `:6-8`, the never-self-start rule
  `:10-13`, when-to-use as `## Preconditions` `:15-17`, numbered process `:19-63`, worked example
  `:65-74`, the parallel and contributor cases `:76-84`, safety rules `:86-93`. 94 lines against
  the 500 limit, one file in the folder, so the one-level-deep rule is trivially satisfied.
  Residual: `1b.` is not a CommonMark ordered-list marker, so the twelve-line block at `:27-38`
  renders as a lazy continuation of step 1 rather than as its own item. Agents read the raw text,
  so this does not hide the step, and keeping the numbers stable is defensible while
  `WORKFLOW.md:601-607` mirrors them; it is a rendering wart, not a structural failure.
- worked example **1**. Concrete and real-valued, which is what the criterion rewards:
  `feature/usr-012-timer`, a real gate line ("merge-gate: preconditions hold (branch
  'feature/usr-012-timer', 1 record(s) checked: docs/evals/code-feature-usr-012-timer.md)"), real
  commands. It loses a point because it is now INCOMPLETE with respect to its own process: the
  transcript at `:70` goes straight from the gate to "fetch + rebase onto origin/main: clean",
  with no line for the step-1b count. The example is the part of a skill an agent imitates most
  literally, so as written the single most imitable artifact in the file models the sequence the
  change exists to prevent. This is a one-line fix (fix 2), not a rewrite; hence 1, not 0.
- precision **1**. Paths, script names and commands are exact throughout (`merge-gate.sh`,
  `boundary-check.sh`, `git push --force-with-lease`, `git remote set-head origin -a`,
  `gh pr merge --squash`, `vitest run`, `.github/workflows/`), and there are no TBDs. Two exact
  defects hold it at 1, both in the new block:
  1. `:36-38` states a MEASURED, PRESENT-TENSE fact: "Measured in this project's own working
     copy: `278  3`, with 42 files the local main carries". The standard bans time-sensitive
     facts that rot, and both numbers move on every commit and every eval record. `skills/` is on
     the publish allowlist (`docs/public-paths.txt:15`), so this ships; a reader who clones the
     PUBLIC repo and runs the command gets `0  0`, so the claim is unreproducible for exactly the
     audience that receives it.
  2. `:28-29` sets the discriminator as "One side large and the other near zero" versus "BOTH
     sides large", with no decisive test behind it. See fix 1: the judgement call is defensible,
     the chosen variable is not.
- safety integration **2**. It references the guardrails instead of owning them: step 0 defers to
  the enforced `merge-gate.sh` and to `boundary-check.sh` and says STOP on non-zero (`:20-25`);
  `:10-13` states the human floor and names the three rationalizations that break it ("The
  reviews passed", "the pipeline continues", "the user merged the last one" are not permission);
  `:42-43` carries the honesty rule verbatim in its own voice ("A suite that has never been
  executed is not green"); `:40` and `:93` forbid weakening a test to resolve a conflict. The new
  rule at `:88-90` adds the two-history case without contradicting anything else in the file.
  Two residuals, both fixes below, neither enough to drop this to the rubric's 0 ("contradicts or
  restates"), because the dominant behavior here is referencing by name: step 0's gloss of the
  gate's refusal reasons has already DRIFTED (fix 5), and the new rule's enumeration of voided
  steps is incomplete (fix 4).

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no criterion at 0)

## Ceiling: 10/10

Nothing about this skill structurally caps a criterion. It is an explicit command, which the
rubric handles natively under trigger clarity; real enforced guardrails apply, so safety
integration can reach 2; the two points lost are ordinary defects with cheap fixes.

## Answers to the five questions put to this review

**1. Does step 1b fire where it is placed? For a sequential reader, yes. For every other reader,
not yet.** It sits between `git fetch origin` and `git rebase origin/main`, so anyone reading the
numbered steps top to bottom cannot reach the rebase without passing it, and it carries its own
verdict rather than a pointer elsewhere. That is the right placement and it is a real improvement
over a ledger lesson. But the brief asked whether it is "impossible to read step 2 as standalone",
and it is not:
- `:39` is still a bare imperative, "`git rebase origin/main`, replay this branch's commits on top
  of the latest main", with no condition in the line and no back-reference to 1b. An agent
  resuming mid-flow ("continue the rebase", conflict resolution re-entry) or scanning for the
  command it recognizes hits an unguarded instruction.
- The worked example (`:70`) shows fetch then rebase with no 1b line.
- The frontmatter description (`:2`) promises the rebase unconditionally.
- Outside this file, `AGENTS.md:145`, `global/CLAUDE.md:61` and `WORKFLOW.md:601-602` all still
  carry the unqualified "rebase onto latest `origin/main`". `AGENTS.md` is read at session start;
  the skill is read only when `/merge` is invoked. The trap therefore survives in the documents
  most likely to be in context when someone rebases OUTSIDE `/merge`.
- Placement-not-wording is the right diagnosis, and by that same diagnosis prose at the point of
  use is still prose. The standard's own rule ("Pre-written scripts over agent-generated code for
  critical operations", the `privacy-scan.sh` principle) points at a deterministic check: a
  `bin/` helper, or a check inside `merge-gate.sh`, which already runs first and already refuses
  deterministically. It does not fetch, but the check does not need a fetch to detect this case:
  the existing `origin/main` ref is enough to see `278  3`. That is the version of this fix that
  cannot be skimmed past.

**2. Correct and general? Correct in substance, and the threshold variable is the wrong one.**
The block will not scare a normal user away from a normal rebase: the ordinary case is named
first and resolved with "you are behind, rebase". But the chosen variable (magnitude on both
sides) has failures in both directions, and the dangerous one is the false negative:
- False negative: two histories are two histories from the moment they split. A repo whose public
  line was cut last week shows `6  3`. Neither side is "large", the reader concludes "not the
  both-sides case", and rebases into exactly the disaster this block was written for. The
  property that matters is not size, it is lineage.
- False positive: a contributor 200 commits behind a busy upstream with 30 of their own commits
  on a fork's `main` sees "both sides large" and is told rebase is the wrong tool, when it is the
  right tool.
- Mislabelled ordinary case: the command compares `main` with `origin/main`, not the feature
  branch. A user who never commits to local `main` sees `0  N`, not "one side large and the other
  near zero". The normal reading is exactly zero on the left, which is a sharper statement than
  "near zero" and costs no number.
A numberless rule that is decisive: keep the count as the cheap smell, then make lineage the
test. `git merge-base main origin/main` returning nothing means no common ancestor at all,
certainly two histories. Otherwise the question is whether the left-side commits belong to this
line: any commit on your `main` that you did not make locally and do not intend to push means the
remote is not your upstream. Both are yes/no checks, both survive a fresh split, and neither
flags the 200-behind contributor.

**3. The `278  3` example in a public file: no leak, but it rots and it is unverifiable where it
lands.** Nothing private is exposed: no remote URL, no private repo name, no personal data, no
local path, and the two-remote publish model is already public through
`docs/internal-paths.txt`, `docs/public-paths.txt` and `bin/publish-snapshot.sh`. The problem is
the other two criteria: the standard bans facts that rot, and both `278  3` and "42 files" change
continuously; and `skills/` is allowlisted for publication, so the claim "measured in this
project's own working copy" arrives in a clone where the same command prints `0  0`. Keep the
shape, drop the present tense and the file count, and anchor the pattern to something durable
rather than to a count: the numbers work as an illustration of what the output looks like, not as
a live measurement. The measured instance belongs in the internal ledger, where it is evidence;
the public file needs only the shape and a pointer to the mechanism (`docs/internal-paths.txt`).

**4. The new rule duplicates nothing and contradicts nothing, but its enumeration is short and
the example's silence is a real coherence gap.** `:88-90` is the only place stating that steps
can be void, and a one-line restatement of 1b's conclusion in a safety-rules section is what such
a section is for, so the duplication is deliberate and acceptable. Two gaps:
- The enumeration names steps 2, 4 and 5 and stops. Step 6 is `git checkout main && git pull`,
  which in a two-history repo pulls the public line into local `main`: the same destructive move,
  one step later, explicitly listed as safe by omission. Step 6 also deletes a remote branch that
  does not exist in that case.
- The worked example shows only the ordinary path. That is the right choice (the standard wants
  one excellent example, not two mediocre ones), but it currently reads as a full transcript of
  the process, so a reader can finish the file believing the example covers every case. One line
  in the transcript fixes both that and the imitability problem in fix 2.

**5. Other findings.** Listed below, marked PRE-EXISTING or INTRODUCED.

## Top fixes

1. **(INTRODUCED, highest value) Replace the magnitude threshold with a lineage test at `:28-29`.**
   Keep the count as the smell, then: "No common ancestor (`git merge-base main origin/main`
   prints nothing) is decisive: two histories. Otherwise ask what the left-side commits ARE: any
   commit on your `main` that you did not make locally and do not intend to push means this
   remote is not your upstream. The ordinary case is a left side of 0, or only your own unpushed
   work." This closes the fresh-split false negative and stops flagging the contributor who is
   merely far behind.
2. **(INTRODUCED) Make step 2 unreadable as a standalone instruction, `:39`.** Change the line to
   "**Only if 1b showed one history:** `git rebase origin/main`, replay this branch's commits on
   top of the latest main." And add the check to the worked-example transcript between `:69` and
   `:70`: `upstream check: git rev-list --left-right --count main...origin/main -> 0  4 (one
   history, behind by 4)`. Those two edits are what turn a correctly-placed step into one that
   fires for a reader who did not start at line 1.
3. **(INTRODUCED) De-rot the example at `:36-38` before it is published.** Drop "Measured in this
   project's own working copy" and the "42 files" count; keep the shape: "What it looks like when
   it happens: `278  3`, a working repo whose `main` carries internal-only files that the public
   line is built never to receive (this system's own split: `docs/internal-paths.txt`)." Keep the
   measured instance in the internal ledger.
4. **(INTRODUCED) Extend the voided-step list at `:89`** from "steps 2, 4 and 5" to "steps 2, 4
   and 5, and the `git pull` and remote-branch deletion in step 6", naming why: `git pull` on
   `main` merges the other history into yours just as a rebase would.
5. **(PRE-EXISTING) Stop restating the gate's refusal list at `:21-24`.** The skill says the gate
   refuses when "no review record exists in `docs/evals/` for this branch"; `bin/merge-gate.sh`
   also refuses when a record does not approve, when it omits `model_tier`, when it omits
   `reviewed_commit` after the cutoff, and when an untracked non-ignored file sits under
   `docs/evals/`. The copy has already drifted, which is the standard's reason for the
   reference-don't-restate rule. Replace the enumeration with: "It prints exactly which
   precondition failed (usually: run the reviewers so an approving record exists). Fix what it
   names, re-run, only then continue."
6. **(PRE-EXISTING, outside this file, blocks the change's purpose) Qualify the same imperative
   where agents actually meet it:** `AGENTS.md:145`, `global/CLAUDE.md:61`, `WORKFLOW.md:601-602`.
   One clause each ("after confirming `origin/main` is this branch's upstream, see `/merge` step
   1b") keeps the single source in the skill and removes three unguarded copies. `WORKFLOW.md`
   also enumerates the `/merge` steps and is now out of sync with the skill.
7. **(PRE-EXISTING, minor) `main` is hardcoded** throughout while `merge-gate.sh` accepts a base
   ref (`merge-gate.sh [base-ref]`, default `main`). One parenthetical at step 1b ("or your
   project's base branch") covers `master` repos without touching every line.
8. **(PRE-EXISTING, cosmetic) `1b.` breaks the ordered list in rendered markdown.** If the numbers
   must stay stable, make it a bolded sub-item under step 1 instead; if not, renumber and update
   `:89` and `WORKFLOW.md:592-611` together.

**Map duty: satisfied.** `/merge` is already in `docs/system-map.md` (`:68`, plus the flows at
`:12-14` and `merge-gate.sh` at `:137`); the change adds no command and does not alter what the
map claims `/merge` does, so no map edit is owed.

**Integrity:** nothing in this skill reads as copied from another project. The voice, the named
scripts and the offers (`/learn`, `/retro`, `/sync-docs`, `/ci`) are all this system's own.

**Recommended next step:** fixes 1-4 are form and can be applied directly. Whether the guard
actually fires under pressure is a behavioral question this review does not answer: after the
edits, run an `/improve` subagent test (this is a discipline-critical skill, so the framework's
full rigor applies, 5+ reps per variant), with at least one variant that enters at step 2 rather
than step 0. The durable answer remains fix 1's mechanism in `merge-gate.sh`: a prose step is
still something an agent can skim past, and this skill's own history is a lesson that did not
fire.

## History

- **Round 1, 2026-09-22 (this record), 8/10 PASS.** First review of this skill; no prior record,
  so the whole file was scored, not only the pending change. The change under review (step 1b plus
  the two-history safety rule) is correct in substance and placed where a sequential reader must
  meet it before the rebase; it is scored down only where it is incomplete: the magnitude-based
  threshold misses a fresh split, the rebase step and the worked example are still unguarded, and
  the measured `278  3` is a rotting fact in a file that publishes. Points lost: worked example
  (1) and precision (1). Anchor missing: the change is uncommitted and no sha was supplied, so
  `reviewed_commit:` names no commit and this record must be regenerated once the change is
  committed.
