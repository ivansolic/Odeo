#!/usr/bin/env bash
# Tests for bin/ledger-backup.sh, the backup of the files git deliberately does not carry.
#
# WHY THIS EXISTS. The step this program replaces was prose in /retro, and prose has one
# failure mode no reader can see: it describes a success. The reviewed finding was exactly
# that, "the failing branch does not exist, so the only stated outcome is success, and a
# silent failure gets reported to the user as a completed backup."
#
# So the contract under test is NOT "the files arrive". It is that every way this can fail is
# DISTINGUISHABLE from success, by exit code, and that a failure never leaves the stamp that
# makes `--check` say "up to date". The stamp is the thing a Stop hook reads, so a stamp
# written after a refused push would convert a loud failure into a quiet false claim, which is
# worse than having no backup at all: you would stop looking.
#
# Hermetic: the "remote" is a local bare repo, the "directory target" is a temp dir. No
# network, no credentials, nothing outside $TMP.
#
# Run: bash tests/ledger-backup.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/ledger-backup.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

[ -x "$SCRIPT" ] || { echo "FAIL - instrument broken: $SCRIPT missing or not executable"; exit 1; }

TMP="$(mktemp -d)" || { echo "FAIL - no temp dir"; exit 1; }
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export GIT_TERMINAL_PROMPT=0

# mkproject <name> [config-line] -> a git work tree with a ledger, optionally configured.
# The config goes in CLAUDE.md here; case 9 covers CLAUDE.local.md winning over it.
mkproject() {
  local d="$TMP/$1"
  mkdir -p "$d/.claude/tasks"
  ( cd "$d" && git init -q . ) >/dev/null 2>&1
  printf 'ledger v1\n' > "$d/.claude/tasks/todo.md"
  printf 'lessons v1\n' > "$d/.claude/tasks/lessons.md"
  printf '# Project\n' > "$d/CLAUDE.md"
  [ -n "${2:-}" ] && printf '%s\n' "$2" >> "$d/CLAUDE.md"
  printf '%s' "$d"
}

# mkremote <name> -> a bare repo usable as a git target, wired as remote "backup".
mkremote() {
  local b="$TMP/$1.git"
  git init -q --bare "$b" >/dev/null 2>&1
  printf '%s' "$b"
}

run() { # run <project> [args...] -> prints output, RETURNS the exit code
  local p="$1"; shift
  "$SCRIPT" "$@" "$p" 2>&1
}

stamp_of() { git -C "$1" rev-parse --absolute-git-dir 2>/dev/null; }
has_stamp() { [ -f "$(stamp_of "$1")/odeo-ledger-backup-stamp" ]; }

# 1. Not configured: exit 3, and the message says WHERE to put the line. This is not an
#    error state, it is "nothing was promised", and a caller must be able to tell it apart
#    from a failed backup so it can stay quiet instead of nagging.
p="$(mkproject p1)"
out="$(run "$p")"; rc=$?
[ "$rc" = 3 ] && ok "no ledger_backup: line -> exit 3" || bad "unconfigured -> exit $rc (want 3)"
case "$out" in *ledger_backup:*CLAUDE.local.md*|*CLAUDE.local.md*ledger_backup:*)
  ok "and it names both the field and where to put it" ;;
  *) bad "the unconfigured message does not say how to configure it (got: $out)" ;;
esac
has_stamp "$p" && bad "an unconfigured run left a stamp" || ok "and it leaves no stamp"

# 2. git target, happy path: the files land ON THE BRANCH, under internal-not-in-git/.
b="$(mkremote r2)"; p="$(mkproject p2 "ledger_backup: git backup internal-files")"
git -C "$p" remote add backup "$b" >/dev/null 2>&1
out="$(run "$p")"; rc=$?
[ "$rc" = 0 ] && ok "git target: exit 0" || bad "git target failed: exit $rc ($out)"
landed="$(git -C "$b" show "internal-files:internal-not-in-git/todo.md" 2>/dev/null)"
[ "$landed" = "ledger v1" ] && ok "and todo.md is readable from the branch, with its content" \
  || bad "todo.md did not reach the branch (got: ${landed:-<nothing>})"
