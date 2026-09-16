---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 663e63c
artifact_version: 2
date: 2026-09-16
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 9/12
verdict: APPROVE WITH COMMENTS
previous_total: 7/12
---

## Artifact

Branch `feature/windows-powershell-entry` at `663e63c`. Round 2 reviews `fab5c0d..HEAD`
(one commit, `663e63c`) plus every round-1 finding. Scope still excludes
`skills/build/SKILL.md` and `skills/retro/SKILL.md` (skill-reviewer, in parallel).
No plan exists in `docs/plans/` for this branch, so there is no contract to compare against.

## Round-1 findings, verified one by one

| # | Round-1 finding | Status |
|---|---|---|
| C1 | `install.ps1` unclassified, publish blocked | **Closed.** `docs/public-paths.txt:29`; and `tests/publish-guard.test.sh` case 16 now runs the REAL tree through the REAL lists. Measured: `git ls-tree -r -z --name-only HEAD \| publish-guard.sh --require-allowlist -` reports internal BLOCK lines only, zero `unclassified`. See I1 for the residual. |
| I1 | INSTALL.md documents tracked symlinks a public clone does not have | **Closed.** The `file .claude/agents` check and the tracked-symlink rationale are gone; the caveat is now `install.sh --link` symlinking into `~/.claude`, which I verified against `install.sh:5,13,44` (`--link` = symlink instead of copy). `install.ps1:155-158` says the same thing. |
| I2 | `accepted` extractor fails open | **Partly closed.** `-h\|--help)` is now caught (measured: `accepted` becomes `--help --lang --link -h`, case 3 fails twice). `-h \| --help)` still is not. See I2 below. |
| I3 | `$shArgString` unquoted | **Closed.** `ConvertTo-BashSingleQuoted` moved above the sh-args block and applied per element (`install.ps1:51-73`). Case 9 now asserts what install.sh RECEIVES in `$@` (`fake install.sh: --link --lang de`, read after a real `eval`), not the printed string, and case 10 feeds those post-quote-removal arguments back through the real parser. Checked the word-splitting worry explicitly: install.sh's only value-taking option reads `$2` as one argument, so `'--lang' 'de'` is identical to `--lang de`; no current or plausible option wants its value split, and if one did, quoting is still the correct side of that trade. |
| I4 | anti-port denylist | **Partly closed.** Case 9b snapshots HOME and the clone around the real run and asserts byte-identity, with a planted-file canary; the grep is relabeled an early warning naming its five spellings. The snapshot is blind to three primitives. See I3 below. |
| I5 | delegation grep that could not fail | **Closed.** `tests/install-ps1.test.sh:170-176` strips the comment-based help (`sed '1,/^#>/d'`) and requires `-lc … ./install.sh`. Fails closed if `#>` ever disappears (sed deletes to EOF, body empty, grep fails). |
| I6 | `wslpath` outside try/catch | **Closed.** `install.ps1:113-122`, with the NativeCommandError/5.1 reason in the comment. `$LASTEXITCODE` can be stale when the catch fires, but `-not $wslRepo` still takes the error path, so it fails closed. The message now names both escape routes. |
| I7 | header overclaim | **Closed.** "end to end on any machine" is now scoped to machines with pwsh; the residual list gained PowerShell 5.1. "only the eight source-level assertions run" is exact: I counted them (2 emitted-flag + 1 bogus-flag + 2 reachability + 1 arm-count + 1 delegation + 1 port). |
| nits | System32/SysWOW64, WSL arm executed, instrument line, ValidateSet `head -1` | All four closed. Case 12b runs the WSL arm's line through the fake with `WSLPATH_OUT` pointed at a real directory; the ValidateSet count is asserted before its contents. |

## Verification (by measurement)

- `bash tests/publish-guard.test.sh` -> ALL PASS, including case 16 and its canary.
- `bash tests/install-ps1.test.sh` -> 33/33, pwsh present.
- `bash bin/docs-claims-check.sh --assertions` -> all four claims match the tree:
  23 bin executables, 30 suites, 22 programs with a suite, **assertions = 881**. The
  README's 881 is correct, not asserted.
