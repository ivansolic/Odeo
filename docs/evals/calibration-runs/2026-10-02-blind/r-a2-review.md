# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode. Plan: `plan.md` (arch_review: pending,
approved: no). Story: `story.md` (6 acceptance criteria). No output language was supplied at
dispatch and no project `CLAUDE.md` exists in the review root, so this review is in English.

Verdict: NOT clean. 0 blocking, 5 important, 6 notes.

## Mechanical checks (rubric criterion 3)
- Reference graph: clean. C1 names its producer (Task 1); Task 1 `Produces: C1`; Task 2
  `Consumes: C1`; C1 `Consumed by: Task 2` equals the set of consuming tasks. No interface
  has two definition sites. No cross-plan references, so the Guardrails 1 approval-scope
  check has nothing to flag.
- Success-signal row count: 6 rows against 6 story criteria. Matches.
- No code blocks inside any `Implement:` field, so no missing `illustrative-not-contract:`
  label.
- Do-not-touch: `server/auth/` is listed and no task touches it.

## Blocking
none

## Important

### I1. A story deviation lives only in the technical layer: the column name `due_date`
- **What:** Criterion 2 names the column "due date". Design decisions sets the header to
  `title,assignee,status,due_date`. That departs from the story's wording and changes what
  the user sees in the first row of their spreadsheet, yet `What you decide` names only the
  UTC choice. Per criterion 6 a deviation from the story's wording must appear under
  `What you decide`.
- **Why it matters:** the human approves from the Summary and would never see this choice.
  The stated reason ("spreadsheet tools that split on spaces") is also not true of CSV,
  which splits on commas; `due date` is a valid unquoted CSV field. A reason that does not
  hold is a sign the decision was not needed.
- **Example scenario:** the team lead's existing weekly sheet has a "due date" column and a
  lookup on that header; the pasted header no longer matches.
- **Alternative:** either use the story's wording (`title,assignee,status,due date`) and drop
  the decision, or keep `due_date` with a correct reason and add it to `What you decide`.

### I2. The formula-neutralising invariant is ambiguous and under-tested
- **What:** C1's invariant reads "no cell starts with `=`, `+`, `-` or `@` unquoted". A
  builder can read "unquoted" as "not wrapped in RFC 4180 double quotes", in which case
  `"=SUM(1)"` satisfies the invariant, yet a spreadsheet still evaluates it, because the
  double quotes are CSV syntax and are removed on import. The test list covers only `=`
  (`=SUM(1)`), not `+`, `-` or `@`, and does not cover a cell that needs both neutralising
  and RFC quoting (for example `=A1,B1`). It also does not say whether the rule applies to
  every column (assignee and status too) or only title.
- **Why it matters:** criterion 5 is the security criterion of this story (CSV/formula
  injection); two competent builders could ship different, and one of them unsafe, code
  from this text (rubric criterion 1).
- **Example scenario:** builder neutralises only `=`, or quotes a title `@cmd` with double
  quotes and considers it "quoted"; the success signal still passes on `=SUM(1)`.
- **Alternative:** state the invariant as behaviour: "every cell, in every column, whose
  first character is `=`, `+`, `-` or `@` gets a leading `'` BEFORE RFC 4180 quoting is
  applied; the RFC quotes never count as neutralising". Add test cases for each of the four
  characters, one in a non-title column, and one cell that needs both prefix and quoting.

### I3. The neutralising mechanism changes what the user sees and is not in `What you decide`
- **What:** prefixing a single quote is a Design decision that changes the file's content:
  depending on how the file is opened or pasted, the user sees `'=SUM(1)` or `'- fix login`
  with a visible apostrophe. It also collides with criterion 4 ("survive ... unchanged") for
  any ordinary title beginning with `-` or `+`, such as "- follow up with client".
- **Why it matters:** criterion 6 requires every Design decision that changes what the user
  gets in `What you decide`. The tradeoff between criterion 4 and criterion 5 is a product
  choice the human should make knowingly, not discover in the weekly sheet.
- **Alternative:** add one line to `What you decide`: "titles starting with = + - or @ get a
  leading apostrophe so a spreadsheet cannot run them; such a title shows that apostrophe".

