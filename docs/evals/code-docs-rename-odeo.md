---
artifact: docs-rename-odeo
type: code
branch: docs/rename-odeo-and-readme
reviewed_commit: 9802526
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

## Scope reviewed

`9802526` (`docs: follow the GitHub rename to Odeo, and fix three claims review
caught`), the delta `8c85a3e..9802526`, 17 files, +192/-38. Provenance:
ORCHESTRATING SESSION, not an isolated builder, so `build_model_as_dispatched:`
is omitted by design.

Verified `git rev-parse --short HEAD` == `9802526` myself. Working tree clean and
bit-identical to the `9802526` blobs before and after this review; all execution
was done against a `git archive` export in `/tmp/odeo-verify` with `HOME`
redirected, so nothing ran against the repo.

Evidence gathered this round: live `git ls-remote` + GitHub API against three
repo names, 26/26 suites GREEN with **exactly 818** assertions re-counted from a
real run, `bin/skills-lint.sh` 40/40, `publish-snapshot.sh` + `publish-guard
--require-allowlist` on the materialized tree, `python3 json.load` on
`plugin.json`.

## Claim verification

**The GitHub rename is REAL, and the new URL is the correct one.** This
supersedes the previous record's conclusion (see History).
- `git ls-remote https://github.com/ivansolic/Odeo.git` resolves;
  `HEAD == refs/heads/main == 1955085`.
- `gh api repos/ivansolic/claude-cofounder` returns
  `full_name: ivansolic/Odeo`, i.e. the old name is now only a redirect.
- `gh api users/ivansolic/repos` lists exactly one public repo: `Odeo`.
  `ivansolic/Odeo-private` exists and is private.
- Local remotes already point at the new names (`origin` -> `Odeo.git`,
  `backup` -> `Odeo-private.git`).

**Clone URL and the `cd` line agree with the live remote.**
`README.md:183` and `INSTALL.md:123` both say
`git clone https://github.com/ivansolic/Odeo.git`; `README.md:184` and
`INSTALL.md:124` both say `cd Odeo`, which is exactly the directory `git clone`
creates from that URL.

**Writer/reader path agreement, verified exhaustively.** `install.sh:69-76`
writes `~/.claude/odeo-docs/` (+ `/checklists`) and `install.sh:109,111` writes
`~/.claude/odeo-baseline.md`. Every reader was moved in the same commit:
`agents/architect.md:34`, `agents/skill-reviewer.md:20`,
`agents/pm-reviewer.md:39`, `skills/guide/SKILL.md:14`,
`skills/start/SKILL.md:16`, plus two the brief did not name,
`docs/checklists/language-live-check.md:27,99`, and the user-facing
`INSTALL.md:141`. `git grep "cofounder-docs\|cofounder-baseline"` outside the
denylisted archives returns **zero** hits. The silent-degradation risk the brief
flagged (readers fall back to the repo-local copy, so a mismatch would fail only
in a user project) does not exist at this head.

**Tree alignment preserved.** `INSTALL.md:250` is
`│   └── Odeo/                  ← the cloned repo ...`: `Odeo/` + 18 spaces = 23
columns, exactly what `claude-cofounder/` + 6 spaces occupied. The mangled
`└── Odeo/← the cloned repo` is gone. `README.md:49` is the tree root, no
alignment to hold. Column-scanning every `←` in the README tree puts all three
new/changed lines (`:93`, `:96`, `:129`) at column 30, matching the block; the
only outliers (`:76`, `:87`, `:111`, `:112`, `:135`) are pre-existing long-name
lines. The two new continuation lines (`:104`, `:130`) align under their parent
text.

**`plugin.json` valid.** `python3 -c "json.load(...)"` parses; `name: odeo`,
`homepage` and `repository` both `https://github.com/ivansolic/Odeo`.

**Important 1 (bin count), CLOSED and exact.** `find bin -maxdepth 1 -type f
-perm -u+x | wc -l` == **22**, and `find bin -maxdepth 1 -type f | wc -l` == 22
too, so "22 executables" is right and there are no non-executable strays.
`README.md:96` now lists `token-report.py` and correctly calls it "the one
non-bash tool here" (21 `.sh` + 1 `.py`).

