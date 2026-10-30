#!/usr/bin/env bash
# Tests for scripts/odeo-migrate-legacy.sh: moves the copies an install.sh install left in the
# home directory out of the way of the plugin, so nothing loads twice.
#
# The guarantees are OUTCOMES, checked on a fake HOME: a dry run (the default) changes
# nothing; --apply moves exactly the install.sh-placed items (Odeo's skill, agent and bin
# names, odeo-docs, ~/.claude-templates) into one ~/.claude/odeo-legacy-<ts>/ folder;
# everything else survives in place, including a skill or agent of the user's own that merely
# shares an Odeo name (moved only when its content is a copy Odeo shipped); and no file is
# ever deleted (the file count over home is identical before and after).
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 apply by default                      -> 3 FAIL (case 1)
#   M2 `rm -rf` instead of `mv`              -> 9 FAIL (case 2: every kept-in-legacy + count)
#   M3 also move ~/.claude/CLAUDE.md          -> 1 FAIL (case 2, untouched)
#   M4 no shims (SHIM_NAMES empty)           -> 11 FAIL (cases 2, 7, 8, 8b, 9, 10)
#   M5 shim exits 0 when no plugin is found  -> 2 FAIL (cases 8, 8b, fails open)
#   M6 no plugin-root check                  -> 3 FAIL (cases 11, 12)
#   M7 shim may exec itself (drop -ef)       -> 1 FAIL (case 8b, 143 from the watchdog)
#   M8 shim marker matched anywhere in file  -> 1 FAIL (case 12). Write this mutant as
#      `grep -q "$SHIM_MARKER" "$HOME/$f"`: dropping the FILE argument too leaves a grep
#      reading stdin, which hangs the run instead of testing the rule (it did, once).
#   M9 shim loop reads the cache listing on stdin -> 2 FAIL (cases 13, 14: the guard got the
#      listing, 550 bytes, instead of the pushed paths, and passed an internal path)
#   M10 no refresh of outdated shims         -> 2 FAIL (case 15)
#   M11 refresh overwrites without a copy    -> 1 FAIL (case 15, nothing is ever deleted)
# Observed failing (2026-09-29), after the move to scripts/:
#   M12 the bin/ wrapper (tests/fixtures/legacy-bin-wrapper.sh) exits 0 without forwarding -> 2 FAIL (case 16)
#   M13 bounded() without the explicit <&0 (stdin becomes /dev/null) -> 1 FAIL (case 16)
# Observed failing (2026-10-29), after skills and agents are moved only on a content match
# (the fake roots carry a fixture hash list; case 23 uses the real list):
#   M14 recognise by name only (known_copy always true)           -> 22 FAIL (cases 17-21, 23)
#   M15 hash the skill DIRECTORY instead of its SKILL.md          -> 18 FAIL (cases 2, 3, 18, 19, 20, 23: nothing moves)
#   M16 hash the plugin's copy of an agent, not the user's file   -> 6 FAIL (cases 2, 18, 23)
#   M17 a bare set of hashes (kind and name not bound)            -> 4 FAIL (cases 20, 22)
#   M18 the loader drops one list line (fixture line 4)           -> 2 FAIL (case 2: that entry no longer recognises its copy)
#   M19 the REAL list loses the current `skill research` entry    -> 1 FAIL (case 23)
#   M20 a missing list is tolerated (no refusal)                  -> 2 FAIL (case 22)
#   M21 every skill is moved (the keep branch removed)            -> 20 FAIL (cases 17-21)
#   M22 the bin/ scan also walks the list file                    -> 1 FAIL (case 24)
#   M23 the left-in-place report is silent                        -> 11 FAIL (cases 17, 19, 21)
#   M24 list lines are not validated                              -> 1 FAIL (case 22, the loud report only: matching is by exact
#       whole line, so a malformed line could never recognise a copy anyway; the check is for the maintainer to see)
# Observed failing (2026-10-30), after the list loader matches each line in the shell
# (`[[ "$line" =~ $LIST_LINE_RE ]]`) instead of forking grep per line:
#   M25 the line regex wants 65 hex characters, not 64            -> 24 FAIL (cases 2, 3, 17-21, 22, 23: no valid line loads)
#   M26 the line regex is `^.*$` (every line accepted)           -> 2 FAIL (case 22: no malformed line reported, and the count)
#   M27 the line regex loses its ^ and $ anchors                  -> 1 FAIL (case 22: the count, 4 reported instead of 5, because
#       the line with one stray character still contains a valid line)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REAL_SCRIPT="$ROOT/scripts/odeo-migrate-legacy.sh"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }
exists() { if [ -e "$2" ] || [ -L "$2" ]; then ok "$1"; else bad "$1 ($2 missing)"; fi; }
gone() { if [ -e "$2" ] || [ -L "$2" ]; then bad "$1 ($2 still there)"; else ok "$1"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
count_files() { find "$1" \( -type f -o -type l \) | wc -l | tr -d ' '; }
# fake_root <dir>: a removable copy of the plugin root (manifest, scripts, skills, agents), so
# a shim's baked fallback can be taken away the way an uninstall or cache sweep would
fake_root() {
  mkdir -p "$1/docs"; cp -R "$ROOT/.claude-plugin" "$ROOT/scripts" "$ROOT/skills" "$ROOT/agents" "$1/"
  cp "$ROOT/docs/agent-rubric.md" "$1/docs/"
  fixture_list > "$1/$LIST_REL"; printf '%s' "$1"
}
# sha_str <text>: sha256 of the text exactly as given (shasum on macOS, sha256sum elsewhere)
sha_str() { printf '%s' "$1" | { shasum -a 256 2>/dev/null || sha256sum; } | awk '{print $1}'; }
# The hash list a plugin root carries (what the script recognises as Odeo's). Fake roots get a
# FIXTURE list built from the content make_home writes, so the cases below do not depend on
# git history (a published snapshot has none); the REAL list is checked in case 23.
LIST_REL="scripts/odeo-legacy-hashes.txt"
fixture_list() {
  local odeo s; odeo="$(sha_str 'odeo
')"
  for s in build merge research; do echo "skill $s $odeo"; done
  echo "agent builder $odeo"
  echo "skill deploy $(sha_str 'old deploy v1
')"
  echo "agent architect $(sha_str 'old architect v1
')"
}
FR="$(fake_root "$TMP/root")"; SCRIPT="$FR/scripts/odeo-migrate-legacy.sh"
# bounded <cmd...>: runs a command that must not hang (a shim that execs itself would). A
# watchdog kills it by PID after 10s (an exec chain keeps the PID), giving exit 143. Not
# perl's alarm: on macOS each exec restarts the alarm countdown, so a loop that re-execs
# faster than the timeout never fires (measured; the alarm itself survives exec). The
# watchdog's output goes to /dev/null so it never holds a caller's pipe open for 10s.
# The command's stdin is redirected explicitly: without job control, `cmd &` gets
# /dev/null, so a piped input vanished and read as a program that swallowed it.
bounded() {
  "$@" <&0 & local pid=$!
  ( sleep 10; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 & local dog=$!
  wait "$pid"; local rc=$?
  kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null
  return "$rc"
}

# make_home <dir>: an install.sh-style home plus the user's own things
make_home() {
  local h="$1"
  mkdir -p "$h/.claude/skills" "$h/.claude/agents" "$h/.claude/odeo-docs" "$h/bin" \
           "$h/.claude-templates/tasks" "$h/.claude/community-knowledge"
  for s in build merge research; do mkdir -p "$h/.claude/skills/$s"; echo odeo > "$h/.claude/skills/$s/SKILL.md"; done
  mkdir -p "$h/.claude/skills/my-own"; echo mine > "$h/.claude/skills/my-own/SKILL.md"
  echo odeo > "$h/.claude/agents/builder.md"; echo mine > "$h/.claude/agents/my-agent.md"
  echo odeo > "$h/.claude/odeo-docs/plan-format.md"
  echo odeo > "$h/.claude-templates/CLAUDE.md"
  printf '#!/bin/sh\n' > "$h/bin/merge-gate.sh"; printf '#!/bin/sh\n' > "$h/bin/my-tool.sh"
  printf '#!/bin/sh\nexit 0\n' > "$h/bin/secret-scan.sh"; chmod +x "$h/bin/secret-scan.sh"
  echo "# mine" > "$h/.claude/CLAUDE.md"; echo secret-terms > "$h/.claude/privacy-denylist.txt"
  echo lesson > "$h/.claude/community-knowledge/a.md"
}

# 1) the default is a dry run: it lists what would move and changes nothing
H="$TMP/h1"; make_home "$H"; before="$(find "$H" | sort)"
out="$(HOME="$H" "$SCRIPT" 2>&1)"; rc=$?
assert_exit "dry run -> 0" 0 "$rc"
assert_contains "dry run lists a skill" ".claude/skills/build" "$out"
assert_contains "dry run says how to apply" "--apply" "$out"
[ "$(find "$H" | sort)" = "$before" ] && ok "dry run changed nothing" || bad "dry run changed the home"

# 2) --apply moves exactly the install.sh items, keeps everything else, deletes nothing
H="$TMP/h2"; make_home "$H"; n_before="$(count_files "$H")"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; rc=$?
assert_exit "apply -> 0" 0 "$rc"
legacy="$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null | head -1)"
[ -n "$legacy" ] && ok "one legacy folder created" || bad "no legacy folder"
for p in .claude/skills/build .claude/skills/merge .claude/skills/research .claude/agents/builder.md \
         .claude/odeo-docs bin/merge-gate.sh .claude-templates; do
  gone "moved: $p" "$H/$p"; exists "kept in legacy: $p" "$legacy/$p"
done
for p in .claude/skills/my-own .claude/agents/my-agent.md bin/my-tool.sh .claude/CLAUDE.md \
         .claude/privacy-denylist.txt .claude/community-knowledge/a.md; do
  exists "untouched: $p" "$H/$p"
done
# every original survives (in place or in legacy); the only NEW file is the one shim
[ "$(count_files "$H")" = "$((n_before + 1))" ] && ok "no file deleted ($n_before + 1 shim)" \
  || bad "file count changed: $n_before -> $(count_files "$H") (expected +1 shim)"
exists "original secret-scan kept in legacy" "$legacy/bin/secret-scan.sh"
assert_contains "names the legacy folder" "$legacy" "$out"

# 3) a --link install (symlinks): the link moves, its target is untouched
H="$TMP/h3"; mkdir -p "$H/.claude/skills" "$TMP/clone/skills/build"; echo odeo > "$TMP/clone/skills/build/SKILL.md"
ln -s "$TMP/clone/skills/build" "$H/.claude/skills/build"
HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
legacy="$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null | head -1)"
[ -L "$legacy/.claude/skills/build" ] && ok "symlink moved as a link" || bad "symlink not moved as a link"
exists "link target untouched" "$TMP/clone/skills/build/SKILL.md"

# 4) nothing to migrate: says so, exit 0, creates no folder
H="$TMP/h4"; mkdir -p "$H/.claude"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; rc=$?
assert_exit "clean home -> 0" 0 "$rc"
assert_contains "clean home says nothing to do" "nothing to migrate" "$out"
[ -z "$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null)" ] && ok "no empty legacy folder" || bad "empty legacy folder created"

# 5) re-running after an apply finds nothing
H="$TMP/h2"; out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"
assert_contains "second apply is a no-op" "nothing to migrate" "$out"

# 7) the ~/bin/secret-scan.sh a pre-plugin project's pre-commit hook calls becomes a shim
#    that runs the newest plugin copy and passes its exit code through
shim="$H/bin/secret-scan.sh"
grep -q "odeo-migrate-legacy shim" "$shim" && ok "secret-scan.sh replaced by a shim" || bad "no shim at ~/bin/secret-scan.sh"
[ -x "$shim" ] && ok "shim is executable" || bad "shim is not executable"
[ -e "$H/bin/publish-guard.sh" ] && bad "shim written for a script the user never had" || ok "no shim for an absent script"
# an Odeo 0.2.x cache entry keeps its programs in bin/; the shim still finds them there
c="$H/.claude/plugins/cache/odeo/odeo/0.9.0/bin"; mkdir -p "$c"
printf '#!/usr/bin/env bash\necho PLUGIN-SCAN\nexit 1\n' > "$c/secret-scan.sh"; chmod +x "$c/secret-scan.sh"
out="$(HOME="$H" "$shim" 2>&1)"; rc=$?
assert_contains "shim runs the plugin's copy" "PLUGIN-SCAN" "$out"
assert_exit "shim passes a blocking exit through" 1 "$rc"
# 8) no plugin anywhere (no cache, the plugin root it was migrated from is gone): BLOCKS
H8="$TMP/h8"; make_home "$H8"; R8="$(fake_root "$TMP/root8")"
HOME="$H8" "$R8/scripts/odeo-migrate-legacy.sh" --apply >/dev/null 2>&1; rm -rf "$R8"
out="$(HOME="$H8" bounded "$H8/bin/secret-scan.sh" 2>&1)"; rc=$?
assert_exit "shim without a plugin blocks" 1 "$rc"
assert_contains "shim says how to fix it" "Odeo plugin" "$out"
# 8b) a fallback that points back at the shim itself never loops: it blocks, fast
perl -pi -e "s|^fallback=.*|fallback=$H8/bin|" "$H8/bin/secret-scan.sh"
HOME="$H8" bounded "$H8/bin/secret-scan.sh" >/dev/null 2>&1; rc=$?
assert_exit "self-referencing fallback blocks instead of looping" 1 "$rc"
# 9) a second apply recognises its own shim and leaves it
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"
grep -q "odeo-migrate-legacy shim" "$shim" && ok "second apply keeps the shim" || bad "second apply moved the shim"
assert_contains "second apply still has nothing to migrate" "nothing to migrate" "$out"

# 10) THE GUARANTEE, end to end: a project scaffolded before the plugin, with the
#     pre-plugin pre-commit hook (its lookup copied verbatim from that version), still has
#     its secret gate after --apply, and the gate is the plugin's current scanner.
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
H="$TMP/h10"; make_home "$H"
printf '#!/usr/bin/env bash\nexit 0\n' > "$H/bin/secret-scan.sh"            # the old copy passes
c="$H/.claude/plugins/cache/odeo/odeo/1.0.0/scripts"; mkdir -p "$c"
printf '#!/usr/bin/env bash\necho PLUGIN-BLOCKED >&2\nexit 1\n' > "$c/secret-scan.sh"; chmod +x "$c/secret-scan.sh"
old="$TMP/old-project"; git init -q "$old"; git -C "$old" commit -q --allow-empty -m init
cat > "$old/.git/hooks/pre-commit" <<'OLDHOOK'
#!/usr/bin/env bash
scan="$(command -v secret-scan.sh || true)"
[ -z "$scan" ] && [ -x "$HOME/bin/secret-scan.sh" ] && scan="$HOME/bin/secret-scan.sh"
[ -z "$scan" ] && [ -x "bin/secret-scan.sh" ] && scan="bin/secret-scan.sh"
if [ -n "$scan" ]; then
  "$scan" || exit 1
else
  echo "pre-commit WARNING: secret-scan.sh not found, committing WITHOUT the secret gate." >&2
fi
exit 0
OLDHOOK
chmod +x "$old/.git/hooks/pre-commit"
HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
( cd "$old" && echo x > f && git add f && HOME="$H" PATH="$(dirname "$(command -v git)"):/usr/bin:/bin" git commit -qm c >/dev/null 2>"$TMP/err10" ); rc=$?
[ "$rc" != 0 ] && ok "pre-plugin project: commit still gated after --apply" \
  || bad "pre-plugin project committed WITHOUT a secret gate after --apply"
assert_contains "the gate that ran is the plugin's scanner" "PLUGIN-BLOCKED" "$(cat "$TMP/err10")"

# 11) run from a copy outside a plugin root (install.sh used to put one in ~/bin): refuses,
#     because every "what Odeo ships" name comes from the root it runs in
H="$TMP/h11"; make_home "$H"; printf '#!/bin/sh\n' > "$H/bin/my-own-backup-tool"
cp "$SCRIPT" "$H/bin/odeo-migrate-legacy.sh"; before="$(find "$H" | sort)"
out="$(HOME="$H" "$H/bin/odeo-migrate-legacy.sh" --apply 2>&1)"; rc=$?
assert_exit "copy outside a plugin root -> 2" 2 "$rc"
assert_contains "says to run the plugin's copy" "plugin" "$out"
[ "$(find "$H" | sort)" = "$before" ] && ok "refusing copy moved nothing" || bad "refusing copy changed the home"
# 12) a stale ~/bin/odeo-migrate-legacy.sh (it CONTAINS the shim marker text) is not
#     mistaken for a shim: it moves aside like any other install.sh copy
out="$(HOME="$H" "$SCRIPT" 2>&1)"
assert_contains "stale migrate copy is a candidate" "bin/odeo-migrate-legacy.sh" "$out"

# 13) the shim hands its caller's stdin to the real script untouched. publish-guard.sh reads
#     the pushed paths on stdin; a shim that exec'd from inside a loop reading `ls` output
#     handed it the rest of that listing instead, so the guard checked 0 files and passed.
H="$TMP/h13"; make_home "$H"; HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
c="$H/.claude/plugins/cache/odeo/odeo/2.0.0/scripts"; mkdir -p "$c" "$H/.claude/plugins/cache/odeo/odeo/1.9.0/scripts"
printf '#!/usr/bin/env bash\nwc -c | tr -d " "\n' > "$c/secret-scan.sh"; chmod +x "$c/secret-scan.sh"
touch -t 202001010000 "$H/.claude/plugins/cache/odeo/odeo/1.9.0/scripts"   # a second, older cache entry
got="$(printf 'docs/plans/x.md\0README.md\0' | HOME="$H" "$H/bin/secret-scan.sh" 2>/dev/null)"
assert_exit "shim passes stdin through byte for byte" "$(printf "docs/plans/x.md\0README.md\0" | wc -c | tr -d " ")" "$got"

# 14) THE GUARANTEE, end to end: an internal path piped through the ~/bin/publish-guard.sh
#     shim reaches the plugin's real guard and is refused
H="$TMP/h14"; make_home "$H"; printf '#!/bin/sh\n' > "$H/bin/publish-guard.sh"
HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
real="$H/.claude/plugins/cache/odeo/odeo/3.0.0"; mkdir -p "$real/scripts" "$real/docs"
cp "$ROOT/scripts/publish-guard.sh" "$ROOT/scripts/privacy-scan.sh" "$real/scripts/"
printf 'docs/plans/\n' > "$real/docs/internal-paths.txt"; printf 'README.md\n' > "$real/docs/public-paths.txt"
plain="$TMP/plain14"; mkdir -p "$plain"
rc="$(cd "$plain" && printf 'docs/plans/secret.md\0' | env -u CLAUDE_INTERNAL_PATHS -u CLAUDE_PUBLIC_PATHS \
  GIT_CEILING_DIRECTORIES="$TMP" HOME="$H" "$H/bin/publish-guard.sh" - >/dev/null 2>&1; echo $?)"
assert_exit "an internal path piped through the shim is refused" 1 "$rc"

# 15) an outdated shim (written by an earlier version) is refreshed by --apply; a current one
#     is left alone, and neither counts as an install.sh item to move
H="$TMP/h15"; make_home "$H"; HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
current="$(cat "$H/bin/secret-scan.sh")"
printf '#!/usr/bin/env bash\n# odeo-migrate-legacy shim: an older version\nexec true\n' > "$H/bin/secret-scan.sh"
out="$(HOME="$H" "$SCRIPT" 2>&1)"
assert_contains "dry run names the outdated shim" "refresh" "$out"
[ "$(sed -n 3p "$H/bin/secret-scan.sh")" = "exec true" ] && ok "dry run leaves the outdated shim" || bad "dry run changed the shim"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"
[ "$(cat "$H/bin/secret-scan.sh")" = "$current" ] && ok "--apply refreshes an outdated shim" || bad "outdated shim not refreshed"
# the refreshed-over version is KEPT (a user may have edited it): nothing is ever deleted
kept="$(grep -rl '^exec true$' "$H"/.claude/odeo-legacy-*/bin/secret-scan.sh 2>/dev/null | head -1)"
[ -n "$kept" ] && ok "the replaced shim is kept in a legacy folder" || bad "the replaced shim was overwritten without a copy"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"
assert_contains "a current shim is not refreshed again" "nothing to migrate" "$out"

# 16) THE COMPATIBILITY PROMISE for shims: a ~/bin shim written by 0.2.2 (it only knows
#     */odeo/*/bin), verbatim except the two baked paths, keeps its guard while the cache holds
#     a 0.3.0 to 0.3.5 version (programs in scripts/, forwarding wrappers in bin/): the
#     caller's stdin and the exit code pass through. With bin/ gone (releases after 0.3.5) it
#     BLOCKS, which is the outcome the session-start nudge warns about. HOME is the fake home
#     and CLAUDE_CONFIG_DIR is unset, so no real cache can answer instead.
H16="$TMP/h16"; mkdir -p "$H16/bin"; v16="$H16/.claude/plugins/cache/odeo/odeo/0.3.0"
mkdir -p "$v16/scripts" "$v16/bin"
printf '#!/usr/bin/env bash\nwc -c | tr -d " "\nexit 5\n' > "$v16/scripts/publish-guard.sh"; chmod +x "$v16/scripts/publish-guard.sh"
cp "$ROOT/tests/fixtures/legacy-bin-wrapper.sh" "$v16/bin/publish-guard.sh"
{ printf '#!/usr/bin/env bash\n'
  printf '# odeo-migrate-legacy shim: a pre-plugin project'"'"'s git hook calls ~/bin/publish-guard.sh; this runs the\n'
  printf '# newest Odeo plugin copy instead. Delete this file if you no longer use those projects.\n'
  printf 'fallback=%q\nconfig_at_migration=%q\n' "$TMP/swept/bin" "$H16/.claude"
  cat <<'OLDSHIM'
name="$(basename "$0")"
# run_if <path>: execs a candidate with the CALLER's stdin (publish-guard.sh reads the pushed
# paths there) and never this shim itself (that would loop forever). fd 3 carries the cache
# listing and is closed first: exec'ing inside a loop that reads the listing on stdin once
# handed the guard the rest of the listing, so it checked 0 files and passed.
run_if() { [ -x "$1" ] && ! [ "$1" -ef "$0" ] && exec "$1" "${@:2}" 3<&-; return 0; }
while IFS= read -r d <&3; do
  run_if "$d/$name" "$@"
done 3< <(ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/bin \
                "$config_at_migration"/plugins/cache/*/odeo/*/bin \
                "$HOME"/.claude/plugins/cache/*/odeo/*/bin 2>/dev/null)
run_if "$fallback/$name" "$@"
echo "$name: the Odeo plugin was not found, so this guard cannot run and BLOCKS." >&2
echo "Reinstall the Odeo plugin, or delete ~/bin/$name if you no longer need it." >&2
exit 1
OLDSHIM
} > "$H16/bin/publish-guard.sh"; chmod +x "$H16/bin/publish-guard.sh"
# through bounded(), which must hand the caller's stdin on: a background job gets /dev/null
got="$(unset CLAUDE_CONFIG_DIR; printf 'a\0b\0c' | HOME="$H16" bounded "$H16/bin/publish-guard.sh" - 2>/dev/null)"; rc=$?
assert_exit "0.2.2 shim reaches scripts/ through the bin/ wrapper with stdin intact" 5 "$got"
assert_exit "0.2.2 shim passes the guard's exit code through" 5 "$rc"
rm -rf "$v16/bin"
# matched by its message too: observed failing (2026-09-30) with bin/ kept and the guard
# exiting 1, which the exit code alone could not tell from the block
out="$( unset CLAUDE_CONFIG_DIR; printf 'a\0b\0c' | HOME="$H16" bounded "$H16/bin/publish-guard.sh" - 2>&1 >/dev/null )"; rc=$?
assert_exit "0.2.2 shim with bin/ gone blocks" 1 "$rc"
assert_contains "0.2.2 shim with bin/ gone says it cannot run" "cannot run and BLOCKS" "$out"

# 17) THE GUARANTEE for the user's own work: a skill or agent that merely SHARES an Odeo name
#     (here a retired skill name, `deploy`, and an agent name, `architect`) but whose content is
#     not a copy Odeo ever shipped is left alone, and the dry run says so and why
H="$TMP/h17"; make_home "$H"
mkdir -p "$H/.claude/skills/deploy"; echo "my own deploy runbook" > "$H/.claude/skills/deploy/SKILL.md"
echo "my own architect persona" > "$H/.claude/agents/architect.md"
before="$(find "$H" | sort)"
out="$(HOME="$H" "$SCRIPT" 2>&1)"; rc=$?
assert_exit "dry run with a same-named own skill -> 0" 0 "$rc"
assert_contains "dry run says the own skill is not recognised as Odeo's" "not recognised as Odeo's" "$out"
assert_contains "dry run names the own skill" ".claude/skills/deploy" "$out"
assert_contains "dry run names the own agent" ".claude/agents/architect.md" "$out"
would_move="${out%%not recognised*}"
case "$would_move" in *skills/deploy*|*agents/architect.md*) bad "dry run lists an own item under 'would move'";; *) ok "own items are not in the would-move list";; esac
assert_contains "dry run still lists the genuine skill" ".claude/skills/build" "$would_move"
[ "$(find "$H" | sort)" = "$before" ] && ok "dry run changed nothing (own skill)" || bad "dry run changed the home (own skill)"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; rc=$?
assert_exit "apply with a same-named own skill -> 0" 0 "$rc"
legacy="$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null | head -1)"
exists "own skill stays after --apply" "$H/.claude/skills/deploy/SKILL.md"
[ "$(cat "$H/.claude/skills/deploy/SKILL.md")" = "my own deploy runbook" ] && ok "own skill content intact" || bad "own skill content changed"
exists "own agent stays after --apply" "$H/.claude/agents/architect.md"
gone "own skill is not in the legacy folder" "$legacy/.claude/skills/deploy"
exists "the genuine skill still moved" "$legacy/.claude/skills/build/SKILL.md"
assert_contains "apply reports the left-in-place items" "not recognised as Odeo's" "$out"
# a home with ONLY a same-named own skill has nothing to migrate and no legacy folder
H="$TMP/h17b"; mkdir -p "$H/.claude/skills/deploy"; echo "mine" > "$H/.claude/skills/deploy/SKILL.md"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; rc=$?
assert_exit "only an own same-named skill -> 0" 0 "$rc"
assert_contains "only an own skill: says nothing to migrate" "nothing to migrate" "$out"
assert_contains "only an own skill: still says why it was left" "not recognised as Odeo's" "$out"
[ -z "$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null)" ] && ok "no legacy folder for an own-only home" || bad "legacy folder created for an own-only home"
exists "own-only skill untouched" "$H/.claude/skills/deploy/SKILL.md"

