---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 994ede8
artifact_version: 5
date: 2026-09-17
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## Artifact

Round 5, at `994ede8`. Same artifact scope as rounds 1 to 4. Exactly two things inside that
scope moved since `2e7c740`: a 14-line HOME warm-up in `tests/install-ps1.test.sh` (the fix
round 4 asked for) and one README number (`1007` -> `1016` assertions). Everything else in
`2e7c740..994ede8` belongs to the ledger-backup program, scored separately in
`docs/evals/code-ledger-backup.md`; it is not re-scored here but it was checked for collateral
damage to this artifact (see Verification and n5). `install.ps1` is still byte-identical to
`cebc0a0`, confirmed: `git diff --stat cebc0a0..HEAD -- install.ps1` is empty, and so is the
same diff for `install.sh`, `.gitattributes`, `INSTALL.md`, the language-allowlist suite, the
community-refresh suite, the publish-guard suite and `bin/docs-claims-check.sh`. No plan exists
in `docs/plans/` for this branch, so there is no contract to compare against.

## The round-4 Important: closed, by measurement

Round 4's finding was that case 9b's byte-identity guarantee held only because cases 7 and 8
launch pwsh under the same HOME before the `before` snapshot is taken, which nothing stated, so
a reordering or a future pwsh directory would produce a false FAIL blamed on `install.ps1`.
`tests/install-ps1.test.sh:339-351` now warms the redirected HOME once, immediately after
`PWSH` is resolved and before any snapshot exists.

I did not verify this by reading it. I lifted `mkrepo`, `fakebin`, `snapshot` and `run_ps1`
VERBATIM out of the suite (awk-extracted function bodies, no paraphrase) into a scratch probe
that runs the case 9 / 9b comparison as the FIRST pwsh launch under a fresh HOME, i.e. the
worst case round 4 described, and ran it both ways:

| Probe | Result |
|---|---|
| with the shipped warm-up | `RESULT: IDENTICAL`, the anti-port comparison passes as the first pwsh launch |
| warm-up removed (negative control) | `RESULT: DIFFERENT`, and the diff is exactly the six entries round 4 recorded: `D .`, `D ./.cache`, `D ./.local`, `D ./.local/share`, `D ./.local/share/powershell`, `D ./.local/share/powershell/Modules` |

So the ordering dependency is gone, the fix is load bearing rather than decorative, and the
probe that says so is proven able to give both answers (`lessons.md:15`, `:19`).

Did the warm-up introduce anything new? No. Its output under HOME is
`.cache/powershell/{StartupProfileData-NonInteractive,telemetry.uuid}` plus
`.local/share/powershell/Modules` and the parent directories, all created BEFORE the first
`before` snapshot at `:404`, so no later case can attribute any of it to `install.ps1`. The
repo side is covered too, and that is the part reading alone would miss: `mkrepo` builds a
FRESH sandbox per case, so a first-launch artefact written into the CWD would be invisible to a
HOME warm-up. My probe used a fresh repo directory and the repo half of the snapshot came back
identical as well.

The prune kept alongside the warm-up is still justified, re-measured rather than inherited:
two consecutive launches under an ALREADY WARM HOME still differ on
`.cache/powershell/StartupProfileData-NonInteractive` (hash `ad0d910...` -> `edb0cf4...`). The
comment's reason for keeping it is true at HEAD.

## Verification (by measurement, on this machine)

- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`, pwsh 7.6.6, 9.5s wall.
  Unchanged count: the warm-up asserts nothing, which is n1 below.
- `bash bin/docs-claims-check.sh --assertions` -> `ok: bin executables = 24`,
  `ok: test suites = 33`, `ok: programs with their own suite = 24`, `ok: assertions = 1016`,
  `every countable claim matches the tree`. The README's new number is verified against the
  tree, not against the commit body.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, `the real tree feeds 240 tracked paths into
  the guard`, zero unclassified, planted-path canary green. This is the collateral check on the
  sibling: the ledger-backup work did not break this artifact's real-tree case.
- Order-independence probe and its negative control, as tabled above.
- Prune-necessity probe, snapshot with the prune removed, two warm launches.
- Em/en dash scan over the in-scope diff (`README.md`, `tests/install-ps1.test.sh`): clean.
- Scope files untouched since the 12/12 round: `git diff --stat cebc0a0..HEAD` over
  `install.ps1`, `install.sh`, `.gitattributes`, `INSTALL.md`, `tests/language-allowlist-
  agreement.test.sh`, `tests/community-refresh.test.sh`, `tests/publish-guard.test.sh`,
  `bin/docs-claims-check.sh` is empty, so rounds 1 to 3's findings on them carry forward
  unchanged and were not re-litigated.

## Findings

### Critical

None.

### Important

None. The single round-4 Important is closed by mechanism and independently re-measured above.

### Nitpicks

- `tests/install-ps1.test.sh:349-351`. The warm-up is the one mechanism in this file that can
  fail without saying so. Its exit status is discarded (`>/dev/null 2>&1`, no check) and it
  produces no assertion, while every other instrument here refuses loudly (`instrument broken`)
  or carries a canary (case 2 for case 1, case 6 for case 5, the four planted shapes for 9b).
  If it ever no-ops, case 9b reverts to the round-4 behaviour and the red it prints says
  `install.ps1 modified the filesystem itself; it is becoming a second implementation`, which is
  the misattribution the warm-up exists to prevent. One line fixes it:
  `if env -i HOME=... "$PWSH" -NoProfile -Command exit >/dev/null 2>&1; then ok "the sandbox
  HOME is warmed before any snapshot (case 9b does not depend on case order)"; else bad "the
  HOME warm-up did not run; a filesystem diff below would be pwsh's first launch, not
  install.ps1"; fi`. Note this moves the suite to 39 and the README to 1017.