- Empty-feed probe on the guard: `printf '' | publish-guard.sh --require-allowlist -` ->
  `clean (0 files checked).`, rc 0, no `unclassified` line. This is what makes I1 below true.
- Extractor probe, run from a script file (not an inline string) on four synthetic parser
  blocks: real block -> `[--lang --link]`, 2 arms / 2 flags; `-h|--help)` -> 4/4 (caught);
  `-h | --help)` -> **2/2, invisible**; two arms on one line -> **2/2, invisible**.
- Snapshot probe, same function as the suite's: regular file SEEN; **symlink to a directory
  MISSED; symlink to a file MISSED; created directories MISSED; permission change MISSED.**
- Em/en dash scan over the whole diff: clean (house rule, AGENTS.md).

## Findings

### Critical

None. The round-1 Critical is closed and structurally guarded.

### Important

**I1. Case 16 passes on an empty read, and its canary does not answer the question its own
comment asks.**
`tests/publish-guard.test.sh:141-152`. The case greps the guard's output for
`unclassified path` and calls the absence a pass. Measured above: on empty stdin the guard
prints `clean (0 files checked).` and exits 0, so any failure of
`git ls-tree -r -z --name-only HEAD` (unborn HEAD, a git that errors, the pipeline's rc is
never read even under `pipefail` because it sits in a command substitution) produces exactly
the same green. The comment at line 146 states the hazard precisely, "the case above is a
decoration that passes on an empty read", and then plants the probe path with `printf`,
i.e. through a DIFFERENT feed. So the canary proves the guard invocation can report an
unclassified path; it cannot prove the tree feed was non-empty, which is the only way this
case goes vacuous. The round-1 record recorded that exact trap ("First attempt without a
path list returned clean (0 files checked); that run was vacuous").
Fix: make the count part of the assertion, one input, read twice:
```sh
git -C "$ROOT" ls-tree -r -z --name-only HEAD > "$TMP/tree.z"
n_paths=$(tr -cd '\0' < "$TMP/tree.z" | wc -c | tr -d ' ')
[ "$n_paths" -gt 0 ] || { echo "FAIL: the real-tree feed was empty, so the check below proves nothing"; fail=1; }
real_out="$(... < "$TMP/tree.z")"
```
Optionally assert `n_paths` equals `git ls-tree -r --name-only HEAD | wc -l`.

**I2. The arms extractor still fails open, and the comment above it claims every arm.**
`tests/install-ps1.test.sh:81-86` says "EVERY arm is extracted and then split on `|`". The
pattern `^[[:space:]]*[^ )|]+(\|[^ )|]+)*\)` excludes the space character, so an arm written
`-h | --help)` (legal, common sh style) matches nothing at all, and a second arm placed
after a previous arm's `;;` on the same line matches nothing either. Measured above: both
leave `accepted` at `--lang --link` and case 3 green, which is the identical fail-open that
round 1 found, narrowed by one spelling rather than eliminated. The new count cross-check
(lines 93-99) cannot catch it, because it counts the arms the same regex already saw:
`n_arms` and `n_flags` both stay 2.
Fix: get the arm count from a source the regex does not own, and fail loudly on disagreement.
The block's `;;` terminators are exactly one per arm (3 in today's block = `--link`, `--lang`,
`*`):
```sh
n_semis=$(printf '%s\n' "$parser" | grep -o ';;' | grep -c .)
[ "$((n_arms + 1))" -eq "$n_semis" ] || bad "parser has $n_semis arms, the extractor read $((n_arms + 1)); an arm shape it cannot parse was added"
```
That fails closed on ANY arm spelling, which is what makes the class claim in the comment
true. Until then, narrow the comment to "every arm written `flag)` or `a|b)` without spaces",
and the same applies to `install.ps1:57-60`, which tells the reader the suite "asserts every
option install.sh accepts is reachable from here".

