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
#      relative dir OR a relative remote URL, an unknown kind, a target inside ANY git
#      repository, a remote that IS this repository however it is spelled, the project's own
#      publish remote), an unreadable ledger, or the caller is not inside a git work tree
#      What this program CANNOT decide, so nobody reads more into a green run: whether a remote
#      is PUBLIC. It refuses the project's publish remote by name and by normalised URL, which
#      catches the obvious mistake; an ssh spelling of the same host, a mirror or a fork are
#      invisible here, and choosing a private target stays the human's call.
#   3  nothing was promised: no ledger_backup: line recorded, OR the line still holds the
#      template's <placeholder> (the message says which). Not a failure.
#   4  the target could not be used: no remote of that name, an unreachable or unreadable
#      remote, a local remote url this program CANNOT SEE (it reads as a path, nothing is there,
#      so containment cannot be asked and the run stops rather than guess), a clone that failed,
#      a missing directory, or a copy that failed. A failed COPY
#      places nothing (the files are staged first); a failure during the final MOVES can leave
#      an incomplete set, and the message distinguishes the two.
#   5  the copy was made but PUSH WAS REFUSED, so nothing was backed up
#   6  nothing to back up (neither ledger file exists)
set -uo pipefail
# THE WHOLE GIT ENVIRONMENT IS DROPPED, not the two variables that name a repository.
#
# Every git call below is meant to be about the PROJECT DIRECTORY passed in. Inherited GIT_DIR
# or GIT_WORK_TREE silently redirect all of them at whatever repository the caller's environment
# names, which is routine when this runs from a git hook.
#
# GIT_INDEX_FILE is the one that does real damage, and it is why this list is not shorter. git
# exports it to pre-commit, prepare-commit-msg, commit-msg and post-commit, and under
# `git commit -a` it is an ABSOLUTE path to the project's own index. Measured before this line
# covered it: the temp clone's `git add -A` wrote the ledger into the PROJECT's index, the run
# reported success and stamped it, `git status` then failed with "unable to read <sha>", and a
# real pre-commit hook turned it into "error: Error building trees", so the user's commit did
# not happen while the backup claimed it did. Destroying the caller's index is a worse outcome
# than not backing up.
#
# The rest are the remaining members of the same family (object storage, common dir, namespace,
# quarantine), dropped together rather than one per incident: they are what git hands a hook,
# and a program that takes a project directory as an argument must answer about that directory
# and nothing the environment quietly points at.
#
# TWO KINDS of variable matter here, and the first list covered only one. Those above NAME a
# repository. The GIT_CONFIG_* family REWRITES one: git exports GIT_CONFIG_PARAMETERS to hooks,
# and a `url.<other>.insteadOf` pair sends the push somewhere else entirely. Measured before
# this line existed: the configured remote stayed empty and the ledger arrived at the injected
# one, at exit 0 with the stamp written. Dropping GIT_CONFIG_COUNT is what neutralises every
# GIT_CONFIG_KEY_n, because git reads the numbered keys only through that count.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_QUARANTINE_PATH \
      GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM

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

# NOT named GIT_DIR. Under `set -a` (SHELLOPTS=allexport, which bash reads from the environment)
# every assignment this script makes becomes an EXPORTED variable, so a local called GIT_DIR
# turns back into the git variable the unset above exists to remove, and the index corruption
# closed one commit earlier returns with no change to this file. A script that unsets a name
# must not then reuse it.
PROJECT_GIT_DIR="$(git -C "$PROJECT_DIR" rev-parse --absolute-git-dir 2>/dev/null)" || PROJECT_GIT_DIR=""
[ -n "$PROJECT_GIT_DIR" ] || { echo "ledger-backup: $PROJECT_DIR is not a git work tree" >&2; exit 2; }

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
STAMP="$PROJECT_GIT_DIR/odeo-ledger-backup-stamp"

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

