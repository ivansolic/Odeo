---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: cebc0a0
artifact_version: 3
date: 2026-09-16
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 9/12
---

## Artifact

Round 3. The subject is `4416477`, which answers the three round-2 Importants and two of the
four nitpicks. `reviewed_commit` is `cebc0a0` because that is HEAD of the branch and the gate
compares the whole tree against it; the ledger-backup program that `cebc0a0` adds is reviewed
separately in `docs/evals/code-ledger-backup.md`, which carries this same branch. Scope still
excludes `skills/build/SKILL.md` (skill-reviewer). No plan exists in `docs/plans/` for this
branch, so there is no contract to compare against.

Every claim below was reproduced here rather than read out of the commit body.

## Round-2 findings, verified one by one

| # | Round-2 finding | Status |
|---|---|---|
| I1 | case 16 passes on an empty feed, canary uses a different feed | **Closed, by mechanism.** `tests/publish-guard.test.sh:143-177`. The tree goes to a file, the NUL count is asserted before the guard reads it, and the probe is appended to a COPY of that same file. Measured here: `ok: the real tree feeds 238 tracked paths into the guard`, then `ok: and the same read reports a planted unclassified path`, whose pattern is now `*unclassified-probe*` rather than the generic `*unclassified*`. A `git ls-tree` that fails now reddens twice (the `if !` branch and the count), where before it was indistinguishable from a clean repo. |
| I2 | arm extractor still fails open on `-h \| --help)`, cross-check self-confirming | **Closed, and fail-closed.** `tests/install-ps1.test.sh:81-116`. I ran the shipped extractor against six synthetic parser blocks: real block `heads=2 semis=3` GREEN; `-h \| --help)` now READ (`arms=[--help --lang --link -h]`, which makes case 3 fail twice because install.ps1 emits neither); `-h\|--help)` likewise; two arms on one line `heads=2 semis=4` RED; an arm the regex cannot see terminated by `;&` RED; an arm body containing `;;` in a string RED. Every mutation I could construct either becomes visible or reddens the count. The `;;` source is genuinely not owned by the label regex, which is what round 2 asked for. |
| I3 | byte-identity snapshot blind to symlinks, directories, chmod | **Closed for the two shapes that matter.** `tests/install-ps1.test.sh:282-300`. Links are recorded by `readlink` target, directories by name, files by hash, and the canary is a loop over file/dir/link. Measured in the shipped suite: three separate `ok - the comparison notices a planted {file,dir,link}` lines. This is the right fix for the named risk, `install.sh --link` symlinking into `~/.claude`. Residual: modes are still invisible, see the nitpicks. |
| nit | WSL arm not bracketed by the no-write assertion | **Closed.** `tests/install-ps1.test.sh:502,509-514`, and it passes: `ok - and the WSL arm changed nothing under HOME or in the clone either`. |
| nit | `$LASTEXITCODE` stale when the catch fires | **Closed, by construction.** `install.ps1:118-127`. `$wslRc` is initialized to 1 and assigned INSIDE the try, so the failure path no longer depends on which native command ran last. The comment states exactly that reason. |
| nit | case 16 FAILs rather than SKIPs outside a work tree | Not taken. Still `fail=1` at `tests/publish-guard.test.sh:180-183`. Defensible as fail-closed; carried forward unchanged. |
| nit | `WSLPATH_OUT` wired for every case, comment explains only the default | Not taken. Harmless, carried forward. |

## Verification (by measurement, on this machine)

- `bash tests/install-ps1.test.sh` -> `all 37 assertions passed`, pwsh present.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, 238 tracked paths through the real lists,
  zero unclassified.
- `bash bin/docs-claims-check.sh --assertions` -> `bin executables = 24`, `test suites = 32`,
  `programs with their own suite = 24`, `assertions = 932`. Every countable claim in the README
  matches the tree.
- Extractor probe, six mutated parser blocks, results in the I2 row above.
- Snapshot probe, the shipped `snapshot()` function lifted verbatim: a `chmod +x` on an existing
  file leaves `before` and `after` identical (still blind); pwsh under a fresh HOME created
  nothing at all across three runs, so widening to `-type d` introduces no flakiness from the
  host runtime's own bookkeeping.
- Em/en dash scan over both commits: clean.

## Findings

### Critical

None.

### Important

None. All three round-2 Importants are closed by a mechanism rather than by narrowing a
sentence, and I reproduced each mechanism's failure mode rather than trusting the commit body.

### Nitpicks

- `tests/install-ps1.test.sh:282-288`. The widening comment reads "Measured: with `-type f`
  only, a planted symlink, a symlink into HOME, a new directory and a chmod +x were all
  invisible", and the next sentence lists what IS recorded (targets, names, hashes), which
  correctly omits modes. Strictly the comment is true, but three of the four items in that list
  were fixed and the fourth was not, in one sentence, under a heading that says the widening is
  "the load-bearing part". Measured: `chmod +x` is still invisible. Either drop `chmod +x` from
  the sentence or record the mode (`printf 'F %s %s\n' "$(ls -l "$p" | cut -c1-10)" "$(shasum "$p")"`).
  The same applies to the older "Nothing else is excluded" line, which now also elides fifos,
  sockets and devices via the `\( -type f -o -type l -o -type d \)` filter.
