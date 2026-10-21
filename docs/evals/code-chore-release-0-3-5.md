---
artifact: release-0.3.5
type: code
branch: chore/release-0.3.5
reviewed_commit: 91566d1
artifact_version: 1
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 10/12
verdict: APPROVE WITH COMMENTS
---

# Code review: chore/release-0.3.5, round 1

## Scope reviewed

- The release commit 91566d1. It changes `.claude-plugin/plugin.json:4` from 0.3.4 to 0.3.5
  and nothing else.
- The release contents, `git log dd566c2..91566d1`: 49 commits before the bump, in a straight
  line. dd566c2 is the 0.3.4 release record on local main.

origin is the public publication, a separate history, and was not compared.

## Checks

1. **Coverage.** Every non-eval commit is covered by an approving record. Each record is
   anchored at its branch's last code commit, or at a later commit that only adds records.
   There are four branches. The dispatcher listed three:
   - `docs/knowledge-stacked-squash` (5df0dbf, 84dde3e, e82c918): the dispatcher missed this
     one. Its record `docs/evals/code-docs-knowledge-stacked-squash.md` is anchored at
     e82c918, the last code commit (104e33c only adds the record). It approves with
     comments. Its files are all under `knowledge/`, which is internal.
   - `docs/res-002-platform-support` (9da1025 to 921f906): `docs/evals/RES-002.md` passes at
     921f906, the last report commit, with 16/16.
   - `chore/research-one-fact-rule` (246bcc9 to 57daa41):
     - The code record approves with comments at 57daa41, the last code commit.
     - The skill record passes at 16c6cc5, which only adds a record. SKILL.md last changed
       at 81877e4 and rubric.md at 9705c4e, both before 16c6cc5. The skill reviewer could
       not run the diff itself, so I checked its claim from the file lists: nothing under
       `skills/` moved between 81877e4 and 16c6cc5.
     - Neither artifact line names `bin/research-check.sh` (added in 25b2a85 and never
       changed) or the fixtures (added in 56ded01). They are inside the branch the code
       record reviewed across nine rounds, and I read both here.
   - `docs/knowledge-fail-closed-class` (06bbf15, 00541ba, 02494f8): its record approves at
     02494f8, with 12/12.

   No commit is uncovered.
2. **Bump type.** Patch is the right bump under CONTRIBUTING.md:42-45. Nothing a user
   depends on was moved or renamed:
   - `scripts/research-check.sh` is new. Only the research skill calls it (step 5b). No
     gate, hook or other script calls it, so a report that already exists is never checked
     against the new format.
   - The rubric is stricter. A Verified claim now needs both notes to quote the same fact,
     and criterion 1 has a new middle step. That changes how a new review is scored, not the
     structure. It is the same kind of change as the 0.3.4 plan criterion 6, which was a
     patch. Records that already pass keep their verdict, and spec-gate does not read
     research records.
   - The script needs `python3`, which `focus-check.sh` already needed. When python3 is
     missing it exits 2 ("did not run"), and the skill tells the agent to say so.
3. **Classification.** All 347 tracked paths at 91566d1 are classified: 231 public, 116
   internal, none unclassified. The eight new public paths are `bin/research-check.sh`,
   `scripts/research-check.sh`, `tests/research-check.test.sh` and five files under
   `tests/fixtures/research/`, so 223 + 8 = 231.
4. **Public surface.**
   - `tests/research-check.test.sh` reads nothing internal while it runs. It reads only
     `$ROOT/scripts/research-check.sh` and `$ROOT/tests/fixtures/research` (line 182), and
     the script reads only its arguments. The fixtures are synthetic ("Widget CLI"), with no
     PII and no local paths.
   - The worked example in `skills/research/SKILL.md` names RES-002 by ID. 0.3.4 already
     did that, and the quotes are from public vendor docs and a public repo, so nothing
     internal is linked.
   - Two comments do name an internal file, `docs/evals/RES-002.md`, which the public tree
     will not have. See Important 2.
