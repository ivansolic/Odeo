# Plan review: USR-014 Export my tasks as a spreadsheet file (plan.md, v1)

Reviewer: architecture-reviewer, plan-review mode. Story read: story.md (6 acceptance criteria).
No output language was supplied at dispatch and there is no project CLAUDE.md in scope, so this review is in English.

Result: NOT clean. 2 blocking, 5 important, 6 notes.

## What checks out
- Reference graph is clean: C1 names its producing task (Task 1); Task 1 `Produces: C1`; Task 2 `Consumes: C1`; C1 `Consumed by: Task 2` equals the set of consuming tasks. No cross-plan references, so the approval-scope rule (AGENTS.md Guardrails 1) has nothing readable to flag.
- Success-signal row count is 6, equal to the story's 6 criteria; no criterion is dropped outright.
- No code block inside any `Implement:` field, so no missing `illustrative-not-contract:` label. No interface has two definition sites.
- Boundaries: team taken only from `req.user.teamId`, `?teamId=B` tested as a widening attempt, `server/auth/` listed as do-not-touch and nothing in the file map touches it. Inherited architecture (Express, Knex, React, session cookie) is restated, not redecided.
- The UTC due-date choice is correctly surfaced under `What you decide`.

## Blocking

### B1. The header row departs from the story's wording, and the gate never sees it
- **What:** Criterion 2 names the columns "title, assignee, status, due date". Design decisions sets the header to `title,assignee,status,due_date`. That is a departure from the story's wording that changes what the user gets (the literal text in the first row of their spreadsheet), and it lives only in the technical layer. `What you decide` names only the UTC choice.
- **Why it matters:** plan-format criterion 6: a story deviation left only in the technical layer is a finding; the human approves from the Summary and would never see it. The stated reason ("spreadsheet tools that split on spaces") is also questionable for a comma-separated file, so the human has a real choice here.
- **Alternative:** either use the story's header (`due date`) or keep `due_date` and add it to `What you decide` with a plain-language reason.

