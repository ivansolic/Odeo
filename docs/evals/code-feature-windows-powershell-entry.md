---
artifact: install.ps1 + tests/install-ps1.test.sh + tests/publish-guard.test.sh real-tree case + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 0125901
artifact_version: 6
date: 2026-09-18
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 12/12
---

## Artifact

Round 6, at `0125901`. Same artifact scope as rounds 1 to 5. This round exists for a gate
reason, not a code reason: the merge gate requires every record on the branch to cover the
commit being merged, and the sibling ledger-backup program moved again in `0125901`.

Exactly ONE thing inside this artifact's scope moved since `994ede8`, and it is a number:
`README.md:169`, `1016` -> `1027` assertions. `git diff --stat 994ede8..HEAD` over the scope
lists only `README.md`; `tests/install-ps1.test.sh` is byte-identical to `994ede8`, and
`install.ps1`, `install.sh`, `.gitattributes`, `INSTALL.md`, the language-allowlist suite, the
community-refresh suite, the publish-guard suite and `bin/docs-claims-check.sh` are all
byte-identical to `cebc0a0`, the last commit that touched them. So rounds 1 to 5's findings on
those files carry forward unchanged and were not re-litigated; what this round actually does is
verify the one moved number against the tree and re-measure the two nitpicks the sibling could
have moved. Everything else in `994ede8..0125901` (`bin/ledger-backup.sh`,
`tests/ledger-backup.test.sh`, `AGENTS.md`, `docs/plan-format.md`, `docs/system-map.md`,
`skills/retro/SKILL.md`) belongs to the ledger-backup program, scored separately in
`docs/evals/code-ledger-backup.md`. It is not re-scored here, but it was checked for collateral
damage to this artifact. No plan exists in `docs/plans/` for this branch, so there is no
contract to compare against.

## The two carried nitpicks, re-measured at this head

**n1, the warm-up still asserts nothing. Still true, still a nitpick.**
`tests/install-ps1.test.sh:350-351` is unchanged: `env -i HOME=... "$PWSH" -NoProfile -Command
exit >/dev/null 2>&1`, exit status discarded, no `ok`/`bad` line. The suite still reports 38
assertions, the same count as round 5, which is the arithmetic proof that nothing was added
here. The reason it stays a nitpick rather than an Important is unchanged and was re-derived,
not inherited: the warm-up is not a guard whose green is trusted, it is a precondition whose
failure mode is a LOUD red in case 9b, just a red with the wrong name on it. The risk is
misattribution, not a silent pass. The fix (one `ok`/`bad` pair, moving the suite to 39 and the
README to 1028) is still the right shape and still optional.

**n3, the root-run skip note. Assessment stands, and the specific worry this round raised did
not materialise.** The brief asked whether `0125901`'s new ledger-backup cases (34, 34b, 35, 36)
added skip lines that would worsen the accounting. They did not. Measured both ends rather than
reasoned about: `git show 994ede8:tests/ledger-backup.test.sh | grep -cE 'SKIP'` is 6, and the
same grep at HEAD is 6; `grep -nE 'id -u' tests/ledger-backup.test.sh` returns the same six
guards at `:404`, `:479`, `:498`, `:539`, `:564`, `:591`. The four new cases are not root-gated.
So the finding is exactly as large as round 5 recorded it, no larger: on a root run,
`bin/docs-claims-check.sh:86-90` prints a note whose single stated cause ("an optional tool is
missing") is false for six of the skips, and `README.md:171-172` says the same thing with the
same single cause. Still sibling-induced, still flagged and not scored here, still low
probability (no CI config in the tree, no documented container workflow).

## Verification (by measurement, on this machine)

- `bash tests/install-ps1.test.sh` -> `all 38 assertions passed`, pwsh 7.6.6, 9.6s wall. This
  is the collateral check the brief asked for: the sibling's changes did not break this suite.
- `bash tests/publish-guard.test.sh` -> `ALL PASS`, including `the real tree feeds 240 tracked
  paths into the guard`, `every tracked path in the real tree is classified public or internal`,
  and the planted-path canary. The count is still 240 because `0125901` added and removed no
  files, only content; had the sibling added an unclassified path, this case is the one that
  would have caught it, and it is green.
- `bash bin/docs-claims-check.sh --assertions` -> `ok: bin executables = 24`, `ok: test suites =
  33`, `ok: programs with their own suite = 24`, `ok: assertions = 1027`, `every countable claim
  matches the tree`, exit 0. The README's new number is verified against the TREE, not against
  the commit body. Note that no `note: N check(s) were SKIPPED here` line was printed, which is
  the independent confirmation that this run skipped nothing and 1027 is a full count rather
  than a low one that happened to match.
- Scope immobility: `git diff --stat 994ede8..HEAD` over the scope lists `README.md` only, and
  `git diff --stat cebc0a0..HEAD` over `install.ps1`, `install.sh`, `.gitattributes`,
  `INSTALL.md`, `tests/language-allowlist-agreement.test.sh`, `tests/community-refresh.test.sh`,
  `tests/publish-guard.test.sh`, `bin/docs-claims-check.sh` is empty.
- Root-skip census at both commits, as tabled above.
- Em/en dash scan over the in-scope diff (`994ede8..HEAD` on `README.md` and
  `tests/install-ps1.test.sh`): clean.
- Round 5's measurements (the order-independence probe with its negative control, and the
  prune-necessity probe) were NOT re-run. They are measurements of
  `tests/install-ps1.test.sh:339-351`, which is byte-identical to the commit they were taken
  at, so re-running them would be redundant work on unchanged text. Their results are carried
  forward and the immobility that licenses that is stated above.