**I3. The byte-identity snapshot is blind to symlinks, new directories and permission
changes, and `--link` is a symlink installer.**
`tests/install-ps1.test.sh:255-269`. `find . -type f` lists regular files only. Measured
above: a symlink into HOME, a symlink to a file, `mkdir -p .claude/agents`, and a `chmod +x`
all leave `before` and `after` identical. Case 9b's comment claims the class, "it must leave
the filesystem BYTE-IDENTICAL, whatever primitive a future edit reaches for", and the canary
plants a regular file, so it proves only the primitive that was never in doubt. This matters
concretely and not theoretically: `install.sh --link` installs by SYMLINKING into
`~/.claude` (`install.sh:13`), the run being snapshotted is `-Link -Lang de`, and a
`New-Item -ItemType SymbolicLink` port, the single most likely way install.ps1 grows a second
implementation, is exactly what the guard cannot see. The comment names one exclusion
(`.cache/powershell/`) and says "Nothing else is excluded", which reads as completeness.
Fix: widen the mechanism and the canary together:
```sh
snapshot() {
  [ -d "$1" ] || return 0
  ( cd "$1" && find . -mindepth 1 -not -path './.cache/powershell*' \
      -exec sh -c 'for p; do
          if [ -L "$p" ]; then printf "L %s -> %s\n" "$p" "$(readlink "$p")";
          elif [ -d "$p" ]; then printf "D %s\n" "$p";
          else printf "F %s\n" "$(shasum "$p")"; fi; done' _ {} + | sort )
}
```
and plant a symlink and a directory in the canary beside the file, since a canary that plants
only what the mechanism already sees cannot tell you the mechanism is narrow.

### Nitpicks

- `tests/publish-guard.test.sh:139` reassigns `ROOT` inside an otherwise hermetic suite and
  makes it environment-dependent: outside a git work tree the case FAILS rather than SKIPs
  (line 155). Defensible as fail-closed, and the published artifact is a git repo, but a
  tarball consumer running the suite meets a red that says nothing about the guard. A named
  SKIP plus the loud FAIL only when `.git` is present would separate "cannot run" from
  "ran and found something".
- `tests/install-ps1.test.sh:279-281` wires `WSLPATH_OUT` through `run_ps1` for every case,
  not only 12b. Harmless (the default keeps the non-existent `/mnt/c/repo`), but the fake's
  comment explains the default and not the override; one line naming which case sets it
  would save the next reader the grep.
- Case 9b snapshots only the Git Bash arm's run. The WSL arm (12b) executes a full handoff
  and is not bracketed, so a port reachable only from that branch is unguarded. Reusing
  `before`/`after` around 12b is three lines.
- `install.ps1:113-122`: the catch sets `$wslRepo = $null` and leaves `$LASTEXITCODE`
  whatever the previous native call left. It fails closed today only because of the
  `-not $wslRepo` half of the condition. Setting `$LASTEXITCODE = 1` in the catch would make
  the intent explicit rather than incidental.

## Scores

