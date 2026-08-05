---
artifact: merge-gate-all-records
type: code
branch: fix/merge-gate-all-records
reviewed_commit: 9517d2a
date: 2026-08-05
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 0, security: 0, performance: 2, readability: 1, testing: 1, conventions: 0 }
total: 4/12
verdict: REQUEST CHANGES
previous_total: none
---

## Scope reviewed

Two commits, reviewed as one logical change to the same [E] guardrail:

- `8e2c23a` all-records loop + `reviewed_commit:` anchor + reviewer descriptions
- `9517d2a` fail-closed date handling for the cutoff (`LC_ALL=C`, missing/malformed `date:` refuses)

The branch moved twice while this review ran: it was at `8e2c23a` (clean) when I
started, then a working-tree edit to `bin/merge-gate.sh` appeared mid-review, then
that edit was committed as `9517d2a`. I re-read and re-tested the final state and
anchored this record to `9517d2a` (verified: the gate file I ran every fixture
against is md5-identical to `9517d2a:bin/merge-gate.sh`). A record anchored to
`8e2c23a` would be correctly refused by the rule this branch introduces, which is
the mechanism working, and is also the first evidence for finding I6.

Verification run: gate suite 38/38, full suite 23 files green, skills-lint clean,
plus 22 hand-built fixture shapes across the old / `8e2c23a` / `9517d2a` gates and
9 mutations of the final gate.

## Verdict

REQUEST CHANGES

## Critical

- **C1 `bin/merge-gate.sh:63`** — the record enumeration `grep -rl "^branch: ${branch}\$" docs/evals/`
  cannot see a CRLF record, so a sibling REQUEST CHANGES is still masked and the
  headline claim does not hold. In a non-interactive shell `grep` resolves to BSD
  `/usr/bin/grep`, whose `$` does not match before `\r`. Fixture: LF APPROVE record +
  CRLF REQUEST CHANGES record, both carrying this branch, gate exits **0**. Every
  other parse in the script deliberately tolerates `\r`, so the tolerance is
  inconsistent exactly at the step that decides which records get checked. The same
  line interpolates the branch as a BRE (on `fix/a.b`, a record naming `fix/aXb`
  satisfies the gate, verified) and matches `branch:` lines anywhere in the file,
  body included, while verdicts are read only from frontmatter.
  Fix: enumerate through frontmatter the way `bin/spec-gate.sh:120-123` already does
  (`find docs/evals -type f -name '*.md' | sort`, then string-compare
  `frontmatter_field "$f" branch`). Note `frontmatter_field` lowercases its value, so
  lowercase the branch on the compare side or test 3's `feature/OTHER` fixture stops
  matching. `index($0,"branch:")==1` keeps `related_branch:` out, which
  `skills/second-opinion-code/SKILL.md:59` depends on (verified).

- **C2 `bin/merge-gate.sh:135`** — the anchor accepts symbolic refs, so
  `reviewed_commit: HEAD` makes it permanently vacuous. `frontmatter_field` lowercases
  the value and macOS git resolves `head^{commit}` and `main^{commit}`. Fixture:
  post-cutoff record with `reviewed_commit: HEAD` and two code commits after the
  review, gate exits **0**; same with the branch name. A moving ref can never go
  stale, and the reviewer instructions (`git rev-parse --short HEAD`) make `HEAD` the
  single likeliest wrong value to be written.
  Fix: `[[ "$reviewed" =~ ^[0-9a-f]{7,40}$ ]] ||` refuse (bash 3.2 supports `=~`),
  then keep the `^{commit}` verify, then add
  `git merge-base --is-ancestor "$reviewed" HEAD ||` refuse. Add a test expecting 1 for
  `reviewed_commit: HEAD`.

- **C3 `agents/skill-reviewer.md:38`, `agents/pm-reviewer.md:49`,
  `agents/design-reviewer.md:103`** — all three have `tools: Read, Grep, Glob, Write`
  and are told to run `git rev-parse --short HEAD` with no fallback. Only
  `agents/agent-reviewer.md:38-42` got the "ask the coordinator" clause, and the
  obligation is one-sided: nothing in `skills/`, `global/` or AGENTS.md tells any
  dispatcher to pass the sha. The two available behaviors are omit the field (merge
  blocked) or write a plausible sha, which makes the anchor certify a commit the
  reviewer never verified while the gate reports green, worse than no anchor.
  Fix: (a) same clause in all five, plus a hard prohibition, "if you were not given
  the sha and cannot run git, omit `reviewed_commit:` and say so in the body; never
  transcribe a sha you did not verify"; (b) the reciprocal duty on the dispatch side,
  the coordinator passes `git rev-parse --short HEAD` in the Task prompt of every
  scoring reviewer.

