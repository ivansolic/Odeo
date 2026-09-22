---
artifact: skills/merge/SKILL.md
type: skill
branch: docs/merge-two-history-guard
reviewed_commit: 1cd2927
artifact_version: 4
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/merge/SKILL.md`, scored in round 3 at commit `f8a0aa3` and re-anchored
here to `1cd2927`, the sha supplied at dispatch. The re-anchor is MECHANICAL: one two-word
deletion closing the single residual round 3 named, verified below, no re-scoring and no new
scope. Round 3 remains the last scoring round: `docs/eval-framework.md` stop condition 2 (three
rounds on one artifact) is reached, and condition 3 applies as well (see "Why this loop stops").
Round 3 read step 1b in full (`:19-57`), `bin/merge-gate.sh:1-95`, `bin/publish-snapshot.sh:19-33`,
`bin/install-git-guards.sh`, and the class precedent at
`docs/decisions/ADR-001-plans-carry-contracts-not-code.md:330-336` and
`docs/evals/code-feature-windows-powershell-entry.md:270-276`. Form only, no runtime behavior
tested. Output language `en`, supplied at dispatch. Line citations below are unchanged by the
re-anchor: the deletion shortened line 45 without moving any line.

## Skill: merge  (explicit command, `disable-model-invocation: true`, intentional: the merge is
the human floor)

## Scores

Unchanged at 10/10. Stated plainly so the record cannot be read as rewarding responsiveness:
both items shipped in `f8a0aa3` were listed in round 2 as **non-score-bearing**, so they could
not move the total and did not. What they changed is the residual list, which is shorter and
whose remaining entries are now smaller than the ones they replaced. The `1cd2927` deletion is
likewise non-score-bearing.

- trigger clarity **2** (2, 2). `:2` unchanged, still names both outcomes.
- structure **2** (2, 2). The shape holds and the file is still far under the limit. One warning
  rather than a deduction: step 1b is now roughly 28 lines (`:27-54`), the longest step by a
  wide margin and about a fifth of the file, and it has grown in each of the three rounds. It is
  a genuine decision point, which the standard allows prose for, so it is not over-length yet.
  But it is at the size where the next insertion starts costing the reader the rest of the
  process. The next thing this guard needs should go into `## Two histories` or into a
  mechanism, not into a fourth paragraph of 1b.
- worked example **2** (1, 2). Unchanged this round; both transcripts still match the process,
  and `:35`'s "If NEITHER line prints" is consistent with the echoes the transcripts show.
- precision **2** (1, 2). The shipped wording is exact and lands as described (verification
  below). One new residual, one cosmetic, both non-score-bearing, in the fixes list.
