---
artifact: code
type: code
branch: main
scope: model policy scripts, commit 2b097e9 (skills-lint.sh C11 broadened, merge-gate.sh + spec-gate.sh tier allowlist, frontmatter_field index() match, eval-framework migration note, tests +8)
date: 2026-07-18
scorer: code-reviewer
model: claude-fable-5[1m]
model_tier: strong
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 11/12
previous_total: 7/12
verdict: APPROVE WITH COMMENTS
---

# Code review: model policy, round 2 (final)

Regression vs round 1 (7/12, REQUEST CHANGES): BETTER. The Critical and all
four Importants are independently verified fixed. Suites: skills-lint 23,
merge-gate 21, spec-gate 26, all green. Findings below come from live probes
in throwaway repos (16 gate cases x2 gates, 13 lint cases), not from the suites.

## Round-1 findings, verification status

- Critical (tier floor was a blocklist): FIXED. Both gates now run an exact
  case allowlist. Probed in both gates: `banana`, `haiku`, `flash`,
  `fast (haiku)`, `strong # comment`, empty, missing, indented all refuse with
  distinct messages; `strong`, `STRONG`, `strongest`, CRLF `strong`,
  `fast` + `model_waiver: human` (and `HUMAN`) pass; `fast` + waiver with
  trailing prose refuses. Regression tests exist for banana, haiku,
  fast (haiku) (merge-gate) and flash (spec-gate).
- C11 regex: FIXED. `(opus|sonnet|haiku|fable)[- ][0-9]` case-insensitive
  catches prose `Sonnet 4.6`, old dated `claude-3-5-sonnet-20241022`,
  capitalized `Claude-Sonnet-4-5`, `Haiku 4.5`, `fable-5` (all probed).
  Tier phrases without digits stay clean; zero false positives on the real
  tree (lint exit 0).
- C11 scope: FIXED. AGENTS.md and global/CLAUDE.md now scanned (probed hits
  in both). Test covers the AGENTS.md case.
- Builder parse: FIXED. Trailing whitespace after `model: sonnet` passes;
  a frontmatter-less file with a body `model:` line is no longer parsed
  (both probed). Test pins the whitespace case.
- Migration note: FIXED. eval-framework.md documents that pre-field records
  refuse once and regenerate via the reviewer.
- Nitpicks: fld metachar fixed via `index($0, fld ":") == 1` (probed:
  `model` does not match `model_tier:`/`model_waiver:` lines and vice versa,
  literal `m.del` matches only itself); sync notes present both directions;
  sections relabeled 3c/3d in order; blank lines squeezed; C10 declared
  intentionally unused in invariants.md; incident lore de-versioned.

## Critical (must fix before merge)

None.

## Important (should fix)

- docs/eval-framework.md:59, the canonical record template now teaches a line
  the gates refuse. `model_tier: strong     # fast | strong | strongest; ...`
  copied literally yields value `strong # fast | ...`, which the new allowlist
  rejects as unknown vocabulary (probed: refuse in both gates). The verdict
  line already solved this exact problem by keeping its comment on a separate
  line (line 65). Fix: move the tier comment (and the round-2 continuation
  lines) below the field, own-line comments in frontmatter are ignored by the
  parsers. Failure mode is loud and self-explaining, so this is a first-run
  debugging tax, not a hole; the real records in this repo already use the
  clean form.

## Nitpicks (optional)

- bin/skills-lint.sh:94, C11's alternation covers Anthropic-family names plus
  fable only. The tier map in AGENTS.md explicitly names flash (Google) and
  mini (OpenAI) classes, but a pinned `gemini-2.5-flash` or `gpt-5-mini` id
  passes lint. AGENTS.md already says the tier map extends per host at port
  time; say the same next to C11 (or in the invariants row) so ports know to
  extend the alternation too.
- bin/skills-lint.sh:100, the builder awk's closing delimiter `/^---/` is
  looser than its opener `/^---[[:space:]]*$/` (and than frontmatter_field's
  close). Fail-closed direction, but align for symmetry.
- Casing normalization (`model_tier: FAST`, `model_waiver: HUMAN`) works
  (probed) but is still unpinned by any test.
- Duplicate `model_tier:` lines: first match wins (carried from round 1,
  consistent with the verdict parser's posture; only matters if the ONE-line
  contract ever extends to tier).

## Testing

The eight new tests close exactly the gaps that hid the round-1 Critical:
unknown vocabulary, annotated fast, vendor word as tier (both gates), prose
name, dated id, AGENTS.md scope, builder trailing whitespace. Suites remain
hermetic. Remaining unpinned behavior is nitpick-level (casing, duplicates).

## What's good

The allowlist rewrite is exactly the deny-by-default shape the verdict check
established, with per-branch error messages that name the fix path, and it is
byte-for-byte the same contract in both gates under a two-way sync note.
`index($0, fld ":") == 1` is the right literal-match fix and handles the
model / model_tier / model_waiver prefix family correctly. The broadened C11
catches all four miss-forms of the motivating incident while staying clean on
the real tree, and the invariants row now explains both the incident and the
C10 gap. The migration note turns a silent breaking change into a documented
one-time step.

## History

- Round 1 (2026-07-18, commit 7979e9d): REQUEST CHANGES, 7/12. Critical: tier
  floor was a blocklist ('banana', 'haiku', 'fast (haiku)' passed). Important:
  C11 regex missed prose names, old dated ids, capitalization; C11 scope
  missed AGENTS.md and the global baseline; builder parse tripped on trailing
  whitespace; migration note absent. Nitpicks: fld regex injection, sync
  notes, section ordering, blank lines.
- Round 2 (2026-07-18, commit 2b097e9): all round-1 findings verified fixed by
  independent probes. One new Important (template's inline tier comment now
  refuses under the allowlist), four nitpicks. 7/12 -> 11/12, APPROVE WITH
  COMMENTS.
