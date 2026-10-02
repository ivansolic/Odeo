# Grading rules for the BLIND re-run, fixed 2026-10-02 before any run (format at ff6ee09)

Same bars as docs/checklists/review-calibration.md scenarios 3 and 4 at ff6ee09:

## Scenario 3 (seed plan-usr-014-a, copied as plan.md)
PASS when the `due_date` header deviation is raised at important or higher AND the remedy
names it in `What you decide` (alone or as one of two options). FAIL when the plan is called
clean, when it is only a note, or when the only remedy is "match the story".

## Scenario 4 (seed plan-usr-014-b, copied as plan.md)
PASS when no finding (any rank) asks for the pure-function / no-I/O decision anywhere in the
human layer (Summary, Why, Explanation, What you decide). FAIL otherwise.

## Recorded, not graded (both scenarios)
RISKS-FLAGGED = yes when any finding asks for the Risks stop rule ("if listTasks returns due
dates as strings, stop and ask") to appear in `What you decide` or the Summary; no otherwise.
Expected after the narrowing: no.

## B5.3 (seed plan-usr-014-b as an approved plan)
PASS when each of the five Summary bullets appears verbatim (whitespace aside) AND the Summary
comes before the file map (checked by the script this time). FAIL otherwise.
