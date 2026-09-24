# Contributing to Odeo

Thank you for wanting to make this better. Odeo grows by what its
users bring back, and **contributions are not just code.** In fact, most of the
value here lives in the writing, the workflow, and the knowledge, so improving any
of those counts just as much.

## You can contribute to everything, not just code

| Area | Examples |
|---|---|
| **Docs** | A clearer explanation in `BEGINNERS-GUIDE.md`, a fix in `WORKFLOW.md`, a better `README.md` line, typos. |
| **Workflow** | A sharper command, a better gate, a missing step in `/build`, `/merge`, `/learn`, etc. |
| **Commands & agents** | New or improved templates in `project-templates/`. |
| **Skills** | Improvements to the `test-driven-development` or `ux-design` skills. |
| **Presets** | A filled stack preset (e.g. a new framework) others can start from. |
| **Knowledge** | Generalizable lessons via `/contribute-lesson` (the easiest way in, see below). |
| **Ideas & feedback** | Open an issue. A good problem report or idea is a real contribution. |

If you are not a developer, the docs, workflow, presets, and knowledge are exactly
where you can help most. Don't self-filter because "it's not code."

## The easiest contribution: a lesson

If you solved something reusable while building, run `/contribute-lesson`. It takes
a local `knowledge/` entry, **sanitizes and generalizes it** (no secrets, no PII,
no proprietary code, no internal names), shows you exactly what would be shared,
and only opens a PR after you approve. Nothing leaves your machine without your OK.
This is how the shared knowledge base, and everyone's copy of the system, gets
smarter.

## How to contribute (code or docs)

1. **Open an issue first** for anything non-trivial, so we can agree on direction
   before you invest time. Small fixes (typos, a clearer sentence) can skip
   straight to a PR.
2. **Fork** the repo and create a branch: `feature/...`, `fix/...`, `docs/...`.
3. **Make the change.** Match the surrounding style. One logical change per PR.
4. **Test it.** If you touched `init-project.sh`, run a scaffold in
   a throwaway dir and confirm it works (both `--ui` and `--no-ui`).
5. **Open a PR** using the template. Describe the what and the why.

## House style (please follow)

- **No em dashes or en dashes** in any text. Use commas, colons, periods, or
  parentheses. This is a hard rule across the whole project; PRs that add them will
  be asked to change.
- Conventional Commits for messages: `type(scope): description` (`feat`, `fix`,
  `docs`, `chore`, `refactor`, `test`).
- Keep the beginner in mind. Much of the audience is PMs and non-developers;
  prefer plain language and explain jargon.
- Never commit secrets, `.env` files, or anything private.

## Respecting the licenses we build on

This project credits and depends on others' work (see the Credits section in
`README.md`). When contributing, respect those licenses: don't paste in code or
text from another project and strip its attribution. Build from public methods and
your own words, or fork with proper credit.

## Code of conduct

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md). Be kind,
be constructive, assume good faith.

## License

By contributing, you agree that your contributions are licensed under the project's
[MIT License](LICENSE).
