---
artifact: USR-006
type: code
branch: feature/usr-006-prose-language-check
reviewed_commit: 9ff98f5
artifact_version: 5
date: 2026-08-18
scorer: code-reviewer
model: claude-opus-4.8
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 7/12
---

# Code review, USR-006 warn on prose-language mismatch (round 5)

Scope: the delta `d8cf267..9ff98f5` only, one commit `9ff98f5`, two files
(`bin/prose-language-check.sh`, `tests/prose-language-check.test.sh`), +126/-165 (net -39).
This commit is a REFACTOR of the code-span extractor, reviewed as a whole design, not an
incremental patch. Everything cleared in rounds 1 to 4 outside the extractor (frontmatter,
fence, heading, table exclusions; resolver agreement; decision rule C4; UNREADABLE; the C5
lint; provenance) stands and was not re-derived, since this commit did not touch it. Contracts:
`docs/plans/2026-08-13-usr-006-prose-language-warning.md`, C1 (prose region), C3 (status set),
C4 (decision rule).

## Provenance

The executor was the ORCHESTRATING SESSION, not an isolated builder; `build_model_as_dispatched:`
is omitted, not guessed. The human switched the session model to Opus 4.8 partway through this
work, so this record is judged on Opus 4.8; the commit trailer still reads "Claude Opus 5
(1M context)" for branch consistency, a provenance nit, not a code defect (nitpick 4). Every
number here was measured by me at `9ff98f5`, from `/tmp` copies of the `d8cf267` and `9ff98f5`
blobs plus `/tmp` fixtures. Mutations were installed into a `/tmp` shim tree (symlinks to the
real `bin/`, one script overridden, real `tests/fixtures` symlinked) and never touched git; both
files were checksum-verified against their `9ff98f5` blobs afterwards
(`bin/prose-language-check.sh` git-blob `eba2a65…`, `tests/…` git-blob `ff665d3…`, both equal),
and `git status --porcelain` holds only this untracked record.

## Verdict
APPROVE WITH COMMENTS

The Critical class that scored correctness 0 in rounds 2, 3 and 4 (a deletion eating prose
ACROSS a line break and silencing the warning) is STRUCTURALLY GONE, and I proved it by mutation
and adversarial measurement, not by reading. Same-line pairing plus the one-bit `opn` state make
a deletion incapable of leaving the line it starts on: `match()` runs on a single-line awk record
(default `RS="\n"`), and a line that begins inside an open span is kept VERBATIM and never
scanned. I could not construct any shape that eats prose across a break, and even the pathological
worst case cannot silence a warning. The two residuals are deliberate, bounded, pinned as cases,
and honestly recorded. One item keeps this from a clean pass and it is a PLAN reconciliation, not
a code defect: residual (a) means the region now contains bytes from a wrapped code span, which
the plan's C1 invariant says it never does. The commit surfaces this for the gate rather than
silently editing the contract, which is the correct process, but the invariant as written no
longer holds, so it is an Important finding to reconcile before merge (with C3's UNREADABLE and
the M5 line, both also still open and both flagged by the commit).

## The central claim, verified by mutation and adversarial measurement

