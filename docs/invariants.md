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
| C5 | Every `*.sh` referenced in skills/agents exists in `bin/` (or repo root) | dead references after renames |
| C6 | Every reviewer agent carries the single-verdict contract ("Only you" + `## History`) | F2, the eval hand-edit incident |
| C7 | No em/en dashes anywhere in skills/, agents/, AGENTS.md, global baseline | the standing style rule, now enforced |
| C8 | No person credits and no third-party plugin names in skills/, agents/, system map, global baseline | attribution policy |
| C9 | Every SKILL.md has a non-empty `description:` frontmatter line | plugin listing sanity |

Maintenance: when a new rule class appears (a bug that a grep could have
caught), add the invariant HERE, the check to `bin/skills-lint.sh`, and a test
to `tests/skills-lint.test.sh`, in that order (doc -> RED -> GREEN).
