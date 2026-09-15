---
artifact: docs-rename-odeo
type: code
branch: docs/rename-odeo-and-readme
reviewed_commit: 8c85a3e
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 1
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: none
---

## Scope reviewed

`8c85a3e`, three commits on `docs/rename-odeo-and-readme` (`7287024` rename +
README tree, `7e28f87` WORKFLOW command table, `8c85a3e` punctuation), 20 files,
+84/-55. Provenance: ORCHESTRATING SESSION, not an isolated builder, so
`build_model_as_dispatched:` is omitted by design.

Verified `git rev-parse --short HEAD` == `8c85a3e` myself. This is a docs change
that makes factual claims about the repo's own contents, so every claim was
re-derived against the actual tree rather than read for plausibility.

Evidence gathered this review: 26/26 test suites GREEN, `bin/skills-lint.sh`
clean, `bash -n install.sh` clean, publish classification complete (no
unclassified path).

## Claim verification (the primary dimension)

**Rename, verified TRUE.**
- `git grep "Claude Cofounder"` returns 0 hits across the whole tracked tree.
- The 38 lowercase `claude-cofounder` occurrences (URLs and paths) are
  byte-identical to `main`: diffing the sorted per-file occurrence lists between
  `main` and HEAD is empty. Nothing in the rename touched a URL or a path.
- Clone URL intact: `README.md:180` and `INSTALL.md:123`,
  `git clone https://github.com/ivansolic/claude-cofounder.git`.
- Install paths consistent with what `install.sh` actually writes:
  `INSTALL.md:141` claims `~/.claude/claude-cofounder-baseline.md`, and
  `install.sh:109,111` writes exactly that; `~/.claude/claude-cofounder-docs/`
  at `install.sh:69-76` is unchanged.
- `bash -n install.sh` passes.

**"26 suites, ~818 assertions", verified TRUE and exact.** Re-derived
independently by running all 26 suites and counting emitted `ok` lines:
**exactly 818**, 26/26 green. The static call-site count is only 77, so the
number can only come from a real run; it reproduces. This is an honest claim and
a large correction of the previous false "31 assertions".

**bin/ and agents/ listings, verified.** All 21 `bin/*.sh` appear, and each
description matches that script's header comment. The sharpened
`merge-gate.sh` line ("EVERY review approves") is supported by
`bin/merge-gate.sh:8-9`. All 11 `agents/*.md` appear with accurate roles, and
`agent-rubric.md` is honestly labelled as a rubric rather than an agent.

**Six new WORKFLOW rows, verified.** All eight named skill directories exist and
each one-liner matches the skill's own `description:`. Two specific claims
checked because they are falsifiable: `/ci` "~2 minutes" is supported by
`skills/ci/SKILL.md:15` ("makes it exist in about two minutes"); the **PAID**,
opt-in claim is supported by `docs/second-opinion-protocol.md:4` ("a PAID
cross-model review") and `:25` ("Data leaves the machine and it costs money"),
plus `disable-model-invocation: true` on all four variants. Telling the user this
costs money is correct, not a scare.

**Punctuation commit, verified meaning-preserving.** `git diff -w 8c85a3e^
8c85a3e` is EMPTY, so the change is whitespace-only; the instrument was
positive-controlled against `7287024` first. Exactly 32 ` , ` artifacts removed,
0 remaining in `skills/` and `agents/`. The two occurrences inside code fences
(`skills/product-signal/SKILL.md:44`, `skills/start/SKILL.md:51`) are
illustrative output shapes, asserted by nothing in `tests/` or `bin/`. The one
real interaction risk, `bin/coverage-check.sh`'s requirement parser, is safe: its
regex `\*\*R[0-9]+` is tolerant of both spellings, and `skills/prd/SKILL.md` does
not carry an `- **R<n>` template line at all.

**Cross-doc consistency.** `BEGINNERS-GUIDE.md` and `ROADMAP.md` never name the
product (they say "the system"), so nothing contradicts the rename. The only
count claims in any published doc are the two README lines above.

## Findings

### Important

1. `project-templates/design/README.md:36`, the old product name survives:
   "Cofounder consumes the file you give it". `project-templates/` is on the
   publish allowlist (`docs/public-paths.txt`) AND this file is scaffolded into
   every new user project, so the stale brand ships twice over. Fix: "Odeo
   consumes the file you give it".

2. `README.md:93`, "21 scripts" undercounts `bin/`. The directory holds 22
   tracked executable scripts: 21 `.sh` plus `bin/token-report.py` (mode 755,
   tested by `tests/token-report.test.sh` at 16 assertions, documented in
   `docs/system-map.md`). It is the only bin entry absent from an otherwise
   exhaustive list. This is a NEW inaccuracy introduced by the commit whose
   stated purpose was completeness. Fix: say "22 scripts" and add a
   `token-report.py ← per-agent token/cost report for a session` row.

3. `README.md:127`, "one per guard script" is false in both directions.
   `bin/session-end-check.sh` has NO suite, and five suites are cross-cutting
   rather than per-script: `global-default-inherit`, `language-allowlist-agreement`,
   `language-change-anytime`, `line-endings`, `localized-prose`. Fix: drop the
   bijection and write "26 suites, ~818 assertions, covering the guard scripts
   plus cross-cutting behavior".

### Nitpicks

4. `README.md:102`, skills-lint is described as a gate "over skills/ and
   agents/", but `bin/skills-lint.sh:5-6` also covers `AGENTS.md`,
   `global/CLAUDE.md` and `docs/system-map.md`. Fix: "over skills/, agents/ and
   the baseline docs".

5. `README.md:128-138`, the `docs/` block omits `docs/examples/`, which is on the
   publish allowlist and therefore WILL exist in the published snapshot. Every
   other public docs entry is listed. Fix: add an `examples/` row.

6. The ` , ` artifact class was cleaned in `skills/` and `agents/` only and
   survives in published surfaces: `project-templates/CLAUDE.md:79,80` (scaffolded
   into every user project), `bin/coverage-check.sh:56` (a user-facing stdout
   string, `"coverage: $prd_id , all $count requirements covered"`), and five
   `bin/*.sh` header comments. Not a regression, but the same defect the commit
   set out to remove. The `- **R1 , alpha.**` forms in `tests/coverage-check.test.sh`
   should stay: they pin the parser's tolerance.

## Environment warning (not a defect in this branch)

Mid-review the working tree mutated with no write command from this session: 15
tracked files were rewritten to replace the lowercase `claude-cofounder` in URLs
and paths (`plugin.json` name -> `odeo`, clone URL ->
`https://github.com/ivansolic/Odeo.git`, `~/.claude/odeo-baseline.md`,
`~/.claude/odeo-docs/`, and a mangled tree line `│   └── Odeo/← the cloned repo`).
That is precisely the rename this branch deliberately did NOT do, and it would
have broken the clone URL and every installed path. Captured to
`/tmp/UNEXPECTED_MUTATION_1789460229.diff` and reverted with `git restore .`; it
has not recurred. Some other session or tool is writing to this repo. Confirm
nothing else is running against it before publishing.

## Regression note

First record for this branch, no previous version to compare.

## Publishing assessment

Nothing BLOCKS publication. The publish path is sound: every tracked path is
classified (no unclassified path under `--require-allowlist`), internal
artifacts (`docs/evals`, `docs/plans`, `knowledge/`, `.claude/`) are correctly
denylisted and would be stripped by `publish-snapshot.sh`. Findings 1 to 3 are
reader-visible falsehoods in the public README and the scaffolded templates, and
should be fixed before the public push, not after.
