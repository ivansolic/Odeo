#!/usr/bin/env bash
# Tests for bin/session-end-check.sh, the advisory end-of-session sweep (Stop hook).
#
# WHY THIS EXISTS. This was the one program in bin/ with no suite, and it just gained the
# only check in the repo that speaks about files git cannot recover: the ledger backup. Two
# properties matter more than what it prints:
#
#   1. IT ALWAYS EXITS 0. It runs as a Stop hook. A non-zero exit from a broken check would
#      trap the user in a session they are trying to leave, which is a worse outcome than
#      every warning it could ever print.
#   2. IT IS SILENT WHEN THERE IS NOTHING TO SAY, and specifically when no backup location is
#      recorded. A hook that nags every session for a state that is usually fine is the
#      reason the ledger-backup step was NOT put in a hook in the first place; it earns its
#      place here only by staying quiet unless a configured backup has actually fallen behind.
#
# Scope: the ledger arm and the exit-code invariant. The tunnel and dev-server arms read
# global process state (pgrep, lsof) and are left to the reader rather than faked, which is
# stated here rather than implied by an empty file.
#
# Run: bash tests/session-end-check.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/session-end-check.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

[ -x "$SCRIPT" ] || { echo "FAIL - instrument broken: $SCRIPT missing or not executable"; exit 1; }

TMP="$(mktemp -d)" || { echo "FAIL - no temp dir"; exit 1; }
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com

# The hook is invoked from the project directory, and it locates ledger-backup.sh next to
# itself. So a sandbox project gets a bin/ holding BOTH real scripts, and is run from there.
mkproject() { # mkproject <name> [config-line] -> project dir
  local d="$TMP/$1"
  mkdir -p "$d/.claude/tasks" "$d/bin"
  ( cd "$d" && git init -q . ) >/dev/null 2>&1
  cp "$ROOT/bin/session-end-check.sh" "$ROOT/bin/ledger-backup.sh" "$d/bin/"
  chmod +x "$d/bin/"*.sh
  printf 'ledger v1\n' > "$d/.claude/tasks/todo.md"
  printf '# P\n' > "$d/CLAUDE.md"
  [ -n "${2:-}" ] && printf '%s\n' "$2" >> "$d/CLAUDE.md"
  printf '%s' "$d"
}
run() { ( cd "$1" && ./bin/session-end-check.sh 2>&1 ); }

# 1. No backup configured: SILENT about the ledger, and exit 0. This is the property the
#    /retro commit's own rationale demanded ("a hook would nag every session").
p="$(mkproject quiet)"
out="$(run "$p")"; rc=$?
[ "$rc" = 0 ] && ok "unconfigured project: exit 0" || bad "exit $rc (a Stop hook must exit 0)"
case "$out" in *ledger*|*backup*) bad "it mentioned the backup with none configured (got: $out)" ;;
  *) ok "and it says nothing about a backup nobody asked for" ;; esac

# 2. Configured but NEVER backed up: it warns, and says the files are not in git. This is the
#    state a new project sits in, and the one where the warning is worth the interruption.
p2="$(mkproject never "ledger_backup: dir $TMP/nowhere-yet/ledger")"
out="$(run "$p2")"; rc=$?
[ "$rc" = 0 ] && ok "configured-but-never-backed-up: still exit 0" || bad "exit $rc"
case "$out" in *NEVER*) ok "and it warns that the ledger has never been backed up" ;;
  *) bad "no warning for a configured backup that never ran (got: ${out:-<silence>})" ;; esac
case "$out" in *gitignored*) ok "and it says why git will not save you (they are gitignored)" ;;
  *) bad "the warning does not explain why git cannot recover them" ;; esac

# 3. Backed up, then the ledger is edited: it warns that the backup is BEHIND. This is the
#    measurement the whole mechanism exists for, and it is what a habit cannot notice.
dest="$TMP/synced"; mkdir -p "$dest"
p3="$(mkproject behind "ledger_backup: dir $dest/ledger")"
( cd "$p3" && ./bin/ledger-backup.sh . ) >/dev/null 2>&1
out="$(run "$p3")"
case "$out" in *BEHIND*|*NEVER*) bad "it warns immediately after a successful backup (got: $out)" ;;
  *) ok "a fresh backup produces no warning" ;; esac
