# Plan review: USR-014 Export my tasks as a spreadsheet file

Reviewer: architecture-reviewer, plan-review mode. Reviewed against `story.md` (6 acceptance
criteria), `docs/plan-format.md` (rubric criteria 1 to 6) and `AGENTS.md`. No output language
was supplied at dispatch and there is no project `CLAUDE.md` here, so this review is in English.

Verdict: **not clean**. No blocking findings. Six important findings and six notes.

## What checks out
- Reference graph is clean. C1 names its producing task (Task 1). Its `Consumed by:` set
  ({Task 2}) matches the tasks that cite `Consumes: C1`. Task 1's `Produces: C1` resolves.
  There are no cross-plan references, so the "approval covers only the plan as approved" rule
  has nothing readable to flag.
- Success signal has 6 rows for the story's 6 criteria. Each row is quoted and attributed.
- No code blocks inside `Implement:` fields, so no labels are missing. Each interface (C1) is
  declared in one place only.
- Inherited architecture is restated and not redecided. The `server/auth/` do-not-touch
  boundary is respected (no task touches it). The team comes only from `req.user.teamId`,
  which is the right fence for criterion 3, and the `?teamId=B` test checks it.
- The human layer is present and in plain language. The UTC choice (a real user-visible
  decision) is correctly raised to `What you decide`. The stop rule in Risks is correctly
  kept out of it.

## Blocking
none

## Important

### I1. The header-name change appears only in the technical layer (criterion 6)
- **What:** Design decisions sets the header to `title,assignee,status,due_date`. The story
  (criterion 2) says the column is "due date". This changes what the user gets: it is the
  first row they paste into their status sheet, and it departs from the story's wording. It
  does not appear under `What you decide`.
- **Why it matters:** the human approves from the Summary and would never see this choice.
  The stated reason ("tools that split on spaces") is also doubtful, since CSV splits on
  commas, so this is a choice the human should get to make.
- **Alternative:** either use `due date` as the story says, or add the choice to
  `What you decide`, for example "the last column is headed `due_date`, not `due date`".

### I2. Formula neutralising changes real titles, and the gate is not told (criterion 6, and criterion 4 of the story)
- **What:** a cell starting with `-`, `+`, `=` or `@` gets a leading `'`. Ordinary titles like
  "- follow up with vendor" or "@Maria review" will show up in the spreadsheet with a visible
  apostrophe. The CSV does not carry Excel's hidden-apostrophe convention, and other tools
  show it as text. This is a user-visible trade-off between criterion 5 and the spirit of
  criterion 4 ("survive ... unchanged").
- **Why it matters:** this is the most likely way users will see the export as "wrong", and
  the Summary does not mention it.
