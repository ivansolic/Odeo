---
artifact: merge-gate-all-records
type: code
branch: fix/merge-gate-all-records
reviewed_commit: 0316b7e
date: 2026-08-05
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 4
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 8/12
---

## Scope reviewed

`0316b7e`, the fourth and final state of one logical change to the `/merge` [E]
guardrail (`8e2c23a` -> `9517d2a` -> `419b495` -> `744edbe` -> `0316b7e`). Dispatcher
supplied `0316b7e`; verified myself, `git rev-parse 0316b7e` == `git rev-parse HEAD`,
tree clean, `~/bin/merge-gate.sh` md5-matches the repo (`d6de6918…`).

Evidence: gate suite 63/63, all 23 test files green, skills-lint clean, plus my own
guarantee-by-guarantee fixtures, two independent spot-checks of the coordinator's
mutation claims, and one novel divergence probe.

## On the threat model

The coordinator's reframing is correct, and I am recording why I accept it rather than
just accepting it, so this approval is auditable.

These records are produced by five of our own reviewers against a format defined in
`docs/eval-framework.md`. The right test for a residue is not "can a shape be
constructed" but "does anything in the system produce it". That line is where my own
evidence already fell: CRLF was reachable through ordinary cross-platform tooling and
`grep`-version differences, and the malformed-frontmatter shape had in-repo precedent in
case 6g, so I called both Critical. A tab inside a `branch:` value, two `branch:` lines
with a decoy first, and a `.txt` record are produced by nothing, and I had already graded
the last of those on plausibility rather than kind in v3.

What settles it is that round 3's fix was structural, not another patch. Keying the
tripwire on "the frontmatter does not parse" instead of on matching a `branch:` line
removes the entire evasion class by construction, rather than removing the three
instances I happened to demonstrate. I verified that: padded, tabbed, uppercase and
blank-line-first records all refuse now, and I could not find a fourth shape, because
there is nothing left to pattern-match against.

**On whether the three guarantees are the right set: yes, with two amendments.**
1. Add the **model_tier floor** as a fourth. It is an enforced, AGENTS.md-documented
   property, independently regressible, and not implied by the other three. I tested it:
   one fast-tier record among five approving ones refuses.
2. The genuinely open gap is not in this diff and not in that list: the gate verifies
   that every record **present** approves, but it cannot know that a required reviewer
   **never ran**. A UI change carrying only a code-reviewer record passes today. That is
   the same shape as the bug this branch fixed (checking what is present rather than what
   is required), one level up, and it is mechanizable, since the diff is available and
   `boundary-check.sh` already reads it. That is worth the next round far more than
   another parser shape.

## Verdict

APPROVE WITH COMMENTS. All three guarantees hold under records our reviewers actually
produce, plus the tier floor. Nothing fails open. Two remaining defects are fail-CLOSED
robustness issues with one-line fixes; neither should hold the merge.

## Guarantees verified (my own fixtures, not the suite)

1. **Any non-approving record refuses.** Five records all approving -> 0; five with the
   last a REQUEST CHANGES -> 1; **four PASSes with a REQUEST CHANGES enrolled first -> 1**,
   which is the exact ADR-001 situation that motivated the change; one fast-tier record
   among five -> 1.
2. **A record describing moved code refuses.** Anchor == HEAD -> 0; after one code
   commit -> 1; after an evals-only commit -> 0. The anchor is tight in every direction
   I tested earlier and re-confirmed: hex-only, `^{commit}`-peeled, ancestor-checked,
   tree-compared with `docs/evals` excluded.
3. **An unreadable record refuses rather than being skipped.** All four shapes refuse:
   no opening `---`, no closing `---`, CRLF throughout, and an empty file. The tripwire
   and `frontmatter_field` agree on "parseable", which I probed specifically with a
   blank-line-before-frontmatter record (-> 1).

Also verified: none of the 20 tracked files under `docs/evals/` trips the tripwire, and
the two mutation claims I spot-checked hold (dropping the closing-`---` requirement
fails 4 assertions; re-adding `-name '*.md'` fails 1). The harness is trustworthy now.

## Important (should fix, not blocking)

1. **`bin/merge-gate.sh:82` — an untracked or gitignored file under `docs/evals/` blocks
   every merge on every branch, and `.DS_Store` is the likely instance.** `find` walks the
   filesystem, so a gitignored file is invisible to the clean-tree check at step 2 but
   visible to the tripwire. Verified: gitignored junk under `docs/evals/` leaves
   `git status --porcelain` empty and the gate exits 1 with "frontmatter does not parse".
   `.DS_Store` is on line 2 of this repo's `.gitignore` and Finder creates it in any
   folder a human browses, so on macOS this is a matter of time, and the remedy the
   message suggests ("re-run the reviewer") is the wrong advice for it. Fail-closed, so
   no bad merge passes; the cost is a permanently blocked merge path with a misleading
   diagnosis. Fix, one line, and strictly better than a name filter because it excludes
   junk by construction while keeping symlinks and non-`.md` records:
   ```bash
   done < <(git ls-files docs/evals | sort)
   ```
   Every real record is tracked (step 2 already refuses on untracked non-ignored files),
   so nothing legitimate is lost.
