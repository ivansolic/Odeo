#!/usr/bin/env bash
# Tests for what a SCAFFOLDED project does with its build ledger.
#
# WHY THIS EXISTS. Two claims were shipped about `.claude/tasks/todo.md` and `lessons.md`,
# repeated across the skill, the templates, the system map and a program's own header: that
# they are gitignored so the ledger never reaches a published snapshot, and that git therefore
# does not carry them. Both were true in THIS repo and false in every project the scaffolder
# creates: `init-project.sh` wrote a .gitignore with no entry for them and then ran
# `git add -A && git commit`, so a new project committed its ledger on day one.
#
# A claim that holds where it was written and fails where the code ships is worse than no
# claim, because it is only ever checked by the person who cannot see the failure. So this
# suite asserts both properties against a REAL scaffold, from the REAL templates:
#
#   1. the two ledger files are ignored, and are not tracked;
#   2. a fresh project is NOT configured for a backup, so the end-of-session check stays
#      silent instead of warning about a backup nobody asked for.
#
# (2) exists because the template's documentation example matched the same grep that reads
# the setting, so every new project shipped a live `ledger_backup: git <remote-name> <branch>`
# and nagged every session about a placeholder.
#
# Run: bash tests/init-project.ledger.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/init-project.sh"
LEDGER="$ROOT/bin/ledger-backup.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

TMP="$(mktemp -d)" || { echo "FAIL - no temp dir"; exit 1; }
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

# The templates are the REAL ones, not a fixture: the defect this suite exists for lived in
# project-templates/CLAUDE.md, so a stub would have reproduced nothing.
TMPL="$TMP/templates"
mkdir -p "$TMPL/tasks" "$TMPL/docs" "$TMPL/design" "$TMPL/knowledge"
cp "$ROOT/project-templates/CLAUDE.md" "$TMPL/CLAUDE.md"
printf '# todo\n'    > "$TMPL/tasks/todo.md"
printf '# lessons\n' > "$TMPL/tasks/lessons.md"
touch "$TMPL/docs/ADR-TEMPLATE.md" "$TMPL/design/tokens.json" "$TMPL/design/README.md" \
      "$TMPL/knowledge/README.md"

run="$TMP/run"; mkdir -p "$run"
( cd "$run" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" scaffolded --no-ui \
    </dev/null >/dev/null 2>&1 ); rc=$?
P="$run/scaffolded"
[ "$rc" = 0 ] && [ -d "$P" ] || { echo "FAIL - instrument broken: the scaffold did not run (exit $rc)"; exit 1; }
ok "instrument: a project scaffolds from the real templates"

# 1. IGNORED. Asked of git, not of the .gitignore text: a nested ignore file, a negation, or a
#    reordering can all make the text look right while the file is still tracked.
for f in todo.md lessons.md; do
  if git -C "$P" check-ignore -q ".claude/tasks/$f" 2>/dev/null; then
    ok "a scaffolded project ignores .claude/tasks/$f"
  else
    bad ".claude/tasks/$f is NOT ignored in a scaffolded project"
  fi
done

# 2. NOT TRACKED. The scaffolder commits with `git add -A`, so "ignored" and "not in the
#    commit" are two different questions and only the second one is the harm: a tracked ledger
#    ships with the repo and reaches whoever clones it.
tracked="$(git -C "$P" ls-files .claude/tasks 2>/dev/null)"
if [ -z "$tracked" ]; then
  ok "and neither file is tracked after the scaffold commit"
else
  bad "the scaffold committed the ledger: $(printf '%s' "$tracked" | tr '\n' ' ')"
fi

# 3. The files still EXIST as working files. Ignoring them must not mean losing them, or the
#    scaffold would hand the user an empty ledger and the seeding step would be pointless.
[ -s "$P/.claude/tasks/todo.md" ] && [ -s "$P/.claude/tasks/lessons.md" ] \
  && ok "and both are present on disk as working files" \
  || bad "the ledger files are missing from the scaffold"

# 4. NOT CONFIGURED for a backup. Exit 3, not 4: 3 means "nothing was promised" and the
#    end-of-session check stays quiet, 4 means a target was named and could not be reached,
#    which is a warning on every single session of every new project.
out="$(bash "$LEDGER" --check "$P" 2>&1)"; rc=$?
[ "$rc" = 3 ] && ok "a fresh project reports 'not configured' (exit 3), not a broken target" \
  || bad "a fresh scaffold reports exit $rc: $out"

# 5. And the same, through the hook that actually runs: silence. This is the property the
#    whole design rests on, since a hook that warns in the default state gets muted, and then
#    so does the warning that mattered.
cp "$ROOT/bin/session-end-check.sh" "$ROOT/bin/ledger-backup.sh" "$P/" 2>/dev/null
out="$( cd "$P" && bash ./session-end-check.sh 2>&1 )"; rc=$?
[ "$rc" = 0 ] && ok "the end-of-session hook exits 0 in a fresh project" || bad "hook exit $rc"
#    Only the LEDGER lines are examined. Matching the hook's whole output made this depend on
#    the machine: the same sweep reports tunnels, dev servers and worktrees, so a dev server
#    called "backup-api" would have failed a case about something else entirely.
ledger_lines="$(printf '%s\n' "$out" | grep -iE 'ledger|backed up' || true)"
if [ -z "$ledger_lines" ]; then
  ok "and says nothing about a backup nobody set up"
else
  bad "the hook warns about a backup in a brand new project: $ledger_lines"
fi
rm -f "$P/session-end-check.sh" "$P/ledger-backup.sh"

# 6. The template's example lines must not READ as configuration. This is the mechanism for
#    finding 4 rather than a second opinion about it: the program's own reader is pointed at
#    the shipped template, so an example that starts matching again fails here.
probe="$TMP/probe"; mkdir -p "$probe/.claude/tasks"
( cd "$probe" && git init -q . ) >/dev/null 2>&1
cp "$ROOT/project-templates/CLAUDE.md" "$probe/CLAUDE.md"
printf 'x\n' > "$probe/.claude/tasks/todo.md"
out="$(bash "$LEDGER" --check "$probe" 2>&1)"; rc=$?
[ "$rc" = 3 ] && ok "the shipped template itself configures nothing (exit 3)" \
  || bad "project-templates/CLAUDE.md reads as live configuration (exit $rc): $out"

# 7. And the template carries no LIVE line at all, checked with the program's own reader
#    pattern. Case 6 alone would stay green on an uncommented example, because the placeholder
#    guard inside the program catches `<...>` too; that guard is a BACKSTOP. This asserts the
#    first layer independently, so removing the `#` fails here even while the backstop holds.
live="$(grep -E '^[[:space:]]*ledger_backup:[[:space:]]*' "$ROOT/project-templates/CLAUDE.md" || true)"
if [ -z "$live" ]; then
  ok "and the template's examples are commented out, so nothing depends on the backstop"
else
  bad "the template has a LIVE ledger_backup line: $live"
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "init-project.ledger: all $pass assertions passed."; else echo "init-project.ledger: $fail FAILURE(S) above."; fi
exit "$fail"
