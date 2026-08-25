---
artifact: docs-output-language
type: code
branch: docs/output-language-docs
reviewed_commit: cd06103
previous_total: 11/12
artifact_version: 2
date: 2026-08-25
scorer: code-reviewer
model: claude-opus-4-8
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
---

# Code review, output-language docs (four guides)

Re-anchor of `docs/output-language-docs` at cd06103. Delta `eafc973..cd06103` is one
commit touching exactly two files, README.md and WORKFLOW.md, each a one-line reword
that applies the single Important fix from v1 (enforcement over-attribution). INSTALL.md
and BEGINNERS-GUIDE.md are byte-identical to eafc973 (`git diff eafc973..cd06103 --
INSTALL.md BEGINNERS-GUIDE.md` is empty). The only non-evals change since eafc973 is
these two files. This is a re-anchor confirming the enforcement-attribution fix, not a
fresh full review; the v1 factual verification of every other claim still stands.

## Verdict
APPROVE. Nothing blocks merge. The one Important from v1 is closed and nothing new broke.

## What the fix changed (verified against AGENTS.md [E]/[I] split)
- README.md:127 now reads: "Code and every machine-read surface stay English:
  filenames, branch names, and commit type/scope by a deterministic guardrail, commit
  subjects and code identifiers by instruction and review." This matches the authoritative
  split: `language-guard.sh` [E] refuses non-ASCII/non-slug filenames, directory names,
  frontmatter field names, branch names and commit scopes, plus commit types outside the
  eight (AGENTS.md:375-378); commit SUBJECTS (`feat(anmeldung)` passes, AGENTS.md:379) and
  code IDENTIFIERS are [I] "English by instruction, caught by review, not by a script"
  (AGENTS.md:380-381, 401). The two examples previously mis-credited to the guard (commit
  subjects, identifiers) are now correctly on the instruction+review side. No residual
  over-attribution: every surface is now on the correct side of the [E]/[I] line.
- WORKFLOW.md:791 now reads "code, commits and filenames stay English, the prose check is
  advisory and never blocks", with "by enforcement" removed. It states the outcome as
  policy, the framing v1 called accurate in INSTALL/BEGINNERS. Correct.

## Cross-doc consistency (still holds)
- All four docs still agree on the boundary: prose follows the setting, machine surfaces
  stay English, the prose check is advisory. README now carries the precise mechanism
  split; WORKFLOW/INSTALL/BEGINNERS state the outcome as policy. No doc contradicts
  another, and the fix introduced no new inaccuracy.

## Scores
correctness 2/2 (README.md:127 mechanism attribution now matches AGENTS.md [E]/[I];
WORKFLOW.md:791 nitpick also resolved) · security 2/2 · performance 2/2 · readability 2/2
· testing 2/2 · conventions 2/2 -> total 12/12 (threshold >=9, no zero: PASS)

## Ceiling
12/12, reached. The v1 cap (README mechanism over-attribution) is removed.

## What's good
- The fix is surgical: two one-line rewords, no scope creep, and it distinguishes the
  deterministic guard's actual coverage from the instruction-and-review surfaces exactly
  as AGENTS.md defines them.
- Every claim in the branch still traces to real code; the boundary reads consistently
  across all four guides.

## History
- v1 (eafc973): first review. One Important accuracy finding (README.md:127 enforcement
  over-attribution), one matching nitpick (WORKFLOW.md:791), no Criticals. 11/12.
  APPROVE WITH COMMENTS.
- v2 (cd06103): re-anchor. Both the Important and the nitpick are fixed by the one new
  commit; README/WORKFLOW now match the AGENTS.md [E]/[I] split. Correctness 1 -> 2,
  total 11 -> 12. Regression note vs v1: BETTER. APPROVE.
