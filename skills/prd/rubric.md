# PRD rubric

Scored by `pm-reviewer` (0-2 per criterion). Used as a quality gate, for
regression checks (better than the previous version?), and for blind scoring in
subagent tests. Record goes to `docs/evals/<PRD-id>.md`.

```
1. Problem clarity      0 vague or missing
                        1 stated (who + pain)
                        2 evidence-backed: who hurts, how much, why now, source cited
                          or explicitly tagged as assumption

2. Measurable outcome   0 none, or a feature dressed as an outcome ("ship login")
                        1 outcome stated but not measurable
                        2 a user outcome with metric + target ("regain access in
                          under 60s without support")

3. Scope discipline     0 wishlist, no cuts
                        1 scoped but fuzzy edges
                        2 thin slice that tests the outcome + explicit non-goals

4. Risks & assumptions  0 absent
                        1 listed
                        2 riskiest assumption named + "how we'd know we're wrong"

5. Security & data      (only if the feature touches auth, PII, payments, uploads,
                         or anything private; otherwise mark N/A and rescale)
                        0 ignored
                        1 mentioned
                        2 security pre-mortem done, answers captured as requirements

Threshold: total >= 8/10 (or >= 6/8 when criterion 5 is N/A) AND no criterion at 0.
```

Notes for the scorer:
- Score the document, not the idea. A well-specified bad idea passes the rubric
  and dies in `/odeo:critique`, that is the correct division of labor.
- Quote the line that earned or lost each point. No unexplained scores.
