---
artifact: remove-install-sh
type: code
branch: chore/remove-install-sh
reviewed_commit: d1909a8
date: 2026-09-24
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 10/12
verdict: APPROVE
---

## Scope reviewed

`main..d1909a8`, which is two commits:
- `4bbf31c chore(plugin): remove install.sh, install.ps1 and the dogfood symlinks`. This is
  the round-1 scope: 16 files, with the full diff read.
- `d1909a8 fix(docs): drop the removed install.ps1 from two coverage statements`. This is
  round 2: 2 files, with the full diff `4bbf31c..d1909a8` read.

## Round-2 verification

- **bin/docs-claims-check.sh:121-137.** The printed skip note (`skip_reason` and the two
  `echo` lines) now names only causes that actually occur: the case cannot run as this user,
  or the shell refuses what it needs. The comment names the same two measured causes. It
  keeps the old pwsh wording only as history ("It once named only a missing optional
  tool..."), so the rationale reads coherently again. `git grep -i 'optional tool'` matches
  only that history line.
- **tests/language-allowlist-agreement.test.sh:12-14, :29.** The header now names
  init-project.sh and .claude-plugin/plugin.json as the two files checked textually. The
  maintenance note now says "all six files". Both match what the test asserts: four
  behavioral scripts, the init-project.sh case arm, and the plugin.json options and default.
- **Re-ran the two affected suites.** `tests/docs-claims-check.test.sh` has 21 ok and 0 FAIL,
  including the skip-note cases. `tests/language-allowlist-agreement.test.sh` has 42 ok and
  0 FAIL.
- **Other checks.** `bin/docs-claims-check.sh` still matches the tree: 26 bin, 37 suites,
  26 programs. `bin/skills-lint.sh` is clean. The fix commit changes only comments and
  message text, so the README's assertion count (1228) is unaffected.

## Round-1 verification (4bbf31c, still valid)

- **Test suites.** 36 of 37 suites are green with `</dev/null`. `tests/install-git-guards.test.sh`
  is flaky: a different assertion fails on each run. It fails the same way on `main`, and this
  branch does not touch it. It is tracked as a separate item, outside this branch.
- **Publish snapshot.** `bin/publish-snapshot.sh <tmp>` exits 3, which means advisory privacy
  findings only. The snapshot contains no install.sh or install.ps1. Publish-guard case 16
  (every path in the real tree is classified) is green.
- **Whole-tree grep.** I grepped for install.sh, install.ps1, ~/.claude-templates, ~/bin,
  odeo-docs, .claude/agents and .claude/skills. Nothing left points at a deleted file in a
  misleading or mechanism-breaking way. The legacy and historical references were kept on
  purpose.
- **Legacy exit path.** It is intact: `bin/odeo-migrate-legacy.sh`, the SessionStart notice in
  `hooks/odeo-context.sh`, INSTALL.md:137 and README.md:75.
- **Allowlist coverage.** It shrank only by the install.ps1 ValidateSet case. Six copies
  remain, and all six are asserted.

## Findings

None open.

## History

- v1 (4bbf31c): APPROVE WITH COMMENTS, 10/12 (readability 1, conventions 1). It had two
  Importants:
  - bin/docs-claims-check.sh:134-135: the skip note still named a missing optional tool
    (pwsh), a cause that can no longer occur.
  - tests/language-allowlist-agreement.test.sh:12-14, :29: the header claimed install.ps1
    was still checked, and said "five files".
- v2 (d1909a8): both are fixed as suggested, and the two affected suites are green.
  APPROVE, 12/12. Trajectory: 10/12 -> 12/12 (better).
