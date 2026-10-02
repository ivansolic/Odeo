---
artifact: fix-assertion-count-honesty
type: code
branch: fix/assertion-count-honesty
reviewed_commit: 9be9472
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 1, testing: 1, conventions: 2 }
total: 9/12
verdict: REQUEST CHANGES
---

## Scope reviewed

I reviewed `git diff main...HEAD` (main c04c60b, HEAD 9be9472), which has two commits: `4c96dcb`
(docs-claims-check counts SKIP lines) and `9be9472` (the suites declare their counts, README
1408). The changed files are `scripts/docs-claims-check.sh`, `tests/docs-claims-check.test.sh`,
`tests/language-guard.test.sh`, `tests/ledger-backup.test.sh` and `README.md`. This branch has
no plan file. The contract is the goal stated in the dispatch: the README assertion count is
one number on every machine.

What I checked myself:
- I read the run branch of each of the seven ledger-backup SKIP counts. Cases 24, 25c and 26
  make 2 assertions each. Cases 28, 29 and 30 make 3 each. Case 40 makes 2. All seven are
  correct.
- The language-guard PER_LOCALE value of 8 is correct: there are 4 `for l in $UTF8_LOCALES`
  loops, each calls `assert_locale` once, and each call makes 2 assertions.
- I ran a mutation of the stdin redirect. With `</dev/null` removed, the case-8 fixture goes red
  (the suite fails and the run exits 1). As shipped it is green. The guard is real.
- I ran the SKIP regex under /bin/bash 3.2.57. `SKIP 2 - r` matches and captures 2.
  `SKIP 2 -r`, `SKIP - r` and `SKIPPED 2 - r` are rejected. `SKIP 0 - r` is accepted.
  `SKIP 08 - r` prints an arithmetic error and drops the 8 without failing.
- I fed the shipped check a fixture suite that prints a lowercase `skip - ...` line. It reports
  DRIFTED with the "Fix the NUMBER in the document" footer, against a README that is correct.

## Findings

### Important
1. **Four root-dependent assertions still skip without a count, so the README's own example is
   false.** README.md:244 says that a case a machine cannot run "as root" prints
   `SKIP <n> - <reason>`. Three such branches do not:
   - tests/prose-language-check.test.sh:219 prints a lowercase `skip:` line (1 assertion).
   - tests/token-report.test.sh:107 prints a lowercase `skip -` line (1 assertion).
   - tests/odeo-context.test.sh:311 prints nothing at all (2 assertions).

   The check matches `^SKIP` case-sensitively, so none of them is counted or refused. As root
   the run measures 1404 against a correct README, and it tells the reader to edit the README.
   That is the harm the old UNVERIFIED path existed to prevent. Fix: change each to
   `SKIP <n> - ...` (n = 1, 1 and 2), turning the odeo-context guard into an if/else. Then
   close the class at the check: use `grep -iE '^skip'` in scripts/docs-claims-check.sh:126,
   so that a lowercase skip line is refused as uncounted instead of disappearing.
2. **The program's documented contract still describes the removed behaviour.**
   - The header at scripts/docs-claims-check.sh:18-19 still says exit 0 may carry UNVERIFIED
     claims because "this machine could not run the whole suite".
   - The `claim()` comment at lines 45-54 justifies the fourth argument by the more-or-less
     skipped machine.

   Now UNVERIFIED arises only with a failed suite, and that run exits 1. Rewrite both to the
   failed-suite rationale.
3. **The uncounted-SKIP failure prints a false cause.** scripts/docs-claims-check.sh:123-124
   adds to `suite_fail`, so the footer (line 160) and `count_reason` (line 141) both say
   "suite(s) exited non-zero" about a suite that exited 0. Fix: keep a separate
   `skip_fail` counter with its own footer line, for example "a suite printed an uncounted
   SKIP; fix the suite".
4. **CI should get the `--assertions` step in this branch.** Right now the claim "the same on
   every machine" has been measured on one machine. The old README numbers also do not
   reconcile with locales alone. If Linux lacks both locales and runs case 40, 1399 on macOS
   predicts 1385 on Linux, not the 1383 that was recorded. That leaves an unexplained 2-assertion
   Linux difference, unless the two figures came from different commits. Fix: add a step that
   runs `bash scripts/docs-claims-check.sh --assertions` to .github/workflows/checks.yml (it
   could replace the suites loop, since it fails on any failed suite). Raise `timeout-minutes`
   to cover a second full run. This is a CI change, so the decision is Ivan's, but without it
   the branch's headline claim stays unverified.

### Nitpicks
- scripts/docs-claims-check.sh:119 accepts `SKIP 0`, and `SKIP 08` makes an arithmetic error
  that silently drops the count. Use `^SKIP\ ([1-9][0-9]*)\ -\ `.
- tests/language-guard.test.sh:258: the tripwire counts only the exact spelling
  `for l in $UTF8_LOCALES; do` at column 0. It does not check that each loop calls
  `assert_locale` exactly once. Count `assert_locale "` calls inside those loops instead, or
  state the limit in the comment.
- tests/docs-claims-check.test.sh:119-125: the case-6 header still speaks of the unverified
  outcome in the present tense. Put it in the past tense.
- On its own, commit 4c96dcb turns `--assertions` red on this Mac (case 40's bare SKIP) until
  9be9472. That does not matter for an ff merge, but it is not bisect-clean.

## Spec change versus weakened test (cases 4, 5, 7)

This is a spec change, not a weakened test. The removed assertions pinned behaviour the new
contract deliberately reverses: a mismatch excused as UNVERIFIED at exit 0, and the second
summary form. The replacements are stricter in every direction. They pin the exact total
(4 = 2 ok + 2 skipped). Both one-below and one-above are now required to fail as DRIFTED. They
pin the suite's quoted reason, and they require an uncounted SKIP to fail and blame the suite.
The only thing dropped without a replacement is the "measurable claim stays fatal while another
is unverified" scope check. It is now unobservable, because UNVERIFIED only coexists with a
failed suite, which exits 1 anyway.

## Answers to the points raised

- Hand-written counts can drift unseen only on machines that run the case. The count is never
  read there, so the drift is harmless until a machine skips the case, and that machine shows
  DRIFTED. This holds, with one caveat: no machine in CI skips any ledger-backup case, so a
  wrong n would surface only as root. Nothing protects it except review.
- No suite needs stdin. I agree with the author's grep, and the mutation confirms the
  redirect is load-bearing.
- `[[ =~ ]]` and BASH_REMATCH work under bash 3.2. The escaped-space unquoted regex is correct
  there.
- The regex is anchored correctly at the start and requires `<n> - `. The gaps are the
  lowercase variant (Important 1) and 0 or leading-zero counts (nitpick).

## Scores
correctness 1/2 · security 2/2 · performance 2/2 · readability 1/2 · testing 1/2 · conventions 2/2 -> total 9/12 (threshold: >=9, no zero)

## Ceiling
12/12 is reachable. Fixing Important 1 to 3 restores correctness and readability. Testing
reaches 2 with the CI step (or with an explicit human decision to defer it, recorded in the
body).

## Verdict
REQUEST CHANGES. The total clears the threshold, but the branch's stated invariant is not
held for root, which is a case the README names. The fix is a few lines.
