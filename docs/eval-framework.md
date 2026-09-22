# Eval framework

How this system measures quality, proves improvement, and prevents regressions.
One shared model for every artifact type: code, UI, PM documents, and skills.

## What an eval is
An eval is a systematic, repeatable way to SCORE the quality of an output and to
tell whether a change made things better or worse. It is the "proof" step of every
loop: nothing passes a gate on good vibes.

## The shared model (five parts, same everywhere)

```
RUBRIC (data)          what "good" means: named criteria + levels + a pass threshold
   |  used by
SCORER (who judges)    deterministic script | reviewer agent (LLM judge) | human
   |  writes
EVAL RECORD (file)     scores per criterion + findings + verdict + version + date
   |  saved in git
BASELINE / REGRESSION  compare the new record to the previous one: better or worse?
   |  feeds
FEEDBACK LOOP          repeated failures become lessons/knowledge or an /improve run
```

## Rubrics
- A rubric = named criteria, scoring levels (0 to 2 per criterion), and a pass
  threshold (for example: total >= 8/10 AND no criterion at 0).
- Rubrics are DATA, not agents. Each lives next to the skill that produces the
  artifact it judges: `skills/prd/rubric.md`, `skills/stories/rubric.md`.
  The skill rubric lives in `docs/skill-authoring-standard.md` (it judges skills
  themselves). Code and UI rubrics live inside `code-reviewer` and `design-reviewer`.
- Anyone can read a rubric and know exactly what the bar is. That is the point.

## Scorers (three kinds, they combine)
1. **Deterministic**, scripts and tests: test suite, lint, typecheck,
   `privacy-scan.sh`. Exit codes, no judgment. Strongest form.
2. **Reviewer agents (LLM judge)**, each owns one domain and scores against the
   domain rubric: `code-reviewer` (code), `design-reviewer` (UI), `pm-reviewer`
   (PM documents), `skill-reviewer` (skills), `agent-reviewer` (agent definitions
   in `agents/`). Independent from whoever produced
   the artifact, and they can score BLIND (they see artifacts, not who or what
  version made them), which is how subagent A/B tests stay honest.
3. **Human**, the final gate. Taste and context advantage; you approve or reject.

## Eval records
One small file per artifact in the project's `docs/evals/`, overwritten on each
new eval. Git history is the archive, so "compare to last time" = read the file,
then `git log`/`git show` for the previous version.

```markdown
docs/evals/PRD-007.md
---
artifact: PRD-007        # or covers: USR-001 USR-002 ... for a set (spec-gate matches these)
type: prd
branch: feature/usr-007-password-reset   # required for code/UI records; merge-gate matches on it
reviewed_commit: 4f2a1c9  # the commit you actually read. merge-gate verifies no non-evals
                          # file moved since, because a timestamp cannot tell that a record
                          # describes superseded text. Required on records dated 2026-08-05
                          # or later; earlier records are exempt (no hand migration).
                          # If the code moves, REGENERATE the record, never re-date it.
artifact_version: 3
date: 2026-07-07
scorer: pm-reviewer
model: <exact model that judged, as the agent's context reports it>
model_tier: strong
effort: high             # the judge's effort level (declared in the agent frontmatter); provenance
build_model_as_dispatched: <model>  # CODE records only, after a for-me build: the model
#                         the orchestrator dispatched the BUILDER on, handed to you the
#                         same way the commit sha is. It lives HERE and not in the plan
#                         because merge-gate compares every non-evals path against
#                         reviewed_commit:, so a post-review plan edit would force a full
#                         code re-review for one provenance line, while this file is
#                         excluded from that comparison by construction. Named "as
#                         dispatched", not "as ran": nobody here can verify which model
#                         the vendor served, so it discloses what was REQUESTED. Omit it
#                         when you were given no value; never guess one.
# tier vocabulary: fast | strong | strongest; the gates enforce the floor and
# read the value only, keep the model_tier line clean like the verdict line.
# (Records written before this field existed refuse once; regenerate via the reviewer.)
scores: { problem: 2, outcome: 2, scope: 1, risks: 2, security: 2 }
total: 9/10
verdict: PASS
# (threshold comes from the rubric; the verdict line stays clean, the merge gate reads it)
previous_total: 7/10   # regression check: improved
---
Findings: scope still lists two nice-to-haves without a cut line.
Change vs previous version: outcome criterion went 1 -> 2 (metric + target added).
```

