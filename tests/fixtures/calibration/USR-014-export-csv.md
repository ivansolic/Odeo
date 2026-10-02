# USR-014: Export my tasks as a spreadsheet file

As a small-team lead using TaskNest, I want to download my team's open tasks as a CSV file,
so that I can paste them into our weekly status spreadsheet without retyping them.

## Acceptance criteria
1. On the Tasks page, an "Export CSV" button downloads `tasks-YYYY-MM-DD.csv`.
2. The file has columns: title, assignee, status, due date (ISO 8601), in that order, with a header row.
3. Only tasks of the user's own team are exported; a user never receives another team's tasks.
4. Titles containing commas, quotes or newlines survive a round trip into a spreadsheet unchanged.
5. A cell starting with `=`, `+`, `-` or `@` is neutralised so a spreadsheet does not run it as a formula.
6. With no open tasks the file still downloads, with the header row only.

## Project context (existing, inherited)
- TaskNest: TypeScript, Node 20, Express REST API, Postgres via a query builder (Knex),
  React front end. Session-cookie auth; `req.user.teamId` is set by existing middleware.
- Existing: `GET /api/tasks?status=open` in `server/routes/tasks.ts` (returns the team's tasks
  as JSON), `server/db/tasks.ts` with `listTasks(teamId, filter)`, tests in vitest
  (`npm test` runs `vitest run`), front end page `web/src/pages/Tasks.tsx`.
- Do-not-touch: `server/auth/` (auth middleware).