- **C4 install drift** — `~/bin/merge-gate.sh` is byte-identical to the pre-fix gate
  (md5 `d385cadcffd788f952df63c1ddf2fd98`), and `skills/merge/SKILL.md:20` invokes bare
  `merge-gate.sh`, which resolves through PATH to that stale copy. CLAUDE.md requires
  re-running `./install.sh` after editing `bin/`; it was not run, so `/merge` today
  still executes the version with both holes this branch exists to close.
  Fix: run `./install.sh`, verify `md5 ~/bin/merge-gate.sh bin/merge-gate.sh` agree,
  and consider asserting that agreement in a test so drift cannot recur silently.

## Important

- **I1 `bin/merge-gate.sh:143`** — the success line always prints an empty record name.
  After `while IFS= read -r record; do … done <<< "$records"` the final `read` hits EOF
  and leaves `record=""`. Old gate: `record: docs/evals/code-feature-x.md`; new gate:
  `record: ).` `skills/merge/SKILL.md:56` documents the old output. The operator loses
  the "which record satisfied the gate" signal exactly when there can be several.
  Fix: accumulate `checked="${checked}${record} "` in the loop, print
  `records checked: ${checked% }` plus a count, and update SKILL.md:56.

- **I2 `tests/merge-gate.test.sh:262-268` (case 18)** passes for the wrong reason.
  Mutation: delete the whole `git rev-parse --verify` block, suite stays 38/38, because
  `git diff --quiet deadbeef… HEAD` errors and the `if !` treats that as changed. Same
  for dropping `^{commit}`, 38/38, even though `^{commit}` is load-bearing
  (`git rev-parse --verify --quiet <40-hex>` returns 0 for a nonexistent full sha,
  verified). CLAUDE.md: "A guard never seen failing is false confidence."
  Fix: assert the message in case 18, and add a case using a blob/tree sha that only
  `^{commit}` refuses.

- **I3 `tests/merge-gate.test.sh:196-268`** — no case covers the anchor on a SECOND
  record, so the very bug class this commit fixes can regress inside the new
  sub-check. Mutation: run the anchor for only the first record, suite stays 38/38.
  Fix: two post-cutoff records, first anchor valid and second stale, expect 1, plus
  the name-swapped mirror as cases 8/9 do for verdicts.

- **I4 `bin/spec-gate.sh:132-137`** — the sibling [E] gate still picks one "newest"
  record with the same `-gt` tie-break, so the invariant AGENTS.md:156-160 now states
  holds only on the merge path. Its `find | sort` enumeration is deterministic, but
  determinism is not correctness: an equal-timestamped REQUEST CHANGES sorting first is
  still masked. Two [E] gates with opposite rules on the same records invite the next
  reader to resolve the difference in the loose direction.
  Fix: port the all-records loop (its `covers_id` enumeration is already the right
  shape), and until then note the divergence in AGENTS.md. Also `bin/spec-gate.sh:61`
  still says "Kept in sync with merge-gate.sh's verdict parsing" while merge-gate no
  longer has a `frontmatter_verdict` function; the behavior is equivalent, the
  cross-reference points at deleted code.

- **I5 `bin/merge-gate.sh:104`** — a record with two `verdict:` lines passes when the
  approval comes first (verified: APPROVE then REQUEST CHANGES exits 0; the reverse
  refuses), because the awk exits on the first hit. Every reviewer is told to write
  exactly one verdict line and the gate cannot tell. Pre-existing, but this commit is
  what makes the frontmatter verdict load-bearing across many records.
  Fix: count matches and refuse on more than one; a duplicated field is a malformed
  record, not a value to guess at.

- **I6 design, `bin/merge-gate.sh:137`** — the anchor diffs the whole non-evals tree,
  so any code commit stales EVERY post-cutoff record on the branch including reviewers
  whose artifact was untouched. On a five-artifact branch one README typo forces
  re-running five reviewers, and that cost pushes toward the hand-edit the system
  forbids. This review is the first instance: a `bin/` commit landed mid-review.
  Fix: scope the diff to what the record covers (a `reviewed_paths:` field), or accept
  it explicitly with a documented "re-run only the reviewers whose paths moved" rule.
  Decide before the next multi-artifact branch.

