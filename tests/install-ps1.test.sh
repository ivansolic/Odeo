#!/usr/bin/env bash
# Tests for install.ps1, the Windows entry point.
#
# WHY THIS EXISTS. install.ps1 is the only executable in this repo that cannot run on the
# machine it was written on, and it shipped with nothing checking it at all. The two ways
# an entry point like this rots are both silent:
#
#   1. FLAG DRIFT. install.sh grows an option and install.ps1 cannot reach it, or emits one
#      install.sh rejects. Either way the Windows user gets a different installer than the
#      documented one, and nobody on macOS ever sees it.
#   2. IT QUIETLY BECOMES A PORT. The design is one implementation of every guard, reached
#      from both shells. A well-meant `Copy-Item` added here is the first half of the second
#      implementation the whole decision exists to prevent.
#
# HOW FAR THIS ACTUALLY GETS. On a machine WITH PowerShell, the Git Bash and WSL handoffs run
# end to end against FAKE `bash.exe` and `wsl.exe` on PATH (the fake-binary pattern from
# share-tunnel.test.sh), so the branch choice, the flag string, the path translation and the
# exit-code propagation are verified by OUTCOME. Without pwsh only the eight source-level
# assertions run and the rest report SKIP; that is most of the file unproven, which is why
# each skipped case is named rather than counted as passing.
#
# WHAT IS STILL UNVERIFIED, and stays unverified until someone runs this on Windows:
#   - a real `wsl -l -q` prints UTF-16; the fake prints ASCII, so the DISTRO-PRESENT arm is
#     verified in shape, not in encoding;
#   - `wslpath` translation of a real C:\ path;
#   - whether Windows symlink permission actually bites a `--link` install;
#   - PowerShell 5.1, which is what `.\install.ps1` starts by default on Windows. Everything
#     here runs on the pwsh that is installed, in practice 7.x. The 5.1-specific hazard the
#     code guards against (native stderr raising NativeCommandError under EAP=Stop) is
#     therefore reasoned about, not observed.
# Those are the honest residual, and INSTALL.md says the Windows path is unverified for the
# same reason. This suite narrows that claim; it does not retire it.
#
# Run: bash tests/install-ps1.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0; skipped=0
ok()   { echo "ok   - $1"; pass=$((pass+1)); }
bad()  { echo "FAIL - $1"; fail=$((fail+1)); }
skip() { echo "SKIP - $1"; skipped=$((skipped+1)); }

TMP="$(mktemp -d)" || { echo "FAIL - instrument broken: no temp dir"; exit 1; }
trap 'rm -rf "$TMP"' EXIT

[ -f "$ROOT/install.ps1" ] || { echo "FAIL - install.ps1 is missing from the repo root"; exit 1; }

# ---------------------------------------------------------------------------
# INSTRUMENTS. Both sides of the flag contract are extracted from their own source, so a
# case below compares install.ps1 against install.sh and never against a paraphrase of
# either. Both extractions are TEXT RANGES, so they fail OPEN: a moved marker hands back
# the rest of the file and the cases would then redden for the wrong reason. Bound each one
# and refuse loudly instead, the way install-bin.test.sh does.
# ---------------------------------------------------------------------------
parser="$(awk '/^# BEGIN arg-parse/,/^# END arg-parse$/' "$ROOT/install.sh")"
parser_lines=$(printf '%s\n' "$parser" | wc -l | tr -d ' ')
if [ -z "$parser" ] || [ "$parser_lines" -gt 25 ] \
   || ! printf '%s' "$parser" | grep -q 'unknown option' \
   || ! printf '%s' "$parser" | grep -q 'END arg-parse'; then
  echo "FAIL - instrument broken: extracted $parser_lines lines from install.sh, expected the"
  echo "       BEGIN/END arg-parse block. A marker in install.sh moved or was removed."
  exit 1
fi

shargs="$(awk '/^# BEGIN sh-args/,/^# END sh-args$/' "$ROOT/install.ps1")"
shargs_lines=$(printf '%s\n' "$shargs" | wc -l | tr -d ' ')
if [ -z "$shargs" ] || [ "$shargs_lines" -gt 20 ] \
   || ! printf '%s' "$shargs" | grep -q 'shArgs' \
   || ! printf '%s' "$shargs" | grep -q 'END sh-args'; then
  echo "FAIL - instrument broken: extracted $shargs_lines lines from install.ps1, expected the"
  echo "       BEGIN/END sh-args block. A marker in install.ps1 moved or was removed."
  exit 1
