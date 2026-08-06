---
artifact: gate-ignore-untracked-evals
type: code
branch: fix/gate-ignore-untracked-evals
reviewed_commit: c4de1b6
date: 2026-08-06
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 7/12
---

## Scope reviewed

`c4de1b6`, the second state of this branch (`cd5a985` -> `c4de1b6`), closing the Critical
and the two Importants of v1. Verified myself: `git rev-parse --short HEAD` == `c4de1b6`,
tree clean, `md5 -q bin/merge-gate.sh` == `md5 -q ~/bin/merge-gate.sh` == `1e6b52b2`, so the
gate that `/merge` runs is the gate I read. Files: `bin/merge-gate.sh` (+2 guards, `-z`
enumeration, `-r` check), `docs/eval-framework.md` (wording), `tests/merge-gate.test.sh`
(cases 51 to 55).

`record_version` goes 1 -> 2 (the field this record already carried, and the precedent in
`docs/evals/code-fix-merge-gate-all-records.md`, which reached `record_version: 4`).

Evidence, my own fixtures re-run against `c4de1b6` at the time of writing rather than
recalled: the gate suite (71/71), single-guard mutation probes, behaviour probes, two
NUL-pipeline probes, and the suite re-run against each single-guard mutation.

## Verdict

APPROVE WITH COMMENTS. The Critical is closed in every configuration state I can construct,
and closed with the stronger of the two options: the CLI flag makes the guarantee
config-independent, and the explicit stray check makes it true by construction rather than
by inheritance. Nothing the previous version refused now passes, except the one input that
was refused BY MISTAKE. One Important remains, a testing gap on the flag, non-blocking.

## (a) Every v1 finding, closed or open

- **Critical 1 (guarantee 1 failed open under `status.showUntrackedFiles=no`): CLOSED.**
  `bin/merge-gate.sh:59` forces `--untracked-files=normal`, and `:68-75` refuses any
  untracked non-ignored file under `docs/evals` by name. Re-verified with post-cutoff
  anchored records (committed `code-x.md` APPROVE + uncommitted `design-x.md`
  REQUEST CHANGES, a new filename so no tracked file is modified) in four states: default
  config, repo-level `status.showUntrackedFiles=no`, the same via `GIT_CONFIG_*` env
  (the global-config equivalent), and untracked code outside `docs/evals`. All rc=1. The v1
  repro that gave exit 0 now refuses.
  I also spot-checked the coordinator's claim that each guard holds alone, since the
  redundancy argument rests on it. It holds for this class: with the flag removed the belt
  refuses by name, with the belt removed the flag refuses generically. The two "missing"
  mutations are indeed redundancy, with one asymmetry, see the Important below.
- **Important 2 (`git ls-files` C-quoted unusual paths): CLOSED.** `:143` is now
  `git ls-files -z docs/evals | LC_ALL=C sort -z -u` with `read -r -d ''` at `:100`.
  Verified: a `docs/evals/code-café.md` APPROVE record enumerates and passes (it appears by
  its real name in the success line), and a `docs/evals/code-résumé.md` REQUEST CHANGES
  beside an APPROVE refuses on its VERDICT, not as unparseable. Case 55 asserts on the
  MESSAGE rather than the exit code, which is the right technique for that distinction.
- **Important 3 (fix not installed): CLOSED.** `~/bin/merge-gate.sh` md5 `1e6b52b2` equals
  the repo copy, so the path `skills/merge/SKILL.md:20` names first now runs this code.
- **Nits taken and verified:** the unreadable-index-entry message (`:113-117`) no longer
  blames the frontmatter; `docs/eval-framework.md:88-89` now says "refuses merges from EVERY
  branch, because the parse check runs before branch matching"; the untracked consequence is
  no longer asserted unconditionally; the dead `2>/dev/null` on the enumeration is gone;
  `sort -z -u` also de-duplicates the three index stages of a conflicted path, which folds
  in the conflict nit.
- **Nit NOT taken (the KEPT IN SYNC marker at `:110-112` is documentation, not a
  mechanism): open, and I agree with the deferral.** Extracting `frontmatter_opens()`
  touches `bin/spec-gate.sh`, which has its own deferred fix in the ledger; doing half of it
  here would leave two partial refactors. Do both together, and prefer the helper over a
  byte-identity lint: a helper removes the divergence, a lint only reports it.

## (b) Anything the previous version refused that `c4de1b6` passes

