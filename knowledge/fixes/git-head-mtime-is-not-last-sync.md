---
module: hooks/odeo-context.sh community reminder, scripts/community-sync.sh
tags: [git, mtime, freshness, fetch, FETCH_HEAD, clone, staleness]
problem_type: pattern
provenance: feature/community-freshness-reminder (review round 1, 2026-09-30), measured 2026-09-30
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
- `.git/FETCH_HEAD` is written by every successful fetch, even an up-to-date one, but does
  NOT exist right after a clone.
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
Best available order for an old copy: own stamp -> FETCH_HEAD -> HEAD (clone time) ->
"cannot be dated, say so".