- `tests/install-ps1.test.sh:290`. `-not -path './.cache/powershell/*'` excludes the children of
  that directory but no longer the directory itself, now that `-type d` is in scope. It is safe
  today only because earlier cases have already created it; a reordering that made 9b the first
  pwsh run would redden it as an "install". Drop the slash: `-not -path './.cache/powershell*'`.
- `tests/install-ps1.test.sh:291-298`. `find -print` piped into `while IFS= read -r p` splits a
  path containing a newline into two entries. Sandbox-only, but `-print0` plus `read -r -d ''`
  costs one line and removes the class.
- `tests/install-ps1.test.sh:108-110`. When the `;;` count disagrees because an arm BODY contains
  `;;` inside a string (measured: RED), the message says "the parser has 5 arms but the extractor
  saw 4", which sends the next reader after a missing arm that does not exist. Name both
  possibilities in the second line.
- The commit body says the tree's "NUL count asserted (235 paths)"; the code asserts `>= 50` and
  the tree is now 238. The loose threshold is the right choice, so it is the sentence that is
  imprecise, not the guard.

## Scores

correctness 2/2 - the only production change in this round, `install.ps1:118-127`, replaces an
accidental fail-closed with a constructed one, and the reason is written down. Nothing else in
the shipped Windows path moved, and what cannot be checked off Windows is still stated.

security 2/2 - unchanged and still clean: every element pasted into a bash command line goes
through `ConvertTo-BashSingleQuoted`, the harness stays sealed (`env -i`, redirected HOME,
replaced PATH, no-op `install.sh`), no secrets, no PII, no network.

performance 2/2 - the widened snapshot adds one `find` pass over a sandbox HOME, the real-tree
case one `ls-tree` over 238 paths. Nothing in a hot path.

readability 2/2 - raised from 1. The three comments round 2 docked for claiming a class over a
narrow mechanism now describe mechanisms that deliver the class, and each says how it was
measured and what the earlier version missed. The residual is half a sentence about `chmod`,
filed as a nitpick because the enumeration that follows it is accurate.

testing 2/2 - raised from 1. This is the round where the class stopped being narrowed and started
being eliminated: the arm count now comes from the `;;` terminators, a source the label regex
does not own, and every mutation I could build either becomes visible or reddens it; the real
tree case asserts the size of its own feed and plants the probe into that same feed; the
snapshot records the primitive `--link` actually uses, with a canary per shape. I verified all
three by running them, not by reading about them.

conventions 2/2 - raised from 1. The recurring lesson (`lessons.md`, 2026-09-16, "a guard's
comment may name only what it verifies; to claim a CLASS the mechanism must assert an OUTCOME")
was answered the way the user's own standing rule demands, with a mechanism at the point of use
rather than a fourth phrasing of the sentence. Countable claims verified against the tree, no em
or en dashes, comments English, classification intact.

total 12/12 (threshold >= 9, no zero) -> APPROVE.

## Ceiling

12/12, reached. Nothing structurally caps this change: the Windows-unverifiable half is handled
the way this repo accepts (a stated residual, including PowerShell 5.1), and the five nitpicks
above are each one line and none of them weakens a claim the code makes.

## What's good

- The response to all three findings was the same shape, and it is the right one: find a signal
  the broken instrument does not control (the `;;` terminators for the arm count, the feed's own
  NUL count for the tree case, the file TYPE for the snapshot) and assert against that. Two
  rounds of narrowing sentences ended here with the class actually removed.
- The canary loop over file/dir/link is the detail that makes I3 stay closed: a canary that
  plants only what the mechanism already sees is how the narrow snapshot got certified in the
  first place, and the loop makes the next widening self-checking.
- `$wslRc` initialized to 1 and assigned inside the try, with the comment explaining that the
  old code failed closed "by luck rather than by construction", is precisely the distinction
  worth writing down at the point of use.
- Every measurement I re-ran matched the commit body: 2 failures from the spaced arm, 238 paths,
  the three canary shapes, the WSL arm's no-write line, 37 and 932 assertions.

## History

- 2026-09-16 (`fab5c0d`, claude-opus-5[1m], effort high): round 1. REQUEST CHANGES, 7/12
  (correctness 1, security 2, performance 2, readability 1, testing 1, conventions 0). One
  Critical (`install.ps1` in neither classification list, hard-blocking the publish path), seven
  Important, six nitpicks. No prior record, so no regression comparison.
- 2026-09-16 (`663e63c`, claude-opus-5[1m], effort high): round 2. APPROVE WITH COMMENTS, 9/12.
  Improved, +2: correctness 1 -> 2, conventions 0 -> 1. The Critical and all seven Importants
  addressed, but three findings remained and all three were the SAME class narrowed rather than
  eliminated (a comment claiming more than its mechanism covers).
- 2026-09-16 (`cebc0a0`, subject `4416477`, claude-opus-5[1m], effort high): round 3. APPROVE,
  12/12. **Improved, +3**: readability 1 -> 2, testing 1 -> 2, conventions 1 -> 2; correctness,
  security and performance held at 2. All three round-2 Importants closed by mechanism and
  independently re-measured here, plus two of the four nitpicks. The recurring class (comment
  claims a class, mechanism covers an instance) did not survive this round: each guard now keys
  on a signal it does not itself produce. Five nitpicks remain, none of which weakens a claim.
