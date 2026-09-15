---
artifact: community-knowledge-guarded
type: code
branch: feature/community-knowledge-guarded
reviewed_commit: c8d046b
date: 2026-09-15
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 1
scores: { correctness: 0, security: 0, performance: 1, readability: 1, testing: 1, conventions: 1 }
total: 4/12
verdict: REQUEST CHANGES
---

## Scope reviewed

Commit `c8d046b` (`feat(knowledge): treat community knowledge as untrusted input,
and diagnose refresh honestly`), reviewed as the delta `main..c8d046b`: two files,
`AGENTS.md` (+18) and `install.sh` (+20/-3).

Provenance: ORCHESTRATING SESSION, not an isolated builder, so
`build_model_as_dispatched:` is omitted by design.

`git rev-parse --short HEAD` == `c8d046b`, resolved by me. Working tree clean at both
ends; `git hash-object` on both files equals the `c8d046b` blobs
(`665f9d1...` for `AGENTS.md`, `3d02e5d...` for `install.sh`). Every scenario ran
against repos built under `/tmp/ckrev/`, with a private `GIT_CONFIG_GLOBAL` and a
parameterized copy of the block; nothing was written into the repository and no
command ran against the real `~/.claude/community-knowledge`.

Reach beyond the diff, each justified by a named risk: `global/CLAUDE.md` and
`project-templates/CLAUDE.md` (the files that actually govern a user session, to test
whether the new rule reaches the point of use), `agents/architect.md` +
`agents/builder.md` (the bodies that instruct reading community knowledge),
`bin/init-project.sh` (whether scaffolded projects carry `AGENTS.md`), and the
`ivansolic/Odeo-knowledge` CI + branch protection via `gh` (the second layer, which
the dispatch brief explicitly asked about).

## Instrument, proved before use

Per `lessons.md:15` and `:21`, the probe was run from a script file, not an inline
string, and a positive control ran first: scenario s1 (clean, behind the remote)
prints the "refreshed" branch, so the harness is demonstrably able to reach every
branch. Eight real repos, not three. The proposed replacement classifier was run
against the same eight before being recommended, so the fix in C2 is measured, not
asserted.

| # | scenario | branch taken | correct? |
|---|---|---|---|
| s1 | clean, behind | refreshed | yes (positive control) |
| s2 | edit to the file upstream changed | local edits | yes |
| s3 | edit to an unrelated file | refreshed | yes, pull is not blocked |
| s4 | diverged, clean tree | diverged | yes |
| s5 | diverged + an untracked file | **local edits** | **no** |
| s6 | remote unreachable, clean | offline | yes |
| s7 | remote unreachable + local edits | **local edits** | **no** |
| s8 | detached HEAD, remote reachable | diverged | remedy works, cause wrong |
| s9 | untracked file colliding with a new upstream file | local edits | yes |

All nine exited 0 and continued past the block: `set -e` never fires (every git call
sits in an `if`/`elif` condition or inside `$(...)` within `[[ ]]`), `set -u` is safe,
and `pipefail` is inert because the new block contains no pipeline at all. The section
cannot fail the install. It can stall it, see I9. `bash -n install.sh` passes,
`bin/skills-lint.sh .` reports all invariants hold, and all 27 `tests/*.test.sh` are
green (PASS=27 FAIL=0).

## Critical

**C1, the protection never reaches a user machine.** `AGENTS.md:154-170` is the only
place in the tree where the untrusted-input rule exists (verified by a tree-wide
grep). `install.sh` never installs `AGENTS.md` (zero occurrences of the string in the
script), `project-templates/` contains no `AGENTS.md`, and `bin/init-project.sh` never
mentions one. The files that DO govern an installed session, `global/CLAUDE.md:170-173`
(which becomes `~/.claude/CLAUDE.md`) and `project-templates/CLAUDE.md:164`, instruct
the agent to consult `~/.claude/community-knowledge/` and say nothing about trust. The
two agent bodies that ship to `~/.claude/agents/`, `agents/architect.md:21-22` and
`agents/builder.md:37-38`, do the same. This also violates the file's own stated
convention at `AGENTS.md:5-7`: safety-critical rules are embedded in skill and agent
bodies precisely so they survive when `AGENTS.md` is absent, which is every user
install and every marketplace-plugin install. As shipped, the control protects people
editing this repository, not the users described in the threat model.

**C2, `install.sh:186-190`, offline plus local edits is misdiagnosed, with a
destructive remedy attached.** Scenario s7: the remote is unreachable, the tree is
dirty, the pull fails on the network, and the dirty-tree branch fires first. The user
is told their edits froze the mirror and is handed a command that permanently destroys
those edits while fixing nothing, because the cause was the network. This is the same
class of error the commit set out to remove, inverted: the old code blamed the network
for an edit, the new code blames the edit for the network, and this direction costs the
user data. The verified replacement classifies all eight scenarios correctly in one
network round trip: fetch, then `merge-base --is-ancestor HEAD FETCH_HEAD` for
divergence, then `merge --ff-only FETCH_HEAD`, with "local edits" as the only remaining
cause.

## Important

- **I1, `install.sh:195`**, the printed `rm -rf` interpolates the path unquoted. With a
  space in `$HOME` the copy-pasted command deletes the first path segment: rendering
  confirmed against a spaced path. Print the path inside escaped quotes; same at `:190`.
