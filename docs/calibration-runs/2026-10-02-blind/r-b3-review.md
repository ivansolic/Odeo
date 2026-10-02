# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode. Inputs: `plan.md`, `story.md`,
`docs/plan-format.md`, `AGENTS.md`. No output language was supplied at dispatch and no
target-project `CLAUDE.md` exists in the directory, so this review is in English.

**Verdict: NOT clean.** 0 blocking, 7 important, 6 notes.

## Mechanical checks (criterion 3, what only this reviewer checks)

- Reference graph: clean. C1 names its producing task (Task 1). Task 2 is the only task with
  `Consumes: C1`, and C1's `Consumed by:` is `Task 2`, so the sets match. No cross-plan
  references, so the batch-approval rule (AGENTS.md Guardrails 1) has nothing to flag.
- Success-signal row count: 6 rows, and the story has 6 acceptance criteria. The count
  matches. Whether each row actually proves its criterion is a separate question (see I3, I4).
- Code blocks inside `Implement:`: none, so no labels are missing.
- Two definition sites: none. C1 is declared once.
- Boundaries: `server/auth/` is listed as do-not-touch, and no file-map entry touches it.

## Blocking

none

## Important

### I1. The formula fix changes what users see, but the Summary never mentions it (criterion 6)
- **What:** Design decision 5 handles criterion 5 by adding a single quote (`'`) in front of
  any cell that starts with `=`, `+`, `-` or `@`. When a CSV file is opened or imported, that
  quote is ordinary text and stays visible. So a task titled `- follow up` or `-1 day slip`
  arrives as `'- follow up`. The story's word is only "neutralised", and this method changes
  visible content. `What you decide` names the UTC choice and the `due_date` choice, but not
  this one.
- **Why it matters:** the human approves from the Summary, and this choice lives only in the
  technical layer. Titles starting with a dash are common in task lists, so users will see it.
- **Example scenario:** a team lead pastes the export into the status sheet. Every
  bullet-style title starts with a stray `'`, and the lead edits them by hand, which is the
  retyping this story exists to remove.
