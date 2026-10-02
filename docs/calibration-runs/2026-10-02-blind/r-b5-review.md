# Plan review: USR-014 Export my tasks as a spreadsheet file

Mode: plan review (architecture-reviewer). Plan: `plan.md`. Story: `story.md`.
Output language: none supplied at dispatch and no project `CLAUDE.md` in the directory, so this review is in English.

Verdict: NOT clean. 0 blocking, 5 important, 4 notes.

## What checks out
- Reference graph is clean: C1 names its producing task (Task 1); Task 1 `Produces: C1`, Task 2 `Consumes: C1`, and C1's `Consumed by:` set {Task 2} equals the set of consuming tasks. No cross-plan references, so the "approval covers only the plan as approved" rule has nothing readable to flag.
- Success signal has 6 rows; the story has 6 acceptance criteria. No criterion is dropped.
- No code block inside any `Implement:` field, so no missing `illustrative-not-contract:` label. No interface with two definition sites (C1 is declared once).
- Inherited architecture is respected: Express route, Knex `listTasks`, `req.user.teamId` from existing middleware, vitest. `server/auth/` is named as do-not-touch and no task touches it.
- Human layer is present and plain. The two choices that change what the user gets (UTC due dates, `due_date` header deviating from the story's "due date") are both in `What you decide`. The only Risks entry is a builder stop rule ("if `listTasks` returns due dates as strings, stop and ask"), which correctly stays out of `What you decide`.

## Important

### I1. Formula neutralisation is a user-visible choice that lives only in the technical layer, and it collides with criterion 4
- **What:** Design decisions fix the mechanism "prefix a single quote" for cells starting with `=`, `+`, `-` or `@`. That changes the file content the user pastes: a title such as `- follow up with vendor` or `@Anna review` arrives as `'- follow up with vendor`. Criterion 4 says titles survive "unchanged", criterion 5 says such cells are neutralised; for a title starting with `-` or `@` the two criteria conflict, and the plan resolves the conflict silently in favour of criterion 5. Neither the choice nor the conflict appears under `What you decide`.
- **Why it matters:** Criterion 6 of the plan rubric: a Design decision that changes what the user gets must be in the Summary. The human approves from the Summary and would never see that ordinary titles beginning with a dash get an apostrophe.
- **Example scenario:** A team lead whose tasks are written as bullet-style `- ...` titles finds an apostrophe on every row of the weekly spreadsheet and files a bug against a plan they approved.
- **Alternative:** Add to `What you decide`: "titles starting with `=`, `+`, `-` or `@` get a leading apostrophe so a spreadsheet cannot run them; this means such titles are not byte-identical after paste (criterion 4 yields to criterion 5 for these titles)." Optionally offer the human the narrower choice of neutralising `-`/`+` only when followed by a non-space character, as a decision, not a builder guess.

### I2. C1's invariant wording admits the wrong mechanism
- **What:** C1's invariant reads "no cell starts with `=`, `+`, `-` or `@` unquoted". In a CSV contract, "quoted" naturally means RFC 4180 double-quoting, and a double-quoted `"=SUM(1)"` still executes as a formula in spreadsheets. The single-quote prefix is stated only in Design decisions, not in the contract the builder binds to.
- **Why it matters:** Two competent builders could satisfy the invariant differently (rubric criterion 1), and one of them ships a formula injection hole while the invariant reads as met.
- **Example scenario:** A builder wraps every risky cell in double quotes, the test `'=SUM(1)'` is written to match whatever the builder produced, and criterion 5 is not actually met.
- **Alternative:** Restate the invariant as behaviour: "a cell whose value starts with `=`, `+`, `-` or `@` is emitted with a leading `'` prepended to the value BEFORE RFC 4180 quoting is applied; neutralisation applies to every column, not only title." That also turns the second Review Focus item into a contract rule rather than a hope.

### I3. `Task` type and per-column formatting are undeclared
- **What:** C1 declares `toTasksCsv(tasks: Task[]): string` but nowhere says where `Task` comes from, what the `assignee` cell contains (user id, display name, email), or what an absent assignee or absent due date writes. "Due date ISO UTC" says nothing about a null due date.
- **Why it matters:** The builder will guess. If `listTasks` returns `assigneeId`, the spreadsheet gets numeric ids; if it returns an email, the export carries PII into a file the plan does not mention. A null due date may throw inside the date formatter and fail the whole download.
- **Example scenario:** One unassigned task without a due date turns the export into a 500 for the whole team.
- **Alternative:** In C1, name the input type (the row type `listTasks` returns, by its existing name and file) and a per-column rule: `assignee` = the field it maps from, empty cell when null; `due_date` = `YYYY-MM-DD` in UTC, empty cell when null. Add both null cases to Task 1's test list. If `listTasks` does not return a display name, that is a stop-and-ask in Risks.

### I4. Task 2's verify count does not match its test list
- **What:** Task 2 names three cases (team A/B including `?teamId=B`, filename with fixed clock, empty list) but `Verify:` expects "passes 4 tests". Whether the `?teamId=B` variant is a separate test, or a fourth case is missing, is not stated.
- **Why it matters:** The builder runs the verify command literally; 3 passing tests against an expected 4 is either a false failure or an invitation to invent a test the plan did not specify.
- **Alternative:** List the four cases explicitly (for example: own-team only; `?teamId=B` ignored; filename and `Content-Type: text/csv` / `Content-Disposition: attachment`; empty list gives header only), or change the expected count to 3.

### I5. Route ordering against an existing parameterised route is not addressed
- **What:** `GET /api/tasks/export.csv` is added to `server/routes/tasks.ts`, which already serves task routes. If that router has (or later gains) `GET /api/tasks/:id`, a route registered before the export matches `export.csv` as an id.
- **Why it matters:** Silent misrouting: the request hits the single-task handler, returns 404 or a JSON error, and the button downloads an error body named `export.csv`. Tests pass only if the test happens to mount the router the same way production does.
- **Alternative:** Add a behaviour rule to Task 2: the export route is registered before any `/:id` route in the same router, and the route test exercises the real router module rather than a fresh router with only the export handler. Or add it to Review Focus if the builder cannot see the router order at plan time.

## Notes

### N1. Criterion 1's button is not proven by any check
The success row for "Export CSV button downloads" points at the route filename test; the button in `Tasks.tsx` has no test and no behaviour spec beyond "links to it". State the mechanism (a plain link to the export URL, so the session cookie travels with it, with the visible label "Export CSV") and either a component test or an explicit manual check in the success row.

### N2. Filename date timezone is unspecified
Due dates are fixed to UTC, but `tasks-YYYY-MM-DD.csv` does not say whose date. Near midnight in Vienna the file can be named for tomorrow. Say "UTC, same clock as due dates" in Task 2, consistent with the Summary choice.

### N3. First Review Focus item is already tested
"A query parameter that reaches `listTasks` and widens the team" is exactly Task 2's `?teamId=B` case. Review Focus is for failure modes the tasks do not test (rubric criterion 6). Replace it with an untested one, for example the route being mounted outside the existing auth middleware (then `req.user` is undefined and the handler throws instead of returning 401), or I5's route-ordering risk.

### N4. `model_plan.judgment` carries a placeholder
`judgment: <session model>` is a literal placeholder. Per the plan format, a value read rather than stated carries its source, e.g. `judgment <model> (per session environment)`. The effort half is correctly sourced (`configured, per CLAUDE_EFFORT`).

## Rubric reasoning (not a published score)
1 Executability 1 (I2, I3, I5) / 2 File map 2 / 3 Task quality 1 (I4; reference graph and row count clean) / 4 Constraint fit 2 / 5 Honesty 1 (I3 and I5 belong in Risks) / 6 Human layer 1 (I1, N3).

To reach clean: resolve I1 to I5 by plan revision; the notes are recommended but would not on their own hold the plan.
