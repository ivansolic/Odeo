# Plan review: USR-014 Export my tasks as a spreadsheet file

Mode: plan review (architecture-reviewer). Reviewed `plan.md` against `story.md`, using
`docs/plan-format.md` (rubric criteria 1 to 6) and `AGENTS.md` Guardrails 1.
No output language was supplied at dispatch and no target project `CLAUDE.md` exists in the
review directory, so this review is written in English.

Result: **not clean**. 0 blocking, 6 important, 7 notes.

## What checks out
- Reference graph is clean. C1 names its producing task (Task 1); Task 1 `Produces: C1`;
  Task 2 `Consumes: C1`, and C1's `Consumed by:` set is exactly {Task 2}. No cross-plan
  references, so the approval-scope rule (Guardrails 1) has nothing to flag.
- Success-signal row count is 6, matching the story's 6 acceptance criteria.
- No code block inside any `Implement:` field, so no missing `illustrative-not-contract:`
  label. No interface has two definition sites.
- Inherited architecture respected: Express, Knex via existing `listTasks`, session-derived
  `req.user.teamId`; `server/auth/` is listed as do-not-touch and no task touches it.
- The team fence is designed correctly: the team comes only from the session, and a test
  sends `?teamId=B` to prove a query parameter cannot widen it.
- The UTC due-date choice, which changes what users see, is correctly raised in `What you decide`.
- The Risks entry ("if `listTasks` returns due dates as strings, stop and ask") is a builder
  stop rule, correctly kept out of `What you decide`.

## Blocking
none

## Important

### I1. The `due_date` header departs from the story's wording, and only the technical layer says so (criterion 6)
- **What:** Criterion 2 names the columns "title, assignee, status, due date". The Design
  decision writes the header as `title,assignee,status,due_date`. That is the column label
  every user sees in their spreadsheet, and it differs from the story. The Summary's
  `What you decide` names only the UTC choice.
- **Why it matters:** The human approves from the Summary, so they would never see this
  deviation. The stated reason ("spreadsheet tools that split on spaces") is also doubtful,
  since a CSV splits on commas. The human should get to accept or reject it.
- **Alternative:** Either use the story's label `due date` (a space is legal in an RFC 4180
  field), or keep `due_date` and add it to `What you decide` as a named choice.

### I2. The formula guard visibly changes some titles, and that conflicts with criterion 4, but the human is not asked (criterion 6, honesty)
- **What:** Criterion 4 says titles "survive a round trip ... unchanged"; criterion 5 forces a
  change for any cell starting with `=`, `+`, `-` or `@`. With the single-quote prefix, an
  ordinary title like `-1 day slip` or `@alice follow up` arrives as `'-1 day slip`, and
  depending on the tool the apostrophe shows in the cell.
- **Why it matters:** This is a user-visible effect and a direct trade-off between two
  acceptance criteria. Right now it is resolved silently in Design decisions. A team lead who
  sees stray apostrophes will think the export is broken.