- safety integration **2** (2, 2). The publication question now governs two of the three ancestry
  shapes instead of one, and `:45` keys the refusal on the answer rather than on the shape,
  which is the correct dependency. The round-1 carry-over (step 0's drifted restatement of the
  gate's refusal list) is still open.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no criterion at 0)

## Ceiling: 10/10, held for a second round

## Verification of the two shipped items (round 3, `f8a0aa3`)

Both land as described.

1. **Exit-status wording, as specified.** `:29-30` states it before the block: "`--is-ancestor`
   answers with its EXIT STATUS and prints nothing, so make it speak, or you will be reading
   silence and calling it inconclusive". Both commands carry an echo (`:32-33`), and the
   downstream sentence was updated to match the new failure signal, "If NEITHER line prints"
   (`:35`), rather than being left describing a test that no longer speaks that way. That
   consistency is the part that is easy to miss and was not missed.
2. **The AHEAD branch, with the reasoning named.** `:41-44` asks the question on AHEAD, gives the
   cause ("A publication remote that was once seeded by a direct push reads as 'you are ahead'")
   and the consequence ("'ahead' invites steps 4, 5 and 6, which is the push this whole check
   exists to prevent"), and states the division of labour in one line: "Ancestry tells you the
   shape of the gap; only that question tells you what the remote IS." The refusal at `:45` is
   keyed on the answer, which is the right dependency and fixes the muddy antecedent the
   insertion created.

## Why this loop stops here

`docs/eval-framework.md` stop condition 2 is reached mechanically: round 3 was the third round.
Condition 3 is the more useful one, and it was invoked explicitly rather than left for a fourth
round to discover.

**The class, in one phrase: another uncovered reading of the guard, closed by another clause.**
Round 1 found the guard absent from four entry points and it was added to four entry points.
Round 2 found it silent on one test and blind on one ancestry shape, and a sentence and a
paragraph were added. Round 3 could name the next instance without trying hard:

**The publication question is not asked on BEHIND** (round 3 state). `:45` promised the refusal
applied "whatever the ancestry said", but the instruction to ASK appeared only for diverged
(`:35-40`) and AHEAD (`:41-44`). BEHIND fell through to step 2 unasked. **CLOSED at `1cd2927`**
by deleting "whatever the ancestry said", so the claim now covers exactly the two shapes the
step instructs on.

The argument for why BEHIND is safe to leave unasked is worth keeping on the record, because it
is the reason the fix was a deletion and not a fourth clause: `bin/publish-snapshot.sh:32` builds
the public tree with `git archive`, which copies content and no history, so published commits are
never in your history and yours are never in theirs once the lines split. For local `main` to be
an ancestor of a publication remote's base, that remote would have to literally contain your
commits, which this publication mechanism cannot produce. BEHIND therefore implies one lineage.
The gap was in the PROSE'S PROMISE (three shapes claimed, two instructed), not in the safety of
the omission, which made it a claim slightly wider than its mechanism: the same small shape as
the class ADR-001 is about, one size down. Narrowing the claim is the direction that closes it
without growing step 1b, which was the stated reason for stopping.

## Recommendation on the `merge-gate.sh` mechanism (for the human's decision)

Requested on the record, in my words, not the coordinator's. I am not building it and I am not
asking for it to be built in this branch; this is the input for that call.

### (a) What the gate should assert, running before any fetch and making no network calls

The gate must assert a FACT it can check locally, not a CONCLUSION about intent. Concretely, on
entry (it already runs from the repo root, on a story branch, with a base ref argument that
defaults to `main`):

> For the base branch, enumerate the remote-tracking refs that carry it (`refs/remotes/*/<base>`).
> For each, run the two local `git merge-base --is-ancestor` tests against local `<base>`. If any
> remote's base line is neither an ancestor nor a descendant of local `<base>`, refuse, naming the
> remote, the base, and what to do (answer step 1b's question, then re-run).

That is deterministic, needs no network, costs microseconds, and asserts only what it measured:
"this repo currently holds two non-ancestral lines for `<base>`". It does NOT assert "that remote
is a publication", which no local check can know.

The staleness caveat must be printed, not assumed away, and its direction is favourable. Without
a fetch the remote-tracking refs may lag. Working it through: a stale ref can only be an ancestor
of the real one, so a BEHIND verdict from a stale ref is still true of the real one; a
DIVERGED verdict may be a false alarm if someone has since pushed your `main` into that line, and
an AHEAD verdict is the unreliable one, because the real ref may have moved on. The errors
therefore fall on the fail-closed side for the case that matters: the cost of a false refusal is
one `git fetch` and one re-run, which is also exactly the right instruction to print.

### (b) Can it distinguish a publication remote without project-specific configuration? No, and it
should not try

Sniffing for `bin/publish-snapshot.sh` or `docs/internal-paths.txt` would be this project's
naming baked into a gate that ships to other projects: project-specific configuration wearing a
heuristic's clothes, and silently absent in any repo that named things differently. Parsing the
pre-push hook to learn WHICH remote it refuses is worse, since hooks are arbitrary programs.

It needs a DECLARED setting, because the thing being asserted is a fact about the project that a
human knows and git does not. The cheap shape: a git config key set once at the moment the human
is already asserting exactly this fact, namely when `bin/install-git-guards.sh` installs the
pre-push hook that refuses the public remote. For example `remote.<name>.role = publication`.
Then the gate's rule is fully deterministic and needs no inference: refuse when the integration
target is a remote declared `publication`. With the key unset, an ordinary project sees no new
behavior at all, and the gate falls back to the (a) fact-check, whose refusal message asks the
human the question rather than guessing the answer. Zero configuration for the common case, a
hard mechanism for the project that declared itself.

### (c) Is a partial gate worth building, or is it the wide-claim failure? Worth building, if it
is named for what it does

The failure class this project already has a lesson about is not "partial mechanism". Read the
precedents: ADR-001:330-336 and `code-feature-windows-powershell-entry.md:270-276` are both about
a CLAIM wider than the mechanism backing it. A narrow mechanism with a narrow claim is the fix
for that class, not an instance of it. So the condition on building it is a naming condition:

- Do not call it two-history protection. Call it what it asserts: "refuses when `<base>` has two
  non-ancestral remote lines, or when the target remote is declared a publication."
- Print what it does not cover: it does not fetch, so its view may be stale; it cannot know
  intent; and it protects the `/merge` path only.

**But if only one thing gets built, it should not be the gate.** The gate protects the path that
already has the prose. The failure this whole branch came from is a rebase typed outside `/merge`,
and git has a hook for exactly that: `pre-rebase` receives the upstream being rebased onto, so it
can refuse when that upstream resolves to a remote declared `publication`, regardless of who typed
the command, which skill was open, or whether anyone read it. Installed by
`bin/install-git-guards.sh` beside the pre-push hook, it keys on the same declared fact as (b).
That is the version that survives an agent who skims, which is the whole reason this branch
exists.

Three honest limits on that recommendation, so it is not adopted wider than it is:
1. Coverage is not total. `pre-push` covers the push, `pre-rebase` covers the rebase, and the
   `git pull` fast-forward into local `main` (step 6's hazard) is not hook-coverable, since no
   hook fires on a fast-forward merge. That residual stays prose, and should be said out loud
   rather than papered over.
2. I have not verified whether `pre-rebase` fires for `git pull --rebase` in current git. Treat
   that as unverified and test it before claiming the hook covers that path.
3. A declared-config mechanism protects only projects that declared. A fresh user of the published
   skill has the prose and nothing else, so the mechanism must never be used as a reason to trim
   step 1b. The prose is the shipped product; the hook is this repo's seatbelt.

## Remaining fixes (none score-bearing)

1. ~~Make `:45`'s promise match what is asked.~~ **CLOSED at `1cd2927`**: "whatever the ancestry
   said" deleted, so the answer-keyed refusal claims exactly the two shapes (diverged, AHEAD) the
   step instructs on. AHEAD coverage is untouched, since `:41-44` still directs the question
   there. The alternative (six words at `:32`) was correctly not taken: it would have grown the
   block.
2. **(carried from round 1, still open) Stop restating the gate's refusal list at `:21-24`.** The
   skill names one refusal reason; `bin/merge-gate.sh` also refuses on a non-approving record, a
   missing `model_tier`, a missing `reviewed_commit` after the cutoff, and an untracked
   non-ignored file under `docs/evals/`. Replace with "It prints exactly which precondition
   failed. Fix what it names, re-run, only then continue."
3. **(carried) `main` is hardcoded** while `merge-gate.sh` takes a base ref; one parenthetical at
   1b covers `master` repos.
4. **(carried) `1b.` breaks the ordered list in rendered markdown**; now cited by name from four
   files, so renumbering probably costs more than it saves.
5. **(cosmetic) `:47` runs long** against the file's own ~95-column wrap, and `:45` now wraps
   short; a single re-wrap of `:45-49` tidies both. Untouched by the deletion.
6. **(carried) the `--ff-only` precondition and the record-name inconsistency** in the Two
   histories transcript (`:98`, `:95`).

**Recommended next step, unchanged and now the only one:** the form is settled and three rounds
of review is what this artifact gets. The open question is behavioral and no reviewer can answer
it by reading. Run `/improve` at full rigor (5+ reps per variant, discipline-critical skill), with
at least one variant entering at step 2 and one on a repo whose `main` reads AHEAD.

**Integrity:** nothing in this skill reads as copied from another project.

## History

- **Round 1, 2026-09-22, 8/10 PASS** (uncommitted working tree; no sha supplied, so that record
  carried no valid anchor and said so). First full scoring. worked example **1** (the transcript
  showed gate -> fetch -> rebase with no check, so the most imitated artifact modelled the unsafe
  sequence) and precision **1** (a present-tense `278  3` and a 42-file count, both rotting and
  unreproducible in a public clone; plus a magnitude threshold silent on a fresh split). Also
  raised: step 2 readable standalone, step 6's unguarded `git pull`, three unqualified copies of
  the imperative outside the skill, a drifted restatement of the gate's refusal list.
- **Round 2, 2026-09-22, `86ad820`, 10/10 PASS** (previous 8/10, improved +2). Both 1s moved on
  evidence: the ordinary transcript gained the upstream check and the publication path gained its
  own complete transcript; the rotting measurement and the size threshold were replaced by
  ancestry plus one binary question. My round-1 `git merge-base` emptiness suggestion was measured
  and rejected, correctly: the lines share a root, the test is sufficient but not necessary, and
  the only discriminating version reintroduces the magnitude judgement just removed. Seven fixes
  left open, all non-score-bearing.
- **Round 3, 2026-09-22, `f8a0aa3`, 10/10 PASS** (previous 10/10, held). The two items shipped
  there were round 2's non-score-bearing fixes, so they could not and did not move the total; both
  land as described, including the downstream consistency edit at `:35` and the re-keying of the
  refusal onto the answer at `:45`. **Loop stopped** under `docs/eval-framework.md` conditions 2
  (three rounds) and 3 (recurring class: "another uncovered reading of the guard, closed by
  another clause"; the next instance, the question not being asked on BEHIND, was named with the
  argument for closing it by deleting two words rather than adding a fourth paragraph). The
  mechanism question is answered on the record under "Recommendation on the `merge-gate.sh`
  mechanism": assert a local fact not a conclusion, key it on a declared
  `remote.<name>.role = publication` rather than on sniffing this project's filenames, build it
  narrow and name it narrowly, and if only one thing is built make it a `pre-rebase` hook rather
  than the gate, because the gate only protects the path that already has the prose.
- **Re-anchor, 2026-09-22, `1cd2927`. NOT a round: no re-scoring, no new scope, verdict and total
  unchanged at PASS 10/10.** The loop remains stopped. The single residual round 3 named is
  CLOSED, by the first of the two options offered and in the direction that does not grow step 1b:
  "whatever the ancestry said" deleted from `:45`, which now reads **When the answer is "a
  separate step":**. Verified at this sha, and verified that nothing else in `:26-57` moved. The
  deletion introduces nothing: the antecedent is still the question stated at `:36-38` and
  re-scoped at `:41`, AHEAD coverage still comes from `:41-44` rather than from the deleted
  clause, and no line numbers shifted, so every citation in this record still resolves. Fixes 2-6
  remain open and are unaffected.
