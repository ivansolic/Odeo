#!/usr/bin/env bash
#
# ledger-backup.sh, back up the working files git deliberately does not carry.
#
# WHY THIS EXISTS. `.claude/tasks/todo.md` and `lessons.md` are gitignored on purpose, so the
# build ledger can never reach a published snapshot. The consequence is rarely stated: git
# therefore does not back them up either, and between them they hold the task state and every
# correction the project has learned. Losing them loses the "why", while the code survives.
#
# Until now keeping a copy was a ritual that depended on someone remembering, and a ritual
# fails in two ways that look identical from the outside: it does not run, or it runs and
# does not work (an expired token, a diverged branch, a refused push). The second is worse,
# because "I back this up" stays true in your head for weeks after it stopped being true.
#
# So this program does the copy and REPORTS WHAT HAPPENED with an exit code, and it records a
# local stamp ONLY after a verified success. `--check` then answers "is the backup behind?"
# offline, from that stamp, which is what makes a silent failure visible on the next session.
#
# Usage:
#   ledger-backup.sh [<project-dir>]            back up now (default: current directory)
#   ledger-backup.sh --check [<project-dir>]    report only, never writes, no network
#
# Configuration, one line in the project's CLAUDE.local.md (preferred, gitignored) or
# CLAUDE.md:
#   ledger_backup: git <remote-name> <branch>   e.g. `ledger_backup: git backup internal-files`
#   ledger_backup: dir <path>                   e.g. `ledger_backup: dir ~/Dropbox/odeo-ledger`
# A backup target is often private, which is why CLAUDE.local.md is read FIRST and wins: a
# public repo should not have to name where its owner keeps their copy.
#
# Exit codes (the whole point; a caller must be able to tell these apart):
#   0  backed up, or already current  (--check: the backup is up to date)
#   1  --check only: the backup is BEHIND the ledger
#   2  usage, or not inside a git work tree
#   3  no ledger_backup: line recorded (not a failure: nothing was promised)
#   4  target unreachable (no such remote, clone/fetch failed, directory missing)
#   5  the copy was made but PUSH WAS REFUSED, so nothing was backed up
#   6  nothing to back up (neither ledger file exists)
set -uo pipefail

CHECK=0
PROJECT_DIR=""
for a in "$@"; do
  case "$a" in
    --check) CHECK=1 ;;
    -*) echo "usage: ledger-backup.sh [--check] [<project-dir>]" >&2; exit 2 ;;
    *) [ -n "$PROJECT_DIR" ] && { echo "usage: ledger-backup.sh [--check] [<project-dir>]" >&2; exit 2; }
       PROJECT_DIR="$a" ;;
  esac
done
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
[ -d "$PROJECT_DIR" ] || { echo "ledger-backup: no such directory: $PROJECT_DIR" >&2; exit 2; }
# Absolute from here on. A relative project dir would make "is the target inside the project"
# below compare a path against "." and answer no for every target, which is the check that
# stops this program from writing the ledger into the work tree it is meant to keep it out of.
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)" || exit 2

GIT_DIR="$(git -C "$PROJECT_DIR" rev-parse --absolute-git-dir 2>/dev/null)" || GIT_DIR=""
[ -n "$GIT_DIR" ] || { echo "ledger-backup: $PROJECT_DIR is not a git work tree" >&2; exit 2; }

LEDGER_DIR="$PROJECT_DIR/.claude/tasks"
FILES="todo.md lessons.md"
# The stamp lives inside the GIT DIR, never in the work tree. Nothing under .git is ever
# tracked, in any project, so this needs no .gitignore entry anywhere and cannot be committed
# by accident. It is also per-worktree, which is correct: it describes this clone's copy.
STAMP="$GIT_DIR/odeo-ledger-backup-stamp"

# --- configuration -----------------------------------------------------------------------
# CLAUDE.local.md first (gitignored, the right home for a private target), then CLAUDE.md.
read_config() {
  local f v
  for f in "$PROJECT_DIR/CLAUDE.local.md" "$PROJECT_DIR/CLAUDE.md"; do
    [ -f "$f" ] || continue
    v="$(grep -m1 -E '^[[:space:]]*ledger_backup:[[:space:]]*' "$f" 2>/dev/null \
         | sed -E 's/^[[:space:]]*ledger_backup:[[:space:]]*//; s/[[:space:]]+$//' | tr -d '\r')"
    [ -n "$v" ] && { printf '%s' "$v"; return 0; }
  done
  return 1
}

not_configured() {
  echo "ledger-backup: no backup location recorded for this project." >&2
  echo "  Add ONE line to $PROJECT_DIR/CLAUDE.local.md (gitignored, best for a private target)" >&2
  echo "  or CLAUDE.md:" >&2
  echo "    ledger_backup: git <remote-name> <branch>" >&2
  echo "    ledger_backup: dir <path>" >&2
  exit 3
}