# 18) a genuine OLD copy (content = a blob the list carries) of a retired skill and of an agent
#     still moves
H="$TMP/h18"; mkdir -p "$H/.claude/skills/deploy" "$H/.claude/agents"
printf 'old deploy v1\n' > "$H/.claude/skills/deploy/SKILL.md"; printf 'old architect v1\n' > "$H/.claude/agents/architect.md"
echo "keep me" > "$H/.claude/skills/deploy/notes.md"   # a companion file travels with its skill
out="$(HOME="$H" "$SCRIPT" 2>&1)"
assert_contains "dry run lists the genuine old deploy" ".claude/skills/deploy" "$out"
case "$out" in *"not recognised"*) bad "a genuine old copy was called unrecognised";; *) ok "genuine old copies are not reported as unrecognised";; esac
HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1; legacy="$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null | head -1)"
gone "genuine old skill moved" "$H/.claude/skills/deploy"; exists "genuine old skill kept in legacy" "$legacy/.claude/skills/deploy/SKILL.md"
exists "its companion file moved with it" "$legacy/.claude/skills/deploy/notes.md"
gone "genuine old agent moved" "$H/.claude/agents/architect.md"; exists "genuine old agent kept in legacy" "$legacy/.claude/agents/architect.md"

# 19) THE TRADEOFF, stated in the script header: an Odeo skill the user hand-edited no longer
#     matches any shipped copy, so it stays (and is reported) rather than being moved
H="$TMP/h19"; make_home "$H"; printf 'odeo\nmy own tweak\n' > "$H/.claude/skills/research/SKILL.md"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; legacy="$(ls -d "$H"/.claude/odeo-legacy-* 2>/dev/null | head -1)"
exists "hand-edited Odeo skill stays" "$H/.claude/skills/research/SKILL.md"
gone "hand-edited Odeo skill is not in legacy" "$legacy/.claude/skills/research"
assert_contains "hand-edited skill is reported" ".claude/skills/research" "${out#*not recognised}"
gone "its unedited neighbours still moved" "$H/.claude/skills/build"