fi

# The flags install.ps1 EMITS, read only from that block, so the same flag quoted in a help
# string ("'--link' needs developer mode") is not mistaken for one that is passed on.
emitted="$(printf '%s\n' "$shargs" | grep -oE "'--[a-z][a-z-]*'" | tr -d "'" | sort -u | tr '\n' ' ')"
emitted="${emitted% }"
# The flags install.sh ACCEPTS, read from the real parser's case arms.
# EVERY arm is extracted and then split on `|`, not just the ones shaped like `--flag)`. The
# narrower pattern failed OPEN, which is the worst way for this instrument to break: adding
# `-h|--help) ...` to install.sh left `accepted` at exactly `--lang --link`, so case 3 stayed
# green while `--help` was unreachable from Windows, and case 3 is reason #1 in this header.
# Measured with that arm planted before the fix: 0 failures. Now: 2.
arm_heads="$(printf '%s\n' "$parser" \
             | grep -oE '^[[:space:]]*[^ )|]+([[:space:]]*\|[[:space:]]*[^ )|]+)*\)' \
             | sed -E 's/\)$//; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^\*$')"
arms="$(printf '%s\n' "$arm_heads" | tr '|' '\n' | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//' \
        | grep -v '^$' | sort -u)"
accepted="$(printf '%s\n' "$arms" | grep -E '^-' | tr '\n' ' ')"
accepted="${accepted% }"
[ -n "$emitted" ]  || { echo "FAIL - instrument broken: no flags found in install.ps1's sh-args block"; exit 1; }
[ -n "$accepted" ] || { echo "FAIL - instrument broken: no flags found in install.sh's parser"; exit 1; }
echo "instrument: install.ps1 emits [$emitted], install.sh accepts [$accepted]"
# How many arms the extractor SAW, counted against a source it does not own: every case arm
# ends in `;;`, so the terminators count the arms independently of the pattern that reads
# their labels. Without this the count was self-confirming, and it was: the first pattern
# could not see a space around the `|`, so `-h | --help)` was invisible to both the extractor
# and the count, leaving case 3 green with --help unreachable from Windows. Measured on
# synthetic parser blocks: `-h|--help)` was caught, `-h | --help)` was not.
# The +1 is the `*)` default arm, which is dropped above because it is not an option.
n_arm_heads=$(printf '%s\n' "$arm_heads" | grep -c .)
n_semis=$(printf '%s\n' "$parser" | grep -o ';;' | grep -c .)
if [ "$((n_arm_heads + 1))" -eq "$n_semis" ]; then
  ok "the extractor saw every arm install.sh has ($n_arm_heads + the default = $n_semis)"
else
  bad "install.sh's parser has $n_semis arms but the extractor saw $((n_arm_heads + 1)); an option it"
  bad "  cannot read is an option case 3 cannot check, so a flag may be unreachable on Windows"
fi
# An arm that is not a flag would be a positional install.ps1 has no way to express, and the
# flag comparison below would simply not see it. Count them rather than let them vanish.
n_arms=$(printf '%s\n' "$arms" | grep -c .)
n_flags=$(printf '%s\n' "$accepted" | tr ' ' '\n' | grep -c .)
if [ "$n_arms" -eq "$n_flags" ]; then
  ok "every option install.sh parses is a flag ($n_flags), so the comparison below sees all of them"
else
  bad "install.sh's parser has $n_arms option labels but only $n_flags are flags; the rest are invisible to case 3"
fi

# run_parser <args...> -> RETURNS the real parser's exit status, output discarded.
# Two helpers rather than one that prints and returns both: that shape is what produced the
# empty-status bug recorded in install-bin.test.sh, so it stays split here too.
run_parser() {
  ( set +e; LINK=false; INSTALL_LANG=""; eval "$parser" ) >/dev/null 2>&1
  return $?
}
# Same, but prints what the parser said, so a case can assert the message too.
run_parser_err() {
  local errfile rc
  errfile="$TMP/parser.err"
  ( set +e; LINK=false; INSTALL_LANG=""; eval "$parser" ) >/dev/null 2>"$errfile"
  rc=$?
  cat "$errfile"
  return $rc
}

