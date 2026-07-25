---
artifact: enforced-publish-guard
type: code
branch: feature/publish-guard
artifact_version: 2
date: 2026-07-25
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 11/12
verdict: APPROVE
previous_total: 11/12
---

Re-verification of the enforced publish guard at HEAD 9027020 (nitpick commit) +
d9b5cc4 (docs), reviewed as `git diff 524672f..HEAD` against the approved plan
docs/plans/2026-07-24-enforced-publish-guard.md. Round 1 (v1, 524672f) was
APPROVE WITH COMMENTS at 11/12 with four optional nitpicks and no
Critical/Important; that 11/12 is both the baseline and the ceiling for this
change. This round re-verifies HEAD after all four nitpicks were addressed.

## Verdict
APPROVE. All four Round-1 nitpicks are resolved and the two fixes that changed
behavior (Nit-1 trim, Nit-3 PIPESTATUS) each close a latent fail-OPEN and move
the system strictly safer. No new Critical/Important/nitpick was introduced by
the fixes. The fail-closed guarantee still holds end to end. Merge.

## Regression note (v1 11/12 -> v2 11/12: SAME, strictly safer within it)
Total is unchanged because the prior 11/12 was the stated ceiling. Two of the six
dimensions moved internally in the safer direction without changing their 2/2:
- correctness/security: Nit-1 (a whitespace-padded denylist entry silently going
  inert -> would ship internal paths as "clean") and Nit-3 (per-assignment `$?`
  resetting PIPESTATUS so an ls-tree enumeration failure fell through as a clean
  push) were both LATENT FAIL-OPENs. Both are now closed and locked by tests. The
  Round-1 2/2 stands (they were latent, not live: committed lists are clean and
  ls-tree does not fail in normal operation), but the margin is now real, not
  assumed.
- conventions stays at 1/2 (see below): the stale-plan nit that was one of its two
  causes is fixed, but the loader duplication that was the other cause is now
  deeper (identical 5-line trim/parse block in both scripts), so the dimension does
  not clear to 2/2.

## What was re-verified (empirically, on the real tree, bash 3.2.57 macOS)
- Full suite GREEN: 17/17 test files pass (all `tests/*.test.sh`), including the
  two new regression cases in publish-guard.test.sh (14 padded-entry, 15
  flag-after-dir). skills-lint clean ("all invariants hold", exit 0).
- The two new tests are NON-VACUOUS: replayed against v1 (git show 524672f:bin/
  publish-guard.sh) both exit 0 (pass-as-clean = the bug); against HEAD both exit 1
  (blocked). Test 15 also asserts the unclassified path is NAMED, proving
  allowlist mode actually engaged, not just that some nonzero code was returned.
- Fail-closed dry-run holds at HEAD: guard on the worktree tree exit 1 (24 internal
  paths BLOCKed); snapshot build exit 3 (advisory privacy only:
  project-templates/CLAUDE.md, global/CLAUDE.md; zero deny/unclassified); guard
  --require-allowlist on the built snapshot exit 3 with zero deny/unclassified and
  every internal dir (docs/plans, docs/evals, .claude/, ...) stripped.

### Nit-by-nit verification
- Nit-1 (trim, bin/publish-guard.sh:71-73 load_list + bin/publish-snapshot.sh:40-42
  strip loop): the two-step parameter-expansion trim
  `${line#"${line%%[![:space:]]*}"}` / `${line%"${line##*[![:space:]]}"}` is
  bash-3.2-safe (ran green on 3.2.57), runs BEFORE the `''|'#'*` skip so a padded
  comment/blank still skips and a padded real entry is trimmed THEN classified by
  the `*/` prefix-vs-exact split. Verified: padded `   docs/plans/   ` now matches
  (exit 1) where it previously went inert; normal entries, comment/blank skipping,
  and the prefix/exact split are unaffected (full suite green).
- Nit-2 (flag in any position, bin/publish-guard.sh:39-45): a `for a in "$@"` loop
  sets REQUIRE_ALLOWLIST and a single POSITIONAL/HAVE_POS. Verified under set -u
  with zero args (loop over empty `"$@"` is safe): flag-first, flag-after-dir,
  no-arg stdin, `-` stdin, and flag-only+stdin all resolve correctly; multiple
  positionals do not crash (last one wins, silently). Residual: multiple
  positionals silently keep the last rather than erroring, no worse than v1 and not
  a fail-open (it only ever scans a dir the caller explicitly named); this keeps
  the dimension shy of perfect but is not a finding.
- Nit-3 (PIPESTATUS, bin/install-git-guards.sh:64): the pipeline status is captured
  once into `pst=( "${PIPESTATUS[@]}" )` immediately after the pipeline, then
  pst[0]/pst[1] are read. Simulated both refuse paths: (A) ls-tree ok + guard hit
  -> lst=0 gst=1 -> "internal path" refuse, exit 1; (B) bogus sha -> lst=128 gst=0
  -> "enumeration" refuse, exit 1 (this is exactly the case v1 fell open on). Both
  fail closed with the correct distinct message. set -u safe.
- Nit-4 (plan text only, docs/plans/...): the plan's Task 5 step 1 now shows
  `git ls-tree -r -z ... | publish-guard.sh -` with a note that `-z` is required.
  Not shipped code; resolves the stale-copy fail-open in the doc.

## Nitpicks (optional, carried)
- (conventions) The CR-strip + trim + comment/blank + prefix/exact classification is
  now a verbatim 5-line block duplicated in bin/publish-guard.sh:69-78 and
  bin/publish-snapshot.sh:38-47. Consistent and safe, but it is the single-source
  list-parse logic living in two places; a shared helper (sourced snippet or a
  `--print-normalized-list` mode on the guard) would remove the drift risk. This is
  the sole reason conventions is not 2/2.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 1/2  -> total 11/12  (threshold: >=9, no zero)

Round 1 -> final: 11/12 -> 11/12 (SAME). Ceiling: 11/12 was the stated ceiling and
still is; conventions is held at 1 solely by the two-loader duplication (now
deeper after the fix applied the same idiom to both). Everything else is a genuine
2/2, and the two behavior-changing fixes each removed a latent fail-open, so the
unchanged total sits on firmer ground than in v1.

## History
2026-07-25 v1 (524672f): initial adversarial review, APPROVE WITH COMMENTS, 11/12,
four optional nitpicks (Nit-1 latent fail-open on padded list entries, Nit-2
flag-first-only parsing, Nit-3 PIPESTATUS reset masking enumeration failure, Nit-4
stale plan command).
2026-07-25 v2 (9027020 + d9b5cc4): re-verification after all four nitpicks fixed.
APPROVE, 11/12 (SAME, ceiling). Nit-1/2/3/4 all confirmed resolved and, for the two
behavior-changing ones, locked by non-vacuous regression tests (cases 14, 15).
No new issue introduced. Conventions stays 1/2 on the now-deeper loader
duplication.
