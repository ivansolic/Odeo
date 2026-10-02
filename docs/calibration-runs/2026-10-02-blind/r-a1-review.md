# Plan review: USR-014 Export my tasks as a spreadsheet file

Mode: plan review (architecture-reviewer). No output language was supplied at dispatch and no
project `CLAUDE.md` exists in the review root, so this review is written in English.

Verdict: NOT clean. 0 blocking, 5 important, 6 notes.

## Checks only this reviewer can make (plan-format criterion 3 and 6)
- Reference graph: clean. C1 names its producing task (Task 1); Task 1 `Produces: C1`;
  Task 2 is the only task with `Consumes: C1`, and that matches C1's `Consumed by: Task 2`.
  No cross-plan references, so the approval-scope rule (AGENTS.md Guardrails 1) has nothing
  readable to flag.
- Success-signal row count: 6 rows, and the story has 6 acceptance criteria. Count matches
  (but see I2: row 1 does not prove what it claims).
- Unlabeled code blocks in `Implement:` fields: none.
- Interfaces with two definition sites: none as interfaces, but the neutralisation RULE has
  two differing statements (I3).
- Human layer: present and plain. One story deviation lives only in the technical layer (I1).

## Blocking
none

## Important

### I1: header name `due_date` departs from the story and is not in "What you decide"
- **What:** Criterion 2 says the columns are "title, assignee, status, due date". Design
  decisions fix the header as `title,assignee,status,due_date`. That changes the wording the
  user sees in the file and departs from the story, yet the Summary's `What you decide` names
  only the UTC choice.
- **Why it matters:** criterion 6 of the rubric: a story deviation that lives only in the
  technical layer is a finding, because the human approves from the Summary and never sees it.
  The stated reason ("tools that split on spaces") is also doubtful: CSV tools split on the
  delimiter, not on spaces.
- **Example scenario:** the team lead's status sheet has a column headed "due date"; the paste
  arrives as `due_date` and they did not agree to that.
- **Alternative:** either use `due date` as the story says, or keep `due_date` and add it to
  `What you decide` as a named deviation.

### I2: criterion 1 (the button) is not proven, and the button has no test or spec
- **What:** the Success signal maps "Export CSV button downloads tasks-YYYY-MM-DD.csv" to the
  route's filename test. That proves the server's `Content-Disposition`, not that a button
  labelled "Export CSV" exists on the Tasks page and triggers the download. Task 2's
  `Implement:` says only "the button links to it": no label text, no element (`<a href download>`
  vs. fetch + blob), no placement, no test.
- **Why it matters:** the row count is right but the row is hollow; the builder will never
  notice the front end half of criterion 1 is unverified. Two builders would also produce
  different buttons (rubric criterion 1).
- **Alternative:** state the element and label exactly (for example a plain link to
  `/api/tasks/export.csv` with visible text `Export CSV`, so the session cookie rides along and
  no client CSV handling exists), add a component test in `web/src/pages/` that asserts the
  label and the `href`, add that test file to the File map, and point row 1 at both tests.
  Consider splitting the button into its own task: it is a separate reviewer gate (front end vs.
  route).

### I3: the neutralisation rule has two conflicting statements
- **What:** Design decisions say "prefixed with a single quote". C1's invariant says "no cell
  starts with `=`, `+`, `-` or `@` unquoted". "Unquoted" reads naturally as RFC 4180 double
  quoting, which does NOT stop a spreadsheet from evaluating a formula. A builder satisfying the
  invariant literally could wrap the cell in `"..."` and pass.
- **Why it matters:** this is the security property of the story (criterion 5, CSV injection),
  and the contract is the part the builder is bound to.
- **Alternative:** make the invariant the mechanism: "every cell whose first character is one of
  `= + - @` is emitted with a leading `'` added BEFORE RFC 4180 quoting; this applies to every
  column, not only title". Add a test case on a non-title column (for example an assignee named
  `@bob` or `-x`).

### I4: the `Task` input shape and its null cases are unspecified
- **What:** `toTasksCsv(tasks: Task[])` names a `Task` type the plan never locates or describes.
  Which field holds the assignee (name, email, id?), what is written when the assignee or the
  due date is null, and what the `status` cell contains are all open. The only stop rule covers
  "due dates as strings".
- **Why it matters:** rubric criterion 1 (two builders, equivalent code). A task with no due date
  is common; one builder emits an empty cell, another crashes on `null.toISOString()`.
- **Alternative:** name the source type (the row type returned by `listTasks` in
  `server/db/tasks.ts`), list the four field mappings, and state "null assignee or due date ->
  empty cell", with a test case.

### I5: route path can be shadowed by an existing parameterised route
- **What:** `GET /api/tasks/export.csv` is added inside `server/routes/tasks.ts`. If that router
  already defines `GET /api/tasks/:id` (typical for a tasks router), Express matches in
  registration order and `export.csv` is handled as a task id.
- **Why it matters:** an untested failure mode: the route tests would catch it only if they run
  against the full router, and the plan does not say they do. Nothing in Review Focus names it.
- **Alternative:** state the invariant "the export route is registered before any `/:id`
  route in the same router" and require the route tests to mount the real tasks router, not the
  handler in isolation.

## Notes
- N1: `model_plan.judgment` is `<session model>`, a placeholder. The format requires the model
  read from the session with its source, for example `judgment <model> (per session environment)`.
- N2: the filename date's time zone is unstated. Due dates are UTC by decision; say whether the
  filename date is UTC as well, so the fixed-clock test has one right answer.
- N3: Task 2 `Verify:` expects 4 tests, but its test-first list reads as 3 cases (team A with the
  `?teamId=B` variant, filename, empty). Name the four tests so the count is checkable.
- N4: criterion 4 says "survive a round trip into a spreadsheet". The plan does not say what the
  round-trip test parses with. Name it (an existing CSV parser dev dependency, or a hand-written
  RFC 4180 reader in the test) so it is not left to the builder to add a dependency. Also state
  `Content-Type: text/csv; charset=utf-8` and whether a UTF-8 BOM is written, since Excel misreads
  non-ASCII titles without one, which would break "unchanged".
- N5: `Constraints:` points to the story file instead of copying the criteria verbatim, as the
  format asks. Harmless here, but the plan is meant to stand alone.
- N6: the route relies on `req.user.teamId` being set; say the route sits behind the same existing
  auth middleware as `GET /api/tasks` (without touching `server/auth/`), and add an
  unauthenticated-request case (expect 401, not a 500 from `req.user` being undefined). The
  Summary also says "commas and quotes" but omits newlines from criterion 4; minor.

## Rubric reasoning (not a published score)
1 Executability 1 (I2, I4) · 2 File map 1 (no front end test file) · 3 Task quality 1 (I3; graph
clean, row count matches) · 4 Constraint fit 2 (inherits architecture, do-not-touch respected) ·
5 Honesty 1 (I5, N2 not raised as questions) · 6 Human layer 1 (I1).