Claim under test: no deletion can eat prose across a line break, for ANY document. I printed the
surviving region for each shape (the prior four Criticals were all "measure the region, not the
count").

Nine adversarial shapes, region measured, NONE eats across a break:

- Stray backtick then four German lines: the German lines begin inside the stray's span, kept
  verbatim, not one word eaten.
- Line begins mid-span with real German prose on it: kept verbatim whole.
- Wrapped span whose second line carries its OWN stray: line 2 kept verbatim (strays and all),
  German intact; the extra strays on an in-span line change nothing because that line is never
  scanned.
- EMPTY blank line inside an open span: `opn` reset to 0, the following line scanned normally,
  its `` `the of` `` deleted and the German around it (`und mit von der die`) survives.
- WHITESPACE-only line (`  \t `) inside an open span: same reset, same result, so both blank
  shapes close the span.
- Code fence opening while a span is open: the fence marker and fenced lines `next` out and do
  NOT reset or toggle `opn`, so a following German line stays in-span and is kept verbatim
  (counted, never eaten).
- Backticks on a HEADING line and on a TABLE line: both lines `next` out BEFORE the parity
  update, so their backticks never toggle `opn`; the next prose line scans with `opn==0` and the
  German survives.
- Odd number of backticks on a heading line: still no toggle, next line clean.

Two never-silence checks under a `de` project (the failure that actually matters):
- Stray opens a span, English body kept verbatim to EOF: `WARN detected=en counted=22 en=21`.
- Wrapped span then English body: `WARN detected=en counted=27 en=25`.
Both WARN; the warning is not silenced.

Worst-case accumulation of residual (b): an English body under `de` with a stray+span on EVERY
line: `WARN detected=en counted=48 en=48`. The parity alternates (an odd line eats, the next line
is kept verbatim, restoring the eaten tokens there), so even the pathological document warns. The
design comment's "the loss is confined to ONE line and cannot silence a verdict built from a whole
document" holds under stress, which is why it is NOT the story's fifth over-wide claim.

## The specific mechanics the scope named

- `opn` is updated by `bt=$0; opn=(opn + gsub(/\`/,"",bt)) % 2` on the ORIGINAL line, AFTER the
  fence/heading/table `next`s. Confirmed: dropped lines never reach the update, so their backticks
  never toggle the bit (ADV6/7/8/9 above). A line whose backticks were deleted by rule 6
  contributes the right parity because the count is on `$0`, and rule 6 deletes spans in pairs
  (`` `[^`]*` ``, two backticks each, an even count), so parity on `$0` equals parity on the
  deleted `line`.
- Blank-line reset `if (line ~ /^[ \t]*$/) opn=0` fires on both an empty line and a whitespace-only
  line (ADV4/ADV5), correctly ABANDONS the span (CommonMark: a code span cannot contain a blank
  line), and the reset is checked on `line` while it still equals `$0` (before the `opn==0`
  deletion block), so it does not depend on deletion order. The line after a blank scans with
  `opn==0`, which is the correct state and causes no over-deletion beyond same-line span removal.
- AGENTS.md re-derived independently: `counted=1031`. Line 191 (`HEAD\`) ...`) begins inside the
  `` (`git rev-parse --short `` span opened on line 190 and is kept whole, so "the / because /
  only" on it are counted, not eaten. Sweep of all 160 tracked `.md` files, each report diffed
  against `d8cf267`: seven move, all tiny (delta 1 to 5 tokens), all stay `OK`/`en`, none changes
  a verdict. Six increase (wrapped-span content now counted, residual a). One decreases,
  `BEGINNERS-GUIDE.md 581 -> 580`: a real double-backtick literal-backtick construct
  (`` `` Ctrl+` `` ``) is a stray+span on one line, so residual (b) eats "and run" there (one `en`
  token, "and"); verdict unchanged. This is residual (b) occurring in the repo's own docs,
  bounded to one line, exactly as designed.

## Residual (a): wrapped-span content is counted, honestly recorded but a live C1 divergence

K10 measures it: line 1 opens a span, line 2 begins inside it and is kept verbatim, so the wrapped
span's content survives as text and is tokenized. Region printed; `en >= 6` (the content is made
of function words on purpose to show the residual), `de >= 24`, status `OK` (German still
dominates). This reverts round 2's "delete wrapped spans" behaviour, and K10 is respecified to
assert the new behaviour, correctly.

Judgement the scope asked for: this is HONESTLY recorded, NOT a silent contract break. The commit
body names it, the code comment (lines 63 to 85) explains it at length, K10 pins it, K12/K12e/K15
show a document is never silenced by it, K12b shows a blank line ends its reach, and the commit
explicitly queues it "FOR THE GATE" as a plan correction alongside the same category as C1's
existing "a 4-space indented block is prose" limitation. BUT it is still a real divergence: C1's
declared invariant is "the region never includes any byte from ... an inline code span ... a code
span deletes only up to its own closing backtick", and a wrapped span now contributes bytes and
is deleted not at all. Per the review rule (a stated invariant the code does not hold is a finding
even when every test passes), this is an Important finding: the plan's C1 must be amended at the
gate before merge. It caps conventions at 1. It does NOT threaten correctness, because the check
is advisory, wrapped-span content is code (almost never a function word), and the divergence keeps
text rather than eating it, so it cannot silence a warning.

