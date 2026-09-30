---
artifact: ci-setup
type: code
branch: chore/ci-setup
reviewed_commit: d9383ec
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 12/12
verdict: APPROVE
---

# Code review: CI checks workflow (round 2)

## Scope reviewed

Round 2 re-anchors on `d9383ec`. It reads the fix delta
`git diff 08e734c..d9383ec -- .github/workflows/checks.yml` (+6/-3) on top of the full
round-1 review of `git diff main...08e734c` (`.github/workflows/checks.yml`,
`tests/config-dir.test.sh`, `tests/set-project-language.test.sh`). The only other path
that moved since round 1 is this record (`66f6638`). No plan document; judged against the
stated intent and the human decision of 2026-09-30 (Linux only on the private copy, both
OSes on the public repo).

## Verdict

APPROVE. The round-1 nitpicks were either applied or declined with a reason, and the new
matrix expression is correct as written. The public half of it is judged by reading only
and has not run yet (see below).

## Round-1 items, checked at d9383ec

- **Private macOS cost (open decision): applied as the human decided.**
  `checks.yml:22` is now
  `os: ${{ fromJSON(github.event.repository.private && '["ubuntu-latest"]' || '["ubuntu-latest","macos-latest"]') }}`.
  Dropping my `backup-main` exception is right: every backup lands on `backup-main`, so
  keeping macOS there would have kept most of the cost the decision was meant to remove.
- **timeout 20 -> 10: applied** (`checks.yml:24`). The Linux job took 1m07s at d9383ec.
- **`stat` in the header comment: applied** (`checks.yml:4`), plus a comment
  (`checks.yml:5-7`) explaining the private/public split.
- **cancel-in-progress on main: kept, human decision.** The reason ("a newer run tests
  newer code") holds, so this is not a finding.
- **Fork-only `if:` for pull_request: not applied, reason accepted.** Merges are local and
  the public repo takes only snapshot pushes, so same-repo PRs, the only case that
  duplicates, do not occur.
- **Pin maintenance: unchanged, still bump by hand** (no Dependabot on the public repo).

## The matrix expression, judged by reading

- **Context availability:** `jobs.<id>.strategy` may use the `github` context, and the
  private run proves the expression is evaluated there: run 36702062476
  (headSha `d9383ec6...`) produced exactly one job, `checks (ubuntu-latest)`, success, with
  39 `PASS tests/` lines (all 39 suites).
- **Payload field:** `repository.private` is part of the repository object in both the
  `push` and the `pull_request` webhook payloads. For a fork PR on the public repo,
  `github.event.repository` is the BASE repository, which is public, so fork PRs get both
  OSes. This is from the documented payload shape, not observed for `pull_request` here.
- **Ternary idiom:** `cond && A || B` goes wrong only when A is falsy. A is a non-empty
  string, so it is always truthy. Both literals are valid JSON arrays.
- **Failure direction:** if the field were ever missing or null, the condition is falsy and
  the job gets both OSes: more cost, never less coverage. That is the safe side.
- **Target visibility:** `gh api repos/ivansolic/Odeo --jq .private` returns `false`, and
  Odeo-private returns `true`, so the public repo takes the both-OS branch.
- **Unobserved, plainly:** the `false` branch (Linux plus macOS on the public repo) has
  never run. It will be observed only on the next snapshot publish. The macOS job itself
  was green on the full tree at 08e734c (run 36689920329), and in round 1 the whole suite
  was green on a locally built stripped snapshot on macOS, so the residual risk is only
  that the expression's public branch misbehaves, not that the suites fail there. Check
  the first public run for two jobs.

## Other checks at d9383ec

- `scripts/privacy-scan.sh .github/workflows/checks.yml`: clean. The workflow is ASCII
  only, so no em or en dashes.
- The header's first line still says "on Linux and macOS"; lines 5-7 qualify it right
  below, so it does not overclaim.
- The new comment says private macOS minutes are billed "at a higher rate" without a
  number, so there is no volatile figure to go stale.
- Security posture unchanged from round 1: `contents: read`, `persist-credentials: false`,
  no secrets, no `pull_request_target`. The only untrusted value used in an expression is
  a boolean from the event payload, and it is never inserted into a `run:` step.

## What's good

- The cost fix is one expression, with no second workflow file and no duplicated job
  definitions.
- The declined items each have a stated reason tied to how this repository is actually
  used, rather than being ignored.
- The claim about the public branch was put to the reviewer as unobserved instead of
  presented as verified.

## History

- Round 1 (08e734c): APPROVE WITH COMMENTS, 12/12. No defects; five optional nitpicks and
  one cost decision for the human (macOS on every private push).
- Round 2 (d9383ec): APPROVE, 12/12. Cost decision applied (Linux only on private), timeout
  and comment nitpicks applied, cancel-in-progress and fork-only `if:` declined with
  reasons. Regression: same score, fewer open comments.