# --- THE CONTAINMENT INVARIANT ------------------------------------------------------------
# A backup may not land inside a git repository. Defined HERE, above the kinds, because it was
# written inside the `dir` arm and therefore never asked on the `git` one: a `backup` remote
# that is a bare repository sitting INSIDE the work tree passed at exit 0, stamped, and left
# the ledger's objects in the project where the next `git add -A` stages them. The rule is a
# property of backups, not of one spelling of a target, so it lives where both arms see it.
#
# This replaced three rounds of asking the narrower question, "is it inside THIS project",
# which had an endless supply of disguises. Each round closed the spelling the previous one
# demonstrated and opened another: a raw prefix compare missed a symlink, a `..` and a case
# difference; asking git about the destination's PARENT closed those and reopened a nested
# repo, a sibling worktree and a destination that is itself a symlink. Trading one failure
# shape for another is the signature of guarding instances instead of removing the class.
#
# So the question changed instead of the answer, twice. First from "inside this project" to
# "inside any repository", which one question settles for every disguise at once and is the
# stronger rule anyway: a backup inside a repo shares the disk it protects against.
#
# Then from asking GIT to reading the DISK. The previous version called git and matched its
# stderr, and git prints the same "not a git repository" sentence for two opposite situations:
# there is none here, and there is one it cannot follow (a linked worktree whose administrative
# directory is unreadable, a `.git` file pointing at a gitdir that is gone). Measured on the
# shipped script: the second landed the ledger in the LIVE work tree at exit 0 with the stamp
# written, so `--check` then called it current. A path is now inside a repository if any
# ancestor carries a repository MARKER. Markers do not move with git's locale, version or
# phrasing, and an unreadable one is still VISIBLE, which turns "guess no" into "see it".
#
# Both marker shapes are checked, because the old exit-status version accepted both and losing
# either would be a silent regression (pinned by case 32):
#   - a `.git` entry, whether directory, file (linked worktree, submodule) or dangling link;
#   - a git directory itself, i.e. HEAD + objects/ + refs/, which is what a BARE repository and
#     a `.git` directory look like from outside, and neither has a `.git` child.
# Only traversal is required, never read permission, so a repository locked down to 000 is
# detected rather than walked into.
#
# KNOWN RESIDUALS, stated rather than discovered later: a synced folder that happens to sit
# inside an unrelated repository is refused too; and a directory that merely CONTAINS a file
# named `.git`, or the three names of a git directory, without being a repository, is refused
# as well. Both are fail-closed, and the cost is a confusing refusal against a leak that
# reports success.
IN_REPO_MARKER=""
in_work_tree() {
  local p="$1"
  IN_REPO_MARKER=""
  while :; do
    if [ -e "$p/.git" ] || [ -L "$p/.git" ]; then IN_REPO_MARKER="$p/.git"; return 0; fi
    if [ -e "$p/HEAD" ] && [ -d "$p/objects" ] && [ -d "$p/refs" ]; then IN_REPO_MARKER="$p"; return 0; fi
    [ "$p" = "/" ] && break
    p="$(dirname "$p")"
  done
  return 1
}
refuse_in_repo() {
  echo "ledger-backup: the target is inside a git repository ($1)" >&2
  # The MARKER is named, not just the target. With the decision made on disk, the repository
  # that refuses a path can be several levels above it (a dotfiles $HOME refuses ~/Dropbox/...,
  # which is this file's own documented example), and a message naming only the target sends
  # the reader looking in the wrong directory.
  [ -n "$IN_REPO_MARKER" ] && echo "  The repository that contains it: $IN_REPO_MARKER" >&2
  echo "  A backup in a repo is not a backup: it shares the disk it protects against, and" >&2
  echo "  the next 'git add -A' commits the ledger you are keeping out of git." >&2
  echo "  Point it at a directory outside every repository." >&2
  exit 2
}