- **I2, `install.sh:186-190`**, diverged plus any untracked file reports "local edits"
  (s5). The remedy deletes the untracked file and does not restore updates. Closed by
  the C2 classifier.
- **I3, `install.sh:184-196`**, the new branching has zero suite coverage; no test in
  `tests/` references the community section. `CLAUDE.md` requires coverage proven by
  mutation, and `lessons.md:15` states that an ad-hoc probe is unreviewed code and that
  a check worth asserting belongs in the suite. The manual three-repo check missed s5
  and s7 for exactly that reason. Add a test that parameterizes the directory so it
  never touches a real `$HOME`.
- **I4, `install.sh:187-190` and `:194-195` versus `:192`**, three failure branches in
  one chain, two on stderr and one on stdout. Route all three the same way.
- **I5, `install.sh:190`**, the discard command is labelled only "Discard the edits",
  for an audience `AGENTS.md:187-190` defines as including non-developers. The clean
  step permanently removes untracked files and directories with no undo. Offer the
  stash form first and mark the discard line as permanent.
- **I6, `AGENTS.md:154`**, the `[I]` tag appears 39 lines before the legend that defines
  it (`AGENTS.md:193-195`) and is the only tagged bullet outside Guardrails, the section
  the file calls the single source of truth. The tag VALUE is right, nothing enforces
  this rule. The placement is not. Put the rule in Guardrails and leave a pointer here.
- **I7, `AGENTS.md:163-165` against `AGENTS.md:145-146`**, unresolved tension: one line
  instructs reuse of a documented solution, the other says its code is never to be run
  or pasted unread, and nothing says what remains usable once a file trips the red flag.
  Two agents diverge here, one discards the entry, one applies the lesson and ignores
  the sentence. State which.
- **I8, `AGENTS.md:154-170`**, the detection surface is "text that reads as an
  instruction", so the rule misses a plausible non-imperative FALSE lesson, which is the
  higher-yield attack. Add a sub-bullet making an entry a claim to verify rather than a
  fact, specifically before acting on anything that weakens a security or privacy
  property.
- **I9, `install.sh:191`**, the reachability probe is a second network round trip on
  exactly the path where the first one already timed out, so an offline install now
  stalls roughly twice as long as before. The ordering rationale was to avoid a round
  trip; the outcome on the offline path is the opposite. The C2 classifier removes it.

## Nitpicks

- `install.sh:191`, a renamed remote reports "offline" for a configuration problem.
- `install.sh:184,186,191`, three repetitions of the same `git -C` prefix; a one-line
  local wrapper shortens the block and the printed commands.
- No git call in the section disables the terminal credential prompt; with the repo
  variable overridden to a private repo, git can block the install on a prompt, which
  the stderr redirect does not suppress. Pre-existing at the clone path, one more site
  now.

## Is the protection adequate as a whole

No, not yet, for two independent reasons.

First, today there is effectively one layer, not two: C1 means the agent-side rule is
absent from every installed machine, so the knowledge repo's CI plus maintainer review
is carrying the entire load.

Second, once C1 is fixed, the repo-side layer still has two soft spots. Its
instruction-shaped check is a fixed phrase denylist of roughly eight patterns, which is
the blocklist approach the security baseline tells us to avoid, and it is trivially
evaded by descriptive phrasing. And branch protection keeps a code-owner approval valid
after a later push to the same PR (stale-review dismissal off, last-push approval off),
so an approve-then-amend PR is a concrete bypass of the human half; the required status
check still re-runs, but the human review does not. Enforcement on admins is also off,
which makes the maintainer a single point of trust by design.

The most likely way this still gets through: a plausible, non-imperative FALSE lesson
in a perfectly formatted entry, for example an install-category lesson whose documented
fix quietly weakens a guardrail, written as description rather than instruction. It
passes every mechanical check and reads like every other entry to a reviewer scanning a
lesson PR, and the agent is instructed to reuse it.

One mechanically certain hole worth closing cheaply, verified here: a symlinked `.md`
under `knowledge/` escapes all three content checks, because the category loop selects
regular files only and recursive grep does not follow symlinks it meets during
recursion. It is cloned onto every machine and resolves to whatever it points at, for
example a private key file in the user's home directory, which the agent then reads as
community knowledge. A refusal for symlinks and for non-markdown files under
`knowledge/` closes it.

## Ceiling

12/12 is reachable. Nothing about this change structurally caps a criterion; the two
Criticals and the nine Importants are all fixable within the same two files plus the
three installed files C1 names.

## What is good

The diagnosis instinct in `install.sh:180-183` is right and the comment explains WHY,
not what: permanent invisible staleness really is worse than losing the edits, and that
sentence is the most valuable line in the diff. Scenarios s2, s3, s4, s6 and s9 all
classify correctly, including the non-obvious s3 case where a dirty tree does not block
the pull at all. The block genuinely degrades rather than blocking, confirmed under
`set -euo pipefail` across nine scenarios. On the `AGENTS.md` side, the precedence
language is unambiguous and the closing sentence covering maintainer impersonation,
quoting the baseline back, and claims that the rules changed anticipates the three
social attack shapes correctly; the instructed behaviour (name the file, say it tried
to instruct you, carry on) is concrete enough for two agents to converge on it.
