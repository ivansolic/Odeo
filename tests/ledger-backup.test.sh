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

# leak_in_tree <project> <canary> -> the first repository INSIDE the work tree that carries the
# ledger's content, or nothing.
#
# WHY THIS EXISTS, and it is a finding against the tests rather than the program: the harm
# assertions said "no ref in the project's repo, no object in the project's repo, no todo.md
# loose in the work tree", and a bare repository sitting inside the work tree satisfies all
# three while holding the ledger. Measured twice: a suite of 188 assertions ran green across a
# live leak, in the exact shape the case above was written to catch. A test that cannot see the
# harm it names is worse than no test, because it is counted as coverage.
#
# Repositories are found by MARKER, the same way the program itself decides, not by the `.git`
# suffix in their name. The first version keyed on the name and was measured blind to a bare repo
# called `mirror` and to a submodule, which is the same defect one level out: the check and the
# thing it checks answering a differently-worded question.
leak_in_tree() {
  local pp="$1" c="$2" r o
  while IFS= read -r r; do
    [ -n "$r" ] || continue
    while IFS= read -r o; do
      [ -n "$o" ] || continue
      if git -C "$r" cat-file blob "$o" 2>/dev/null | grep -q "^$c\$"; then echo "$r"; return 0; fi
    done <<EOF
$(git -C "$r" cat-file --batch-all-objects --batch-check='%(objectname) %(objecttype)' 2>/dev/null \
  | awk '$2=="blob"{print $1}')
EOF
  done <<EOF
$(find "$pp" -type d 2>/dev/null | while IFS= read -r d; do
    [ -e "$d/HEAD" ] && [ -d "$d/objects" ] && [ -d "$d/refs" ] && echo "$d"
  done)
EOF
  return 1
}

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
case "$out" in *"inside a git repository"*) ok "and it says why, rather than blaming the path" ;;
  *) bad "the refusal does not explain itself (got: $out)" ;; esac
#     And inside an UNRELATED repository too. The rule is not "not in this project", which
#     turned out to have an endless supply of disguises, but "not in any repository": one
#     question git can answer for every disguise at once, and the stronger claim anyway, since
#     a backup in someone else's repo is still on the same disk and still one `add -A` from
#     being published.
other="$TMP/unrelated-repo"; mkdir -p "$other"; ( cd "$other" && git init -q . ) >/dev/null 2>&1
p19b="$(mkproject p19b "ledger_backup: dir $other/backups")"
out="$(run "$p19b")"; rc=$?
[ "$rc" = 2 ] && ok "a target inside an UNRELATED repository -> exit 2" \
  || bad "target in another repo -> exit $rc (want 2)"
