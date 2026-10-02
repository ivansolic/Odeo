# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode. Plan: `plan.md`. Story: `story.md`.
Rubric: `docs/plan-format.md`, criteria 1 to 6. No output language was supplied at dispatch
and no project `CLAUDE.md` exists in the review directory, so this review is in English.

## Result: NOT clean

0 blocking, 6 important, 6 notes.

## Mechanical checks (criterion 3)

- Reference graph: clean. C1 names its producer (Task 1). Task 1 `Produces: C1`, Task 2
  `Consumes: C1`. The C1 `Consumed by: Task 2` set matches the set of tasks citing it. No
  cross-plan references, so the batch approval rule has nothing to check.
- Success signal row count: 6 rows, and the story has 6 acceptance criteria. Count matches,
  but two rows claim more than their test proves (Important 1 and 2 below).
- Unlabelled code blocks in `Implement:` fields: none.
- Interfaces with two definition sites: none. The header row is stated in Design decisions
  and is implied, not redeclared, by C1.

## Important

### 1. Criterion 5 is only partly tested: three of the four trigger characters, and every column except the title, go unchecked
- **What:** Criterion 5 covers cells starting with `=`, `+`, `-` or `@`. Task 1 tests only
  `=SUM(1)`, in what reads as the title. The success signal row says the "formula case"
  proves the whole criterion.
- **Why it matters:** This is a security criterion (CSV formula injection). A builder can
  check only for `=`, or only in the title, and every listed test still passes. The builder
  runs the tests it was given and would never notice the gap. This review is the last check
  before that happens.
- **Example scenario:** A task assigned to a user whose display name is `@cmd|...`, or a
  title `+1+cmd|...`, goes out un-neutralised. The assignee column is just as much user
  input as the title.
- **Alternative:** Make the Task 1 formula case a table over all four characters, with at
  least one case in a non-title column (assignee). Add one case that needs both quoting and
  neutralising, such as `=A,B`, so the order named in Review Focus is pinned by a test.

### 2. The C1 invariant contradicts the design decision on neutralising
- **What:** C1 says "no cell starts with `=`, `+`, `-` or `@` **unquoted**". The Design
  decision says such a cell is "prefixed with a single quote". Review Focus warns about
  "neutralising a cell after quoting it instead of before".
- **Why it matters:** "Unquoted" can be read as "RFC 4180 double-quoting is enough". That
  reading permits `"=SUM(1)"`, which spreadsheets still run as a formula. The invariant is
  the binding part of the contract, so the weaker reading is the one a builder can defend.
- **Alternative:** Restate the invariant as behaviour: "the raw value of any cell whose
  first character is `=`, `+`, `-` or `@` is prefixed with `'` before RFC 4180 quoting is
  applied." Drop the word "unquoted".

### 3. Empty fields (no due date, no assignee) are unspecified
- **What:** The plan never says what to write when a task has no due date or no assignee.
  The only nearby rule is the Risks stop rule about due dates arriving as strings.
- **Why it matters:** Two competent builders will disagree here (rubric criterion 1). One
  writes an empty cell, one writes `null`, one calls `toISOString()` on `null` and the whole
  export returns a 500.
- **Alternative:** Add a Design decision such as "a missing value is written as an empty
  cell", add an invariant to C1, and add a Task 1 test case with a task that has no due
  date and no assignee.

### 4. Criterion 1's button has no check
- **What:** The success signal row for criterion 1 cites the route's filename test. Nothing
  checks that the Tasks page has an "Export CSV" button that points at the route. Task 2
  says only "the button links to it".
- **Why it matters:** Half the criterion (the button exists, has that label, and downloads)
  is unproven. A wrong href or a missing button passes every listed test.
- **Alternative:** Add a component test in the project's existing vitest setup (button
  labelled "Export CSV" with `href="/api/tasks/export.csv"`), or name an explicit manual
  check in the success signal row. Also consider splitting the button into its own task,
  because a reviewer could reject it separately from the route.

### 5. The route's behaviour without a session is not stated
- **What:** The route reads `req.user.teamId`. The plan does not say that the new route
  must sit behind the same auth middleware as `GET /api/tasks`, or what an unauthenticated
  request receives.
- **Why it matters:** If the route is registered outside that middleware, `req.user` is
  undefined. The result is a 500 that may expose a stack trace, or, worse, a builder adds a
  fallback. Criterion 3 rests on this. `server/auth/` is do-not-touch, so the fix has to be
  route placement, not changes to the middleware.
- **Alternative:** Add an invariant: "registered behind the existing auth middleware, the
  same as `GET /api/tasks`; an unauthenticated request gets the existing 401 behaviour."
  Add a Task 2 test case for an unauthenticated request.

### 6. The single-quote prefix changes what users see, but it is missing from "What you decide"
- **What:** The neutralising mechanism (a leading `'`) is a Design decision that shows up
  in the user's spreadsheet. A title like `-fix login` or `=draft` arrives as `'-fix login`.
  The story says only "neutralised". The Summary's "What you decide" lists UTC and the
  `due_date` header, but not this.
- **Why it matters:** Criterion 6: a choice that changes what the user gets must not live
  only in the technical layer. Titles that start with `-`, such as bullet-style titles, are
  common, so users will notice.
- **Alternative:** Add it to "What you decide" in plain words, for example: "titles that
  start with `=`, `+`, `-` or `@` get a leading apostrophe in the file, so a spreadsheet
  does not treat them as formulas."

## Notes

1. **Filename date timezone is unstated.** Due dates are UTC, but the date in
   `tasks-YYYY-MM-DD.csv` has no stated zone. State "UTC, same as due dates" so the
   fixed-clock test and the code agree.
2. **Route ordering.** If `server/routes/tasks.ts` has, or later gets, a `/:id` route
   registered first, `/api/tasks/export.csv` will be captured as `id = "export.csv"`. Tell
   the builder to register the export route before any parameterised `/api/tasks/:id`
   route.
3. **Response headers.** Only `Content-Disposition: attachment` is named. Also state
   `Content-Type: text/csv; charset=utf-8`. Decide whether to add a UTF-8 BOM: without one,
   Excel mangles non-ASCII titles, which matters for a criterion about titles surviving
   unchanged.
4. **Task 2 verify count.** "passes 4 tests" against a list that reads as three cases
   (team fence with `?teamId=B`, filename, empty), or four if `?teamId=B` is its own test.
   Name the four tests so the count can be checked.
5. **Review Focus has 2 items, and the format asks for 3 to 5.** The first ("a query
   parameter that ... widens the team") is partly covered by the `?teamId=B` test. Narrow it
   to the untested part, such as a different parameter name or a body field. Candidates for
   a third item: the export and the JSON list drifting apart in what counts as "open", and
   the export reading a different team source than the JSON route does.
6. **`model_plan.judgment` is a placeholder.** `<session model>` is not a model name. The
   format asks for the read model with its source, for example `judgment <model> (per
   session environment)`. Under "No placeholders" this should be filled in before the gate.

## Strengths
- The team fence is defined by its source (`req.user.teamId` only), and a hostile
  `?teamId=B` test backs it up. That is the right shape for criterion 3.
- The serializer is a pure function, so the riskiest logic is unit-tested without a server.
- Both story deviations it does name (UTC, the `due_date` header) are surfaced to the human.
- The do-not-touch boundary is respected, and the inherited architecture is not redecided.

## Re-review
On the next round, check each Important item and Note above against the revised plan.
Findings move only through plan revisions.