# 20) the pairs are bound to a NAME and a KIND, not a bare set of hashes: genuine content under
#     another name, or as the other kind, is not recognised
R20="$(fake_root "$TMP/root20")"
printf 'skill research %s\nagent merge %s\n' "$(sha_str 'odeo
')" "$(sha_str 'odeo
')" > "$R20/$LIST_REL"
H="$TMP/h20"; mkdir -p "$H/.claude/skills/deploy" "$H/.claude/skills/merge" "$H/.claude/skills/research" "$H/.claude/agents"
for s in deploy merge research; do echo odeo > "$H/.claude/skills/$s/SKILL.md"; done
echo odeo > "$H/.claude/agents/builder.md"
out="$(HOME="$H" "$R20/scripts/odeo-migrate-legacy.sh" 2>&1)"
would_move="${out%%not recognised*}"
assert_contains "same content, the listed name: moves" ".claude/skills/research" "$would_move"
for p in skills/deploy skills/merge agents/builder.md; do
  case "$would_move" in *"$p"*) bad "$p matched by content alone (name or kind not bound)";; *) ok "$p not recognised: wrong name or kind";; esac
  assert_contains "$p is reported as left in place" ".claude/$p" "${out#*not recognised}"
done

# 21) symlinks named after an Odeo skill: the link is judged by what it RESOLVES to. A link to
#     genuine content moves (case 3); one to foreign content, and a dangling one, stay.
H="$TMP/h21"; mkdir -p "$H/.claude/skills" "$TMP/c21/mine" "$TMP/c21/gone"
echo "foreign" > "$TMP/c21/mine/SKILL.md"
ln -s "$TMP/c21/mine" "$H/.claude/skills/build"; ln -s "$TMP/c21/does-not-exist" "$H/.claude/skills/merge"
out="$(HOME="$H" "$SCRIPT" --apply 2>&1)"; rc=$?
assert_exit "links to foreign or missing content -> 0" 0 "$rc"
[ -L "$H/.claude/skills/build" ] && ok "link to foreign content stays" || bad "link to foreign content moved"
[ -L "$H/.claude/skills/merge" ] && ok "dangling link stays" || bad "dangling link moved"
assert_contains "links left in place are reported" "not recognised as Odeo's" "$out"

