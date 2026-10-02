# Research rubric

Scored by `pm-reviewer` (0-2 per criterion) over one research report
(`docs/research/RES-NNN-<slug>.md`). Record goes to `docs/evals/<RES-id>.md`.

Definitions the criteria use. They are the ONE place these terms are defined: the research
skill points here instead of rewording them, so the two files cannot drift apart.
- **Claim:** any statement of fact in the report, including a cell or sentence marked
  unverified. Marking a claim "?" or "unverified" does not make it traced; it makes it honest.
- **Independent sources:** neither one derives from the other (two articles citing one
  press release are ONE source; two pages of the same vendor's documentation are ONE
  source). For a product's own behaviour, its documentation and its shipped code, binary or
  changelog count as two, when each states the claim itself; a changelog is a dated release
  record, wherever it is hosted.
- **Note:** a numbered entry under Findings naming one or more sources, each with its page or
  file and a quote or locator from the source's body (not a search-result snippet).
- **Traced:** a claim names at least one note a reader can find and check.
- **Scoped:** the question states its scope, region, segment and date sensitivity where they
  apply (the first four items of step 1 in the research skill).
- **Dated fact:** a fact that can change over time (a price, a limit, a version, a count).
- **Load-bearing claim:** a claim that the Answer or an Implication rests on.
- **Confidence words**, one per claim, written where the claim appears (an Answer clause
  may carry it by citing the Findings claim that does):
  - **Verified:** backed by two independent sources, counted PER CLAIM (a note that backs
    several claims verifies only those it gives two sources for).
  - **One source:** backed by exactly one source.
  - **Unverified:** backed by no source the report can name.
  - **Not verified** means one source or unverified; every not-verified claim, and every
    contested one, is listed in the Unverified section.

```
1. Question             0 no scoped question
                        1 scoped, but sub-questions, mode, depth or the decision it serves
                          are missing, or a key term in it is undefined
                        2 a scoped question, its sub-questions, mode, depth, the decision it
                          serves, and its key terms defined

2. Answer               0 missing, does not answer the question, or only lists what is
                          unknown without giving the best answer the evidence supports
                        1 answers, but a factual clause outruns the Findings (states as fact
                          what Findings mark not verified), skips part of the question, or
                          leads with jargon
                        2 plain language first, the best supported answer to every part of
                          the question, and every factual clause matches its Findings and
                          carries its confidence word, in the clause itself or in the
                          Findings claim it cites

3. Traceability         0 a load-bearing claim cannot be traced to any named source (sources
                          counted but not named count as not traced), or fewer than half of
                          all claims can
                        1 every load-bearing claim is traced, but other claims are not, or
                          sources are counted ("two sources") without being named
                        2 every claim, verified or not, names its source (page or file plus
                          a quote or locator), and verified claims name two independent ones

4. Dates and methods    0 no number or dated fact carries a data date, or an estimate is
                          passed as a measurement
                        1 access dates given, but some data dates, the version or commit of a
                          measured thing, or an estimate's method are missing
                        2 every number and dated fact carries its data date, every estimate
                          is labeled with its method, every local measurement names what it
                          measured and at which version or commit
                        (N/A only when the report contains no numbers and no dated facts;
                          then rescale)

5. Unverified labelling 0 no Unverified section, or a load-bearing not-verified or contested
                          claim presented as fact
                        1 an Unverified section exists, but some not-verified claims,
                          inferences or conflicts are missing from it, a conflict lacks its
                          values, or a label claims more than the evidence shows (an "upper
                          bound" the report never shows to be one)
                        2 every not-verified claim, inference and conflict is labeled where
                          it appears and listed under Unverified, conflicts with both
                          values, and each label is justified

6. Evidence fit         0 no source was read, or the evidence answers a different question than
                          the one asked
                        1 some findings use a stand-in the report does not justify (region
                          for language, one product for a market), some sub-question has no
                          findings, a cited source shows only a search snippet, or the
                          promised depth was not delivered
                        2 the evidence measures what the question asks, each sub-question
                          has findings, every cited source carries a quote or locator from
                          its body, and the promised depth was delivered

7. Implications         0 none, or they do not follow from the Findings
                        1 present, but one rests on not-verified evidence without saying so,
                          gives a recommendation without its reason, or there are more than
                          three bullets
                        2 at most three bullets, each follows from cited Findings, each gives
                          its reason, and any that rests on not-verified evidence says so

8. Sources list         0 missing, or no source was read
                        1 present, but not grouped, access dates, versions or the pages
                          actually used are incomplete, or it does not say what it leaves out
                        2 grouped, every page actually used listed with its access date and
                          its version where the source has one, and one line saying what the
                          search did not cover (regions, paywalls, languages, blocked or lost
                          pages)

A criterion that meets none of its 0 conditions and misses any of its 2 conditions scores 1.

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
