---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ bin/docs-claims-check.sh, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: ad00988
artifact_version: 9
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 0, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 6/12
verdict: REQUEST CHANGES
previous_total: 6/12
---

## Artifact

Commit `ad00988` on `feature/windows-powershell-entry`, clean tree. Two commits since round 8.
`5972c27` is the one under review (one shared URL-to-path conversion, a refusal for relative
URLs, the frozen residuals, three new rows in case 37, cases 41 and 42). `ad00988` touches
`bin/docs-claims-check.sh`, `tests/docs-claims-check.test.sh` and one README line only.

**`bin/ledger-backup.sh` and `tests/ledger-backup.test.sh` are BYTE-IDENTICAL across
`5972c27..ad00988`** (`git diff --quiet` on both paths). So every measurement below, taken
against the working tree, describes `ad00988` exactly. **I agree `ad00988` is out of scope for
this record**: it cannot affect this artifact, and the claims check it fixes is scored in
`code-feature-windows-powershell-entry.md`, not here. One observation in passing, not a finding
against this artifact: its `--assertions` run is green here and the README's `1090 assertions` is
measured correct on this machine.

## THE ROUND-8 CRITICAL IS CLOSED, MEASURED BY RUNNING IT

Not read off the diff. I replayed all five leaks from round 8's C1 and I1 against the shipped
script, from a clean project each time, with the previous commit as a POSITIVE CONTROL so a
"refused" line means something (`lessons.md` 2026-08-06: a negative result needs an instrument
proven to give a positive).

| round-8 leak | at `b3b66f7` (control) | at `ad00988` |
|---|---|---|
| (a) `file://localhost$PROJECT` | exit 0, stamped, ref in the project's own repo | **exit 2**, no stamp, no ref: "IS this project's own repository" |
| (b) `file://localhost$PROJECT/inside.git` | exit 0, stamped, ledger readable in the in-tree bare repo | **exit 2**, no stamp, nothing written |
| (c) `file://localhost<publish remote>` | exit 0, stamped, **ledger ON THE PUBLISH REMOTE** | **exit 2**, no stamp, publish remote empty |
| (c-control) the same repo spelled plainly | exit 2 | exit 2 |
| (d) `$PROJECT/a@b:c/t.git` | exit 0, stamped, ledger in the in-tree bare repo | **exit 2**, no stamp, nothing written |
| (e) relative `b.git`, cwd inside unrelated repo R | exit 0, stamped, ledger landed in R | **exit 2**, no stamp, nothing in R |

The shared `local_url_path` is the right shape and it did what it was built to do: the publish
comparison and the containment guard can no longer give two answers, and the four spelling leaks
are gone. The relative refusal is the honest close of (e). **The commit body's canary claim is
exact**: the HEAD suite against `b3b66f7`'s script produces **17 failures**, the number claimed.
Suite at HEAD: **169 assertions, 26s, one SKIP** (SHELLOPTS readonly on bash 3.2, reported). Case
38 (the legitimate outside clone) passes at exit 0; the `dir` arm is untouched by the diff and its
cases are green.

**And the class is back one transformation over, at the same harm.**

## Findings

### Critical

**C1. The conversion still MODELS what git does with a URL instead of failing closed when it
cannot answer, and it does not know that git PERCENT-DECODES a file URL's path. Four measured
paths reach exit 0 with the stamp written, one of them onto the publish remote, and one of them
needs nothing more exotic than a directory name with a SPACE.** `bin/ledger-backup.sh:384-402`
(`local_url_path`), consumed at `:505-506` and, through `canon_url`, at `:426`.

Measured on the shipped script, each from a clean project:

```
(1) origin = /tmp/.../pub.git  (the publish remote),
    backup = file://localhost/tmp/.../sub/%2e%2e/pub.git
      -> exit 0, "refreshed", stamp WRITTEN, SECRET-LEDGER readable ON THE PUBLISH REMOTE
(2) origin = "/tmp/.../My Backups/pub2.git",
    backup = file://localhost/tmp/.../My%20Backups/pub2.git
      -> exit 0, stamp WRITTEN, SECRET-LEDGER ON THE PUBLISH REMOTE.
         %20 is not an attack. It is how a URL for a path with a space is spelled.
(3) backup = file://localhost$PROJECT/sub/%2e%2e     (the project itself)
      -> exit 0, stamp WRITTEN, the ledger is a REF in the project's own repository
(4) project at "/tmp/.../My Project", backup = file://localhost/tmp/.../My%20Project/in.git
      -> exit 0, stamp WRITTEN, the ledger sits in a bare repo INSIDE the work tree,
         untracked and unignored ("?? in.git/" in `git status --porcelain`)
(5) CONTROL: the same %2e%2e in a PLAIN path (no file:// scheme)
      -> exit 4. git does not decode a plain path, and neither does this program. They AGREE.
         So the defect is confined to the file:// arm, which is where the modelling is.
```

Root cause, one sentence: **`local_url_path` hands back the URL's path bytes verbatim, git
percent-decodes them, and when the two differ the program's path is not a directory, so the
entire containment block at `:506` is SKIPPED rather than refused.** The mechanism is identical
to round 8's: an unmodelled git behaviour turns a guard into a no-op, silently, at exit 0 with
the stamp, after which `--check` answers "up to date" and the user stops looking.

**This is the same class returning, and I say that plainly because the human has a standing rule
about it** (`CLAUDE.md`, Core Principles: stop patching a recurring class, eliminate it or
escalate). Round 7: the guard recognised one spelling. Round 8: two conversions disagreed. Round
9: one conversion, no disagreement, and it still models git's URL grammar by hand. The commit's
own comment at `:370-371` says "A shared function is what makes that class impossible: there is
no second answer to differ from." That sentence is TRUE about the class it names and the code
delivers it. It is not the class that bit: the remaining one is **a single conversion that is
still not total, and whose failure mode is to pass.**

**It is NOT a new defect** and it is NOT new scope: round 8's C1 already named the requirement
("that conversion is not total"), and round 8's own patch sketch would not have closed it either.
I am scoring the same finding against the fix that claimed to make the conversion total.

**The structural close, measured here at ZERO cost, and it does not require knowing what git
does.** The coordinator was right that the *skip* costs nothing for a missing path or a file
path (git refuses those itself, exit 4, no leak). I measured the sharper arrangement, and it is
not dead: the skip is dangerous exactly where **the program's path does not exist while git's
does**, which is what decoding produces. So make an unanswerable question refuse instead of pass:

```sh
    local_path="$(local_url_path "$url")"
    if [ -n "$local_path" ] && [ ! -d "$local_path" ]; then
      # FAIL CLOSED. The url converted to a local path and that path is not a directory, so the
      # two questions below cannot be asked at all. git may still reach something (it decodes
      # %XX in a file url; this program does not), and an unaskable question must not read as a
      # passed one. Exit 4, the code this configuration already returned from the clone.
      echo "ledger-backup: '$remote' names a local path that is not a directory here ($local_path)." >&2
      echo "  The containment questions can only be asked of a directory that exists, so this" >&2
      echo "  program will not act on it. Write the target as a plain absolute path." >&2
      exit 4
    fi
    if [ -n "$local_path" ]; then
```

Measured: **169 assertions green, unchanged**; all four leaks above become exit 4 with no stamp
and nothing written; all five round-8 leaks stay refused. Exit 4 is deliberate, and it is what
made the cost zero: a local path that is not a directory ALREADY ended at exit 4 from the clone,
so the code the caller sees does not change for any configuration that exists today. (I first
tried exit 2 and it broke exactly one case, "unreachable remote -> exit 4". That case was right
and the patch was wrong.)