# ---------------------------------------------------------------------------
# 1. Every flag install.ps1 emits is accepted by install.sh's REAL parser.
#    A flag that needs a value is retried with one, rather than assumed: the test should not
#    carry its own table of which flags take arguments, because that table is the third copy
#    of the contract and would drift like the other two.
# ---------------------------------------------------------------------------
for f in $emitted; do
  if run_parser "$f"; then
    ok "install.sh accepts $f (bare)"
  else
    out="$(run_parser_err "$f")"
    case "$out" in
      *"needs a value"*)
        if run_parser "$f" de; then
          ok "install.sh accepts $f <value>"
        else
          bad "install.sh rejects '$f de', which install.ps1 emits"
        fi ;;
      *) bad "install.sh rejects $f, which install.ps1 emits (said: ${out:-<nothing>})" ;;
    esac
  fi
done

# 2. The instrument can FAIL. Without this, case 1 would pass just as happily against a
#    parser that accepts everything, which is the mutation it must survive.
if run_parser --definitely-not-a-flag; then
  bad "the parser accepted a bogus flag, so case 1 proves nothing"
else
  out="$(run_parser_err --definitely-not-a-flag)"
  case "$out" in
    *definitely-not-a-flag*) ok "a bogus flag is rejected AND named (canary: case 1 can fail)" ;;
    *) bad "bogus flag rejected without naming it (said: ${out:-<nothing>})" ;;
  esac
fi

# 3. The other direction, which is the drift that actually happens: install.sh grows an
#    option and the Windows door cannot reach it. Unreachable is not a cosmetic gap, it is a
#    documented capability that silently is not there on one platform.
for f in $accepted; do
  case " $emitted " in
    *" $f "*) ok "$f is reachable from install.ps1" ;;
    *) bad "install.sh accepts $f but install.ps1 never emits it (unreachable on Windows)" ;;
  esac
done

# 4. install.ps1 DELEGATES, it does not reimplement.
#    The delegation is asserted against the CODE, not the whole file: `install.sh` appears
#    twice in the comment-based help at the top, so grepping the file cannot fail and stayed
#    green on an install.ps1 with the handoff deleted. Without pwsh this is the only backing
#    for the delegation claim, so it has to be able to fail. With pwsh, case 9 proves it by
#    outcome instead.
#    What is required is an INVOCATION: a shell asked to run install.sh, i.e. `-lc` and
#    `./install.sh` on one line. Merely finding the string in the body is not enough either,
#    since the code also NAMES install.sh in the message it prints when translation fails;
#    measured, that alone kept this green with both handoff calls deleted.
body="$(sed '1,/^#>/d' "$ROOT/install.ps1")"
if printf '%s\n' "$body" | grep -qE '\-lc .*\./install\.sh'; then
  ok "install.ps1's code hands a shell the command to run ./install.sh"
else
  bad "no shell invocation of ./install.sh outside the comment header: it no longer hands off"
fi
#    The port guard below is an EARLY WARNING, not a guarantee: it knows five spellings, and
#    `cp`, `ni`, `md`, `Move-Item`, `>` and [IO.File]::WriteAllText all walk past it. Naming
#    that is the point; the class guarantee is case 9b, which watches the filesystem instead.
port=""
for verb in 'Copy-Item' 'New-Item' 'Remove-Item' 'Set-Content' 'Out-File'; do
  grep -q "$verb" "$ROOT/install.ps1" && port="$port $verb"
done
if [ -z "$port" ]; then
  ok "early warning: none of the five install primitives it knows (case 9b is the guarantee)"
else
  bad "install.ps1 has started doing the install itself ($port); that is the second implementation"
fi

# ---------------------------------------------------------------------------
# PowerShell-dependent cases. Everything above ran anywhere; everything below needs pwsh.
# When pwsh is absent these are SKIPPED, loudly and per case, never silently counted as
# passing. Note that this makes the suite's assertion count environment-dependent, which is
# why docs-claims-check reports skipped checks when it totals assertions. The SKIP lines are
# one per CASE, not per assertion, so a skipped run reports fewer lines than the assertions
# it did not run; the point of them is to name what went unverified, not to balance a sum.
# ---------------------------------------------------------------------------
PWSH="$(command -v pwsh 2>/dev/null || true)"

# mkrepo <name> -> a sandbox holding install.ps1 and a NO-OP install.sh.
# The fake install.sh is what makes running install.ps1 safe: even if a case reached the
# handoff unexpectedly, the thing on the other side cannot write to ~/.claude.
mkrepo() {
  local d="$TMP/$1"
  mkdir -p "$d"
  cp "$ROOT/install.ps1" "$d/install.ps1"
  printf '#!/usr/bin/env bash\necho "fake install.sh: $*"\n' > "$d/install.sh"
  chmod +x "$d/install.sh"
  printf '%s' "$d"
}