- `tests/install-ps1.test.sh:350` vs `:313-316`. The warm-up spells `HOME="$TMP/home"` and
  `PATH="$TMP/empty-bin:/usr/bin:/bin"` a second time, duplicating `run_ps1`'s sandbox
  construction. An edit that repoints `run_ps1`'s HOME warms the wrong directory and silently
  restores the ordering dependency. Both nitpicks die in one move: warm up THROUGH the same
  helper, e.g. `warm="$(mkrepo repo-warm)"; run_ps1 "$warm" - "$TMP/cap-warm"` before the first
  snapshot. That also closes the residual in the comment's claim ("every directory at once,
  present and future"): the warm-up launches `-Command exit` while every case launches
  `-File install.ps1`, so a future pwsh that creates a directory only on script execution would
  not be warmed. Measured as NOT a live gap on 7.6.6 (the `-File` run after a `-Command` warm-up
  leaves HOME identical), which is why this is a nitpick and not a finding against the claim.
- `bin/docs-claims-check.sh:92-94` and `README.md:171-172`, SIBLING-INDUCED, flagged not
  re-scored. Both name ONE cause for an environment-dependent assertion count: "an optional tool
  is missing" / "A machine without PowerShell counts fewer". `tests/ledger-backup.test.sh` now
  emits six `SKIP - running as root, ...` lines (five predate this commit, case 30 adds the
  sixth), and they match `grep -cE '^SKIP'` exactly like the pwsh ones. A root run therefore
  prints `DRIFTED: assertions` plus a note whose stated cause is false, sending the reader after
  a tool that is not missing. Low probability here (no CI config in the tree, no documented
  container workflow), which is the only reason this is not Important. Fix: widen both sentences
  to the mechanism's actual scope, "a check that could not run here (an optional tool, or a case
  that cannot run as root)".
- `tests/install-ps1.test.sh:288`. Carried from round 4, not taken. "Links are recorded by
  TARGET, directories by name, files by hash" still omits the mode column that `:303` records.
  Add the word.
- `tests/install-ps1.test.sh:297`. Carried from round 3, not taken. `find -print` into
  `while IFS= read -r p` splits a path containing a newline. `-print0` plus `read -r -d ''`
  costs one line.
- `tests/install-ps1.test.sh:106-107`. Carried from round 3, not taken. When the `;;` count
  disagrees because an arm BODY contains `;;` inside a string, the message sends the reader
  after a missing arm that does not exist. Name both causes.
- `tests/install-ps1.test.sh:455`. Carried from round 4. `chmod 644 "$TMP/home/mode-probe"` runs
  on all four iterations though only one dirties it. Harmless and arguably the safer shape.

## Scores

correctness 2/2 - `install.ps1` has not moved since `cebc0a0`. The one behavioural change in
the harness does what its comment says, proven in both directions: the anti-port comparison now
passes as the first pwsh launch under a fresh HOME, and fails without the warm-up. The warm-up
writes only inside `$TMP` and only before the first snapshot, so it cannot be mistaken for
install work later. The prune it keeps is still necessary at HEAD (re-measured churn).

security 2/2 - unchanged and clean. Every element pasted into a bash command line goes through
`ConvertTo-BashSingleQuoted`; the harness stays sealed, and the warm-up keeps that seal exactly
(`env -i`, redirected HOME, replaced PATH, no repo, no network). It adds no new writable path
outside `$TMP`, and it cannot execute anything from the developer's PATH.

