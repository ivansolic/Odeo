---
artifact: code
type: code
branch: main
scope: dogfood fix batch, commits 8142845..21885d5 (secret-scan toplevel anchor + excludes, merge-gate strict frontmatter/vocabulary, init-project EOF-safe reads, settings allowlist narrowing)
artifact_version: 2
date: 2026-07-13
scorer: code-reviewer
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 8/12
verdict: APPROVE WITH COMMENTS
---

## Verdict
APPROVE WITH COMMENTS. Every finding from v1 is verified fixed, with a
regression test pinning each one. All four suites pass (merge-gate 14/14,
secret-scan 16/16, privacy-scan 11/11, boundary-check 4/4); installed
~/bin copies are in sync with the repo. Regression vs previous record:
better (8/12 REQUEST CHANGES -> 12/12), correctness 0->2, security 1->2,
testing 1->2. Three residual nitpicks remain, none blocking.

## Fix verification (v1 findings, each independently probed)
- Critical, secret-scan cwd-relative pathspecs: FIXED. bin/secret-scan.sh:27
  now does `cd "$(git rev-parse --show-toplevel)"` after the work-tree check.
  Probed from a deep subdir (`packages/api/src/`) with a staged ghp_ token in a
  sibling tree (`other/leak.ts`): BLOCK, rc=1. Regression test present
  (subdir invocation, tests/secret-scan.test.sh).
- Important, merge-gate prefix matching: FIXED. bin/merge-gate.sh:71 is an
  exact case allowlist (`APPROVE|"APPROVE WITH COMMENTS"|PASS`).
  APPROVE-PENDING-FIXES and PASSABLE BUT BROKEN both refused (tests 6f).
- Important, awk not anchored to line 1: FIXED. bin/merge-gate.sh:62 exits
  unless NR==1 is `---`; setext-heading body record refused (test 6g),
  deny-by-default on empty verdict retained.
- Important, init-project `read` under set -e: FIXED. Both prompts
  (bin/init-project.sh:77 and :99) carry `|| _var=""` guards.
- Important, `git branch:*` allowlist too broad: FIXED. Narrowed to
  `git branch`, `git branch --list:*`, `git branch -vv`. Probed the residual
  vector: `git branch --list -D victim` is rejected by git itself (rc=129,
  incompatible options, branch intact), so the --list wildcard is safe.
- Nitpick, xargs trimmer: FIXED, pure-bash trim (merge-gate.sh:68-69).
- Nitpick, JS-centric excludes: FIXED for suffix conventions
  (`**/*_spec.*`, `**/*_test.*`; auth_spec.rb allowed, test pins it).
- Nitpick, broad `**/fixtures/**` hole: FIXED, narrowed to `**/__fixtures__/**`.
- Nitpick, eval-framework example verdict comment: FIXED, comment moved to
  its own line (docs/eval-framework.md:61).

## Nitpicks (optional, residual)
- bin/merge-gate.sh:66, the `%%#*` comment stripping means
  `verdict: APPROVE  # sneaky comment` passes (probed), while the reviewer
  contract demands a value-only line. Not a gaming vector (an editor could
  write the clean value anyway) but it contradicts the stated contract and is
  untested. Either drop the stripping (deny-by-default) or add a test pinning
  the intended leniency.
- bin/secret-scan.sh:58-64, Python prefix convention `test_*.py` still trips
  the assignment heuristic at repo root (probed: rc=1 false positive); only
  suffix conventions are excluded. Add `:(exclude,glob)**/test_*.*` if the
  false-positive pain shows up on Python stacks.
- bin/merge-gate.sh:41,84, record grep and freshness pathspecs are
  cwd-relative; invoked from a repo subdirectory the gate fails CLOSED
  (probed: refuses with "no review record", misleading but safe). For
  consistency with the secret-scan fix, cd to toplevel here too.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## History
- v1 (2026-07-13, commits 8142845..005676a): REQUEST CHANGES, 8/12. One
  Critical (secret-scan scanned only the invoker's subtree; a subdir
  invocation missed root-level staged secrets) and four Important findings
  (merge-gate APPROVE*/PASS* prefix matching, unanchored frontmatter parse,
  init-project EOF abort under set -e, over-broad `git branch:*` allowlist).
- v2 (2026-07-13, commit 21885d5): all v1 findings fixed test-first
  (suites grew 11->14 and 14->16 assertions), each fix independently
  re-probed in throwaway repos. Regression: better.

## What's good
- Every fix landed with a regression test that pins the exact failure mode
  from the review, not a proxy. The setext-heading and prefix-verdict tests
  in particular encode the gate's threat model.
- The toplevel `cd` in secret-scan fixes the Critical and anchors the exclude
  globs in one move, with a comment explaining why, exactly the right shape.
- Fail-closed behavior is consistent everywhere it matters: empty verdict,
  malformed frontmatter, and subdir merge-gate invocation all refuse.
- The `--list` narrowing in the allowlist survives adversarial probing; git's
  own option incompatibility does the enforcement.