# fakebin <name> [bash-only] -> a PATH directory holding fake bash.exe / wsl.exe that RECORD
# their arguments instead of doing anything. $CAPTURE and $FAKE_RC steer them from the test.
# `bash-only` omits wsl.exe, which is the ONLY way to reach the Git Bash branch on a box
# where WSL would otherwise be preferred; a shared fixture serving both branches silently
# tested the WSL one twice.
fakebin() {
  local d="$TMP/$1"
  mkdir -p "$d"
  cat > "$d/bash.exe" <<'FAKE'
#!/usr/bin/env bash
printf 'bash.exe %s\n' "$*" >> "$CAPTURE"
# With EVAL_HANDOFF=1 the fake also RUNS the command string it was handed, through a real
# bash, so a case can assert that the line install.ps1 built is valid shell and not merely
# that it looks right. The thing on the other side is the sandbox's no-op install.sh.
if [ "${EVAL_HANDOFF:-0}" = 1 ]; then
  ( eval "$2" ) >> "$CAPTURE" 2>&1 || printf 'EVAL-FAILED rc=%s\n' "$?" >> "$CAPTURE"
fi
exit "${FAKE_RC:-0}"
FAKE
  cat > "$d/wsl.exe" <<'FAKE'
#!/usr/bin/env bash
printf 'wsl.exe %s\n' "$*" >> "$CAPTURE"
case "${1:-}" in
  -l)      [ "${FAKE_NO_DISTRO:-0}" = 1 ] && exit 1; printf 'Ubuntu\n'; exit 0 ;;
  # A path that does not exist by default, so a case asserting "the translated path is the
  # one bash gets" cannot pass on the untranslated one. $WSLPATH_OUT points it at a real
  # directory for the case that RUNS the command instead of reading it.
  wslpath) printf '%s\n' "${WSLPATH_OUT:-/mnt/c/repo}"; exit 0 ;;
esac
# `wsl.exe bash -lc "<cmd>"`: same eval contract as the fake bash, so the WSL arm's command
# line is executable shell by observation too, not only the Git Bash one.
if [ "${EVAL_HANDOFF:-0}" = 1 ] && [ "${1:-}" = bash ]; then
  ( eval "$3" ) >> "$CAPTURE" 2>&1 || printf 'EVAL-FAILED rc=%s\n' "$?" >> "$CAPTURE"
fi
exit "${FAKE_RC:-0}"
FAKE
  chmod +x "$d/bash.exe" "$d/wsl.exe"
  [ "${2:-}" = "bash-only" ] && rm -f "$d/wsl.exe"
  printf '%s' "$d"
}

# snapshot <dir> -> a stable listing of every file under <dir> with its hash, or nothing when
# the directory does not exist. Used to assert that a run changed NOTHING: comparing content,
# not mtimes, so a rewrite with identical bytes is correctly called no change and a touch is
# correctly ignored.
#
# `.cache/powershell/` is excluded by name: pwsh writes a startup-profile cache into whatever
# HOME it is handed, on every launch. That is the HOST RUNTIME's bookkeeping, not an install,
# and counting it would redden this case on every run, which is the fastest way to have a
# real finding ignored. Nothing else is excluded.
#
# SYMLINKS AND DIRECTORIES ARE INCLUDED, and that is the load-bearing part. `find -type f`
# alone sees a regular file and nothing else, while `install.sh --link` installs by
# SYMLINKING into ~/.claude: a `New-Item -ItemType SymbolicLink` port, the most likely way
# this file grows a second implementation, would have left the snapshot identical. Measured:
# with -type f only, a planted symlink, a symlink into HOME, a new directory and a chmod +x
# were all invisible. Links are recorded by TARGET, directories by name, files by hash.
snapshot() {
  [ -d "$1" ] || return 0
  ( cd "$1" || return 0
    # The exclusion covers the directory ITSELF as well as its contents. With -type d in
    # scope, matching only './.cache/powershell/*' left the directory entry in the listing,
    # so the first run that created it would report a change that install.ps1 did not make.
    find . -path './.cache/powershell' -prune -o -path './.cache/powershell/*' -prune -o \
         \( -type f -o -type l -o -type d \) -print 2>/dev/null \
    | sort | while IFS= read -r p; do
        if [ -L "$p" ]; then printf 'L %s -> %s\n' "$p" "$(readlink "$p")"
        elif [ -d "$p" ]; then printf 'D %s\n' "$p"
        # The MODE is recorded with the hash, because an installer that only flipped an exec
        # bit would otherwise leave the snapshot identical, and `chmod +x` is exactly what a
        # port of install.sh's bin/ step would do.
        else printf 'F %s %s\n' "$(ls -l "$p" 2>/dev/null | cut -c1-10)" "$(shasum "$p" 2>/dev/null)"
        fi
      done )
}