- **Alternative:** add it to `What you decide` in plain words ("titles that start with = + -
  or @ get a leading ' so the spreadsheet does not run them; you will see that mark"). Or
  narrow the rule, for example leave `-` alone when a letter or space follows it. Narrowing
  departs from the story's wording, so it also belongs in `What you decide`.

### I2. C1's invariant permits a fix that does not work
- **What:** C1 says "no cell starts with `=`, `+`, `-` or `@` **unquoted**". Wrapping the
  cell in RFC 4180 double quotes (`"=SUM(1)"`) satisfies that sentence. But spreadsheets
  remove CSV double quotes on import and still run the formula. The Design decision (a
  leading `'`) and the Task 1 test (`'=SUM(1)`) say something different from the invariant.
  Review Focus ("neutralising after quoting instead of before") points at this but does not
  fix the contract.
- **Why it matters:** the invariant is what the builder and code reviewer check against.
  As written, it accepts the exact implementation that criterion 5 forbids.
- **Alternative:** restate the invariant as: "every cell whose first character is `=`, `+`,
  `-` or `@` is written with a leading `'` added BEFORE RFC 4180 quoting is applied; after
  CSV parsing, the cell value's first character is `'`." Add one test case where both rules
  apply, for example a title `=a,b` that also needs quoting.

### I3. Criterion 1's button is never verified
- **What:** the criterion 1 row is proven by the route's filename test. Nothing checks that a
  button labelled "Export CSV" exists on the Tasks page or that it points at the route. Task 2
  says only "the button links to it". It names no element, no label text and no target URL,
  and has no test or manual check.
- **Why it matters:** the row count matches, but half of the criterion has no proof. A build
  that ships the route and forgets or mis-wires the button passes every listed check.
- **Alternative:** state the UI contract: an `<a href="/api/tasks/export.csv" download>` (or
  an equivalent button) with the visible text `Export CSV`, in `web/src/pages/Tasks.tsx`. Add a
  check to the criterion 1 row: a component test if the web app has a test setup, otherwise a
  named manual step in Verify. Also consider making the button its own task, because UI is a
  different surface from the route and a reviewer could reject one without the other.

### I4. Assignee, null values and the round-trip check are not specified
- **What:** C1 takes `Task[]` but never defines the fields. Three gaps follow:
  (a) `assignee` could be a display name, a user id or an email address, and email is
  personal data;
  (b) the plan does not say what an unassigned task or a task with no due date writes;
  (c) the criterion 4 test says "round-trips" but names no parser to check against. A
  builder could write the parser as the serializer's own inverse, and that test would pass
  even when spreadsheets disagree.
- **Why it matters:** criterion 1 of the rubric asks whether two builders would produce
  functionally equivalent code. On these three points they would not.
- **Alternative:** declare the row shape in C1. For example:
  `{ title: string; assigneeName: string | null; status: string; dueDate: Date | string | null }`,
  where null is written as an empty cell, and the assignee column is the display name (or
  whatever is chosen). Make the round-trip test compare against an exact expected CSV string,
  such as `"a ""b"", c\nd"`, rather than a hand-written parser. If an assignee field that
  `listTasks` does not return yet is needed, say so, because that changes `server/db/tasks.ts`,
  which is not in the file map.

### I5. Date-only due dates can shift by a day, and Review Focus misses it
- **What:** the decision says "ISO 8601 in UTC (`YYYY-MM-DD`)". If the due-date column is a
  Postgres `date`, the `pg` driver turns it into a JS `Date` at midnight in the server's local
  time. `toISOString().slice(0,10)` on a server east of UTC then writes the previous day for
  every task, not only late-evening ones. The Risks entry covers only "returned as strings".
  The Summary describes the risk as an evening edge case, which understates it if the column
  is date-only.
- **Why it matters:** every date in the export could be off by one day, and a test that
  builds `Date` values in UTC on a CI machine running in UTC would not notice.
- **Alternative:** add a Risks stop rule: "if the due-date column is `date` (not
  `timestamptz`), stop and ask". Or state the formatting rule for each case: a date-only value
  is written as stored, and a timestamp is converted to UTC. Add a Review Focus line about the
  test clock and timezone. If date-only is the real case, update the UTC wording in the
  Summary to match.

### I6. Route setup and the unauthenticated case are not stated
- **What:** (a) the plan does not say the new route sits behind the same auth middleware as
  the existing `/api/tasks`. If it does not, `req.user` is undefined and the handler either
  crashes with a 500 or, worse, is wired to work around it. (b) If `tasks.ts` has a
  `GET /api/tasks/:id` route, registering `export.csv` after it sends the request to `:id`.
- **Why it matters:** criterion 3 depends on the team coming from the session, and the plan
  never says the session is guaranteed on this route. The route-order trap is silent: it
  passes in a fresh test router and fails in the real one.
- **Alternative:** state the invariant: "mounted on the same router/middleware chain as the
  existing `GET /api/tasks`; an unauthenticated request gets the existing 401." Add that as a
  Task 2 test case. Also state: "registered before any `/:id` route in `server/routes/tasks.ts`."

### I7. Task 2's response contract is underspecified
- **What:** the plan gives no `Content-Type` (for example `text/csv; charset=utf-8`), no exact
  `Content-Disposition` value (`attachment; filename="tasks-YYYY-MM-DD.csv"`), no rule for
  which day the filename date uses (UTC or server-local), and no mechanism for the "fixed
  clock" (an injected `now()` or vitest fake timers). It also does not decide whether the file
  starts with a UTF-8 BOM. Without one, Excel garbles non-ASCII titles (umlauts, for example),
  which works against criterion 4's "unchanged".
- **Why it matters:** these are visible behaviors that two builders would decide differently,
  and the BOM decision is a user-facing choice.
- **Alternative:** add a C2 "export response" contract (or extend Task 2's Implement) with the
  exact headers, the filename date rule and the clock mechanism. Settle the BOM as a Design
  decision. If it affects what users get, add it to `What you decide`.

## Notes

- N1. `model_plan: judgment: <session model>` is a placeholder rather than the model that was
  read. Per the plan format, write the read value with its source, for example
  `(per session environment)`.
- N2. Task 2's Verify says "passes 4 tests", but its Test first lists three or four cases
  depending on whether `?teamId=B` is its own case. Name the cases so the count can be checked.
- N3. The success-signal row for criterion 2 cites a "tasksCsv.test.ts header case", but no
  case with that name exists in Task 1. The closest is "header only for []". Also, no test
  checks that data rows keep the column order `title, assignee, status, due_date`. Add a row
  case and name it to match the table.
- N4. The reason given for `due_date` ("tools that split on spaces") does not hold for CSV,
  which splits on commas. The deviation is correctly listed in `What you decide`, but the
  stated reason may mislead the human approving it. Either give a real reason or keep the
  story's `due date`.
- N5. `Constraints:` points at the story ("verbatim in the story file") instead of copying the
  constraints, as the format asks. Copy the six criteria and the do-not-touch line, or state
  that the story has no separate constraint list.
- N6. The plan assumes the filter shape `listTasks(teamId, { status: "open" })`. Add a Risks
  stop rule ("if `listTasks`'s filter signature differs, stop and ask"). Also, OWASP's CSV
  injection guidance adds tab and carriage return to the dangerous leading characters. The
  story lists four, so this is for the human to consider, not a defect in the plan.

## Rubric reasoning (not a published score)

1. Executability 1 (I4, I6, I7). 2. File map 2 (complete for what the plan actually does;
I4 may add `server/db/tasks.ts`). 3. Task quality 1 (clean graph and matching row count, but
I2, I3, N3). 4. Constraint fit 2 (architecture inherited, do-not-touch respected).
5. Honesty 1 (I5, I6 risks not surfaced). 6. Human layer 1 (I1: a user-visible decision
lives only in the technical layer).

Re-review: each finding above needs a plan revision to resolve. On the next round I will
check each one by ID.
