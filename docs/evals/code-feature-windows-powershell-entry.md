---
artifact: install.ps1 + tests/install-ps1.test.sh + install.sh arg-parse markers + docs-claims-check skip reporting + community-refresh canary content + language-allowlist sixth copy + .gitattributes/.ps1 + README/INSTALL Windows claims
type: code
branch: feature/windows-powershell-entry
reviewed_commit: fab5c0d
artifact_version: 1
date: 2026-09-16
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 1, testing: 1, conventions: 0 }
total: 7/12
verdict: REQUEST CHANGES
previous_total: none
---

## Artifact

Branch `feature/windows-powershell-entry` at `fab5c0d`, 6 commits. Reviewed scope excludes
`skills/build/SKILL.md` and `skills/retro/SKILL.md` (skill-reviewer, in parallel).

1. `install.ps1` (NEW, 156 lines): Windows entry point. Locates a bash (WSL first, Git Bash
   second) and runs the real `install.sh` through it. No install primitives of its own.
2. `install.sh`: `# BEGIN arg-parse` / `# END arg-parse` markers around the existing option
   loop, so the suite can extract and execute the real parser.
3. `tests/install-ps1.test.sh` (NEW, 418 lines, 30 assertions with pwsh): both handoffs
   exercised end to end against fake `bash.exe`/`wsl.exe`, HOME redirected, no-op
   `install.sh` in the sandbox.
4. `bin/docs-claims-check.sh` + `tests/docs-claims-check.test.sh`: `--assertions` now counts
   and reports SKIP lines, with a miniature-tree test in both directions.
5. `tests/community-refresh.test.sh`: `canaries_survive` reads canary CONTENT back, closing
   the in-place-overwrite gap; the comment was narrowed to what it verifies.
6. `tests/language-allowlist-agreement.test.sh`: `-Lang` ValidateSet checked as the sixth
   copy, whole-set comparison (fails closed if the regex finds nothing).
7. `tests/line-endings.test.sh` + `.gitattributes`: `.ps1` pinned to LF and probed.
8. `README.md`, `INSTALL.md`, `AGENTS.md`, `docs/eval-framework.md`: Windows platform claim,
   countable claims, and two round-count clarifications.

No plan exists in `docs/plans/` for this branch, so there is no contract to compare against.

## Verification (by measurement)

- `bash tests/install-ps1.test.sh` -> 30/30 pass, rc 0, pwsh 7.6.6 present on this machine.
- `bash bin/docs-claims-check.sh --assertions` -> all four countable claims match the tree:
  `bin executables = 23`, `test suites = 30`, `programs with their own suite = 22`,
  `assertions = 875`. The README numbers are correct, not asserted.
- "22 bash scripts" (README:58, INSTALL.md:196, install.ps1:9) is exact: 23 programs in
  `bin/`, of which `token-report.py` is Python.
- Test-safety audit of the pwsh half: cases 5 and 6 only `ParseFile` the repo's
  `install.ps1`, they never execute it; every execution runs a `$TMP` copy under
  `env -i HOME="$TMP/home" PATH="<fakebin>:/usr/bin:/bin"` with a no-op `install.sh`
  beside it. `/usr/bin` and `/bin` hold no `bash.exe` or `wsl.exe`, so no real shell can
  leak in and nothing can reach the developer's `~/.claude`. Confirmed clean.
- Injection audit of the strings handed to bash: `$repoRoot` / `$wslRepo` go through
  `ConvertTo-BashSingleQuoted` and case 10b proves it by OUTCOME (fake bash `eval`s the
  line under an `O'Brien` path and the no-op `install.sh` is reached, no `EVAL-FAILED`).
  `$shArgString` is interpolated unquoted, but its only non-literal component is `$Lang`,
  which `[ValidateSet]` binds to one of four two-letter codes before the script body runs.
  No reachable injection today. See Important 3 for why that is a property of the
  ValidateSet and not of the assembly.
- Publish classification, measured:
  `git ls-tree -r -z --name-only HEAD | bash bin/publish-guard.sh --require-allowlist -`
  -> `publish-guard: BLOCK unclassified path (not in public-paths.txt): install.ps1`.
  It is the ONLY unclassified path in the tracked tree. See Critical 1.
  (First attempt without a path list returned "clean (0 files checked)"; that run was
  vacuous, stdin was empty. Re-run with the real tree, per lessons.md on instruments.)
