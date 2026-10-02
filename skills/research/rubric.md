# Research rubric

Scored by `pm-reviewer` (0-2 per criterion) over one research report
(`docs/research/RES-NNN-<slug>.md`). Record goes to `docs/evals/<RES-id>.md`.

Definitions the criteria use:
- **Claim:** any statement of fact in the report, including a cell or sentence marked
  unverified. Marking a claim "?" or "unverified" does not make it traced; it makes it honest.
- **Independent sources:** neither one derives from the other (two articles citing one
  press release are ONE source; two pages of the same vendor's documentation are ONE
  source). For a product's own behaviour, its documentation and its shipped code, binary or
  changelog count as two, when each states the claim itself.
- **Load-bearing claim:** a claim that the Answer or an Implication rests on.
- **Verified:** a claim backed by two independent sources, counted PER CLAIM. A note that
  backs several claims verifies only those it gives two sources for.

```
1. Question             0 no scoped question
                        1 scoped, but sub-questions, mode, depth or the decision it serves
                          are missing, or a key term in it is undefined
                        2 a scoped question, its sub-questions, mode, depth, the decision it
                          serves, and its key terms defined

2. Answer               0 missing, does not answer the question, or only lists what is
                          unknown without giving the best answer the evidence supports
                        1 answers, but a factual clause outruns the Findings (states as fact
                          what Findings mark unverified), skips part of the question, or
                          leads with jargon
                        2 plain language first, the best supported answer to every part of
                          the question, and every factual clause matches its Findings, with
                          its confidence (verified, one source, unverified) said in words or
                          by citing a note that carries that label

3. Traceability         0 a load-bearing claim cannot be traced to any named source, or fewer
                          than half of all claims can
                        1 every load-bearing claim is traced, but other claims are not, or
                          sources are counted ("two sources") without being named
                        2 every claim, verified or not, names its source (page or file plus
                          a quote or locator), and verified claims name two independent ones

4. Dates and methods    0 numbers or dated facts without dates, estimates passed as
                          measurements
                        1 access dates given, but some data dates, the version or commit of a
                          measured thing, or an estimate's method are missing
                        2 every number and dated fact carries its data date, every estimate
                          is labelled with its method, every local measurement names what it
                          measured and at which version or commit
                        (N/A only when the report contains no numbers and no dated facts;
                          then rescale)

5. Unverified labelling 0 no Unverified section, or a load-bearing one-source or contested
                          claim presented as fact
                        1 an Unverified section exists, but some one-source claims,
                          inferences or conflicts are missing from it, a conflict lacks its
                          values, or a label points the wrong way (an "upper bound" that the
                          report never shows is one)
                        2 every one-source claim, inference and conflict is labelled where it
                          appears and listed under Unverified, conflicts with both values,
                          and each label is justified

6. Evidence fit         0 no source was read, or the evidence answers a different question than
                          the one asked
                        1 some findings use a stand-in the report does not justify (region
                          for language, one product for a market), some sub-question has no
                          findings, or sources were read only as search snippets
                        2 the evidence measures what the question asks, each sub-question
                          has findings, sources were read in full, and the promised depth
                          was delivered

7. Implications         0 none, or they do not follow from the Findings
                        1 present, but one rests on unverified evidence without saying so,
                          gives a recommendation without its reason, or there are more than
                          three bullets
                        2 at most three bullets, each follows from cited Findings, each gives
                          its reason, and any that rests on unverified evidence says so

8. Sources list         0 missing, or no source was read
                        1 present, but access dates, versions or the pages actually used are
                          incomplete, or it does not say what it leaves out
                        2 grouped, with access dates and versions, and one line saying what
                          the search did not cover (regions, paywalls, languages, lost notes)

Threshold: total >= 13/16 AND no criterion at 0 AND Answer (criterion 2) = 2.
With criterion 4 N/A: total >= 11/14 AND the same two conditions.
```

Notes for the scorer:
- Quote the line behind every score.
- Count claims for criterion 3 by listing the load-bearing ones first (the Answer's and the
  Implications' factual clauses), then estimating the share of all claims that are traced.
- A "decide later" Implication with no cited finding scores 1 on criterion 7.
- Criterion 1: mode and depth may be stated in the frontmatter; a key term counts as defined
  when the report states what it means in this report (an inline gloss is enough).
- The Answer condition exists because a report that labels everything correctly but
  answers nothing would otherwise pass on its other criteria.
- Judge the evidence the report shows, never the world: without web access, do not call a
  source current or outdated; list the claims a human should re-check before relying on them.
- A conflict is reported as a conflict, never averaged; averaging it is a 0 on criterion 5.
- Mode rules from the skill apply: market-size needs ranges from two methods (criterion 4),
  competitors need a feature table only where sources support it (criterion 3).