Residual (b) by contrast is CONFORMANT to C1 rule 6 as literally written ("delete every SHORTEST
backtick-delimited span, repeatedly"): a stray followed by a real span forms a shortest
backtick-delimited span whose content is prose, and rule 6's own greedy algorithm deletes it.
K15c pins it (`de 7 -> 4`, region printed: "Der Wert  the of and that with is\` zu zum zur", so
"und mit von" is the eaten prose and the code is what survives), and it is an `assert_eq` exact
pin, so any GROWTH of the residual beyond one line reddens it in either direction. K15d embeds the
exact bad line in a real German body and the verdict stays `OK` with `de >= 40`, the bound that
makes it acceptable.

## Every rewritten case passes for the reason its name gives (region printed, not counts trusted)

K10, K12, K12b, K12c, K12d, K12e, K14, K14b, K15, K15b, K15c, K15d all measured. Highlights:
K12e reproduces the AGENTS.md:190-191 shape and reads `de=9 en=0` because line 2 is kept verbatim,
which is why AGENTS.md reads 1031 not 1028; K12b shows a blank line closing the stray's span so
the later `SIX` span IS deleted (`en=0`); K14b is the load-bearing one, an English body under `de`
threaded through the stray+whitespace shape that still WARNS (`en >= 12`), pinning warning
survival rather than a count move. No case passes for the wrong reason.

## Mutation matrix: each new guard reddens only its own cases (full fail lines)

Baseline 202 assertions, 0 failures, exit 0.

```
=== MUTATION: drop the opn gate (scan every line) ===
FAIL: K12 the span after the stray, in the same paragraph, is kept not eaten: en=6 (expected '6', got '0')
FAIL: K12e a line inside a wrapped span is kept verbatim, so its German survives whole: de=9 (expected '9', got '5')
FAIL: K15 line 2 begins inside the stray's span and is kept whole, span included: en=6 (expected '6', got '0')
=== MUTATION: drop the blank-line reset ===
FAIL: K12b a blank line closes the stray's span, so the later span IS deleted: en=0 (expected '0', got '6')
=== MUTATION: neuter rule 6 (code-span deletion) ===
FAIL: B3 inside an inline code span: en=0 (the exclusion removed it) (expected '0', got '6')
FAIL: K6 and both spans are gone: en=0 (expected '0', got '4')
FAIL: K12b a blank line closes the stray's span, so the later span IS deleted: en=0 (expected '0', got '6')
FAIL: K15b no invented WARN on correct German: status OK (expected 'OK', got 'WARN')
FAIL: K15b the two clean spans on the first line are deleted: en=0 (expected '0', got '24')
FAIL: K15c a stray plus a span on one line eats that line's prose between them: de=4 (expected '4', got '7')
```

The `opn` gate reddens exactly the in-span-line cases (K12/K12e/K15); dropping it reintroduces the
old cross-line eating (`K12e de 9 -> 5`), proving the gate is what closed the class. The blank-line
reset reddens exactly K12b. Rule 6 reddens the span-exclusion cases, and `K15c de 4 -> 7` proves
the residual-(b) eating is precisely rule 6, not a separate defect.

## The commit body corrects the record and carries no new over-wide claim

Checked against the story's history of over-wide claims (four scored across rounds 1 to 4, a fifth
would be decisive on conventions). "Multi-line prose can never be eaten": TRUE, by construction
(single-line record) and by every adversarial shape above. "Net -39 lines ... small enough to
read": accurate (126 insertions, 165 deletions = -39 across both files; `prose_region` is 51 lines
including comments, the executable logic ~25). The residuals are stated as CASES (K10, K15c, K15d),
which follows the round-3 lesson "a bound lives in a case, never in a sentence". No fifth over-wide
claim exists.

## Gate items still correctly deferred, not silently dropped

- C3 UNREADABLE fifth status: present in code (the counted==0 split) and tested (K13, K13d), and
  the code comment records it as a deliberate deviation "raised as a plan correction at the gate
  rather than edited here". The commit body repeats it as still open. Not dropped.
- The plan's M5 line ("F2 and H", not "F2 alone"): the commit body carries it forward as still
  open. Not dropped.
- All 26 `tests/*.test.sh` green; real-repo skills-lint clean; 202 assertions; zero `exit 1`
  literals; zero awk interval `{n,m}` expressions; zero non-POSIX `\x` escapes in the script.

## Findings

### Important
1. `bin/prose-language-check.sh` (the `opn==0` verbatim path) and C1. Residual (a): a code span
   that wraps a line break now leaves its bytes IN the prose region and is deleted not at all,
   which the plan's C1 invariant ("the region never includes any byte from an inline code span ...
   a code span deletes only up to its own closing backtick") forbids. This is disclosed, bounded,
   tested (K10), advisory-only, and the commit correctly queues it for the gate rather than editing
   the contract, so it is Important, not Critical, and cannot silence a warning. Fix: amend C1 at
   the gate to state that a code span WRAPPING a line break is a limitation of the region (its
   content is counted), in the same category as C1's existing 4-space-indent limitation, and land
   that plan edit before merge together with the C3 UNREADABLE and M5 reconciliations.

### Nitpicks
2. Design comment, `bin/prose-language-check.sh:81-85`. "the loss is confined to ONE line and
   cannot silence a verdict built from a whole document" is true and I stress-tested it (residual
   (b) on every line of an English body still WARNs), but the reason it holds is the parity
   alternation (an in-span line restores the tokens the previous line ate), which the comment does
   not state. One clause naming that would make the bound self-evidently robust rather than
   asserted.