performance 2/2 - one extra pwsh startup, ~0.5s, and the full suite runs in 9.5s. The
alternative (enumerating pwsh's directories) would cost nothing at runtime and everything in
maintenance, so this is the right trade.

readability 2/2 - the comment names the old behaviour, the hazard, why enumeration was rejected
and why the prune survives the fix, which is the standard this file set for itself. The one
sentence that reaches slightly past its mechanism ("every directory at once, present and
future" over a `-Command exit` launch) is measured as true today and filed as a nitpick with
the fix that would make it structurally true.

testing 2/2 - restored from 1. The reason for the drop was a flagship guarantee whose green
depended on an undeclared case ORDER; that precondition is now both declared and ENFORCED, and I
verified the enforcement with a probe built from the suite's own functions plus a negative
control, rather than from the suite's normal ordering, which cannot distinguish the two. No
claim in this file is currently wider than its mechanism, and no case can go green for the wrong
reason that I could construct: the four canaries still prove 9b can fail, and the snapshot's
only blind spot (`.cache/powershell`) is written down.

conventions 2/2 - countable claims re-derived from the tree (1016 verified, 240 publish paths
intact), no em or en dashes, comments English, record regenerated at the new head rather than
re-dated (`lessons.md`, 2026-08-19), and the fix chose the class-eliminating shape over naming a
second directory, which is `CLAUDE.md`'s core principle and `lessons.md:28`.

total 12/12 (threshold >= 9, no zero) -> APPROVE.

## Ceiling

12/12, reached. Nothing about this change structurally caps a criterion. The
Windows-unverifiable half (PowerShell 5.1, UTF-16 `wsl -l -q`, real `wslpath`, native symlink
permission) stays a stated residual in the suite header and in INSTALL.md, which is how this
repo accepts an unrunnable platform, so it does not cap the score; it bounds what the suite
CLAIMS, and the claims are narrowed to match.

## What's good

- The fix removes the defect CLASS instead of the instance that was demonstrated. Round 3's
  suggested fix (exclude one more directory) and round 4's demonstration (six directories) both
  invited an enumeration; the warm-up makes the question "what does pwsh create" irrelevant to
  the guarantee, which is the shape `CLAUDE.md` asks for and the shape four earlier rounds on
  this file kept missing.
- The prune was NOT removed as redundant once the warm-up landed. It would have looked
  redundant; it is not, and the commit says which measurement proves it. I re-measured and the
  measurement holds.
- The comment names what the old shape depended on ("earlier cases happen to launch pwsh
  first"), so the next reader inherits the reasoning instead of a rule.
- Four rounds of countable-claim discipline held again: the README moved to 1016 in the same
  commit as the assertions that caused it, and `docs-claims-check` confirms it against the tree.

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
- 2026-09-17 (`2e7c740`, claude-opus-5[1m], effort high): round 4, a re-anchor after the
  ledger-backup work moved the tree. APPROVE WITH COMMENTS, 11/12. **Worse, -1**: testing
  2 -> 1; the other five held at 2. Two round-3 nitpicks were addressed in scope. The mode
  canary (n1) is fully closed and measured. The `.cache/powershell` prune (n2) is not: on a
  fresh HOME the snapshot still reports six entries pwsh created, because `~/.local/share/
  powershell` and the parent directories are the same host-runtime bookkeeping and are not
  excluded, so case 9b stays green only by case ORDER. The drop is a NEW measurement, not new
  damage: the hazard predates round 3, which recorded it as a nitpick and proposed a fix that
  was itself partial, and the builder applied that fix literally. Round 3's 12/12 was a
  half-point generous in hindsight on the same code path. No Critical, no security or
  correctness movement, `install.ps1` byte-identical since `cebc0a0`.
- 2026-09-17 (`994ede8`, claude-opus-5[1m], effort high): round 5. APPROVE, 12/12.
  **Improved, +1**: testing 1 -> 2; the other five held at 2. The round-4 Important is CLOSED.
  The one-time HOME warm-up landed and was verified against the hazard itself rather than
  against the suite's normal ordering: the suite's own functions were lifted into a probe that
  runs the anti-port comparison as the FIRST pwsh launch, which passes with the warm-up and
  fails without it on exactly the six entries round 4 recorded. The warm-up introduces nothing
  a later case can attribute to `install.ps1` (everything it writes predates the first
  snapshot), and the repo half of the comparison is clean too, which is the part a fresh
  `mkrepo` per case would have hidden. The prune's stated justification re-measured and still
  true. Seven nitpicks stand, four carried from earlier rounds, none weakening a claim; the new
  ones are a drift hazard (the warm-up duplicates `run_ps1`'s sandbox literals and asserts
  nothing) and one sibling-induced wording gap in the skip note, flagged not scored.
