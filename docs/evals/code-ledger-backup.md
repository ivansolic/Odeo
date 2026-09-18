---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ skills/retro/SKILL.md, docs/system-map.md, docs/plan-format.md, AGENTS.md, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 0125901
artifact_version: 7
date: 2026-09-18
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 0, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 6/12
verdict: REQUEST CHANGES
previous_total: 8/12
---

## Artifact

Commit `0125901` on `feature/windows-powershell-entry`, clean tree. One commit since round 6,
which applied all four round-6 Importants. Suite re-run here: **114 assertions green in 21s**.
`docs-claims-check.sh --assertions` green (24 executables, 33 suites, 24 programs with their own
suite, 1027 assertions, matching README). `skills-lint` green. No plan exists in `docs/plans/`,
so the binding statements remain the program header, the guard comments, `/retro`'s exit table
and the commit bodies.

## Round 6's four findings, checked against the tree

| round-6 finding | state at HEAD |
|---|---|
| I1 environment isolation (`GIT_INDEX_FILE`) | **closed for the eight variables listed.** Case 34 measured green: index byte-identical, backup still exit 0, `git status` still works. 34b pins that an inherited `GIT_DIR` does not choose the project. See I1 below for what the list still misses, and I2 for a route back into the same harm |
| I2 containment on the `git` arm | **partially closed.** The bare-repo-by-plain-path shape is refused (case 35). Three other spellings of the same shape still pass at exit 0, measured: see C1 |
| I3 header rows 3 and 4 vs `/retro` | **partially closed.** Row 3 is right. Row 4 gained "a copy that failed" and the COPY/MOVES distinction, and still omits the unwritable-destination and internal-failure sites round 6 listed by line number. See I3 |
| I4 the refusal names the marker | **closed.** Case 36 green, and every refusal I triggered in this round printed "The repository that contains it: ..." with the correct ancestor |

The canary claim in the commit body holds up on inspection: cases 34, 34b, 35 and 36 each assert
an outcome (index hash, which ledger landed, which branch exists, which path is named), not a
message.

## Findings

### Critical

**C1. The containment invariant on the `git` arm recognises ONE spelling of a local remote, and
three others put the ledger inside the project's own repository at exit 0 with the stamp
written.** `bin/ledger-backup.sh:382-388`. The guard is `[ -d "$url" ]` plus a walk from the
remote's PARENT. Measured on the shipped script at HEAD, each from a clean project:

```
(a) remote = file://$PROJECT/inside-bare.git        -> exit 0, "refreshed", stamp WRITTEN
      `[ -d "file:///..." ]` is false, so the guard never runs.
      git status in the project:  ?? inside-bare.git/     check-ignore: NOT IGNORED
      This is round-6 I2 verbatim, through the spelling round 6 named in the fix instruction.

(b) remote = a SIBLING linked worktree of the project ($PROJ/../wt)   -> exit 0, stamp WRITTEN
      git -C $PROJECT show internal-files:internal-not-in-git/lessons.md
        -> SECRET lesson          <- the ledger is now a BRANCH in the project's own repo

(c) remote = the project directory itself (a second remote name)      -> exit 0, stamp WRITTEN
      git -C $PROJECT rev-parse internal-files -> 6f01a1b
      git -C $PROJECT show internal-files:internal-not-in-git/lessons.md -> SECRET lesson
```

(b) and (c) are worse than what round 6 scored. There the ledger sat as loose objects waiting for
a `git add -A`; here the run itself commits it into the project's object store under a real ref,
where every clone, mirror, `fsck` and `push --all` carries it, and `--check` then reports up to
date. Stated precisely, because this project's own rule is to claim only what was verified: I did
NOT observe the ledger reaching a public remote. Odeo's pre-push hook and `publish-snapshot.sh`
(`git archive` of tracked HEAD) are two later defences. The finding is the program's own headline
promise, "a backup may not land inside a git repository" (`:196-201`), failing open while
reporting success, which is the one outcome this file's first 17 lines say it exists to prevent.

The design choice in the commit body is where the gap is: "asking about the target itself would
refuse every legitimate local remote" is true only of the BARE marker shape. The `.git` marker
shape on the target is never legitimate, and the file already knows this: its own comment at
`:205-208` records that a previous round "asking git about the destination's PARENT ... reopened
a nested repo, a SIBLING WORKTREE and a destination that is itself a symlink". The `dir` arm
learned that and moved to the landing directory itself; the `git` arm has just reintroduced it.

