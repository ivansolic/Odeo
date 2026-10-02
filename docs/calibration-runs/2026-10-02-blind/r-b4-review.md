# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode
Reviewed: plan.md against story.md (the inherited architecture is the story's project context)
Output language: none was supplied at dispatch and no target-project CLAUDE.md exists in the review directory, so this review is in English.

## Verdict

NOT CLEAN. No blocking findings, 8 important, 7 notes.

The plan is shaped well. The reference graph is clean, the team fence is set by the session, and both visible story deviations (UTC dates, the `due_date` header) show up under `What you decide`. What keeps it from clean is mostly executability: several cell-level and route-level decisions are left open, so two competent builders would ship different files. One acceptance criterion is only half proven. And one user-visible design decision appears only in the technical layer.

## Mechanical checks (rubric criterion 3)

- Reference graph: clean. C1 names its producer (Task 1). Task 1 `Produces: C1`, Task 2 `Consumes: C1`. The `Consumed by:` set {Task 2} equals the set of tasks citing C1. No cross-plan references, so the batch-approval rule (AGENTS.md Guardrails 1) has nothing readable to flag.
- Success signal row count: 6 rows for 6 story criteria. The count matches (see I3 for proof quality).
- Unlabeled code blocks in `Implement:` fields: none.
- Interfaces with two definition sites: none. C1 is declared once.

## Blocking

none

## Important

### I1. The single-quote prefix changes what users see, and it appears only in the technical layer
- **What:** Design decision "A cell starting with `=`, `+`, `-` or `@` is prefixed with a single quote" is missing from `What you decide`. It changes what the user gets. When a spreadsheet opens a CSV, the apostrophe is shown as part of the cell text. A title like `-1 day slip` or `@marketing review` then lands in the status sheet as `'-1 day slip`. The story says only "neutralised" and does not pick a mechanism.
- **Why it matters:** Criterion 6 says a Design decision that changes what the user gets must appear under `What you decide`. The human approves from the Summary and never sees this choice. The `-` prefix fires on ordinary task titles, not only on attacks.
- **Example scenario:** A team lead pastes the export and finds stray apostrophes on every task that starts with a dash. They report it as a bug in a feature that was approved.
- **Alternative:** Add it to `What you decide`, in plain words: "titles that start with = + - or @ get a leading apostrophe, so a spreadsheet cannot run them as formulas; you will see that apostrophe in the cell."

### I2. The C1 invariant contradicts the design decision and suggests the wrong defence
- **What:** C1 says "no cell starts with `=`, `+`, `-` or `@` **unquoted**". In a CSV contract, "quoted" naturally means wrapped in RFC 4180 double quotes. Double quotes do not neutralise a formula. The design decision says a leading `'` does.
- **Why it matters:** The invariant is the binding part. A builder who reads "unquoted" as "not in double quotes" meets the invariant and still ships a formula-injection hole. The only guard left is that one test happens to assert `'=SUM(1)`.
- **Example scenario:** The builder wraps risky cells in `"..."`, rewrites the formula test to match, and the hole ships.
- **Alternative:** Restate it: "after serialization, the value of every cell (any column) that started with `=`, `+`, `-` or `@` begins with `'`; the prefix is applied before RFC 4180 quoting." Also say whether the rule covers all four columns or titles only.

### I3. Criterion 1's button is never proven, and its implementation is vague
- **What:** The criterion-1 row is proven by "tasks.export.test.ts filename case", a server test. Nothing proves the "Export CSV" button exists on the Tasks page or triggers the download. Task 2 Implement says only "the button links to it". It does not name the element (an anchor with `href` versus a fetch plus blob), the exact label, or the placement. Task 2's Verify runs only `tasks.export`.
- **Why it matters:** This reviewer is the last line for a dropped criterion. Half of criterion 1 has no check, and the builder will not add one on its own.
- **Example scenario:** The button ships with the label "Export" or "Download", or it uses `fetch` without credentials and downloads a 401 body. Every listed test still passes.
- **Alternative:** Specify a plain `<a href="/api/tasks/export.csv">Export CSV</a>`, since a same-origin navigation carries the session cookie. Add a check: a component test asserting the link's text and `href`, or a named manual step in Verify. Point the criterion-1 row at both.

### I4. The `Task` input shape and per-column formatting are unspecified
- **What:** `toTasksCsv(tasks: Task[])` names a type the plan never locates or describes. Several things are missing. Where is `Task` imported from (`server/db/tasks.ts`?), and what are its field names? Is `assignee` a name, an email or a user id? What goes in the cell for an unassigned task? What goes in the cell for a task with no due date? Which `status` value is written?
- **Why it matters:** Criterion 2 fixes the column order but not the column contents. Two builders will produce different files, which fails rubric criterion 1. Writing an assignee id into a status sheet also defeats the story's "without retyping them".
- **Alternative:** In C1, declare the input fields the serializer reads and their source type. Specify the cell rule for nulls (empty cell) and for assignee (display name, empty when unassigned). If `listTasks` does not return a display name, add a stop rule to Risks.

### I5. The two test counts do not match the listed cases
- **What:** Task 2 lists three cases (team A/B including `?teamId=B`, filename, empty) but its Verify expects "passes 4 tests". Task 1 lists four cases, but the Success signal cites a "header case" and a "round-trip case" that line up only loosely with those names. The criterion-2 row ("columns ... in that order") is proven only by the header-only case for `[]`, which never checks that data rows follow the same column order.
- **Why it matters:** A builder with a hard expected count either invents a fourth test or splits one to reach the number. Either way, the verify step stops meaning what the plan intended.
- **Alternative:** Name every test case explicitly, one per line, with the count derived from that list. Add a Task 1 case that serializes one full task and asserts the exact header plus row string, in order.

### I6. The "round-trip" test has no method
- **What:** "a title with comma, quote and newline round-trips" does not say what it round-trips through. One option is an exact expected output string, for example `"a, ""b""` + newline + `c"`. The other is parsing with a CSV library, which would be a new dependency the File map does not list.
- **Why it matters:** One builder hand-asserts the string. Another adds a parser package, an unreviewed supply-chain addition. A third writes a home-grown parser that shares the serializer's bug, so the test proves nothing.
- **Alternative:** Fix the expected output as an exact string in the test case and say explicitly that no new dependency is added. Pin the line ending too: RFC 4180 says CRLF, so state CRLF between records and the raw newline kept inside the quoted field.

### I7. The download's encoding, content type and filename date are not decided
- **What:** The plan does not set the `Content-Type` (`text/csv; charset=utf-8`), whether a UTF-8 BOM is written, or which clock and timezone produce the `YYYY-MM-DD` in the filename. Due dates are UTC, but the filename date is unstated.
- **Why it matters:** Without a BOM, Excel opens UTF-8 CSVs with non-ASCII titles garbled (the Summary itself picks a Vienna example, so umlauts are likely). That breaks the story's paste-without-retyping outcome even though criterion 4 passes. A filename date in server-local time versus UTC is the kind of choice two builders make differently.
- **Alternative:** Decide each one in Design decisions: content type; BOM yes or no (a user-visible choice, so it also goes in `What you decide`); filename date in UTC, from an injectable clock, matching the test's fixed clock.

### I8. Authentication is assumed but not asserted or tested on the new route
- **What:** The route "reads `req.user.teamId`", but the plan neither states that `GET /api/tasks/export.csv` sits behind the existing auth middleware nor tests an unauthenticated request. That leaves open whether the router in `server/routes/tasks.ts` already applies it, or whether the route must be mounted where the middleware runs.
- **Why it matters:** Criterion 3 is the security property of this story. If `req.user` is undefined, the route crashes with a 500 at best, which may also expose internals. At worst, a builder "fixes" the crash with a fallback. `server/auth/` is do-not-touch, so the plan has to rely on the existing mounting, and it should say so.
- **Alternative:** State that the route uses the same middleware chain as `GET /api/tasks`. Add a Task 2 case: no session gets a 401 and no CSV body.

## Notes

### N1. Review Focus item 1 is already tested
"A query parameter that reaches `listTasks` and widens the team" is exactly Task 2's `?teamId=B` case. Review Focus should name failure modes the tasks do not test (rubric criterion 6). Untested candidates: Express route order, where `/export.csv` registered after an existing `/:id` route is captured by it; a Postgres `date` column parsed into a local-midnight JS `Date`, which shifts back one day when converted to UTC; cells with leading whitespace before `=`.

### N2. The neutralise-then-quote ordering is named but not tested
Review Focus item 2 is real, but a single test would cover it: `=SUM(1,2)` must become `"'=SUM(1,2)"`. Adding that case to Task 1 is cheaper than relying on reviewer attention.

### N3. Route registration order
Tell the builder to register `GET /api/tasks/export.csv` before any parameterised `/api/tasks/:id` route in `server/routes/tasks.ts`.

### N4. Closed tasks are not asserted as excluded
The Task 2 team test should seed a closed team-A task and assert it is absent. Otherwise `{ status: "open" }` is unverified.

### N5. `Constraints:` is not verbatim
The plan format asks for constraints copied verbatim. "the six acceptance criteria of USR-014, verbatim in the story file" is a pointer, not a copy. The story's only constraint-like item is the do-not-touch, which already lives in its own section, so `none beyond the acceptance criteria` would be accurate.

### N6. `model_plan` judgment is a placeholder
`judgment: <session model>` is a placeholder (Rules: "No placeholders"). Fill in the model as read, with its source, for example `(per session environment)`.

### N7. Granularity, and other boundaries nearby
Task 2 combines a security-relevant server route and a UI change. A reviewer could reasonably reject one without the other, so consider splitting them. Also consider listing the existing `GET /api/tasks` JSON behaviour and `listTasks` as must-not-change, since the export only reuses them. A `Cache-Control: no-store` header on the download would keep team data out of shared caches.

## Human layer (criterion 6)

The Summary, Why and Explanation are present and in plain language, and the Why does not restate the Summary. Both disclosed choices (UTC dates, the `due_date` header) are correctly surfaced. The Risks stop rule ("if `listTasks` returns due dates as strings, stop and ask") is a builder stop rule, correctly kept out of `What you decide`, and is not a finding. Remaining gaps: I1 (the apostrophe prefix), I7 if a BOM is chosen, and N1.
