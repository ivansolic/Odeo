---
artifact: community-knowledge-guarded
type: code
branch: feature/community-knowledge-guarded
reviewed_commit: f941b84
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 3
scores: { correctness: 1, security: 1, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 9/12
previous_total: 8/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

The delta `main..f941b84` (13 files, +637/-33), with deepest attention on the two
commits added since `c0b67e3`:

- `4a46ec8` `fix(install): make a failed refresh non-destructive by construction, and
  pin the matrix` (`install.sh` +63/-23, `tests/community-refresh.test.sh` new,
  `skills/sync-community/SKILL.md`, `AGENTS.md`, `README.md`)
- `f941b84` `docs(readme): lead with the lifecycle and the gate rule, and trade prose
  for tables` (`README.md` +100/-33)

`git rev-parse --short HEAD` == `f941b84`, resolved by me. The working tree carries
exactly one modification, this record, which `merge-gate.sh` excludes from its
freshness comparison by construction; every other path is byte-identical to `f941b84`.

Provenance: ORCHESTRATING SESSION, not an isolated builder, so
`build_model_as_dispatched:` is omitted by design.

Mutation discipline: every mutation ran against copies under `/tmp/ck3*` and
`/tmp/ckprobe/`, restored by re-copying from `/tmp`, never via git. Nothing was
written into the repository and no command ran against the real
`~/.claude/community-knowledge`.

Reach beyond the diff, each justified by a named risk: the five orchestrator
`SKILL.md` files and `agents/architect.md` + `agents/builder.md` (the README makes
falsifiable claims about each), `bin/spec-gate.sh` + `bin/merge-gate.sh` (the README
states what they enforce), `AGENTS.md` Guardrails (the `[E]`/`[I]` claim),
`skills/sync-docs/SKILL.md` and `install.sh:53-66,132-139` (whether the new rule
reaches an already-installed user), and an exhaustive grep for every surface that
ingests `community-knowledge`.

## Verification performed

**The class-elimination claim holds.** There is no deletion of the mirror on any path
in the block (`install.sh:180-234`), confirmed by reading and by behavioral fixtures.
Both mutations the dispatch asked for go RED:

| Mutation | Result |
|---|---|
| move-aside replaced by `rm -rf "$COMMUNITY_DIR"` | RED, 3 assertions fail |
| `@{u}` reverted to `FETCH_HEAD` | RED, the detached-HEAD case reports `refreshed.` again |

**Scenario matrix re-run, all non-destructive.** s8 detached HEAD: named, moved aside,
never celebrated. s12/s13/s14 (upstream rename, orphan branch, missing remote): all
resolve through `@{u}`, so the orphan-tip misresolution that produced a spurious
delete command in round 2 cannot occur. Stale index: `.git/index.lock` left by a
crashed git is misclassified as "its history has diverged" but the copy is preserved
intact at `.stale-<ts>` and the install continues, which is exactly the designed
behaviour of a non-load-bearing classifier. Same with `index.lock` plus local edits,
verified the edit survives in the moved-aside copy.

**Can the test pass for a wrong reason?** Partly, and it is worth naming precisely
(see I2). The two instrument defects recorded in the file are real and correctly
fixed: `mkmirror` advances upstream after each clone, so the fixtures are genuinely
behind, and the diverged case captures the log before matching it rather than
SIGPIPE-ing git under `pipefail`. The residual is that assertion 6's guard is a
literal string match, and a mutation spelled `rm -fr` destroys the mirror while that
assertion stays GREEN. The suite still goes RED overall because cases 3 and 4 assert
survival behaviorally, so the protection holds; the belt has a hole, the suspenders
do not.

**Shell-flag fidelity.** `install.sh:17` is `set -euo pipefail`; the harness evaluates
the block under `set +e` (`tests/community-refresh.test.sh:57`). I re-ran all nine
assertions with the subshell switched to `set -euo pipefail` and all nine still pass,
so nothing is wrong today. The gap is future regression invisibility (N4).

**README claims, each checked against the tree.** All true as stated:

| Claim | Evidence |
|---|---|
| five orchestrators exist | `skills/{discover,plan,spec,build,go-to-market}/SKILL.md` |
| `/discover` chains brainstorm → personas → journey map → opportunity tree → experiments | `skills/discover/SKILL.md:13-17`, exact match |
| `/plan` chains prioritize → roadmap | `skills/plan/SKILL.md:14-16` |
| `/spec` chains PRD → critique → stories | `skills/spec/SKILL.md:16-21` |
| `/go-to-market` chains positioning → marketing → GTM plan → release notes | `skills/go-to-market/SKILL.md:13-16` |
| "nothing chains past a gate on its own" | every one of the five carries explicit `GATE` steps; `/plan:25` and `/spec:30` state "never auto-advance" |
| "the `architect` has no write tool" | `agents/architect.md:4` `tools: Read, Grep, Glob` |
| "the `builder` works in its own git worktree" | `agents/builder.md:7` `isolation: worktree`, `skills/build/SKILL.md:199` |
| "the reviewer never sees its context" | separate subagent dispatch; independent by construction |
| `spec-gate`: no story without a fresh passing review | `bin/spec-gate.sh:5-13`, four conditions incl. record-newer-than-artifact |
| `merge-gate`: no merge unless EVERY record approves | `bin/merge-gate.sh:165-216`, frontmatter-only, deny by default |
| every surface named in "What's inside" exists | `/retro`, `/prototype`, `/product-signal`, `/language`, `/start`, `/guide`, `/outcome`, `/learn`, `publish-guard`, `privacy-scan`, `test-driven-development`, `ux-design`, `ux-writing`, `/setup-design`, `init-project.sh`, `/setup-project` all present |

`bin/docs-claims-check.sh` passes, and with `--assertions` too: 23 bin executables,
29 suites, 22 programs with their own suite, 840 assertions. `bin/publish-guard.sh`
clean.

**The one README claim that does not hold is I1 below.**

**Omitting community knowledge from "What's inside" is the right call.** The base is
new and empty, and this very branch just established that its content is untrusted
input. Advertising a curated knowledge base on the front page before a reader would
find anything in it is the same overclaim class the branch exists to remove. Keep it
out until it has content worth promising.

## Critical

None. No path deletes or truncates the user's mirror; no path loses committed work or
uncommitted edits; no injection surface (every interpolation is quoted, nothing is
`eval`'d from remote data); the install completes in every state tested.

## Important

**I1, `README.md:39` overclaims the `[E]` guarantee on the public front page.**
"nothing in the system can quietly weaken an `[E]`" is stronger than the system
delivers, in two independently verifiable ways. First, `skills/commit-push/SKILL.md:104`
says "Never bypass pre-commit hooks with `--no-verify` without asking", which concedes
that the secret-scan `[E]` at `AGENTS.md:243` is bypassable and that an instruction is
the only thing holding it; an agent running `git commit --no-verify` weakens an `[E]`
exactly as quietly as the sentence denies. Second, nothing verifies that an `[E]` line
still has a live mechanism: no suite in `tests/` reads the Guardrails section, so
deleting `bin/spec-gate.sh` or the pre-push hook leaves the `[E]` tag standing and
nothing goes red. Fix: say what `AGENTS.md:195-197` actually claims, e.g. "an `[E]` is
held by a mechanism with an exit code, not by the model's goodwill; an `[I]` is held by
the model, layered with verifiers and your gate." That is true, is still the strongest
sentence on the page, and does not invite a reader to find the counterexample.

**I2, `tests/community-refresh.test.sh:116-118`, the invariant guard is a
spelling check presented as a class guarantee.** The comment at `:114-115` says this
assertion is "asserted independently of every classification" and is "what keeps a
future missed state survivable". The mechanism is `grep -q 'rm -rf'`. I mutated
`mv "$COMMUNITY_DIR" "$stale"` to `rm -fr "$COMMUNITY_DIR"`, which destroys the mirror
just as completely, and assertion 6 printed `ok - no path in the block deletes the
mirror (move-aside only)`. `rm -r`, `git clean -xfd` and `find ... -delete` pass it
too. This is the claim-wider-than-the-mechanism shape from `.claude/tasks/lessons.md`
("Prove a coverage claim by mutation BEFORE writing it"). The suite as a whole still
caught my mutation through cases 3 and 4, so nothing is broken today, but the
assertion that is supposed to survive a regression of the classifier is the one that
does not. Fix: widen to a pattern class, `grep -qE 'rm +-[a-zA-Z]*r|git +clean|-delete'`,
and add the behavioral half, plant a sentinel file in every fixture and assert it is
still readable somewhere under `$home` after each non-offline scenario. Then narrow
the comment to whatever the widened check actually proves.

**I3, `install.sh:226-232`, the sibling `else` branch still carries the exact defect
class the `if` branch just eliminated.** The new comment at `:182-188` says the mirror
is moved aside "for ANY reason including one not enumerated here", but that promise
only covers the `[[ -d "$COMMUNITY_DIR/.git" ]]` arm. Two states verified under `/tmp`:

- `~/.claude/community-knowledge` exists, is non-empty, and is not a git repo (a
  restored backup, a manual copy, a clone killed before `.git` was written)
- `.git` is a file rather than a directory (a gitlink left by a worktree or submodule)

In both, `git clone` refuses a non-empty destination and the user is told
`! community knowledge repo not reachable yet, skipped (set up later). It will
populate on the next install.sh once the repo is published.` That is a network excuse
for a purely local cause, printed on every future install, telling the user to wait
for something that has already happened. Nothing is destroyed, so this is not a
Critical, and prevalence is low, but it is permanent invisible staleness with a
misleading cause, which is the thing this branch exists to abolish. Fix: reuse the
mechanism that is already three lines above, before the clone in the `else` arm, if
`$COMMUNITY_DIR` exists, move it to `$COMMUNITY_DIR.stale-<ts>` and clone into the
freed path, with the same "nothing was deleted" message.

**I4, `install.sh:196-197`, the offline branch is the one arm that can freeze
forever, and the residual is not documented.** `git fetch` failing is the only branch
that never moves aside, which is the right default (you cannot re-clone what you
cannot reach). But fetch also fails on a corrupt `.git`, on an `https` 401 under
`GIT_TERMINAL_PROMPT=0`, and on a remote URL the user edited to something dead. All
three print `could not reach the remote (offline?), kept the existing copy.` on every
install, forever, with no way out offered. The `(offline?)` question mark is honest
about the guess; what is missing is the exit. Fix: one line, `if this repeats on a
machine that is online, this copy may be unusable: move it aside
("mv <dir> <dir>.old") and re-run install.sh`. Then state the residual in the comment
block, so the next reader knows the class was bounded deliberately rather than missed.

**I5, the round-2 delivery gap has two halves and only one is in the deferral note.**
The dispatch carries forward that `install.sh:134-137` never clobbers an existing
`~/.claude/CLAUDE.md`, so an already-installed user's main session does not get the
untrusted-input rule. Correct, and I verified the second half is still open too:
nothing in the tree refreshes an existing project's `CLAUDE.md` either, so
`project-templates/CLAUDE.md:165` reaches only projects scaffolded after this install.
`skills/sync-docs/SKILL.md` is not that mechanism, it reconciles a project's docs
against its own code, not against the upstream template. Mitigating fact I confirmed
rather than assumed: `install.sh:53-66` overwrites `~/.claude/skills/` and
`~/.claude/agents/` on every run, so `architect`, `builder` and `sync-community` DO
carry the rule to existing users, which means the delegated build pipeline is covered
and only the two `CLAUDE.md` surfaces are not. I agree the fix belongs in its own
change: writing into a user's personal global file is precisely the irreversible class
the README says stays with the human, and an ensure-line pass has its own failure
modes (duplicate insertion, wrong section, clobbering a user edit) that deserve their
own plan and tests. What does belong here or in the very next change is a zero-write
bridge: at `install.sh:136`, when the personal global exists and does not contain a
marker from the baseline's untrusted-input rule, print one line naming the rule and
pointing at `~/.claude/odeo-baseline.md`. That is read-only, carries none of the write
risk, and closes the silent half of the gap now.

## Nitpicks

- `install.sh:216`, the user-visible message states a guess as fact, "(its history has
  diverged from the remote)", while the code comment at `:204-205` correctly calls it
  "the likeliest cause". Verified with a stale `.git/index.lock`, where history had not
  diverged at all. Fix: "(likely: its history has diverged from the remote)". On a
  branch whose thesis is diagnostic honesty, the message should hedge where the code
  says it is hedging.
- `install.sh:213`, `date +%Y%m%d%H%M%S` collides if two failing installs land in the
  same second; `mv dir existing-dir` then nests the copy inside the earlier stale
  directory and the path printed at `:218` is wrong. Fix: bump on collision, or
  `stale="$(mktemp -d "$COMMUNITY_DIR.stale-XXXXXX")"` and `rmdir` it before the `mv`.
- `install.sh:212-225`, stale copies accumulate with no cap and each message mentions
  only the one just created. Fix: count existing `.stale-*` siblings and say so, and
  consider `git clone --depth 1` for a read-only mirror to bound both clone time and
  stale-copy size.
- `tests/community-refresh.test.sh:57`, the harness runs the block under `set +e` while
  `install.sh:17` runs it under `set -euo pipefail`. All nine pass under the real flags
  today (I checked), but a future `[[ ... ]] && cmd` whose left side goes false, or any
  bare failing command, would abort the install mid-run and this suite would not see
  it. Fix: `( set -euo pipefail; ... )` and assert the subshell's exit status is 0 in
  each scenario.
- `install.sh:221-224`, the restore branch has no case. I exercised it by hand with an
  unreachable `COMMUNITY_KNOWLEDGE_REPO`: the copy is restored to the original path,
  the user's commit survives, the message is accurate and the install continues. Worth
  ten lines in the suite so it stays that way.
- `INSTALL.md:255`, the `~/.claude/` directory map does not mention
  `community-knowledge.stale-*`, which users will now find sitting next to the mirror.
  One line in the map removes the "what is this and can I delete it" question.
- `README.md:41`, "rejoin at one gate" compresses slightly: `skills/build/SKILL.md:158`
  serializes `/merge` per story with your approval each time, which is stronger than
  one gate, not weaker. Consider "rejoin one at a time, each at your gate".

## Scores

correctness 1/2 · security 1/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 2/2  -> total 9/12  (threshold: >=9, no zero)

- **correctness 1**, the block is right in every state I could construct and the
  destructive class is genuinely gone, but I3 and I4 are real diagnostic defects that
  ship: two states get a network excuse for a local cause, and one can freeze forever
  with no exit offered.
- **security 1**, the untrusted-input rule now reaches every surface that ingests
  community knowledge (exhaustive grep: `AGENTS.md`, `global/CLAUDE.md`,
  `project-templates/CLAUDE.md`, `agents/architect.md`, `agents/builder.md`,
  `skills/sync-community/SKILL.md`), and `sync-community` no longer runs a naive pull.
  Held at 1 only by I5: an already-installed user's main session, the session that
  `global/CLAUDE.md:171-172` tells to read the community base, still has no rule, and a
  read-only warning would have closed that without taking on the write risk.
- **performance 2**, nothing hot, nothing quadratic; the re-clone is bounded and rare.
- **readability 2**, `refresh_note`/`stale`/`upstream` say what they hold, the block is
  55 lines with the reasoning that produced it recorded above the code, and the README
  is materially more scannable than the 19 bullets it replaces.
- **testing 1**, a large step up from nothing: 9 assertions, a marker-drift guard, both
  instrument defects recorded in the file, and two mutations I ran go RED. Held at 1 by
  four named gaps: the spelling hole in the invariant guard (I2), the untested restore
  branch, the entirely untested `else` arm (I3), and the `set +e` fidelity gap.
- **conventions 2**, English comments, Conventional Commits with honest bodies that name
  what was deferred, feature branch, no secrets, no TODOs, errors surfaced not
  swallowed, and the `lessons.md` mutation discipline visibly applied rather than
  claimed. The I2 residual is a gap in one guard, not a repeat of the lesson.

## Ceiling

11/12 reachable on this branch. Security structurally caps below 2 while the delivery
half of I5 is deliberately out of scope: the rule exists correctly in the repository
but cannot reach an already-installed user's personal global file without a change
that, by the system's own rule, is a separate decision. Everything else was reachable
at 2 this round; correctness and testing fall short on findings that have concrete
fixes, not on anything structural.

## What's good

The response to round 2 did the harder and more durable thing. It did not add a sixth
branch to the classifier, it changed the default answer so the classifier stopped
being load-bearing for safety, which is the difference between patching instances and
eliminating a class. The comment at `install.sh:182-194` is unusually valuable because
it records why `FETCH_HEAD` was wrong and why "refreshed" is now asserted against HEAD
rather than an exit code, so the next person cannot re-introduce either by accident.

Asserting the refresh by `HEAD == @{u}` instead of a merge exit code is the single
line that would have caught round 2's worst bug on its own.

The two instrument defects are recorded in the test file rather than in a commit
message that nobody re-reads, at the exact cases where they would recur. That is the
right home for them.

The README restructure earns its verdict on evidence: every chain in the orchestrator
table matches its `SKILL.md` step for step, the three "verify it yourself" claims about
`architect`, `builder` and the reviewer are all literally true, `spec-gate` and
`merge-gate` do what the section says, and deleting "What is this?" rather than
stacking a new section on top of it is the discipline that keeps a front page honest.
Leaving community knowledge out of "What's inside" was the correct restraint.

## History

- **Round 1, `c8d046b`, 4/12, REQUEST CHANGES.** Two Criticals: stranger-authored
  community knowledge ingested with no untrusted-input rule at any surface that
  actually runs, and a refresh classifier whose "offline AND dirty" state handed the
  user a destructive remedy for a network fault.
- **Round 2, `c0b67e3`, 8/12, REQUEST CHANGES.** Both Criticals closed. Blocked on the
  same defect class a second time: I1, the "diverged" branch inferred divergence from a
  failed command against the ambiguous `FETCH_HEAD` and paired it with `rm -rf`, with
  detached HEAD reporting a false "refreshed" forever and an orphan branch upstream
  producing a spurious delete command; I2, that remedy destroyed committed work with no
  save path; I3, the classifier had no test after being wrong in three states across two
  commits; I4, `GIT_TERMINAL_PROMPT=0` did not cover the clone path; I5, the new rule
  did not reach already-installed users.
- **Round 3, `f941b84`, 9/12, APPROVE WITH COMMENTS.** I1 through I4 closed and
  independently verified here, including by mutation. I5 carried forward by agreement,
  and widened: existing projects miss the rule as well as existing globals. Better than
  round 2 on correctness (the destructive class is gone by construction, not by
  branch count), testing (0 to 9 assertions, 2 of 2 requested mutations go RED) and
  conventions. Security unchanged at 1 for the one reason named in I5. The new
  findings are smaller in kind than every previous round's: message accuracy and test
  fidelity, no data loss anywhere.
