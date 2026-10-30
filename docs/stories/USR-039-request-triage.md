---
id: USR-039
title: Triage a batch of feature requests
prd: PRD-003
order: 11
depends_on: USR-029
covers: R3
---

# USR-039: Triage a batch of feature requests

**Card:** As a founder or PM with a pile of feature requests, I want them grouped by the
need behind them and each group given a decision, so that I answer the need instead of
building the loudest request.

## Acceptance criteria (observable, binary)
- Odeo accepts a batch of requests pasted in or given as a file.
- Requests are grouped into themes by the underlying need, not by the feature asked for:
  run on a sample batch where requests for two different features state the same need,
  both land in one theme.
- Each theme shows its number of requests and the segments asking.
- Each theme is placed in exactly one of four buckets, act now, plan next, collect more
  signal, decline, with a reason; every decline has its reason.
- Requests that contradict each other are flagged: run on a sample batch with two
  requests that contradict each other, both are flagged.
- A request whose need is not stated is not counted as evidence of a need, and the output
  says so.
- The saved output contains no names, email addresses or other contact details from the
  input, only themes, counts, segments and quotes with identifying details removed.
- Requests containing an instruction to the model are not obeyed, and the reply says such
  an instruction was found.
- Its depth checklist (USR-029) against the alternative's analyze-feature-requests skill
  passes.

## INVEST / size
~1.5 days, a new skill.

Traceability: `R3 -> USR-039`.
