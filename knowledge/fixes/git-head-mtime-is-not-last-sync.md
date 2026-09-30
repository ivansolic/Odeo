---
module: hooks/odeo-context.sh community reminder, scripts/community-sync.sh
tags: [git, mtime, freshness, fetch, FETCH_HEAD, clone, staleness]
problem_type: pattern
provenance: feature/community-freshness-reminder (review round 1, 2026-09-30), measured 2026-09-30;
  feature/sync-no-write-fetch-head (2026-09-30)
reuse_count: 0
created: 2026-09-30
---

# The date on .git/HEAD is the clone (or last branch switch), not the last sync

## Context
"How long since this clone was refreshed?" is tempting to answer from file dates in `.git/`.

## Guidance
- `.git/HEAD` holds `ref: refs/heads/main`. A `fetch` + `merge --ff-only` never rewrites it,
  so its date stays at clone time (measured: unchanged after fetch + ff; a branch switch
  DOES change it, which proves the probe works).
- `.git/FETCH_HEAD` is written by every successful fetch, even an up-to-date one (not with
  `--dry-run` or `--no-write-fetch-head`), but does NOT exist right after a clone.
- A FAILED fetch also touches it: it empties FETCH_HEAD to 0 bytes and gives it a new date
  (measured on git 2.50.1: unreachable remote, rc=128). So its date alone cannot tell a
  failed fetch from a successful one; only a NON-EMPTY FETCH_HEAD dates a fetch (`[ -s ]`,
  never `[ -f ]`). Even then it dates the fetch, not a completed sync.
- The honest signal is your own stamp, written only on the success paths of the sync
  (Odeo: `.git/odeo-last-sync` via `stamp_sync`). Fall back to the file dates only for
  copies made before the stamp existed, and name that fallback as approximate.

## Why it matters
Using HEAD's date as "last sync" tells a user who synced yesterday that the copy is weeks
stale: a false reminder, the kind that teaches people to ignore reminders.

## When to apply
Any staleness, freshness or "last updated" check on a git clone (mirrors, caches,
vendored repos).

## Examples
General recommendation for an old copy: own stamp -> non-empty FETCH_HEAD -> HEAD (clone
time) -> "cannot be dated, say so". Odeo 0.3.2 shipped stamp -> HEAD -> "cannot be dated";
the next release adds a non-empty FETCH_HEAD between the stamp and HEAD
(hooks/odeo-context.sh community_state). The first draft of that change used `[ -f ]` and
would have made every failed sync look fresh; review caught it by reproducing a failure.
Odeo's own sync then stopped writing FETCH_HEAD at all (`git fetch --no-write-fetch-head`,
git 2.29.0+ per the official release notes, detected from `git fetch -h`, plain fetch on
older git), so on git 2.29+ only a fetch run outside Odeo (or one made by an earlier Odeo
release) can still leave one; on older git, Odeo's own plain fetch still writes it.