case "$KIND" in
  dir)
    dest="$(printf '%s' "$CONFIG" | sed -E 's/^dir[[:space:]]+//')"
    dest="${dest/#\~/$HOME}"
    [ -n "$dest" ] || { echo "ledger-backup: 'dir' needs a path" >&2; exit 2; }
    # ABSOLUTE ONLY. A relative target resolves against whatever directory the caller happens
    # to be in, and /odeo:retro runs this from the project root: `dir backupdir` then writes the
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

    # The containment invariant and both helpers are defined above the `case`, so this arm and
    # the `git` one ask the same question.
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
    # call, and /odeo:retro's exit-2 row says so.
    # ONE CONVERSION FROM URL TO PATH, FOR BOTH GUARDS BELOW. The publish check and the
    # containment check each used to carry their own, and two conversions are two answers: the
    # same repository spelled `file://localhost/srv/pub.git` was a path to one of them and an
    # opaque string to the other, so the containment guard refused the plain spelling while the
    # publish guard let the file-URL spelling through and THE LEDGER WAS PUSHED TO THE PUBLISH
    # REMOTE at exit 0. Four leaks were measured across the two, all of them disagreements
    # rather than missing rules. A shared function is what makes that class impossible: there is
    # no second answer to differ from.
    #
    # Two things it gets right that a spelling list did not:
    #   - A file URL's AUTHORITY is IGNORED BY GIT, not merely permitted when empty. Measured:
    #     `localhost`, `LOCALHOST`, `notahost` and this machine's own name all resolve to the
    #     local path. Stripping the literal `file://` alone left the authority glued to the
    #     front, so the result was never a directory and the guard simply did not fire.
    #   - scp syntax is `[user@]host:path`, and git reads it that way ONLY when no `/` precedes
    #     the colon. `/srv/a@b:c/t.git` is an absolute PATH; the old `*@*:*` arm called it a
    #     host transport and waved it past.
    # A RELATIVE url yields nothing here on purpose: this program cannot root it, because it
    # would have to agree with a `git clone` run from the CALLER's directory. It is refused
    # above rather than guessed at. A LEADING `~` is expanded, which is not a relative path and
    # not modelling: git expands it, the `dir` arm at `:278` has always expanded it with this
    # same idiom, and `~/backup.git` is the line a human is most likely to write by hand.
    local_url_path() {                 # <url> -> the local path it names, or nothing
      local u="$1" p=""
      # The `~` is QUOTED in the pattern. Unquoted, bash tilde-expands the pattern itself, so it
      # would compare the url against $HOME and never match the literal character. Measured: the
      # expansion silently did nothing and `~/backup.git` was still refused as relative.
      case "$u" in '~'|'~'/*) u="${u/#\~/$HOME}" ;; esac
      case "$u" in
        file://*)
          p="${u#file://}"
          case "$p" in
            /*)  : ;;                  # file:///path, the empty authority
            */*) p="/${p#*/}" ;;       # file://host/path, the authority git ignores
            *)   p="" ;;               # an authority and no path at all
          esac ;;
        *://*) : ;;                    # any other scheme: genuinely remote
        /*)    p="$u" ;;               # an absolute path, colons and @ included
        *:*)   case "${u%%:*}" in
                 */*) p="$u" ;;        # a slash before the colon: a relative path, not a host
                 *)   : ;;             # host:path
               esac ;;
      esac
      printf '%s' "$p"
    }

    # RELATIVE, asked separately from the conversion above. KNOWN, MEASURED DISAGREEMENT between
    # the two, left open rather than papered over: `a/b:c` and `./a:b/c` are relative here and a
    # path there, so the same line is refused with one reason or another depending on the
    # caller's directory. Both outcomes are refusals at exit 2, so nothing leaks through the gap;
    # it is the MESSAGE that can be the wrong one.
    url_is_relative() {
      case "$1" in
        *://*|/*|'~'|'~'/*) return 1 ;;   # quoted `~`: an unquoted one is expanded, see above
        *:*) case "${1%%:*}" in */*) return 0 ;; *) return 1 ;; esac ;;
        *) return 0 ;;
      esac
    }

    canon_url() {
      local u="$1" p
      [ -n "$u" ] || return 0
      p="$(local_url_path "$u")"
      if [ -n "$p" ] && [ -d "$p" ]; then ( cd "$p" 2>/dev/null && pwd -P ) && return 0; fi
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

    # A RELATIVE URL IS REFUSED, because the path this program CHECKS would not be the path git
    # USES. git roots a relative remote at the repository that configured it; this program hands
    # the raw string to `ls-remote` and `clone`, which run from the CALLER's directory. Measured
    # on the previous commit, running from inside an unrelated repository R: with the branch
    # already present the clone path was taken and THE LEDGER LANDED IN R at exit 0, and with the
    # branch absent the push failed from the temp directory and blamed credentials.
    # Making the two agree was the alternative, and it was rejected: the agreement would have to
    # hold at every future call site, which is the assumption that failed here. The `dir` arm
    # already refuses a relative target, so both arms now answer alike.
    if url_is_relative "$url"; then
      echo "ledger-backup: '$remote' is a relative URL ($url)." >&2
      echo "  Where it points depends on the directory this program is run from, so the target" >&2
      echo "  checked here would not be the one git writes to. Give an absolute path or a URL." >&2
      exit 2
    fi

    # THE CONTAINMENT INVARIANT ON A LOCAL REMOTE, asked as TWO QUESTIONS ABOUT IDENTITY AND
    # LOCATION, never about how the URL was written.
    #
    # The previous version tested `[ -d "$url" ]` and walked the parent. That recognised exactly
    # one spelling. Three others were measured landing the ledger inside the project's own
    # repository at exit 0 with the stamp written: `file://` (the test is simply false for it),
    # a sibling linked WORKTREE of the project, and the project directory ITSELF. The last two
    # are the worse shape, because the ledger becomes a committed ref in the project's object
    # store rather than loose objects waiting for someone's `git add -A`.
    #
    # Enumerating spellings is what three earlier rounds of this same guard did on the other
    # arm, each closing the one that had been demonstrated. So the question changed again:
    #
    #   1. IS IT THIS REPOSITORY? Compared by git COMMON DIR, which is the identity of a
    #      repository rather than of a path. A linked worktree and its main checkout report the
    #      same common dir, which is exactly why a worktree is refused here: it shares the
    #      object store, so a push into it is a push into the project. This answers for every
    #      way of naming the same repository at once, including ones nobody listed.
    #   2. IS IT INSIDE ONE? The ancestor walk already used by the `dir` arm, applied to the
    #      remote's PARENT. A bare repository IS a repository, so asking about the target itself
    #      would refuse every legitimate local remote; its parent answers "is this sitting in
    #      somebody's work tree".
    #
    # Together these keep the legitimate case that a shape-based rule would have killed: an
    # ordinary CLONE elsewhere on disk, pushed to a branch it does not have checked out, is a
    # real configuration and stays allowed (case 38). It is refused only if it is this
    # repository or lives inside one.
    #
    # The URL reaches these two questions as a PATH, through the one conversion the publish
    # refusal above also uses, so no spelling can be a path to one guard and opaque to the other.
    # A relative URL never arrives here at all: it is refused above, because this program cannot
    # know the directory git would resolve it from. What does not convert (ssh, https, git://)
    # is genuinely remote; the publish-remote refusal is what covers it, with the residual
    # stated in the header.
    # KNOWN RESIDUALS OF THE CONTAINMENT INVARIANT ON THE `git` ARM, stated so a green run is not
    # read as more than it is. Each was measured, not assumed.
    #   - A NON-LOCAL URL CANNOT BE CONTAINED. ssh, https and git:// targets are not paths, so
    #     neither question can be asked of them. The publish-remote refusal is all that covers
    #     them, and it knows one repository, not the class of public ones.
    #   - WHETHER A REMOTE IS PUBLIC IS NOT DECIDABLE HERE. An ssh spelling of the publish remote,
    #     a mirror, a fork: all invisible. Choosing a private target stays the human's call.
    #   - IDENTITY IS ASKED OF GIT, AND GIT CAN REFUSE TO ANSWER. A repository git will not open
    #     (an unreadable worktree admin directory, dubious ownership on a shared mount) yields no
    #     common dir, and the run falls back to the location question alone. Measured on the
    #     unreadable case: the same refusal also stops the push, so it ends at exit 4, not in a
    #     leak. That is an observation about git, not a guarantee this program enforces.
    #   - A REMOTE THAT BORROWS THE PROJECT'S OBJECT STORE (objects/info/alternates) IS ACCEPTED.
    #     Measured: the push writes nothing into the project, and the backup still reads after the
    #     alternate is removed, so containment does not fail here. It is simply not asked about.
    #   - A WINDOWS DRIVE-LETTER TARGET (C:/backup.git) IS NOT RECOGNISED AS A LOCAL PATH. The
    #     `git` arm treats it as a remote url and does not walk it; the `dir` arm refuses it as
    #     non-absolute. Stated rather than claimed: not tested on Windows.
    #   - EXIT 0 AGAINST A REAL NETWORK REMOTE IS NOT PROVEN BY THE SUITE. Every remote under test
    #     is a local repository. Exits 4 and 5 are proven against git's own refusals; a green run
    #     against a live remote is owner attestation.
    #   - A LEADING `~` IS EXPANDED WITH THIS PROCESS'S $HOME, which is what makes `~/backup.git`
    #     work. If the caller's $HOME differs from the one git would use (sudo without -H, a
    #     daemon), the path checked here is not the path git resolves. Both then refuse or both
    #     resolve the same directory in every arrangement measured, but the equality is $HOME's,
    #     not this program's.
    #   - A DIRECTORY THAT EXISTS HERE MAY STILL NOT BE GIT'S. Measured once, by planting a
    #     directory literally named with `%2f`: the conversion sees a directory, the guard runs
    #     and answers about it, and git decodes the name to a different path. Decoding here would
    #     be a fourth model of git's grammar, which is the thing this design stopped doing.
    #   - THE IDENTITY TEST HAS A TOCTOU WINDOW of microseconds: if a common dir is removed
    #     between `pwd -P` and `-ef`, the answer flips from SAME to DIFFERENT. The same race the
    #     guard has always had, stated rather than discovered later.
    # THE GUARD IS NEVER SKIPPED. This block used to run only when the converted path was a
    # directory, and every round of this defect has come back through that door: a url this
    # program reads as "not a path I can see" is not a url git cannot use. git decodes `%2e%2e`
    # and `%20`; measured, that put the ledger on the PUBLISH REMOTE and into the project's own
    # repository at exit 0 with the stamp, with the containment questions never asked.
    #
    # Percent-decoding here would be the FOURTH model of git's url grammar, and the previous
    # three were each correct about what was known at the time. So the question is not "what else
    # does git decode" but "may this program act on a target it cannot see". It may not. If the
    # conversion yields a path and that path is not a directory HERE, the run stops at exit 4,
    # the code this configuration already returns for a target that cannot be used. An encoding
    # nobody has thought of now fails closed instead of failing open.
    #
    # What this deliberately does NOT do: refuse when the conversion yields NOTHING. ssh, https
    # and git:// are not paths at all, and refusing them would kill every real remote backup.
    # They are covered by the publish refusal and named in the residuals above.
    local_path="$(local_url_path "$url")"
    if [ -n "$local_path" ] && [ ! -d "$local_path" ]; then
      echo "ledger-backup: cannot see the target of '$remote' ($url) from here." >&2
      echo "  It reads as a local path, but no directory is there, so this program cannot ask" >&2
      echo "  whether it sits inside this repository. git may still resolve it (it decodes" >&2
      echo "  percent escapes, for one), and a target that cannot be checked is not backed up." >&2
      exit 4
    fi
    if [ -n "$local_path" ] && [ -d "$local_path" ]; then
      url_real="$(cd "$local_path" 2>/dev/null && pwd -P)" \
        || { echo "ledger-backup: cannot resolve the remote path $local_path" >&2; exit 4; }
      # The common dir can be reported relative to the repository, so it is resolved from
      # inside it. A path that is not a repository at all simply yields nothing and falls
      # through to question 2, which is correct: git would fail the clone later with exit 4.
      remote_common="$(cd "$url_real" 2>/dev/null \
        && d="$(git rev-parse --git-common-dir 2>/dev/null)" && cd "$d" 2>/dev/null && pwd -P)" || remote_common=""
      project_common="$(cd "$PROJECT_DIR" 2>/dev/null \
        && d="$(git rev-parse --git-common-dir 2>/dev/null)" && cd "$d" 2>/dev/null && pwd -P)" || project_common=""
      # `-ef`, NOT a string compare. `pwd -P` resolves symlinks but preserves the CASE you typed,
      # and this is developed on a case-insensitive filesystem, so `$PROJECT` and `$PROJECTUPPER`
      # are one directory under two spellings. Measured: the identity question answered "a
      # different repository" about the project itself, and the ledger became a ref in the repo it
      # exists to stay out of, at exit 0 with the stamp. A capitalisation typo, not an attack.
      # `-ef` asks the filesystem whether the two names are the same file (device and inode),
      # which is the question this line always meant to ask. The `dir` arm's own hazard note
      # (case 20) is the same lesson, never carried across to this arm until now.
      if [ -n "$remote_common" ] && [ -n "$project_common" ] \
         && [ "$remote_common" -ef "$project_common" ]; then
        echo "ledger-backup: '$remote' IS this project's own repository ($url_real)." >&2
        echo "  It shares the object store, so the backup would be a branch inside the very" >&2
        echo "  repository the ledger is kept out of, readable by anyone who clones it." >&2
        echo "  Point the backup at a separate private repository." >&2
        exit 2
      fi
      if in_work_tree "$(dirname "$url_real")"; then
        refuse_in_repo "$url_real"
      fi
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
