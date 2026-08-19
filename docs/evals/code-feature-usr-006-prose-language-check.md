---
artifact: USR-006
type: code
branch: feature/usr-006-prose-language-check
reviewed_commit: 03f720d
artifact_version: 6
date: 2026-08-19
scorer: code-reviewer
model: claude-opus-4.8
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

# Code review, USR-006 warn on prose-language mismatch (round 6, re-anchor)

Re-anchor of the round-5 record at the new head `03f720d`. This is NOT a fresh code
review: it re-verifies that the code is unchanged, judges whether the docs-only plan
reconciliation honestly closes the single round-5 Important, and re-scores accordingly.
Contracts: `docs/plans/2026-08-13-usr-006-prose-language-warning.md`, C1 (prose region),
C3 (status set), C4 (decision rule), M5 (mutation matrix).

## Why this record was regenerated (not re-dated)

The merge-gate refused because a non-evals file moved after the round-5
`reviewed_commit: 9ff98f5`. The mover is a single file, the plan
`docs/plans/2026-08-13-usr-006-prose-language-warning.md`. Measured, not trusted:

- `git diff --quiet 9ff98f5 03f720d -- bin/ tests/` is CLEAN. Both code files are
  byte-identical to their `9ff98f5` blobs, and each is bit-identical to its `03f720d`
  blob. Therefore every code finding, mutation, adversarial shape and count from round 5
  stands UNCHANGED and was deliberately not re-derived.
- `git diff --name-only 9ff98f5 03f720d` yields exactly two files: this evals record and
  the plan. The ONLY non-evals delta is the plan.

The re-anchor is required because a `reviewed_commit` must be a hex SHA of the exact text
read; a stale SHA cannot certify text that has moved, even when the moved text is docs.

## Provenance

The executor was the ORCHESTRATING SESSION, not an isolated builder; `build_model_as_dispatched:`
is omitted, not guessed. Judged on Opus 4.8, the model this session runs as. Mutation
discipline for the one check I re-ran (M5): the mutated script was installed over the real
`bin/` file with its pristine copy held in `/tmp`, restored from `/tmp` (never git), and both
code files were verified bit-identical to their `03f720d` blobs afterward
(`git diff --quiet 03f720d -- bin/ tests/` clean). `git status --porcelain` holds only this
untracked record.

## Verdict
APPROVE

The round-5 Important is CLOSED. Residual (a), a code span wrapping a line break leaves its
bytes in the region, was an Important only because the plan's C1 invariant, as literally
written, said the region never includes inline-code-span bytes. That was queued for the gate
rather than fixed in code, correctly, because the behaviour is deliberate and the alternative
(deleting wrapped spans) is the exact mispairing that scored three prior Criticals. The plan
now documents the behaviour as a stated limitation of C1, so contract and code agree. With the
divergence reconciled, conventions is no longer capped and the delta reaches 12/12. Nothing
blocks merge.

## The reconciliation, judged against the round-5 Important (diff read, not assumed)

The plan edit `9ff98f5..03f720d` touches C1, C3, C4 and the M5 mutation line. Each closes one
of the three gate items the round-5 record left open, and none papers over a real break.

### C1 (the round-5 Important) — CLOSED, honestly

The invariant now reads "the region never includes any byte from ... an inline code span THAT
OPENS AND CLOSES ON ONE LINE ... a code span deletes only up to its own closing backtick, and
NO deletion ever crosses a line break". A new bullet records STATED LIMITATIONS, in the same
category as one another and none an oversight: (1) a 4-space-indented block is not a code block,
and (2) a code span that WRAPS across a line break is left in the region, content and all,
because pairing backticks in the presence of a stray one is not decidable from a single
document, and every version that tried to delete wrapped spans mispaired a stray and ate real
prose (three review Criticals). The residuals are pinned as cases: K10, K12b for the wrapped-span
limitation; K15c, K15d for the one-line stray+span cost.