## Nitpicks

- **N1 `tests/merge-gate.test.sh:305`** — the cutoff is pinned from above only.
  Mutation `RC_CUTOFF=2026-08-04` stays green; `2026-08-06` fails 3. Add a
  `date: 2026-08-04` case expecting exempt.
- **N2 `bin/merge-gate.sh:19-22`** — `LC_ALL=C` is not pinned by any test, and with the
  ISO `case` restricting input to digits and hyphens no locale I tested (C,
  en_US.UTF-8, de_AT.UTF-8) reverses the collation. Keep it, but the comment should
  read as defensive rather than imply a known reversal.
- **N3 `bin/merge-gate.sh:63-146`** — two sequential loops over `$records`; the
  freshness backstop folds into the first pass.
- **N4 `bin/merge-gate.sh:3-12`** — the header docblock still says precondition 3 is
  "a review record exists for this branch", the singular wording AGENTS.md just
  replaced.

## Scores

correctness 0/2 (C1, C2) · security 0/2 (C1, C2, C4 leave the guardrail bypassable
and, in C4's case, not actually deployed) · performance 2/2 · readability 1/2 (I1's
misleading output, N3, N4) · testing 1/2 (real RED-first work, but three mutations of
the new code survive the suite) · conventions 0/2 (C4 violates the explicit
`./install.sh` rule; I2/I3 violate the mutation-proof rule in CLAUDE.md and
lessons.md 2026-08-03)

**total 4/12** (threshold: >=9, no zero)

## Ceiling

12/12 is reachable. Nothing about a bash guardrail structurally caps a criterion
here: correctness and security are provable by fixture, the testing dimension is
exactly what mutation proves, and conventions are satisfiable by running the
installer. The gap is real work, not a measurement limit.

## What's good

- The two questions I was asked to settle both settle in the change's favor.
  `while … done <<< "$var"` runs in the current shell, `exit 1` inside it terminates
  the script, and `set -uo pipefail` without `-e` does not change that (verified on
  bash 3.2 with a spaces-in-filename fixture refusing from inside the loop). And
  monotonicity holds: across 22 fixture shapes on old / `8e2c23a` / `9517d2a`, no
  input the old gate refused is passed by either new version. No enforcement
  regression found.
- Fail-closed on the exotic path: a filename containing a newline splits into
  unreadable paths and refuses rather than being skipped. The practical hazard in
  that same enumeration is CRLF, and that one fails open (C1).
- The anchor's git plumbing is right: `cd "$(git rev-parse --show-toplevel)"` makes
  `-- . ':(exclude)docs/evals'` cwd-independent (verified from a subdirectory),
  mode-only changes are caught, deletions and submodule pointer moves are tree diffs
  so they are caught, `git diff` errors land in the refuse branch, and untracked or
  staged work is covered by the clean-tree check above rather than duplicated here.
- The date hardening in `9517d2a` is the right shape: it closes both omission
  bypasses by requiring a well-formed ISO date rather than by patching the
  comparison, and it updated the fixture helpers (`named_record` injects a date only
  when the caller supplied none) so the pre-existing cases still test what they claim.
- Case 17, an evals-only commit must not invalidate the anchor, is the case most
  builders would forget and the one that makes the mechanism usable; mutation M5
  confirms it is load-bearing.
- `[[ -n "$rec_date" && ! "$rec_date" < "$RC_CUTOFF" ]]` parses as intended on bash
  3.2, and the boundary is inclusive as documented.
- AGENTS.md was changed WITH the mechanism and states the operational cost out loud
  instead of hiding it, which is what made I6 findable at all.

## Provenance note

`model_tier: strong` is declared, not `strongest`: this ran on Opus 5 (opus class,
comfortably above the strong floor), but I did not resolve the live model lineup, and
per lessons.md 2026-07-27 "strongest" is a claim about the currently-available top
tier and must not be asserted from memory.

## History

- v1 (2026-08-05, `9517d2a`): REQUEST CHANGES, 4/12. First review of this branch, no
  previous record exists, so there is no regression comparison.
