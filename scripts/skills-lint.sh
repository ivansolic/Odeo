#!/usr/bin/env bash
#
# skills-lint.sh, the system's own consistency gate (enforced guardrail).
#
# Checks the mechanical invariants in docs/invariants.md over skills/, agents/,
# AGENTS.md, global/CLAUDE.md, and docs/system-map.md. Every check exists
# because its bug class actually happened; see the invariants file for the map.
#
# Usage:   skills-lint.sh [root]      (default: the repo this script lives in)
# Exit:    0 clean · 1 violations (each printed as "LINT [id] file: reason")
# Used by: tests/skills-lint.test.sh, the repo CI, and /improve after skill edits.

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
fail=0
viol() { echo "LINT [$1] $2"; fail=1; }

SKILLS=()
while IFS= read -r f; do SKILLS+=("$f"); done < <(ls "$ROOT"/skills/*/SKILL.md 2>/dev/null)
AGENTS=()
while IFS= read -r f; do AGENTS+=("$f"); done < <(ls "$ROOT"/agents/*.md 2>/dev/null)
# The published text a user or Claude reads as instructions or messages: the public docs,
# skills, agents, project templates (markdown and JSON), the plugin manifests (their text
# is the enable dialog and /config), the GitHub templates, the path lists, and the messages
# hooks and scripts print. Tests and internal records (docs/evals, docs/plans, ...) are not
# in it. skills-lint.sh itself is left out because it names the patterns it forbids.
PUBLIC_TEXT=()
while IFS= read -r f; do PUBLIC_TEXT+=("$f"); done < <(
  { for n in README.md INSTALL.md WORKFLOW.md BEGINNERS-GUIDE.md AGENTS.md CONTRIBUTING.md \
             ROADMAP.md CLAUDE.md global/CLAUDE.md docs/checklists/review-calibration.md; do
      [ -f "$ROOT/$n" ] && echo "$ROOT/$n"
    done
    ls "$ROOT"/skills/*/*.md "$ROOT"/agents/*.md "$ROOT"/docs/*.md "$ROOT"/docs/examples/*.md \
       "$ROOT"/docs/*-paths.txt "$ROOT"/.claude-plugin/*.json "$ROOT"/hooks/*.json \
       "$ROOT"/hooks/*.sh "$ROOT"/scripts/*.sh 2>/dev/null | grep -v '/scripts/skills-lint\.sh$'
    for d in project-templates .github; do
      [ -d "$ROOT/$d" ] && find "$ROOT/$d" \( -name '*.md' -o -name '*.json' \)
    done
  } | sort -u)

# C1. Model-invocable skills must contain "Use when" (routing floor)
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -q "disable-model-invocation: true" "$f" && continue
  grep -q "Use when" "$f" \
    || viol C1 "$f: model-invocable skill has no 'Use when' trigger in its text"
done

# C2. Tunnel mention => exposure lifecycle owned
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -qiE "cloudflared|ngrok|localtunnel" "$f" || continue
  grep -qiE "stop sharing|teardown" "$f" \
    || viol C2 "$f: mentions a tunnel but has no teardown contract"
done

# C3. Spec-document producers reference the editor-open rule
for name in prd stories critique research; do
  f="$ROOT/skills/$name/SKILL.md"
  [[ -f "$f" ]] || continue
  grep -qE "code -r|code --add" "$f" \
    || viol C3 "$f: produces human-read documents but never opens them (code -r)"
done

# C4. Mode aliases always paired with their plain names (per file)
for f in "${SKILLS[@]:+${SKILLS[@]}}" "${AGENTS[@]:+${AGENTS[@]}}" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md"; do
  [[ -f "$f" ]] || continue
  if grep -q "Mode A" "$f" && ! grep -qiE "with[- ]me" "$f"; then
    viol C4 "$f: says 'Mode A' but never 'with me'"
  fi
  if grep -q "Mode B" "$f" && ! grep -qiE "for[- ]me" "$f"; then
    viol C4 "$f: says 'Mode B' but never 'for me'"
  fi
done

# C5. Every referenced script exists, in TWO name classes, over FOUR sources.
#     AGENTS.md and global/CLAUDE.md are scanned because Guardrails 7 is the single source
#     sixteen surfaces point at by reference (C13), so a rename of a script named only
#     there would leave all sixteen instructing agents to run a nonexistent file.
#     EXTRACT-and-check, not neutralize-and-skip: pass one consumes <name>.test.sh names
#     and requires them under tests/, so pass two cannot see the phantom `test.sh` that a
#     word-boundary match would otherwise pull out of a path like x.test.sh. Neutralizing
#     would kill the phantom but stop checking test references at all, which trades one gap
#     for another. The basename MAY CONTAIN DOTS (tests/init-project.language.test.sh
#     exists here), so the whole dotted run before .test.sh is taken.
C5_SRC=("$ROOT/skills" "$ROOT/agents" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md")
c5_text() { for p in "${C5_SRC[@]}"; do [[ -e "$p" ]] && grep -rh '' "$p" 2>/dev/null; done; }
c5_all="$(c5_text)"
# pass one: test files
trefs="$(printf '%s\n' "$c5_all" | grep -oE '[a-z0-9_.-]+\.test\.sh' | sort -u)"
for r in $trefs; do
  [[ -f "$ROOT/tests/$r" ]] \
    || viol C5 "referenced test file does not exist: $r (searched tests/)"
done
# pass two: everything else, with the test-file names already consumed
orefs="$(printf '%s\n' "$c5_all" | sed -E 's/[a-z0-9_.-]+\.test\.sh/ /g' \
         | grep -oE '\b[a-z][a-z0-9_-]*(\.[a-z0-9_-]+)*\.sh\b' | sort -u)"
for r in $orefs; do
  [[ -f "$ROOT/scripts/$r" || -f "$ROOT/$r" ]] \
    || viol C5 "referenced script does not exist: $r (searched scripts/ and repo root)"
done

# C6. Reviewer agents carry the single-verdict contract
for name in code-reviewer design-reviewer pm-reviewer skill-reviewer; do
  f="$ROOT/agents/$name.md"
  [[ -f "$f" ]] || continue
  { grep -q "Only you" "$f" && grep -q "History" "$f"; } \
    || viol C6 "$f: missing the single-verdict contract ('Only you' + History)"
done

# C7. No em/en dashes in the system's instruction files
dash_hits="$(grep -rlE $'—|–' "$ROOT/skills" "$ROOT/agents" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $dash_hits; do
  viol C7 "$f: contains an em/en dash (style rule: commas, colons, periods)"
done

# C8. No person credits, no third-party plugin names
PERSONS='Podmajersky|Yifrah|Teresa Torres|Marty Cagan|Ron Jeffries|Bill Wake|Clayton Christensen|Osterwalder|April Dunford|Dave McClure|John Doerr|Andy Grove|Ash Maurya|Gary Klein|Kahneman|Karpathy|Intercom|NN/g|Nielsen Norman'
PLUGINS='pm-skills|phuryn'
cred_hits="$(grep -rlE "$PERSONS" "$ROOT/skills" "$ROOT/agents" "$ROOT/docs/system-map.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $cred_hits; do
  viol C8 "$f: credits a person or company by name (attribution policy: frameworks only)"
done
PLUGINS="$PLUGINS|pm-execution|pm-product-discovery"
plug_hits="$(grep -liE "$PLUGINS" "${PUBLIC_TEXT[@]:+${PUBLIC_TEXT[@]}}" /dev/null 2>/dev/null || true)"
for f in $plug_hits; do
  viol C8 "$f: names a third-party plugin"
done

# C11. Model names never version-pinned; tiers only. A versioned ID baked into
#      an instruction file goes stale the day a new model ships (proven:
#      a stale versioned name was quoted after the successor shipped). Harness resolves
#      NOTE: alternation covers the Anthropic family; extend it with each
#      host's model-family words at port time (portability backlog).
#      tiers to the newest; files must speak in tiers.
ver_hits="$(grep -rliE '(opus|sonnet|haiku|fable)[- ][0-9]' "$ROOT/skills" "$ROOT/agents" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $ver_hits; do
  viol C11 "$f: contains a version-pinned model name/id (use tier words; the harness resolves versions)"
done
# Builder executes; its tier is pinned to sonnet (or inherit for max-quality).
if [[ -f "$ROOT/agents/builder.md" ]]; then
  bmodel="$(awk 'NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next } /^---[[:space:]]*$/{exit} /^model:/{sub(/^model:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$ROOT/agents/builder.md")"
  case "$bmodel" in
    sonnet|inherit|"") : ;;  # empty = inherits by default, allowed
    *) viol C11 "agents/builder.md: model must be 'sonnet' or 'inherit', got '$bmodel'" ;;
  esac
fi

# C12. Every agent DEFINITION (a file in agents/ with a name: frontmatter) declares
#      effort: from the allowed set, so a dispatched role's reasoning depth is
#      DECLARED, not left to the ambient session (AGENTS.md model policy). Files in
#      agents/ without a name: (e.g. a rubric) are not definitions and are skipped.
# agent_frontmatter FILE, the frontmatter block, empty when the file has none.
# is_agent_definition FILE, true when that block declares a non-empty name:.
# ONE definition detector, shared by C12 and C13, so the two can never drift into
# disagreeing about what an agent definition is (C2 requires C13 to detect one
# "exactly as C12 does", and two verbatim copies could not be held to that).
agent_frontmatter() {
  awk 'NR==1{if($0!~/^---[[:space:]]*$/)exit; next} /^---[[:space:]]*$/{exit} {print}' "$1"
}
is_agent_definition() {
  agent_frontmatter "$1" | grep -qE '^name:[[:space:]]*[^[:space:]]'
}

if [[ -d "$ROOT/agents" ]]; then
  for f in "$ROOT"/agents/*.md; do
    [[ -f "$f" ]] || continue
    is_agent_definition "$f" || continue
    fm="$(agent_frontmatter "$f")"
    eff="$(printf '%s\n' "$fm" | awk -F':[[:space:]]*' '/^effort:/{print $2; exit}' | tr -d '[:space:]')"
    case "$eff" in
      low|medium|high|xhigh|max) : ;;
      "") viol C12 "$(basename "$f"): agent definition missing 'effort:' (declare low|medium|high|xhigh|max)" ;;
      *)  viol C12 "$(basename "$f"): invalid effort '$eff' (use low|medium|high|xhigh|max)" ;;
    esac
  done
fi

# C13. The prose-generating skills, /build (the dispatcher), and every agent DEFINITION
#      carry the output-language rule: BOTH the token 'output_language' AND the pointer
#      'Guardrails 7'. The token alone cannot tell a POINTER from a RESTATEMENT, so a
#      file that quietly grows its own copy of the guardrail would stay green forever.
#      A listed path absent from the scanned root is SKIPPED (as C3 and C6 do), so the
#      lint stays runnable against any root. Honest limit: two greps prove
#      marker-plus-pointer, never MEANING; an inverted bullet is a reviewer's catch.
c13_check() { # c13_check <file> <label>
  grep -q 'output_language' "$1" \
    || viol C13 "$2: carries no output-language rule (missing the 'output_language' marker)"
  grep -q 'Guardrails 7' "$1" \
    || viol C13 "$2: states the output-language rule without pointing at it (missing 'Guardrails 7')"
}
for name in prd stories critique research product-signal build; do
  f="$ROOT/skills/$name/SKILL.md"
  [[ -f "$f" ]] || continue
  c13_check "$f" "skills/$name/SKILL.md"
done
if [[ -d "$ROOT/agents" ]]; then
  for f in "$ROOT"/agents/*.md; do
    [[ -f "$f" ]] || continue
    is_agent_definition "$f" || continue
    c13_check "$f" "$(basename "$f")"
  done
fi

# C14. Commands are named the way a plugin install types them: /odeo:<skill>.
#      Claude Code namespaces every plugin skill, so a bare /<skill> is not a command a
#      user can type (verified in a fresh session: only /odeo:new-project is offered).
#      The names come from skills/ itself, so a new skill is covered without editing this.
#      A path such as docs/prds/, skills/prd/SKILL.md, ~/prd, a URL or
#      ${CLAUDE_PLUGIN_ROOT}/prd is not a command: the character before its / is a
#      letter, digit, '.', ':', '/', '~', '}' or '-'. The start boundary is that EXCLUSION, not a
#      list of allowed characters: an allowlist let '─/build─' in a diagram and '[/prd](x)'
#      through, because box-drawing characters and '[' were not on it.
names="$(ls -d "$ROOT"/skills/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null | paste -sd'|' -)"
if [ -n "$names" ]; then
  while IFS= read -r hit; do
    [ -n "$hit" ] && viol C14 "$hit (write it as /odeo:<skill>)"
  done < <(grep -nE "(^|[^A-Za-z0-9_.:/~}-])/($names)([^A-Za-z0-9_-]|\$)" \
             "${PUBLIC_TEXT[@]:+${PUBLIC_TEXT[@]}}" /dev/null 2>/dev/null | cut -c1-200)
fi

# C15. Skills and agents cite the rules file as ${CLAUDE_PLUGIN_ROOT}/AGENTS.md.
#      In a plugin install a user's project has no AGENTS.md; Odeo's lives in the plugin, and
#      Claude Code substitutes ${CLAUDE_PLUGIN_ROOT} in skill and agent text. A line that
#      means the PROJECT's own context files says so with the exact phrase
#      "(project + global)" and is left alone; a looser "project" would also exempt a line
#      that merely mentions "the project's CLAUDE.md" next to Odeo's rules file.
while IFS= read -r hit; do
  [ -n "$hit" ] && viol C15 "$hit (cite it as \${CLAUDE_PLUGIN_ROOT}/AGENTS.md, or mark the project's own file with (project + global))"
done < <(grep -n 'AGENTS\.md' "$ROOT"/skills/*/*.md "${AGENTS[@]:+${AGENTS[@]}}" /dev/null 2>/dev/null \
           | awk '{ line = $0; gsub(/\$\{CLAUDE_PLUGIN_ROOT\}\/AGENTS\.md/, "", line)
                    if (line ~ /AGENTS\.md/ && index(line, "(project + global)") == 0) print }' | cut -c1-200)