**Exactly one input, and it is the intended fix: a record whose filename contains
non-ASCII bytes** (or `"` / `\`). `cd5a985` refused it as "frontmatter does not parse";
`c4de1b6` reads it and judges it. That is refuse -> judge, not refuse -> pass: probe C
confirms a non-ASCII REQUEST CHANGES still refuses, on its verdict.

Everything else in the diff only ADDS refusals (the flag, the stray check, the `-r` check).
Three ways this could have gone wrong, checked rather than assumed:
- **`sort -u` collapsing distinct records.** It compares whole NUL-delimited paths, and
  `LC_ALL=C` is in force twice (exported at `:22-23`, inline at `:143`), so two distinct
  paths can never compare equal. Safe.
- **The last enumerated entry being dropped.** `read -r -d ''` silently drops an
  unterminated tail (probed directly: two entries in, one seen). It is safe here only
  because `sort -z` always emits a terminating NUL, including when its own input lacks one
  (probed). Confirmed end to end: an alphabetically LAST `z-refuse.md` beside
  `a-approve.md` refuses, and a sole `zzz-refuse.md` refuses. Worth knowing before anyone
  removes the `| sort` stage.
- **The `-r` check short-circuiting.** It exits on the first unreadable entry instead of
  batching like the unparseable list. Still a refusal, so fail-closed either way.

The gitignored-junk fix from `cd5a985` is intact: a gitignored `.DS_Store` under
`docs/evals` passes even with `status.showUntrackedFiles=no` (rc=0). `--exclude-standard` is
what preserves it, and it reads the same exclude sources as `git status`, so the two guards
cannot disagree about what "ignored" means.

## (c) Does the stray check create a new fail-closed annoyance?

**No new annoyance, and one dead message.** For any untracked non-ignored file under
`docs/evals` the clean-tree check at `:59` fires FIRST, because `--untracked-files=normal`
on the CLI beats the very config the stray check exists to defeat. I could not construct a
state in which the by-name message at `:70-73` is reachable: default config prints
"uncommitted changes present", and so does `status.showUntrackedFiles=no`.

So the class people actually hit (editor temp files: `.code-x.md.swp`, `code-x.md~`, emacs
`#code-x.md#` and `.#code-x.md`, none of which are in this repo's `.gitignore`) is refused
exactly as it was before this branch, by step 2, with the same generic message. Verified in
both config states. Nothing legitimate is newly blocked, because an untracked record is
supposed to block: a record only counts once committed.

Two cheap follow-ups, both nits:
1. Move the `:64-75` block ABOVE the `:55-62` block. Then the accurate, actionable message
   wins for the `docs/evals` case and the generic one covers everything else, the new
   `docs/eval-framework.md` sentence "refused explicitly, by name" becomes observably true,
   and each guard gets exactly one observable class (see the Important).
2. Add `*~`, `*.sw[po]`, `.#*` to `.gitignore`, so an open editor buffer never blocks
   `/merge`. Pre-existing, not caused by this diff.

## Important (should fix, not blocking)

**`bin/merge-gate.sh:59`, the `--untracked-files=normal` flag is untested, and the belt does
not cover what it protects.** The redundancy is asymmetric: the stray check only looks at
`docs/evals`, so deleting the flag reopens precondition 2 ("clean working tree") for the
whole rest of the tree. Verified: with the flag reverted to plain `git status --porcelain`
and `status.showUntrackedFiles=no`, an untracked `src-new.go` beside a valid record gives
**rc=0** (uncommitted code merges), while the suite stays **71/71 green**. Removing the belt
instead also stays 71/71, but that mutation genuinely loses only redundancy.

So the answer to "one guard plus a test that pins which one" is: keep both guards, and pin
them on the two classes that separate them.
```bash
# 56. Untracked file OUTSIDE docs/evals with showUntrackedFiles=no -> refuse.
#     Only --untracked-files=normal can catch this; the docs/evals stray check cannot.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "code-x.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && git config status.showUntrackedFiles no && echo new > src-new.go ) >/dev/null 2>&1
check "refuses untracked work outside docs/evals with showUntrackedFiles=no" 1 "$d"; rm -rf "$d"
```
With nit (c)(1) applied (stray check first), cases 51 and 52 then pin the belt by message and
case 56 pins the flag, so neither guard can be deleted silently. That is the mutation
discipline `AGENTS.md` and lessons.md 2026-08-03 ask for: a guard never seen failing is false
confidence.

## Nitpicks

- `bin/merge-gate.sh:98-99`, the sentence that caused the Critical is still there verbatim,
  "Nothing is lost: an untracked non-ignored file is already refused by the clean-tree
  check". It is TRUE now, but it credits only the check whose weakness was the bug, and a
  future reader who deletes the flag will find it reassuring. Point it at both guards and
  their line numbers.
- `bin/merge-gate.sh:113-117`, the `-r` block sits between the TRIPWIRE comment and the awk
  it describes, so the comment now dangles. Move the block above the comment.
- The two ordering and hygiene nits in (c).

## Guarantees re-verified at `c4de1b6`

1. **Any non-approving record refuses**, including one with a non-ASCII filename, one that
   sorts last, and one that is untracked under a config that hides it from `git status`.
2. **A record describing moved code refuses.** Anchor logic untouched by this diff and
   exercised incidentally by my fixtures (one probe correctly refused with "code changed
   after the reviewed commit" when I committed a `.gitignore` after the record).
3. **A record the gate cannot READ refuses**, now split into two accurate reasons:
   unreadable (`:113`) and unparseable (`:118`).
4. **The model_tier floor holds**, untouched, suite-covered.

## Scores

correctness 2/2 (Critical closed and re-verified in four configuration states; the one
refuse -> judge change is the intended fix and its refusal path is pinned by message; the
NUL-pipeline and `sort -u` traps checked rather than assumed) · security 2/2 (guarantee 1 no
longer depends on client git configuration, and precondition 2 was hardened beyond what I
asked: untracked CODE can no longer hide from the gate either) · performance 2/2 (one
`ls-files` plus one `--others` walk scoped to `docs/evals`) · readability 2/2 (both guards
carry a comment that names the hole and why the flag beats the config; two comment-placement
nits, no defect) · testing 1/2 (cases 51 to 55 are RED-first, real, and 55 asserts on the
message; but the `--untracked-files=normal` flag is unpinned, and dropping it lets
uncommitted code through a merge with the suite still green, which I demonstrated) ·
conventions 2/2 (install synced and md5-verified against the repo, conventional commit that
names the reviewer's finding honestly, no dashes, RED-first cases, mutation claims
self-checked before being reported)

**total 11/12** (threshold: >=9, no zero) -> PASS

## Ceiling

12/12 needs only the Important: one 7-line fixture (case 56 above), plus the two-line comment
fix at `:98-99` if you want the file to stop pointing at the wrong guarantor. Nothing
structural remains on this branch.

## Regression note vs v1 (7/12 at `cd5a985`)

Better, 7 -> 11, and better in the way that matters: the Critical was not patched, it was
closed twice over, once by making the guarantee independent of client configuration and once
by making the claim true by construction. The coordinator reproduced the fail-open before
fixing it, which let me re-verify rather than take it on trust, and it pre-empted the two
mutation "misses" by checking each guard alone instead of reporting them as coverage. That
is the pattern the parent branch's four rounds kept missing: a claim in a comment was carried
forward untested three times, into code, into docs, and into a commit message. This round
the claim arrived with the mechanism that makes it true. The one thing still asserted rather
than pinned is the flag itself, which is the same shape one size smaller, and that is why it
is the only Important left.

## History

- v1 (2026-08-06, `cd5a985`): REQUEST CHANGES, 7/12. One Critical: enumerating tracked files
  made guarantee 1 depend on `git status` reporting untracked files, so with
  `status.showUntrackedFiles=no` an untracked REQUEST CHANGES record was invisible to both
  checks and the merge passed, where the pre-change `find` version refused. Two Importants:
  `git ls-files` C-quoted non-ASCII paths, so a valid record blocked every merge with a
  misleading reason; and `./install.sh` had not been re-run, so `/merge` still ran the
  pre-change gate. Six nits.
- v2 (2026-08-06, `c4de1b6`): **APPROVE WITH COMMENTS, 11/12.** Critical closed with two
  independent guards (CLI `--untracked-files=normal` plus an explicit refusal for untracked
  non-ignored files under `docs/evals`), verified in four configuration states; C-quoting
  closed with `-z` and `read -r -d ''`, which also removed the newline-in-filename hazard and
  the conflicted-stage duplication; install synced. Cases 51 to 55 added. One Important left:
  the flag is unpinned and the belt cannot cover what it protects, so dropping the flag lets
  uncommitted code through a merge with the suite still green (demonstrated, fixture
  supplied). The `.DS_Store` fix from v1 is intact under the new checks.