sleep 1
printf 'ledger v2\n' > "$p3/.claude/tasks/todo.md"
out="$(run "$p3")"; rc=$?
[ "$rc" = 0 ] && ok "after an edit: still exit 0" || bad "exit $rc"
case "$out" in *BEHIND*) ok "and it reports the backup is behind the ledger" ;;
  *) bad "an edited ledger produced no warning (got: ${out:-<silence>})" ;; esac

# 4. THE INVARIANT: a broken ledger-backup.sh must not change the exit code. A Stop hook that
#    fails because a check it calls failed is the shape this program must never have.
p4="$(mkproject broken "ledger_backup: dir $dest/ledger")"
printf '#!/usr/bin/env bash\nexit 99\n' > "$p4/bin/ledger-backup.sh"
chmod +x "$p4/bin/ledger-backup.sh"
out="$(run "$p4")"; rc=$?
[ "$rc" = 0 ] && ok "a ledger check exiting 99 still leaves the hook at exit 0" \
  || bad "the hook exited $rc because a check it calls failed"

# 4b. A check that CANNOT DECIDE must be spoken, not swallowed. The program exits 2 when it
#     cannot read a ledger file's timestamp, saying that silence would be a lie; the hook then
#     reacted to exit 1 only and discarded stderr, so the user's seat looked exactly like
#     "all fine". The silence had moved one level out, not gone.
p4b="$(mkproject undecidable "ledger_backup: dir $TMP/synced/ledger")"
printf '#!/usr/bin/env bash\nexit 3\n' > "$p4b/bin/ledger-backup.sh"   # any non-0/1 "cannot decide"
chmod +x "$p4b/bin/ledger-backup.sh"
out="$(run "$p4b")"
case "$out" in *ledger*|*backup*) bad "exit 3 (not configured) was spoken; it must stay silent" ;;
  *) ok "exit 3 stays silent (nobody asked for a backup)" ;; esac
printf '#!/usr/bin/env bash\necho "ledger-backup: cannot read the modification time of: todo.md" >&2\nexit 2\n' \
  > "$p4b/bin/ledger-backup.sh"
chmod +x "$p4b/bin/ledger-backup.sh"
out="$(run "$p4b")"; rc=$?
[ "$rc" = 0 ] && ok "an undecidable check: hook still exits 0" || bad "hook exit $rc"
case "$out" in *"cannot read the modification time"*) ok "and the reason reaches the user" ;;
  *) bad "exit 2 was swallowed, so an unknown state reads as fine (got: ${out:-<silence>})" ;; esac
case "$out" in *UNKNOWN*) ok "and it is named as UNKNOWN, not as a lag" ;;
  *) bad "the undecidable case is reported as if it were a measurement" ;; esac

# 5. And a MISSING ledger-backup.sh is not a crash either, because the hook ships into
#    projects installed before this program existed.
p5="$(mkproject missing "ledger_backup: dir $dest/ledger")"
rm -f "$p5/bin/ledger-backup.sh"
out="$(run "$p5")"; rc=$?
[ "$rc" = 0 ] && ok "a missing ledger-backup.sh still leaves the hook at exit 0" \
  || bad "the hook exited $rc when the ledger check was absent"
case "$out" in *ledger*) bad "it warned about a ledger check that is not installed" ;;
  *) ok "and it stays quiet rather than reporting a check it could not run" ;; esac

# 6. Outside a git work tree the hook must still exit 0, since the Stop hook fires wherever
#    the session happened to be.
nogit="$TMP/nogit"; mkdir -p "$nogit"
out="$( cd "$nogit" && bash "$SCRIPT" 2>&1 )"; rc=$?
[ "$rc" = 0 ] && ok "outside a git repo: exit 0" || bad "exit $rc outside a git repo"

echo ""
if [ "$fail" -eq 0 ]; then echo "session-end-check: all $pass assertions passed."; else echo "session-end-check: $fail FAILURE(S) above."; fi
exit "$fail"