Fix, measured here rather than proposed. Replace `:382-388` with:

```sh
url_path="$url"
case "$url_path" in file://*) url_path="${url_path#file://}"; url_path="${url_path#localhost}" ;; esac
case "$url_path" in /*) ;; *) [ -d "$PROJECT_DIR/$url_path" ] && url_path="$PROJECT_DIR/$url_path" ;; esac
if [ -d "$url_path" ]; then
  url_real="$(cd "$url_path" 2>/dev/null && pwd -P)" \
    || { echo "ledger-backup: cannot resolve the remote path $url" >&2; exit 4; }
  # A remote that carries a .git marker is somebody's WORK TREE, never a backup target.
  if [ -e "$url_real/.git" ] || [ -L "$url_real/.git" ]; then
    IN_REPO_MARKER="$url_real/.git"; refuse_in_repo "$url_real"
  fi
  in_work_tree "$(dirname "$url_real")" && refuse_in_repo "$url_real"
fi
```

Result on the patched copy: (a), (b), (c) and the relative-URL case all refuse at exit 2 naming
the repository; the legitimate bare remote outside every work tree still exits 0 (case 35b green).
Running the whole suite against the patched script flips **exactly one** case: 27
(`denyCurrentBranch`, a non-bare remote outside the tree) goes 5 -> 2. That is the one decision
for the human: refusing a non-bare remote up front is stricter than the current contract and, I
would argue, the correct reading of the invariant, but it retires case 27's construction. Exit 5
stays proven by case 6 (pre-receive hook) and case 28 (a real permission refusal), so nothing is
lost but the case's comment, which should be rewritten to pin exit 2 and say why.

Pin it with an OUTCOME assertion over a table of spellings, not one case per spelling, per
`lessons.md` 2026-09-16: for each of {plain path, `file://`, symlink, relative, self, sibling
worktree, bare-inside-tree}, run and assert that `git -C "$PROJECT" rev-parse --verify
internal-files` fails AND that no ledger blob is reachable from the project's repo. A table with
one assertion is what makes the next spelling a test failure instead of a round 8.

### Important

**I1. "THE WHOLE GIT ENVIRONMENT IS DROPPED" is a claim two variables wider than its list, and the
two it misses redirect the backup to a repository the user never named.** `:49`, `:68-69`.
`GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_n`/`GIT_CONFIG_VALUE_n` and `GIT_CONFIG_PARAMETERS` survive the
unset and inject config into every git call. Measured on the shipped script:

```
GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=url.$EVIL.insteadOf GIT_CONFIG_VALUE_0=$BACKUP \
  ledger-backup.sh $proj
  -> exit 0, "refreshed (... -> backup/internal-files ...)", stamp WRITTEN
  -> intended remote: fatal: invalid object name 'internal-files'   (nothing arrived)
  -> EVIL remote:     SECRET lesson                                 (everything arrived)
```