5. **Counts.**
   - The quick `bash scripts/docs-claims-check.sh` passes with rc 0: 27 programs, 40
     suites, and 27 programs with their own suite.
   - I ran `tests/research-check.test.sh` alone: 145 ok, 0 FAIL, rc 0. It is the only
     suite in the range that changed, so 1426 + 145 = 1571, which matches README.md:242.
   - I did not run the full `--assertions` total. The coordinator will run it inside the
     snapshot.
   - The script line in README.md:216 matches the script.
   - The `/odeo:research` row in `docs/system-map.md:72` says "every claim 2+ independent
     sources or labeled unverified". That row predates this range and still roughly holds,
     because a claim labelled one source is also listed under Unverified.
6. **Dashes.** The added lines under README.md, scripts/, tests/, skills/, bin/ and
   .claude-plugin/ have no em or en dashes. The scan was checked first on a line that does
   contain one, and it found it.

## Findings

Critical: none.

Important
- `skills/research/SKILL.md:35` and `:75`: the quote check can pass on pages from another
  project.
  - **What:** each project numbers its own reports (step 5: the next number after its own
    highest `RES-` file). But the sources go to one shared folder per machine,
    `~/.cache/odeo/research/RES-NNN/`. So the first report in project A and the first in
    project B both save into `RES-001/`. An abandoned earlier attempt in the same project
    leaves its pages there too.
  - **Why it matters:** `read_sources` (`scripts/research-check.sh:264-288`) joins every
    file in the folder into one text, and `check_quotes` accepts a quote found anywhere in
    it. Measured on the public fixture: with `hooks.md` removed the check fails (rc 1,
    6/8 quotes). The same page copied under `from-another-project/page.md` makes it pass
    (rc 0, 8/8). So a quote that only appears in some other project's page is counted as
    verbatim in this one's source.
  - **Fix:** name the folder per project and require it to be new. For example
    `~/.cache/odeo/research/<repo top-level dir name>/RES-NNN/`, and if that folder
    already exists, empty it only with the human's OK, or stop and ask. Put a stale folder
    in the "Honest limits" list. This is a skill change, so it needs a skill-reviewer pass.
    It can go in a 0.3.6 fix branch rather than this release, because the reviewer still
    judges quotes and the failure only makes a heuristic check weaker.
- `scripts/research-check.sh:4` and `tests/research-check.test.sh:7`: two public files cite
  `(docs/evals/RES-002.md)`, an internal record that the public tree will not have. Round 1
  of 0.3.4 caught this same class in `docs/checklists/review-calibration.md`, as a
  nitpick. It is rated higher now because the class came back one release later, and
  nothing checks for it.
  - **Fix now:** delete the parenthetical in both comments. "the defects the RES-002
    review rounds found by hand" reads correctly on its own.
  - **Fix the class:** add a mechanism instead of a third reminder. For example, a test (or
    a `publish-guard.sh --require-allowlist` step) that takes every tracked internal FILE
    path and greps the public files for it as a literal. That catches
    `docs/evals/RES-002.md` but not the generic `docs/research/RES-NNN-<slug>.md` that the
    skills legitimately point users at. Plant one reference first and watch it go red.

Nitpicks
- `bin/research-check.sh:2-3`: the comment says the wrapper exists "so git hooks and
  ~/bin shims written by Odeo 0.2.x still find it". No 0.2.x caller can exist, because the
  program is new in 0.3.5. The real reason is that `tests/bin-wrappers.test.sh` requires
  bin/ and scripts/ to name the same programs. Fix: say that in the comment. Or exempt
  programs added after 0.2.x from that rule, so bin/ does not grow while
  `docs/public-paths.txt` says it is "removed in the next release".

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 1/2 -> total 10/12 (threshold: >=9, no zero). PASS.

## Ceiling

12/12 is reachable, and nothing in the change caps it. Two things block it:
- correctness: the shared sources folder (Important 1);
- conventions: the internal path in public comments, which came back (Important 2).

Removing the two parentheticals is a comment-only change, which needs this record
regenerated, not a new skill review. The cache-folder fix touches the skill and needs its
own reviewer.

The 1571 total adds the coordinator's earlier full-run figure, 1426, to the 145 this
reviewer counted. It is not a full snapshot run.

## Regression note

This is the first record for this branch. For context, the 0.3.4 release ended at 12/12
APPROVE.