This is exactly the fix the round-5 record prescribed ("amend C1 ... state that a code span
WRAPPING a line break is a limitation of the region (its content is counted), in the same
category as C1's existing 4-space-indent limitation"). The round-2 decision to delete wrapped
spans is REVERSED, and the plan says so in words ("this reverses the round-2 decision to delete
wrapped spans, deliberately") rather than hiding it. The over-wide "the region never includes
any byte from an inline code span" claim is narrowed to the true "opens and closes on one line",
so the contract no longer asserts something the code does not do. Honest reconciliation, not a
paper-over: the price is stated (wrapped-span content is counted; it is code, almost never a
function word, so it cannot move a verdict), and the bound lives in cases, not in a sentence,
which is the round-3 lesson this story learned.

### C3 / C4 (UNREADABLE fifth status) — CLOSED

C3's status set now reads `WARN | OK | LOW-EVIDENCE | NO-PROSE | UNREADABLE`, with a paragraph
recording that UNREADABLE was added in round 3 and splits C4's `counted == 0` case: a non-empty
region that yields no countable token (non-Latin script, or Latin prose holding none of the four
lists' function words) reports UNREADABLE, while a genuinely empty region stays NO-PROSE. C4's
rule table is split to match: `counted == 0` with no non-whitespace char -> NO-PROSE;
`counted == 0` with a non-empty region -> UNREADABLE. This matches the code (the counted==0 split)
and the tests (K13, K13d), both unchanged and green.

### M5 (mutation line) — CLOSED and independently re-measured

The line now reads: "change `MIN_HITS` to 11 -> F2 and H red (H pins `MIN_HITS=12` per C2, so it
reddens together with F2; measured at review, the v1 claim of 'F2 red alone' was wrong)." I
re-measured this at `03f720d` by installing `MIN_HITS=11` over the real script (pristine copy in
`/tmp`) and running the suite. Full fail lines:

```
FAIL: F2 (0 de + 11 en): status LOW-EVIDENCE (expected 'LOW-EVIDENCE', got 'WARN')
FAIL: F2 prints no WARN even at a 100 percent rival (unexpected 'WARN')
FAIL: H MIN_HITS is 12 (expected '12', got '11')
```

Exactly F2 (two assertions: the status route flips to WARN because `counted(11) < MIN_HITS(11)`
is now false and `rival*2 > counted`, and the "prints no WARN" guard) and H (`H MIN_HITS is 12`).
The corrected line is accurate; the v1 "F2 red alone" was indeed wrong. The script was restored
from `/tmp` and re-verified bit-identical to its `03f720d` blob; the baseline suite is green
(all assertions passed, exit 0).

## Carried-forward code findings (code unchanged, not re-derived)

All round-5 code conclusions stand at `03f720d` because `bin/` and `tests/` are byte-identical:
the cross-line eating class is structurally gone (nine adversarial shapes, two never-silence
checks and a worst-case accumulation, none eating across a break, none silencing a warning);
residual (b) eats one line only and is conformant to C1 rule 6 as written; 202 assertions, all
26 suites green. These are not re-measured here by design (the review budget forbids redundant
re-runs of unchanged, already-evidenced code); the M5 mutation was the one exception, run only
because the plan makes a fresh factual claim about it that this re-anchor had to confirm.

## Findings

### Important
None. The round-5 Important (residual (a) vs C1) is closed by the plan reconciliation above.

### Nitpicks (carried forward from round 5, unchanged code, optional)
1. Design comment, `bin/prose-language-check.sh:81-85`. The "loss is confined to ONE line and
   cannot silence a verdict" bound holds because of parity alternation (an in-span line restores
   the tokens the previous line ate); one clause naming that mechanism would make the bound
   self-evidently robust rather than asserted.
2. `tests/prose-language-check.test.sh` K12e comment cites "AGENTS.md:190-191"; pinned line
   numbers drift as AGENTS.md is edited. Prefer "the AGENTS.md git...HEAD wrapped-span shape".
3. Commit trailer reads "Claude Opus 5 (1M context)" while the work executed partly on Opus 4.8.
   Provenance only, kept for branch consistency; no code impact.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold >= 9, no zero)

- **correctness 2.** Unchanged from round 5. The cross-line eating class is structurally
  eliminated; residual (b) eats one line only and cannot silence a whole-document verdict.
- **security 2.** Unchanged. The awk program is a fixed literal, document bytes never reach a
  shell word, paths are quoted, no secret or PII is printed.
- **performance 2.** Unchanged. One line-level awk pass, no `RS=""` buffering.
- **readability 2.** Unchanged. One `opn` bit plus a blank-line reset; bounds named at their
  code sites.
- **testing 2.** Unchanged. The class is closed structurally and both residuals are pinned as
  cases (K15c an exact `assert_eq`); the M5 attribution reproduced exactly again this round.