git -C "$b" show "internal-files:internal-not-in-git/lessons.md" >/dev/null 2>&1 \
  && ok "and lessons.md is there too" || bad "lessons.md did not reach the branch"
has_stamp "$p" && ok "and a verified backup leaves a stamp" || bad "no stamp after a successful backup"

# 3. The stamp is INSIDE the git dir, so no project has to gitignore it. A stamp in the work
#    tree would be committed by the next `git add -A` in a project that did not know to
#    exclude it, which is how local state leaks into a public repo.
st="$(stamp_of "$p")/odeo-ledger-backup-stamp"
case "$st" in */.git/*) ok "the stamp lives under .git, so it can never be committed" ;;
  *) bad "the stamp is in the work tree: $st" ;; esac

# 4. Run again with nothing changed: still exit 0, no empty commit, and the stamp MOVES.
#    A quiet week must not accumulate into "behind", or the warning trains the user to ignore
#    it, which costs more than the warning is worth.
before_commits=$(git -C "$b" rev-list --count internal-files 2>/dev/null || echo 0)
sleep 1
out="$(run "$p")"; rc=$?
after_commits=$(git -C "$b" rev-list --count internal-files 2>/dev/null || echo 0)
[ "$rc" = 0 ] && ok "an unchanged ledger is still exit 0" || bad "unchanged ledger -> exit $rc"
[ "$before_commits" = "$after_commits" ] && ok "and it creates no empty commit" \
  || bad "an unchanged ledger still committed ($before_commits -> $after_commits)"
run "$p" --check >/dev/null; rc=$?
[ "$rc" = 0 ] && ok "and --check reports up to date" || bad "--check says behind right after a backup (rc=$rc)"

# 5. --check sees a ledger edited AFTER the last backup. This is the whole point of the
#    stamp: it answers "is the copy current", not "did someone run the command".
sleep 1
printf 'ledger v2\n' > "$p/.claude/tasks/todo.md"
out="$(run "$p" --check)"; rc=$?
[ "$rc" = 1 ] && ok "an edited ledger -> --check exits 1 (behind)" || bad "--check missed an edit (rc=$rc)"
case "$out" in *BEHIND*) ok "and it says how far behind, in words" ;;
  *) bad "--check does not report the lag (got: $out)" ;; esac

# 6. PUSH REFUSED is the failure that must never look like success. Simulated with a
#    pre-receive hook, which is what branch protection does on the server side.
b2="$(mkremote r6)"; p2="$(mkproject p6 "ledger_backup: git backup internal-files")"
git -C "$p2" remote add backup "$b2" >/dev/null 2>&1
printf '#!/bin/sh\necho "refused by protection" >&2\nexit 1\n' > "$b2/hooks/pre-receive"
chmod +x "$b2/hooks/pre-receive"
out="$(run "$p2")"; rc=$?
[ "$rc" = 5 ] && ok "a refused push -> exit 5" || bad "refused push -> exit $rc (want 5)"
case "$out" in *"NOTHING was backed up"*) ok "and it says plainly that nothing was backed up" ;;
  *) bad "a refused push did not say the backup failed (got: $out)" ;; esac
has_stamp "$p2" && bad "a refused push left a stamp, so --check would claim it is current" \
  || ok "and NO stamp is left, so --check still reports behind"
out="$(run "$p2" --check)"; rc=$?
[ "$rc" = 1 ] && ok "--check still says behind after a refused push (the silent-failure case)" \
  || bad "--check reports up to date after a failed backup (rc=$rc)"

# 7. Unreachable target: a remote that is not there at all.
p3="$(mkproject p7 "ledger_backup: git backup internal-files")"
git -C "$p3" remote add backup "$TMP/definitely-not-a-repo.git" >/dev/null 2>&1
out="$(run "$p3")"; rc=$?
[ "$rc" = 4 ] && ok "an unreachable remote -> exit 4" || bad "unreachable remote -> exit $rc (want 4)"
has_stamp "$p3" && bad "an unreachable target left a stamp" || ok "and leaves no stamp"

# 8. A remote NAME that does not exist in the repo at all, which is a different mistake and
#    deserves a different message from "offline".
p4="$(mkproject p8 "ledger_backup: git nosuchremote internal-files")"
out="$(run "$p4")"; rc=$?
[ "$rc" = 4 ] && ok "an unknown remote name -> exit 4" || bad "unknown remote -> exit $rc"
case "$out" in *"no remote named"*) ok "and the message names the missing remote, not the network" ;;
  *) bad "unknown remote blamed something else (got: $out)" ;; esac

# 9. CLAUDE.local.md WINS over CLAUDE.md. A backup target is usually private, and a public
#    repo should not have to name where its owner keeps their copy.
d="$TMP/localwins"; b3="$(mkremote r9)"
p5="$(mkproject localwins "ledger_backup: git backup wrong-branch")"
printf 'ledger_backup: git backup right-branch\n' > "$p5/CLAUDE.local.md"
git -C "$p5" remote add backup "$b3" >/dev/null 2>&1
out="$(run "$p5")"; rc=$?
[ "$rc" = 0 ] && ok "CLAUDE.local.md is used: exit 0" || bad "local config run failed: $rc ($out)"
git -C "$b3" rev-parse --verify right-branch >/dev/null 2>&1 \
  && ok "and the branch from CLAUDE.local.md is the one written" \
  || bad "the public CLAUDE.md branch won over the private one"
git -C "$b3" rev-parse --verify wrong-branch >/dev/null 2>&1 \
  && bad "the CLAUDE.md branch was written too" || ok "and the CLAUDE.md value was not used at all"

# 10. dir target: the plain case, for a synced folder.
p6="$(mkproject p10)"; dest="$TMP/synced/ledger"
mkdir -p "$TMP/synced"
printf 'ledger_backup: dir %s\n' "$dest" >> "$p6/CLAUDE.md"
out="$(run "$p6")"; rc=$?
[ "$rc" = 0 ] && ok "dir target: exit 0" || bad "dir target failed: exit $rc ($out)"
[ -f "$dest/internal-not-in-git/todo.md" ] && ok "and the file is in the directory" \
  || bad "nothing was copied to $dest"

# 11. A mistyped dir path must FAIL, not be created. Backing up into a directory nobody syncs
#     reads as success and protects nothing, which is the same lie as a refused push.
p7="$(mkproject p11 "ledger_backup: dir $TMP/no/such/parent/ledger")"
out="$(run "$p7")"; rc=$?
[ "$rc" = 4 ] && ok "a dir target whose parent does not exist -> exit 4" \
  || bad "a mistyped dir path -> exit $rc (want 4)"
[ -d "$TMP/no" ] && bad "it created the mistyped path anyway" || ok "and it does not create it"

# 12. Nothing to back up: no ledger files at all.
p8="$(mkproject p12 "ledger_backup: dir $TMP/synced/ledger2")"
rm -f "$p8/.claude/tasks/todo.md" "$p8/.claude/tasks/lessons.md"
out="$(run "$p8")"; rc=$?
[ "$rc" = 6 ] && ok "no ledger files -> exit 6" || bad "empty ledger -> exit $rc (want 6)"

# 13. An unknown kind is a usage error, not a silent skip. A typo like `ledger_backup: github`
#     must not read as "not configured", which is the exit code a caller stays quiet about.
p9="$(mkproject p13 "ledger_backup: github ivan/whatever")"
out="$(run "$p9")"; rc=$?
[ "$rc" = 2 ] && ok "an unknown kind -> exit 2, distinct from 'not configured'" \
  || bad "unknown kind -> exit $rc (want 2)"

# 14. Outside a git work tree: exit 2, because the stamp has nowhere to live and every caller
#     of this program runs inside a project repo.
nogit="$TMP/nogit"; mkdir -p "$nogit/.claude/tasks"
printf 'x\n' > "$nogit/.claude/tasks/todo.md"
printf 'ledger_backup: dir %s\n' "$TMP/synced/ledger3" > "$nogit/CLAUDE.md"
out="$(run "$nogit")"; rc=$?
[ "$rc" = 2 ] && ok "outside a git work tree -> exit 2" || bad "non-repo -> exit $rc (want 2)"

# 15. --check NEVER writes. A Stop hook runs it on every session end, so a check that created
#     or moved a stamp would report "up to date" forever after its first run.
p10="$(mkproject p15 "ledger_backup: dir $TMP/synced/ledger4")"
run "$p10" --check >/dev/null 2>&1
has_stamp "$p10" && bad "--check created a stamp" || ok "--check writes no stamp (it only reports)"
out="$(run "$p10" --check)"; rc=$?
[ "$rc" = 1 ] && ok "and a never-backed-up ledger reports behind, not up to date" \
  || bad "a never-backed-up ledger reported rc=$rc"
case "$out" in *NEVER*) ok "and says it has never been backed up, rather than a lag in minutes" ;;
  *) bad "the never-backed-up message is not distinguishable (got: $out)" ;; esac

# 16. THE STEADY STATE: an existing branch whose content CHANGED. Cases 2 and 9 create the
#     branch through the orphan path and case 4 stops at "already current", so clone -> commit
#     -> push, the path every run after the first takes and the only one that pushes from a
#     shallow clone, had no coverage at all.
b4="$(mkremote r16)"; p16="$(mkproject p16 "ledger_backup: git backup internal-files")"
git -C "$p16" remote add backup "$b4" >/dev/null 2>&1
run "$p16" >/dev/null 2>&1
sleep 1
printf 'ledger v2-changed\n' > "$p16/.claude/tasks/todo.md"
out="$(run "$p16")"; rc=$?
[ "$rc" = 0 ] && ok "a changed ledger on an existing branch: exit 0" || bad "second backup failed: $rc ($out)"
landed="$(git -C "$b4" show internal-files:internal-not-in-git/todo.md 2>/dev/null)"
[ "$landed" = "ledger v2-changed" ] && ok "and the branch carries the NEW content" \
  || bad "the second backup did not update the branch (got: ${landed:-<nothing>})"
n=$(git -C "$b4" rev-list --count internal-files 2>/dev/null || echo 0)
[ "$n" = 2 ] && ok "and the branch has exactly 2 commits, one per real change" \
  || bad "expected 2 commits on the branch, found $n"

# 17. Someone else advanced the branch between our runs (a second machine, another clone).
#     A shallow clone that force-pushed would silently drop their work, so the contract is:
#     fast-forward or fail. Their file must still be there afterwards.
third="$TMP/third"; git clone -q "$b4" "$third" >/dev/null 2>&1
git -C "$third" checkout -q internal-files >/dev/null 2>&1
printf 'from another machine\n' > "$third/internal-not-in-git/other-machine.md"
git -C "$third" add -A >/dev/null 2>&1
git -C "$third" commit -q -m "other machine" >/dev/null 2>&1
git -C "$third" push -q origin internal-files >/dev/null 2>&1
sleep 1
printf 'ledger v3\n' > "$p16/.claude/tasks/todo.md"
out="$(run "$p16")"; rc=$?
[ "$rc" = 0 ] && ok "a branch advanced by someone else still accepts our backup" \
  || bad "backup failed after a third party advanced the branch: $rc ($out)"
git -C "$b4" show internal-files:internal-not-in-git/other-machine.md >/dev/null 2>&1 \
  && ok "and their file survived (no force push)" \
  || bad "the other machine's commit was destroyed"

# 18. A RELATIVE dir target is refused. Run from somewhere else entirely, it resolves against
#     the caller's directory; run from the project root, which is what /retro does, it writes
#     the ledger INTO the work tree where nothing ignores it and reports success. That is this
#     program putting into git the content it exists to keep out of git.
p18="$(mkproject p18 "ledger_backup: dir backupdir")"
elsewhere="$TMP/elsewhere"; mkdir -p "$elsewhere"
out="$( cd "$elsewhere" && "$SCRIPT" "$p18" 2>&1 )"; rc=$?
[ "$rc" = 2 ] && ok "a relative dir target -> exit 2" || bad "relative dir -> exit $rc (want 2)"
[ -e "$elsewhere/backupdir" ] && bad "it wrote into the caller's directory anyway" \
  || ok "and nothing is written next to the caller"
out="$( cd "$p18" && "$SCRIPT" . 2>&1 )"; rc=$?
[ -e "$p18/backupdir" ] && bad "run from the project root it wrote the ledger into the work tree" \
  || ok "and nothing is written into the work tree"
has_stamp "$p18" && bad "a refused relative target still stamped success" || ok "and leaves no stamp"

# 19. A target INSIDE the project is refused even when absolute: a copy in the work tree is
#     the same file with a second name and the same single point of failure, and it would be
#     committed by the next `git add -A`.
p19="$(mkproject p19)"
printf 'ledger_backup: dir %s/backups\n' "$p19" >> "$p19/CLAUDE.md"
out="$(run "$p19")"; rc=$?
[ "$rc" = 2 ] && ok "an absolute target inside the project -> exit 2" \
  || bad "in-project target -> exit $rc (want 2)"
case "$out" in *"inside the project"*) ok "and it says why, rather than blaming the path" ;;
  *) bad "the refusal does not explain itself (got: $out)" ;; esac

# 20. The placeholder from the template is NOT configuration. Every project scaffolded from
#     project-templates/ carried a live `ledger_backup: git <remote-name> <branch>` because the
#     documentation example matched the same grep that reads the setting; the program then
#     failed with "no remote named <remote-name>" and the Stop hook nagged every session.
#     Exit 3, the silent one, because a placeholder means nothing was promised.
p20="$(mkproject p20 "ledger_backup: git <remote-name> <branch>")"
out="$(run "$p20")"; rc=$?
[ "$rc" = 3 ] && ok "a template placeholder -> exit 3 (not configured), not a broken target" \
  || bad "placeholder -> exit $rc (want 3)"
case "$out" in *placeholder*) ok "and it says the line is still the placeholder" ;;
  *) bad "the placeholder message does not name the cause (got: $out)" ;; esac

# 21. Every `exit N` the program can produce has a row in the /retro table that tells an agent
#     what to say about it. The reviewed defect in round 1 was prose promising what nothing
#     implemented; the defect in round 2 was prose describing the implementation INCOMPLETELY
#     (the table had no row for 2, which is what a config typo returns). Same shape, one level
#     up, so it gets a mechanism instead of a third wording.
SKILL="$ROOT/skills/retro/SKILL.md"
if [ -f "$SKILL" ]; then
  # EVERY `exit N` in the file, with no shape rules. The earlier pattern anchored at line
  # start and demanded a trailing `;`, so a one-line case arm (`--check) ...; exit 2 ;;`) and
  # an `|| { ...; exit 4; }` were both invisible, and the check passed only because those
  # codes happened to appear elsewhere in a shape it could see. Over-matching a code that
  # appears in a comment costs one extra table row; under-matching costs the contract.
  missing=""
  for code in $(grep -oE 'exit [0-9]+' "$SCRIPT" | grep -oE '[0-9]+' | sort -un); do
    [ "$code" = 1 ] && continue   # --check only; the table says so in words
    grep -qE "^\| $code \|" "$SKILL" || missing="$missing $code"
  done
  if [ -z "$missing" ]; then
    ok "every exit code the program can return has a row in /retro's table"
  else
    bad "exit code(s)$missing are reachable but have no row in skills/retro/SKILL.md"
  fi
else
  bad "skills/retro/SKILL.md is missing, so the exit-code contract could not be checked"
fi

# 22. The containment guard, against paths that are inside the project WITHOUT LOOKING LIKE IT.
#     The first version compared "$dest/" to "$PROJECT_DIR"/* as raw strings, and three
#     ordinary shapes walked through it, each landing the ledger in the work tree at exit 0
#     with a stamp written. The guard asks git now, so it answers about the repository the
#     path is really in rather than about how the path was spelled.
p22="$(mkproject p22)"
p22_real="$(cd "$p22" && pwd -P)"
ln -s "$p22_real" "$TMP/sneaky-link"
mkdir -p "$TMP/sideways"
i=0
for shape in "$TMP/sneaky-link/backups" "$TMP/sideways/../$(basename "$p22")/backups"; do
  i=$((i + 1))
  printf 'ledger_backup: dir %s\n' "$shape" > "$p22/CLAUDE.local.md"
  out="$(run "$p22")"; rc=$?
  [ "$rc" = 2 ] && ok "a disguised in-project target is refused ($i: exit 2)" \
    || bad "disguised target $i reached exit $rc: $shape"
  [ -e "$p22/backups" ] && bad "and it wrote the ledger into the work tree ($i)" \
    || ok "and nothing landed in the work tree ($i)"
  has_stamp "$p22" && bad "and it stamped success for a refused target ($i)" \
    || ok "and no stamp was written ($i)"
done
#     Case-only difference, which matters because macOS ships a case-insensitive filesystem:
#     the path resolves to the same directory while the strings differ. Asserted as "does not
#     succeed" rather than a specific code, because on a case-SENSITIVE filesystem the same
#     line is simply a missing directory, and both answers are correct refusals.
upper="$(dirname "$p22_real")/$(basename "$p22_real" | tr 'a-z' 'A-Z')"
printf 'ledger_backup: dir %s/backups\n' "$upper" > "$p22/CLAUDE.local.md"
out="$(run "$p22")"; rc=$?
[ "$rc" != 0 ] && ok "a case-differing in-project target does not succeed (exit $rc)" \
  || bad "a case-differing path backed up into the project and reported success"
[ -e "$p22/backups" ] && bad "and it wrote into the work tree via the case-differing path" \
  || ok "and nothing landed in the work tree"
rm -f "$p22/CLAUDE.local.md"

# 23. A REAL directory whose name contains an angle bracket is not a placeholder. Rejecting
#     any value containing `<` or `>` would turn the backup off for it silently, and the hook
#     would then stay quiet forever about a project that asked for a backup.
odd="$TMP/od>d"; mkdir -p "$odd"
p23="$(mkproject p23 "ledger_backup: dir $odd/ledger")"
out="$(run "$p23")"; rc=$?
[ "$rc" = 0 ] && ok "a real path containing '>' still backs up (exit 0)" \
  || bad "a legitimate path was read as a placeholder: exit $rc ($out)"
[ -f "$odd/ledger/internal-not-in-git/todo.md" ] && ok "and the file is there" \
  || bad "nothing was copied to the odd-named directory"

# 24. An unreadable ledger file must FAIL the git branch too. The cp there was unchecked, so a
#     failed copy left the file the CLONE brought (the previous backup), `add -A` saw no
#     change, and the run reported "already current" and stamped it: a skipped update that
#     cannot be told from a successful one, on the branch beside the one where that reasoning
#     was already applied.
b24="$(mkremote r24)"; p24="$(mkproject p24 "ledger_backup: git backup internal-files")"
git -C "$p24" remote add backup "$b24" >/dev/null 2>&1
run "$p24" >/dev/null 2>&1                      # first backup succeeds
sleep 1
printf 'ledger v2\n' > "$p24/.claude/tasks/todo.md"
chmod 000 "$p24/.claude/tasks/todo.md"
out="$(run "$p24")"; rc=$?
chmod 644 "$p24/.claude/tasks/todo.md"
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, an unreadable file is still readable"
else
  [ "$rc" = 4 ] && ok "an unreadable ledger file on the git path -> exit 4" \
    || bad "unreadable file -> exit $rc (want 4): $out"
  case "$out" in *"NOTHING was backed up"*) ok "and it says nothing was backed up" ;;
    *) bad "a failed copy did not say so (got: $out)" ;; esac
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "ledger-backup: all $pass assertions passed."; else echo "ledger-backup: $fail FAILURE(S) above."; fi
exit "$fail"
