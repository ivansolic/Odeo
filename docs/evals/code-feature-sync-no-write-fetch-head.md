---
artifact: sync-no-write-fetch-head
type: code
branch: feature/sync-no-write-fetch-head
reviewed_commit: 2b61d03
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 11/12
verdict: APPROVE
---

# Code review: community sync fetches without writing FETCH_HEAD (round 2)

## Scope reviewed

Round 2 reads the fix delta `git diff e1cc727..2b61d03` (one commit, 2b61d03; comments in
`hooks/odeo-context.sh` and the knowledge entry
`knowledge/fixes/git-head-mtime-is-not-last-sync.md`, no code), on top of the full round-1
review of `git diff main...e1cc727` against the approved plan `vast-plotting-russell.md`.
I did not re-run the suites: the delta touches only comments and a markdown entry, and the
builder reported odeo-context, community-sync and lint green.

## Round-1 findings, verified closed

- Important, knowledge entry self-contradiction: closed. Lines 45-47 now say that on git
  2.29+ only a fetch run outside Odeo or by an earlier Odeo release can leave FETCH_HEAD, and
  that on older git Odeo's own plain fetch still writes it. That matches the code
  (`scripts/community-sync.sh:44-48`) and the round-1 probes.
- Nitpick, hook "Known gap" omitted the pre-upgrade source: closed. `hooks/odeo-context.sh:40-43`
  names older git, a fetch outside Odeo, and a fetch by an earlier Odeo release, each bounded
  by the stated 14 days. The sentence is now exact.
- Nitpick, header line width: closed. The widest line in the block (lines 33-47) is 93 columns.
- Nitpick, provenance: closed. It appends `feature/sync-no-write-fetch-head` as an indented
  YAML plain-scalar continuation, the same form as
  `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md`. No script in `scripts/` or
  `hooks/` parses `provenance:` line by line (grep), so the continuation breaks nothing.
  `language-guard.sh` on the entry: clean. No em or en dashes in the delta.

## Evidence carried from round 1 (code unchanged since e1cc727)

- The option name stays untranslated under de_DE, fr_FR and zh_CN (Homebrew git 2.54.0 with
  catalogs), so the `*write-fetch-head*` detection works in every locale. A detection failure
  degrades to the old plain fetch; a false positive is impossible.
- `git clone` and `fetch --no-write-fetch-head` create no FETCH_HEAD; `@{u}` still advances.
- The only FETCH_HEAD reader is `community_state` (`[ -s ]`).
- Mutation M36 reproduced in a temp copy (RED as recorded); the test file is green under
  `/bin/bash` 3.2.57.

## Findings

None open.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## History

- Round 1 at `e1cc727`: 11/12, APPROVE WITH COMMENTS. One Important (the knowledge sentence
  contradicted itself about older git) and three nitpicks (the hook's Known gap left out
  pre-upgrade FETCH_HEAD files, one 120-column line, provenance missing the branch). That
  record was never committed.
- Round 2 at `2b61d03`: all four fixed in comments and markdown only; 12/12, APPROVE.
  Trajectory 11/12 -> 12/12, ending under the review-loop stop condition (approve).