CONFIG="$(read_config)" || not_configured
# A value still holding the template's placeholder is NOT configuration. Without this, every
# project scaffolded from project-templates/ ships a live `ledger_backup: git <remote-name>
# <branch>` line, because the documentation example matches the same grep that reads the
# setting: the program then fails with "no remote named <remote-name>" and the end-of-session
# check nags about a backup nobody set up, in the default state of every new project. Measured
# on a fresh scaffold before this guard existed.
case "$CONFIG" in
  *'<'*|*'>'*)
    echo "ledger-backup: the ledger_backup: line still holds the template placeholder:" >&2
    echo "    ledger_backup: $CONFIG" >&2
    echo "  Replace <...> with a real target, or delete the line to turn the backup off." >&2
    exit 3 ;;
esac
KIND="$(printf '%s' "$CONFIG" | awk '{print $1}')"

# --- --check: offline, reads the stamp, writes nothing ------------------------------------
# Deliberately compares the stamp against the LEDGER FILES, not against "did someone run the
# command". A run that failed leaves no stamp, so a broken backup reports BEHIND exactly like
# one that was never attempted, which is the failure this program exists to make visible.
if [ "$CHECK" -eq 1 ]; then
  # "no ledger files" and "I could not read a timestamp" are counted separately on purpose.
  # Folding them (|| echo 0) made an unreadable mtime look like an empty ledger, so the check
  # went SILENT and reported fine forever: the exact silent-failure shape this program exists
  # to eliminate, inside the code that does the eliminating.
  newest=0; n_present=0; unreadable=""
  for f in $FILES; do
    [ -f "$LEDGER_DIR/$f" ] || continue
    n_present=$((n_present + 1))
    t="$(date -r "$LEDGER_DIR/$f" +%s 2>/dev/null)" || t=""
    case "$t" in ''|*[!0-9]*) unreadable="$unreadable $f"; continue ;; esac
    [ "$t" -gt "$newest" ] && newest="$t"
  done
  [ "$n_present" -eq 0 ] && { echo "ledger-backup: nothing to back up"; exit 0; }
  [ -n "$unreadable" ] && {
    echo "ledger-backup: cannot read the modification time of:$unreadable" >&2
    echo "  so whether the backup is current cannot be decided, and silence would be a lie." >&2
    exit 2; }
  if [ ! -f "$STAMP" ]; then
    echo "ledger-backup: the ledger has NEVER been backed up (no stamp), and git does not carry it"
    exit 1
  fi
  stamped="$(date -r "$STAMP" +%s 2>/dev/null || echo 0)"
  if [ "$stamped" -ge "$newest" ]; then
    echo "ledger-backup: up to date"
    exit 0
  fi
  mins=$(( (newest - stamped) / 60 ))
  if [ "$mins" -ge 1440 ]; then behind="$((mins / 1440)) day(s)"
  elif [ "$mins" -ge 60 ]; then behind="$((mins / 60)) hour(s)"
  else behind="$mins minute(s)"; fi
  echo "ledger-backup: the backup is $behind BEHIND the ledger (last verified: $(date -r "$STAMP" '+%Y-%m-%d %H:%M'))"
  exit 1
fi

# --- collect what there is to back up -----------------------------------------------------
present=""
for f in $FILES; do [ -f "$LEDGER_DIR/$f" ] && present="$present $f"; done
present="${present# }"
[ -n "$present" ] || { echo "ledger-backup: nothing to back up (no todo.md or lessons.md)"; exit 6; }

stamp_now() { date '+%Y-%m-%d %H:%M:%S %z' > "$STAMP"; printf 'target: %s\n' "$CONFIG" >> "$STAMP"; }