# C16. Programs are named by the path a plugin install can run.
#      The programs live in scripts/ and a plugin install puts them on no PATH that lasts
#      (the bin/ compatibility wrappers go in the next release), so a SKILL.md or an agent
#      names each one exactly as ${CLAUDE_PLUGIN_ROOT}/scripts/<name>, which Claude Code
#      substitutes in those bodies only. Any other form is flagged: a bare name, a relative
#      or absolute path, another variable. A skill's supporting file is read raw, where
#      nothing is substituted, so it names no program at all. Anywhere in the published
#      text, bin/<program> is the 0.2.x layout and is flagged, except the ~/bin/ and
#      $HOME/bin/ copies of the old install, which are real. A name that is part of a longer
#      name (my-x.sh, x.sh.bak, tests/x.test.sh) is not a program reference.
#      The check runs in perl; if perl is missing or fails, C16 fails instead of passing.
c16_scan() { # c16_scan <mode: body|public> <files...>: prints "file:line: reason" per hit
  PROGRAMS="$PROGRAMS" MODE="$1" perl -ne '
    BEGIN { @n = split " ", $ENV{PROGRAMS}; $re = join "|", map { quotemeta } @n; $re = "(?!)" unless @n }
    my $support = ($ENV{MODE} eq "body" && $ARGV =~ m{/skills/[^/]+/} && $ARGV !~ m{/SKILL\.md$});
    while (/($re)(?![\w\-]|\.\w)/g) {
      my $n = $1; my $pre = substr($_, 0, $-[1]);
      next if $pre =~ /[\w.\-]$/;    # part of a longer name; ./x ends in "/" and stays a hit
      if ($ENV{MODE} eq "public") {
        next unless $pre =~ /(^|[^\w.\-])(\S*)bin\/$/;
        my $lead = $2;
        next if $lead =~ /(^|[^\w])(~|\$HOME|\$\{HOME\})\/$/ || $lead =~ /^(~|\$HOME|\$\{HOME\})\/$/;
        print "$ARGV:$.: bin/$n (the programs are in scripts/; bin/ is the 0.2.x layout)\n"; last;
      }
      if ($support) { print "$ARGV:$.: $n named in a supporting file (read raw; name programs in SKILL.md)\n"; last }
      next if $pre =~ /\$\{CLAUDE_PLUGIN_ROOT\}\/scripts\/$/;
      next if $pre =~ /(~|\$HOME|\$\{HOME\})\/bin\/$/;
      print "$ARGV:$.: $n not named as \${CLAUDE_PLUGIN_ROOT}/scripts/$n\n"; last;
    }
    close ARGV if eof' "${@:2}" /dev/null
}
PROGRAMS="$(ls "$ROOT"/scripts 2>/dev/null | tr '\n' ' ')"
if ! command -v perl >/dev/null 2>&1; then
  viol C16 "perl not found; the program-name check cannot run"
