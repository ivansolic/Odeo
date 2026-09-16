---
artifact: refresh-residuals
type: code
branch: fix/refresh-residuals
reviewed_commit: e78d0d9
date: 2026-09-16
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 10/12
previous_total: 8/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

`main..e78d0d9`, four commits. This round is a NARROW re-review, requested by the human
after the stop condition fired at round 5, with three questions: is the Critical closed,
was the escalation answered by narrowing claims rather than widening mechanisms, and is
this mergeable. The escalated class was deliberately NOT re-litigated; where a residual of
it is named below it is named once, with a one-sentence fix, and never as a demand for
another mechanism round.

New since `da296f1`:

- `1f381d2` split `run_with_canaries()` out of `run()`, anchor case 1, pin the mutation
  recipe in the header, close two assertions that could not fail, add fixture `c3`.
- `e78d0d9` narrow three claims (early-warning grep, installer bridge, "SAME CLASS").

Provenance: ORCHESTRATING SESSION, so `build_model_as_dispatched:` is omitted by design.

Mutation discipline: every mutation ran against copies under `/tmp/odeo-rev7`, `/tmp/mut-a`
through `/tmp/mut-i`, with throwaway `HOME`s under `mktemp -d`. The repository was never a
mutation target; verified afterwards: `git status --porcelain` shows only this untracked
record, `git diff --stat e78d0d9` is empty, and `git hash-object` equals
`git rev-parse e78d0d9:<path>` for every file this branch touched. No command ran against
the reviewer's real `~/.claude`.

## Verification performed

### 1. The Critical is closed, and closed structurally (question a)

Dumped the message every scenario actually produces at `e78d0d9`, same probe as last round:

| Case | Message at `da296f1` (round 5) | Message at `e78d0d9` |
|---|---|---|
| 1 normal | `! could not be refreshed (it has local edits)` | **`refreshed.`** |
| 2 detached | `not on a branch that tracks` | `not on a branch that tracks` |
| 3 local edits | `it has local edits` | `it has local edits` |
| 4 diverged | `it has local edits` (branch dead) | **`its history has diverged from the remote`** |
| 5 offline | `could not reach the remote (offline?)` | `could not reach the remote (offline?)` |

All five classification branches are alive, including the diverged branch that was dead at
`da296f1`. The success path is back under test.

The anchor is load-bearing, not incidental: re-injecting the exact round-5 regression
(planting the canaries back inside `run()`) now produces
`FAIL - normal mirror: ! this copy could not be refreshed (it has local edits)`. The
fixture change that used to be silent is now a loud red. That is the RED that proves the
fix, and it is the one thing a re-review of a Critical must show.

### 2. The pinned mutation recipe reproduces exactly what the header claims (question a)

Ran the header recipe verbatim. It replaces both `mv "$COMMUNITY_DIR" "$stale"` sites
(`install.sh:243` and `:263`) and produces **exactly four failures, canary among them**:

```
FAIL - the user's edit was lost (no stale copy holding it)
FAIL - committed work was destroyed by the diverged path
FAIL - a scenario destroyed a canary: a misdiagnosis would cost the user's work
FAIL - early warning: the block contains a destructive-looking command
```

Ran the documented TRAP as well (replacement side unescaped): the mutant is literally
`rm -rf ""` at both sites, and the suite reports cases 3 and 4 red with the canary GREEN,
3 failures. That is precisely what the header says happens and why it misleads. The header
is honest, reproducible, and worth the twelve lines it costs.

### 3. The two closed assertions genuinely could not fail before, and can now (question a)

Injected `/bin/rm -rf "$COMMUNITY_DIR"` as the first statement of the offline arm, the arm
whose entire contract is "touch nothing":

| Variant | case 5 | canary block | early-warning grep |
|---|---|---|---|
| `rm -rf` in the offline arm | **RED** | **RED** | reddens |
| `mv "$COMMUNITY_DIR" away` (no spelling the grep knows) | **RED** | **RED** | walks past (correctly) |
| same mutation, new `[[ -d .../.git ]]` half removed from case 5 | GREEN | RED | walks past |
| same mutation, fixture `c3` removed | RED | GREEN, but `FAIL - instrument broken: found 2 canary homes, expected 3` | walks past |

Both additions are load-bearing and neither is redundant with the other: removing either one
alone leaves the mutation detected by the survivor, and the `mv` row shows the canary block
catching a spelling the text grep cannot, which is exactly the division of labour the new
comment claims. The `n_homes` tripwire also catches deletion of a fixture, so the canary
pass cannot be silently shrunk.