- Instrument fail-open, proven by mutation rather than asserted: with
  `-h|--help) echo usage; exit 0 ;;` added to install.sh's case block, the suite's
  `accepted` extractor still yields exactly `--lang --link`, and the instrument guard
  (<=25 lines, contains `unknown option`, contains `END arg-parse`) still passes. Case 3,
  the drift direction the suite exists for, stays green on an unreachable flag. See
  Important 2.

## Findings

### Critical

**C1. `install.ps1` is unclassified, so the branch cannot be published at all.**
`docs/public-paths.txt` lists `install.sh` among the public root files and does not list
`install.ps1`; `docs/internal-paths.txt` does not list it either. Per the fail-closed rule
in both files and AGENTS.md Guardrails 2, an unclassified committed path is a HARD block.
Measured above: `publish-guard.sh --require-allowlist` names `install.ps1` and exits 1, and
`publish-snapshot.sh:51` runs exactly that check, then deletes the snapshot and exits 1 on
rc 1. The Windows entry point therefore reaches no user through the only sanctioned publish
path, and it takes every other change on this branch down with it.
This is the same class lessons.md recorded on 2026-07-25 ("committed paths the plan never
classified (`.claude/`, `.claude-plugin/`)").
Fix: add `install.ps1` to `docs/public-paths.txt` next to `install.sh`.
Structural fix for the class, which is what this repo asks for: `tests/publish-guard.test.sh`
tests classification only against synthetic fixtures, so nothing fails until publish time.
Add one case that pipes `git ls-tree -r -z --name-only HEAD` through
`--require-allowlist -` and asserts zero `unclassified` lines (denylist BLOCK lines are
expected in the working tree and must be tolerated). Then the next new root file reddens a
suite instead of a release.

### Important

**I1. `INSTALL.md:206-218,240` documents a symlink pair the published repo does not contain.**
Step 6w's "WSL is the recommended path, for a specific reason" rests on "The repo tracks two
symlinks, `.claude/agents` and `.claude/skills`", and the Windows ✓ CHECK tells the user to
run `file .claude/agents` and expect "symbolic link". Both paths are tracked here, but
`.claude/` is the first entry in `docs/internal-paths.txt` and `publish-snapshot.sh:38-48`
`rm -rf`s it out of the snapshot. A user cloning the public repo gets "No such file or
directory", and the stated reason to prefer WSL over Git Bash is unverifiable for them.
`install.ps1:140-142` prints the same claim at runtime. Every pre-existing reference in the
public docs is to `~/.claude/agents` (the install DESTINATION), which is a different and
real concern.
Fix: decide which document is wrong. If `.claude/` stays internal, rewrite the caveat around
what a public Windows clone actually hits, `install.sh --link` creating symlinks under
`~/.claude` (which `install.ps1:139` already states correctly), and drop the
`file .claude/agents` check from the ✓ CHECK. If the symlinks are meant to ship, classify
them and say so.

**I2. The `accepted` extractor fails open on any case arm that is not a bare `--flag)`.**
`tests/install-ps1.test.sh:74-76` reads install.sh's flags with
`grep -oE '^[[:space:]]*--[a-z][a-z-]*\)'`. An arm written `-h|--help)`, `--foo|--bar)`, or
with a leading short option is invisible. Proven by mutation above: `--help` added to
install.sh leaves `accepted` unchanged and case 3 green, while `--help` is unreachable from
Windows. The header calls flag drift the number-one reason the suite exists, and this is the
half of the check that catches the drift that actually happens.
The instrument guard at lines 53-60 does not catch it either: it bounds the block's SIZE,
not the completeness of the extraction, so this is a bounded extractor that still fails open
on the axis that matters.
Fix: count the arms and cross-check the parse. Extract every case label in the block
(`grep -oE '^[[:space:]]*[^ ].*\)' | grep -v '^\s*\*)'`), split each on `|`, keep the
`--`-prefixed tokens, and additionally assert that the number of non-`*` arms equals the
number of flags extracted, refusing loudly when they disagree.

**I3. The flag string is assembled unquoted, and the comment above it does not say what
makes that safe.**
`install.ps1:55-58` builds `$shArgString` by `-join ' '` and line 105/146 interpolate it raw
into the bash command. It is safe today only because `[ValidateSet]` constrains `$Lang` to
four literals, and nothing in the block records that dependency. The suite's case 3 makes
the pressure concrete: every option install.sh grows MUST be emitted from this block or the
suite reddens, so the first flag that carries free-form text (a path, a name, a URL) lands
here unquoted, next to a `ConvertTo-BashSingleQuoted` helper that was written for exactly
this hazard and is not applied. That is the eliminate-the-class principle pointing one way
and the code going the other.
Fix: move `ConvertTo-BashSingleQuoted` above the sh-args block (PowerShell executes
top-down, so it is not callable where the block sits today) and quote each element:
`$shArgString = (($shArgs | ForEach-Object { ConvertTo-BashSingleQuoted $_ }) -join ' ')`.
install.sh's parser accepts `'--link' '--lang' 'de'` identically; case 9's pattern
(`*"--link"*"--lang de"*`) needs updating to match.

**I4. Case 4's anti-port guard is a five-word denylist, which is the shape this branch's own
commit 2423381 removed from `community-refresh.test.sh`.**
`tests/install-ps1.test.sh:141-150` greps for `Copy-Item New-Item Remove-Item Set-Content
Out-File`. `cp`, `ni`, `md`, `mkdir`, `Move-Item`, `Add-Content`, `sc`, `>`, `>>`,
`[IO.File]::WriteAllText` and `[IO.Directory]::CreateDirectory` all walk past it. The
comment asserts the wide claim ("a copy primitive appearing here is how that decision
quietly becomes two implementations") over the narrow mechanism, which is verbatim the
lessons.md entry dated 2026-09-16 that the same branch applied correctly two commits
earlier.
The justification given, "the absence of a second implementation cannot be observed by
running the first", is not true here: the suite already runs install.ps1 under a redirected
HOME in a sandbox repo. Snapshot `$TMP/home` and the sandbox repo before the run and assert
they are byte-identical after, and any write primitive fails the case regardless of how it
is spelled. That converts a denylist into an outcome check and eliminates the class.
Fix: add that outcome case; keep the grep only as a fast hint, and narrow its comment to
name the five spellings it actually covers.

**I5. Case 4's first assertion cannot fail.**
`tests/install-ps1.test.sh:136` is `grep -q 'install\.sh' "$ROOT/install.ps1"` under the
label "install.ps1 hands off to install.sh". The `.DESCRIPTION` block at lines 6-7 contains
"install.sh" twice, so the assertion stays green on an install.ps1 whose handoff has been
deleted entirely. It is one of only 8 assertions that run on a machine without pwsh, where it
is the ONLY thing standing behind the delegation claim.
Fix: scope the grep to the executable body (exclude the `<# ... #>` comment block), or delete
the assertion and let case 9 carry the claim, saying so in the comment.

**I6. `install.ps1:103` calls a native command with `2>$null` outside any try/catch, under
`$ErrorActionPreference = 'Stop'`.**
`Get-WslReady` correctly wraps its `& wsl.exe -l -q 2>$null` in try/catch; the `wslpath`
call four lines later is not wrapped. On Windows PowerShell 5.1 (the default `powershell.exe`
on Windows, and the edition a user double-clicking this script gets), a native command
writing to stderr with EAP=Stop raises `NativeCommandError`. The result is a raw PowerShell
exception with a stack trace instead of the designed "Could not translate '...' into a WSL
path." message, which AGENTS.md's security baseline explicitly forbids ("Never expose stack
traces or internals to users").
Fix: wrap lines 103-108 in the same try/catch shape as `Get-WslReady`, emitting the same
named message on failure.

**I7. Two claims in the suite header outrun what the suite verifies.**
`tests/install-ps1.test.sh:16-18` says "The Git Bash and WSL handoffs are exercised END TO
END on any machine". They are gated behind `if [ -z "$PWSH" ]` and skipped without pwsh,
which the mid-file comment at line 155 states accurately and the header does not. The
residual list at lines 21-25 names three Windows-specific unknowns and omits two more:
(a) pwsh absence, and (b) that the parse check ran only under PowerShell 7 (the ok line
prints "PowerShell 7.6.6"), never Windows PowerShell 5.1, which is what the INSTALL.md
instruction `.\install.ps1` invokes by default on Windows. Given I6, 5.1 is not a
theoretical difference.
Fix: change "on any machine" to "on any machine WITH pwsh", and add both items to the
residual list. INSTALL.md Step 6w should also name the minimum PowerShell edition it was
written against.

### Nitpicks

- `tests/install-ps1.test.sh:82` emits an unconditional `ok` ("instrument: install.ps1
  emits [...]") after two guards that `exit 1`. It is a report line, not an assertion, but
  it is counted into the 875 the README publishes. Print it with `echo` instead.
- The WSL command string is never executed as shell: only the Git Bash fake honours
  `EVAL_HANDOFF` (line 178), and the `wsl.exe` fake never evals. `ConvertTo-BashSingleQuoted`
  is shared, so 10b covers the quoting, but the WSL arm's assembly (`cd ... && ./install.sh`)
  is verified by string match only. One `EVAL_HANDOFF` arm in the wsl fake would close it.
- `INSTALL.md:173-179`: "In PowerShell, from inside the cloned folder:" is followed by a
  block that begins with `git clone` and `cd Odeo`. Drop the "from inside the cloned folder"
  clause or drop the clone lines.
- `INSTALL.md:227-237` repeats the CRLF remedy that already sits at INSTALL.md:14-20. The
  Step 6w copy adds the useful `git add --renormalize` correction; fold that into the
  original and cross-reference instead of maintaining two copies.
- `install.ps1:81` excludes the WSL shim by `-notmatch 'System32'`. Correct on 64-bit
  PowerShell; a 32-bit host sees the same shim under `SysWOW64`. Matching on
  `\\Windows\\Sys(tem32|WOW64)\\` would cover both.
- `tests/language-allowlist-agreement.test.sh:115` takes `head -1` of the ValidateSet
  matches. A second ValidateSet added ABOVE the `-Lang` one would silently retarget the
  check. Anchor on the `$Lang` parameter instead. (It does fail closed on a reformat: an
  empty extraction mismatches `EXPECTED`, verified by reading.)

## Scores

correctness 1/2 - the handoff logic itself is sound and proven by outcome (branch choice,
wslpath use, exit-code propagation, apostrophe paths). Two real defects reach users: the
symlink section documents a path the published clone does not have (I1), and the unwrapped
native call produces a stack trace instead of the designed message on the default Windows
PowerShell edition (I6).
security 2/2 - no reachable injection: the repo path is single-quoted and proven by an
executing fake, and `$Lang` is allowlist-bound before the body runs, which is exactly what
the security baseline prescribes. No secrets, no PII, no network. The test harness cannot
touch the real `~/.claude`: HOME is redirected, PATH is replaced rather than extended, and
the repo's own `install.ps1` is only ever parsed, never executed. I3 is a latent shape, not
a live hole, and is scored under correctness/readability.
performance 2/2 - no hot paths; the suite completes in seconds and the `--assertions` change
adds one capture per suite.
readability 1/2 - install.ps1 is small, single-purpose, and its comments explain the WHY
(the wsl-exists-but-no-distro trap, the apostrophe hazard) rather than the what. Docked for
the header claims that outrun the mechanism (I7) and for a guard comment asserting a class
over a denylist (I4), which is the specific writing failure this repo's lessons.md names.
testing 1/2 - genuinely strong work: outcome assertions against fake binaries, two canaries
that prove their own cases can fail, a fixture that forces the Git Bash arm, a real `eval`
of the built command line, and the produced line fed back through the real parser. Docked
for a proven fail-open in the extractor that backs the suite's stated primary purpose (I2),
an assertion that cannot fail (I5), and the absence of any check that would have caught C1.
conventions 0/2 - a new committed root path was not classified, which the repo's own
fail-closed guardrail turns into a hard block on the release path (C1), repeating lessons.md
2026-07-25. Compounded by I4 reintroducing the denylist-behind-a-class-claim shape that
commit 2423381 on this same branch removed elsewhere.

total 7/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 is reachable. Nothing here structurally caps: the Windows-unverifiable half is handled
the way this repo accepts, by stating the residual, and the residual list only needs two
entries added (I7). C1 and I1 are one-line and one-paragraph fixes; I2, I4 and I5 are
test-side and all three have outcome-shaped replacements available.

## History

- 2026-09-16 (`fab5c0d`, claude-opus-5[1m], effort high): first review. REQUEST CHANGES,
  7/12. No prior record for this branch, so no regression comparison.