**Important 2 (tests line), CLOSED and exact.** Ran all 26 suites from a clean
export and counted emitted `ok:`/`FAIL:` lines: 813 + `line-endings.test.sh`,
which needs a real work tree and yields 5 there, = **exactly 818**, all green.
The new shape claim also checks out arithmetically: 20 suites are named after a
`bin/` script, `init-project.language.test.sh` covers a 21st, leaving **five**
cross-cutting (`global-default-inherit`, `language-allowlist-agreement`,
`language-change-anytime`, `line-endings`, `localized-prose`) and
`session-end-check.sh` as the one guard with no suite of its own. 21 + 5 = 26
suites; 21 + 1 = 22 executables. Both halves of the sentence are true.

**Important 3 (stale brand in a scaffolded template), CLOSED.**
`project-templates/design/README.md:36` now reads "Odeo consumes the file you
give it".

**Nitpick 4 (skills-lint scope), CLOSED and accurate.** `README.md:103-104` now
claims skills, agents, AGENTS.md, the global baseline and the system map;
`bin/skills-lint.sh` reads all five (`:47`, `:67`, `:93`, `:101`, `:105`,
`:116`).

**Nitpick 6 (` , ` artifacts), the two named sites are CLOSED and the two
deliberate keeps are CORRECTLY reasoned.** `project-templates/CLAUDE.md:79,80`
and `bin/coverage-check.sh:1,56` are fixed. The brief's reasoning holds:
`bin/coverage-check.sh:23` must keep its ` , ` because it quotes the literal
list-item form the parser tolerates (`"- **R1 , ..."`), and that form is what
`/prd` actually emits (see `docs/prds/PRD-001-output-language.md:92-119`, every
requirement written `- **R1 , resolution...`). The parser regex
`^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]+` accepts both spellings, so the comment
is documentation of tolerance, not a live dependency. Same for the
`- **R1 , alpha.**` fixtures in `tests/coverage-check.test.sh:22-24`: they are
test INPUT pinning that tolerance, and normalizing them would delete the
coverage. You did not get it backwards.

**Product-name sweep.** `git grep -i cofounder` outside `docs/evals` and
`docs/plans` returns exactly three hits, all in Findings 1 and the note below.
Zero occurrences of "Claude Cofounder" anywhere that ships. The materialized
snapshot confirms it: only `.gitignore:16,25` and
`.github/ISSUE_TEMPLATE/config.yml:4`.

**No PII in the shipping snapshot.** `grep -rniE "ivan\.solic|movec|/Users/ivan"`
over `/tmp/odeo-snap` returns nothing.

## Findings

### Important

1. `.github/ISSUE_TEMPLATE/config.yml:4`, the "Question or idea (discussion)"
   contact link still points at `https://github.com/ivansolic/claude-cofounder/discussions`
   and it leads to a **404**. Two independent problems stacked in one line: the
   repo name is stale (it 301-redirects to `.../Odeo/discussions`, so the name
   alone would survive), and `gh api repos/ivansolic/Odeo` reports
   `has_discussions: false`, so the destination does not exist either way. This
   file SHIPS (present in the verified snapshot) and GitHub renders it in the
   issue chooser, so it is the first thing a public visitor filing an issue sees
   on day one. Fix: enable Discussions on `ivansolic/Odeo` and change the URL to
   `https://github.com/ivansolic/Odeo/discussions`; if Discussions stays off,
   delete the `contact_links` block instead of pointing at a dead page.

2. `install.sh:81`, the bin install loop globs `"$REPO_DIR"/bin/*.sh`, so
   `bin/token-report.py` is **never copied to `~/bin/`**, while
   `install.sh:78`'s own comment claims it installs "all of `bin/`". The commit
   made this mismatch reader-visible rather than creating it: `README.md:93,96`
   now advertise "22 executables" including `token-report.py`, and
   `docs/system-map.md:144` lists it under "Utility scripts (in `bin/`, **run
   directly**)" next to `publish-snapshot.sh`, which IS installed. A user who
   follows the public docs and types `token-report.py` after install gets
   "command not found", silently, forever. Fix: install every executable regular
   file, `for script in "$REPO_DIR"/bin/*; do [[ -f "$script" && -x "$script" ]]
   || continue; ...` (keeps the existing `place` + `chmod`), which makes the
   "all of bin/" comment true and matches the README's new count. If the `.py`
   is deliberately repo-only, say so in `system-map.md` instead, but then
   `README.md:93` should not count it as an installed executable.