else
  for mode in body public; do
    if [[ $mode == body ]]; then files=("$ROOT"/skills/*/*.md "${AGENTS[@]:+${AGENTS[@]}}")
    else files=("${PUBLIC_TEXT[@]:+${PUBLIC_TEXT[@]}}"); fi
    hits="$(c16_scan "$mode" "${files[@]}" 2>&1)"; rc=$?
    if [[ $rc -ne 0 ]]; then viol C16 "the program-name check failed to run (perl exit $rc): $(printf '%s' "$hits" | head -c 200)"; continue; fi
    while IFS= read -r hit; do
      [[ -n "$hit" ]] && viol C16 "$(printf '%s' "$hit" | cut -c1-240)"
    done <<< "$hits"
  done
fi

# C9. Every SKILL.md declares a non-empty description
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -qE '^description: .+' "$f" \
    || viol C9 "$f: missing or empty 'description:' frontmatter"
done

# C10. second-opinion skills reference the shared protocol, and NO vendor name
#      appears in a skill folder/command name (vendor is an argument; names belong
#      only in records, e.g. vendor_model:, and spoken at send time). Extend the
#      vendor list per integrated CLI.
VENDOR_NAMES='codex|gemini'
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  case "$f" in */second-opinion-*/SKILL.md) : ;; *) continue ;; esac
  grep -q "second-opinion-protocol.md" "$f" \
    || viol C10 "$f: a second-opinion skill must reference docs/second-opinion-protocol.md (never restate it)"
  dir="$(basename "$(dirname "$f")")"
  echo "$dir" | grep -qiE "$VENDOR_NAMES" \
    && viol C10 "$f: vendor name in the skill folder '$dir' (vendor is an argument, not a name)"
done

if [[ $fail -eq 0 ]]; then
  echo "skills-lint: all invariants hold."
  exit 0
fi
echo "skills-lint: violations found (see docs/invariants.md for the rules)." >&2
exit 1
