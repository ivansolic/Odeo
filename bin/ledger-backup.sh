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
#   2  refused or undecidable: usage, a ledger_backup: line this program will not act on (a
#      relative dir, an unknown kind, a target inside ANY git repository, the project's own
#      publish remote), an unreadable ledger, or the caller is not inside a git work tree
#      What this program CANNOT decide, so nobody reads more into a green run: whether a remote
#      is PUBLIC. It refuses the project's publish remote by name and by normalised URL, which
#      catches the obvious mistake; an ssh spelling of the same host, a mirror or a fork are
#      invisible here, and choosing a private target stays the human's call.
#   3  no ledger_backup: line recorded (not a failure: nothing was promised)
#   4  target unreachable (no such remote, clone/fetch failed, directory missing)
#   5  the copy was made but PUSH WAS REFUSED, so nothing was backed up
#   6  nothing to back up (neither ledger file exists)
set -uo pipefail
# Every git call below is meant to be about the PROJECT DIRECTORY passed in. Inherited GIT_DIR
# or GIT_WORK_TREE silently redirect all of them at the repository the caller's environment
# names instead, which is routine when this runs from a git hook, and would make the program
# read one repository's ledger and stamp another's. Dropped once, here, rather than guarded at
# each call site.
unset GIT_DIR GIT_WORK_TREE

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
# An UNREADABLE ledger directory is not an empty one. Without this, `chmod 000 .claude/tasks`
# makes every `[ -f ]` below false, so the program reports "nothing to back up" and exits 0,
# and the Stop hook then stays silent forever about a ledger it cannot see. That is the same
# silent-failure shape this program exists to close, one line above the branch where it was
# closed for timestamps.
if [ -d "$LEDGER_DIR" ] && ! ls "$LEDGER_DIR" >/dev/null 2>&1; then
  echo "ledger-backup: $LEDGER_DIR exists but cannot be read, so whether there is anything to" >&2
  echo "  back up cannot be decided. Reporting nothing would be a lie." >&2
  exit 2
