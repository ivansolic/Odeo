---
description: Stage, commit with conventional commit message, and push to the current branch. Runs safety checks first, refuses to push to main, checks for secrets, runs tests and typecheck.
disable-model-invocation: true
---

Execute the following steps in order. **If any step fails or reveals a problem, STOP and report to the user. Do not continue to the next step.**

## 1. Check current branch
Run `git branch --show-current`.

If the branch is `main` or `master`:
- STOP
- Tell the user: "You're on the main branch. I won't push here. Let's create a branch first. What should it be called? Format: `feature/<name>`, `fix/<name>`, `chore/<name>`, etc."
- Wait for the user's branch name, then run `git checkout -b <branch-name>`
- Continue to step 2

## 2. Review what's changed
Run `git status` and `git diff --stat`.

Briefly summarize to the user:
- Which files changed
- The nature of each change (1 sentence per file)
- Whether anything looks unexpected or unintended

## 3. Secret gate (ENFORCED, a script decides, not judgment)
After staging (or on what's about to be staged), run the deterministic scanner:
`secret-scan.sh` (on PATH through the Odeo plugin).
- **Exit 0:** clean, continue.
- **Exit 1: BLOCKED.** Show the findings verbatim. The user must remove the
  secret (env var / secrets manager) or unstage the file; if the value was real,
  it is treated as leaked, rotate it. Re-run until clean. There is no
  "commit anyway" override for secrets.
Also eyeball for sensitive files the scanner can't judge by pattern
(`credentials.json`, `firebase-adminsdk*.json`) and raise them.
(The pre-commit hook runs the same scanner, this step catches it earlier and
covers repos without hooks installed.)

## 4. Run local checks
Read the project's `CLAUDE.md` to find the test and typecheck commands.

Run them in order. If either fails:
- STOP
- Show the user the failure
- Ask: "Tests/typecheck failed. Fix before committing, or commit anyway and fix in next commit?"

## 5. Stage appropriate files
Ask the user: "Ready to stage all changes, or do you want to exclude something?"

Based on their response, run `git add` appropriately. Default to `git add -A` if they approve everything.

## 6. Propose commit message
Analyze the changes and propose a commit message in Conventional Commits format:

```
type(scope): short imperative description

Optional body explaining *why*, not *what*. Keep lines under 72 chars.
```

Types:
- `feat`, new feature
- `fix`, bug fix
- `chore`, maintenance, dependencies, build config
- `docs`, documentation only
- `refactor`, code change without behavior change
- `test`, adding or fixing tests
- `style`, formatting, whitespace
- `perf`, performance improvement

Show the message to the user. Wait for approval or edits.

## 7. Commit
Run `git commit -m "<approved-message>"`.

If the message has a body, use a heredoc:
```bash
git commit -m "$(cat <<'EOF'
type(scope): description

Body text.
EOF
)"
```

## 8. Push
Run `git branch --show-current` again to get the current branch name.

- If this is the branch's first push: `git push -u origin <branch-name>`
- If already tracking remote: `git push`

Never use `--force` or `--force-with-lease` without explicit approval from the user.

## 9. Confirm
Show the user:
- The final commit hash and message
- The branch name
- The remote URL if visible
- A reminder: "Branch pushed. Next step is opening a Pull Request on your Git host."

## Safety Rules
- Never amend commits that are already pushed to shared branches
- Never rewrite history on `main` or `master`
- Never push if local checks failed without explicit user override
- Never bypass pre-commit hooks with `--no-verify` without asking