### Nitpicks

3. `README.md:131-141`, the `docs/` block still omits `docs/examples/` (carried
   over unaddressed from the previous round). It is on the publish allowlist
   (`docs/public-paths.txt:41`) and IS present in the verified snapshot
   (`docs/examples/prototype-findings-example.md`), so the only public `docs/`
   entry missing from an otherwise exhaustive list is one that actually ships.
   Fix: add `├── examples/              ← worked examples (e.g. prototype findings)`.

4. The ` , ` sweep is now three-quarters done and the remainder is the same
   class: `bin/language-guard.sh:2`, `bin/prose-language-check.sh:2`,
   `bin/skills-lint.sh:133,134`, and `docs/plan-format.md:104` all ship and all
   carry it. `tests/coverage-check.test.sh:2` is now a specific oddity: its
   header comment still mirrors the OLD text of `bin/coverage-check.sh:1`, which
   this commit fixed, so the pair visibly diverges. Fix: one more pass over those
   five header comments (leave `bin/coverage-check.sh:23` and the
   `tests/coverage-check.test.sh:22-24` fixtures alone, per the reasoning above).
   `docs/prds/` and `docs/research/` are denylisted, so their many occurrences
   are irrelevant to the publish.

5. `install.sh:150`, the community-knowledge default is now
   `https://github.com/ivansolic/Odeo-knowledge.git`. Verified: that repo does
   **not** exist, but neither did `claude-cofounder-knowledge`, and
   `install.sh:158-164` handles the clone failure gracefully ("not reachable
   yet, skipped"). So this is not a regression, it is a forward commitment: when
   the repo is created it must be named exactly `Odeo-knowledge`, or this line
   and `skills/contribute-lesson/SKILL.md:54` both go stale together.

6. `agents/architect.md:34`, `agents/skill-reviewer.md:20`,
   `skills/guide/SKILL.md:14`, `skills/start/SKILL.md:16` and
   `bin/init-project.sh:7` were left unreflowed after the shorter name went in,
   producing visibly short lines mid-paragraph. Cosmetic, zero behavioral
   impact, mentioned only so nobody mistakes it for a truncation.

## Verified correct, do NOT "fix"

`.gitignore:16,25` reference "the private `claude-cofounder-personal` repo".
That looks like a missed rename, and it is not:
`gh api repos/ivansolic/claude-cofounder-personal` resolves with that exact
`full_name` (no redirect), while `Odeo-personal` 404s. The comment is
factually accurate today. The only judgment call is that this comment publicly
names a private repo; if that bothers you, generalize the wording rather than
renaming the repo to match a comment.

## One thing you need to know (CORRECTED)

The previous record (v1, at `8c85a3e`) reported a mid-review working-tree
mutation by an unknown writer and concluded it "would have broken the clone URL
and every installed path", i.e. a latent Critical. **Both halves of that
conclusion are now known to be wrong, and the record is corrected here so no
false Critical survives on this file.**

- The writer was the ORCHESTRATING SESSION, editing the same files under
  review. Not an unknown tool, not a corrupted repo. Nothing committed was ever
  at risk, and `git restore .` cost nothing but the session's own in-flight work.
- The edit was not a break. While that review was running, the human renamed
  both GitHub repos; `ivansolic/Odeo` and `ivansolic/Odeo-private` are the live
  names, independently confirmed above by `git ls-remote` and the GitHub API.
  The premise the v1 review reasoned from (repo still named `claude-cofounder`)
  was true when it was dispatched and false by the time it concluded. The
  rename in the tree is the CORRECT state.
- The one real defect v1 caught in that edit, the mangled tree line
  `│   └── Odeo/← the cloned repo`, was genuine and is fixed at
  `INSTALL.md:250`.

The transferable lesson is about method, not about this repo: a review's
conclusions are only as good as the world-state premises it was handed, and a
premise about an external system (a remote's name) must be re-verified against
that system, not inherited from the dispatch brief. That is why this round
called `git ls-remote` and the GitHub API instead of trusting the correction it
was given.

Separately: the brief for this round stated the record is untracked. It is not.
`docs/evals/code-docs-rename-odeo.md` was committed as part of `9802526`
(`git ls-files --error-unmatch` confirms). This regeneration therefore shows up
as a tracked modification, not an untracked file. Harmless for the publish
(`docs/evals/` is denylisted and verified stripped), but the working assumption
was wrong and you should know before the next `git add`.

## Regression note

**Same, 11/12** (v1 11/12 -> v2 11/12), but the composition changed and the
quality of the code went up, not sideways. Per dimension: correctness 1 -> 1,
everything else 2 -> 2. All three v1 Importants and two of three v1 nitpicks are
genuinely closed, verified by re-derivation rather than by reading the commit
message. Correctness stays at 1 because two NEW Importants surfaced once the
docs became accurate enough to be checked against behavior: the dead Discussions
link (`config.yml:4`) and the `token-report.py` install gap (`install.sh:81`),
the latter created precisely by the honest new "22 executables" claim. This is
the healthy pattern, a more accurate document exposes a real inconsistency in
the system it describes. One v1 nitpick (`docs/examples/`) is carried forward
unaddressed.

## Publishing assessment

**Nothing blocks publishing to a public repo.** The publish path is sound at
this head, re-verified end to end rather than assumed:
`bin/publish-snapshot.sh /tmp/odeo-snap` materialized tracked HEAD, stripped the
denylist, and passed `publish-guard --require-allowlist` with **no unclassified
and no internal path**, exiting 3 (advisory privacy findings only, all of them
files that document the patterns they match: `bin/secret-scan.sh`,
`docs/privacy-guard.md`, the guard test suites, and so on). Confirmed absent
from the snapshot: `docs/evals/`, `docs/plans/`, `knowledge/`, `.claude/`,
`docs/prds/`, `docs/stories/`, `docs/research/`, `docs/decisions/`. Confirmed
absent from the snapshot content: every form of Ivan's name, employer, and local
paths.

Both Importants are degradations, not breakage: the install works, the clone URL
is live, the paths line up. But Finding 1 is a broken link on the repo's own
issue-filing page and takes under a minute to fix, so fix it BEFORE the push
rather than as a follow-up commit on a public repo.

## What's good

The count claims in this README are now the rare kind that survive an
adversarial re-derivation: 22 and 818 are both exactly right, and 818 in
particular cannot be guessed or statically approximated (a static call-site
count gives 77), so it can only have come from a real run. The tests line went
further than the finding demanded, replacing a false bijection with the actual
shape (five cross-cutting suites, one uncovered guard) that arithmetically
reconciles 26 suites against 22 executables. The path rename moved the writer
and all seven readers in one commit, which is what keeps a silently-degrading
mismatch from existing at all. And the `- **R<n>` comma keeps were reasoned
correctly under pressure to normalize everything: leaving a "wrong-looking"
string in place because it is load-bearing documentation of parser tolerance is
the harder and better call.

## History

- **v1, `8c85a3e`, 2026-09-15, APPROVE WITH COMMENTS, 11/12.** First record for
  this branch. Verified the product-name rename left every URL and path
  byte-identical to `main`, re-derived 818 assertions, confirmed the WORKFLOW
  command table. Three Importants: stale "Cofounder" in
  `project-templates/design/README.md:36`; `bin/` undercounted as 21 scripts;
  `README.md:127` falsely claimed "one per guard script". Three nitpicks:
  skills-lint's understated scope, `docs/examples/` missing from the docs tree,
  and the surviving ` , ` artifacts. Also reported an unexplained mid-review
  working-tree mutation and judged the rename it contained to be a latent
  Critical, a conclusion this round corrects (see above).
- **v2, `9802526`, 2026-09-15, APPROVE WITH COMMENTS, 11/12.** All three v1
  Importants closed and re-verified by independent derivation; the GitHub rename
  confirmed legitimate against the live remote; the v1 "Environment warning"
  section replaced with the corrected account. Two new Importants (dead
  Discussions link, `token-report.py` not installed), one v1 nitpick carried
  forward.