correctness 2/2 - both round-1 correctness defects are gone: the INSTALL.md section no longer
tells a public-clone user to verify a path the snapshot strips (checked against
`publish-snapshot.sh`'s `rm -rf` of `.claude/`), and `wslpath` is inside try/catch with the
5.1 reason written down. The quoting change was checked for the word-splitting regression it
could have caused and does not have one; what install.sh receives in `$@` is now asserted
after a real `eval`, not inferred from the printed string. Nothing in the shipped Windows path
is wrong as far as it can be checked off Windows, and what cannot be checked is stated.

security 2/2 - every element pasted into a bash command line now goes through
`ConvertTo-BashSingleQuoted`, so the safety of the flag string no longer depends on the
ValidateSet holding forever; the repo path was already proven by an executing fake under an
`O'Brien` path. Test harness remains sealed: `env -i`, HOME redirected, PATH replaced, no-op
`install.sh`, and the repo's own `install.ps1` only ever copied or parsed. No secrets, no PII,
no network.

performance 2/2 - nothing in a hot path; the new real-tree case adds one `ls-tree` over 235
paths and the snapshots two `find` passes over a sandbox.

readability 1/2 - the comments do real teaching work (why System32 AND SysWOW64, why the
try/catch, why the fixture lists are unset for case 16, what the denylist does NOT cover) and
three of the four round-1 overclaims were narrowed rather than papered over. Docked because
three comments still name a class the mechanism does not deliver: "EVERY arm is extracted"
(I2), "whatever primitive a future edit reaches for" / "Nothing else is excluded" (I3), and
case 16's "a decoration that passes on an empty read" describing a hazard its canary does not
close (I1). That is the writing failure this repo's lessons.md dated 2026-09-16 names, applied
correctly in three places in this same commit and missed in three others.

testing 1/2 - a genuinely strong round: the real tree now runs through the real lists so the
next unclassified root file reddens a suite instead of a release; the anti-port rule became an
outcome check; two assertions that could not fail now can, both mutation-proven. Docked for
three instrument gaps that are all the same shape as the ones round 1 found, narrowed rather
than eliminated: a vacuity that an empty feed still walks through (I1), a fail-open on a legal
arm spelling with a cross-check that cannot see it (I2), and a byte-identity claim blind to
the exact primitive the `--link` mode uses (I3). All three are measured above, none is
hypothetical.

conventions 1/2 - the hard breach is fixed (classification, with a structural guard behind it),
the countable claims match the tree, README's 881 is real, no em or en dashes, comments are
English. Docked, not zeroed, because lessons.md 2026-09-16 ("a guard's comment may name only
what it verifies; to claim a CLASS the mechanism must assert an OUTCOME") recurs three times
in the same commit that applies it three times elsewhere. Per the user's own standing rule on
repeating lessons, the answer is not a fourth phrasing: I2 and I1 both have a concrete
mechanism above (an arm count the regex does not own, a feed count asserted with the check),
and I3 is a one-function widening. Give them the mechanism and the class claims become true.

total 9/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

## Ceiling

12/12 remains reachable and is now close. Nothing structurally caps: the Windows-unverifiable
half is handled the way this repo accepts (stated residual, now including 5.1), and all three
remaining findings have a concrete mechanism written out above, none larger than a helper
function. Full marks on testing and conventions need those three mechanisms; readability
follows from them, since with the mechanisms in place the existing comments become true as
written.

## What's good

- The response to C1 was structural rather than local: classifying `install.ps1` fixes the
  instance, and case 16 makes the whole hermetic-fixture blind spot visible for every future
  root file. It also names why nothing noticed ("the fixture could not know the repo had
  grown one") and disarms the fixture-scope trap with `env -u`, which is the failure the case
  would otherwise have hit on its first run.
- Case 9's shift from "what install.ps1 printed" to "what install.sh received in `$@`" is the
  right level to assert at; it turns the quoting change from a plausible edit into an observed
  property, and case 10 then feeds those exact arguments back through the real parser.
- Every claim in the commit body that I spot-checked held: 0-then-2 failures for the
  `-h|--help` mutation, the `Add-Content` walk-past, the 881 count, the eight non-pwsh
  assertions. Measured claims, not asserted ones.
- The denylist was kept and RELABELED instead of deleted. Fast hint plus slow guarantee, with
  the hint's coverage written down, is the honest shape.

## History

- 2026-09-16 (`fab5c0d`, claude-opus-5[1m], effort high): round 1. REQUEST CHANGES, 7/12
  (correctness 1, security 2, performance 2, readability 1, testing 1, conventions 0).
  One Critical (`install.ps1` in neither classification list, hard-blocking the publish path),
  seven Important, six nitpicks. No prior record, so no regression comparison.
- 2026-09-16 (`663e63c`, claude-opus-5[1m], effort high): round 2. APPROVE WITH COMMENTS,
  9/12. **Improved, +2**: correctness 1 -> 2, conventions 0 -> 1 (the hard breach is fixed;
  held at 1, not 2, for the lessons repeat described below); readability, testing, security
  and performance unchanged in score. The Critical
  and all seven Importants are addressed, five of them completely and three by outcome rather
  than by text check. Three findings remain, and all three are the SAME class narrowed rather
  than eliminated (a comment claiming more than its mechanism covers): the real-tree case
  still passes on an empty feed, the arm extractor still misses `-h | --help)`, and the
  byte-identity snapshot still misses symlinks and directories. That the class survived one
  round of fixing is the signal worth carrying forward, per the user's standing rule that a
  recurring recorded lesson needs a mechanism at the point of use, not another phrasing.