Records are used for: gates (did it pass the threshold?), regression (better than
last time?), `/improve` signals (repeated drops on the same criterion), and blind
scoring in subagent tests.

## docs/evals is machine-owned (enforced)

`merge-gate.sh` requires that EVERY tracked file under `docs/evals/` be a parseable
record: frontmatter opening the file with `---` and closing with `---`. A tracked file
that is not (a README, a note, a stray draft) refuses merges from EVERY branch, because the
parse check runs before branch matching, and because
the gate cannot tell which branch it reviews, and skipping it would let a malformed
REFUSAL hide behind a sibling approval.

Practical consequences:
- Do not put documentation in `docs/evals/`. It belongs in `docs/`.
- GITIGNORED files are ignored by the gate, so a `.DS_Store` or `Thumbs.db` is harmless.
  An UNTRACKED non-ignored file under `docs/evals/` is refused explicitly, by name, because
  a record only counts once committed and an uncommitted one could hide a refusal. That
  check does not depend on `status.showUntrackedFiles`.
- Records are written and regenerated by reviewers, never hand-edited to pass a gate.

## Second-opinion records (a consult, not a gate)
A paid cross-model review (see `docs/second-opinion-protocol.md`) writes its own
record at `docs/evals/second-opinion-<target>-<id>.md`. It fits the family above
and adds provenance for what actually ran plus a comparison authored by OUR
matching reviewer. It NEVER carries a gate `verdict:` (it informs); OUR reviewer's
own record still holds the verdict the gate reads. Critically, it uses
`related_branch:` NOT `branch:`, so the `merge-gate` (which matches `^branch:` and
then requires a verdict) never picks up this verdict-less record.

```markdown
docs/evals/second-opinion-code-usr-012.md
---
artifact: USR-012
type: second-opinion
target: code                 # code | plan | pm | design
related_branch: feature/usr-012-timer   # association only; NOT the gate-matched 'branch:'
date: 2026-07-19
vendor: <vendor>             # the CLI used (an argument, never a baked-in name)
vendor_model: <model>        # what ACTUALLY answered, from the provenance stamp
raw_log: docs/second-opinion-logs/code-<vendor>-<stamp>.log   # gitignored
output_sha256: <hash>        # integrity of the raw transcript
scorer: code-reviewer        # OUR matching reviewer authored the comparison
model: <model that judged ours>
model_tier: strongest
# NO verdict line: a second opinion informs, it does not gate.
---
## Findings (structured)
- target=code | class=correctness | app.ts:42 | High | off-by-one on the last page
## Comparison
- overlap: [findings both OUR reviewer and the vendor raised]
- only-ours: [what our reviewer caught that the vendor missed]
- only-vendor: [what the vendor caught that we missed, the value we paid for]
- recommendation: [what to do; our verdict is unchanged, in its own record]
```

Recurring `only-vendor` classes are the `/improve` signal that upgrades OUR
reviewers (the absorption loop in the protocol).

## Rigor allocation (risk-based)
Testing effort is proportional to the risk of being wrong:
- **Content artifacts** (PRD, memo, stories): rubric scoring by the domain
  reviewer. Cheap, and mistakes are caught by later layers (critique, human gate).
- **Skill changes**: subagent A/B testing via `/improve`. Full rigor (5+
  repetitions per variant) is reserved for discipline-critical skills
  (guardrails, TDD, merge, privacy). The user can request full rigor on anything.
- **Code**: deterministic first (tests, lint), then `code-reviewer` scoring.

## Community sharing (opt-in)
Improved rubrics and eval learnings can be contributed to the community knowledge
base through `/contribute-lesson`, the same path as lessons: sanitize, privacy-scan
(hard gate), show exactly what leaves, your approval, maintainer curation. Nothing
is shared automatically.

## Honesty rules (apply to every scorer)
- Never fabricate scores or data. No evidence = say so, don't estimate.
- Score against the rubric, not against sympathy for the author (there is none,
  scoring is blind where possible).