### I4. Criterion 1's success-signal row does not prove the button
- **What:** criterion 1 is "On the Tasks page, an Export CSV button downloads ...". Its row is
  proven by "tasks.export.test.ts filename case", a server test. Nothing checks that the
  button exists on `web/src/pages/Tasks.tsx` or that it points at
  `/api/tasks/export.csv`; Task 2's Verify runs only the route tests. The button is also
  bundled into Task 2 with no test and no verify step of its own.
- **Why it matters:** the plan's own `How we will know it works` relies on a download from
  the page, and the builder executes only what it is given; a missing or mis-linked button
  passes every listed check.
- **Alternative:** add a component test (vitest + the project's React testing setup) that
  renders `Tasks.tsx` and asserts a link/button labelled "Export CSV" with
  `href="/api/tasks/export.csv"` (or a named manual check, if UI tests are test-after in
  this project), and cite it in the criterion 1 row.

### I5. The Task-to-row mapping is unspecified, so two builders will produce different files
- **What:** `toTasksCsv(tasks: Task[])` does not say which `Task` fields map to the four
  columns. In particular `assignee` may be an id, an email or a display name in the row
  returned by `listTasks`, and a task with no assignee or no due date has no stated output.
  The filename date `YYYY-MM-DD` has no stated time zone either, while due dates are
  explicitly UTC.
- **Why it matters:** rubric criterion 1 (two builders, functionally equivalent code).
  An assignee id is useless in a status spreadsheet; an email would also put more PII into
  a file that leaves the system than the story needs.
- **Alternative:** in C1, state the mapping (for example "assignee = the assignee's display
  name as returned by `listTasks`; empty cell when unassigned; empty due date cell when
  none"), and state that the filename date is the UTC date of the request, consistent with
  the UTC decision. If `listTasks` does not return a display name, add that to Risks as a
  stop-and-ask, since widening the query is a data-layer change.

## Notes

- **N1. Unauthenticated request behaviour is not stated.** Task 2 relies on
  `req.user.teamId` but does not say the new route sits behind the same existing auth
  middleware as `GET /api/tasks`, or that a request without a session gets 401 and no file.
  Add it as an invariant and a test case; it costs one line and closes the most likely
  failure of criterion 3 outside the A/B test.
- **N2. Route ordering.** If `server/routes/tasks.ts` has a parameterised route such as
  `GET /api/tasks/:id`, a route registered after it is shadowed (`export.csv` matched as an
  id). State that the export route is registered before any `/:id` route, or add a Risks
  stop-and-ask if one exists.
- **N3. Response headers.** Only `Content-Disposition: attachment` is named. State the
  `filename=` parameter and `Content-Type: text/csv; charset=utf-8`; decide whether a UTF-8
  BOM is written (Excel misreads non-ASCII titles without it). If it is decided, it changes
  what the user sees and belongs in `What you decide`.
- **N4. Verify counts do not match the listed cases.** Task 2 lists team A only, the
  `?teamId=B` variant, filename, and empty list; whether that is 3 or 4 tests is left to
  interpretation, and a mismatch makes the Verify line fail on a correct build. Name the
  tests or drop the count. "Round-trips" in Task 1 also does not say against what (a named
  CSV parser, or an exact expected string).
- **N5. Review Focus.** It has two items, the format asks for 3 to 5, and the first ("a
  query parameter that reaches `listTasks` and widens the team") is already tested by the
  `?teamId=B` case, so it restates a task instead of naming an untested failure. Candidates
  that the tasks do not test: the button linking to a stale or wrong path; a large team
  export loading every open task into memory; Excel's locale-dependent separator (`;` in
  German/Austrian locales) splitting the file into one column.
- **N6. `model_plan` judgment is a literal placeholder.** `judgment: <session model>` is a
  placeholder; per the format it carries the model read from the session with its source,
  for example `judgment <model> (per session environment)`.

## Rubric reasoning (not a published score)
1. Executability: 1 (I2, I5, N1 to N4).
2. File map: 2.
3. Task quality: 1 (graph and row count clean; I2 and I4 leave cases untested).
4. Constraint fit: 2 (architecture inherited, do-not-touch respected).
5. Honesty: 1 (one stop-and-ask; the assignee, null-field and route-order unknowns are not
   surfaced).
6. Human layer: 1 (I1 and I3 leave story-affecting decisions only in the technical layer;
   N5 Review Focus restates a tested case). Summary, Why and Explanation are otherwise
   plain, distinct and consistent with the technical layer.