- **conventions 2.** UP from 1. The single stated-contract divergence that capped this dimension,
  C1's "region excludes inline-code-span bytes" vs the code counting wrapped-span content, is
  reconciled: C1 now narrows the invariant to same-line spans and records wrapped-span content as
  a stated limitation in the same category as the 4-space-indent one, pinned as cases. C3
  UNREADABLE and the M5 line are likewise closed and the M5 correction is measurement-accurate.
  Plan and code now agree; no new inconsistency is introduced by the edit.

## Ceiling

12/12, no structural cap remains. Conventions was capped at 1 in round 5 solely by the three
open plan reconciliations (C1 wrapped-span, C3 UNREADABLE, M5 line), all of which had to land in
the plan, a file outside the two code files, and so could not be closed within the round-5 commit.
They have now landed. Every dimension is at 2.

## Round 5 -> round 6 (regression note: BETTER)

11/12 -> 12/12, APPROVE WITH COMMENTS -> APPROVE. conventions 1 -> 2; all other dimensions hold
at 2. No code changed (`bin/` and `tests/` byte-identical to `9ff98f5`); the gain is entirely the
docs-only plan reconciliation closing the round-5 Important and the two long-standing gate items,
verified honest by reading the diff and by re-measuring the M5 mutation. Nothing blocks merge.

## History

- v1, `916b6c9`, 8/12, REQUEST CHANGES. One Critical (the fence-exclusion mutation proof did not
  reproduce, because `PRD-905`'s fenced lines started with `#` and the heading rule shadowed the
  fence rule) and six Importants.
- v2, `9b4ca34`, 8/12, REQUEST CHANGES. All eight round-1 items closed. One new Critical from the
  fix for item 4 (`RS="\x01"` widened rules 6 to 8 past the constructs they name), one Important
  on the missing over-drop case, one on how the four-language limit surfaces, four nitpicks.
- v3, `d730719`, 7/12, REQUEST CHANGES. Round-2 Critical narrowed but reproducible across a
  whitespace-only line (AC1 silenced), one Important on the guard's unbounded leak, one on the
  unrecorded C3 deviation, two nitpicks. The `AGENTS.md` +3 confirmed a correction.
- v4, `d8cf267`, 7/12, REQUEST CHANGES. All three v3 findings and both nitpicks closed and verified
  by mutation; one new Critical, the per-line fallback over-consuming inside an odd paragraph (C1
  breach, AC1 silenced, regression against `d730719`), two Importants on the "step 6 verbatim"
  mislabel, two nitpicks. WARN -> OK against `916b6c9` independently confirmed a correction.
- v5, `9ff98f5`, 11/12, APPROVE WITH COMMENTS. Refactor: same-line pairing plus one `opn` bit and
  a blank-line reset, deleting the `RS=""` records, the parity branch, the per-line fallback and
  the whitespace-line special case. The cross-line eating class that scored three Criticals is
  structurally gone, verified by mutation and by nine adversarial shapes plus a worst-case
  accumulation. Two residuals disclosed, bounded and pinned as cases (a: wrapped-span content
  counted, K10; b: one-line stray+span eating, K15c/K15d). One Important remained: residual (a)
  violated C1's stated region-excludes-code-span invariant, deferred to the gate with the still
  open C3 UNREADABLE and M5 items. 202 assertions, all 26 suites green.
- v6, `03f720d`, 12/12, APPROVE. Re-anchor after a docs-only plan reconciliation; `bin/` and
  `tests/` byte-identical to `9ff98f5`, so all code findings carry forward unchanged. The plan now
  narrows C1 to same-line code spans, records wrapped-span content as a stated limitation (K10,
  K12b) alongside the one-line stray+span cost (K15c, K15d) and states the round-2 reversal
  explicitly; C3 records UNREADABLE as the fifth status with the counted==0 split; the M5 line is
  corrected to "F2 and H" and re-measured accurate. The round-5 Important is closed, conventions
  rises 1 -> 2, nothing blocks merge.

## What is good

The reconciliation does the honest thing under a gate that could have been gamed: instead of
quietly editing the code to match the contract or the contract to hide the code, it narrows the
C1 invariant to what the code actually guarantees (same-line spans, no deletion across a break)
and records the wrapped-span cost as a stated limitation in the same category as the pre-existing
4-space-indent one, with the round-2 reversal named out loud and every residual pinned to a case
rather than a sentence. The M5 correction goes further than it had to, admitting the v1 "F2 red
alone" claim was wrong and stating why (H pins MIN_HITS=12), and it re-measured exactly. Code and
contract now say the same thing, which is the whole point of a contract.