fi
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
# Matched as a PLACEHOLDER SHAPE (<word>), not on the characters themselves: `<` and `>` are
# legal in a directory name, and rejecting any value containing one would silently turn the
# backup off for a real target called `out>put`, with the hook then quiet forever.
case "$CONFIG" in
  *'<'*'>'*)
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
    # The PARENT must exist: creating a whole tree for a mistyped path would silently back up
    # into a directory nobody syncs, which reads as success and protects nothing.
    parent="$(dirname "$dest")"
    [ -d "$parent" ] || { echo "ledger-backup: no such directory: $parent" >&2; exit 4; }

    # THE INVARIANT: a backup target may not live inside ANY git work tree.
    #
    # This replaced three rounds of asking the narrower question, "is it inside THIS project",
    # which turned out to have an endless supply of disguises. Each round closed the spelling
    # the previous one demonstrated and opened another: the raw prefix compare missed a
    # symlink, a `..` and a case difference; asking git about the destination's PARENT closed
    # those and reopened a nested repo the prefix compare had caught, plus a sibling worktree
    # and a destination that is itself a symlink. Trading one failure shape for another is the
    # signature of guarding instances instead of removing the class.
    #
    # So the question changed instead of the answer. "Not in any repository" is decided by git
    # in one call, for every disguise at once, because a resolved directory either sits in a
    # work tree or does not. It is also the stronger rule, and the honest one: a backup inside
    # a repo shares the disk it protects against, and any `git add -A` can publish it.
    #
    # The KNOWN RESIDUAL, written down rather than discovered later: a synced folder that
    # happens to live inside some unrelated repository is refused too. That is a real cost and
    # a deliberate one.
    # THREE answers, not two. git exiting non-zero means "not a repository" only when it says
    # so; it also fails when it cannot READ the repository (dubious ownership on a shared
    # mount, an unreadable .git/config), and treating that ignorance as "no repository here"
    # put the ledger inside that repository at exit 0. One line above, this same program
    # refuses an unreadable ledger because reporting nothing would be a lie; the two had
    # opposite policies for the same ignorance.
    # DECIDED ON DISK, NEVER FROM A MESSAGE. This guard asked git and then read the ANSWER OUT
    # OF ITS STDERR, and git prints the same "not a git repository" sentence for two opposite
    # situations: there is no repository here, and there is one it cannot follow (a linked
    # worktree whose administrative directory is unreadable, a `.git` file pointing at a gitdir
    # that is gone). Measured on the shipped script: the second landed the ledger in the LIVE
    # work tree at exit 0, with the stamp written, so `--check` then reported "up to date"
    # about a copy inside the repository it exists to survive.
    #
    # That was the third round in which this same guard failed open on a decision keyed to text,
    # so the wording is not patched again. The question is answered without asking git at all:
    # a path is inside a repository if any ancestor carries a repository MARKER. Markers do not
    # move with git's locale, version or error phrasing, and an unreadable one is still visible,
    # which turns the whole failure mode from "guess no" into "see it".
    #
    # Both marker shapes are checked, because the old exit-status version accepted both and
    # losing either would be a silent regression (pinned by case 32):
    #   - a `.git` entry, whether directory, file (linked worktree, submodule) or dangling link;
    #   - a git directory itself, i.e. HEAD + objects/ + refs/, which is what a BARE repository
    #     and a `.git` directory look like from outside, and neither has a `.git` child.
    # Only traversal is required, never read permission, so a repository locked down to 000 is
    # detected rather than walked into.
    #
    # KNOWN RESIDUAL, unchanged and stated rather than discovered: a directory that merely
    # CONTAINS a file named `.git` without being a repository is refused too. Fail-closed, and
    # the cost is one confusing refusal against a leak that reports success.
    in_work_tree() {
      local p="$1"
      while :; do
        if [ -e "$p/.git" ] || [ -L "$p/.git" ]; then return 0; fi
        if [ -e "$p/HEAD" ] && [ -d "$p/objects" ] && [ -d "$p/refs" ]; then return 0; fi
        [ "$p" = "/" ] && break
        p="$(dirname "$p")"
      done
      return 1
    }
    refuse_in_repo() {
      echo "ledger-backup: the target is inside a git repository ($1)" >&2
      echo "  A backup in a repo is not a backup: it shares the disk it protects against, and" >&2
      echo "  the next 'git add -A' commits the ledger you are keeping out of git." >&2
      echo "  Point it at a directory outside every repository." >&2
      exit 2
    }
    parent_real="$(cd "$parent" 2>/dev/null && pwd -P)" \
      || { echo "ledger-backup: cannot resolve $parent" >&2; exit 4; }
    # Asked BEFORE creating anything, so an obvious mistake costs no directory...
    in_work_tree "$parent_real" && refuse_in_repo "$parent_real"
    mkdir -p "$dest/internal-not-in-git" 2>/dev/null \
      || { echo "ledger-backup: cannot write to $dest" >&2; exit 4; }
    # ...and again on the directory the files ACTUALLY LAND IN, once it exists. Not on `$dest`:
    # either `$dest` or `internal-not-in-git` inside it can be a symlink that mkdir follows
    # somewhere else, and asking about `$dest` missed the second one by exactly one level. The
    # question is unchanged; only the argument is now the real landing place.
    # Empty directories are removed on refusal; rmdir cannot take anything that is not empty,
    # and it cannot take a symlink either, so a planted one is left as it was found.
    landing_real="$(cd "$dest/internal-not-in-git" 2>/dev/null && pwd -P)" \
      || { echo "ledger-backup: cannot resolve $dest/internal-not-in-git" >&2; exit 4; }
    if in_work_tree "$landing_real"; then
      rmdir "$dest/internal-not-in-git" "$dest" 2>/dev/null
      refuse_in_repo "$landing_real"
    fi
    # Staged, then moved into place. Copying straight in could leave todo.md refreshed and
    # lessons.md not, which would make the exit-4 message ("nothing was backed up") false, and
    # a half-true failure message is worse than a blunt one. Both files are written to a
    # staging dir on the SAME filesystem first, so the moves are renames.
    # The trap matters because the staging dir sits INSIDE the destination: an interrupted run
    # would otherwise leave a full copy of the ledger in a synced folder forever, under a name
    # nobody recognises.
    staging="$dest/internal-not-in-git/.staging.$$"
    rm -rf "$staging"; mkdir -p "$staging" 2>/dev/null \
      || { echo "ledger-backup: cannot write to $dest" >&2; exit 4; }
    trap 'rm -rf "$staging"' EXIT INT TERM
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

    # NEVER the project's publish remote. `ledger_backup: git origin internal-files` is one
    # plausible typo away from pushing todo.md and lessons.md to the repository the world
    # reads, and the whole reason these files are gitignored is that they must never get
    # there. Compared by URL as well as by name, because a second remote name can point at the
    # same repository and the name is not the thing that publishes.
    # Compared after NORMALISATION, because the plain text compare was three spellings of one
    # repository away from useless, and all three were measured pushing the ledger to the
    # publish remote: a trailing slash, a trailing `/.`, and a `..` in the middle.
    #   - `ls-remote --get-url` is GIT's own answer, so `insteadOf` rewrites are applied by
    #     the tool that will do the pushing rather than guessed at here;
    #   - a URL that is a local PATH is resolved with `pwd -P`, the same mechanism the `dir`
    #     invariant already uses, which settles every punctuation spelling at once;
    #   - otherwise one trailing `/` and one trailing `.git` are dropped, which is the whole
    #     of what this normalisation claims.
    # WHAT IT DOES NOT DO, so nobody reads more into it: it cannot decide whether a remote is
    # PUBLIC. ssh and https spellings of the same host, a mirror under another name, a fork:
    # all invisible here. Choosing a backup target that is not published stays the human's
    # call, and /retro's exit-2 row says so.
    canon_url() {
      local u="$1"
      [ -n "$u" ] || return 0
      if [ -d "$u" ]; then ( cd "$u" 2>/dev/null && pwd -P ) && return 0; fi
      u="${u%/}"; u="${u%.git}"
      printf '%s' "$u"
    }
    pub_remote="${CLAUDE_PUBLIC_REMOTE:-origin}"
    pub_url="$(git -C "$PROJECT_DIR" ls-remote --get-url "$pub_remote" 2>/dev/null || true)"
    [ "$pub_url" = "$pub_remote" ] && pub_url=""     # git echoes the name back when unknown
    url="$(git -C "$PROJECT_DIR" ls-remote --get-url "$remote" 2>/dev/null || printf '%s' "$url")"
    if [ "$remote" = "$pub_remote" ] \
       || { [ -n "$pub_url" ] && [ "$(canon_url "$url")" = "$(canon_url "$pub_url")" ]; }; then
      echo "ledger-backup: '$remote' is this project's publish remote ($url)." >&2
      echo "  The ledger is gitignored precisely so it never reaches there; pushing it to the" >&2
      echo "  public repository would publish the task state and every recorded correction." >&2
      echo "  Use a separate private remote for the backup." >&2
      exit 2
    fi

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

    # Checked, for the same reason the dir branch checks: an unchecked cp on a cloned branch
    # leaves the file the CLONE brought, which is the previous backup. `add -A` then sees no
    # change, the run reports "already current", and the stamp moves. A silently skipped
    # update would be indistinguishable from a successful one, which is the whole failure
    # class this program exists to close, one branch over from where it was closed.
    mkdir -p "$work/internal-not-in-git" \
      || { echo "ledger-backup: cannot write the clone, NOTHING was backed up" >&2; exit 4; }
    for f in $present; do
      cp "$LEDGER_DIR/$f" "$work/internal-not-in-git/$f" \
        || { echo "ledger-backup: copy failed for $f, NOTHING was backed up" >&2; exit 4; }
    done
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