# 22) the list itself is untrusted data: a malformed line is skipped loudly and never widens
#     what moves; a missing list refuses to guess (exit 2, nothing moves)
R22="$(fake_root "$TMP/root22")"
{ echo "# a comment and a blank line are fine"; echo
  echo "skill ../../escape $(sha_str 'odeo
')"
  echo "skill build not-a-hash"
  echo "skill build $(sha_str 'odeo
')0"   # a valid line with one stray character: only the anchors reject it
  echo "skill * $(sha_str 'odeo
')"
  echo "tool build $(sha_str 'odeo
')"
  echo "skill research $(sha_str 'odeo
')"
} > "$R22/$LIST_REL"
H="$TMP/h22"; make_home "$H"
out="$(HOME="$H" "$R22/scripts/odeo-migrate-legacy.sh" 2>&1)"; rc=$?
assert_exit "a list with malformed lines still runs" 0 "$rc"
assert_contains "malformed lines are reported" "malformed" "$out"
n_bad="$(printf '%s\n' "$out" | grep -c 'malformed line')"
[ "$n_bad" = 5 ] && ok "exactly the five malformed lines are reported" || bad "expected 5 malformed-line reports, got $n_bad"
would_move="${out%%not recognised*}"
assert_contains "the one valid line still recognises its skill" ".claude/skills/research" "$would_move"
case "$would_move" in *skills/build*|*skills/merge*) bad "a malformed line recognised a skill";; *) ok "malformed lines recognise nothing";; esac
H="$TMP/h22b"; make_home "$H"; before="$(find "$H" | sort)"; rm -f "$R22/$LIST_REL"
out="$(HOME="$H" "$R22/scripts/odeo-migrate-legacy.sh" --apply 2>&1)"; rc=$?
assert_exit "a missing list refuses" 2 "$rc"
assert_contains "a missing list says what is missing" "odeo-legacy-hashes.txt" "$out"
[ "$(find "$H" | sort)" = "$before" ] && ok "a missing list moved nothing" || bad "a missing list changed the home"