- A verdict is always produced, and always explained per criterion.
- Report **round-by-round** across re-reviews (Round 1 score -> final, and whether it
  moved), and ALWAYS state the achievable **ceiling**: if a criterion structurally caps
  below max for this artifact (e.g. safety integration = 1 when no guardrail applies is
  correct, not a defect), say the max reachable and why. No one should have to wonder
  "why not full marks".

### The review loop's STOP CONDITION (required by AGENTS.md: every loop declares one)

The review loop is an autonomous loop, so it needs a declared stop, not a human asking
"should this be the last round?" each time. It stops on the FIRST of these:

1. **APPROVE**, or **PASS** where the reviewer uses that word. The verdict clears **the
   threshold declared by the rubric for THAT artifact type**, with no criterion at 0 and
   no Critical. The normal exit.

   The number lives in the rubric and only there. It is not repeated in this file on
   purpose: the totals differ by type (code and UI are scored out of 12, skills, agent
   definitions and plans out of 10), and a second copy of a number is the exact shape of
   drift this framework exists to prevent. Read it where it is declared:

   | Artifact | Rubric that declares the threshold |
   |---|---|
   | Code | `agents/code-reviewer.md`, Scoring |
   | UI / design | `agents/design-reviewer.md`, Scoring |
   | Skill | `docs/skill-authoring-standard.md`, the rubric section |
   | Agent definition | `agents/agent-rubric.md` |
   | Implementation plan | `docs/plan-format.md`, the plan rubric (see the note below) |
   | PM document | the rubric shipped with the producing skill (`agents/pm-reviewer.md` step 1) |

   **The plan loop is the one exit without a number.** `architecture-reviewer` writes no
   record and publishes no score, so its clearing verdict is **clean** (no real findings
   left), recorded by the orchestrator as `arch_review: clean (v<N>, <date>)` in the plan's
   frontmatter, per `skills/build/SKILL.md`, mode B5 step 2. Stop conditions 2 and 3 below apply to
   it unchanged. The plan rubric still governs WHAT the reviewer checks; it just is not the
   thing the loop reads to stop.

   Worked example: a code review scoring 9/12 with `security: 0` does NOT stop the loop.
   It clears the total in `agents/code-reviewer.md` and still fails the same rubric's
   "no criterion at 0", so the loop continues to round two.
2. **THREE ROUNDS on the same artifact**, whatever the score. Stop, do not dispatch a
   fourth, and hand the human: what is still open, what moved between rounds, and what did
   not. Three rounds that have not converged is evidence about the CHANGE, not a reason to
   buy a fourth opinion.
3. **TWO CONSECUTIVE ROUNDS raising findings of the SAME CLASS.** Stop immediately, even
   at round two, and say so. A recurring class means the last fix was an instance patch,
   and the next one will be too. This is Core Principles ("stop patching a recurring
   class; eliminate it or escalate") applied to the loop that keeps discovering it.
   **Same class, operationally**, since "class" is otherwise a word two reviewers read
   differently: the new finding would be closed by the SAME KIND of fix as the previous
   one (another spelling in the same denylist, another branch of the same conditional,
   another wording of the same claim), and closing it would leave the same next instance
   possible. Two findings in one file, or sharing a severity, are NOT the same class.
   The test is the shape of the fix, not the location of the defect. State the class in
   one phrase when invoking this, so the human can judge whether it is real.

Why the cap is three and not higher, stated so nobody quietly raises it: measured on the
USR-006 and community-knowledge branches, rounds 2, 3 and 4 each returned the same defect
class, and each fix moved the failure rather than removing it. The loop was not converging,
it was circling, and the human paid for four rounds to learn something round two already
showed. Four is what those branches cost before this cap existed, not a competing cap: the
cap is three. A cap makes that visible on schedule instead of by someone's patience running
out.

**What STOP does not mean.** It is not "ship it". The branch stays blocked by the gate if
the record does not approve; the loop simply stops spending rounds and gives the human the
decision, which is where a judgment about cost belongs. And a **Critical always overrides**
the cap: a security or data-loss finding is reported whenever it is found, including at
round four, because a cap is a budget on attention, never a budget on safety.
- Flag **volatile external facts** stated as current without a source (model
  names/versions, prices, "the latest X", benchmarks, ownership, recent dates): the
  artifact must cite a source or label them `unverified`, never assert them from memory.
