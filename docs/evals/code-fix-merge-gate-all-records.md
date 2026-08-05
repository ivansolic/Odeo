---
artifact: merge-gate-all-records
type: code
branch: fix/merge-gate-all-records
reviewed_commit: 744edbe
date: 2026-08-05
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 3
scores: { correctness: 1, security: 1, performance: 2, readability: 1, testing: 1, conventions: 2 }
total: 8/12
verdict: REQUEST CHANGES
previous_total: 5/12
---

## Scope reviewed

`744edbe` on top of `419b495`, `9517d2a` and `8e2c23a`, one logical change to the
`/merge` [E] guardrail. Dispatcher supplied `744edbe`; verified myself,
`git rev-parse 744edbe` == `git rev-parse HEAD`, tree clean, `~/bin/merge-gate.sh`
md5-matches the repo (`8d5edf2a…`). The v2 record was committed inside `744edbe`
unaltered (verdict, total, version and the Critical's text intact).

Evidence: the 58-assertion suite (control 58/58), plus 20 of my own fixtures and 3
mutations. My first mutation probe was itself broken (relative gate path inside the
fixture repos, rc=127); I caught it and re-ran with absolute paths, and one of the
three "gaps" it reported dissolved once the probe worked. Noted because the same
failure hit the coordinator this round.

## Verdict

REQUEST CHANGES, and this is the narrow one. No Critical. Three mechanical edits below
take it to APPROVE; nothing here needs a redesign.

## Verified closed

- **The v2 Critical is closed for both demonstrated shapes.** Malformed frontmatter
  (title line above `---`) carrying a refusal alongside a valid APPROVE now refuses
  (was 0); two `branch:` lines with a decoy first now refuses (was 0). The tripwire's
  placement is right: it fires only when the frontmatter branch is EMPTY, so a record
  that parsed and names another branch is still legitimately skipped and its body still
  ignored.
- **No false positive on any path asked about.** Verified individually: a record for
  another branch whose body names ours passes (case 27's property preserved); a record
  with no branch field and no mention passes; `docs/evals` absent refuses with the
  correct "no review record" message, not a tripwire message; a dangling symlink is
  ignored without error (awk's open failure is swallowed and `nbranch` falls back to 0);
  a malformed second-opinion record using `related_branch:` passes, which
  `skills/second-opinion-code/SKILL.md:59` depends on. One false-positive path does
  exist but is not in that list; see Important 3.
- **Generic dup-key check** catches duplicated `branch`, `date`, `verdict`,
  `model_tier` and `reviewed_commit` (verified each). Replacing the bespoke `vcount`
  with one generic check was the right call.
- **`-type l`** closes the symlinked-record hole; **`skills/merge/SKILL.md:56`** now
  matches the gate's real output exactly.
- **My (c) items are all covered**: case 40 is the tree-identical non-ancestor fixture I
  handed over (case 31 refused via the tree diff, so the ancestor check was unpinned);
  case 41 pins branch equality against substring; case 42 asserts the success line's
  content.
- **spec-gate deferral condition met**: `.claude/tasks/todo.md:243` carries it as an
  unchecked item, including the `bin/spec-gate.sh:61` stale sync note. The judgment
  stands: defensible deferral, not a Critical.
- One honest non-finding: deleting the tripwire's `sub(/\r$/,"",line)` leaves the suite
  green, but the mutant is behaviourally EQUIVALENT, because the trailing-whitespace
  trim already removes `\r` (`[[:space:]]` includes CR). CR-tolerance is delivered
  twice over. Not a test gap, and I am recording it so it is not mistaken for one.

## Important (should fix)

1. **`bin/merge-gate.sh:74-76` and `:108` — the tripwire compares the whole LINE
   literally, so an internal-whitespace variant evades it and the v2 Critical shape
   returns.** Verified: malformed frontmatter + `branch:  feature/x` (two spaces) or
   `branch:\tfeature/x` (tab) carrying REQUEST CHANGES, alongside a valid APPROVE,
   exits **0**. Not a regression (the old grep required a single space too), but the
   guard's stated coverage ("a record the gate cannot read must not be skipped") is
   wider than the mechanism, which is the lessons.md 2026-08-03 pattern one level down.
   Fix: compare the PARSED value the way `frontmatter_field` does, not the literal line,
   which kills every whitespace variant at once:
   ```awk
   { line=$0; sub(/\r$/,"",line); sub(/^[[:space:]]+/,"",line)
     if (index(tolower(line), "branch:") == 1) {
       v=substr(line, 8); sub(/^[[:space:]]+/,"",v); sub(/[[:space:]]+$/,"",v)
       if (tolower(v) == want) { found=1; exit } } }
   ```
   with `want="$branch_lc"`. Stronger alternative worth considering: fire the tripwire on
   "the frontmatter itself does not parse" rather than on a branch-line match at all.
   Then no spacing, casing or fencing subtlety can evade it, and Important 3 disappears
   too. Cost: an unrelated broken record blocks every branch, which is arguably correct
   since it is broken.
2. **`bin/merge-gate.sh:108` — `-name '*.md'` makes a non-`.md` refusing record
   invisible, and this one IS a fail-open regression.** A record saved as
   `docs/evals/z-refuse.txt` or `.markdown` with `verdict: REQUEST CHANGES` is masked by
   a sibling APPROVE: old **1** (the old `grep -rl docs/evals/` had no name filter),
   new **0**. Graded Important rather than Critical on plausibility, not on kind: it is
   the same masking class, but nothing in the system produces a non-`.md` record, every
   reviewer is instructed to write `.md`, and all 20 existing records are `.md`. Fix:
   drop the name filter from the tripwire scan, which is safe precisely because that
   scan can only ever REFUSE: `find docs/evals \( -type f -o -type l \) 2>/dev/null | sort`.
3. **`bin/merge-gate.sh:96-101` — one false-positive path, with a misleading message.**
   A record with no `branch:` field at all that quotes an exact `branch: <this branch>`
   line anywhere, including inside a fenced code block, becomes a suspect and refuses
   the merge (verified). PM and design records have no branch field, so they are exactly
   the files that reach the tripwire. The direction is fail-closed, so it is not a
   security hole, but the message says "its frontmatter does not parse" when in fact the
   frontmatter parsed fine and simply has no `branch:` field, which sends the operator
   hunting for the wrong defect on the strictest gate in the repo. Fix: distinguish the
   two conditions in the message, or adopt the "frontmatter does not parse" trigger from
   Important 1, which removes the path entirely.
4. **Two live mutations survive the 58-assertion suite**, both in the tripwire's
   normalization, both verified live before reporting (each flips a real fixture from
   refuse to pass):
   - dropping `lc=tolower(line)`: a `Branch: feature/x` malformed refuser goes 1 -> 0,
     suite stays 58/58.
   - dropping the leading/trailing whitespace trims: an indented `  branch: feature/x`
     malformed refuser goes 1 -> 0, suite stays 58/58.
   The comment claims exact-line, CR-tolerant matching; the case and indent tolerance
   are real but unpinned. Fix: one fixture each, or fold them in when Important 1 lands
   and pin the parsed-value comparison instead.

## Nitpicks (optional)

- `bin/merge-gate.sh:100` — `printf '  %s\n' $suspects` is unquoted, so a suspect path
  with spaces splits across lines and a `*` globs. Diagnostic path only, after the
  decision. Use a `while read` loop over `$suspects`.
- `model_waiver` is the sixth field the gate reads and is absent from the dup-key list.
  It is genuinely safe (to loosen anything you would need `human` to win, which a single
  line already does), but adding it costs nothing and removes the need for anyone to
  re-derive that argument.
- The dup-key awk calls `split("branch date verdict …", k, " ")` inside the per-key loop,
  so it re-splits five times per line. Hoist it to `BEGIN`.
- Enumeration now runs two awk passes per file plus five per enrolled record. Fine at 20
  records; if `docs/evals/` reaches the hundreds, read all fields in one pass.

## Scores

correctness 1/2 (one fail-open regression remains, non-`.md` records, plus the
whitespace evasion of the new tripwire; no Critical) · security 1/2 (same two narrow
masking paths on the guardrail whose whole job is to prevent masking) · performance 2/2
· readability 1/2 (the tripwire's rationale comments are genuinely good, but its message
misdiagnoses the case it most often fires on, and the unquoted `printf` and re-split awk
are sloppy edges) · testing 1/2 (58 assertions, cases 35-42 all real and well-aimed, six
guards mutation-proven one at a time, and they caught their own broken harness, which is
the rule working; against that, two live mutations still survive and the two masking
shapes above have no fixtures) · conventions 2/2 (install synced and md5-verified, lint
clean, spec-gate deferral in the ledger per the stated condition, mutation discipline
applied AND self-audited with the broken probe reported rather than hidden; the
claim-wider-than-mechanism issue is scored under correctness and testing, not
double-counted here)

**total 8/12** (threshold: >=9, no zero)

## Ceiling

12/12 remains reachable. The three edits that close it: parsed-value comparison in the
tripwire (Important 1), drop `-name '*.md'` from the tripwire scan (Important 2), and a
fixture each for case-folding and indent (Important 4). Important 3 comes free with 1.

## Regression note vs v2 (5/12 at `419b495`)

Better, and the trajectory is now clearly convergent: 4 -> 5 -> 8, and for the first
time there is no Critical. The v2 Critical is closed for both shapes I demonstrated, the
dup-key generalisation closed two bypasses I found, and the three test gaps I named are
all covered by real fixtures rather than by shapes that pass for the wrong reason. Two
things to note without softening them. First, the defect class persisted for a third
round in a narrower form: enumeration still has ways to skip a record silently
(whitespace variant, non-`.md`), which is why correctness and security are 1 rather than
2. Second, the good sign is that this round's residue was found only by attacking the
new guard's normalization, not by attacking the design, and the coordinator's own
self-audit caught a broken probe before reporting it, which is exactly the discipline
lessons.md asks for.

## Provenance note

`model_tier: strong` is declared, not `strongest`: this ran on Opus 5 (opus class, above
the strong floor), but I did not resolve the live model lineup, and per lessons.md
2026-07-27 "strongest" is a claim about the currently-available top tier and must not be
asserted from memory.

## History

- v1 (2026-08-05, `9517d2a`): REQUEST CHANGES, 4/12. Four Criticals: enumeration blind
  to CRLF and treating the branch as a regex; `reviewed_commit: HEAD` a permanent
  bypass; the anchor contract one-sided across four no-Bash reviewers; the fix not
  installed, so `/merge` still ran the vulnerable gate. Six Importants.
- v2 (2026-08-05, `419b495`): REQUEST CHANGES, 5/12. All four v1 Criticals closed. One
  new Critical: the enumeration rewrite silently skipped unparseable records, so a
  malformed REQUEST CHANGES was masked by a sibling APPROVE, a fail-open the old gate
  caught. Five Importants. spec-gate deferral judged defensible, conditional on it
  entering the backlog.
- v3 (2026-08-05, `744edbe`): REQUEST CHANGES, 8/12. No Critical. The v2 Critical closed
  for both demonstrated shapes; dup-key generalisation and `-type l` closed the
  bypasses found alongside it; the three test gaps covered. Four Importants remain, all
  mechanical: the tripwire evades on internal whitespace, non-`.md` records are still
  masked (a regression), one false-positive path with a misleading message, and two live
  mutations survive the suite. Deferral condition met at
  `.claude/tasks/todo.md:243`.