# 23) the REAL list, with the real script: every skill and agent this tree ships is recognised
#     (so a plain install.sh copy of the current version moves), a same-named own skill is not
H="$TMP/h23"; mkdir -p "$H/.claude/skills" "$H/.claude/agents"
for d in "$ROOT"/skills/*/; do n="$(basename "$d")"; mkdir -p "$H/.claude/skills/$n"; cp "$d/SKILL.md" "$H/.claude/skills/$n/SKILL.md"; done
for f in "$ROOT"/agents/*.md; do cp "$f" "$H/.claude/agents/"; done
cp "$ROOT/docs/agent-rubric.md" "$H/.claude/agents/agent-rubric.md"
mkdir -p "$H/.claude/skills/deploy"; echo "my own deploy runbook" > "$H/.claude/skills/deploy/SKILL.md"
out="$(HOME="$H" "$REAL_SCRIPT" 2>&1)"; rc=$?
assert_exit "real list: dry run -> 0" 0 "$rc"
n_ship="$(( $(ls -d "$ROOT"/skills/*/ | wc -l) + $(ls "$ROOT"/agents/*.md | wc -l) + 1 ))"
n_listed="$(printf '%s\n' "${out%%not recognised*}" | grep -c '^  ~/\.claude/')"
[ "$n_listed" = "$n_ship" ] && ok "real list recognises all $n_ship shipped skills and agents" \
  || bad "real list recognises $n_listed of $n_ship shipped skills and agents"
case "${out#*not recognised}" in *skills/deploy*) ok "real list: own deploy skill left in place";; *) bad "real list: own deploy skill not reported";; esac
# a genuine retired skill from history (only where the history is present: a published
# snapshot has none, and the case is then not applicable, not passed)
if git -C "$ROOT" rev-parse -q --verify dev-phase-archive >/dev/null 2>&1 \
   && git -C "$ROOT" cat-file -e dev-phase-archive:skills/deploy/SKILL.md 2>/dev/null; then
  H="$TMP/h23b"; mkdir -p "$H/.claude/skills/deploy"
  git -C "$ROOT" show dev-phase-archive:skills/deploy/SKILL.md > "$H/.claude/skills/deploy/SKILL.md"
  out="$(HOME="$H" "$REAL_SCRIPT" 2>&1)"
  case "${out%%not recognised*}" in *skills/deploy*) ok "real list recognises the archived deploy skill";; *) bad "real list does not recognise the archived deploy skill";; esac
else
  echo "skip: no dev-phase-archive tag in this clone (archived deploy skill not checked)"
fi

# 24) the hash list is data for the migration, never an install.sh program: a file of that name
#     in ~/bin is not treated as one (the bin/ scan walks the plugin's scripts/ folder, where
#     the list lives)
H="$TMP/h24"; mkdir -p "$H/bin"; echo "mine" > "$H/bin/odeo-legacy-hashes.txt"
out="$(HOME="$H" "$SCRIPT" 2>&1)"
assert_contains "a ~/bin file named like the list is not a candidate" "nothing to migrate" "$out"
exists "that file stays" "$H/bin/odeo-legacy-hashes.txt"

# 6) unknown flag -> usage, exit 2, nothing moved
H="$TMP/h6"; make_home "$H"; before="$(find "$H" | sort)"
HOME="$H" "$SCRIPT" --force >/dev/null 2>&1; rc=$?
assert_exit "unknown flag -> 2" 2 "$rc"
[ "$(find "$H" | sort)" = "$before" ] && ok "unknown flag moved nothing" || bad "unknown flag changed the home"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
