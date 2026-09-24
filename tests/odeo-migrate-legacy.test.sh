#!/usr/bin/env bash
# Tests for bin/odeo-migrate-legacy.sh: moves the copies an install.sh install left in the
# home directory out of the way of the plugin, so nothing loads twice.
#
# The guarantees are OUTCOMES, checked on a fake HOME: a dry run (the default) changes
# nothing; --apply moves exactly the install.sh-placed items (Odeo's skill, agent and bin
# names, odeo-docs, ~/.claude-templates) into one ~/.claude/odeo-legacy-<ts>/ folder;
# everything else survives in place; and no file is ever deleted (the file count over
# home is identical before and after).
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
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/odeo-migrate-legacy.sh"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }
exists() { if [ -e "$2" ] || [ -L "$2" ]; then ok "$1"; else bad "$1 ($2 missing)"; fi; }
gone() { if [ -e "$2" ] || [ -L "$2" ]; then bad "$1 ($2 still there)"; else ok "$1"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
count_files() { find "$1" \( -type f -o -type l \) | wc -l | tr -d ' '; }
# fake_root <dir>: a removable copy of the plugin root (manifest, bin, skills, agents), so
# a shim's baked fallback can be taken away the way an uninstall or cache sweep would
fake_root() {
  mkdir -p "$1/docs"; cp -R "$ROOT/.claude-plugin" "$ROOT/bin" "$ROOT/skills" "$ROOT/agents" "$1/"
  cp "$ROOT/docs/agent-rubric.md" "$1/docs/"; printf '%s' "$1"
}
# bounded <cmd...>: runs a command that must not hang (a shim that execs itself would). A
# watchdog kills it by PID after 10s (an exec chain keeps the PID), giving exit 143. Not
# perl's alarm: bash drops an inherited alarm on exec, so that version never fired.
bounded() {
  "$@" & local pid=$!
  ( sleep 10; kill "$pid" 2>/dev/null ) & local dog=$!
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
c="$H/.claude/plugins/cache/odeo/odeo/0.9.0/bin"; mkdir -p "$c"
printf '#!/usr/bin/env bash\necho PLUGIN-SCAN\nexit 1\n' > "$c/secret-scan.sh"; chmod +x "$c/secret-scan.sh"
out="$(HOME="$H" "$shim" 2>&1)"; rc=$?
assert_contains "shim runs the plugin's copy" "PLUGIN-SCAN" "$out"
assert_exit "shim passes a blocking exit through" 1 "$rc"
# 8) no plugin anywhere (no cache, the plugin root it was migrated from is gone): BLOCKS
H8="$TMP/h8"; make_home "$H8"; R8="$(fake_root "$TMP/root8")"
HOME="$H8" "$R8/bin/odeo-migrate-legacy.sh" --apply >/dev/null 2>&1; rm -rf "$R8"
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
c="$H/.claude/plugins/cache/odeo/odeo/1.0.0/bin"; mkdir -p "$c"
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
c="$H/.claude/plugins/cache/odeo/odeo/2.0.0/bin"; mkdir -p "$c" "$H/.claude/plugins/cache/odeo/odeo/1.9.0/bin"
printf '#!/usr/bin/env bash\nwc -c | tr -d " "\n' > "$c/secret-scan.sh"; chmod +x "$c/secret-scan.sh"
touch -t 202001010000 "$H/.claude/plugins/cache/odeo/odeo/1.9.0/bin"   # a second, older cache entry
got="$(printf 'docs/plans/x.md\0README.md\0' | HOME="$H" "$H/bin/secret-scan.sh" 2>/dev/null)"
assert_exit "shim passes stdin through byte for byte" "$(printf "docs/plans/x.md\0README.md\0" | wc -c | tr -d " ")" "$got"

# 14) THE GUARANTEE, end to end: an internal path piped through the ~/bin/publish-guard.sh
#     shim reaches the plugin's real guard and is refused
H="$TMP/h14"; make_home "$H"; printf '#!/bin/sh\n' > "$H/bin/publish-guard.sh"
HOME="$H" "$SCRIPT" --apply >/dev/null 2>&1
real="$H/.claude/plugins/cache/odeo/odeo/3.0.0"; mkdir -p "$real/bin" "$real/docs"
cp "$ROOT/bin/publish-guard.sh" "$ROOT/bin/privacy-scan.sh" "$real/bin/"
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

# 6) unknown flag -> usage, exit 2, nothing moved
H="$TMP/h6"; make_home "$H"; before="$(find "$H" | sort)"
HOME="$H" "$SCRIPT" --force >/dev/null 2>&1; rc=$?
assert_exit "unknown flag -> 2" 2 "$rc"
[ "$(find "$H" | sort)" = "$before" ] && ok "unknown flag moved nothing" || bad "unknown flag changed the home"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