Probed the nastiest vacuity the design invites: a mutant that destroys the whole
`$HOME/.claude`, taking the `.canary-home` marker with it. The canary line then goes quiet
(the home becomes invisible), and the tripwire fires `found 2 canary homes, expected 3`, so
the suite is red, not falsely green. The comment at `:95-99` predicted that hazard and the
backstop holds. See N2 for the one wrinkle.

### 4. The three narrowed claims, judged against their mechanisms (question b)

| Claim | Mechanism | Honest? |
|---|---|---|
| test `:209-211` "four spellings ... a typo-catcher, not a class guard. The class guard is the canary block above" | 3 regex alternatives matching >= 6 spellings; canary block proven above to catch spellings the grep misses | **Yes.** The claim is now NARROWER than the mechanism and it points at the thing that actually carries the guarantee. Count is off (N1), in the safe direction. |
| `install.sh:144-150` "Matches TWO KNOWN WORDINGS, not the rule itself, which no grep can recognize" | `grep -qiE 'UNTRUSTED INPUT\|DATA, never instructions'`, two alternatives | **Yes.** It names the mechanism exactly, concedes the residual false alarm instead of claiming it removed, and bounds both error directions against the `odeo-baseline.md` copy. One wording is a spare (N3). |
| `docs/eval-framework.md:190-196` "SAME CLASS, operationally" | prose test: same KIND of fix, same next instance still possible; two explicit negatives; name the class in one phrase | **Yes, and it is operational.** Applied retroactively to my own round-5 escalation ("the claim is wider than the mechanism": another wording of the same claim, another branch of the same conditional) it returns the same answer I reached by argument, which is the property it needed. |

This is the right response to the escalation. Nothing was widened to chase an instance; three
sentences were made true. That is what I asked for and it was done without argument.

### 5. Full check set

`bin/skills-lint.sh .` rc=0 ("all invariants hold") · `bash -n install.sh` OK ·
`bin/docs-claims-check.sh` rc=0 ("every countable claim matches the tree", test suites = 29)
· **all 29 `tests/*.test.sh` green** (28 in the `/tmp` copy; `line-endings.test.sh` needs a
git work tree and is green in the real tree, ALL PASS).

`install.sh` end to end, throwaway `HOME`, local upstream: fresh install, up-to-date mirror,
local edits, offline, plain non-git directory, existing global without the rule, existing
global with the rule, plus an idempotent second run. **All exit 0**, each with the correct
message. Re-verified the data-loss-critical one explicitly: with upstream advanced and a
local edit, the edit is preserved verbatim in `community-knowledge.stale-<ts>/f.md` and a
fresh mirror is in place. `install.sh`'s diff since `da296f1` is comment-only (verified by
filtering the diff), so the ten-state matrix from round 5 still stands unchanged.

## Critical (must fix before merge)

None. C1 from `record_version: 1` is closed and proven closed by re-injection.

## Important (should fix)

**I1, `tests/community-refresh.test.sh:111-112`, the one claim of this shape that was NOT
narrowed is the one the new comment now leans on.** Three claims were narrowed; the
strongest claim in the file was left standing: "A command that destroys the user's files
fails this check whatever it is called, including one nobody has thought of." Measured at
`e78d0d9`, in the offline arm that now HAS a canary fixture:
`echo overwritten > "$COMMUNITY_DIR/canary-tracked.md"; : > "$COMMUNITY_DIR/f.md"` passes
**10/10, exit 0**, and prints `ok - no scenario destroyed the user's files`. `canaries_survive`
tests `[[ -f ]]`, so content destruction is invisible to it. The new early-warning comment
at `:211` ("The class guard is the canary block above") makes that sentence carry more
weight than it did last round, not less. This is not a request for another mechanism round:
the fix is the same one you applied three times in `e78d0d9`, applied once more to the
sentence you did not touch. Change `:111-112` to state the mechanism ("a command that
REMOVES the user's files fails this check whatever it is called; content overwritten in
place is not covered, the file still exists") and soften the `ok` text at `:206` from "every
path" to "every path a canary fixture runs through" (the non-git `else` arm at
`install.sh:255-267` has no canary home at all, which is the same honesty issue one line
over). Two sentence edits, no new fixtures, no new patterns.