# run_ps1 <repo> <bindir|-> <capture> [args...] -> RETURNS pwsh's exit status.
# HOME is redirected and PATH is replaced, not extended: a real bash or wsl leaking in from
# the developer's PATH would make the branch under test depend on the machine.
run_ps1() {
  local repo="$1" bin="$2" cap="$3"; shift 3
  local path="$TMP/empty-bin"
  mkdir -p "$path"
  [ "$bin" != "-" ] && path="$bin"
  ( cd "$repo" && env -i HOME="$TMP/home" PATH="$path:/usr/bin:/bin" CAPTURE="$cap" \
      FAKE_RC="${FAKE_RC:-0}" FAKE_NO_DISTRO="${FAKE_NO_DISTRO:-0}" \
      EVAL_HANDOFF="${EVAL_HANDOFF:-0}" WSLPATH_OUT="${WSLPATH_OUT:-}" \
      "$PWSH" -NoProfile -File "$repo/install.ps1" "$@" ) >"$TMP/ps.out" 2>&1
  return $?
}

if [ -z "$PWSH" ]; then
  skip "install.ps1 parses (no pwsh on this machine: brew install powershell)"
  skip "a planted syntax error is caught (canary for the parse check)"
  skip "run outside the clone -> exit 2"
  skip "no bash anywhere -> exit 1 naming both remedies"
  skip "Git Bash handoff passes the right flags"
  skip "install.ps1 writes nothing itself (the anti-port guarantee)"
  skip "the flags reaching install.sh are accepted by the real parser"
  skip "a repo path containing an apostrophe still reaches install.sh"
  skip "install.sh's exit code propagates"
  skip "WSL is preferred when a distro exists"
  skip "the WSL arm's command line runs and reaches install.sh"
  skip "wsl.exe with NO distro falls through to Git Bash"
  skip "-UseGitBash skips an available WSL"
  skip "an invalid -Lang is refused before any handoff"
else
  # WARM THE REDIRECTED HOME ONCE, before anything snapshots it. pwsh creates its own
  # bookkeeping under HOME on first launch (`.local/share/powershell/Modules`, `.cache`), and
  # the anti-port case compares a before/after snapshot of that same HOME to prove install.ps1
  # writes nothing itself. Pruning `.cache/powershell` covered one directory; the others were
  # invisible only because earlier cases happen to launch pwsh first, which made a REORDERING
  # of the cases, or a pwsh version that invents a seventh directory, turn the guarantee into a
  # false failure blamed on install.ps1. One warm-up removes the ordering dependency for every
  # directory at once, present and future, instead of naming them one by one. The prune stays:
  # `.cache/powershell/StartupProfileData-NonInteractive` is rewritten on EVERY launch, which
  # is churn no warm-up can settle.
  mkdir -p "$TMP/empty-bin" "$TMP/home"
  env -i HOME="$TMP/home" PATH="$TMP/empty-bin:/usr/bin:/bin" \
      "$PWSH" -NoProfile -Command exit >/dev/null 2>&1

  cat > "$TMP/parse.ps1" <<'PS'
