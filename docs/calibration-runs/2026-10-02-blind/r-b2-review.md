# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode. No output language was supplied, so this
review is in English.
Inputs read: plan.md, story.md, docs/plan-format.md (rubric), AGENTS.md. There is no
codebase; the story's "Project context" is the inherited architecture.

## Verdict
NOT clean. 0 blocking, 7 important, 6 notes.

## Mechanical checks (rubric criterion 3, what only this reviewer checks)
- Reference graph: clean. C1 names its producer (Task 1). `Consumed by: Task 2` equals the set
  of tasks citing `Consumes: C1` (Task 2 only). Task 1 `Produces: C1` resolves. No cross-plan
  references, so the approval-scope rule (AGENTS.md Guardrails 1) has nothing to flag.
- Success-signal row count: 6 rows, story has 6 acceptance criteria. Count matches (but see
  important 4 and 5 on what two rows actually prove).
- Unlabelled code blocks inside `Implement:`: none.
- Interfaces with two definition sites: none. C1 is declared once.
- Do-not-touch: `server/auth/` listed and not in the file map. Respected.

## Blocking
none.

## Important

1. **The neutralisation mechanism is a user-visible choice that lives only in Design
   decisions (criterion 6).** "Prefix with a single quote" changes what the user gets: any
   title, assignee or status starting with `-`, `+`, `=` or `@` (e.g. "- follow up with
   legal", "@Maria review") lands in the spreadsheet with a visible leading apostrophe in
   many tools, and it collides with criterion 4's "unchanged" for those titles. The story only
   says "neutralised"; picking a visible prefix is a choice about the user's data, so it must
   also appear under Summary `What you decide`, in plain words ("titles that start with - + =
   or @ get a leading ' so the spreadsheet does not treat them as formulas; you will see that
   mark").

2. **C1's invariant is weaker than the design decision and admits a wrong build.** The
   invariant says "no cell starts with `=`, `+`, `-` or `@` unquoted". "Unquoted" reads
   naturally as RFC 4180 quoting, and a builder can satisfy it by wrapping the cell in double
   quotes, which spreadsheets strip on import, so the formula still runs. Restate the
   invariant as the mechanism: "after parsing the CSV, no cell value begins with `=`, `+`, `-`
   or `@`; such a value is stored as `'` + original value, and the prefix is applied BEFORE RFC
   4180 quoting". The Review Focus item on ordering is then a stated rule, not just a worry.
   Also say which columns it applies to (all four, per "a cell" in criterion 5).

3. **The `Task` type and the column sources are undefined (criterion 1, executability).**
   `toTasksCsv(tasks: Task[])` names a type the plan never locates or defines. Two builders
   will differ on: is `assignee` a name, email or id, and what does the file show for an
   unassigned task; what does a task with no due date write (empty cell?); is `status` the raw
   enum value. State the input shape (or name the existing type and file it comes from), and
   the rule for null assignee and null due date, plus one test case for each.

4. **Criterion 5 is proven by one character out of four, in one column.** The test list has
   only `=SUM(1)` on a title. Add cases for `+`, `-` and `@`, at least one in a non-title
   column, and one combining neutralisation with a character that forces quoting (e.g.
   `=a,"b"`) so the ordering rule in important 2 is actually tested, not only listed in Review
   Focus.

5. **Criterion 4's round-trip test is circular or unspecified.** "A title with comma, quote and
   newline round-trips" does not say round-trips through WHAT. If the builder writes its own
   parser for the test, the test proves only self-consistency. Specify the check: assert the
   exact encoded output string (e.g. title `a, "b"` + newline + `c` encodes to
   `"a, ""b""` newline `c"`), or name an existing parser dependency (adding one is a decision
   that would need the human). Also state the row terminator (RFC 4180 says CRLF; "RFC 4180
   quoting" covers quoting only).

6. **Criterion 1's button is not proven by anything.** The success row for criterion 1 cites
   the route's filename test; the button in `web/src/pages/Tasks.tsx` has no test and no
   verify step, so "On the Tasks page, an Export CSV button" can be missing and every check
   still passes. Either add a component test (rendered link with the label "Export CSV" and
   href `/api/tasks/export.csv`) as a test-after, or add a manual verify step to Task 2 and
   cite it in the row. Related: splitting the button from the route would give the UI its own
   reviewer gate, but merging is acceptable if the check exists.

7. **`model_plan: judgment: <session model>` is a placeholder.** The format requires a
   resolved model name, or a read value with its source (`judgment <model> (per session
   environment)`). A literal `<session model>` is a "No placeholders" failure and leaves the
   gate without a record of who judged.

## Notes

1. **Route shadowing.** `GET /api/tasks/export.csv` is added to `server/routes/tasks.ts`. If
   that router has `GET /:id`, it is registered first and `export.csv` will be captured as an
   id. Add one line: register the export route before any parameterised `/:id` route, or a
   builder stop rule if the order cannot be changed.
2. **Unauthenticated and failure paths are unstated.** Say the route sits behind the same
   middleware as the existing `GET /api/tasks` (so a missing session gives that middleware's
   401, never a 500 on `req.user` being undefined), and that a `listTasks` failure returns a
   generic 500 with no partial file. Add `Content-Type: text/csv; charset=utf-8`.
3. **DATE columns and the UTC rule.** If the due date is a Postgres `DATE`, the pg driver
   parses it as local midnight, and converting that to UTC can move it back one day on a
   server east of UTC, the same symptom as the Summary's Vienna example but for a different
   reason. The existing stop rule only covers strings. Suggest widening it ("if due dates are
   a `DATE` column or a string, stop and ask") or adding this to Review Focus.
4. **Review Focus has 2 items; the format asks for 3 to 5.** Candidates: note 3 (date shift),
   note 1 (route shadowing), non-ASCII titles opening garbled in Excel without a UTF-8 BOM
   (also bears on criterion 4).
5. **Filename date timezone and Task 2's test count.** Say whether `YYYY-MM-DD` in the
   filename is the server's UTC date (consistent with the due-date rule). Task 2 lists three
   cases but expects "passes 4 tests"; name the fourth (presumably the `?teamId=B` variant as
   its own test) so the verify line is checkable.
6. **Constraints are cited, not copied.** The format says Constraints are "copied verbatim
   from the spec/story"; the plan points at the story file instead. Harmless here, since the
   only story constraint is the do-not-touch, which has its own home, but copy the six
   criteria or write `none beyond the acceptance criteria`.

## Rubric reasoning (not a published score)
1 Executability 1 (important 2, 3, 5) · 2 File map 2 · 3 Task quality 1 (graph clean, test
coverage gaps in important 4 to 6) · 4 Constraint fit 2 · 5 Honesty 1 (notes 1 to 3 are
unasked questions) · 6 Human layer 1 (important 1, Review Focus count).

The human layer otherwise holds: both story deviations it makes (UTC, `due_date` header) are
named in `What you decide`; the Risks stop rule is correctly kept out of it; Why does not
restate the Summary.
