---
artifact: merge-gate-all-records
type: code
branch: fix/merge-gate-all-records
reviewed_commit: 419b495
date: 2026-08-05
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 0, security: 0, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 5/12
verdict: REQUEST CHANGES
previous_total: 4/12
---

## Scope reviewed

`419b495` on top of `9517d2a` and `8e2c23a`, reviewed as one logical change to the
`/merge` [E] guardrail. The dispatcher supplied `419b495` and I verified it myself
rather than trusting it: `git rev-parse 419b495` equals `git rev-parse HEAD`, tree
clean. That is the reciprocal duty this change adds at AGENTS.md:163-168 working as
designed on its first real use.

The v1 record was committed inside `419b495`. I verified it went in byte-identical
(md5 `21362ffc…`, verdict and scores intact), so no one edited a reviewer's record to
move a gate. This file overwrites it, which is the documented flow: one record per
artifact, git history is the archive.

Evidence base: the 50-assertion gate suite (control 50/50), skills-lint clean, my own
fixtures for every edge the coordinator asked about, and 7 mutations of the new gate.

## Verdict

REQUEST CHANGES

One Critical outstanding. It is narrower than v1's and was introduced by the fix for
v1's C1 rather than being an original hole, but it is a fail-open in the exact
property this branch exists to guarantee, and the OLD gate caught it.

## Verified closed

- **C1 enumeration** (`bin/merge-gate.sh:61-78`). All four sub-cases fixed and
  independently reproduced: LF APPROVE + CRLF REQUEST CHANGES now refuses (was 0); a
  CRLF-only APPROVE is still FOUND and passes, so the fix did not pass case 24 by
  making CRLF records unreadable, and case 25 pins that, which is the right instinct;
  on `fix/a.b` a record naming `fix/aXb` refuses (was 0); a `branch:` line in the body
  no longer enrols (was 1). The per-machine-grep note in the comment is a real addition
  and correct: my own first run hid the bug because ugrep 7.5.0 was on the interactive
  PATH while the gate resolved `/usr/bin/grep`.
- **C2 anchor** (`bin/merge-gate.sh:183-206`). Every edge behaves: uppercase hex passes
  (frontmatter_field lowercases first), 7-char passes, 6-char refuses, a TREE sha
  refuses via `^{commit}`, `HEAD` and a branch name refuse on the hex case, a
  non-ancestor refuses. `$branch` can never be empty (unborn and detached HEAD both
  yield the literal `HEAD`), so there is no empty-branch enrolment hole. An ambiguous
  short prefix is fail-closed by construction (`rev-parse --verify --quiet` returns
  non-zero on "short SHA1 is ambiguous"); I could not manufacture a 4-char collision in
  400 commits, so that one is reasoned, not demonstrated.
- **C3 the one-sided contract**. All four no-Bash reviewers
  (`agents/design-reviewer.md:103`, `pm-reviewer.md:49`, `skill-reviewer.md:38`,
  `agent-reviewer.md:41`) now state they have no shell, that the dispatcher supplies the
  sha, that they must ASK if it was not given, and that they must never transcribe,
  guess or copy one, with omission named as the safe failure.
  `agents/code-reviewer.md:142` keeps its own resolution and is told the others cannot.
  AGENTS.md:163-168 carries the reciprocal `[I]` duty. The contract is two-sided now.
- **C4 install drift**. `md5 ~/bin/merge-gate.sh bin/merge-gate.sh` both
  `7b8b244a6aa830944b4e8c6181834e08`. The fix is live on the path `/merge` uses.
- **I2** case 18 asserts the message; **I3** closed by case 32 (second-record stale
  anchor); **I5** duplicate `verdict:` refuses (case 33); **N1** closed by case 34 (day
  before the cutoff still exempt); **N4** the header docblock states the plural rule.
- Both mutations I named are now caught, independently reproduced: deleting the
  rev-parse block and gating the anchor on the first record only both fail the suite.

## Critical (must fix before merge)

