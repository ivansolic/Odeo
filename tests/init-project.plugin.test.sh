#!/usr/bin/env bash
# Tests that bin/init-project.sh works from a plugin install: no ~/.claude-templates, no
# ~/bin, nothing on PATH. It must find project-templates/ and install-git-guards.sh next to
# itself, which is the layout Claude Code copies into the plugin cache.
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 templates default back to $HOME/.claude-templates   -> 4 FAIL (cases 1, 2, 4)
#   M2 guard installer looked up in $HOME/bin, not beside   -> 2 FAIL (case 2)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

# A fake plugin root: the real script and templates, and a stub guard installer that
# records where it ran (the real one is covered by install-git-guards.test.sh).
plugin="$TMP/cache/odeo/0.2.0"; mkdir -p "$plugin/bin"
cp "$ROOT/bin/init-project.sh" "$plugin/bin/"
cp -R "$ROOT/project-templates" "$plugin/project-templates"
printf '#!/usr/bin/env bash\npwd -P > "%s/guards-ran-in"\n' "$TMP" > "$plugin/bin/install-git-guards.sh"
chmod +x "$plugin/bin/"*.sh
GIT_DIR_BIN="$(dirname "$(command -v git)")"
CLEAN_PATH="$GIT_DIR_BIN:/usr/bin:/bin"          # no ~/bin, no plugin bin on PATH
home="$TMP/home"; mkdir -p "$home"               # no ~/.claude-templates

# 1) no CLAUDE_TEMPLATES_DIR: templates come from the plugin's own project-templates/
run="$TMP/run1"; mkdir -p "$run"
out="$(cd "$run" && env -u CLAUDE_TEMPLATES_DIR HOME="$home" PATH="$CLEAN_PATH" \
  bash "$plugin/bin/init-project.sh" app --no-ui </dev/null 2>&1)"; rc=$?
assert_exit "scaffolds from the plugin root" 0 "$rc"
if [ -f "$run/app/CLAUDE.md" ]; then ok "project CLAUDE.md written"; else bad "project CLAUDE.md missing"; fi
# 2) the sibling guard installer ran inside the new project
if [ -f "$TMP/guards-ran-in" ] && [ -d "$run/app" ] \
   && [ "$(cat "$TMP/guards-ran-in")" = "$(cd "$run/app" && pwd -P)" ]; then ok "sibling install-git-guards.sh ran in the project"
else bad "sibling install-git-guards.sh did not run in the project"; fi
assert_contains "no 'hooks skipped' warning" "installing git guards" "$out"
case "$out" in *"hooks skipped"*) bad "guards reported as skipped";; *) ok "guards not skipped";; esac

# 3) CLAUDE_TEMPLATES_DIR still overrides (the other init-project tests rely on it)
alt="$TMP/alt-templates"; cp -R "$ROOT/project-templates" "$alt"; echo "# ALT MARKER" >> "$alt/CLAUDE.md"
run="$TMP/run3"; mkdir -p "$run"
( cd "$run" && CLAUDE_TEMPLATES_DIR="$alt" HOME="$home" PATH="$CLEAN_PATH" \
  bash "$plugin/bin/init-project.sh" app --no-ui </dev/null >/dev/null 2>&1 ); rc=$?
assert_exit "override run succeeds" 0 "$rc"
assert_contains "override templates used" "ALT MARKER" "$(cat "$run/app/CLAUDE.md" 2>/dev/null)"

# 4) templates missing next to the script: fails and says to reinstall the plugin
rm -rf "$plugin/project-templates"
run="$TMP/run4"; mkdir -p "$run"
out="$(cd "$run" && env -u CLAUDE_TEMPLATES_DIR HOME="$home" PATH="$CLEAN_PATH" \
  bash "$plugin/bin/init-project.sh" app --no-ui </dev/null 2>&1)"; rc=$?
assert_exit "missing templates -> 1" 1 "$rc"
assert_contains "names the plugin as the fix" "Odeo plugin" "$out"

# 5) the project name is an allowlisted slug: /new-project passes user text straight in
cp -R "$ROOT/project-templates" "$plugin/project-templates"
run="$TMP/run5"; mkdir -p "$run/inner"
for name in "../escape" "/tmp/abs-$$" "a/b" "." ".." "has space" '$(touch pwned)' ".hidden"; do
  out="$(cd "$run/inner" && env -u CLAUDE_TEMPLATES_DIR HOME="$home" PATH="$CLEAN_PATH" \
    bash "$plugin/bin/init-project.sh" "$name" --no-ui </dev/null 2>&1)"; rc=$?
  assert_exit "rejects name '$name'" 1 "$rc"
  assert_contains "says why for '$name'" "project name" "$out"
done
[ -z "$(ls -A "$run")" ] || [ "$(ls -A "$run")" = "inner" ] && [ -z "$(ls -A "$run/inner")" ] \
  && ok "no directory created for any rejected name" || bad "a rejected name created something"
[ ! -e "/tmp/abs-$$" ] && ok "absolute path not created" || { bad "absolute path created"; rm -rf "/tmp/abs-$$"; }
for name in "my-app" "App_2" "api.v2"; do
  ( cd "$run/inner" && env -u CLAUDE_TEMPLATES_DIR HOME="$home" PATH="$CLEAN_PATH" \
    bash "$plugin/bin/init-project.sh" "$name" --no-ui </dev/null >/dev/null 2>&1 ); rc=$?
  assert_exit "accepts name '$name'" 0 "$rc"
done

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
