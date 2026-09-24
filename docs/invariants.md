# System invariants (mechanically enforced by bin/skills-lint.sh)

Rules the system's own files must obey, checked by a script, not by memory.
Every invariant here was born from a real bug that reached a dogfood test;
the lint moves the catch from "test day" to "commit time". Run:
`bin/skills-lint.sh` (exit 0 = clean; exit 1 prints every violation).

| ID | Invariant | Born from |
|----|-----------|-----------|
| C1 | Every model-invocable skill (no `disable-model-invocation: true`) contains "Use when" in its description | F1, routing lost to a third-party plugin |
| C2 | Any skill that names a tunnel TOOL (cloudflared/ngrok/localtunnel) owns the exposure lifecycle (contains "stop sharing" or "teardown") | S1, tunnel left running after the test |
| C3 | Skills that produce human-readable spec documents (`prd`, `stories`, `critique`, `research` when it exists) reference the editor-open rule (`code -r` / `code --add`) | P1, docs unreadable in raw terminal markdown |
| C4 | A file that says "Mode A" also says "with me"; "Mode B" also says "for me" (per file) | naming drift after the mode rename |
| C5 | Every script referenced in `skills/`, `agents/`, `AGENTS.md` or `global/CLAUDE.md` resolves, in TWO name classes: a `<name>.test.sh` reference must exist under `tests/`, and every other `<name>.sh` reference must exist in `bin/` or at the repo root. Stated as two classes and NOT as "a test reference is not read as `test.sh`", because that wording would describe a check that skips test files entirely, which is a gap and not an exception | dead references after renames, and after a rename of a script named only in AGENTS.md, which sixteen surfaces read by reference (2026-08-13) |
| C6 | Every reviewer agent carries the single-verdict contract ("Only you" + `## History`) | F2, the eval hand-edit incident |
| C7 | No em/en dashes anywhere in skills/, agents/, AGENTS.md, global baseline | the standing style rule, now enforced |
| C8 | No person credits in skills/, agents/, system map, global baseline; no third-party plugin names (the `PLUGINS` list in `bin/skills-lint.sh`) in ANY published text (the same set C14 scans) | attribution policy; the plugin half widened after a third-party PM plugin's commands survived in the beginners guide, outside the old scope (2026-09-24) |
| C9 | Every SKILL.md has a non-empty `description:` frontmatter line | plugin listing sanity |
| C10 | Each `second-opinion-*` skill references `docs/second-opinion-protocol.md`, and no vendor name (codex/gemini/...) appears in a skill folder or command name | vendor is an argument, never a name; the shared mechanism is referenced, never restated |
| C11 | No version-pinned model ids in skills/agents (tier words only; the harness resolves versions); builder's `model:` is `sonnet` or `inherit`. Checks the FILE DEFAULT only, never the model a run was dispatched on, which is the human's per-run choice recorded in the plan | a stale versioned model name was quoted in conversation after its successor had shipped (2026-07-17) |
| C12 | Every agent definition (a file in `agents/` with a `name:` frontmatter) declares `effort:` from low\|medium\|high\|xhigh\|max | a dispatched role's reasoning depth must be declared, not left to the ambient session (2026-07-24) |
| C13 | The five prose-generating skills (`prd`, `stories`, `critique`, `research`, `product-signal`), `skills/build/SKILL.md`, and every agent definition carry the output-language rule: BOTH the literal token `output_language` AND the literal pointer `Guardrails 7`. A listed file absent from the scanned root is skipped. Honest limit: two greps prove marker-plus-pointer, never MEANING, so a bullet that is present, points correctly and says the wrong thing is a reviewer's catch, not the lint's | the rule is prose, so nothing but a grep can tell that a new generating skill shipped without it; the pointer half exists so a local RESTATEMENT of the guardrail cannot pass as a reference to it (USR-005, 2026-08-12) |
| C14 | No bare `/<skill>` for an Odeo skill in published text: the public docs, skills, agents, project templates (md, json), the plugin manifests (their text is the enable dialog and `/config`), the GitHub templates, the path lists, and hook and script messages. It must read `/odeo:<skill>`. Skill names come from `skills/`, so a new skill is covered without editing the lint. A path, URL or `~/` path is not a command: the start boundary excludes letters, digits and `. : / ~ } -`. Honest limit: text outside that set (tests, internal records, a file type not listed) is not scanned | Claude Code namespaces plugin skills, so the new-project command is not typeable without its prefix in a plugin install; the README published with 0.2.0 said to type it (found by the human in a fresh session, 2026-09-24) |

Maintenance: when a new rule class appears (a bug that a grep could have
caught), add the invariant HERE, the check to `bin/skills-lint.sh`, and a test
to `tests/skills-lint.test.sh`, in that order (doc -> RED -> GREEN).