param([string]$Path)
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$errors) | Out-Null
if ($errors -and $errors.Count -gt 0) { $errors | ForEach-Object { Write-Output $_.Message }; exit 1 }
exit 0
PS

  # 5. It parses. The cheapest possible defect in a script nobody here can run is that it is
  #    not a valid script at all.
  if out="$("$PWSH" -NoProfile -File "$TMP/parse.ps1" "$ROOT/install.ps1" 2>&1)"; then
    ok "install.ps1 parses under PowerShell $("$PWSH" -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>/dev/null)"
  else
    bad "install.ps1 does not parse: $out"
  fi

  # 6. The canary for case 5: a file with a planted syntax error must be REPORTED. A parse
  #    check that returns 0 on everything is indistinguishable from one that works.
  sed 's/^param(/param( {{/' "$ROOT/install.ps1" > "$TMP/broken.ps1"
  if "$PWSH" -NoProfile -File "$TMP/parse.ps1" "$TMP/broken.ps1" >/dev/null 2>&1; then
    bad "a planted syntax error parsed cleanly, so case 5 proves nothing"
  else
    ok "a planted syntax error is caught (canary: case 5 can fail)"
  fi

  # 7. Run from the wrong directory. The first thing a Windows user does wrong is run the
  #    script from outside the clone; that must be a named refusal, not a confusing failure
  #    deeper in.
  lone="$TMP/lone"; mkdir -p "$lone"; cp "$ROOT/install.ps1" "$lone/"
  run_ps1 "$lone" - "$TMP/cap-lone"; rc=$?
  [ "$rc" = "2" ] && ok "run outside the clone -> exit 2" || bad "run outside the clone -> exit $rc (want 2)"
  grep -q 'install.sh is not next to this script' "$TMP/ps.out" \
    && ok "and it says what is wrong" \
    || bad "exit 2 without explaining why (said: $(head -1 "$TMP/ps.out"))"

  # 8. No bash reachable at all. This is the most likely first run on a clean Windows box,
  #    and the message is the whole value of it: both remedies, named, in one place.
  repo="$(mkrepo repo-nobash)"
  run_ps1 "$repo" - "$TMP/cap-nobash"; rc=$?
  [ "$rc" = "1" ] && ok "no bash anywhere -> exit 1" || bad "no bash anywhere -> exit $rc (want 1)"
  if grep -q 'wsl --install' "$TMP/ps.out" && grep -q 'winget install' "$TMP/ps.out"; then
    ok "and both remedies are named (wsl --install, winget install)"
  else
    bad "the no-bash message does not name both remedies"
  fi

  # 9. The Git Bash handoff, end to end against a fake bash.exe that RUNS what it is handed.
  #    This is the case that turns "written" into "observed", and running the line matters:
  #    the arguments are single-quoted for bash, so what install.sh finally receives in $@ is
  #    a fact about quote removal, not about the string install.ps1 printed.
  bin="$(fakebin bin-gitbash bash-only)"; repo="$(mkrepo repo-gitbash)"; cap="$TMP/cap-gitbash"; : > "$cap"
  before="$(snapshot "$TMP/home"; snapshot "$repo")"
  EVAL_HANDOFF=1 run_ps1 "$repo" "$bin" "$cap" -Link -Lang de; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  [ "$rc" = "0" ] && ok "Git Bash handoff exits 0 when the shell succeeds" \
                  || bad "Git Bash handoff exited $rc (want 0); called: ${called:-<nothing>}"
  case "$called" in
    *"./install.sh"*) ok "it runs ./install.sh through bash, rather than installing anything itself" ;;
    *) bad "bash was not asked to run ./install.sh (called: ${called:-<nothing>})" ;;
  esac
  case "$called" in
    *"fake install.sh: --link --lang de"*) ok "install.sh receives exactly: --link --lang de" ;;
    *) bad "flags did not survive the handoff (called: ${called:-<nothing>})" ;;
  esac
  case "$called" in
    *"cd '$repo'"*) ok "it hands off from the clone directory" ;;
    *) bad "the handoff does not cd into the clone (called: ${called:-<nothing>})" ;;
  esac

  # 9b. THE ANTI-PORT GUARANTEE, by outcome. The denylist in case 4 knows five spellings and
  #     a sixth walks past it, which is the instance-patch shape this repo's lessons.md
  #     forbids and which commit 2423381 removed from community-refresh.test.sh two commits
  #     ago. Here the class is decidable: install.ps1's whole job is to delegate, so it must
  #     leave the filesystem BYTE-IDENTICAL, whatever primitive a future edit reaches for.
  #     The run above did the work; this reads the same two trees back.
  after="$(snapshot "$TMP/home"; snapshot "$repo")"
  if [ "$before" = "$after" ]; then
    ok "install.ps1 changed nothing under HOME or in the clone (it only delegates)"
  else
    bad "install.ps1 modified the filesystem itself; it is becoming a second implementation"
    printf '%s\n' "$before" > "$TMP/fs.before"; printf '%s\n' "$after" > "$TMP/fs.after"
    diff "$TMP/fs.before" "$TMP/fs.after" | head -10 | sed 's/^/       /'
  fi
  #  And the comparison must be able to SEE each shape an install leaves behind, or "nothing
  #  changed" is two blind reads agreeing. A file, a DIRECTORY, and a SYMLINK: the last is
  #  what `install.sh --link` actually creates, so a canary that plants only a file would
  #  have certified a snapshot that could not see the likeliest port.
  printf 'mode-probe\n' > "$TMP/home/mode-probe"; chmod 644 "$TMP/home/mode-probe"
  before="$(snapshot "$TMP/home"; snapshot "$repo")"
  for shape in file dir link mode; do
    case "$shape" in
      file) printf 'planted\n' > "$TMP/home/planted-by-the-test" ;;
      dir)  mkdir -p "$TMP/home/planted-dir" ;;
      link) ln -s "$repo/install.sh" "$TMP/home/planted-link" ;;
      mode) chmod +x "$TMP/home/mode-probe" ;;   # same bytes, different mode
    esac
    if [ "$before" != "$(snapshot "$TMP/home"; snapshot "$repo")" ]; then
      ok "the comparison notices a planted $shape (canary: case 9b can fail)"
    else
      bad "the filesystem comparison cannot see a planted $shape, so case 9b is blind to it"
    fi
    rm -rf "$TMP/home/planted-by-the-test" "$TMP/home/planted-dir" "$TMP/home/planted-link"
    chmod 644 "$TMP/home/mode-probe"
  done
  rm -f "$TMP/home/mode-probe"

  # 10. Close the loop: feed install.sh's real parser exactly the arguments install.sh
  #     RECEIVED (post quote-removal, read out of the no-op's echo), not the string that was
  #     printed. Case 1 checked the flags one at a time as install.ps1 spells them; this
  #     checks the whole line as it arrives, including order and spacing.
  line="$(printf '%s\n' "$called" | sed -n 's|^fake install\.sh: ||p' | head -1)"
  if [ -n "$line" ]; then
    # shellcheck disable=SC2086
    if run_parser $line; then
      ok "the arguments that arrived ('$line') are accepted by install.sh's parser"
    else
      bad "install.sh rejects the arguments install.ps1 sent it: '$line'"
    fi
  else
    bad "could not read install.sh's arguments out of the handoff (called: ${called:-<nothing>})"
  fi

  # 10b. A path with an APOSTROPHE in it, which a Windows home directory can have
  #      (C:\Users\O'Brien\...). The command line is assembled as a single-quoted bash
  #      string, so an unescaped apostrophe closes that string early and the rest of the path
  #      becomes shell syntax. Here the fake bash RUNS what it was handed, so the assertion
  #      is whether the no-op install.sh was actually reached, not how the line looks.
  bin="$(fakebin bin-quote bash-only)"; repo="$(mkrepo "repo-o'brien")"; cap="$TMP/cap-quote"; : > "$cap"
  EVAL_HANDOFF=1 run_ps1 "$repo" "$bin" "$cap" -Link; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  case "$called" in
    *"fake install.sh: --link"*) ok "a repo path containing an apostrophe still reaches install.sh" ;;
    *) bad "an apostrophe in the path broke the handoff (called: ${called:-<nothing>})" ;;
  esac
  case "$called" in
    *EVAL-FAILED*) bad "the command line install.ps1 built is not valid shell (called: $called)" ;;
    *) ok "and the line it built runs as shell without error" ;;
  esac

  # 11. The exit code is the user's only signal that the install failed. Swallowing it would
  #     print "Odeo installed." over a failed run.
  bin="$(fakebin bin-rc)"; repo="$(mkrepo repo-rc)"; cap="$TMP/cap-rc"; : > "$cap"
  FAKE_RC=7 run_ps1 "$repo" "$bin" "$cap"; rc=$?
  [ "$rc" = "7" ] && ok "install.sh's exit code propagates (7)" || bad "exit code swallowed: got $rc, want 7"
  grep -q 'Odeo installed' "$TMP/ps.out" \
    && bad "it reported success over a failed install" \
    || ok "and a failed install is not reported as success"

  # 12. WSL is preferred when a distro exists. Asserted by which fake got called, not by
  #     reading the branch.
  bin="$(fakebin bin-wsl)"; repo="$(mkrepo repo-wsl)"; cap="$TMP/cap-wsl"; : > "$cap"
  run_ps1 "$repo" "$bin" "$cap"; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  case "$called" in
    *"wsl.exe bash -lc"*) ok "WSL is used when a distro is listed" ;;
    *) bad "a listed distro did not take the WSL branch (called: ${called:-<nothing>})" ;;
  esac
  case "$called" in
    *wslpath*) ok "and the Windows path is translated with wslpath first" ;;
    *) bad "the repo path was passed to WSL untranslated" ;;
  esac
  #  The translation must also be USED. Calling wslpath and then handing bash the original
  #  C:\ path is the shape where the call looks right and the install still cannot find the
  #  repo, so assert the cd carries what wslpath returned.
  case "$called" in
    *"cd '/mnt/c/repo'"*) ok "and bash is given the translated path, not the Windows one" ;;
    *) bad "wslpath was called but its output was not used (called: ${called:-<nothing>})" ;;
  esac

  # 12b. The WSL arm's command line must also be RUNNABLE, not merely well-shaped. Case 12
  #      reads the string; this one hands it to a shell, with wslpath pointed at a directory
  #      that exists so `cd && ./install.sh` can actually complete. Without this the Git Bash
  #      arm was the only one whose line was ever executed, and the two arms build it with
  #      different variables.
  bin="$(fakebin bin-wsl-run)"; repo="$(mkrepo repo-wsl-run)"; cap="$TMP/cap-wsl-run"; : > "$cap"
  before="$(snapshot "$TMP/home"; snapshot "$repo")"
  EVAL_HANDOFF=1 WSLPATH_OUT="$repo" run_ps1 "$repo" "$bin" "$cap" -Lang fr; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  case "$called" in
    *"fake install.sh: --lang fr"*) ok "the WSL arm's line runs, and install.sh receives --lang fr" ;;
    *) bad "the WSL arm's command line did not reach install.sh (called: ${called:-<nothing>})" ;;
  esac
  #  The byte-identity guarantee applies to THIS arm too, and it is the one that runs on a
  #  real Windows install. Case 9b watched the Git Bash arm; the two build their command from
  #  different variables, so neither covers the other.
  if [ "$before" = "$(snapshot "$TMP/home"; snapshot "$repo")" ]; then
    ok "and the WSL arm changed nothing under HOME or in the clone either"
  else
    bad "the WSL arm modified the filesystem itself"
  fi

  # 13. THE DEFECT THE CODE CLAIMS TO PREVENT, verified: wsl.exe ships on modern Windows
  #     with no distro installed. Branching on the command's existence would hand the
  #     install to a WSL that cannot run a single script. With no distro listed it must fall
  #     through to Git Bash instead.
  bin="$(fakebin bin-nodistro)"; repo="$(mkrepo repo-nodistro)"; cap="$TMP/cap-nodistro"; : > "$cap"
  FAKE_NO_DISTRO=1 run_ps1 "$repo" "$bin" "$cap"; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  case "$called" in
    *"wsl.exe bash -lc"*) bad "wsl.exe with NO distro was still used for the install" ;;
    *"bash.exe -lc"*)     ok "wsl.exe with no distro falls through to Git Bash" ;;
    *) bad "no distro and no fallback: nothing ran (called: ${called:-<nothing>})" ;;
  esac

  # 14. -UseGitBash must win over an available WSL, otherwise the documented escape hatch is
  #     decoration.
  bin="$(fakebin bin-force)"; repo="$(mkrepo repo-force)"; cap="$TMP/cap-force"; : > "$cap"
  run_ps1 "$repo" "$bin" "$cap" -UseGitBash; rc=$?
  called="$(cat "$cap" 2>/dev/null)"
  case "$called" in
    *"bash.exe -lc"*) ok "-UseGitBash skips an available WSL" ;;
    *) bad "-UseGitBash still went to WSL (called: ${called:-<nothing>})" ;;
  esac

  # 15. An unsupported language must be refused at the door, BEFORE any handoff. Passing it
  #     through would surface as a failure from a script the Windows user never invoked.
  bin="$(fakebin bin-lang)"; repo="$(mkrepo repo-lang)"; cap="$TMP/cap-lang"; : > "$cap"
  run_ps1 "$repo" "$bin" "$cap" -Lang es; rc=$?
  [ "$rc" != "0" ] && ok "an unsupported -Lang is refused (exit $rc)" || bad "-Lang es was accepted"
  if [ -s "$cap" ]; then
    bad "it reached the shell before validating -Lang (called: $(cat "$cap"))"
  else
    ok "and nothing was handed to bash before the refusal"
  fi
fi

echo ""
if [ "$skipped" -gt 0 ]; then
  echo "install-ps1: $skipped check(s) SKIPPED (no pwsh here), so this run proves less than a full one."
fi
if [ "$fail" -eq 0 ]; then
  echo "install-ps1: all $pass assertions passed."
else
  echo "install-ps1: $fail FAILURE(S) above."
fi
exit "$fail"