2. **The invariant "every file in `docs/evals/` is a parseable record" is now enforced but
   undocumented.** Verified: a `docs/evals/README.md` explaining the folder blocks every
   merge. That is a defensible design decision, the directory is machine-owned, but a
   human adding a README is ordinary behaviour and nothing warns them. Fix: state it in
   `docs/eval-framework.md` (records only, no README or index, because the gate treats an
   unparseable file as a broken record), and consider naming it in the refusal message.

## Nitpicks

- `bin/merge-gate.sh:119` — `printf '  %s\n' $unparseable` is unquoted, so a path with
  spaces splits and a `*` globs. Diagnostic path only, after the decision is made.
- The opening-frontmatter test `NR==1 { if ($0 !~ /^---[[:space:]]*$/) …}` now exists in
  four copies (lines 36, 89, 100, 158). They agree today, and I verified the tripwire's
  copy agrees with `frontmatter_field`'s, but if the new copy at line 89 ever diverges,
  a file could be parseable enough to skip the tripwire and unparseable to the field
  reader, which silently reopens guarantee 3. The file already uses a KEPT IN SYNC
  convention elsewhere; the new copy deserves the marker, or all four deserve one helper.
- Records reachable only by a hand-crafted file, explicitly recorded as nits per the
  agreed threat model, not as findings: a tab or padding inside a `branch:` value, two
  `branch:` lines, a `.txt` record. All refuse now anyway.

## Scores

correctness 1/2 (the enumeration predicate is wrong for non-record files; two real
shapes demonstrated, both fail-closed) · security 2/2 (all three guarantees plus the
tier floor hold; I could not construct a fail-open under any record our reviewers
produce, and I tried the five-record set, the ADR case, four unreadability shapes, moved
code, and evals-only commits) · performance 2/2 · readability 2/2 (this round made the
code simpler than v3: the branch-line matching is gone and the rationale comments carry
the history) · testing 2/2 (63 assertions, two of six mutation claims independently
re-verified, my novel divergence probe found nothing; the only untested shapes are the
two in Important 1 and 2, counted once under correctness) · conventions 2/2 (install
synced and md5-verified, lint clean, spec-gate deferral in the ledger, mutation
discipline applied one-at-a-time and self-audited)

**total 11/12** (threshold: >=9, no zero) -> PASS

## Ceiling

12/12 needs only Important 1: one line, `git ls-files` instead of `find`. Important 2 is
a documentation line. Neither changes the gate's guarantees.

## Sequencing note (read before merging)

My record now approves, so the gate will pass once this file is committed: it is the only
record carrying this branch, and `docs/evals` is excluded from the anchor diff, so
committing it cannot stale its own anchor. But if the two Importants are fixed **before**
merging, that touches `bin/merge-gate.sh` and `docs/eval-framework.md`, which stales this
record and requires a re-review by the rule this branch introduces. Both orders are
legitimate; pick deliberately. Merging now and fixing on a follow-up branch is the
cheaper one, and the two fixes are independent of everything merged here. This is the
operational cost I raised as v1's I6 and it is still real: a repo-wide anchor makes any
follow-up edit re-stale every record on the branch.

## Regression note vs v3 (8/12 at `744edbe`)

Better, and the change closes with the defect class actually gone rather than narrowed:
4 -> 5 -> 8 -> 11. Round 3's tripwire rewrite is the first fix in this sequence that
removed a class by construction instead of removing instances, and it did so by taking
the stronger of the two options I offered rather than the cheaper one. All four of v3's
Importants are closed: the whitespace evasions and the PM-record false positive vanished
with the branch-line matching, the `-name '*.md'` fail-open is gone, and the two live
mutations no longer exist because the code they mutated no longer exists. What remains is
a different and smaller class than anything in v1 to v3: the gate is now correct about
records and wrong about non-records, and both instances refuse rather than allow.

## Provenance note

`model_tier: strong` is declared, not `strongest`: this ran on Opus 5 (opus class, above
the strong floor), but I did not resolve the live model lineup, and per lessons.md
2026-07-27 "strongest" is a claim about the currently-available top tier and must not be
asserted from memory.

## History

- v1 (2026-08-05, `9517d2a`): REQUEST CHANGES, 4/12. Four Criticals: enumeration blind to
  CRLF and treating the branch as a regex; `reviewed_commit: HEAD` a permanent bypass;
  the anchor contract one-sided across four no-Bash reviewers; the fix not installed, so
  `/merge` still ran the vulnerable gate. Six Importants.
- v2 (2026-08-05, `419b495`): REQUEST CHANGES, 5/12. All four v1 Criticals closed. One new
  Critical: the enumeration rewrite silently skipped unparseable records, so a malformed
  REQUEST CHANGES was masked by a sibling APPROVE, a fail-open the old gate caught.
- v3 (2026-08-05, `744edbe`): REQUEST CHANGES, 8/12. No Critical. The v2 Critical closed
  for both demonstrated shapes; four Importants remained, all in the tripwire's
  line-matching normalization plus a `-name '*.md'` fail-open.
- v4 (2026-08-05, `0316b7e`): **APPROVE WITH COMMENTS, 11/12.** Tripwire re-keyed on
  parseability, which removed the whole evasion class; name filter dropped. All three
  stated guarantees verified independently, plus the tier floor. Two fail-closed
  Importants remain (untracked junk such as `.DS_Store` blocks every merge; the
  records-only invariant is undocumented) and are not blocking. Threat model
  renegotiated and accepted, with two amendments to the guarantee set: add the tier
  floor, and log that the gate cannot detect a required reviewer that never ran.