case "$KIND" in
  dir)
    dest="$(printf '%s' "$CONFIG" | sed -E 's/^dir[[:space:]]+//')"
    dest="${dest/#\~/$HOME}"
    [ -n "$dest" ] || { echo "ledger-backup: 'dir' needs a path" >&2; exit 2; }
    # ABSOLUTE ONLY. A relative target resolves against whatever directory the caller happens
    # to be in, and /retro runs this from the project root: `dir backupdir` then writes the
    # ledger INTO the work tree, where nothing ignores it, and reports success. That is this
    # program putting the content it exists to keep out of git into git.
    case "$dest" in
      /*) ;;
      *) echo "ledger-backup: 'dir' needs an absolute path (got '$dest')" >&2
         echo "  A relative path resolves against the caller's directory, not the project." >&2
         exit 2 ;;
    esac
    # And never inside the project, for the same reason: a copy in the work tree is not a
    # backup, it is the same file with a second name and the same single point of failure.
    case "$dest/" in
      "$PROJECT_DIR"/*) echo "ledger-backup: the target is inside the project ($dest)" >&2
         echo "  A copy in the work tree is not a backup; point it outside the repo." >&2
         exit 2 ;;
    esac
    # The PARENT must exist: creating a whole tree for a mistyped path would silently back up
    # into a directory nobody syncs, which reads as success and protects nothing.
    parent="$(dirname "$dest")"
    [ -d "$parent" ] || { echo "ledger-backup: no such directory: $parent" >&2; exit 4; }
    mkdir -p "$dest/internal-not-in-git" 2>/dev/null \
      || { echo "ledger-backup: cannot write to $dest" >&2; exit 4; }
    # Staged, then moved into place. Copying straight in could leave todo.md refreshed and
    # lessons.md not, which would make the exit-4 message ("nothing was backed up") false, and
    # a half-true failure message is worse than a blunt one. Both files are written to a
    # staging dir on the SAME filesystem first, so the moves are renames.
    staging="$dest/internal-not-in-git/.staging.$$"
    rm -rf "$staging"; mkdir -p "$staging" 2>/dev/null \
      || { echo "ledger-backup: cannot write to $dest" >&2; exit 4; }
    for f in $present; do
      cp "$LEDGER_DIR/$f" "$staging/$f" \
        || { rm -rf "$staging"; echo "ledger-backup: copy failed for $f, NOTHING was backed up" >&2; exit 4; }
    done
    for f in $present; do
      mv -f "$staging/$f" "$dest/internal-not-in-git/$f" \
        || { rm -rf "$staging"; echo "ledger-backup: could not place $f, the copy is incomplete" >&2; exit 4; }
    done
    rmdir "$staging" 2>/dev/null
    stamp_now
    echo "ledger-backup: refreshed ($present -> $dest/internal-not-in-git/)"
    exit 0
    ;;
  git)
    remote="$(printf '%s' "$CONFIG" | awk '{print $2}')"
    branch="$(printf '%s' "$CONFIG" | awk '{print $3}')"
    [ -n "$remote" ] && [ -n "$branch" ] || { echo "ledger-backup: 'git' needs <remote> <branch>" >&2; exit 2; }
    url="$(git -C "$PROJECT_DIR" remote get-url "$remote" 2>/dev/null)" \
      || { echo "ledger-backup: this repo has no remote named '$remote'" >&2; exit 4; }

    tmp="$(mktemp -d)" || { echo "ledger-backup: no temp dir" >&2; exit 4; }
    trap 'rm -rf "$tmp"' EXIT
    work="$tmp/backup"
    # An EXISTING branch is cloned; a missing one starts as an orphan. Both are normal, and
    # the distinction must not be guessed from the clone's failure, which also covers "no
    # network" and "no such repo". So the branch is probed first, against the remote.
    if ! git ls-remote --exit-code --heads "$url" "$branch" >/dev/null 2>&1; then
      if ! git ls-remote --heads "$url" >/dev/null 2>&1; then
        echo "ledger-backup: cannot reach '$remote' (offline, or no access)" >&2
        exit 4
      fi
      git init -q "$work" >/dev/null 2>&1 || { echo "ledger-backup: git init failed" >&2; exit 4; }
      git -C "$work" remote add origin "$url" >/dev/null 2>&1
      git -C "$work" checkout -q --orphan "$branch" >/dev/null 2>&1
    else
      git clone -q --depth 1 --branch "$branch" --single-branch "$url" "$work" >/dev/null 2>&1 \
        || { echo "ledger-backup: cannot reach '$remote' (offline, or no access)" >&2; exit 4; }
    fi

    mkdir -p "$work/internal-not-in-git"
    for f in $present; do cp "$LEDGER_DIR/$f" "$work/internal-not-in-git/$f"; done
    git -C "$work" add -A >/dev/null 2>&1
    if git -C "$work" diff --cached --quiet 2>/dev/null; then
      # Nothing changed since the last backup. That IS a current backup, so the stamp moves:
      # otherwise a quiet week would report "behind" forever and teach the user to ignore it.
      stamp_now
      echo "ledger-backup: already current ($remote/$branch)"
      exit 0
    fi
    git -C "$work" -c user.name="${GIT_AUTHOR_NAME:-odeo}" \
                   -c user.email="${GIT_AUTHOR_EMAIL:-odeo@localhost}" \
        commit -q -m "chore(backup): refresh the gitignored working files" >/dev/null 2>&1 \
        || { echo "ledger-backup: commit failed" >&2; exit 4; }
    if ! git -C "$work" push -q origin "HEAD:$branch" >/dev/null 2>&1; then
      # The copy exists locally, in a temp dir about to be deleted. Saying "backed up" here is
      # the exact lie this program was written to stop, so the stamp does NOT move.
      echo "ledger-backup: PUSH REFUSED to $remote/$branch, so NOTHING was backed up." >&2
      echo "  Common causes: expired credentials, branch protection, or a diverged branch." >&2
      exit 5
    fi
    stamp_now
    echo "ledger-backup: refreshed ($present -> $remote/$branch:internal-not-in-git/)"
    exit 0
    ;;
  *)
    echo "ledger-backup: unknown ledger_backup kind '$KIND' (expected 'git' or 'dir')" >&2
    exit 2
    ;;
esac