## Findings

### Critical

None.

### Important

None. The round-4 Important was closed at `994ede8` by mechanism and independently re-measured
there; the code that closed it has not moved since.

### Nitpicks

All seven carry forward from round 5. None weakens a claim, none is new this round.

- `tests/install-ps1.test.sh:349-351`. The warm-up is the one mechanism in this file that can
  fail without saying so. Its exit status is discarded and it produces no assertion, while every
  other instrument here refuses loudly (`instrument broken`) or carries a canary (case 2 for
  case 1, case 6 for case 5, the four planted shapes for 9b). If it ever no-ops, case 9b reverts
  to the round-4 behaviour and the red it prints says `install.ps1 modified the filesystem
  itself; it is becoming a second implementation`, which is the misattribution the warm-up
  exists to prevent. One line fixes it: `if env -i HOME=... "$PWSH" -NoProfile -Command exit
  >/dev/null 2>&1; then ok "the sandbox HOME is warmed before any snapshot (case 9b does not
  depend on case order)"; else bad "the HOME warm-up did not run; a filesystem diff below would
  be pwsh's first launch, not install.ps1"; fi`. Note this moves the suite to 39 and the README
  to 1028.
- `tests/install-ps1.test.sh:350` vs `:313-316`. The warm-up spells `HOME="$TMP/home"` and
  `PATH="$TMP/empty-bin:/usr/bin:/bin"` a second time, duplicating `run_ps1`'s sandbox
  construction. An edit that repoints `run_ps1`'s HOME warms the wrong directory and silently
  restores the ordering dependency. Both nitpicks die in one move: warm up THROUGH the same
  helper, e.g. `warm="$(mkrepo repo-warm)"; run_ps1 "$warm" - "$TMP/cap-warm"` before the first
  snapshot. That also closes the residual in the comment's claim ("every directory at once,
  present and future"): the warm-up launches `-Command exit` while every case launches
  `-File install.ps1`, so a future pwsh that creates a directory only on script execution would
  not be warmed. Measured at round 5 as NOT a live gap on 7.6.6, which is why this is a nitpick
  and not a finding against the claim.
- `bin/docs-claims-check.sh:86-90` and `README.md:171-172`, SIBLING-INDUCED, flagged not
  re-scored. Both name ONE cause for an environment-dependent assertion count: "an optional tool
  is missing" / "A machine without PowerShell counts fewer". `tests/ledger-backup.test.sh` emits
  six `SKIP - running as root, ...` lines (six at `994ede8`, six at HEAD, re-counted this round),
  and they match `grep -cE '^SKIP'` exactly like the pwsh ones. A root run therefore prints
  `DRIFTED: assertions` plus a note whose stated cause is false, sending the reader after a tool
  that is not missing. Fix: widen both sentences to the mechanism's actual scope, "a check that
  could not run here (an optional tool, or a case that cannot run as root)".
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

