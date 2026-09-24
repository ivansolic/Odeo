#!/usr/bin/env bash
# Tests for bin/skills-lint.sh, the system's own consistency gate.
# Each check gets one violating fixture (expect exit 1) and the clean fixture
# passes; finally the REAL repo must pass. Run: bash tests/skills-lint.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT="$TEST_DIR/../bin/skills-lint.sh"
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
  mkdir -p "$d/bin" "$d/agents" "$d/global" "$d/docs"
  touch "$d/bin/privacy-scan.sh"
  mkskill "$d" alpha "" "Use when the user wants alpha things."
  mkskill "$d" beta "disable-model-invocation: true\n" "Explicit command, any description."
  printf -- '---\nname: code-reviewer\neffort: high\n---\nOnly you write the verdict.\n## History\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/code-reviewer.md"
  printf -- 'baseline\n' > "$d/global/CLAUDE.md"
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
d="$(clean_root)"; printf -- '---\nname: lonely\n---\nbody\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
check "C12 flags an agent without effort:" 1 "$d"; rm -rf "$d"
# C12: an agent with an invalid effort value -> fail
d="$(clean_root)"; printf -- '---\nname: lonely\neffort: turbo\n---\nbody\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
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
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md Prose follows output_language, see AGENTS.md Guardrails 7."
check "C3 flags prd without editor-open" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>. Prose follows output_language, see AGENTS.md Guardrails 7."
check "C3 passes prd with editor-open" 0 "$d"; rm -rf "$d"

# C4: "Mode A" without "with me" in the same file -> fail
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "Pick Mode A or Mode B. for me is one of them."
check "C4 flags Mode A without with-me pairing" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "with me (Mode A) or for me (Mode B)."
check "C4 passes paired mode names" 0 "$d"; rm -rf "$d"

# C5: referencing a script that doesn't exist -> fail
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run ghost-script.sh first."
check "C5 flags missing referenced script" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run privacy-scan.sh first."
check "C5 passes existing script reference" 0 "$d"; rm -rf "$d"

# C6: reviewer agent without the single-verdict contract -> fail
d="$(clean_root)"; printf -- '---\nname: pm-reviewer\n---\nScores documents.\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/pm-reviewer.md"
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
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: haiku\ntools: Read\n---\nOnly you write the verdict.\n## History\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
check "C11 flags builder on a non-sonnet tier" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: sonnet\neffort: high\ntools: Read\n---\nbody\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
check "C11 passes builder on sonnet" 0 "$d"; rm -rf "$d"

# C11: prose model name with version -> fail; old-style id -> fail; in AGENTS.md -> fail
d="$(clean_root)"; mkskill "$d" lam "disable-model-invocation: true\n" "Prose name." "Reviews run best on Sonnet 4.6 today."
check "C11 flags prose versioned name" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" mu "disable-model-invocation: true\n" "Old id." "Use claude-3-5-sonnet-20241022 here."
check "C11 flags old-style dated id" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; printf -- 'baseline\nOpus 4.8 is great.\n' > "$d/AGENTS.md"
check "C11 flags versioned name in AGENTS.md" 1 "$d"; rm -rf "$d"

# C11: builder model with trailing whitespace must still pass
d="$(clean_root)"; printf -- '---\nname: builder\nmodel: sonnet \neffort: high\ntools: Read\n---\nbody\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/builder.md"
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
d="$(clean_root)"; printf -- '---\nname: lonely\neffort: high\n---\nbody\nSee AGENTS.md Guardrails 7 for the rule.\n' > "$d/agents/lonely.md"
check "C13 catches a pointer with no marker" 1 "$d"; rm -rf "$d"

d="$(clean_root)"; printf -- 'A rubric, not a definition: no frontmatter, no name key.\n' > "$d/agents/agent-rubric.md"
check "C13 skips a non-definition file in agents/" 0 "$d"; rm -rf "$d"

d="$(clean_root)"
mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>. Prose follows output_language, see AGENTS.md Guardrails 7."
mkskill "$d" build "disable-model-invocation: true\n" "Builds a story." "Hand the builder output_language, see AGENTS.md Guardrails 7."
printf -- '---\nname: lonely\neffort: high\n---\nbody\noutput_language: prose follows it, see AGENTS.md Guardrails 7.\n' > "$d/agents/lonely.md"
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
# `test.sh` unless test-file names are consumed first. No bin/test.sh exists, so the naive
# widening turns the lint RED on the clean repo. This case must be GREEN both before and
# after the change; if it ever goes red, the two-pass extraction has been undone.
d="$(clean_root)"; mkdir -p "$d/tests"
printf -- 'baseline\nsee tests/localized-prose.test.sh for the evidence\n' > "$d/AGENTS.md"
printf -- 'placeholder\n' > "$d/tests/localized-prose.test.sh"
check "C5 reads a .test.sh reference as a test file, not as test.sh" 0 "$d"; rm -rf "$d"

# A DOTTED script name. Pass two used to match only the last dotted run, so a reference to
# bin/init-project.language.sh yielded the phantom `language.sh`; this repo really contains
# tests/init-project.language.test.sh, so dotted names are not hypothetical here.
d="$(clean_root)"; printf -- 'baseline\nrun bin/init-project.language.sh for setup\n' > "$d/AGENTS.md"
printf -- 'placeholder\n' > "$d/bin/init-project.language.sh"
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

# C8 over ALL public docs: no third-party plugin names (pm-skills once lived in the beginners guide)
d="$(clean_root)"; printf -- 'Write a PRD with /pm-execution:create-prd.\n' > "$d/BEGINNERS-GUIDE.md"
check "C8 flags a third-party plugin in a public doc" 1 "$d"; rm -rf "$d"

# FINAL: the real repo must pass its own lint
check "the actual repo passes its own invariants" 0 "$TEST_DIR/.."

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
