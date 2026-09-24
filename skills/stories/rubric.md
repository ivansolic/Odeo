# User stories rubric

Scored by `pm-reviewer` (0-2 per criterion) over a story set (or a single story).
Record goes to `docs/evals/<USR-id or set>.md`.

```
1. Value slicing        0 technical layers disguised as stories ("build the database")
                        1 mostly user-facing value
                        2 every story delivers something a user can feel

2. Acceptance criteria  0 vague ("user-friendly", "works well")
                        1 mostly checkable
                        2 every criterion observable and binary (pass or fail,
                          no interpretation needed)

3. Size & independence  0 multi-week epics or heavily entangled stories
                        1 mostly right-sized
                        2 each story ~0.5-2 days, minimal coupling (INVEST)

4. Dependency order     0 no order
                        1 order stated but questionable
                        2 explicit build order that respects technical dependencies
                          (data model before the feature that uses it)

5. UI states coverage   (only for stories with UI; otherwise N/A and rescale)
                        0 happy path only
                        1 some states
                        2 loading/empty/error/success + focus/disabled folded into
                          the acceptance criteria, behavioral not visual

Threshold: total >= 8/10 (or >= 6/8 when criterion 5 is N/A) AND no criterion at 0.
```

Notes for the scorer:
- Quote the criterion or story line behind every score.
- A beautiful story set for the wrong feature still passes here, feature choice
  is `/odeo:prioritize` and `/odeo:critique` territory, not this rubric.
- **Coverage is a precondition, not a graded criterion.** Before scoring a set that
  decomposes a PRD, confirm every PRD requirement maps to at least one story (a
  traceability map); an uncovered requirement blocks the set regardless of score. Kept
  out of the score so the N/A rescale stays clean.