Why this is the structural version and not a sixth phrasing: it eliminates the class rather than
the instance. **Any future git transformation this program does not model produces a path that is
not a directory, and therefore a refusal, not a silent pass.** Percent-decoding would then be a
CONVENIENCE to add if you want `%20` paths to keep working, never a guard, and it must not be
shipped as the fix on its own: decoding alone is precisely the fifth phrasing the human's rule
warns about, and it would leave the next unmodelled transformation passing at exit 0.

Pin it with two rows in case 37's existing table (`file://localhost$pp_real/sub/%2e%2e/<bare>`
and a project path containing a space spelled with `%20`) and one row in case 41 (the publish
remote via `%20`). All three fail at HEAD and pass on the patch, measured. **And see I1: as case
37 is written today, two of those rows would pass while leaking.**

### Important

**I1. Case 37's three "THE HARM" assertions are blind to the very harm shape the new leak
produces, and the suite proves it against itself.** `tests/ledger-backup.test.sh:780-796`.
Carried from round 8 (I3), not applied, and now demonstrated twice:

- I ran the case's three checks verbatim against leak (4) above. Ground truth: the ledger WAS in
  a bare repo inside the work tree. The case's checks: ref-in-project `passes`, ledger-object-in-
  project `passes`, copy-in-work-tree `passes`. **All three BLIND.** Added as a row, that leak
  would be caught only by the exit-code and stamp assertions, which are rule and bookkeeping
  checks, not the outcome the case's own header claims to assert.
- The canary run says the same thing without me: at `b3b66f7` the rows `file-url-host` and
  `at-colon-path` leaked into an in-tree bare repo, and of their five assertions only exit code
  and stamp went red. The three harm lines stayed green through a real leak.

A bare repo nested in the work tree holds compressed objects that neither `cat-file
--batch-all-objects` on the project nor `find -name todo.md` reaches. Fix, one assertion,
measured catching it (` M .claude/tasks/todo.md ?? CLAUDE.local.md ?? inside.git/`):
`git -C "$pp" status --porcelain` must show nothing beyond the ledger's own paths.