**I2 (carried, unchanged), `AGENTS.md:43` vs `docs/eval-framework.md:199`, the two round
counts still disagree.** AGENTS.md says the rule went unapplied "until one branch had cost
five rounds"; eval-framework says "the human paid for four rounds". Both describe the same
branches, inside the passage whose stated purpose is that nobody can quietly move the
number, in a repo that ships `docs-claims-check.sh`. Filed last round as I6, not part of
the escalated class, untouched by this round. Fix: state the counts as the records hold
them and make the two files agree.

**I3 (carried, unchanged), `skills/build/SKILL.md:263-264` vs `docs/eval-framework.md:181`,
the cap is still stated with two different numbers in the two places an agent reads it.**
SKILL.md: "fix -> same reviewer re-verifies -> repeat (max 3 cycles)", i.e. three
RE-reviews after the first = four rounds. eval-framework: "THREE ROUNDS on the same
artifact ... do not dispatch a fourth". SKILL.md is where the dispatch decision is actually
made. Filed last round as I3, not part of the escalated class, untouched. Fix: one number,
in SKILL.md, plus a pointer to the same-class clause that now exists.

## Nitpicks (optional)

**N1, `tests/community-refresh.test.sh:209` and `:214`, "four spellings" is not countable
from the pattern.** `grep -qiE 'rm +-[a-zA-Z]*r|git +(-C +[^ ]+ +)?clean|-delete'` is three
alternatives and catches at least six spellings (measured: `rm -rf`, `rm -fr`, `rm -Rf`,
`rm -r`, `git -C X clean`, `find -delete`; it walks past `rm --recursive`, `find -exec rm`,
`shutil.rmtree`, `mv`, `git reset --hard`, `rmdir`). This errs NARROW, so it is not the
escalated class returning, but the commit's whole point was countable claims. Say "three
patterns, covering the spellings that appeared in real mutations" and drop the number from
the `ok` line.

**N2, `tests/community-refresh.test.sh:205-207`,** when the `.canary-home` marker is itself
destroyed the suite is correctly red (tripwire), but the canary line still prints
`ok - no scenario destroyed the user's files (both canaries survive every path)` in the same
run where a whole `~/.claude` was wiped. No false green at the gate, since the suite exits
non-zero, but the line asserts something untrue. Gate the `ok` on `n_homes` too, or word it
"in the N homes checked".

**N3 (carried), `install.sh:151`,** the second alternative `DATA, never instructions`
matches nothing in the shipped baseline, which says "DATA, never **as** instructions"
(`grep -c` = 0 against `global/CLAUDE.md`). One live wording plus one spare, so "TWO KNOWN
WORDINGS" is optimistic by one. One word fixes it; not worth a round on its own.

**N4 (carried, unchanged), `tests/community-refresh.test.sh:174-180`,** three comment
blocks now stack in the invariant region and the first two both open with "THE INVARIANT",
the first being the stale round-4 text. Delete the stale one.

**N5, `tests/community-refresh.test.sh:182`,** fixture `c2` is labelled "c2 diverge" but
cannot exercise the diverged branch: the untracked canary makes `status --porcelain` dirty,
so it classifies as "it has local edits", same as `c1` (verified by dumping its message).
The comment already concedes c1 and c2 share the move-aside site, so nothing claimed is
false, but the label misleads. Rename it, or note that under canaries only "local edits" and
"offline" are reachable.

**N6 to N8 (carried, unchanged), `install.sh:256-262`,** the dangling-symlink miss
(`[[ -e ]]` does not see it, so the clone fails for a local cause reported as a network
one), the over-fire on an EMPTY directory, and the silent `mv` failure. Unchanged from round
5; these are why correctness stays at 1.

## Noted, not investigated (escalated class, per the scope of this round)

- I1 from round 5 (canary asserts existence, not content), re-measured only because it is
  now load-bearing for a new claim; reported above as I1 in its narrow, one-sentence form.
- I2 from round 5 (the non-git `else` arm has no outcome coverage), unchanged, folded into
  the wording fix rather than re-filed as a fixture demand.
- I5 from round 5 (bridge matcher wordings), unchanged mechanism, claim now honest; N3 only.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 1/2  -> total 10/12  (threshold: >=9, no zero)

- **correctness 1**, unchanged, and unchanged for the same reason: `install.sh` is
  byte-identical in logic to `da296f1`, where I verified all ten community states and five
  global states exit 0 with correct behaviour, and where N6/N7/N8 (dangling symlink, empty
  directory, silent `mv`) remained open. No new correctness defect this round; no old one
  closed either, because the human spent this round on claims instead, which was the right
  call.