[ -e "$other/backups" ] && bad "and it left a directory behind in that repo" \
  || ok "and it leaves no directory behind"

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
#     The list is every disguise any round of review produced, kept together so a future
#     change has to face all of them at once instead of one at a time:
#       1 a symlink whose PARENT is outside but which points back in
#       2 a path containing `..`
#       3 the destination ITSELF being a symlink into the repo (mkdir follows it)
#       4 a nested repository inside the project (the shape the git-toplevel version regressed)
#       5 a sibling worktree of the same repository
mkdir -p "$p22/vendor/nested" && ( cd "$p22/vendor/nested" && git init -q . ) >/dev/null 2>&1
( cd "$p22" && git add -A && git commit -qm base ) >/dev/null 2>&1
git -C "$p22" worktree add -q "$TMP/sibling-wt" -b wt-branch >/dev/null 2>&1
#     Shape 3's symlink points at a directory that EXISTS, which is the measured bypass: the
#     parent is outside the repo, so a guard that only asks about the parent says yes, and
#     then mkdir follows the link and the files land in the work tree.
mkdir -p "$p22_real/backups-via-link"
ln -s "$p22_real/backups-via-link" "$TMP/dest-is-a-link"
i=0
for shape in "$TMP/sneaky-link/backups" "$TMP/sideways/../$(basename "$p22")/backups" \
             "$TMP/dest-is-a-link" "$p22_real/vendor/nested/backups" "$TMP/sibling-wt/backups"; do
  i=$((i + 1))
  # The stamp is cleared per shape, or one shape that WRONGLY succeeded leaves a stamp that
  # the next shape's assertion then blames on itself. Measured while mutation-testing: shape 3
  # slipped through and shape 4 was reported as stamping success it never wrote.
  rm -f "$(stamp_of "$p22")/odeo-ledger-backup-stamp"
  printf 'ledger_backup: dir %s\n' "$shape" > "$p22/CLAUDE.local.md"
  out="$(run "$p22")"; rc=$?
  [ "$rc" = 2 ] && ok "a disguised in-project target is refused ($i: exit 2)" \
    || bad "disguised target $i reached exit $rc: $shape"
  #  Asked of the PROJECT, not of one expected path. Checking `$p22/backups` could not fail
  #  for shapes 3 to 5, which land elsewhere: under the destination-check mutation, shape 3
  #  leaked and that assertion still printed ok. A search for the ledger anywhere in the work
  #  tree is the harm itself, and is shape-independent.
  leaked="$(find "$p22" -name 'todo.md' -not -path "$p22/.claude/tasks/*" 2>/dev/null)"
  [ -n "$leaked" ] && bad "and the ledger landed in the work tree ($i): $leaked" \
    || ok "and no copy of the ledger exists anywhere in the work tree ($i)"
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

# 25. The project's PUBLISH remote is refused as a backup target. `ledger_backup: git origin
#     internal-files` is one plausible typo from pushing the task state and every recorded
#     correction to the repository the world reads, and being unreadable there is the entire
#     reason these files are gitignored. Checked by URL as well as by name, since a second
#     remote name can point at the same repository and the name is not what publishes.
b25="$(mkremote r25)"; p25="$(mkproject p25 "ledger_backup: git origin internal-files")"
git -C "$p25" remote add origin "$b25" >/dev/null 2>&1
out="$(run "$p25")"; rc=$?
[ "$rc" = 2 ] && ok "the publish remote by name -> exit 2" || bad "git origin -> exit $rc (want 2)"
case "$out" in *"publish remote"*) ok "and it says that is what it is" ;;
  *) bad "the refusal does not name the reason (got: $out)" ;; esac
#     Same repository, different remote name: the name is not the thing that publishes.
printf 'ledger_backup: git mirror internal-files\n' > "$p25/CLAUDE.local.md"
git -C "$p25" remote add mirror "$b25" >/dev/null 2>&1
out="$(run "$p25")"; rc=$?
[ "$rc" = 2 ] && ok "a second name pointing at the publish URL -> exit 2" \
  || bad "an alias of the publish remote was accepted (exit $rc)"
git -C "$b25" rev-parse --verify internal-files >/dev/null 2>&1 \
  && bad "and it pushed the ledger to the publish remote" || ok "and nothing was pushed there"
#     THREE SPELLINGS OF ONE REPOSITORY, each measured pushing the ledger to the publish
#     remote before the URLs were normalised. A guard that compares text is only as good as
#     the spellings someone thought of, so the comparison now runs through git's own
#     `ls-remote --get-url` and then resolves a local path the same way the `dir` invariant
#     does. What it still cannot see (ssh vs https for one host, a mirror, a fork) is stated
#     in the program header rather than implied by this passing.
j=0
for spelling in "$b25/" "$b25/." "$(dirname "$b25")/../$(basename "$(dirname "$b25")")/$(basename "$b25")"; do
  j=$((j + 1))
  git -C "$p25" remote remove alias >/dev/null 2>&1
  git -C "$p25" remote add alias "$spelling" >/dev/null 2>&1
  printf 'ledger_backup: git alias internal-files\n' > "$p25/CLAUDE.local.md"
  out="$(run "$p25")"; rc=$?
  [ "$rc" = 2 ] && ok "publish remote spelled differently is still refused ($j)" \
    || bad "spelling $j reached exit $rc and was accepted: $spelling"
done
git -C "$b25" rev-parse --verify internal-files >/dev/null 2>&1 \
  && bad "one of the spellings pushed the ledger to the publish remote" \
  || ok "and after all three, the publish remote still has no ledger branch"

# 25b. `internal-not-in-git` itself planted as a symlink into the project. The invariant was
#      asked about the destination, and this sits one level deeper, which is the difference
#      between asking the right question and asking it of the right argument.
p25b="$(mkproject p25b)"
p25b_real="$(cd "$p25b" && pwd -P)"
synced="$TMP/synced-planted"; mkdir -p "$synced"
mkdir -p "$p25b_real/leak"
ln -s "$p25b_real/leak" "$synced/internal-not-in-git"
printf 'ledger_backup: dir %s\n' "$synced" >> "$p25b/CLAUDE.md"
out="$(run "$p25b")"; rc=$?
[ "$rc" = 2 ] && ok "a planted symlink at the landing directory is refused (exit 2)" \
  || bad "planted landing symlink -> exit $rc (want 2)"
leaked="$(find "$p25b" -name 'todo.md' -not -path "$p25b/.claude/tasks/*" 2>/dev/null)"
[ -n "$leaked" ] && bad "and the ledger landed in the work tree: $leaked" \
  || ok "and no copy of the ledger reached the work tree"

# 25c. A git that CANNOT ANSWER is not a git that said "no repository". With an unreadable
#      .git/config (the portable stand-in for dubious ownership on a shared mount, which is
#      routine in containers) the check used to read the failure as "not a repo" and put the
#      ledger inside that repository at exit 0. The program refuses an unreadable LEDGER for
#      exactly this reason; the two had opposite policies for the same ignorance.
broken="$TMP/broken-repo"; mkdir -p "$broken"
( cd "$broken" && git init -q . ) >/dev/null 2>&1
chmod 000 "$broken/.git/config" 2>/dev/null
p25c="$(mkproject p25c "ledger_backup: dir $broken/backups")"
out="$(run "$p25c")"; rc=$?
chmod 644 "$broken/.git/config" 2>/dev/null
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, an unreadable config is still readable"
else
  [ "$rc" = 2 ] && ok "a repository git cannot read -> exit 2, not 'no repository here'" \
    || bad "unreadable repo state -> exit $rc (want 2): $out"
  [ -e "$broken/backups" ] && bad "and it wrote into that repository anyway" \
    || ok "and nothing was written into it"
fi

# 26. An UNREADABLE ledger directory is not an empty one. `chmod 000 .claude/tasks` made every
#     file test false, so the program reported "nothing to back up" at exit 0 and the Stop
#     hook stayed silent forever about a ledger it could not see: the silent-failure shape
#     this program exists to close, one line above where it was closed for timestamps.
p26="$(mkproject p26 "ledger_backup: dir $TMP/synced/ledger26")"
mkdir -p "$TMP/synced"
chmod 000 "$p26/.claude/tasks"
out="$(run "$p26")"; rc=$?
out2="$(run "$p26" --check)"; rc2=$?
chmod 755 "$p26/.claude/tasks"
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, an unreadable directory is still readable"
else
  [ "$rc" = 2 ] && ok "an unreadable ledger directory -> exit 2, not 'nothing to back up'" \
    || bad "unreadable ledger dir -> exit $rc (want 2): $out"
  [ "$rc2" = 2 ] && ok "and --check refuses too, instead of reporting fine" \
    || bad "--check on an unreadable ledger -> exit $rc2 (want 2)"
fi

# 27. PUSH REFUSED BY GIT ITSELF, with no hook in sight. Case 6 proves exit 5 against a
#     `pre-receive` hook we wrote, which is a fixture of a refusal: it proves the program reads
#     a non-zero push, not that git refuses anything on its own. Here the remote is an ORDINARY
#     NON-BARE repository with the backup branch checked out, and git's own
#     `receive.denyCurrentBranch` refuses the push. Nothing in this case is our invention
#     except the mistake, which is a realistic one: pointing the backup at a working clone on
#     another disk instead of at a bare repo.
nb="$TMP/nonbare-remote"
git init -q -b internal-files "$nb" >/dev/null 2>&1
printf 'seed\n' > "$nb/seed.md"
git -C "$nb" add -A >/dev/null 2>&1
git -C "$nb" commit -q -m seed >/dev/null 2>&1
p27="$(mkproject p27 "ledger_backup: git backup internal-files")"
git -C "$p27" remote add backup "$nb" >/dev/null 2>&1
out="$(run "$p27")"; rc=$?
[ "$rc" = 5 ] && ok "git's own refusal of a checked-out branch -> exit 5" \
  || bad "denyCurrentBranch -> exit $rc (want 5): $out"
has_stamp "$p27" && bad "and it stamped success for a push git refused" \
  || ok "and no stamp, so --check still reports behind"
git -C "$nb" show "internal-files:internal-not-in-git/todo.md" >/dev/null 2>&1 \
  && bad "and the ledger reached the remote anyway" || ok "and nothing reached the remote"

# 28. NO WRITE ACCESS to a reachable remote, which is what an expired credential or a
#     read-only deploy key looks like from here: the refs advertise fine, the push cannot land.
#     The exit-5 message names credentials as a common cause, and until now nothing proved the
#     program reaches exit 5 for anything but a hook. Permissions are the portable stand-in: a
#     real expired token needs a server, and a test that needs a server does not get run.
b28="$(mkremote r28)"; p28="$(mkproject p28 "ledger_backup: git backup internal-files")"
git -C "$p28" remote add backup "$b28" >/dev/null 2>&1
chmod -R a-w "$b28" 2>/dev/null
out="$(run "$p28")"; rc=$?
chmod -R u+w "$b28" 2>/dev/null
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, a read-only repository is still writable"
else
  [ "$rc" = 5 ] && ok "a reachable remote that refuses the write -> exit 5" \
    || bad "read-only remote -> exit $rc (want 5): $out"
  case "$out" in *"NOTHING was backed up"*) ok "and it says nothing was backed up" ;;
    *) bad "a refused write did not say the backup failed (got: $out)" ;; esac
  has_stamp "$p28" && bad "and it stamped a backup that never landed" || ok "and leaves no stamp"
fi

# 29. EXIT 4 FROM THE CLONE, not from the probe. The program asks the remote whether the branch
#     exists, and only then clones; case 7 kills the whole target so both calls fail together,
#     which leaves the clone's own failure branch unproven. Here the refs stay readable (the
#     branch exists, so the program takes the clone path) while the objects do not, so the
#     failure happens where nothing had exercised it. Both branches print the same message on
#     purpose, so this asserts the CODE and the absence of a stamp, not the wording.
b29="$(mkremote r29)"; p29="$(mkproject p29 "ledger_backup: git backup internal-files")"
git -C "$p29" remote add backup "$b29" >/dev/null 2>&1
run "$p29" >/dev/null 2>&1                        # first backup creates the branch
sleep 1
printf 'ledger v2\n' > "$p29/.claude/tasks/todo.md"
rm -f "$(stamp_of "$p29")/odeo-ledger-backup-stamp"
chmod -R 000 "$b29/objects" 2>/dev/null
out="$(run "$p29")"; rc=$?
chmod -R 755 "$b29/objects" 2>/dev/null
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, unreadable objects are still readable"
else
  [ "$rc" = 4 ] && ok "an existing branch whose objects cannot be read -> exit 4" \
    || bad "unreadable objects -> exit $rc (want 4): $out"
  has_stamp "$p29" && bad "and it stamped success for a backup that never got off the disk" \
    || ok "and leaves no stamp"
  landed="$(git -C "$b29" show internal-files:internal-not-in-git/todo.md 2>/dev/null)"
  [ "$landed" = "ledger v2" ] && bad "and the new content reached the branch anyway" \
    || ok "and the branch still carries the previous backup, not the new one"
fi

# 30. A REPOSITORY GIT CANNOT FOLLOW is still a repository. This is the measured fail-open that
#     stopped round 5: the containment guard decided "not in a repository" by matching git's
#     stderr, and git prints the SAME "not a git repository" sentence for a linked worktree
#     whose administrative directory it cannot read. The ledger then landed in the live work
#     tree, the run reported success, and the stamp was written, so --check said "up to date"
#     about a copy sitting inside the repository it is supposed to survive.
#     The guard no longer reads messages at all, so this case is decided by the target's
#     ancestors on disk, which do not depend on git's wording, locale or version.
wtmain="$TMP/wt-main"; mkdir -p "$wtmain"
( cd "$wtmain" && git init -q . && printf 'x\n' > f && git add -A && git commit -qm base ) >/dev/null 2>&1
git -C "$wtmain" worktree add -q "$TMP/wt-linked" -b wt-broken >/dev/null 2>&1
chmod 000 "$wtmain/.git/worktrees" 2>/dev/null
p30="$(mkproject p30 "ledger_backup: dir $TMP/wt-linked/backups")"
out="$(run "$p30")"; rc=$?
chmod 755 "$wtmain/.git/worktrees" 2>/dev/null
if [ "$(id -u)" = "0" ]; then
  echo "SKIP - running as root, an unreadable worktree directory is still readable"
else
  [ "$rc" = 2 ] && ok "a worktree whose gitdir git cannot follow is still refused (exit 2)" \
    || bad "unfollowable worktree -> exit $rc (want 2): $out"
  [ -e "$TMP/wt-linked/backups" ] && bad "and the ledger landed inside that work tree" \
    || ok "and nothing was written into the work tree"
  has_stamp "$p30" && bad "and it stamped a backup that went into a repository" \
    || ok "and no stamp was written"
fi

# 31. The same class without any permission trick, so it runs everywhere including as root: a
#     `.git` FILE pointing at a gitdir that does not exist. git says "not a git repository" here
#     too, and the marker on disk says otherwise. Which of the two is authoritative about
#     "is this path in a repository" is the whole question this guard got wrong three times.
orph="$TMP/orphan-pointer"; mkdir -p "$orph"
printf 'gitdir: %s/nowhere/.git/worktrees/gone\n' "$TMP" > "$orph/.git"
p31="$(mkproject p31 "ledger_backup: dir $orph/backups")"
out="$(run "$p31")"; rc=$?
[ "$rc" = 2 ] && ok "a .git pointer to a missing gitdir is refused (exit 2)" \
  || bad "dangling .git pointer -> exit $rc (want 2): $out"
[ -e "$orph/backups" ] && bad "and it wrote next to the dangling pointer" \
  || ok "and nothing was written there"

# 32. REGRESSION GUARD for the rewrite itself. The old guard keyed on git's EXIT STATUS, which
#     is 0 inside a bare repository and inside a .git directory, and the header called that
#     strictness deliberate. A guard that walks ancestors for a `.git` entry would lose exactly
#     that, since a bare repo has no `.git` child, so both shapes are pinned here rather than
#     left to be rediscovered as a leak.
bare32="$TMP/bare32.git"; git init -q --bare "$bare32" >/dev/null 2>&1
p32="$(mkproject p32 "ledger_backup: dir $bare32/backups")"
out="$(run "$p32")"; rc=$?
[ "$rc" = 2 ] && ok "a target inside a BARE repository is refused (exit 2)" \
  || bad "bare repo target -> exit $rc (want 2): $out"
[ -e "$bare32/backups" ] && bad "and it wrote into the bare repository" \
  || ok "and nothing was written into it"
p32b="$(mkproject p32b)"
printf 'ledger_backup: dir %s/.git/backups\n' "$p32b" > "$p32b/CLAUDE.local.md"
out="$(run "$p32b")"; rc=$?
[ "$rc" = 2 ] && ok "a target inside a .git directory is refused (exit 2)" \
  || bad "target inside .git -> exit $rc (want 2): $out"

# 33. The HEADER's exit-code table is the caller contract the file itself claims to publish, and
#     case 21 checks that contract only in /retro. This is the same mechanism pointed at the
#     second reader: every reachable code must have a row in the header too.
#     WHAT IT CANNOT CATCH, said plainly so a green run is not read as more: the drift that was
#     actually found here was a row that EXISTED and described six states too few ("usage, or
#     not inside a git work tree", while exit 2 had grown to cover refused targets and an
#     unreadable ledger). A row's presence is mechanical; whether its sentence is still true is
#     not, and that one was fixed by reading it.
missing_hdr=""
for code in $(grep -oE 'exit [0-9]+' "$SCRIPT" | grep -oE '[0-9]+' | sort -un); do
  grep -qE "^#[[:space:]]+$code[[:space:]]" "$SCRIPT" || missing_hdr="$missing_hdr $code"
done
[ -z "$missing_hdr" ] && ok "every exit code the program can return has a row in its own header" \
  || bad "exit code(s)$missing_hdr are reachable but missing from the header table"

# 34. THE CALLER'S INDEX IS NOT OURS TO TOUCH. git exports GIT_INDEX_FILE to pre-commit,
#     prepare-commit-msg, commit-msg and post-commit, and under `git commit -a` it is an
#     ABSOLUTE path to the project's index. The temp clone's `git add -A` then wrote the ledger
#     into THAT index: measured before the guard covered it, the run reported success and
#     stamped it while `git status` in the project failed with "unable to read <sha>", and as a
#     real pre-commit hook it became "error: Error building trees", so the user's commit did
#     not happen and the backup claimed it did. Destroying the caller's index is worse than
#     not backing up, so this asserts the index is byte-identical AND that the backup still ran.
b34="$(mkremote r34)"; p34="$(mkproject p34 "ledger_backup: git backup internal-files")"
git -C "$p34" remote add backup "$b34" >/dev/null 2>&1
( cd "$p34" && git add -A && git commit -qm base ) >/dev/null 2>&1
idx_before="$(shasum "$p34/.git/index" 2>/dev/null | awk '{print $1}')"
out="$(GIT_INDEX_FILE="$p34/.git/index" "$SCRIPT" "$p34" 2>&1)"; rc=$?
idx_after="$(shasum "$p34/.git/index" 2>/dev/null | awk '{print $1}')"
[ "$rc" = 0 ] && ok "a run with GIT_INDEX_FILE set still backs up (exit 0)" \
  || bad "GIT_INDEX_FILE run -> exit $rc: $out"
[ "$idx_before" = "$idx_after" ] && ok "and the caller's index is byte-identical afterwards" \
  || bad "the run rewrote the project's git index"
git -C "$p34" status --short >/dev/null 2>&1 \
  && ok "and the project's git status still works" || bad "the project's index was corrupted"
#     The same family, one level up: GIT_DIR pointed elsewhere must not decide which repository
#     this program reads. Asserted by outcome, the ledger of the project ARGUMENT is what lands.
b34b="$(mkremote r34b)"; p34b="$(mkproject p34b "ledger_backup: git backup internal-files")"
git -C "$p34b" remote add backup "$b34b" >/dev/null 2>&1
printf 'the argument project\n' > "$p34b/.claude/tasks/todo.md"
out="$(GIT_DIR="$p34/.git" GIT_WORK_TREE="$p34" "$SCRIPT" "$p34b" 2>&1)"; rc=$?
[ "$rc" = 0 ] && ok "an inherited GIT_DIR does not redirect the run (exit 0)" \
  || bad "GIT_DIR run -> exit $rc: $out"
landed="$(git -C "$b34b" show internal-files:internal-not-in-git/todo.md 2>/dev/null)"
[ "$landed" = "the argument project" ] \
  && ok "and the ledger backed up is the one the argument names" \
  || bad "the inherited environment chose the project (got: ${landed:-<nothing>})"

# 35. THE CONTAINMENT INVARIANT ON THE `git` ARM. It was written inside the `dir` arm, so this
#     shape was never asked about: a bare repository INSIDE the project's work tree, used as
#     the backup remote. Measured before the hoist: exit 0, stamped, and the pushed objects sat
#     in the work tree untracked and unignored, where `git add -A` stages the ledger verbatim.
#     Same harm as the `dir` arm's headline case, one arm over.
p35="$(mkproject p35 "ledger_backup: git backup internal-files")"
git init -q --bare "$p35/inside-bare.git" >/dev/null 2>&1
git -C "$p35" remote add backup "$p35/inside-bare.git" >/dev/null 2>&1
out="$(run "$p35")"; rc=$?
[ "$rc" = 2 ] && ok "a bare repo inside the work tree as backup remote -> exit 2" \
  || bad "in-tree bare remote -> exit $rc (want 2): $out"
has_stamp "$p35" && bad "and it stamped a backup that landed in the project" \
  || ok "and no stamp was written"
git -C "$p35/inside-bare.git" rev-parse --verify internal-files >/dev/null 2>&1 \
  && bad "and the ledger branch was created inside the work tree" \
  || ok "and no ledger branch exists inside the work tree"
#     The refusal must NOT cost the ordinary case: a bare repo outside every work tree is the
#     documented way to configure this, and asking about the remote itself rather than its
#     parent would refuse all of them (a bare repo IS a repository). Cases 2, 9 and 16 rely on
#     it; this asserts the distinction directly, next to the refusal it must not break.
b35="$(mkremote r35)"; p35b="$(mkproject p35b "ledger_backup: git backup internal-files")"
git -C "$p35b" remote add backup "$b35" >/dev/null 2>&1
out="$(run "$p35b")"; rc=$?
[ "$rc" = 0 ] && ok "and a bare repo OUTSIDE any work tree is still accepted (exit 0)" \
  || bad "the parent-walk refused a legitimate bare remote: exit $rc ($out)"

# 36. The refusal names the REPOSITORY, not only the target. With the decision made on disk the
#     marker can be several levels above the path the user wrote (a dotfiles $HOME refuses
#     ~/Dropbox/..., this file's own example), and a message naming only the target sends the
#     reader to the wrong directory.
deep="$TMP/deep-repo"; mkdir -p "$deep/a/b"; ( cd "$deep" && git init -q . ) >/dev/null 2>&1
p36="$(mkproject p36 "ledger_backup: dir $deep/a/b/ledger")"
out="$(run "$p36")"; rc=$?
[ "$rc" = 2 ] && ok "a target three levels inside a repository -> exit 2" \
  || bad "deep in-repo target -> exit $rc (want 2)"
case "$out" in *"$deep/.git"*) ok "and the message names the repository that contains it" ;;
  *) bad "the refusal names only the target, not the repository (got: $out)" ;; esac

# 37. EVERY SPELLING OF A LOCAL REMOTE, ASSERTED BY OUTCOME. The `git` arm's containment guard
#     recognised ONE spelling, a bare directory path, and three others were measured landing the
#     ledger inside the project's own repository at exit 0 with the stamp written. That is the
#     same class as the `dir` arm's three rounds: a guard that recognises one way of writing its
#     target while its comment claims the class.
#
#     So this case does not test spellings against a rule. It asserts THE HARM, once, for every
#     spelling at once: after the run, no ledger content may be reachable from the project's
#     repository, by ref or by object, and none may sit in its work tree. A spelling nobody
#     thought of fails this the same way as the four below, because the assertion is about the
#     leak, not about the syntax.
#
#     Each row is a fresh project, since a leak in one would otherwise be attributed to the next.
#     Rows 5 to 7 were added a round later, after the guard was rewritten to ask about identity
#     and location. The two questions held under attack; the STEP THAT FEEDS THEM did not. The
#     URL was turned into a path by matching spellings, so a file URL carrying an AUTHORITY
#     (`file://localhost/...`, which git resolves to the local path exactly as it resolves the
#     empty one) and an absolute path containing `@` and `:` (read as a host transport by the
#     `*@*:*` arm) both walked past the questions at exit 0. Same class, one layer down, which
#     is why they are rows here rather than a case of their own: the harm is identical.
i=0
for spelling in self worktree file-url bare-inside file-url-host file-url-host-self at-colon-path; do
  i=$((i + 1))
  pp="$(mkproject "p37-$i" )"
  pp_real="$(cd "$pp" && pwd -P)"
  ( cd "$pp" && git add -A && git commit -qm base ) >/dev/null 2>&1
  # The canary is written AFTER the base commit, and is unique per row. mkproject's ledger is
  # committed by that base commit (nothing here gitignores it), so searching the project's
  # objects for the ledger's ORIGINAL content finds a blob that is not a leak, and the
  # assertion would fail for every spelling including the ones that refuse correctly. Measured
  # while writing this case: all four rows reported the same object, which is the giveaway.
  canary="CANARY-37-$i-$$"
  printf '%s\n' "$canary" > "$pp/.claude/tasks/todo.md"
  case "$spelling" in
    self)        target="$pp_real" ;;                        # the project itself
    worktree)    git -C "$pp" worktree add -q "$TMP/sib-$i" -b "wt-$i" >/dev/null 2>&1
                 target="$TMP/sib-$i" ;;                     # a linked worktree: same object store
    file-url)    git init -q --bare "$pp/inside37.git" >/dev/null 2>&1
                 target="file://$pp_real/inside37.git" ;;    # a scheme the [ -d ] test cannot see
    bare-inside) git init -q --bare "$pp/plain37.git" >/dev/null 2>&1
                 target="$pp_real/plain37.git" ;;            # the one spelling that was caught
    file-url-host)
                 git init -q --bare "$pp/inside37h.git" >/dev/null 2>&1
                 target="file://localhost$pp_real/inside37h.git" ;;  # git ignores the authority
    file-url-host-self)
                 target="file://localhost$pp_real" ;;        # the project itself, via an authority
    at-colon-path)
                 mkdir -p "$pp/a@b:c" >/dev/null 2>&1
                 git init -q --bare "$pp/a@b:c/t37.git" >/dev/null 2>&1
                 target="$pp_real/a@b:c/t37.git" ;;          # an absolute path that looks like scp
  esac
  git -C "$pp" remote add backup "$target" >/dev/null 2>&1
  printf 'ledger_backup: git backup internal-files\n' > "$pp/CLAUDE.local.md"
  out="$(run "$pp")"; rc=$?
  [ "$rc" = 2 ] && ok "a local remote inside the project is refused ($spelling: exit 2)" \
    || bad "$spelling reached exit $rc: $out"
  has_stamp "$pp" && bad "and it stamped success ($spelling)" || ok "and no stamp was written ($spelling)"
  # THE HARM, asked of the project's own repository rather than of the target we wrote. A ref
  # named anywhere in it, or a blob whose content is the ledger, means the backup went into the
  # thing it exists to survive. `cat-file --batch-all-objects` reaches loose and packed objects
  # both, which is what distinguishes "pushed a branch" from "left objects behind".
  git -C "$pp" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the project's repo now carries the backup ref ($spelling)" \
    || ok "and no backup ref exists in the project's repo ($spelling)"
  leaked_obj="$(git -C "$pp" cat-file --batch-all-objects --batch-check='%(objectname) %(objecttype)' 2>/dev/null \
                | awk '$2=="blob"{print $1}' \
                | while read -r o; do
                    git -C "$pp" cat-file blob "$o" 2>/dev/null | grep -q "^$canary\$" && echo "$o"
                  done | head -1)"
  [ -n "$leaked_obj" ] && bad "and the ledger's content is an object in the project's repo ($spelling: $leaked_obj)" \
    || ok "and the ledger's content is in no object of the project's repo ($spelling)"
  leaked_wt="$(find "$pp" -name 'todo.md' -not -path "$pp/.claude/tasks/*" 2>/dev/null | head -1)"
  [ -n "$leaked_wt" ] && bad "and a copy sits in the work tree ($spelling: $leaked_wt)" \
    || ok "and no copy sits in the work tree ($spelling)"
  # AND the shape the three assertions above are blind to: a repository INSIDE the work tree.
  inside="$(leak_in_tree "$pp" "$canary")"
  [ -n "$inside" ] && bad "and a repo inside the work tree carries the ledger ($spelling: $inside)" \
    || ok "and no repo inside the work tree carries the ledger ($spelling)"
done

# 38. THE REFUSAL MUST NOT COST THE LEGITIMATE CASE, and this is the line the rule walks. A
#     backup remote that is an ordinary CLONE somewhere else on disk (a checkout on an external
#     drive, pushed to a branch it does not have checked out) is a real configuration, and a
#     rule phrased as "refuse any remote that is a work tree" would silently kill it. The rule
#     is identity and location, not shape: refuse a remote that IS this repository (shared
#     object store, which is what a linked worktree is) or that sits inside one.
outside="$TMP/outside-clone"
git init -q "$outside" >/dev/null 2>&1
printf 'x\n' > "$outside/f"; git -C "$outside" add -A >/dev/null 2>&1
git -C "$outside" commit -qm base >/dev/null 2>&1
p38="$(mkproject p38 "ledger_backup: git backup internal-files")"
git -C "$p38" remote add backup "$outside" >/dev/null 2>&1
out="$(run "$p38")"; rc=$?
[ "$rc" = 0 ] && ok "an unrelated clone outside every repo is still a valid remote (exit 0)" \
  || bad "a legitimate non-bare remote was refused: exit $rc ($out)"
git -C "$outside" show internal-files:internal-not-in-git/todo.md >/dev/null 2>&1 \
  && ok "and the ledger reached it" || bad "the backup reported success but nothing landed"

# 39. CONFIG INJECTION. `unset` covered the variables that NAME a repository and missed the ones
#     that REWRITE one. git exports GIT_CONFIG_PARAMETERS to hooks, and GIT_CONFIG_COUNT with a
#     `url.<evil>.insteadOf` pair redirects the push: measured before this line, the intended
#     remote stayed empty and the ledger arrived at the attacker's. Dropping GIT_CONFIG_COUNT
#     alone neutralises every GIT_CONFIG_KEY_n, since git reads the keys only through the count.
b39="$(mkremote r39)"; evil39="$(mkremote evil39)"
p39="$(mkproject p39 "ledger_backup: git backup internal-files")"
git -C "$p39" remote add backup "$b39" >/dev/null 2>&1
out="$(GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.$evil39.insteadOf" GIT_CONFIG_VALUE_0="$b39" \
       "$SCRIPT" "$p39" 2>&1)"; rc=$?
[ "$rc" = 0 ] && ok "a run under an insteadOf rewrite still backs up (exit 0)" \
  || bad "GIT_CONFIG_COUNT run -> exit $rc: $out"
git -C "$evil39" rev-parse --verify internal-files >/dev/null 2>&1 \
  && bad "and the ledger was redirected to the injected remote" \
  || ok "and the injected remote received nothing"
git -C "$b39" show internal-files:internal-not-in-git/todo.md >/dev/null 2>&1 \
  && ok "and the configured remote is the one that got it" \
  || bad "the configured remote received nothing"

# 40. A NAME THIS SCRIPT UNSETS MUST NEVER BE A NAME IT ASSIGNS. The script used a local called
#     GIT_DIR, three lines under the `unset GIT_DIR`. Under `set -a` (bash reads SHELLOPTS from
#     the environment where that is permitted) every assignment becomes an exported one, so that
#     local turns back into the git variable the unset exists to remove, and the index
#     corruption closed one commit earlier returns with no change to this file.
#
#     Asserted STATICALLY, on purpose. The outcome version of this test cannot fail on every
#     machine: measured here, bash 3.2 makes SHELLOPTS readonly, so the injection is refused by
#     the shell and the assertion passes whether or not the defect is present. A test that
#     cannot fail is not a guard, it is decoration that reads like one. The source rule holds
#     everywhere and is checkable everywhere, so that is what is checked.
unset_names="$(grep -A4 '^unset GIT_DIR' "$SCRIPT" | tr ' \\\n' '\n\n\n' | grep -E '^GIT_[A-Z_]+$' | sort -u)"
[ -n "$unset_names" ] || bad "instrument broken: could not read the unset list out of the script"
clash=""
for n in $unset_names; do
  grep -qE "^[[:space:]]*$n=" "$SCRIPT" && clash="$clash $n"
done
[ -z "$clash" ] && ok "no variable the script unsets is later assigned by it" \
  || bad "the script assigns to name(s) it unsets:$clash (exported under set -a)"
#     And the outcome, where the shell allows it to be exercised at all. Reported as a skip
#     rather than a pass when it cannot be, so a green line never stands for an unrun check.
if ( SHELLOPTS=allexport bash -c 'shopt -qo allexport' ) 2>/dev/null; then
  b40="$(mkremote r40)"; p40="$(mkproject p40 "ledger_backup: git backup internal-files")"
  git -C "$p40" remote add backup "$b40" >/dev/null 2>&1
  ( cd "$p40" && git add -A && git commit -qm base ) >/dev/null 2>&1
  idx40_before="$(shasum "$p40/.git/index" 2>/dev/null | awk '{print $1}')"
  out="$(SHELLOPTS=allexport "$SCRIPT" "$p40" 2>&1)"; rc=$?
  idx40_after="$(shasum "$p40/.git/index" 2>/dev/null | awk '{print $1}')"
  [ "$idx40_before" = "$idx40_after" ] \
    && ok "under allexport the caller's index is still byte-identical" \
    || bad "allexport re-exported a script variable and the index was rewritten"
  [ "$rc" = 0 ] && ok "and the backup still ran (exit 0)" || bad "allexport run -> exit $rc: $out"
else
  echo "SKIP - this shell refuses SHELLOPTS from the environment, so allexport cannot be exercised"
fi

# 41. THE PUBLISH REFUSAL READS THE SAME URL, so it must read it the same WAY. The containment
#     guard and the publish-remote comparison each had their own conversion from URL to path,
#     and they disagreed: `canon_url` recognised a path only when `[ -d ]` was true of the raw
#     string, so `file://localhost/...` fell through to the trailing-`.git` trim and compared
#     unequal to the very same repository spelled plainly. Measured before this line: the ledger
#     was pushed TO THE PUBLISH REMOTE at exit 0.
#
#     The plain spelling is the control. If the control ever fails, this case is testing nothing.
pub41="$(mkremote pub41)"
pub41_real="$(cd "$pub41" && pwd -P)"
for spelling in plain file-url-host; do
  p41="$(mkproject "p41-$spelling" "ledger_backup: git backup internal-files")"
  git -C "$p41" remote add origin "$pub41_real" >/dev/null 2>&1
  case "$spelling" in
    plain)         target="$pub41_real" ;;
    file-url-host) target="file://localhost$pub41_real" ;;
  esac
  git -C "$p41" remote add backup "$target" >/dev/null 2>&1
  out="$(run "$p41")"; rc=$?
  [ "$rc" = 2 ] && ok "the publish remote is refused however it is spelled ($spelling: exit 2)" \
    || bad "$spelling reached exit $rc: $out"
  has_stamp "$p41" && bad "and it stamped success ($spelling)" || ok "and no stamp was written ($spelling)"
  git -C "$pub41" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the ledger is now on the publish remote ($spelling)" \
    || ok "and the publish remote received nothing ($spelling)"
done

# 42. A RELATIVE URL IS REFUSED, because the guard and git resolve it from DIFFERENT directories.
#     The guard rooted it at PROJECT_DIR, which is what git does with a remote it has CONFIGURED;
#     but this script hands the raw string to `ls-remote` and `clone` from the CALLER'S cwd. So
#     the path that is checked is not the path that is used.
#
#     Both arrangements are rows, because the damage is not the same and neither is acceptable.
#     Measured on the previous commit, from inside an unrelated repository R:
#       - branch-exists  -> the `clone` path is taken, exit 0, and THE LEDGER LANDS IN R;
#       - branch-missing -> the orphan path is taken and the push fails from the temp dir, so it
#                           exits 5 blaming "expired credentials, branch protection", none of
#                           which is what went wrong.
#
#     Two directories can be made to agree, and that is the fix this case rejects: the agreement
#     would have to hold for every future call site too. The `dir` arm already refuses a relative
#     target for exactly this reason, so the two arms now answer alike.
for arrangement in branch-exists branch-missing; do
  r42="$(mktemp -d "$TMP/r42-$arrangement.XXXXXX")"
  git init -q "$r42" >/dev/null 2>&1
  git init -q --bare "$r42/rel42.git" >/dev/null 2>&1
  if [ "$arrangement" = branch-exists ]; then
    seed42="$(mktemp -d "$TMP/seed42.XXXXXX")"
    git init -q "$seed42" >/dev/null 2>&1
    printf 'seed\n' > "$seed42/s"
    ( cd "$seed42" && git add -A && git commit -qm seed && git branch -m internal-files \
      && git push -q "$r42/rel42.git" internal-files ) >/dev/null 2>&1
  fi
  p42="$(mkproject "p42-$arrangement" "ledger_backup: git backup internal-files")"
  git -C "$p42" remote add backup "rel42.git" >/dev/null 2>&1
  out="$( cd "$r42" && "$SCRIPT" "$p42" 2>&1 )"; rc=$?
  [ "$rc" = 2 ] && ok "a relative remote URL is refused ($arrangement: exit 2)" \
    || bad "a relative URL reached exit $rc ($arrangement): $out"
  has_stamp "$p42" && bad "and it stamped success ($arrangement)" \
    || ok "and no stamp was written ($arrangement)"
  git -C "$r42/rel42.git" show internal-files:internal-not-in-git/todo.md >/dev/null 2>&1 \
    && bad "and the ledger landed where the caller happened to stand ($arrangement)" \
    || ok "and nothing landed where the caller happened to stand ($arrangement)"
  printf '%s' "$out" | grep -q 'relative' \
    && ok "and the refusal names the relative URL as the reason ($arrangement)" \
    || bad "the refusal does not tell the caller what to change ($arrangement): $out"
done

# 43. THE GUARD MAY NOT BE SKIPPED JUST BECAUSE THIS PROGRAM CANNOT SEE THE TARGET. Three rounds
#     closed three ways of MODELLING what git does with a url, and each time git knew one more
#     thing than the model: first the spelling list, then the file-url authority, then percent
#     decoding (`%2e%2e` and `%20`, which git decodes and this program did not). Every one had
#     the same shape: the converted path was not a directory, so the containment block was
#     SKIPPED, and a skipped guard reads exactly like a passed one.
#
#     The rule under test is therefore not about urls at all: IF THE TARGET CANNOT BE SEEN FROM
#     HERE, THE RUN REFUSES. That is decidable without knowing git's grammar, which is why it
#     ends the class instead of adding a fourth model. A future encoding nobody has thought of
#     fails these rows the same way, because the assertion is on the harm and the refusal.
#
#     Rows 1 and 2 are the worst outcome (the ledger on the PUBLISH remote), rows 3 and 4 put it
#     in the project's own repository. Row 4 uses a project whose directory legitimately contains
#     a space, so `%20` is ordinary encoding rather than an attack.
#     The publish remote is FRESH PER ROW for the same reason the project is: sharing one would
#     let row 1's leak fail row 3's assertion, and a test that blames the wrong row is worse than
#     no test, because the fix then goes to the wrong place.
i=0
for row in pub-dotdot pub-space self-dotdot space-inside; do
  i=$((i + 1))
  pub43="$(mkremote "pub43-$i")"; pub43_real="$(cd "$pub43" && pwd -P)"
  case "$row" in
    space-inside) pp="$(mkproject "p43 with space $i")" ;;
    *)            pp="$(mkproject "p43-$i")" ;;
  esac
  pp_real="$(cd "$pp" && pwd -P)"
  ( cd "$pp" && git add -A && git commit -qm base ) >/dev/null 2>&1
  canary="CANARY-43-$i-$$"
  printf '%s\n' "$canary" > "$pp/.claude/tasks/todo.md"
  git -C "$pp" remote add origin "$pub43_real" >/dev/null 2>&1
  case "$row" in
    pub-dotdot)   mkdir -p "$pp/sub" >/dev/null 2>&1
                  target="file://localhost$pub43_real/../$(basename "$pub43_real")"
                  target="file://localhost$(dirname "$pub43_real")/sub43/%2e%2e/$(basename "$pub43_real")"
                  mkdir -p "$(dirname "$pub43_real")/sub43" >/dev/null 2>&1 ;;
    pub-space)    mkdir -p "$TMP/My Backups $i" >/dev/null 2>&1
                  git init -q --bare "$TMP/My Backups $i/b43.git" >/dev/null 2>&1
                  git -C "$pp" remote set-url origin "$TMP/My Backups $i/b43.git" >/dev/null 2>&1
                  spaced43="$TMP/My Backups $i/b43.git"
                  target="file://localhost$TMP/My%20Backups%20$i/b43.git" ;;
    self-dotdot)  target="file://localhost$pp_real/.claude/%2e%2e/%2e%2e/$(basename "$pp_real")" ;;
    space-inside) # Named `mirror`, with NO `.git` suffix, on purpose: leak_in_tree finds
                  # repositories by marker, and a name-keyed version was measured blind to
                  # exactly this shape. The row proves the finder as well as the program.
                  git init -q --bare "$pp/mirror" >/dev/null 2>&1
                  enc="$(printf '%s' "$pp_real" | sed 's/ /%20/g')"
                  target="file://localhost$enc/mirror" ;;
  esac
  git -C "$pp" remote add backup "$target" >/dev/null 2>&1
  printf 'ledger_backup: git backup internal-files\n' > "$pp/CLAUDE.local.md"
  out="$(run "$pp")"; rc=$?
  [ "$rc" != 0 ] && ok "an unseeable target is refused rather than waved through ($row: exit $rc)" \
    || bad "$row reached exit 0: $out"
  has_stamp "$pp" && bad "and it stamped success ($row)" || ok "and no stamp was written ($row)"
  git -C "$pp" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the project's repo now carries the backup ref ($row)" \
    || ok "and no backup ref exists in the project's repo ($row)"
  git -C "$pub43" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the ledger is now on the publish remote ($row)" \
    || ok "and the publish remote received nothing ($row)"
  inside="$(leak_in_tree "$pp" "$canary")"
  [ -n "$inside" ] && bad "and a repo inside the work tree carries the ledger ($row: $inside)" \
    || ok "and no repo inside the work tree carries the ledger ($row)"
  if [ "$row" = pub-space ]; then
    git -C "$spaced43" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
      && bad "and the ledger is on the publish remote spelled with a space ($row)" \
      || ok "and the space-spelled publish remote received nothing ($row)"
  fi
done

# 44. AND THE REFUSAL MUST NOT EAT A REAL CONFIGURATION. `~/backup.git` is a plausible line for a
#     human to write, git expands it, and the `dir` arm has always expanded it too. A fail-closed
#     rule that cannot see `~` would refuse it with a reason that is false for it, so the two arms
#     would disagree about the one character most likely to appear in a hand-written path.
home44="$(mktemp -d "$TMP/home44.XXXXXX")"
git init -q --bare "$home44/tilde44.git" >/dev/null 2>&1
p44="$(mkproject p44 "ledger_backup: git backup internal-files")"
git -C "$p44" remote add backup "~/tilde44.git" >/dev/null 2>&1
out="$(HOME="$home44" "$SCRIPT" "$p44" 2>&1)"; rc=$?
[ "$rc" = 0 ] && ok "a ~ remote is expanded and still backs up (exit 0)" \
  || bad "the fail-closed rule refused a legitimate ~ remote: exit $rc ($out)"
git -C "$home44/tilde44.git" show internal-files:internal-not-in-git/todo.md >/dev/null 2>&1 \
  && ok "and the ledger reached it" || bad "the ~ remote reported success but nothing landed"

# 45. IDENTITY ASKS WHETHER IT IS THE SAME FILE, NOT WHETHER IT IS SPELLED THE SAME. The two
#     common dirs were compared as STRINGS from `pwd -P`, which preserves the case you typed. On
#     a case-insensitive filesystem (the macOS default, where this is developed) `$PROJECT` and
#     `$PROJECTUPPERCASED` are one directory with two spellings, so the identity question
#     answered "different repository" about the project itself: exit 0, stamped, the ledger a ref
#     in the very repo it is kept out of. No attacker, just a capitalisation typo in a config
#     line a human writes by hand.
#
#     This hazard is not new to the project: the suite already pins it for the `dir` arm at
#     case 20. It was simply never carried across to the `git` arm, which is the more expensive
#     half of the same lesson.
#
#     SKIPPED, loudly, where the filesystem is case-sensitive: there the two spellings really are
#     two directories and the case would pass while testing nothing.
p45="$(mkproject P45Mixed "ledger_backup: git backup internal-files")"
p45_upper="$TMP/P45MIXED"
# The setup is SHARED by both branches on purpose: an `else` that forgot the remote would test
# "no remote of that name" and pass for the wrong reason on every case-sensitive machine.
( cd "$p45" && git add -A && git commit -qm base ) >/dev/null 2>&1
canary45="CANARY-45-$$"
printf '%s\n' "$canary45" > "$p45/.claude/tasks/todo.md"
git -C "$p45" remote add backup "$p45_upper" >/dev/null 2>&1
if [ -d "$p45_upper" ]; then
  out="$(run "$p45")"; rc=$?
  [ "$rc" = 2 ] && ok "the project spelled in another case is still the project (exit 2)" \
    || bad "a case variant of the project's own path reached exit $rc: $out"
  has_stamp "$p45" && bad "and it stamped success (case variant)" \
    || ok "and no stamp was written (case variant)"
  git -C "$p45" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the ledger is a ref in the project's own repository (case variant)" \
    || ok "and no backup ref exists in the project's repo (case variant)"
else
  # NOT a skip. Case 20 pins this same hazard for the `dir` arm without one, and the reasoning
  # carries: where the filesystem IS case-sensitive the uppercase path does not exist, so the
  # fail-closed rule refuses a target it cannot see. The SPECIFIC defect (two spellings, one
  # directory) is unreproducible there, and there is no portable substitute, since `pwd -P`
  # normalises symlinks, trailing slashes and `/./` alike. But the CONTRACT holds on both
  # filesystems and is worth asserting on both: this line must never end at exit 0.
  out="$(run "$p45")"; rc=$?
  [ "$rc" != 0 ] && ok "a case variant of the project's path never reaches exit 0 (exit $rc)" \
    || bad "a case variant reached exit 0 on a case-sensitive filesystem: $out"
  has_stamp "$p45" && bad "and it stamped success (case variant)" \
    || ok "and no stamp was written (case variant)"
  git -C "$p45" rev-parse --verify --quiet internal-files >/dev/null 2>&1 \
    && bad "and the ledger is a ref in the project's own repository (case variant)" \
    || ok "and no backup ref exists in the project's repo (case variant)"
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "ledger-backup: all $pass assertions passed."; else echo "ledger-backup: $fail FAILURE(S) above."; fi
exit "$fail"