- **Alternative:** Name the trade-off in `What you decide` (for example: "titles that start
  with `-` or `@` get a leading apostrophe so a spreadsheet cannot run them as formulas"), and
  state in the Design decision that criterion 5 takes precedence over criterion 4 for those cells.

### I3. Criterion 5 is proven for one of its four characters, and the invariant can be read two ways (criteria 1, 3)
- **What:** The Task 1 formula case tests only `=SUM(1)`. Nothing tests `+`, `-` or `@`,
  although the success-signal row claims "= + - @". The C1 invariant says "no cell starts
  with `=`, `+`, `-` or `@` **unquoted**", which a builder can read as "wrap it in RFC 4180
  double quotes". That does NOT neutralise a formula, yet it satisfies the invariant as written.
- **Why it matters:** This is the security property of the story (CSV formula injection). One
  builder implements the apostrophe prefix for `=` only and passes every listed test; another
  double-quotes the cell and passes the invariant. Two builders, two non-equivalent outputs.
- **Alternative:** Reword the invariant to "every cell whose first character is `=`, `+`, `-`
  or `@` is prefixed with `'` before RFC 4180 quoting is applied". Make the test table-driven
  over all four characters, plus one case that also needs quoting (for example
  `=A1,"x"` becomes `"'=A1,""x"""`), which also covers the second Review Focus item.

### I4. Criterion 1's button is in the plan but nothing proves it (dropped half of a criterion)
- **What:** Criterion 1 is "On the Tasks page, an 'Export CSV' button downloads
  `tasks-YYYY-MM-DD.csv`". Its success-signal row points only at the server filename test.
  The `Tasks.tsx` change has no test, no exact behavior (label text, link target, a plain
  `<a href download>` or a fetch) and no verify step.
- **Why it matters:** The builder executes what is listed. The button could be missing,
  mislabelled or pointed at the wrong URL while every listed check passes.
- **Alternative:** Specify the button exactly (label "Export CSV", an anchor to
  `/api/tasks/export.csv`, so the session cookie goes with it and the server's
  `Content-Disposition` sets the filename). Add a front-end vitest case asserting the label
  and the `href`, and cite it in row 1 next to the filename case. Consider making it its own
  task: it is a separate surface a reviewer could reject on its own.

### I5. Data shape and empty values are unspecified, so two builders write different files (criterion 1)
- **What:** `toTasksCsv(tasks: Task[])` never says where `Task` comes from or which fields map
  to the four columns. Is `assignee` a display name, an email or an id? What does a cell hold
  when there is no assignee or no due date (empty, `null`, `undefined`)? The Risks entry
  covers only the due-date type.
- **Why it matters:** An unassigned task is ordinary data. One builder writes an empty cell,
  another writes `null`, a third throws on `.toISOString()` of `null` and the whole export
  fails with a 500.
- **Alternative:** Name the source type (the row type `listTasks` returns in
  `server/db/tasks.ts`), the field for each column (for example `assignee` = display name), and
  the rule "a missing value is an empty cell". Add one Task 1 test for a task with no assignee
  and no due date. Extend the Risks stop rule to "if `listTasks` does not return an assignee
  name, stop and ask".

### I6. Unauthenticated and failure paths of the route are not stated (criteria 1, 4)
- **What:** Task 2 says the route "reads `req.user.teamId`" but not that it is mounted behind
  the same auth middleware as `GET /api/tasks`, nor what an unauthenticated request gets.
  It also does not say what happens when `listTasks` throws.
- **Why it matters:** If the new route sits outside the guarded router, `req.user` is
  undefined and the request crashes, or worse, a later "fix" defaults the team. This is the
  story's one data-access risk; it deserves an explicit rule and a test, not an assumption.
- **Alternative:** State "registered on the existing authenticated tasks router; no session
  returns 401 and no body", add that as a Task 2 test, and state that a database error returns
  the project's generic 500 with no partial file (no stack trace, per the security baseline).

## Notes

- **N1. Verify counts do not match the listed cases.** Task 2 lists three cases (team A/B
  including `?teamId=B`, filename, empty) but says "passes 4 tests". Task 1 has no case named
  "header case", yet success-signal row 2 cites one. Name each test case explicitly so the
  count and the row citations resolve, and add one data-row case asserting column order.
- **N2. Route ordering.** `GET /api/tasks/export.csv` in `server/routes/tasks.ts`: if a
  `/:id` route exists or is added later, it can capture `export.csv`. State "register before
  any parameterised `/api/tasks/:...` route", or tell the builder to check and stop if unsure.
- **N3. Filename date clock.** Which date goes in `tasks-YYYY-MM-DD.csv`, server UTC or the
  user's local date? Say UTC to match the due-date decision, and note it in the same
  `What you decide` line.
- **N4. Response encoding.** Specify `Content-Type: text/csv; charset=utf-8` and decide on a
  UTF-8 BOM. Without one, Excel garbles non-ASCII titles (for example "Übergabe"), which works
  against criterion 4. Also state the line terminator (RFC 4180 is CRLF).
- **N5. Round-trip test mechanism.** "Round-trips" needs a parser, and the plan does not say
  whether to add a CSV-parsing dependency. Prefer asserting the exact serialized string, so no
  dependency enters the project unreviewed.
- **N6. Review Focus.** It has 2 items where the format asks for 3 to 5, and the first item
  (a query parameter widening the team) is already tested by the `?teamId=B` case, so it is
  not an untested failure mode. Replace it with untested ones, for example: a leading
  tab or carriage return before `=` (OWASP lists these too); a very large team export held in
  memory as one string.
- **N7. Header.** `Constraints:` points at the story instead of copying the criteria verbatim
  as the format asks, and the header names `USR-014` but not the story file path.

## Rubric reasoning (not a published score)
1 Executability 1 (I3, I5, I6) / 2 File map 2 / 3 Task quality 1 (I3, I4, N1) /
4 Constraint fit 2 / 5 Honesty 1 (I2, I5) / 6 Human layer 1 (I1, I2, N6).

## For the next round
On re-review I will check that I1 to I6 are resolved by plan revisions and that N1 to N7 are
either fixed or answered.
