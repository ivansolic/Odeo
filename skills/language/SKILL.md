---
description: Show or change the language your generated documents are written in (PRDs, stories, plans, reviews). "/odeo:language" reports the current language and where it is set; "/odeo:language de" sets it for this project; "/odeo:language de --global" changes your default for all projects. Supported codes: en, de, hr, fr. Explicit command; code, filenames, commit messages, and every machine-read field stay English. Example: "/odeo:language hr".
disable-model-invocation: true
---

# Language (show or change the output language)

Set which language the system WRITES your documents in, at any time, without
editing a file by hand. The preference is one line, `output_language: <code>`,
the same line the resolver reads; this command shows it and changes it.

## When to use (and when not)
- You want to know which language your documents come out in right now, and which
  level set it: this project, or your global default.
- You want to change it: for this project only (the default), or everywhere
  (`--global`).
- Not for documents that already exist: the setting applies to newly generated
  prose, never retro-translates.
- Not for code, comments, filenames, branch names, commit types, or frontmatter
  fields. Those stay English, and `language-guard.sh` is the enforced gate for it
  (see AGENTS.md).
- Supported codes: `en`, `de`, `hr`, `fr`. Anything else is refused by the script.
  Relay its refusal message unchanged, whatever it is; never pick a code for the user.

## Process
The scripts are on PATH through the Odeo plugin. The project is the repo root:
`root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`.

**Show, `/odeo:language` with no argument:**
1. Run `language-status.sh "$root"`. It prints one line, `<code> <scope>`, where
   scope is `project`, `global`, or `default` (the built-in English fallback).
2. Report it plainly: name the language and where it comes from, for example
   "German (de), set for this project", "Croatian (hr), inherited from your global
   default", or "English (en), the default, nothing is set".

**Set for this project, `/odeo:language <code>` (the default scope):**
1. Run `set-project-language.sh "$root" <code>`. A non-zero exit is a refusal:
   relay its message unchanged and stop.
2. Re-run `language-status.sh "$root"` and report the new state.

**Set your global default, `/odeo:language <code> --global`:**
1. Run `set-global-language.sh <code> --overwrite`. The flag is what allows a
   CHANGE; without it the writer deliberately leaves an existing value alone,
   which is what keeps the install-time question a one-time question.
2. Re-run `language-status.sh "$root"`. If the scope still reads `project`, say
   so: this project's own line still wins, and offer `/odeo:language <code>` to change
   it here too.

**Scope words map to the flag, they are never passed to a script.** "global",
"globally", "everywhere", "all projects", "my default" mean `--global`, anywhere in
the user's message. "here", "this project", "this repo", or no scope word at all
mean the default project scope. Pass ONLY the code to the script; passing a scope
word as an argument produces a confusing usage error.

If the user names a language instead of a code, map only these; pass anything else
through unchanged so the script refuses it:

| The user says | Code |
|---|---|
| English | `en` |
| German, Deutsch | `de` |
| Croatian, Hrvatski | `hr` |
| French, Francais | `fr` |

Codes are lowercase: lowercase the code the user typed before passing it (`DE` -> `de`).
That is not picking a code and never widens the set.

## Worked example
Working in `~/code/shop`, whose CLAUDE.md carries `output_language: en`, with a
global default of `de`:

- "/odeo:language" -> `language-status.sh ~/code/shop` prints `en project` -> "English
  (en), set for this project. Your global default is separate."
- "/odeo:language hr" -> `set-project-language.sh ~/code/shop hr` prints "project
  output language set to hr", status now prints `hr project` -> "Croatian (hr)
  from now on, in this project. Documents already written stay as they are."
- "/odeo:language hr" again -> CLAUDE.md still has exactly one `output_language:` line;
  the value is replaced, never appended.
- "/odeo:language klingon" -> the script exits 1 with "unknown language: klingon
  (allowed: en de hr fr)". Relay it; do not guess a code.
- "/odeo:language fr --global" -> `set-global-language.sh fr --overwrite` changes the
  global default, and status still prints `hr project`, so: "Your default for new
  projects is French now. This project still has Croatian; run /odeo:language fr here
  if you want to change that too."
- "/odeo:language de" in a directory with NO `CLAUDE.md` -> the script exits 1 with "no
  CLAUDE.md in <dir>". Do NOT create the file. Say: "This project has no CLAUDE.md
  yet, so there is nothing to set the language on. Want me to run /odeo:setup-project? It
  configures the project and asks for the language as part of setup. If you would
  rather not configure this project, /odeo:language de --global changes your default for
  all projects instead." Then wait for the answer.
- "/odeo:language German everywhere" -> "everywhere" is a scope word, so this is
  `set-global-language.sh de --overwrite`; only `de` reaches the script.

## Output
- No document. The change is one line: `output_language: <code>` in this project's
  `CLAUDE.md` (project scope) or in your global config `~/.claude/CLAUDE.md`
  (global scope). Exactly one such line per file.
- The next generated document (PRD, story, plan, review write-up) follows it.

## Rules
- The scripts own validation and the write. Never hand-edit either file to help
  the command along, and never widen the code set here.
- If this project has no `CLAUDE.md`, do not create one and do not write the line
  yourself. Relay the refusal, then OFFER to run `/odeo:setup-project` for the user (it
  configures the project properly and asks for the language as part of setup), and
  name `/odeo:language <code> --global` as the alternative if they do not want to
  configure this project at all. Wait for their answer; never run setup unasked.
  That file is `/odeo:setup-project`'s artifact.
- A `--global` change refuses a symlinked global config (a `--link` install points
  it at a tracked repo file). Relay the refusal and offer project scope instead.
- Machine surfaces stay English whatever the code is; the guardrails in AGENTS.md
  hold as written (referenced here, not restated).