The comment's own justification is "they are what git hands a hook". Measured: git exports
`GIT_CONFIG_PARAMETERS` to hooks whenever the invoking command used `git -c`
(`git -c core.abbrev=12 commit` -> the pre-commit hook sees `['core.abbrev'='12']`), so the missed
variable is inside the very set the sentence claims. This is `lessons.md` 2026-09-16 ("a guard's
comment may name only what it verifies") repeated in the headline sentence of the guard, and the
overclaim has already been copied into `docs/system-map.md:145` ("The whole git environment
(`GIT_DIR`, `GIT_INDEX_FILE` and family) is dropped at startup").

Fix, proven: add `GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM` to
the unset. Dropping `GIT_CONFIG_COUNT` alone neutralises every `GIT_CONFIG_KEY_n`, verified
directly, so the unbounded `_n` family needs no loop. With the patch the same run puts the ledger
on the intended remote and nothing on the other. Then either the sentence becomes true, or narrow
it to "the repository-location and config-injection families" and say what is deliberately kept
(`GIT_AUTHOR_NAME`/`GIT_AUTHOR_EMAIL`, used at `:428-429`; `GIT_SSH_COMMAND`, needed to push).

**I2. The local variable named `GIT_DIR` is no longer a style point: it is a measured route back
into round-6 I1, corrupting the caller's index.** `:88-89`, `:106`, versus the unset at `:68`.
Round 6 filed this as a nitpick with the words "one `export` or one `set -a` re-arms the exact
bug just fixed". Measured at HEAD, with no source change at all, only an inherited shell option
that bash 3.2 imports through a shebang:

```
SHELLOPTS=allexport ledger-backup.sh $proj
  -> exit 0, "refreshed", stamp WRITTEN
  -> project index: CHANGED
  -> git -C $proj ls-files: internal-not-in-git/lessons.md internal-not-in-git/todo.md
  -> git status: " D CLAUDE.md" - the project's tracked file now reads as deleted
```

`unset` strips the export attribute; the assignment 19 lines later re-creates the variable, and
under `allexport` it is exported again, so every `git -C "$work"` below is redirected at the
project. `export SHELLOPTS=xtrace` is a known debugging habit, which is how an environment gets
there. Fix, proven: rename to `PROJECT_GIT_DIR` at `:88`, `:89` and `:106`; the same run then
leaves the index byte-identical. This is `lessons.md`'s "mechanism at the point of use" exactly: a
name that cannot collide, rather than a comment explaining why the collision is currently harmless.

**I3. The exit-4 row is in its third consecutive round of describing fewer states than the code
returns, which is now a class by `docs/eval-framework.md`'s own operational test.** `:43-45` and
`skills/retro/SKILL.md:53`. The rewrite added the copy/move distinction and kept the omission
round 6 enumerated by line. Exit 4 is returned at 14 sites; the row describes 5. Undescribed:
an unwritable destination (`:288`, `:310`), an unresolvable landing dir (`:296`), an unresolvable
remote path (`:384`), no temp dir (`:390`), `git init` failed (`:401`), the clone's directory
unwritable (`:415`), commit failed (`:431`). A caller reading "no remote of that name, an
unreachable or unreadable remote, a clone that failed, a missing directory, or a copy that
failed" will diagnose a permissions problem as a network problem.

Round 6 predicted this precise repeat and named the answer, so do not write a fourth wording:
add the mechanism. One case that extracts the header's rows and `/retro`'s rows and asserts they
carry the same set of codes AND the same clause count per code, plus a row clause for the family
the code actually has ("or the program could not write what it needed to write"). Case 33 sees a
missing row; nothing sees a row that is shorter than the code.

### Nitpicks

- `bin/ledger-backup.sh:382` and `:353`. Both `[ -d "$url" ]` and `canon_url` resolve a local URL
  against the CALLER's cwd, while git resolves a relative remote URL against the repository root.
  Measured: a relative in-tree remote is refused correctly when run from the project root (as
  `/retro` runs it) and, run from `/tmp`, skips the containment check and then dies at exit 4 with
  "cannot reach 'backup' (offline, or no access)" about a target that is perfectly reachable. It
  fails closed, so it is not the Critical, but the diagnosis is false and the C1 patch above fixes
  both with one `case` line. Carried unchanged from rounds 5 and 6.
- `bin/ledger-backup.sh:243`. The ancestor walk still terminates on the literal `[ "$p" = "/" ]`.
  Re-measured here: `dirname //` returns `/` on this platform, so it terminates; on a platform
  where it returns `//` this loops forever. The fixpoint version (`np="$(dirname "$p")";
  [ "$np" = "$p" ] && break`) costs the same and assumes nothing. Carried.
- `tests/ledger-backup.test.sh:633-644`. Case 33 still greps `exit [0-9]+` over the whole file,
  comments included. Its comment gained an honest "what it cannot catch" paragraph about stale
  rows but still does not mention this trade. Carried.
- `tests/ledger-backup.test.sh:468-487`. Case 25c's comment still frames itself as "a git that
  CANNOT ANSWER is not a git that said no repository", an axis the mechanism no longer has.
  Carried.
- `tests/ledger-backup.test.sh:537`, `:561`. Cases 28 and 29 restore permissions inline before
  their assertions, which is the pattern round 6 asked for; what is still missing is a trap, so an
  abort between the `chmod` and the restore leaves a `chmod 000` directory that the suite's own
  `rm -rf "$TMP"` cannot remove. Weakest of the carried nits.
- `AGENTS.md:285-291`. The de-duplication quotes the deleted rule verbatim ("max score reached, or
  no actionable fixes remain, or 3 cycles") inside a normative rules file. A wrong rule printed in
  the file an agent obeys is the shape that gets followed by accident; the history belongs in the
  commit body, which already has it. Also "the one named a few lines above in this file" points at
  line 39, 246 lines above. Leave one pointer, delete the quotation.
- Carried and re-measured unchanged: `awk '{print $3}'` (`:327`) truncates
  `ledger_backup: git backup my branch` to branch `my`; the case-only assertions at
  `tests/ledger-backup.test.sh:371-377` are vacuous on a case-sensitive filesystem; `:147` still
  assigns an unused `d`; case 26 still has no note that `chmod 444` rests on this platform's `ls`.
- Checked and NOT a finding, recorded so the next round does not re-derive it: removing
  `Threshold:` from `docs/plan-format.md` breaks no consumer (no script greps the token; the
  `docs/eval-framework.md` threshold table row for plans is covered by the note directly under it).

## Scores

correctness 1/2, the four round-6 fixes do what they say for every shape they were written
against, and I confirmed each by outcome rather than by reading. Docked hard, not zeroed, because
the guard shipped this round takes the wrong branch for three spellings of its own target (C1) and
because an inherited shell option turns the program back into the index-corrupting version it just
stopped being (I2). A reader who scores C1 in correctness as well as security reaches 5/12 and the
same verdict; the measurements are the same either way.

security 0/2, a Critical lands here. The one confidentiality property this program exists to
enforce, the ledger never sits inside a git repository, fails open at exit 0 with the stamp
written, and in two of the three shapes the ledger becomes a committed branch in the project's own
repository rather than loose objects awaiting a later `git add -A`. I1 adds a second, smaller
exposure: an inherited config-injection variable sends the whole ledger to a repository nobody
named while the message names the intended one. Hygiene elsewhere remains good: quoting
throughout, no `eval`, no ledger content on stdout, the stamp under the git dir, `--check`
offline, and the publish-remote refusal still holds for all three spellings it claims.

performance 2/2, unchanged and verified: the containment decision is `test` calls plus one
`dirname` fork per ancestor, the new `git`-arm check adds at most one `cd`+`pwd -P`, and the suite
runs in 21s here, still dominated by three deliberate `sleep 1`s the mtime assertions need.

readability 1/2, the refusal message is materially better (it names the repository, case 36), the
exit-3 row is right, and the `/retro` rows read like the program now behaves. Docked for two
sentences that overclaim their mechanism in the most load-bearing places in the file, `:49` (I1)
and `:376-381` (C1's rationale, which argues for the parent-only question in the same file whose
`:205-208` records that the parent-only question is what reopened the sibling-worktree hole), for
the `GIT_DIR` name re-use now proven live (I2), and for the exit-4 row (I3). The guard's historical
narrative has grown again; a one-line rule plus a pointer to this record would now read better
than the fourth retelling.

testing 1/2, cases 34, 34b, 35, 35b and 36 are well built: each asserts an outcome, each was
canaried against the previous commit, and 35b deliberately pins the case the fix must NOT break,
which is the discipline that makes a tightening safe. 114 green, re-run here. Docked because every
new case pins the exact shape the previous reviewer described and nothing generalises: one
spelling of a local remote (a plain path), one variable family member (`GIT_INDEX_FILE`), one row
(exit 3). C1 and I1 are both "the next instance of what was just tested", which is what an outcome
table over a spelling list would have caught before I did.

conventions 1/2, verified rather than accepted: conventional commit with a body that separates
measured from derived, feature branch, no secrets, English comments, no em or en dashes in any
changed file, `docs-claims-check --assertions` and `skills-lint` both green, README counts
matching. Docked one for a documented-convention violation, not for style: `lessons.md` 2026-09-16
("a guard's comment may name only what it verifies; to claim a class the mechanism must assert an
OUTCOME, because text checks are evaded by the next spelling") is the exact shape of both C1 and
I1, and I1 has already propagated the overclaim into `docs/system-map.md`.

total 6/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

**Why the total fell while the artifact improved.** All four round-6 Importants were applied and
three are fully closed; nothing regressed. The total moved because round 6 scored this same open
containment hole as Important on the only shape it had measured (loose objects, harm deferred to a
later `git add -A`), and the shapes measured here complete the harm inside the run itself, as a
committed ref in the project's own repository. The severity is my reading of the same defect with
better evidence, not a new defect introduced by this commit: (b) and (c) leaked identically at
`994ede8`, where the `git` arm asked nothing at all.

## Ceiling

**11/12 is the honest ceiling for the next round, not 12.** C1, I1 and I2 all have fixes proven in
this review, and I3 has a named mechanism, so correctness, security, readability and conventions
can all reach 2. Testing caps at 1 until the spelling table exists as one outcome-asserted case
rather than seven cases, and even then the remote-side residual is unchanged from rounds 2 to 7
and is worth stating rather than scoring: exits 4 and 5 are proven against git's own refusals,
exit 0 against a real network remote remains owner attestation I did not reproduce, and a non-local
URL (ssh, https, git://) cannot be contained by any on-disk walk. That last one is a permanent
residual and belongs in the header as such.

## Loop position

**This is round 7, against a cap of three** (`docs/eval-framework.md`, stop condition 2), reached
because the human took the escalation after rounds 3, 5 and 6. `docs/eval-framework.md` also says
a Critical always overrides the cap, which is why C1 is reported here rather than deferred.

**Stop condition 3 fires, and this time it is not a first-time class.** Stated in one phrase, as
the framework requires: *a containment guard that recognises one spelling of its target, or asks
about one level of it, while its comment claims the class.* Operationally, the framework's own
test: C1(a) is closed by "another spelling in the same conditional", C1(b)/(c) by "another branch
of the same conditional", I1 by "another name in the same list", and closing each one leaves the
next instance possible. That is the same class as round 3's containment spellings, round 4's
publish-remote compare, round 5's stderr match and round 6's I2, and it is also `lessons.md`
2026-09-16 written down and then repeated.

**So the answer is not an eighth opinion, and it is not "freeze as-is" either.** Round 6 said a
first-time class in round 7 would mean freeze; a RECURRING class means the opposite of another
patch: eliminate it or escalate. Recommended, in this order:

1. **Fix now, once, structurally.** Apply the C1 patch (proven here), the I1 unset (proven), the
   I2 rename (proven). Then add the ONE mechanism that ends the class: a table-driven outcome case
   that runs every spelling of a local remote and asserts no ledger content is reachable from the
   project's repository. Without that case, the next spelling is a round 8.
2. **One human decision, and only one:** case 27's contract. The fix refuses a non-bare remote up
   front (exit 2) instead of letting git refuse the push (exit 5). I recommend accepting it; exit
   5 stays proven by cases 6 and 28.
3. **Then freeze the containment contract** and write the residuals into the header: non-local
   URLs cannot be contained, a remote that is a repository the walk cannot see from disk cannot be
   contained, and choosing a private target stays the human's call.
4. **Re-dispatch this reviewer ONCE to re-anchor the record**, and treat that as the last round on
   this artifact regardless of what it returns. If round 8 raises another instance of this same
   class, the evidence is about the surface area of a local-remote backup target, and the correct
   product answer is to narrow the feature (accept only a bare repository outside every work tree,
   refuse everything else by default) rather than to keep widening a guard.

## Does this cover HEAD for the merge gate?

The record describes `0125901` exactly, with a clean tree, re-measured today. It does NOT clear
the gate: the verdict is REQUEST CHANGES on C1, with two Importants carrying proven one-line
fixes. Do not re-date this record; regenerate it at the new head after the fixes.

## What's good

- Every new case asserts an OUTCOME, not a message: an index hash, which ledger landed, which
  branch exists, which path is printed. Case 34 in particular pins the harm (the caller's index is
  byte-identical) rather than the mechanism (the variable is unset), which is why it will survive
  the refactor that C1's fix implies.
- Case 35b is the part most rewrites skip: alongside the case that pins the new refusal sits the
  case that pins what the refusal must NOT cost. That pair is what let me measure the cost of my
  own proposed fix in one run and report "exactly one case flips" instead of guessing.
- The environment fix went for the family rather than the reported variable, and the comment says
  what was measured and what it cost the user. It is short by two names, which is I1, but the
  instinct was right and it is the reason `GIT_OBJECT_DIRECTORY` and `GIT_QUARANTINE_PATH` are not
  a round 8.
- The commit body is the best on this branch: it names each finding it closes, states the design
  choice it made and WHY (the parent-versus-target argument), and reports the canary count. The
  argument turns out to be wrong for one marker shape, but it was written down clearly enough to
  be checked, which is the only reason C1 took one read rather than five.
- The folded-in doc fixes are real, not cosmetic: `AGENTS.md` had two incompatible stop conditions
  for one loop, and `docs/plan-format.md` had an extractable `Threshold:` token under prose saying
  there is no threshold. Both were correctly resolved toward a single source, and I verified
  nothing downstream read the removed token.

## History

- **Round 1** (`cebc0a0`, 2026-09-16): REQUEST CHANGES, 5/12. Two Criticals: the template's example
  lines read as live configuration in every scaffolded project; `init-project.sh` wrote no
  `.gitignore` entry for the ledger and then committed it.
- **Round 2** (`4558a32`, 2026-09-17): REQUEST CHANGES, 7/12. Better: both Criticals closed. Five
  Importants, all one class, a guard or comment wider than its mechanism.
- **Round 3** (`6f0ab87`, 2026-09-17): REQUEST CHANGES, 7/12. Mixed: four Importants closed and
  mutation-proven, the containment guard traded three failure shapes for three others and regressed
  one the previous version caught. Two consecutive rounds of the same class triggered
  `docs/eval-framework.md` stop condition 3; the tradeoff went to the human instead of to a round 4
  of the same loop.
- **Round 4** (`0046a92`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **better, and the
  loop is genuinely broken.** The human's structural choice is verified: the containment class is
  closed against every route tried here, including three that no previous round tested, and I4
  (install) and I2 (invisible ledger) from round 3 are closed and independently mutation-proven.
  What blocks the merge is not that class: it is the publish-remote guard added this round, which
  makes a class claim with a text compare and which I bypassed with a trailing slash, pushing the
  ledger to the publish remote at exit 0. One finding, one decision, no fourth spelling.
- **Round 5** (`2e7c740`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **same total,
  different composition, and the class is the story.** Closed: round-4 I1 (the publish guard took
  the honest close, claim narrowed and residual published, three spellings pinned) and I2 (the
  landing directory, not its parent, is now the argument), plus four of the six nits, plus the
  first real proofs of exit 5 against git's own refusal and of exit 4 from the clone path. Open:
  I3 only half closed, and the half that remains is a NEW measured fail-open of the SAME class,
  a safety decision read off git's stderr text, which lands the ledger in a live work tree at
  exit 0 with a stamp. Three consecutive rounds of that class means the next step is the
  structural version (measured here) or a documented residual chosen by the human, not another
  pattern.
- **Round 6** (`994ede8`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **same total,
  materially better artifact, and the loop's own class is gone.** The human chose the structural
  option and it holds: C1 is closed, and I attacked it from seven directions (unreadable
  worktree gitdir, dangling `.git` pointer, bare repo, `.git` directory, unreadable-but-traversable
  ancestor, symlinked and `..` ancestors, reftable layout) without getting back in. The
  text-keyed-safety-decision class is removed, not patched, so stop condition 3 does not fire for
  a fourth time. Round 4's exported-`GIT_DIR` nit is closed. What blocks the merge is four
  first-time findings in three new classes: the same commit's environment guard covers two of the
  four git variables that matter and the missing one (`GIT_INDEX_FILE`) makes the backup replace
  the caller's index at exit 0 with a stamp (I1, fix proven here); the containment invariant is
  enforced on the `dir` branch only, so a `git` target inside the work tree lands the ledger's
  objects untracked and unignored (I2); and the header's exit-4 and exit-3 rows drift from
  `/retro` exactly as exit-2 did, in the commit that fixed exit 2 and added a mechanism that
  cannot see it (I3, I4). Total unchanged because two measured exit-0-with-a-stamp paths remain;
  composition much improved, and every remaining fix is narrow.
- **Round 7** (`0125901`, 2026-09-18): REQUEST CHANGES, 6/12. Regression note: **worse total, better
  artifact, and the class round 6 declared gone is back one arm over.** All four round-6 Importants
  were applied; I1 (environment) and I4 (name the marker) are closed and outcome-pinned, I2 and I3
  are half closed. The total fell because round 6 scored the open `git`-arm hole on the only shape
  it measured, and the three shapes measured here are worse: a `file://` spelling, a sibling
  worktree of the project, and the project itself as the remote all pass at exit 0 with the stamp
  written, and two of them leave the ledger as a COMMITTED branch in the project's own repository
  (C1, fix proven here, costing exactly one existing case). Two Importants are the same class one
  level out: "the whole git environment is dropped" misses `GIT_CONFIG_COUNT`/`GIT_CONFIG_PARAMETERS`,
  which redirect the entire backup to an unnamed repository at exit 0 (I1, and git exports the
  latter to hooks, inside the set the comment claims), and the local `GIT_DIR` name that round 6
  filed as a nitpick is now measured corrupting the caller's index under `SHELLOPTS=allexport`
  (I2). Stop condition 3 fires on a recurring class, stated in one phrase: a containment guard
  that recognises one spelling of its target, or asks about one level of it, while its comment
  claims the class. The recommendation is not an eighth opinion: apply the three proven fixes,
  add ONE table-driven outcome case over the spellings, take the single decision about case 27,
  then freeze the contract with the residuals written into the header.
