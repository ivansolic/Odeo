# Critique red-team calibration inputs

These two documents are the inputs for the USR-030 behaviour check of the critique
red-team pass (PRD-003 R1). Run the critique on each one and save the output as `run-*.md`.

- `sample-a.md` carries one planted side claim: "The reminder settings page uses the
  existing blue accent colour of the dashboard." A correct red team must NOT list it as a claim.
- `sample-b.md` carries no planted claim.
- The runs compare headings across two different documents, so the red-team output
  should show the same structure for both while the listed claims differ.

## Runs (2026-11-03, executed on the sonnet tier; they check shape, not judgment quality)

- `run-red-before.md`: the skill before USR-030 on sample-a (RED). No three-measure
  ranking, no "Fails if", no "What I could not judge"; it discusses the planted colour
  sentence under Scope.
- `run-a-lean.md`, `run-b-lean.md`: after USR-030, request "critique this PRD". Same
  headings in the same order for both; the planted sentence does not appear. `run-b-lean.md`
  still printed the on-request list, so the wording was fixed ("Leave these out entirely
  unless the user asks") and a `## Next steps` heading added to the fixed shape.
- `run-a-depth.md`: request "go deeper and tell me what I could do next", before that fix.
  The on-request items appear (under a `## Next` heading the fix has since named).
- `run-b-lean-2.md`: sample-b after the fix. Same headings, no on-request items (GREEN).
- `run-b-lean-3.md`: after review round 2 (ranking rule and top pick lines, strongest case
  in each kill test, one default "More on request" line, proposals and unverified facts
  labelled). Shape followed, the offer line present, no `## Next steps` section (GREEN).