### B2. Formula neutralisation conflicts with criterion 4, and the conflict is not put to the human
- **What:** Criterion 4 says titles survive a round trip "unchanged"; criterion 5 says a cell starting with `=`, `+`, `-` or `@` is neutralised. The plan resolves this by prefixing a single quote, which means a title such as `- follow up with vendor` or `@Anna review` arrives in the spreadsheet altered (in a CSV import the apostrophe is a visible character, not Excel's hidden typed-apostrophe). This is a design decision that changes what the user gets and departs from criterion 4's wording, yet it is not in `What you decide`.
- **Why it matters:** the user pastes these titles into a status sheet; a visible leading `'` on every dash-bulleted title is exactly the retyping the story is meant to remove. The human must choose the trade-off (safety for all four characters vs. fidelity for common titles like leading `-`), not discover it after shipping.
- **Alternative:** name the trade-off in `What you decide` (e.g. "titles starting with = + - @ get a leading apostrophe, so they show it in the sheet"), and state in Design decisions that criterion 5 takes precedence over criterion 4 for those cells.

## Important

### I1. Criterion 1's button is never proven
- **What:** Criterion 1 is "On the Tasks page, an 'Export CSV' button downloads ...". The success-signal row maps it only to the route's filename test. `web/src/pages/Tasks.tsx` is modified, but no task writes a test or a verify step for the button (label, presence, target URL).
- **Why it matters:** a builder can ship a working endpoint and a missing or mis-linked button, and every listed check stays green.
- **Alternative:** add a front-end test (the button with text "Export CSV" exists and links to `/api/tasks/export.csv`), or a named manual check in Verify, and cite it in the criterion 1 row.

### I2. The `assignee` column has no defined source
- **What:** C1 takes `Task[]` with no declared shape. The story's column is "assignee"; whether `listTasks` returns an assignee name, an id, or a join is not stated, nor what to write when a task is unassigned. The only Risks stop rule covers due dates.
- **Why it matters:** two competent builders will diverge (one writes a numeric user id, one a display name), which fails rubric criterion 1 (executability). An id in the sheet does not serve the story.
- **Alternative:** declare in C1 the input fields used (`title`, assignee display name, `status`, `dueDate`) and the empty-cell rule for null assignee and null due date; add a stop rule if `listTasks` does not return the assignee's name.

### I3. Missing values are unspecified
- **What:** Nothing says what a task without a due date (or assignee) produces. The due-date test only covers a present date.
- **Why it matters:** a `null` passed to an ISO formatter throws or writes `1970-01-01`/`Invalid Date`, breaking the export for any team that has one undated task.
- **Alternative:** add to C1's invariants "null due date or assignee gives an empty cell" and a test case for it.

### I4. The neutralisation invariant is ambiguous about quoting
- **What:** C1's invariant reads "no cell starts with `=`, `+`, `-` or `@` unquoted". "Unquoted" can be read as RFC 4180 double-quoting, which does NOT neutralise a formula (`"=SUM(1)"` is still evaluated). Review Focus already names the ordering hazard, which shows the plan knows it, but the contract itself still admits the wrong reading. It also does not say whether the rule applies to every column (assignee, status) or only titles; "a cell" in the story means every column.
- **Why it matters:** a builder that satisfies the invariant literally with double quotes ships the exact vulnerability criterion 5 exists to prevent.
- **Alternative:** state the invariant as "every cell, in every column, whose value starts with one of `= + - @` is prefixed with `'` BEFORE RFC 4180 quoting is applied", and add a formula case on a non-title column.

### I5. The new route may be swallowed by an existing parameter route
- **What:** `GET /api/tasks/export.csv` is added to `server/routes/tasks.ts`. If that router also has `GET /api/tasks/:id` (typical for a tasks REST resource) registered first, Express matches `export.csv` as an id. The plan neither states registration order nor adds a stop rule.
- **Why it matters:** the route test may pass in isolation while the real app returns a 404 or a task lookup error.
- **Alternative:** state "register the export route before any `/:id` route in the same router" as a behavior rule, or add it to Risks as a stop-and-ask.

## Notes
- N1. Task 2's Verify says "passes 4 tests" but its Test first names three cases (team fence incl. `?teamId=B`, filename, empty). Say whether the `?teamId=B` attempt is its own test so the count is unambiguous.
- N2. The criterion 2 row cites a "header case", but Task 1's only header check is the empty-list case; column ORDER with a data row is never asserted. Add "one task produces columns in the order title, assignee, status, due date".
- N3. The filename date's time zone is unstated, while due dates are UTC. Say UTC for the filename too, so a download just after midnight in Vienna is predictable, and so the fixed-clock test has one answer.
- N4. No response `Content-Type` (`text/csv; charset=utf-8`) or BOM decision. Without a UTF-8 BOM, Excel on Windows mis-decodes names with umlauts, which bears on criterion 4's "unchanged". Worth a one-line design decision.
- N5. The route's behavior when `req.user` is absent is unstated; it should sit behind the existing auth middleware (unchanged) so it returns the app's usual 401, not a 500 from reading `teamId` of undefined.
- N6. Review Focus has two items; the format asks for 3 to 5. I5 and N4 are candidates. Also `model_plan` `judgment: <session model>` is an unfilled placeholder: the format wants the model stated, or read with its source (`(per session environment)`).

## Rubric reasoning (not a published score)
1 Executability 1 (I2, I3, I4, I5) / 2 File map 2 / 3 Task quality 1 (I1, N1, N2; reference graph itself clean) / 4 Constraint fit 2 / 5 Honesty 1 (only one stop rule; I2, I5 unasked) / 6 Human layer 1 (B1, B2).

Verdict: not clean; revise and re-dispatch for re-review.