- **`bin/merge-gate.sh:70-75` — the rewritten enumeration SKIPS what it cannot parse, so
  a malformed refusal is masked by a sibling approval. Fail-open regression: the old
  gate refused these, `419b495` passes them.** Two demonstrated shapes, one root cause:
  1. A record whose frontmatter does not open the file (a title line above the `---`,
     the exact shape case 6g exists for because it happened in this repo before) with
     `branch: feature/x` + `verdict: REQUEST CHANGES`, alongside a valid APPROVE:
     old **1**, `9517d2a` **1**, `419b495` **0**.
  2. A record with two `branch:` lines, decoy first (`feature/other`), ours second,
     carrying REQUEST CHANGES, alongside a valid APPROVE: old **1**, `419b495` **0**
     (first-wins in `frontmatter_field`).
  Case 6g still passes only because its malformed record is the ONLY one, so the gate
  refuses via "no record"; it no longer tests what its comment claims.
  Root cause: enumeration cannot distinguish "not a record for this branch" from "a file
  that looks like one and failed to parse". Silent skipping is fail-open in a masking
  gate. Fix, one mechanism for both, keeping frontmatter as the only thing that can
  APPROVE:
  ```bash
  # Tripwire: a file that names this branch but did NOT enrol through frontmatter is a
  # record that failed to parse, not a record that is absent. Skipping it would let a
  # malformed refusal be masked by a sibling approval, so refuse and name the file.
  # grep -F is safe here precisely because this scan can only ever REFUSE: its quirks
  # (CRLF, body matches) make the gate stricter or equal, never looser.
  while IFS= read -r r; do
    [[ -n "$r" ]] || continue
    case $'\n'"$records"$'\n' in *$'\n'"$r"$'\n'*) continue ;; esac
    echo "merge-gate: REFUSED, $r names 'branch: $branch' but did not parse as a" >&2
    echo "record for it (frontmatter must open the file, exactly one 'branch:' line)." >&2
    exit 1
  done < <(grep -rlF "branch: ${branch}" docs/evals 2>/dev/null || true)
  ```
  Add both shapes RED-first, and give case 6g a valid APPROVE sibling so it tests the
  skip rather than the absence.

## Important (should fix)

- **`tests/merge-gate.test.sh` case 31 passes for the wrong reason**, the same class
  fixed in case 18. Removing `merge-base --is-ancestor` leaves the fixture refusing, via
  the tree diff, because the side commit adds `o.txt`. Verified: with the check removed
  it still prints "REFUSED, code changed after the reviewed commit". The fixture that
  isolates the check is a non-ancestor with an IDENTICAL non-evals tree, which I built
  and confirmed goes GREEN against the mutant:
  ```bash
  ( cd "$d" && git branch side HEAD && git checkout -q side \
    && git commit -q --amend -m "same tree, different sha" && git checkout -q feature/x )
  side="$( cd "$d" && git rev-parse side )"   # tree-identical, not an ancestor
  ```
  With that anchor the full gate refuses on "is not an ancestor of HEAD". Assert the
  message too.
- **`bin/merge-gate.sh:70-75` — enumeration equality is only half pinned.** Mutation
  M-a, `==` to `== *"$branch_lc"*`, keeps the suite at 50/50: case 26 covers regex
  metacharacters, nothing covers a superstring. Fix: a record naming
  `feature/x-extended` while on `feature/x`, expecting refuse.
- **`bin/merge-gate.sh:107-119` — the duplicate-field check covers `verdict:` only, and
  the other first-wins fields are live bypasses of the same shape.** Verified on
  `419b495`: two `date:` lines with a pre-cutoff value first exempts the record from the
  anchor entirely (exit 0); two `model_tier:` lines with `strong` first bypasses the
  tier floor (exit 0). Generalise instead of adding one-offs, which also replaces the
  bespoke `vcount` block:
  ```bash
  dup="$(awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    match($0, /^[A-Za-z_][A-Za-z0-9_]*:/) { k=substr($0,1,RLENGTH-1); if (++c[k]==2) print k }
  ' "$record")"
  [[ -z "$dup" ]] || { echo "merge-gate: REFUSED, duplicate frontmatter field(s) in $record: $dup" >&2; exit 1; }
  ```
  This also closes shape 2 of the Critical at the field level.
- **`skills/merge/SKILL.md:56` still documents the old success line**
  (`record: code-feature-usr-012-timer.md`); the gate now prints `N record(s) checked: …`.
  The gate half of I1 is fixed and correct, the doc half is not, and this is the line an
  operator reads to know what a pass looks like. Nothing asserts the success text either
  (`check()` discards stdout), so mutating the listing away leaves the suite green.
