# Eval framework

How this system measures quality, proves improvement, and prevents regressions.
One shared model for every artifact type: code, UI, PM documents, and skills.

## What an eval is
An eval is a systematic, repeatable way to SCORE the quality of an output and to
tell whether a change made things better or worse. It is the "proof" step of every
loop: nothing passes a gate on good vibes.

## The shared model (five parts, same everywhere)

```
RUBRIC (data)          what "good" means: named criteria + levels + a pass threshold
   |  used by
SCORER (who judges)    deterministic script | reviewer agent (LLM judge) | human
   |  writes
EVAL RECORD (file)     scores per criterion + findings + verdict + version + date
   |  saved in git
BASELINE / REGRESSION  compare the new record to the previous one: better or worse?
   |  feeds
FEEDBACK LOOP          repeated failures become lessons/knowledge or an /improve run
```

## Rubrics
- A rubric = named criteria, scoring levels (0 to 2 per criterion), and a pass
  threshold (for example: total >= 8/10 AND no criterion at 0).
- Rubrics are DATA, not agents. Each lives next to the skill that produces the
  artifact it judges: `skills/prd/rubric.md`, `skills/stories/rubric.md`.
  The skill rubric lives in `docs/skill-authoring-standard.md` (it judges skills
  themselves). Code and UI rubrics live inside `code-reviewer` and `design-reviewer`.
- Anyone can read a rubric and know exactly what the bar is. That is the point.

## Scorers (three kinds, they combine)
1. **Deterministic**, scripts and tests: test suite, lint, typecheck,
   `privacy-scan.sh`. Exit codes, no judgment. Strongest form.
2. **Reviewer agents (LLM judge)**, each owns one domain and scores against the
   domain rubric: `code-reviewer` (code), `design-reviewer` (UI), `pm-reviewer`
   (PM documents), `skill-reviewer` (skills). Independent from whoever produced
   the artifact, and they can score BLIND (they see artifacts, not who or what
  version made them), which is how subagent A/B tests stay honest.
3. **Human**, the final gate. Taste and context advantage; you approve or reject.

## Eval records
One small file per artifact in the project's `docs/evals/`, overwritten on each
new eval. Git history is the archive, so "compare to last time" = read the file,
then `git log`/`git show` for the previous version.

```markdown
docs/evals/PRD-007.md
---
artifact: PRD-007
type: prd
artifact_version: 3
date: 2026-07-07
scorer: pm-reviewer
scores: { problem: 2, outcome: 2, scope: 1, risks: 2, security: 2 }
total: 9/10
verdict: PASS          # threshold from the rubric
previous_total: 7/10   # regression check: improved
---
Findings: scope still lists two nice-to-haves without a cut line.
Change vs previous version: outcome criterion went 1 -> 2 (metric + target added).
```

Records are used for: gates (did it pass the threshold?), regression (better than
last time?), `/improve` signals (repeated drops on the same criterion), and blind
scoring in subagent tests.

## Rigor allocation (risk-based)
Testing effort is proportional to the risk of being wrong:
- **Content artifacts** (PRD, memo, stories): rubric scoring by the domain
  reviewer. Cheap, and mistakes are caught by later layers (critique, human gate).
- **Skill changes**: subagent A/B testing via `/improve`. Full rigor (5+
  repetitions per variant) is reserved for discipline-critical skills
  (guardrails, TDD, merge, privacy). The user can request full rigor on anything.
- **Code**: deterministic first (tests, lint), then `code-reviewer` scoring.

## Community sharing (opt-in)
Improved rubrics and eval learnings can be contributed to the community knowledge
base through `/contribute-lesson`, the same path as lessons: sanitize, privacy-scan
(hard gate), show exactly what leaves, your approval, maintainer curation. Nothing
is shared automatically.

## Honesty rules (apply to every scorer)
- Never fabricate scores or data. No evidence = say so, don't estimate.
- Score against the rubric, not against sympathy for the author (there is none,
  scoring is blind where possible).
- A verdict is always produced, and always explained per criterion.
