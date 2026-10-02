# Research rubric

Scored by `pm-reviewer` (0-2 per criterion) over one research report
(`docs/research/RES-NNN-<slug>.md`). Record goes to `docs/evals/<RES-id>.md`.

```
1. Question             0 vague or unscoped, no mode or depth
                        1 scoped, but sub-questions or the decision it serves are unclear
                        2 a scoped question, its sub-questions, mode and depth stated

2. Answer               0 missing, or it does not answer the question
                        1 answers, but a factual clause outruns the Findings (states as
                          fact what Findings mark unverified), skips part of the question,
                          or leads with jargon
                        2 plain language first, covers the whole question, and every
                          factual clause matches what Findings support

3. Traceability         0 claims with no sources
                        1 sources listed, but some claims cannot be traced to a named
                          source, or "two sources" are counted without being named
                        2 every claim in Findings can be traced to named sources (page or
                          file plus a quote or locator), and the two sources behind a
                          "verified" claim are independent

4. Dates and methods    0 numbers or facts without dates, estimates passed as measurements
                        1 access dates given, but some data dates, the version or commit of
                          a measured thing, or an estimate's method are missing
                        2 every number carries its data date and method, estimates are
                          labelled as such, and local measurements name what they measured

5. Unverified labelling 0 single-source or contested claims presented as facts
                        1 an Unverified section exists, but some one-source claims,
                          inferences or conflicts are missing from it, or a conflict lacks
                          its values
                        2 every one-source claim, inference and conflict is labelled where
                          it appears and listed under Unverified, conflicts with both values

6. Implications         0 none, or they do not follow from the Findings
                        1 present, but one rests on an unverified claim without saying so,
                          or gives a recommendation without its reason
                        2 at most three, each follows from cited Findings, each gives its
                          reason, and any that rests on unverified evidence says so

7. Sources list         0 missing
                        1 present, but access dates, versions or the pages actually used
                          are incomplete
                        2 grouped, with access dates and versions, and it says what it does
                          not cover

Threshold: total >= 12/14 AND no criterion at 0.
```

Notes for the scorer:
- Quote the line behind every score.
- A report full of correctly labelled "unverified" items still has to ANSWER the question:
  an Answer that only lists what is unknown scores at most 1 on criterion 2.
- Judge the evidence the report shows, never the world: without web access, do not call a
  source current or outdated; list the claims a human should re-check before relying on them.
- A conflict is reported as a conflict, never averaged; averaging it is a 0 on criterion 5.
