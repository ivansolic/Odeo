#!/usr/bin/env bash
# Tests for scripts/skills-lint.sh, the system's own consistency gate.
# Each check gets one violating fixture (expect exit 1) and the clean fixture
# passes; finally the REAL repo must pass. Run: bash tests/skills-lint.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT="$TEST_DIR/../scripts/skills-lint.sh"
pass=0; fail=0

check() { # check <name> <want_rc> <root>
  ( bash "$LINT" "$3" ) >/dev/null 2>&1; local rc=$?
  if [[ $rc -eq $2 ]]; then echo "ok   - $1"; pass=$((pass+1));
  else echo "FAIL - $1 (rc=$rc want=$2)"; fail=$((fail+1)); fi
}

mkskill() { # mkskill <root> <name> <frontmatter-extra> <body>
  mkdir -p "$1/skills/$2"
  printf -- '---\ndescription: %s\n%s---\n%s\n' "$4" "$3" "${5:-body}" > "$1/skills/$2/SKILL.md"
}

clean_root() { # a minimal root that passes every check
  local d; d="$(mktemp -d)"
  mkdir -p "$d/scripts" "$d/agents" "$d/global" "$d/docs"
  touch "$d/scripts/privacy-scan.sh"
  mkskill "$d" alpha "" "Use when the user wants alpha things."
  mkskill "$d" beta "disable-model-invocation: true\n" "Explicit command, any description."
  printf -- '---\nname: code-reviewer\neffort: high\n---\nOnly you write the verdict.\n## History\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/code-reviewer.md"
  printf -- 'baseline\nPlan layers: Summary, Why, Technical\n' > "$d/global/CLAUDE.md"
  printf -- '# Plan format\nPlan layers: Summary, Why, Technical\n' > "$d/docs/plan-format.md"
  printf -- 'baseline\n' > "$d/AGENTS.md"
  printf -- 'map\n' > "$d/docs/system-map.md"
  echo "$d"
}

# 0. Clean fixture passes
d="$(clean_root)"; check "clean fixture passes" 0 "$d"; rm -rf "$d"

# C1: auto-invoked skill without "Use when" -> fail
d="$(clean_root)"; mkskill "$d" gamma "" "Does gamma things, invoked by the model."
check "C1 flags auto skill without Use-when" 1 "$d"; rm -rf "$d"

# C12: an agent definition (has name:) missing effort: -> fail
d="$(clean_root)"; printf -- '---\nname: lonely\n---\nbody\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
check "C12 flags an agent without effort:" 1 "$d"; rm -rf "$d"
# C12: an agent with an invalid effort value -> fail
d="$(clean_root)"; printf -- '---\nname: lonely\neffort: turbo\n---\nbody\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
check "C12 flags an agent with invalid effort" 1 "$d"; rm -rf "$d"
# C12: a non-definition file in agents/ (no name:, e.g. a rubric) is NOT required to carry effort
d="$(clean_root)"; printf -- '# Agent rubric\nno frontmatter here\n' > "$d/agents/agent-rubric.md"
check "C12 ignores a non-definition agents/ file" 0 "$d"; rm -rf "$d"

# C2: tunnel mention without teardown -> fail; with teardown -> pass
d="$(clean_root)"; mkskill "$d" share "disable-model-invocation: true\n" "Shares things." "Start a cloudflared tunnel for the user."
check "C2 flags tunnel without teardown" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" share "disable-model-invocation: true\n" "Shares things." "Start a cloudflared tunnel. On stop sharing, kill it (teardown)."
check "C2 passes tunnel with teardown" 0 "$d"; rm -rf "$d"