**I2. `url_is_relative` and `local_url_path` DO disagree, and the comment added this round to
prevent exactly that says they cannot.** `:404` ("RELATIVE, asked the same way, so the refusal
below and the conversion above cannot drift"), `:396-399` against `:408`.

Differential over 26 URL shapes, run against both functions extracted verbatim. Two inputs
disagree: for `a/b:c.git` and `./a:b/c.git` (a slash before the colon), `url_is_relative` returns
RELATIVE while `local_url_path` returns a path, and a RELATIVE one at that. Observable end to
end, because `canon_url` consumes the conversion BEFORE the relative refusal runs, and then does
`[ -d ]` from the caller's cwd:

```
backup = a/b:c.git, origin = the same repo, cwd = the project  -> exit 2 "is a relative URL"
backup = a/b:c.git, origin = the same repo, cwd = where it resolves
                                                               -> exit 2 "is this project's publish remote"
```

**Important, not Critical: both are exit 2, nothing is written, no stamp.** The refusal contains
it. But the two functions answer different questions on the same input, which is round 8's defect
class one layer further out, and I said I would name it plainly if I found it: *this is that
shape, caught before it can cost anything.* Fix: give `url_is_relative` one body, `[ -z "$(local_url_path "$1")" ]`
restricted to the non-scheme cases, or simplest, have the `*:*`/`*/*` arm of `local_url_path`
return nothing like every other relative input already does. Then the sentence at `:404` becomes
true instead of aspirational.

**I3. The relative refusal costs one legitimate configuration, and states a reason that is false
for it.** `:434-448`. Measured: `git remote add backup '~/tilde.git'` is resolved BY GIT to a
local path (verified by pushing to it), and this program now refuses it at exit 2 saying "Where
it points depends on the directory this program is run from". It does not: `~` resolves against
`$HOME`, which is exactly as stable as an absolute path. The `dir` arm expands `~` deliberately
(`:278`, `dest="${dest/#\~/$HOME}"`), so the commit's claim at `:442` that "both arms now answer
alike" is measurably false for the one punctuation the `dir` arm goes out of its way to support.
Fix, one line, mirroring the arm it claims to match: expand a leading `~` before asking
`url_is_relative`. Everything else about the refusal is right: ssh, https, `git://` and
`git@host:path` all pass it untouched (measured, four spellings), and case 42 pins both
arrangements.

**I4. The exit-4 header row is in its FIFTH consecutive round of describing fewer states than the
code returns.** `:43-46` and `skills/retro/SKILL.md:53`. **16** `exit 4` sites in code (18
including comments); the row names 5. Still undescribed: an unwritable destination, an
unresolvable landing dir, an unresolvable remote path, no temp dir, `git init` failed, an
unwritable clone directory, a failed commit. Rounds 6, 7 and 8 each asked for a mechanism rather
than another wording. Minimum honest close, one clause on both rows: "or the program could not
write or resolve something it needed". The mechanism that would end it is case 33 comparing
clause counts per code between the header and `/retro`, not just row presence. Note C1's patch
adds a 17th site, so this row gets further from true if the patch ships without it.

**I5. `:50` still claims THE WHOLE GIT ENVIRONMENT IS DROPPED, and this round I have a measured
consequence rather than a list.** `GIT_SSH_COMMAND`, `GIT_EXEC_PATH`, `GIT_TEMPLATE_DIR` and
`GIT_AUTHOR_*` survive the `unset` at `:76-78`. I used `GIT_SSH_COMMAND` from the caller's
environment to redirect git's ssh transport, and the backup followed it and landed at exit 0 with
the stamp. So an inherited variable the comment says is dropped still decides where the ledger
goes. Round 7 and round 8 both asked for the sentence to be made true or narrowed; only the list
grew. Narrow it to "the repository-location and config-injection families", and name what is kept
and why (`GIT_AUTHOR_*` is kept deliberately, `:566-567` relies on it).

### Nitpicks

- `tests/ledger-backup.test.sh:844-849`. Case 40 still asserts its class with `grep -E "^[[:space:]]*$n="`,
  one of four assignment spellings that `set -a` exports. Carried from round 8 (I2), unapplied.
  One line: `grep -qE "^[[:space:]]*(export|declare|typeset|local|readonly)[[:space:]]+$n=|^[[:space:]]*$n=" "$SCRIPT"`.
- `bin/ledger-backup.sh:254-259`. The ancestor walk still terminates on the literal `[ "$p" = "/" ]`.
  Measured here: `dirname //a` is `/` on this platform so it terminates, but POSIX leaves `//`
  implementation-defined. The fixpoint version costs the same and assumes nothing. Carried from
  rounds 5 to 8.
- `tests/ledger-backup.test.sh:640-642`. Case 33 still greps `exit [0-9]+` over the whole file,
  comments included (`:74`, `:213`, `:232` are comments and contribute exit 0). Its honest "what
  it cannot catch" paragraph still does not mention that trade. Carried.
- `tests/ledger-backup.test.sh:488-492`. Case 25c's comment still frames itself as "a git that
  CANNOT ANSWER is not a git that said no repository". Still worth re-pointing at the identity
  question (`remote_common=""` falls through), which is where that axis now lives. Carried.
- `tests/ledger-backup.test.sh:494/497`, `:587/590`. The `chmod 000` cases still restore inline
  with no trap, so an abort between `chmod` and restore leaves a directory the suite's own cleanup
  cannot remove. Carried.
- `AGENTS.md:285-291` still quotes the deleted stop-condition rule verbatim inside a normative
  rules file. Carried.
- `:517`. The refusal says "IS this project's own repository" for a plain directory inside the
  project too. Correct refusal, slightly wrong sentence. Carried.
- `canon_url`'s dead weight from rounds 5 to 8 is **CLOSED**: it now shares the one conversion,
  which is what the round-8 nit asked for.

## Residual wording: what changed at this HEAD

All six frozen residuals were re-checked against the new conversion. **Five are still true as
written. One needs a sentence, and one more is missing entirely.**

- **Non-local URL cannot be contained: TRUE, and I verified it is reachable rather than
  theoretical.** With a `GIT_SSH_COMMAND` that lands locally, `git@localhost:$PROJECT/mirror.git`
  put the ledger in a bare repo inside the work tree at exit 0 with the stamp. The program and
  git AGREE on the classification (both call it non-local); the harm comes from the transport,
  which no on-disk walk can see. The residual is honest and correctly scoped. Leave it.
- **Windows drive letter: TRUE, re-checked against the new `*:*` arm.** `C:/backup.git` takes
  `${u%%:*}` = `C`, no slash, so it is read as `host:path` and yields no local path (measured:
  exit 4, not walked); `C:\backup.git` the same; the `dir` arm still refuses both as non-absolute.
  The wording needs no change.
- Public-remote undecidability, git refusing to answer identity, the alternates-borrowing remote,
  and "exit 0 against a real network remote is owner attestation": unchanged code paths, all still
  true.
- **The relative-URL residual is correctly ABSENT**, since relative URLs are refused. Right call.
- **MISSING, and it is the Critical:** there is no residual saying the conversion is a MODEL of
  git's URL handling. Do not add one. A residual describes what the mechanism cannot decide; this
  one decides wrongly and reports success, which is the thing the first 17 lines of the file say
  it exists to prevent. Fix it with the fail-closed patch, after which the honest sentence is:
  "A URL whose local path this program cannot resolve is REFUSED rather than acted on, even
  though git may be able to reach it (it decodes `%XX`; this does not)."

## Scores

correctness 1/2, the round-8 Critical is closed and I proved it by running all five leaks with a
positive control; one shared conversion for both guards is the right structure, the relative
refusal is the right call, the canary is exact at 17, case 38 and the `dir` arm are untouched and
green at 169. Docked for a measured exit-0-with-stamp leak in the same conversion (C1) and for two
helper functions that answer differently on the same input (I2).

security 0/2, a Critical lands here, and its worst arrangement is the one the whole file exists
to prevent: the ledger on the PUBLISH REMOTE at exit 0 with the stamp written, reachable through a
directory name containing a space. Hygiene elsewhere is good and unchanged: quoting is sound, no
`eval`, no ledger content on stdout, the stamp stays under the git dir, the config-injection
family is dropped and case 39 proves it.

performance 2/2, unchanged and verified. The conversion is pure shell pattern matching, no
subprocess; the suite is 26s, still dominated by three deliberate `sleep 1`s.

readability 1/2, the rationale above the conversion is the best version of this comment yet: it
says what the old code got wrong, why a shared function is the fix, and what it deliberately
refuses to guess. `docs/system-map.md` and `skills/retro/SKILL.md` were both brought back in line
with the design, which round 8 asked for. Docked because the sentence added THIS round to prevent
drift (`:404`) is measurably false (I2), `:50` is still false and now measurably so (I5), and
`:442` claims both arms answer alike where they do not (I3).

testing 1/2, cases 41 and 42 are well built: 41 carries its own control and 42 pins both
arrangements with the reason written down, the canary reproduces exactly at 17, and 169 assertions
are green here. Docked because the table's harm assertions are blind to the nested-bare-repo shape
(I1, now demonstrated against the suite's own canary run) and case 40 still asserts a class with a
one-spelling regex. Those two are why a green suite did not catch C1.

conventions 1/2, verified: conventional commit, feature branch, English comments, no em or en
dashes in the changed files, README counts measured correct (1090), `docs-claims-check --assertions`
green, no secrets. Docked one for `lessons.md` 2026-09-16, "a guard's comment may name only what
it verifies", landing on `:404`, `:442` and `:50`, and for the recurring-class rule the Critical
falls under.

total 6/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

**Same total for the third round running, and this time the flat number is the finding.** Round 8
said the decision is structural and the parsing in front of it is not. That is still the exact
sentence. Five leaks closed, twenty-nine assertions added, the residuals frozen, and the harm is
unchanged because the conversion is still a model of git rather than a refusal to guess. The
difference from rounds 7 and 8 is that the eliminating fix is now four lines, measured, and costs
nothing.

## Ceiling

**11/12 is the honest ceiling for a round 10, not 12.** C1 has a fix measured here at zero cost,
I2 and I3 are one line each, I1 is one assertion, I4 and I5 are wording, so correctness, security,
readability and conventions can all reach 2. Testing caps at 1 until case 37's harm assertions can
see a bare repo in the work tree and case 40 asserts its class rather than one spelling, and even
then one residual is permanent and belongs in the header rather than in a score: a non-local URL
cannot be contained by any on-disk walk (verified reachable this round through `GIT_SSH_COMMAND`),
and exit 0 against a live network remote is owner attestation the suite cannot reproduce.

## Loop position

**Stop condition 3 fires for the fifth time, and the phrase has narrowed again.** Rounds 3 to 7:
a containment guard that recognises one spelling. Round 8: two conversions that disagree. Round 9:
**one conversion, no disagreement, still a model of git whose failure mode is to pass.**

The human's standing rule applies and I am not proposing a sixth heuristic. The recommended close
is the one that makes the class impossible rather than the instance: **an unanswerable question
must refuse, not pass.** `[ -n "$local_path" ] && [ ! -d "$local_path" ] -> exit 4`. Four lines,
169 assertions unchanged, every leak from rounds 8 and 9 refused, and it is correct without
knowing anything about git's URL grammar, which is precisely why the next transformation cannot
reopen it. Percent-decoding is optional convenience on top, never the guard.

**Recommendation, in order:**
1. Apply C1's fail-closed check (measured: 169 green, all nine leaks from rounds 8 and 9 refused).
   Do NOT ship percent-decoding as the fix on its own.
2. Fix I2 so the two functions cannot answer differently, and I3 so `~` is expanded rather than
   refused with a false reason.
3. Add I1's `status --porcelain` assertion, the three new table rows, and case 40's four-spelling
   regex. These three are why the suite was green through C1.
4. I4 and I5 are wording, one clause each.
5. If a round 10 finds another instance of URL parsing, the parsing is the wrong layer and the
   product answer is the narrow one round 7 already named: accept a local target only as a plain
   absolute path to a repository outside every work tree, refuse `file://` outright, and say so
   in the header.

## Does this cover HEAD for the merge gate?

The record describes `ad00988` exactly, clean tree, with `bin/ledger-backup.sh` and
`tests/ledger-backup.test.sh` byte-identical to the reviewed `5972c27` change. It does NOT clear
the gate: REQUEST CHANGES on C1. Do not re-date this record; regenerate it at the new head after
the fixes.

## What's good

- **The round-8 Critical is genuinely closed, and closed structurally.** One conversion for both
  guards was the right call and it holds: the publish comparison and the containment guard cannot
  disagree any more, which was the mechanism behind three of the four spelling leaks. Five leaks
  refused, measured against a control that still leaks.
- **The relative URL was refused rather than documented.** That was the harder of the two options
  offered, it is the one that removes a live exit-0 leak, and it mirrors what the `dir` arm
  already does for the same reason. Case 42 pins both arrangements and writes down the rejected
  alternative and why.
- **The canary is exact for the second round running.** 17 failures at `b3b66f7`, precisely as the
  commit body claims. Very few commit bodies survive that check unchanged.
- **The residuals were frozen honestly, and they hold.** I re-checked all six against the new
  conversion, including the Windows one against the new `*:*` arm, and attacked the non-local one
  until it leaked exactly where the residual says it would. A residual that survives being attacked
  is worth more than a guard that has not been.
- **The comment above the conversion explains the defect it fixes, not just the code.** It names
  the two things a spelling list got wrong and why a shared function makes that class impossible.
  Both statements are true; the Critical is about a class the sentence does not claim.

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
- **Round 8** (`b3b66f7`, 2026-09-22): REQUEST CHANGES, 6/12. Regression note: **same total,
  materially better artifact, and the defect moved one step earlier in the pipeline.** The human
  took the structural option again and the DECISION logic is now sound: identity by git common dir
  plus the existing ancestor walk refused every one of seven attack shapes (symlink to an in-tree
  bare repo, symlink to the project, `..` path, submodule, sibling worktree, worktree with an
  unreadable admin dir, and correctly ACCEPTED an alternates-borrowing remote and an ordinary
  outside clone). Round-7 I1 (config injection) and I2 (the `GIT_DIR` name) are closed and pinned
  by cases 39 and 40, the canary reproduces exactly (13 failures at `0125901`), case 27 does not
  flip as claimed, and all 33 suites are green at 140 assertions here. What blocks the merge is
  the step in FRONT of the two questions: the URL is turned into a path by matching spellings, and
  the conversion is not total. Measured at exit 0 with the stamp written, `file://localhost/...`
  (git ignores the authority, not just an empty one) puts the ledger into the project's own
  repository as a ref, into an untracked in-tree bare repo, and ONTO THE PUBLISH REMOTE, which is
  round 4's Critical returning through a different spelling; an absolute path containing `@` and
  `:` is misfiled as a host transport; and a relative url is checked against the project while the
  run resolves it against the caller's cwd, which landed the ledger in an unrelated repository.
  One shared `local_url_path` helper used by both guards closes all but the last, measured at zero
  cost to the 140 existing assertions, and the relative case has a four-line refusal mirroring the
  `dir` arm. The class phrase narrows to: the decision is structural, the parsing in front of it is
  not. Residual wording for the freeze is written into this record, ready to paste.
- **Round 9** (`ad00988`, artifact unchanged since `5972c27`, 2026-09-22): REQUEST CHANGES, 6/12.
  Regression note: **the round-8 Critical is CLOSED and verified by running it, and the same class
  returns one transformation over, at the same harm.** All five round-8 leaks were replayed with
  `b3b66f7` as a positive control that still leaks all five: `file://localhost` to the project, to
  an in-tree bare repo and to the publish remote, the `@`-and-`:` absolute path, and the relative
  URL all now exit 2 with no stamp and nothing written. One shared conversion for both guards was
  the right structure and it delivered what it claimed; relative URLs were refused rather than
  documented, which was the harder and better of the two options; the canary is exact at 17
  failures; case 38 and the `dir` arm are untouched and the suite is green at 169. What blocks the
  merge is that the conversion still MODELS git's URL handling and does not know git
  percent-decodes a file URL's path, so the program's path is not a directory, the containment
  block is SKIPPED rather than refused, and four arrangements reach exit 0 with the stamp: the
  ledger onto the PUBLISH REMOTE via `%2e%2e` and via `%20`, into the project's own repository, and
  into an in-tree bare repo when the project directory merely contains a SPACE. A plain path with
  the same `%2e%2e` exits 4, so the program and git agree everywhere except where the modelling is.
  Two helper functions added this round to agree do disagree on `a/b:c` (contained at exit 2, so
  Important), and case 37's harm assertions are blind to the nested-bare-repo shape, demonstrated
  against the suite's own canary run, which is why 169 green did not see the Critical. The
  eliminating fix is four lines and measured at zero cost: refuse when the converted path is not a
  directory (exit 4, the code that configuration already returned), so every future unmodelled git
  transformation becomes a refusal instead of a silent pass. Class phrase for round 10: one
  conversion, no disagreement, still a model of git whose failure mode is to pass.