correctness 2/2 - `install.ps1` has not moved since `cebc0a0` and the harness has not moved
since `994ede8`, where the one behavioural change was proven in both directions (anti-port
comparison passes as the first pwsh launch under a fresh HOME, fails without the warm-up on
exactly the six entries round 4 recorded). The only correctness question this round could raise
is whether the sibling broke something, and the two suites that would notice are green.

security 2/2 - unchanged and clean. Every element pasted into a bash command line goes through
`ConvertTo-BashSingleQuoted`; the harness stays sealed (`env -i`, redirected HOME, replaced
PATH, no repo, no network), and nothing in `994ede8..0125901` touches any of it. The publish
path is still whole: all 240 tracked paths classify, so the sibling's new content did not open
a leak through this artifact's guard.

performance 2/2 - full suite 9.6s, unchanged. No new work was added anywhere in scope.

readability 2/2 - nothing in scope was reworded. The one sentence that reaches slightly past its
mechanism ("every directory at once, present and future" over a `-Command exit` launch) remains
measured as true today and filed as a nitpick with the fix that would make it structurally true.

testing 2/2 - held. The flagship guarantee (case 9b) no longer depends on case ORDER, the
precondition is declared and enforced, and the four canaries still prove 9b can fail. This round
adds one piece of evidence the earlier rounds could not have: the suite ran green against a tree
whose sibling program changed substantially, which is the collateral question the artifact was
re-reviewed for. The suite's only blind spot (`.cache/powershell`) is still written down.

conventions 2/2 - the countable claim moved in the same commit as the assertions that caused it
and was re-derived from the tree (1027 verified, exit 0, no skips), no em or en dashes, comments
English, output English per `CLAUDE.md:21`, and the record was REGENERATED at the new head
rather than re-dated, which is `lessons.md:25` exactly: a sibling moved the tree, so the
reviewer re-runs instead of the human editing a date.

total 12/12 (threshold >= 9, no zero) -> APPROVE.

## Ceiling

12/12, reached. Nothing about this change structurally caps a criterion. The
Windows-unverifiable half (PowerShell 5.1, UTF-16 `wsl -l -q`, real `wslpath`, native symlink
permission) stays a stated residual in the suite header and in INSTALL.md, which is how this
repo accepts an unrunnable platform, so it does not cap the score; it bounds what the suite
CLAIMS, and the claims are narrowed to match.

## What's good

- The countable-claim discipline survived a sixth commit and a sibling program's churn. `1016`
  -> `1027` landed in the same commit as the assertions that caused it, and `docs-claims-check`
  confirms it against the tree with zero skips, so the number is a full count and not a
  coincidence on a partial run.
- The artifact is genuinely inert under the sibling's changes, and that is checkable rather than
  asserted: two `git diff --stat` runs reduce this round's real work to one number and two
  re-counts, which is what a well-separated program should cost when its neighbour moves.
- The real-tree publish-guard case keeps earning its place. It is the one assertion in this
  artifact that a sibling CAN break by adding a file, and it is the one that proves the sibling
  did not.

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
- 2026-09-18 (`0125901`, claude-opus-5[1m], effort high): round 6, a gate re-anchor after the
  ledger-backup program moved again. APPROVE, 12/12. **Same, 0**: all six criteria held at 2.
  Nothing regressed. One in-scope change, `README.md` `1016` -> `1027`, verified against the
  tree by `docs-claims-check --assertions` (exit 0, and no `note:` line, so the count was full
  rather than skipped-low). Collateral checks green: `install-ps1.test.sh` 38/38 and
  `publish-guard.test.sh` ALL PASS with the real tree still at 240 classified paths. Both
  re-checked nitpicks stand unchanged: the warm-up still asserts nothing (a misattribution risk,
  not a silent-pass risk, so still a nitpick), and the root-skip accounting gap did NOT grow,
  `tests/ledger-backup.test.sh` carries six `id -u` guards at `994ede8` and six at HEAD, so the
  four new cases (34, 34b, 35, 36) are not root-gated. Round 5's warm-up probes were not re-run
  because the code they measure is byte-identical; the immobility is recorded instead.