3. `tests/prose-language-check.test.sh` K12e comment cites "AGENTS.md:190-191"; the wrapped span
   in the live file is now on lines 190 to 191 with the `HEAD\`)` closer on 191, which matches, but
   line numbers drift as AGENTS.md is edited. Consider "the AGENTS.md git...HEAD wrapped-span shape"
   without the pinned line numbers, so the case does not appear to rot when the file moves.
4. Commit trailer reads "Claude Opus 5 (1M context)" while the work was executed partly on Opus
   4.8. Provenance only, kept for branch consistency per the dispatch note; no code impact. Noted
   because the record must not silently inherit a model name that the session did not run on.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 1/2 -> total 11/12 (threshold >= 9, no zero)

- **correctness 2.** The cross-line eating class is structurally eliminated and I could not break
  it: nine adversarial shapes, two never-silence checks and a worst-case accumulation all measured,
  none eats across a break and none silences a warning. Residual (b) eats one line only, is
  conformant to C1 rule 6 as written, and cannot silence a whole-document verdict even
  pathologically. The three prior Criticals are genuinely gone, not moved.
- **security 2.** Unchanged from round 4. The awk program is a fixed literal, document bytes never
  reach a shell word, paths are quoted, no secret or PII is printed, and no document content can
  change the exit code.
- **performance 2.** Simpler than the predecessor: one line-level awk pass, no `RS=""` record
  buffering, no per-paragraph `split`. The 160-file sweep runs in seconds.
- **readability 2.** Net -39 lines, the parity branch and per-line fallback deleted, one `opn` bit
  plus a blank-line reset in their place, and every bound named at the code site that carries it.
- **testing 2.** Up from 1. The class that previously had no case is now closed structurally AND
  the two residuals are pinned as cases (K15c an exact `assert_eq`, K15d its bound), K14b pins
  warning survival, every rewritten case passes for its named reason by region measurement, and
  every mutation attribution in the body reproduced exactly, five rounds running.
- **conventions 1.** One stated-contract invariant (C1: region excludes inline-code-span bytes)
  is not held by the code, because residual (a) counts wrapped-span content. It is disclosed and
  correctly deferred to the gate, which is why it is Important and not a 0, but the plan text and
  the code disagree until the amendment lands, so this is not a clean 2. No new over-wide claim
  (the fifth the story was watching for does not exist), so conventions does not fall to 0.

## Ceiling

11/12 for this delta. Conventions structurally caps at 1 until the plan's C1 (wrapped-span
content), C3 (UNREADABLE fifth status) and M5 line are reconciled at the gate, which is a plan
edit OUTSIDE these two files and so cannot be completed within this commit. Everything else is at
2. The moment those three plan reconciliations land, conventions reaches 2 and the delta is 12/12.

## Round 4 -> round 5 (regression note: BETTER)

7/12 -> 11/12, REQUEST CHANGES -> APPROVE WITH COMMENTS. correctness 0 -> 2 and conventions 0 -> 1
and testing 1 -> 2. The round-4 Critical (per-line fallback over-consuming inside an odd paragraph,
C1 breach, AC1 silenced) is closed by removing the machinery it lived in rather than patching it a
fourth time: the `RS=""` records, the odd/even parity branch, the per-line fallback and the
whitespace-line special case are gone, replaced by same-line pairing and one `opn` bit. Every
prior-round Critical shape re-measured and none is silenced. What remains is not a code defect but
three plan reconciliations the commit itself surfaces. First round of this story to clear the
threshold.

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
  accumulation, none eating across a break and none silencing a warning. Two residuals disclosed,
  bounded and pinned as cases (a: wrapped-span content counted, K10; b: one-line stray+span
  eating, K15c/K15d). One Important remains: residual (a) violates C1's stated
  region-excludes-code-span invariant, disclosed and correctly deferred to the gate with the still
  open C3 UNREADABLE and M5 items. 202 assertions, all 26 suites green.

## What is good

The commit removes a bug CLASS instead of patching a heuristic a fourth time, and it is right that
this was the only move left: an adversarial reviewer could always build the next mispairing, so the
fix had to make the failure structurally impossible, not smaller. It did. `match()` on a single-line
record plus the "in-span lines are kept verbatim" rule means a deletion cannot leave the line it
starts on, and I could not defeat it with any shape I built. The residuals are handled the way the
story learned to handle bounds: written as cases (K15c an exact pin that reddens on any growth,
K15d its embedding bound), not as sentences. The commit is honest about the price, reverting round
2's decision and recording residual (a) as a C1 limitation for the gate rather than quietly editing
the contract, and every mutation and count in the body reproduced exactly when I ran it, which is
five rounds of accurate attribution in a row. K14b remains the case this suite most needed: it pins
that a WARNING survives the mechanism, not merely that a count moved.