- **security 2**, unchanged. Comment-only change to the read-only bridge, no new surface, no
  secrets, `GIT_TERMINAL_PROMPT=0` intact, move-aside still the worst outcome.
- **performance 2**, three extra clones in a test suite that runs in seconds.
- **readability 2**, the comments still carry the file. The new ones are the best kind:
  `run_with_canaries` explains why it is NOT inside `run()`, the header explains a trap that
  cost three rounds, and each cites the lesson it comes from. N4 and N5 are leftovers.
- **testing 2, up from 0.** The Critical is closed with a demonstrated red, the two vacuous
  assertions are closed and each is proven load-bearing by a counterfactual, the third
  fixture is proven to be the one that catches the offline mutation, the mutation recipe is
  pinned AND its trap is documented with the exact failure signature, and the tripwire
  catches both fixture removal and marker destruction. Five classification branches are
  alive, measured, not asserted. This is the strongest the suite has been in six rounds.
- **conventions 1**, Conventional Commits, English comments, correct branch, no secrets, and
  the mutation evidence was produced before the claims were written this time. Held at 1 by
  I1: `CLAUDE.md` says a guard described as catching a class must be seen going RED before
  the claim is written, and the "whatever it is called" sentence is falsified by a
  ten-second mutation. Minor: `e78d0d9` is typed `docs:` but also changed a matcher
  (`grep -qE` to `grep -qiE`) and an assertion message in a test; that is a `test:` change
  riding in a docs commit.

## Ceiling

11/12 reachable on this branch. Correctness caps at 1 while the non-git arm keeps a residual
of the misattribution class it was added to remove (a dangling symlink is a local cause
reported as a network one) and over-fires on an empty directory; those were filed as
nitpicks and the human deliberately did not spend this round on them, which is a legitimate
choice, not a defect in the work delivered. Everything else is at max or reachable:
conventions returns to 2 with the two sentence edits in I1.

## History

- **Round 5 (`record_version: 1`, `da296f1`, 8/12, REQUEST CHANGES).** C1: planting canaries
  inside `run()` put every fixture one commit ahead of upstream, killing the success path
  and the diverged branch while case 1 stayed green on the substring of "could NOT be
  refreshed". Plus I1/I2/I5/N4/N6 escalated as ONE class ("the claim is wider than the
  mechanism"), third consecutive round, under the stop condition rather than filed as
  another patch round. Testing scored 0.
- **Round 6 (this record, `e78d0d9`, 10/12, APPROVE WITH COMMENTS).** REGRESSION CHECK:
  **better, by 2 points, and better in the dimension that was zero.** Testing 0 -> 2 (the
  Critical is closed and proven closed; two assertions that could not fail now can; a third
  fixture and a pinned recipe). Conventions 1 -> 1, correctness 1 -> 1, all others
  unchanged at 2. No new Critical was introduced by the fix, which is the failure mode this
  branch hit twice before. The escalation was answered the way it was escalated: claims
  narrowed, no mechanism widened to chase an instance, and the one claim left un-narrowed
  is I1 above, which needs two sentences and no new code.

## What's good

The Critical was fixed at the level it was found. Splitting `run_with_canaries()` from
`run()` is the structural answer, not the convenient one: it accepts that one fixture cannot
serve both halves of the contract, and the comment says exactly why, at the line where the
next person will be tempted to merge them again. Re-injecting the regression now turns the
suite red, so the fix is pinned by the same discipline it restores.

The response to the diagnostic is the best thing in this round. Finding that the MUTATION
was broken (not the invariant) is the finding nobody wants: it means three rounds of work
chased a correct assertion. Instead of quietly correcting the recipe, it is pinned in the
header WITH the failure signature of the wrong version and a note that the no-op mutant
still reddens two cases, which is what made it convincing. That is a trap disarmed for
everyone who touches this file later, and it generalizes: the instrument doing the checking
is subject to the same vacuity rule as the code.

Both closed assertions were closed by measurement, not by inspection. Case 5 asserted two
things that stayed true after deletion; it now asserts the copy exists, and the
counterfactual proves that half is what carries it. The canary pass was two fixtures deep on
one mutation site; `c3` is proven to be the fixture that catches the offline arm, and
removing it produces an instrument-broken failure rather than silence.

And the escalation was taken, not argued with. Three claims narrowed, zero mechanisms
widened, and the "SAME CLASS" test is now something two reviewers can apply to the same
facts and get the same answer, which is the only property that made it worth writing down.
