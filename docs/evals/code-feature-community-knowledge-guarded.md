---
artifact: community-knowledge-guarded
type: code
branch: feature/community-knowledge-guarded
reviewed_commit: 3bed70a
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 4
scores: { correctness: 1, security: 1, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 9/12
previous_total: 9/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

Narrow re-anchor of the delta `f941b84..3bed70a`, one commit, two files:

- `3bed70a` `fix: stop overclaiming [E] on the front page, and bound the destructive
  family not one spelling` (`README.md` +1/-1, `tests/community-refresh.test.sh` +7/-3)

Confirmed by `git diff f941b84 3bed70a --stat`: exactly those two files, 8 insertions,
4 deletions. Nothing else moved.

**On the anchor.** `git rev-parse --short HEAD` resolves to `bb5db9c`, not `3bed70a`.
`bb5db9c` is `docs(evals): community-knowledge guards review, 9/12 APPROVE at f941b84`,
the commit that made the previous version of THIS record tracked, and it touches
`docs/evals/` and nothing else. The anchor is therefore recorded as `3bed70a`, which is
the commit whose CODE I read: I verified `git hash-object` for `README.md`,
`tests/community-refresh.test.sh` and `install.sh` equals `git rev-parse 3bed70a:<path>`
for all three, and `git diff 3bed70a bb5db9c --stat` shows only this record. `3bed70a` is
an ancestor of HEAD and `merge-gate.sh:294` compares with `':(exclude)docs/evals'`, so the
freshness check passes on it by construction rather than by luck.

This record is committed as of `bb5db9c`, so it now shows as MODIFIED rather than
untracked, and is left modified and uncommitted as instructed.

Provenance: ORCHESTRATING SESSION, not an isolated builder, so
`build_model_as_dispatched:` is omitted by design.

Mutation discipline: every mutation ran against copies under `/tmp/odeo-mut/`, a
standalone tree holding `install.sh` plus `tests/`, so the repository was never the
mutation target and no restore step was required. Re-verified afterwards anyway: all
three files bit-identical to their `3bed70a` blobs, `git status --porcelain` clean
except this record. No command ran against the real `~/.claude/community-knowledge`.

Carried forward by agreement and deliberately NOT re-derived: I3 (the clone-path `else`
arm), I4 (offline with no exit offered), I5 (delivery to already-installed users), and
the round-3 nitpicks. They still ship, so they still hold their bands down; see Scores.

## Verification performed

### 1. I1, the publish hold, is closed

`README.md:39` now reads: guardrails are tagged `[E]` where a mechanism holds them and
`[I]` where the model does, an `[E]` is backed by a script with an exit code rather than
by the model's goodwill, an `[I]` is layered with verifiers and your gate on top.

Checked clause by clause against `AGENTS.md:195-197`:

| Clause | `AGENTS.md:195-197` | Verdict |
|---|---|---|
| tagged `[E]` where a mechanism holds them, `[I]` where the model does | "a mechanism physically stops it ... or [I] instructed, the model holds it" | TRUE |
| `[E]` backed by a mechanism, not the model's goodwill | "a mechanism physically stops it" | TRUE |
| `[E]` is "a script with an exit code" | "(script exit code, tool restriction, git hook)" | one of three kinds, see N1 |
| `[I]` layered with verifiers and your gate on top | "layered with verifiers and the human gate" | TRUE |

**The contradiction with `skills/commit-push/SKILL.md:104` is gone.** The old sentence
made an absolute claim ("nothing in the system can quietly weaken an `[E]`") that
`SKILL.md:104` ("Never bypass pre-commit hooks with `--no-verify` without asking")
directly conceded was false. The new sentence makes no immutability claim at all, so
there is nothing left to contradict. I re-grepped the README for sibling absolutes
(`nothing (in|can)`, `never be`, `cannot be`, `impossible`, `guarantee`): the three hits
are `:33` (the gate rule, a definition), `:144` and `:204` (both about `publish-guard`
and `privacy-scan`, which are scripts with exit codes, so both are accurate). No sibling
overclaim was left behind.

**No new overclaim is introduced.** The one imprecision I found runs in the opposite,
safe direction: it under-describes the mechanism set rather than overstating safety. See
N1 in Nitpicks.

### 2. I2, the invariant assertion, reddens on every named mutation

The assertion at `:120` is now
`grep -qE 'rm +-[a-zA-Z]*r|git +clean|-delete|> *"?\$COMMUNITY_DIR'`.

Method: copy `install.sh` + `tests/` to `/tmp/odeo-mut/`, insert one destructive command
immediately before the move-aside remedy at `install.sh` `if mv "$COMMUNITY_DIR"
"$stale"`, run the suite, and read the INVARIANT's own line specifically rather than the
overall exit code, which is what distinguishes "assertion 6 caught it" from "cases 3 and
4 caught it". Baseline on the unmutated copy: 9/9 ok.

| Mutation inserted | Assertion 6 itself |
|---|---|
| `rm -fr "$COMMUNITY_DIR"` (the round-3 mutation that walked past) | REDDENS |
| `rm -rf "$COMMUNITY_DIR"` | REDDENS |
| `rm -r "$COMMUNITY_DIR"` | REDDENS |
| `git clean -xfd` | REDDENS |
| `find "$COMMUNITY_DIR" -mindepth 1 -delete` | REDDENS |
| `: > "$COMMUNITY_DIR/f.md"` (truncation) | REDDENS |

**I2 as filed is fixed.** The exact mutation that defeated the old check, and the three
other spellings named in round 3, all now redden the invariant itself, not merely the
scenario cases. The move from `grep -q` to `grep -qE` is correct and the alternation
produces no false positive on the current block: `git clone` at `install.sh` does not
match `git +clean`, and the human-facing "Delete it when you no longer need it" line does
not match `-delete` (no leading hyphen).

### 3. Is the pattern as wide as the claim it makes? No

The comment at `:116` says the pattern "covers the DESTRUCTIVE FAMILY, not one spelling
of it". I probed the boundary with seven more destructive spellings, same method:

| Mutation inserted | Assertion 6 | Total FAILs in suite |
|---|---|---|
| `rm -Rf "$COMMUNITY_DIR"` | WALKS PAST | 3 |
| `rm --recursive --force "$COMMUNITY_DIR"` | WALKS PAST | 0 (BSD `rm` rejects the long option, so it is inert on macOS; on GNU it deletes) |
| `git -C "$COMMUNITY_DIR" clean -xfd` | WALKS PAST | **0** |
| `git -C "$COMMUNITY_DIR" reset --hard origin/main` | WALKS PAST | 2 |
| `git -C "$COMMUNITY_DIR" checkout -- .` | WALKS PAST | 1 |
| `find "$COMMUNITY_DIR" -type f -exec rm -f {} +` | WALKS PAST | 2 |
| `mv` then `rmdir` the mirror | WALKS PAST | 3 |

So the pattern is materially wider than `grep -q 'rm -rf'` and closes the filed finding,
but it is still narrower than the class its comment names. See I1 below for the one case
that matters most.

### 4. Nothing else changed, everything still green

- `git diff f941b84 3bed70a --stat`: `README.md` and `tests/community-refresh.test.sh`
  only.
- All 29 suites in `tests/`: **29 passed, 0 failed**.
- `bin/docs-claims-check.sh`: rc=0, "every countable claim matches the tree"
  (bin executables 23, test suites 29, programs with their own suite 22).
- `bin/skills-lint.sh`: rc=0, "all invariants hold".

## Critical

None. No path deletes or truncates the user's mirror; the shipped `install.sh` block
contains none of the destructive spellings probed above; the two changed files introduce
no behavior change to the installer at all (one is a README sentence, one is a test
assertion). The publish hold from round 3 is lifted.

## Important

**I1, `tests/community-refresh.test.sh:116-122`, the guard is still narrower than the
class its comment names, and one realistic spelling is invisible to the ENTIRE suite.**

`git -C "$COMMUNITY_DIR" clean -xfd` walks past the invariant AND reddens nothing else:
total FAILs 0. Both halves matter. It evades `git +clean` because the pattern requires
`git` immediately followed by whitespace and `clean`, while `git -C "$DIR" clean` puts
`-C "$DIR"` in between; and it evades every behavioral case because no fixture in the
file has an UNTRACKED file, so `clean -xfd` removes nothing the assertions look at.
This is not a theoretical spelling: `git -C "$COMMUNITY_DIR" ...` is the form used by
every single git call in the block under test (`install.sh` fetch, rev-parse, merge,
status), so it is the spelling a future edit is most likely to reach for. `rm -Rf`
(valid on both BSD and GNU) and `find ... -exec rm -f {} +` also walk past the invariant,
caught only by the scenario cases, which is precisely the backstop the comment at
`:114-115` says this assertion must not depend on ("asserted independently of every
classification above ... If a future state is misclassified, this is what keeps it
survivable"). For an unenumerated state the scenarios by definition do not cover it, so
the invariant is the only net, and it has holes.

`git -C "$DIR" reset --hard` is the other one worth naming: it destroys uncommitted user
edits, is a plausible remedy for the "local edits" and "diverged" states this block
classifies, and the invariant misses it entirely.

This is the second consecutive round patching the same guard with the same shape, which
the repo's own `.claude/tasks/lessons.md` tells us to stop doing: "prefer a structural
fix over patching instances: if the next round can find a fourth shape, the fix was an
instance patch" (2026-08-06). I found four more shapes.

Concrete fix, structural rather than a third spelling round. Replace the source-text
grep as the PRIMARY invariant with an outcome assertion no spelling can evade: in `run()`,
before invoking the block, plant a canary in the mirror (one tracked file with known
content, one UNTRACKED file), and after the block assert both are still reachable
somewhere under `$home/.claude/` (in place or in the `.stale-*` copy). That is an
assertion over outcomes, so `rm -Rf`, `git -C ... clean -xfd`, `reset --hard` and any
spelling nobody has thought of all fail it identically, and it removes the class instead
of enumerating it. Keep the grep as a cheap secondary tripwire, and narrow its comment
to what it actually does (see N2). If the grep must stay primary for now, widen it to
`rm +-[a-zA-Z]*[rR]|rm +--recursive|git( +-C +[^ ]+)* +(clean|reset +--hard|checkout)|-delete|-exec +rm|> *"?\$COMMUNITY_DIR` and say in the comment that it is a
blocklist, which is the weaker form the security baseline tells us to avoid.

## Nitpicks

**N1, `README.md:39`, "an `[E]` is backed by a script with an exit code" names one of the
three mechanism kinds `AGENTS.md:196` lists.** The source of truth says "(script exit
code, tool restriction, git hook)", and at least three shipped `[E]` rules are not
scripts: `AGENTS.md:244` (the personal layer is kept out of a public repo by gitignore),
`:331` (`architect` and `architecture-reviewer` cannot write or execute anything, a tool
restriction) and `:340` (worktree isolation). The README is internally inconsistent about
this within the same section: `:41`, two lines later, describes the `architect`'s missing
write tool as something you can verify yourself, which is exactly an `[E]` that is not a
script. This is an UNDER-claim, not an overclaim, and the load-bearing contrast ("rather
than by the model's goodwill") is true for every `[E]`, so it does not hold publish. Fix,
one clause: "an `[E]` is backed by a mechanism, a script's exit code, a tool restriction
or a git hook, rather than by the model's goodwill".

**N2, `tests/community-refresh.test.sh:116`, "covers the DESTRUCTIVE FAMILY, not one
spelling of it" is the claim-wider-than-the-mechanism shape the same comment cites
`lessons.md` about, two sentences later.** The enumeration right after it is accurate
(those four spellings are covered, verified above), so the defect is the summary line,
not the detail. Until I1 is fixed structurally, narrow it to what is true: "covers the
four spellings named below, which is wider than the single literal it replaces and still
NOT the whole destructive family, see the suite's outcome assertions for the class."

**N3, `tests/community-refresh.test.sh:120`, the assertion greps the SOURCE TEXT of the
block, so it is fragile to prose.** A future comment inside `install.sh` explaining "this
path never uses `rm -rf`" would turn the guard red while the code is correct. The block's
current comment at `install.sh:3-9` already avoids the literal by writing "never deleted",
which suggests the author felt this. The outcome-based canary in I1 removes this
fragility too; if the grep stays, note the constraint above it so nobody spends a debug
cycle on a red that is about a comment.

## Scores

correctness 1/2 · security 1/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 2/2  -> total 9/12  (threshold: >=9, no zero)

- **correctness 1**, unchanged and not re-derived: this commit changes no installer
  behavior at all, and the band is held where round 3 left it by I3 and I4, which still
  ship (two states get a network excuse for a local cause; one can freeze with no exit
  offered).
- **security 1**, unchanged and not re-derived: held at 1 by I5, the delivery half that
  is out of scope by agreement. Nothing in this delta touches the security surface; the
  test change strengthens a data-destruction guard.
- **performance 2**, one `grep -qE` over a 55-line string, run once.
- **readability 2**, the README sentence is now materially more honest than what it
  replaced and reads plainly for a non-developer; the test comment records why the change
  was made and names the four spellings it covers. N1 and N2 are wording precision on
  otherwise accurate prose, not confusion about what the code does.
- **testing 1**, the filed I2 is genuinely closed (six mutations, including the exact one
  that defeated round 3, now redden the invariant itself rather than a neighbouring
  case). The band stays at 1 because three of the four gaps that held it there are
  untouched, by agreement, and I1 adds a fourth: the untested restore branch, the
  untested `else` arm, the `set +e` fidelity gap, and a class guard with a case
  (`git -C "$DIR" clean -xfd`) that no assertion in the file can see.
- **conventions 2**, English comments, Conventional Commits with a body that names both
  the defect class and the lesson it comes from, correct feature branch, no secrets, no
  unreferenced TODOs, mutation evidence produced before the claim was written for the
  four spellings it enumerates. I1 is a residual gap in one guard, the same call round 3
  made, not a fresh violation of a documented lesson.

## Ceiling

11/12 reachable on this branch, unchanged from round 3 and unchanged by this commit.
Security structurally caps below 2 while the delivery half of I5 stays out of scope: the
rule is correct in the repository but cannot reach an already-installed user's personal
global file without a change that is a separate decision by the system's own rule.
Correctness and testing fall short on findings with concrete fixes, not on anything
structural; a two-file docs-and-test commit could not have moved correctness or security
in either direction.

## What's good

The README fix did the harder thing available to it. The easy repair was to soften the
absolute ("almost nothing can weaken an `[E]`"), which would have kept the shape of the
overclaim while making it unfalsifiable. Instead the sentence was rebuilt around the
distinction that is actually true and actually load-bearing, mechanism versus the model's
goodwill, and it is still the strongest sentence in that section. It no longer invites a
reader to go find the counterexample, which is the property that matters for a public
front page.

Moving from `grep -q` to `grep -qE` with a named alternation, and writing the reason
above it, converts a check that read as a class guarantee into one that at least attempts
the class. The four spellings it names are exactly the four the previous review
demonstrated, so the fix is anchored to evidence rather than to imagination, and I
re-confirmed all four by mutation rather than by reading.

The comment does not hide the history. It says plainly that a literal `rm -rf` check
"read as a class guarantee" and names the shape from `lessons.md`. A test that records
why it is shaped the way it is, at the line where the next person will change it, is
worth more than the assertion itself.

Scope discipline was exact: two files, eight insertions, four deletions, no drive-by
edits, and the 29 suites plus both lint gates stayed green.

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
- **Round 3, `f941b84`, 9/12, APPROVE WITH COMMENTS.** I1 through I4 of round 2 closed
  and independently verified, including by mutation. Merge unblocked, but PUBLISH held
  on one line: `README.md:39` overclaimed the `[E]` guarantee on the public front page,
  contradicted by `skills/commit-push/SKILL.md:104`. Second finding: the invariant guard
  in the new suite was a single-spelling `grep -q 'rm -rf'` presented as a class
  guarantee, defeated by `rm -fr`. I5 carried forward by agreement and widened.
- **Round 4, `3bed70a`, 9/12, APPROVE WITH COMMENTS. SAME total, but the publish hold is
  lifted.** Both round-3 findings are closed as filed: the README sentence now matches
  `AGENTS.md:195-197` clause for clause, no longer contradicts `SKILL.md:104`, and
  introduces no new overclaim (the one imprecision, N1, runs in the safe direction); and
  the invariant assertion now reddens on all six destructive spellings tested, including
  the `rm -fr` that defeated it last round. The total is unchanged because neither fix
  sat inside a band that could move: the README overclaim held PUBLISH rather than
  docking a dimension, and testing stays at 1 because three of its four named gaps were
  out of scope by agreement. Better than round 3 in substance despite the equal score.
  One new Important: the widened pattern is still narrower than the class it names, and
  `git -C "$COMMUNITY_DIR" clean -xfd`, the spelling that matches the block's own house
  style, is invisible to every assertion in the file. Recommended fix is structural (an
  outcome canary), not a third round of spellings.
