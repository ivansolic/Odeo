---
artifact: ci-setup
type: code
branch: chore/ci-setup
reviewed_commit: 08e734c
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: CI checks workflow (round 1)

## Scope reviewed

`git diff main...chore/ci-setup` at `08e734c`, 3 files, +43/-2:
`.github/workflows/checks.yml` (new, commit `3c2259b`), `tests/config-dir.test.sh` and
`tests/set-project-language.test.sh` (stat order fix, commit `08e734c`). No plan document;
reviewed against the stated intent (verify only, both OSes, no secrets, no private data in
public logs) and the house rules.

## Verdict

APPROVE WITH COMMENTS. No defects. The comments are optional hardening and one cost
decision for the human.

## Evidence gathered (not taken on trust)

- Pin: `gh api repos/actions/checkout/git/ref/tags/v7.0.1` resolves to a lightweight tag,
  object type `commit`, sha `3d3c42e5...`, commit "prep v7.0.1 release (#2531)"; v7.0.1 is
  the latest release (published 2026-07-20). The pin is the real commit, not a tag object.
- CI: Odeo-private run 36689920329, headSha `08e734c9...`, both jobs success
  (ubuntu 1m23s, macos 2m46s). The log carries 78 `PASS tests/` lines = 39 suites x 2 OSes,
  matching the 39 `tests/*.test.sh` files, so "every test suite" is literally true. The only
  `SKIP` line (SHELLOPTS allexport) is an in-suite capability skip, present on both OSes.
- Public tree: built the snapshot locally with `scripts/publish-snapshot.sh` into the
  scratchpad (exit 3, 35 advisory privacy findings, none in the changed files), `git init`
  + commit, then ran `skills-lint.sh` and every suite inside it on macOS: all green. So the
  workflow will not go red on the public repo from stripped internal paths, and the suite
  does not depend on `docs/evals/`, `docs/plans/`, `knowledge/` or `.claude/`. Not run on
  Linux against the snapshot.
- Privacy: `scripts/privacy-scan.sh` clean on each of the three changed files, scanned one
  by one (the script reports only the first path when given several). No non-ASCII bytes,
  no em or en dashes in the workflow.
- Other BSD/GNU traps: grep of `scripts tests hooks bin` for `stat -f|stat -c|date -r|date -d|sed -i`
  finds only the two fixed tests plus `date -r` in `scripts/ledger-backup.sh` (reference
  file form, valid on both) and `scripts/share-tunnel.sh:29` (epoch form, GNU falls through
  to `date -d`). No third instance of the class.
- Orphan branch: `internal-files` on Odeo-private carries no `.github/workflows/`, so ledger
  backup pushes do not trigger the workflow or bill any minutes.

## Security

- `permissions: contents: read` at workflow level, `persist-credentials: false`, no
  `secrets.*`, no `pull_request_target`, no untrusted `${{ }}` interpolated into a `run:`
  (only `matrix.os` into `runs-on`). A fork PR on the public repo runs with a read-only
  token and no secrets, and the tree it runs is the stripped snapshot, so there is nothing
  private for its logs to print. Private-repo logs stay private to the repo.
- `/security-review` is not required by AGENTS.md (no auth, input, upload, payment or data
  access change). The CI-specific surface (token scope, fork trust model, injection,
  pinning, credential persistence, public log exposure) is covered above.

## Nitpicks (optional)

- `.github/workflows/checks.yml:6-8`, duplicate runs: a same-repo PR gets a `push` run AND
  a `pull_request` run, and the concurrency key includes `event_name`, so neither cancels
  the other. Low impact here (merges are local via `/odeo:merge`, the public repo accepts
  snapshot pushes only), but if wanted, keep both triggers and add to the job
  `if: github.event_name == 'push' || github.event.pull_request.head.repo.full_name != github.repository`
  so `pull_request` runs only for fork PRs.
- `.github/workflows/checks.yml:13`, `cancel-in-progress: true` also cancels on the default
  branch, so two quick pushes to `main`/`backup-main` leave the first commit without a
  result. Use `cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}` if every main
  commit should keep its own verdict.
- `.github/workflows/checks.yml:19`, `timeout-minutes: 20` against a ~3 min run means a
  hung suite burns 20 macOS minutes. 10 still leaves 3x headroom.
- `.github/workflows/checks.yml:4`, the comment lists `(find, sed, date)`; the one
  divergence this branch actually hit was `stat`. Add it.
- Pin maintenance: a sha pin never updates itself. Do NOT fix this with Dependabot on the
  public repo (its PRs would land outside the snapshot publish path); bump by hand, or
  enable Dependabot on Odeo-private only.

## Open decision for the human (cost, not a defect)

macOS runs on every push to every branch of the private repo. Per push that is 3 billed
macOS minutes (2m46s rounded up) plus 2 Linux. From memory, as of 2026, unverified (the
billing API needs the `user` scope): private-repo macOS minutes count at a 10x multiplier
against the free allowance, so roughly 32 included minutes per push. Public-repo runs are
free. If that is too much, keep Linux everywhere and run macOS only on the public repo and
on `backup-main`, e.g.
`os: ${{ fromJSON((github.event.repository.private && github.ref != 'refs/heads/backup-main') && '["ubuntu-latest"]' || '["ubuntu-latest","macos-latest"]') }}`.
The tradeoff: local development is on macOS, so the private macOS job mostly repeats what
already ran locally, while Linux is the new coverage.

## Testing note

The mode-loss mutations were observed RED on macOS. On Linux the new GNU `stat -c %a`
path has not been seen failing on a mutation; the inference that it would (mktemp creates
600 on Linux too) is sound, and the first Linux run did show the assertion is live there.
The commit message "each check observed RED" does not say macOS; a reader may read it as
Linux. Not worth amending.

## What's good

- Every suite runs even after a failure and the failures are named at the end, with
  `::group::` folding; an empty glob fails closed.
- `fail-fast: false` so one OS cannot hide the other's result.
- The stat fix is the root cause, not a workaround, and the comment explains why the order
  matters on both platforms.
- The pin was resolved live and is verifiably the release commit.

## History

- Round 1 (08e734c): APPROVE WITH COMMENTS, 12/12. No previous record for this branch.