- **Alternative:** name it under `What you decide` ("titles starting with - + = @ get a
  leading apostrophe in the file"). Optionally also name it as the Biggest risk.

### I3. C1's neutralising invariant allows the insecure implementation
- **What:** the invariant "no cell starts with `=`, `+`, `-` or `@` unquoted" can be read as
  "CSV double-quoting counts as quoted". Under that reading, `"=SUM(1)"` satisfies the
  invariant. But a spreadsheet still runs it as a formula once the quotes are stripped.
  Review Focus names the related ordering risk (neutralise before quoting), but the contract
  never states the order.
- **Why it matters:** this is the security-relevant rule of the story (CSV injection). Its
  contract wording should not permit the wrong reading. Two builders could produce code that
  behaves differently.
- **Alternative:** restate the invariant as behavior. The raw cell value is checked first. If
  its first character is one of `= + - @`, a `'` is prepended. Only after that is RFC 4180
  quoting applied. The rule applies to EVERY cell (title, assignee, status, due date), not
  only the title. Say explicitly whether leading tab and carriage return are in scope (OWASP
  also lists them) or out of scope.

### I4. Null and missing fields are unspecified
- **What:** nothing says what the serializer writes for a task with no assignee or no due
  date. It is also not said what an "assignee" cell holds: a user id, a display name or an
  email.
- **Why it matters:** two competent builders would produce different files (empty cell,
  `null`, `undefined`, or a crash on `.toISOString()` of null). That fails rubric criterion 1.
- **Alternative:** add to C1, for example: "a null assignee or due date gives an empty cell;
  assignee is the display name from `listTasks`'s result field `<name>`". Add one test case
  for it.

### I5. Task 2's test list does not match its verify count, and the button is unproven
- **What:** Task 2 lists three cases (team A/B with `?teamId=B`, filename, empty) but its
  Verify expects "passes 4 tests". The builder cannot tell whether the team case is meant to
  be two tests or a fourth case is missing. Separately, criterion 1 says "On the Tasks page, an
  'Export CSV' button downloads ...". The Success signal row proves only the filename. No task
  tests or verifies the button, and Task 2 bundles server and front-end work into one gate.
- **Why it matters:** half of criterion 1 has no check, and you are the last line for that.
  The count mismatch will make the builder stop or guess.
- **Alternative:** name all four route cases explicitly. Add a check for the button: a
  component test in the `web/` vitest suite (the button renders and its href is
  `/api/tasks/export.csv`), or a stated manual check. Point Success signal row 1 at both
  checks. Splitting the button into its own Task 3 would give it its own review gate.

### I6. Behavior for a request with no session is unstated
- **What:** the plan does not say that the new route sits behind the same auth middleware as
  `GET /api/tasks`, or what an unauthenticated request gets.
- **Why it matters:** if the route is registered outside the authenticated router,
  `req.user.teamId` throws, which gives a 500 and possibly a stack trace. In the worst case a
  fallback leaks data. The plan touches the only data-access path in the story, and
  `server/auth/` cannot be changed, so the plan has to state how it reuses that middleware.
- **Alternative:** state "registered on the same authenticated router as `GET /api/tasks`;
  without a session it returns 401 (the existing middleware's behavior)". Add a route test
  for it.

## Notes

- **N1. Route shadowing.** `GET /api/tasks/export.csv` in `server/routes/tasks.ts` will be
  captured by any existing `GET /api/tasks/:id` that is registered earlier. State "register
  before any `/:id` route", or add a stop rule for it.
- **N2. Timezone of the filename date.** `tasks-YYYY-MM-DD.csv` does not say whether the date
  is the server's local date or UTC. The due-date decision says UTC; say the same (or the
  opposite) for the filename so the fixed-clock test has one right answer.
- **N3. Round-trip check is undefined.** "a title with comma, quote and newline round-trips"
  does not say round-trips through what. Name the oracle: a known CSV parser already in the
  repo, or an exact expected output string.
- **N4. Response headers.** Only `Content-Disposition: attachment` is named. Also pin
  `Content-Type: text/csv; charset=utf-8` and the filename parameter. Decide on a UTF-8 BOM:
  without one, Excel garbles non-ASCII titles (for example umlauts for a Vienna team). Either
  decide it or list it under Out of scope.
- **N5. `model_plan` judgment is a placeholder.** `judgment: <session model>` is still the
  template text. The format requires a model, stated or read with its source (for example
  "(per session environment)").
- **N6. Constraints line.** "the six acceptance criteria of USR-014, verbatim in the story
  file" refers to the criteria rather than copying constraints. The story has no constraints
  besides the do-not-touch boundary, so write `none beyond the do-not-touch boundary` to make
  that explicit.

## Rubric reasoning (not a published score)
1 Executability: 1 (I3, I4, I5, N2, N3). 2 File map: 2 (complete; would gain a web test file
if I5 is taken). 3 Task quality: 1 (graph clean, rows 6/6, but the Task 2 count mismatch and
the bundled, unproven button). 4 Constraint fit: 2 (inherits explicitly, boundary respected;
I6 is a clarity gap, not a violation). 5 Honesty: 1 (only one risk listed; null fields,
route order and the auth path are unasked). 6 Human layer: 1 (I1 and I2 leave user-visible
choices only in the technical layer).

To reach clean: resolve I1 to I6. The notes are recommended and do not block clean on their
own.