- **A symlinked record is invisible to enumeration** (`-type f` does not match
  `-type l`), so a symlinked REQUEST CHANGES record is masked by a sibling approval:
  old **0**, new **0**. Pre-existing, not a regression, consistent with
  `bin/spec-gate.sh`, but it is the same masking class as the Critical and costs one
  edit: `find docs/evals \( -type f -o -type l \) -name '*.md'`. The tripwire above
  would also catch it.
- **`bin/spec-gate.sh` deferral: defensible, and I would keep it out of this commit.**
  In order of weight: the AGENTS.md `[E]` bullet is scoped to `/merge`
  (`merge-gate.sh`) at line 156, so nothing is overstated; spec-gate's enrolment via
  `covers_id` is already the correct frontmatter-and-string-equality shape, so only the
  selection is wrong and the fix is small; and bundling it would mix two logical changes
  against one-change-per-commit while denying it its own RED-first cases. One condition:
  the deferral currently lives only in a commit body, and a commit message is not a
  backlog. Add an unchecked item to `.claude/tasks/todo.md` naming spec-gate's
  one-record selection, or it gets found the way this one was.

## Nitpicks (optional)

- Recursion into `docs/evals/` subdirectories is unpinned: mutating to `-maxdepth 1` is
  not caught (no subdirectory fixture). Behaviour matches the old gate, so nothing is
  broken, but an archive convention under `docs/evals/` would silently start blocking
  merges. Pin the intent either way.
- The 7-char floor is a policy bound, not a safety one: git resolves a 6-char prefix
  here. One word in the comment stops someone hardening it as load-bearing.
- Enumeration spawns one awk per `.md` under `docs/evals/` (20 files today). Right trade
  for correctness; if that directory reaches the hundreds, read all fields for a record
  in one awk pass instead of one pass per field.

## Scores

correctness 0/2 (the enumeration rewrite reintroduces fail-open masking, and the old
gate caught it) · security 0/2 (same finding; a bypass of the one property this [E]
guardrail promises) · performance 2/2 · readability 1/2 (clear, well-motivated
comments, but the silent-skip behaviour behind the Critical is not visible from
reading, the duplicate check is a one-off where a general one belongs, and SKILL.md
drifted) · testing 1/2 (50 assertions, case 25's anti-cheat and cases 32/34 are real
work, but case 31 passes for the wrong reason, M-a survives, and the success line is
unasserted) · conventions 1/2 (`./install.sh` run and md5-verified, lint clean, two
named mutations proven caught; against that, case 31 is a coverage claim not proven by
mutation, the repeat offense in lessons.md 2026-08-03, and the deferral is not in the
backlog)

**total 5/12** (threshold: >=9, no zero)

## Ceiling

12/12 remains reachable; nothing here structurally caps a criterion.

## Regression note vs v1 (4/12 at `9517d2a`)

Better, and by more than the total suggests. Three of four Criticals are closed with
evidence, every Important but one is closed, and the anchor is genuinely tight now
(hex-only, peeled, ancestor-checked). The total moved 4 -> 5 only because a single
Critical zeroes two dimensions worth four points and one is outstanding. The character
of the remaining Critical also changed: v1's was an original hole that ordinary
cross-platform tooling would trigger; v2's is narrower, needs an already-malformed
record, and was introduced by the fix for v1's. What did not improve is the class of
defect: silent skipping in enumeration, twice, from opposite directions.

## Provenance note

`model_tier: strong` is declared, not `strongest`: this ran on Opus 5 (opus class,
above the strong floor), but I did not resolve the live model lineup, and per
lessons.md 2026-07-27 "strongest" is a claim about the currently-available top tier and
must not be asserted from memory.

## History

- v1 (2026-08-05, `9517d2a`): REQUEST CHANGES, 4/12. Four Criticals: enumeration blind
  to CRLF and treating the branch as a regex; `reviewed_commit: HEAD` a permanent
  bypass; the anchor contract one-sided across four no-Bash reviewers; the fix not
  installed, so `/merge` still ran the vulnerable gate. Six Importants.
- v2 (2026-08-05, `419b495`): REQUEST CHANGES, 5/12. All four v1 Criticals verified
  closed. One new Critical: the enumeration rewrite silently skips unparseable records,
  so a malformed REQUEST CHANGES is masked by a sibling APPROVE, a fail-open the old
  gate caught. Five Importants, of which case 31's wrong-reason pass and the
  duplicate-field generalisation are the substantive ones. spec-gate deferral judged
  defensible, conditional on it entering the backlog.