# C3: a doc-producing skill (prd) without editor-open -> fail
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md Prose follows output_language, see \${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7."
check "C3 flags prd without editor-open" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>. Prose follows output_language, see \${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7."
check "C3 passes prd with editor-open" 0 "$d"; rm -rf "$d"

# C4: "Mode A" without "with me" in the same file -> fail
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "Pick Mode A or Mode B. for me is one of them."
check "C4 flags Mode A without with-me pairing" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "with me (Mode A) or for me (Mode B)."
check "C4 passes paired mode names" 0 "$d"; rm -rf "$d"

# C5: referencing a script that doesn't exist -> fail
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run ghost-script.sh first."
check "C5 flags missing referenced script" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run \${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh first."
check "C5 passes existing script reference" 0 "$d"; rm -rf "$d"

# C6: reviewer agent without the single-verdict contract -> fail
d="$(clean_root)"; printf -- '---\nname: pm-reviewer\n---\nScores documents.\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/pm-reviewer.md"
check "C6 flags reviewer without verdict contract" 1 "$d"; rm -rf "$d"

# C7: em dash in a skill -> fail
d="$(clean_root)"; mkskill "$d" zeta "disable-model-invocation: true\n" "Dashy skill." "This uses an em dash — forbidden."
check "C7 flags em dash" 1 "$d"; rm -rf "$d"

# C8: person credit -> fail; third-party plugin name -> fail
d="$(clean_root)"; mkskill "$d" eta "disable-model-invocation: true\n" "Credits people." "Based on Teresa Torres."
check "C8 flags person credit" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" theta "disable-model-invocation: true\n" "Mentions plugins." "Also works with pm-skills."
check "C8 flags third-party plugin name" 1 "$d"; rm -rf "$d"

# C9: missing description -> fail
d="$(clean_root)"; mkdir -p "$d/skills/iota"; printf -- '---\n---\nNo description here.\n' > "$d/skills/iota/SKILL.md"
check "C9 flags missing description" 1 "$d"; rm -rf "$d"

# C11: versioned Claude model ID in a skill -> fail
d="$(clean_root)"; mkskill "$d" kappa "disable-model-invocation: true\n" "Uses models." "Runs on claude-sonnet-4-6 for speed."
check "C11 flags versioned model id" 1 "$d"; rm -rf "$d"

# C11: builder frontmatter model must be sonnet or inherit
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: haiku\ntools: Read\n---\nOnly you write the verdict.\n## History\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
check "C11 flags builder on a non-sonnet tier" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: sonnet\neffort: high\ntools: Read\n---\nbody\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
check "C11 passes builder on sonnet" 0 "$d"; rm -rf "$d"

# C11: prose model name with version -> fail; old-style id -> fail; in AGENTS.md -> fail
d="$(clean_root)"; mkskill "$d" lam "disable-model-invocation: true\n" "Prose name." "Reviews run best on Sonnet 4.6 today."
check "C11 flags prose versioned name" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" mu "disable-model-invocation: true\n" "Old id." "Use claude-3-5-sonnet-20241022 here."
check "C11 flags old-style dated id" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'baseline\nOpus 4.8 is great.\n' > "$d/AGENTS.md"
check "C11 flags versioned name in AGENTS.md" 1 "$d"; rm -rf "$d"

# C11: builder model with trailing whitespace must still pass
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: sonnet \neffort: high\ntools: Read\n---\nbody\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
check "C11 tolerates trailing whitespace on builder model" 0 "$d"; rm -rf "$d"

# C10: a second-opinion skill without the protocol reference -> fail
d="$(clean_root)"; mkskill "$d" second-opinion-code "disable-model-invocation: true\n" "Second opinion on code." "Runs the vendor and compares. (no protocol reference here)"
check "C10 flags a second-opinion skill missing the protocol ref" 1 "$d"; rm -rf "$d"

# C10: a vendor name in a second-opinion folder -> fail (even with the protocol ref)
d="$(clean_root)"; mkskill "$d" second-opinion-codex "disable-model-invocation: true\n" "Vendor-named." "See docs/second-opinion-protocol.md for the mechanism."
check "C10 flags a vendor name in the skill folder" 1 "$d"; rm -rf "$d"

# C10: a target-named second-opinion skill that references the protocol -> pass
d="$(clean_root)"; mkskill "$d" second-opinion-code "disable-model-invocation: true\n" "Second opinion on code." "See docs/second-opinion-protocol.md for the shared mechanism."
check "C10 passes a target-named skill that references the protocol" 0 "$d"; rm -rf "$d"

# C13. The prose-generating skills, /build, and every agent definition carry the
#      output-language rule: BOTH the token 'output_language' AND the pointer
#      'Guardrails 7'. A listed path absent from the root is skipped.
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>."
check "C13 catches a prose skill with no output-language rule" 1 "$d"; rm -rf "$d"

d="$(clean_root)"; mkskill "$d" build "disable-model-invocation: true\n" "Builds a story." "Dispatch the architect, then a builder."
check "C13 catches /build not carrying the dispatcher duty" 1 "$d"; rm -rf "$d"

d="$(clean_root)"; printf -- '---\nname: lonely\neffort: high\n---\nbody\n' > "$d/agents/lonely.md"
check "C13 catches an agent definition with no output-language rule" 1 "$d"; rm -rf "$d"

# The POINTER clause, ISOLATED. Every case above omits BOTH strings, so without this
# one the 'Guardrails 7' grep could be deleted and the suite would stay fully green.
# This case is what makes the pointer half of C2 a real invariant instead of a claim,
# and it is the exact rot mode C13 exists to catch: a file that restates the guardrail
# locally instead of pointing at it.
d="$(clean_root)"; printf -- '---\nname: lonely\neffort: high\n---\nbody\nProse follows output_language, and this file keeps its own local copy of the rule.\n' > "$d/agents/lonely.md"
check "C13 catches a restatement: token present, pointer missing" 1 "$d"; rm -rf "$d"

# And the mirror: pointer present, token missing.
d="$(clean_root)"; printf -- '---\nname: lonely\neffort: high\n---\nbody\nSee ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7 for the rule.\n' > "$d/agents/lonely.md"
check "C13 catches a pointer with no marker" 1 "$d"; rm -rf "$d"

d="$(clean_root)"; printf -- 'A rubric, not a definition: no frontmatter, no name key.\n' > "$d/agents/agent-rubric.md"
check "C13 skips a non-definition file in agents/" 0 "$d"; rm -rf "$d"

d="$(clean_root)"
mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>. Prose follows output_language, see \${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7."
mkskill "$d" build "disable-model-invocation: true\n" "Builds a story." "Hand the builder output_language, see \${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7."
printf -- '---\nname: lonely\neffort: high\n---\nbody\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
check "C13 passes when the skills and the agent definition all carry it" 0 "$d"; rm -rf "$d"

# C5, widened scope. AGENTS.md and global/CLAUDE.md are now scanned, because Guardrails 7
#     is the single source sixteen surfaces point at by reference (C13), so a rename of a
#     script named only there would leave all sixteen instructing agents to run a
#     nonexistent file with every gate green.
d="$(clean_root)"; printf -- 'baseline\nrun ghost-script.sh for this\n' > "$d/AGENTS.md"
check "C5 catches a ghost script named only in AGENTS.md" 1 "$d"; rm -rf "$d"

d="$(clean_root)"; printf -- 'baseline\nrun ghost-script.sh for this\n' > "$d/global/CLAUDE.md"
check "C5 catches a ghost script named only in the global baseline" 1 "$d"; rm -rf "$d"

# The PHANTOM, and this case is a permanent positive control rather than a one-off. C5's
# extraction is word-boundary based, so a reference to tests/x.test.sh yields the name
# `test.sh` unless test-file names are consumed first. No scripts/test.sh exists, so the naive
# widening turns the lint RED on the clean repo. This case must be GREEN both before and
# after the change; if it ever goes red, the two-pass extraction has been undone.
d="$(clean_root)"; mkdir -p "$d/tests"
printf -- 'baseline\nsee tests/localized-prose.test.sh for the evidence\n' > "$d/AGENTS.md"
printf -- 'placeholder\n' > "$d/tests/localized-prose.test.sh"
check "C5 reads a .test.sh reference as a test file, not as test.sh" 0 "$d"; rm -rf "$d"

# A DOTTED script name. Pass two used to match only the last dotted run, so a reference to
# scripts/init-project.language.sh yielded the phantom `language.sh`; this repo really contains
# tests/init-project.language.test.sh, so dotted names are not hypothetical here.
d="$(clean_root)"; printf -- 'baseline\nrun scripts/init-project.language.sh for setup\n' > "$d/AGENTS.md"
printf -- 'placeholder\n' > "$d/scripts/init-project.language.sh"
check "C5 resolves a DOTTED script name without inventing a phantom" 0 "$d"; rm -rf "$d"

# C14: a plugin install names every command /odeo:<skill>; a bare /<skill> is not typeable.
# Observed failing (2026-09-24), each mutant checked to differ: README dropped from the scope
# -> "flags a bare command in the README"; end boundary loosened to any character -> "leaves
# built-ins and longer words alone" (/alphabet matched); pm-execution dropped from the plugin
# list -> "C8 flags a third-party plugin in a public doc".
# Round 2: the old allowlist start class -> the diagram and link-text cases (the reviewer's
# positive control); manifests dropped from the scope -> the enable-dialog case.
# Round 3: dropping } from the exclusion -> the plugin-root case (a real ${CLAUDE_PLUGIN_ROOT}/<skill> path).
d="$(clean_root)"; printf -- 'Run `/alpha` to start.\n' > "$d/README.md"
check "C14 flags a bare command in the README" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'Run `/odeo:alpha` to start.\n' > "$d/README.md"
check "C14 passes the prefixed command" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'See docs/alphas/ and skills/alpha/SKILL.md and a/alpha.\n' > "$d/README.md"
check "C14 ignores paths that contain a skill name" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." "Then offer /beta once."
check "C14 flags a bare command inside a skill" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkdir -p "$d/hooks"; printf -- 'echo "change it with /alpha"\n' > "$d/hooks/x.sh"
check "C14 flags a bare command in a hook message" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'Built-ins stay: /security-review, /plugin, /config, /alphabet.\n' > "$d/README.md"
check "C14 leaves built-ins and longer words alone" 0 "$d"; rm -rf "$d"

d="$(clean_root)"; printf -- 'plan ─────/alpha─────> build\n' > "$d/README.md"
check "C14 flags a bare command inside a box-drawing diagram" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'See [/alpha](docs/x.md).\n' > "$d/README.md"
check "C14 flags a bare command as markdown link text" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkdir -p "$d/.claude-plugin"; printf -- '{"description": "change it with /alpha"}\n' > "$d/.claude-plugin/plugin.json"
check "C14 flags a bare command in the plugin manifest (the enable dialog text)" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkdir -p "$d/.github/ISSUE_TEMPLATE"; printf -- '- [ ] /alpha\n' > "$d/.github/ISSUE_TEMPLATE/bug.md"
check "C14 flags a bare command in a GitHub template" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'x ${CLAUDE_PLUGIN_ROOT}/alpha/rubric.md and https://x.io/alpha and ~/alpha\n' > "$d/README.md"
check "C14 leaves plugin-root paths, URLs and home paths alone" 0 "$d"; rm -rf "$d"

# C15: in a plugin install the rules file is the PLUGIN's, a user's project has no AGENTS.md
# Observed failing (2026-09-28): a loose "project" exemption -> the mentions-a-project case;
# C15 disabled -> the bare-citation case; C15 scanning only SKILL.md -> the rubric.md case.
# Each mutant checked to differ.
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." "Follow AGENTS.md Guardrails 1."
check "C15 flags a bare AGENTS.md citation in a skill" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'Follow `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 1.'
check "C15 passes the plugin-root citation" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'Read `AGENTS.md` / `CLAUDE.md` (project + global) for conventions.'
check "C15 passes a line that means the PROJECT's own file" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'A conflict with AGENTS.md or the project'"'"'s CLAUDE.md resolves against the entry.'
check "C15 flags Odeo's rules file even when the line mentions a project" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'Score it per AGENTS.md Guardrails 3.\n' > "$d/skills/alpha/rubric.md"
check "C15 flags a bare citation in a skill's rubric.md" 1 "$d"; rm -rf "$d"

# C8 over ALL public docs: no third-party plugin names (pm-skills once lived in the beginners guide)
d="$(clean_root)"; printf -- 'Write a PRD with /pm-execution:create-prd.\n' > "$d/BEGINNERS-GUIDE.md"
check "C8 flags a third-party plugin in a public doc" 1 "$d"; rm -rf "$d"

# C16: programs live in scripts/ and are not on PATH, so a SKILL.md or an agent names them
# exactly as ${CLAUDE_PLUGIN_ROOT}/scripts/<name>; a supporting file (read raw) names none;
# bin/<program> anywhere public is the 0.2.x layout. Observed failing (2026-09-29, round 2
# after the review), each mutant checked to differ: MA the body pass never reports -> the
# bare-name and four path-form cases; MB the bin/ pass never reports -> the README and
# script-comment cases; MC the ~/bin exemption dropped -> the home-copy case and the real
# repo; MD the right-hand boundary dropped -> the longer-name case; ME the supporting-file
# rule dropped -> the supporting-file case; MF any path accepted as the prefix -> the four
# path-form cases; MG perl's exit status ignored -> the broken-perl case; MH a leading dot
# read as a boundary -> the longer-name case.
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'Run `privacy-scan.sh <file>` first.'
check "C16 flags a bare program name in a skill" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'Run `${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh <file>` first.'
check "C16 passes the plugin-root path" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'Run privacy-scan.sh before sending.\n' > "$d/skills/alpha/rubric.md"
check "C16 flags a bare name in a skill's supporting file" 1 "$d"; rm -rf "$d"
agent16() { # agent16 <root> <body line>: an agent definition that passes every other check
  printf -- '---\nname: debugger\neffort: high\n---\n%s\noutput_language: prose follows it, see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Guardrails 7.\n' "$2" > "$1/agents/debugger.md"
}
d="$(clean_root)"; agent16 "$d" 'Then run ${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh.'
check "C16 control: the agent fixture with the path passes" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; agent16 "$d" 'Then run privacy-scan.sh.'
check "C16 flags a bare program name in an agent" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." 'Evidence: `tests/privacy-scan.test.sh`; unrelated: `my-privacy-scan.sh`, `old.privacy-scan.sh` and `privacy-scan.sh.bak`.'
touch "$d/my-privacy-scan.sh" "$d/old.privacy-scan.sh"; mkdir -p "$d/tests"; touch "$d/tests/privacy-scan.test.sh"
check "C16 leaves test files and longer names alone" 0 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'Publish via bin/privacy-scan.sh.\n' > "$d/README.md"
check "C16 flags the 0.2.x bin/ path in the README" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- '#!/usr/bin/env bash\n# see bin/privacy-scan.sh\n' > "$d/scripts/other.sh"
check "C16 flags the 0.2.x bin/ path in a script comment" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'The shim at ~/bin/privacy-scan.sh and $HOME/bin/privacy-scan.sh stays.\n' > "$d/README.md"
check "C16 leaves the ~/bin copies of the old install alone" 0 "$d"; rm -rf "$d"
# Path forms that point at nothing in a plugin install: only the exact plugin-root prefix counts
for form in 'scripts/privacy-scan.sh' './privacy-scan.sh' '$ROOT/scripts/privacy-scan.sh' '/opt/odeo/scripts/privacy-scan.sh'; do
  d="$(clean_root)"; mkskill "$d" gamma "disable-model-invocation: true\n" "Explicit." "Run \`$form <file>\` first."
  check "C16 flags the path form $form in a skill" 1 "$d"; rm -rf "$d"
done
# A supporting file is read raw (no substitution), so it names no program at all
d="$(clean_root)"; printf -- 'Run ${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh before sending.\n' > "$d/skills/alpha/rubric.md"
check "C16 flags a program named in a supporting file even in the plugin-root form" 1 "$d"; rm -rf "$d"
# A checkout that itself lives under a skills/<x>/ directory: only ROOT/skills/<x>/ makes a
# supporting file, never a skills/ segment above ROOT. Observed failing (2026-09-30) with the
# match on the whole path: the agent case, while both controls stayed red as they should.
nested() { local b r; b="$(mktemp -d)"; r="$(clean_root)"; mkdir -p "$b/skills/nest"; mv "$r" "$b/skills/nest/odeo"; echo "$b/skills/nest/odeo"; }
d="$(nested)"; agent16 "$d" 'Then run ${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh.'
check "C16 passes an agent's plugin-root path in a checkout under skills/<x>/" 0 "$d"; rm -rf "${d%/skills/nest/odeo}"
d="$(nested)"; agent16 "$d" 'Then run privacy-scan.sh.'
check "C16 control: a bare name in an agent under skills/<x>/ is still flagged" 1 "$d"; rm -rf "${d%/skills/nest/odeo}"
d="$(nested)"; printf -- 'Run privacy-scan.sh before sending.\n' > "$d/skills/alpha/rubric.md"
check "C16 control: a supporting file under skills/<x>/ is still flagged" 1 "$d"; rm -rf "${d%/skills/nest/odeo}"
# C16 must never pass because its own instrument broke: with perl unusable it fails loudly
d="$(clean_root)"; fake="$(mktemp -d)"; printf '#!/bin/sh\nexit 127\n' > "$fake/perl"; chmod +x "$fake/perl"
out="$( PATH="$fake:$PATH" bash "$LINT" "$d" 2>&1 )"; rc=$?
if [[ $rc -eq 1 && "$out" == *"failed to run (perl exit"* ]]; then echo "ok   - C16 fails when perl cannot run"; pass=$((pass+1))
else echo "FAIL - C16 passed with a broken perl, or failed for another reason (rc=$rc want=1)"; fail=$((fail+1)); fi
rm -rf "$d" "$fake"
# With no perl on PATH at all, C16 says so instead of reaching the scan. PATH is a mirror of
# every program on the real PATH except perl*, so nothing else goes missing (checked: no
# "command not found"). Observed failing (2026-09-30) with the not-found violation replaced by
# ":": the lint then passed with rc 0, C16 skipped in silence.
d="$(clean_root)"; noperl="$(mktemp -d)"
IFS=: read -ra path_dirs <<< "$PATH"
for pdir in "${path_dirs[@]}"; do
  [[ $pdir == /* ]] || continue # an empty or relative entry would glob / or link to nowhere
  for prog in "$pdir"/*; do
    name="${prog##*/}"
    [[ -x "$prog" && ! -d "$prog" && "$name" != perl* && ! -e "$noperl/$name" ]] && ln -s "$prog" "$noperl/$name"
  done
done
out="$( PATH="$noperl" "$(command -v bash)" "$LINT" "$d" 2>&1 )"; rc=$?
if [[ $rc -eq 1 && "$out" == *"perl not found"* && "$out" != *"command not found"* ]]; then
  echo "ok   - C16 fails when perl is not on PATH"; pass=$((pass+1))
else echo "FAIL - C16 without perl (rc=$rc want=1, want 'perl not found' and no 'command not found')"; fail=$((fail+1)); fi
rm -rf "$d" "$noperl"

# C17: the plan layers are one list in two files. global/CLAUDE.md shapes session plans and
# docs/plan-format.md shapes /odeo:build plans; CLAUDE.md cannot point into the plugin (no
# substitution there), so the list is written twice and this is what keeps the copies equal.
# Observed failing (2026-10-01) before C17 existed: the mismatch and both missing cases.
d="$(clean_root)"; printf -- 'baseline\nPlan layers: Summary, Technical\n' > "$d/global/CLAUDE.md"
check "C17 flags plan layers that differ between the two files" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'baseline\n' > "$d/global/CLAUDE.md"
check "C17 flags global/CLAUDE.md without the plan layers line" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; rm "$d/docs/plan-format.md"
check "C17 flags a missing docs/plan-format.md" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'baseline\nPlan layers:   Summary, Why, Technical  \n' > "$d/global/CLAUDE.md"
check "C17 control: the same list with other spacing passes" 0 "$d"; rm -rf "$d"
# ONE line per file, as the rule says: a second, different list after the first is two lists
# the model reads, and the first-match read never saw it. Observed failing (2026-10-01, review
# round 1) with grep -m1 alone: the duplicate case passed.
d="$(clean_root)"; printf -- '# Plan format\nPlan layers: Summary, Why, Technical\nPlan layers: Summary, Technical\n' > "$d/docs/plan-format.md"
check "C17 flags a second 'Plan layers:' line in one file" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'baseline\nPlan layers:\n' > "$d/global/CLAUDE.md"
out="$( bash "$LINT" "$d" 2>&1 )"; rc=$?
[[ $rc -eq 1 ]] || out="(exit $rc, want 1) $out"
case "$out" in "(exit"*) echo "FAIL - C17 passed an empty list: $out"; fail=$((fail+1));;
  *"empty 'Plan layers:'"*) echo "ok   - C17 calls an empty list empty, not absent"; pass=$((pass+1));;
  *) echo "FAIL - C17 did not report the empty list as empty"; fail=$((fail+1));; esac
rm -rf "$d"

# C18: the research rubric defines its confidence words ONCE, in its Definitions; the criteria
# block (the fenced block) says "not verified" for the broad sense and never uses the bare
# lowercase word "unverified", whose defined meaning is narrower (no nameable source). Three
# review rounds found the two meanings mixed after edits (2026-10-02); two copies of a
# definition drift, so the criteria may not restate it. Capitalised "Unverified" names the
# section and the criterion and is allowed. Observed failing before C18 existed; mutations
# observed failing: whole-file scan, case-insensitive, rule removed, no fail-closed END check.
rubric_root() { # rubric_root <criteria line>: a clean root plus a research rubric
  local d; d="$(clean_root)"; mkdir -p "$d/skills/research"
  printf -- '# Research rubric\n\nDefinitions:\n- **Unverified:** no nameable source.\n- a claim marked unverified is honest\n\n```\n1. Answer  0 missing\n          1 %s\n```\n' "$1" > "$d/skills/research/rubric.md"
  printf '%s' "$d"
}
d="$(rubric_root 'rests on unverified evidence without saying so')"
check "C18 flags the bare word unverified in a rubric criterion" 1 "$d"; rm -rf "$d"
d="$(rubric_root 'rests on not verified evidence; see the Unverified section')"
check "C18 control: not verified and the capitalised section name pass" 0 "$d"; rm -rf "$d"
d="$(clean_root)"
check "C18 control: a root without a research rubric is skipped" 0 "$d"; rm -rf "$d"
# The check must fail CLOSED: a rubric whose criteria block is not a closed ``` fence (fence
# removed, `~~~`, indented, turned into a table) would otherwise be scanned for nothing and pass.
# Observed failing (2026-10-02, code review round 1): `~~~` plus "unverified" passed with rc 0.
d="$(clean_root)"; mkdir -p "$d/skills/research"
printf -- '# Research rubric\n\n~~~\n1. Answer  1 rests on unverified evidence\n~~~\n' > "$d/skills/research/rubric.md"
check "C18 flags a rubric whose criteria are not in a closed backtick fence" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkdir -p "$d/skills/research"
printf -- '# Research rubric\n\n```text\n1. Answer  1 rests on unverified evidence\n```\n' > "$d/skills/research/rubric.md"
check "C18 flags a criterion inside a fence with a language tag" 1 "$d"; rm -rf "$d"

# FINAL: the real repo must pass its own lint
check "the actual repo passes its own invariants" 0 "$TEST_DIR/.."

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
