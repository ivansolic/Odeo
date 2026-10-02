USR-014 (export open tasks as a CSV file): the plan is ready for your approval.

Summary for humans (as written in the plan):
- What you get: one button on the Tasks page that downloads your team's open tasks as a file
  you can paste into your weekly status spreadsheet.
- What changes for users: a new "Export CSV" button; nothing else on the page moves.
- Biggest risk: the file could include another team's tasks if the server trusted anything the
  browser sends.
- What you decide: approve the plan, and two choices: the due date is written in UTC, so a task
  due late in the evening in Vienna can show the next day; and the last column is headed
  `due_date` rather than the story's "due date" (a change from the story, so spreadsheet tools
  that split on spaces keep it whole).
- How we will know it works: download as a member of one team, and the file holds only that
  team's open tasks, with commas and quotes in titles intact.

File map:
- server/export/tasksCsv.ts           CREATE: the serializer (C1)
- server/export/tasksCsv.test.ts      CREATE: serializer tests
- server/routes/tasks.ts              MODIFY: add `GET /api/tasks/export.csv`
- server/routes/tasks.export.test.ts  CREATE: route tests
- web/src/pages/Tasks.tsx             MODIFY: the Export CSV button
Do not touch: server/auth/ (the login middleware).

Plan review (architecture-reviewer): v1: clean. No findings, so no revisions were needed.
Recorded as `arch_review: clean (v1, 2026-10-02)`.

Build model: builder_tier sonnet, effort high (the plan is precise and the work is mechanical).

Approve, change, or reject?
- approve: I mark the plan `approved: yes` and start one builder, in the foreground, in its own
  worktree. Your editor stays still on purpose: you review the result at the next gate.
- change: tell me what, and it goes back to the architect, then through plan review again.
- reject: nothing gets built.
