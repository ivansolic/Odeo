---
artifact: code
type: code
branch: main
scope: dogfood fix batch, commits 8142845..005676a (merge-gate frontmatter verdict, secret-scan test excludes, init-project identity check + settings allowlist)
artifact_version: 1
date: 2026-07-13
scorer: code-reviewer
scores: { correctness: 0, security: 1, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 8/12
verdict: REQUEST CHANGES
---

## Verdict
REQUEST CHANGES. One Critical (secret-scan silently scans nothing outside the
current directory when invoked from a repo subdirectory), plus four Important
findings on gate strictness and the permission allowlist. All test suites pass
(merge-gate 11/11, secret-scan 14/14, privacy-scan 11/11, boundary-check 4/4);
installed copies in ~/bin are in sync with the repo.

## Critical (must fix before merge)
- bin/secret-scan.sh:36, the new `-- . "$@"` pathspec is cwd-relative, so the
  ENTIRE content scan (including the "global" private-key and token rules) is
  limited to the invoker's subdirectory. Verified: from `sub/` in a repo with a
  staged `ghp_...` token and a password assignment at the root, the scan reports
  "staged changes clean" (rc=0). The pre-commit hook runs at toplevel, but any
  /commit-push or manual/agent invocation from a subdir bypasses the whole gate,
  silently. Fix: after the work-tree check, `cd "$(git rev-parse --show-toplevel)"`;
  this also anchors the exclude globs consistently.

## Important (should fix)
- bin/merge-gate.sh:65, `APPROVE*|PASS*` is prefix matching, not an allowlist.
  Verified: `verdict: APPROVE-PENDING-FIXES` and `verdict: PASSABLE BUT BROKEN`
  both pass the gate. The vocabulary is exactly four values; match exactly:
  `case "$verdict" in APPROVE|'APPROVE WITH COMMENTS'|PASS)`.
- bin/merge-gate.sh:61, the awk does not anchor the frontmatter opener to line 1.
  Verified: a record with NO frontmatter, a setext heading (`Title` + `---`),
  and `verdict: APPROVE` / `branch: ...` in the body passes. Given the gate
  exists because an agent once gamed it, parse strictly:
  `NR==1 && /^---[[:space:]]*$/{n=1; next}` and stop at the closing delimiter.
- bin/init-project.sh:99, `read -r -p` under `set -euo pipefail`: EOF (Ctrl-D)
  at the prompt returns nonzero and aborts mid-scaffold, leaving a half-created
  project dir that then blocks re-run ("already exists"). Fix:
  `read -r -p "..." _ans_email || _ans_email=""`. Same latent bug preexists at
  line 77 (`read ... _ans`), fix both.
- project-templates/claude-settings.json:19, `Bash(git branch:*)` is not
  read-only despite the stated intent: it matches `git branch -D x` and
  `git branch -f main <sha>` (moves main without a checkout). Replace with
  `Bash(git branch)`, `Bash(git branch --list:*)`, `Bash(git branch -vv)`.

## Nitpicks (optional)
- bin/merge-gate.sh:63, xargs-as-trimmer: a verdict containing an unmatched
  quote (e.g. `DON'T APPROVE`) makes xargs fail, so the refusal misreports
  "no 'verdict:' field". Fail-closed but misleading; trim in awk (`{$1=$1}`)
  or pure bash instead.
- bin/secret-scan.sh:54-57, excludes are JS-centric: `auth_spec.rb`,
  `foo_test.go`, `test_foo.py` still trip the assignment heuristic (verified
  `_spec.rb` blocks), so the false-positive pain returns on non-JS stacks.
- bin/secret-scan.sh:57, `**/fixtures/**` is the broadest hole: verified
  `src/fixtures/prod-config.yaml` with `password: "..."` passes. Consider
  narrowing to fixtures under test dirs.
- docs/eval-framework.md:60, the framework's own example shows
  `verdict: PASS   # comment`, while the reviewer contract now demands one
  clean value-only line. The gate strips `#` so it works, but align the example.

## Testing gaps
- No test invokes secret-scan.sh from a repo subdirectory (would have caught
  the Critical).
- No merge-gate test for a non-vocabulary verdict (`APPROVE-...`), a malformed
  frontmatter (setext heading), or a `verdict: X  # comment` line (the comment
  stripping at merge-gate.sh:62 is untested).

## What's good
- The frontmatter-only parse genuinely fixes the incident class: body prose
  ("was REQUEST CHANGES, now resolved") can no longer flip the gate, and test
  6b pins that behavior. Deny-by-default on missing, indented, or miscapitalized
  verdict fields all verified fail-closed.
- Comment stripping, CRLF tolerance, `verdict:APPROVE` (no space), and
  first-verdict-wins all behave correctly (probed).
- secret-scan keeps the hard format rules global; a real sk_live_ key or private
  key in a .spec file still blocks, and the tests pin exactly that boundary.
- Tests are hermetic (mktemp repos), behavior-focused, and fast; the
  `record_no_verdict` helper makes the deny-by-default case explicit.
- Everything is bash-3.2 clean (no bashisms beyond `[[ =~ ]]` with unquoted
  pattern, arrays are always non-empty under `set -u`).
