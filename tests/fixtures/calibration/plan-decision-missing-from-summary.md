# Plan: USR-014 Export my tasks as a spreadsheet file
approved: no
model_plan:
  judgment: <session model> effort high (configured, per CLAUDE_EFFORT)
  builder_tier: sonnet effort high
arch_review: pending

## Summary for humans
- What you get: one button on the Tasks page that downloads your team's open tasks as a file
  you can paste into your weekly status spreadsheet.
- What changes for users: a new "Export CSV" button; nothing else on the page moves.
- Biggest risk: the file could include another team's tasks if the server trusted anything the
  browser sends.
- What you decide: approve the plan, and one choice: the due date is written in UTC, so a task
  due late in the evening in Vienna can show the next day.
- How we will know it works: download as a member of one team, and the file holds only that
  team's open tasks, with commas and quotes in titles intact.

## Why
Team leads retype open tasks into a weekly spreadsheet by hand. That costs time every week and
copies mistakes along with the tasks.

## Explanation
- Export button: before, tasks are copied by hand -> after, one download -> team leads.
- Team fence: before, nothing to fence -> after, the server reads the team from the session
  only -> every team, whose tasks stay private.

## Header
Goal: a team lead downloads the team's open tasks as `tasks-YYYY-MM-DD.csv`.
Serves: the story's own outcome (no strategy doc).
Architecture context: Express REST API, Knex on Postgres, React front end, session-cookie auth
  with `req.user.teamId` set by existing middleware; inherited, not redecided.
Constraints: the six acceptance criteria of USR-014, verbatim in the story file.

## Design decisions (resolved, so the builder does not guess)
- The team comes only from `req.user.teamId`; no query parameter can widen it (criterion 3).
- Header row is `title,assignee,status,due_date`, so spreadsheet tools that split on spaces
  keep the last column whole.
- Due dates are written as ISO 8601 in UTC (`YYYY-MM-DD`).
- A cell starting with `=`, `+`, `-` or `@` is prefixed with a single quote (criterion 5).

## Contracts (declared once, referenced by name)
### C1: CSV serializer
- Kind: function
- Declaration: `toTasksCsv(tasks: Task[]): string` in `server/export/tasksCsv.ts`; RFC 4180
  quoting; header row first; rows in the order given.
- Produced by: Task 1
- Consumed by: Task 2
- Invariants: no cell starts with `=`, `+`, `-` or `@` unquoted; an empty list gives the header only.

## File map (before any tasks)
- server/export/tasksCsv.ts         CREATE: the serializer (C1)
- server/export/tasksCsv.test.ts    CREATE: serializer tests
- server/routes/tasks.ts            MODIFY: add `GET /api/tasks/export.csv`
- server/routes/tasks.export.test.ts CREATE: route tests
- web/src/pages/Tasks.tsx           MODIFY: the Export CSV button

## Tasks
### Task 1: serializer
- Test first: `tasksCsv.test.ts` cases: header only for []; a title with comma, quote and
  newline round-trips; `=SUM(1)` becomes `'=SUM(1)`; due date ISO UTC.
- Implement: C1 as declared.
- Produces: C1 (CSV serializer)
- Verify: `npm test -- tasksCsv` passes 4 tests.
- Commit: `feat(export): CSV serializer for tasks`
### Task 2: route and button
- Test first: `tasks.export.test.ts`: user of team A gets only team A's open tasks, also with
  `?teamId=B`; filename `tasks-YYYY-MM-DD.csv` with a fixed clock; empty list gives header only.
- Implement: route reads `req.user.teamId`, calls `listTasks(teamId, { status: "open" })`,
  returns C1's output with `Content-Disposition: attachment`; the button links to it.
- Consumes: C1 (CSV serializer)
- Verify: `npm test -- tasks.export` passes 4 tests.
- Commit: `feat(export): download open tasks as CSV`

## Task order and parallelism
Task 1, then Task 2.

## Do-not-touch boundaries
- server/auth/: the auth middleware (story constraint).

## Risks / open questions
- If `listTasks` returns due dates as strings rather than dates, stop and ask.

## Review Focus
- A query parameter that reaches `listTasks` and widens the team.
- Neutralising a cell after quoting it instead of before.

## Success signal (every acceptance criterion mapped to a concrete check)
| Criterion (short quote, USR-014) | Proven by |
|---|---|
| "Export CSV button downloads tasks-YYYY-MM-DD.csv" | tasks.export.test.ts filename case |
| "columns: title, assignee, status, due date" | tasksCsv.test.ts header case |
| "only tasks of the user's own team" | tasks.export.test.ts team A/B case |
| "commas, quotes or newlines survive" | tasksCsv.test.ts round-trip case |
| "a cell starting with = + - @ is neutralised" | tasksCsv.test.ts formula case |
| "with no open tasks the file still downloads" | tasks.export.test.ts empty case |

## Out of scope
- Exporting closed tasks, or choosing columns.
